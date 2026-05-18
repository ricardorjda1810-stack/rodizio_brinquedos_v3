import 'package:drift/drift.dart';

import '../core/crisis_detection/baseline_profile.dart';
import '../core/crisis_detection/crisis_risk_engine.dart';
import '../core/crisis_detection/physiological_sample.dart';
import '../database/signalflow_database.dart';
import 'physiological_stream_buffer.dart';
import 'realtime_stream_models.dart';
import 'rolling_window_service.dart';

class RealtimePipelineService {
  final SignalFlowDatabase _database;
  final RollingWindowService _rollingWindowService;
  final CrisisRiskEngine _riskEngine;
  final DateTime Function() _now;

  RealtimePipelineService({
    SignalFlowDatabase? database,
    RollingWindowService rollingWindowService = const RollingWindowService(),
    CrisisRiskEngine riskEngine = const CrisisRiskEngine(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _rollingWindowService = rollingWindowService,
       _riskEngine = riskEngine,
       _now = now ?? DateTime.now;

  Future<RealtimePipelineSnapshot> ingestSample({
    required PhysiologicalSample sample,
    required PhysiologicalStreamBuffer buffer,
    BaselineProfile? baseline,
    RealtimeStreamingState streamingState = RealtimeStreamingState.running,
    bool persist = false,
  }) async {
    buffer.addSample(sample);
    return processRealtimeUpdate(
      buffer: buffer,
      baseline: baseline,
      streamingState: streamingState,
      persist: persist,
    );
  }

  Future<RealtimePipelineSnapshot> processRealtimeUpdate({
    required PhysiologicalStreamBuffer buffer,
    BaselineProfile? baseline,
    RealtimeStreamingState streamingState = RealtimeStreamingState.running,
    bool persist = false,
  }) async {
    final snapshot = generateRealtimeSnapshot(
      buffer: buffer,
      baseline: baseline,
      streamingState: streamingState,
    );
    if (persist) {
      await persistSnapshot(snapshot);
    }
    return snapshot;
  }

  RealtimePipelineSnapshot generateRealtimeSnapshot({
    required PhysiologicalStreamBuffer buffer,
    BaselineProfile? baseline,
    RealtimeStreamingState streamingState = RealtimeStreamingState.running,
  }) {
    final generatedAt = _now();
    final window = _rollingWindowService.generateRollingWindow(
      samples: buffer.samples,
      duration: RollingWindow.shortDuration,
      now: generatedAt,
    );
    final metrics = _rollingWindowService.calculateRollingMetrics(
      window: window,
      baseline: baseline,
    );
    return RealtimePipelineSnapshot(
      id: 'realtime-${generatedAt.microsecondsSinceEpoch}',
      generatedAt: generatedAt,
      bufferSize: buffer.samples.length,
      rollingHeartRate: metrics.averageHeartRate,
      rollingHrv: metrics.averageHrv,
      rollingConfidence: metrics.confidence,
      rollingEscalationDensity: metrics.escalationDensity,
      latestEscalationProbability: _latestEscalationProbability(
        buffer.latestSample(),
        baseline,
      ),
      streamingState: streamingState,
    );
  }

  Future<void> persistSnapshot(RealtimePipelineSnapshot snapshot) async {
    await _database
        .into(_database.realtimePipelineSnapshotsTable)
        .insertOnConflictUpdate(
          RealtimePipelineSnapshotsTableCompanion.insert(
            id: snapshot.id,
            generatedAt: snapshot.generatedAt,
            bufferSize: snapshot.bufferSize,
            rollingHeartRate: snapshot.rollingHeartRate,
            rollingHrv: snapshot.rollingHrv,
            rollingConfidence: snapshot.rollingConfidence,
            rollingEscalationDensity: snapshot.rollingEscalationDensity,
            latestEscalationProbability: snapshot.latestEscalationProbability,
            streamingState: snapshot.streamingState.name,
            safetyCopy: snapshot.safetyCopy,
          ),
        );
  }

  Future<List<RealtimePipelineSnapshot>> loadSnapshots({int limit = 20}) async {
    final query = _database.select(_database.realtimePipelineSnapshotsTable)
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.generatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_snapshotFromRow).toList(growable: false);
  }

  double _latestEscalationProbability(
    PhysiologicalSample? sample,
    BaselineProfile? baseline,
  ) {
    if (sample == null || baseline == null) {
      return 0;
    }
    return _riskEngine
        .evaluate(sample: sample, baseline: baseline)
        .score
        .toDouble();
  }

  RealtimePipelineSnapshot _snapshotFromRow(
    RealtimePipelineSnapshotsTableData row,
  ) {
    return RealtimePipelineSnapshot(
      id: row.id,
      generatedAt: row.generatedAt,
      bufferSize: row.bufferSize,
      rollingHeartRate: row.rollingHeartRate,
      rollingHrv: row.rollingHrv,
      rollingConfidence: row.rollingConfidence,
      rollingEscalationDensity: row.rollingEscalationDensity,
      latestEscalationProbability: row.latestEscalationProbability,
      streamingState: RealtimeStreamingState.values.byName(row.streamingState),
    );
  }
}
