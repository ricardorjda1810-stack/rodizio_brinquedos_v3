import 'package:drift/drift.dart';

import '../database/signalflow_database.dart';
import 'replay_engine_models.dart';
import 'replay_timeline_engine.dart';

class AdvancedReplayService {
  final SignalFlowDatabase _database;
  final DateTime Function() _now;
  ReplayTimelineEngine? _timelineEngine;
  ReplayScenario? _scenario;
  ReplayPlaybackState _state = ReplayPlaybackState.stopped;
  double _playbackSpeed = 1;

  AdvancedReplayService({
    SignalFlowDatabase? database,
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _now = now ?? DateTime.now;

  ReplayPlaybackState get state => _state;

  double get playbackSpeed => _playbackSpeed;

  Future<ReplaySession> startReplay({
    required SyntheticReplayDataset dataset,
    double playbackSpeed = 1,
    bool persistScenario = false,
  }) async {
    _scenario = dataset.scenario;
    _playbackSpeed = playbackSpeed.clamp(0.25, 8).toDouble();
    _timelineEngine = ReplayTimelineEngine(
      samples: dataset.samples,
      markers: dataset.markers,
      contextualEvents: dataset.contextualEvents,
      forecasts: dataset.forecasts,
    );
    _state = ReplayPlaybackState.running;
    if (persistScenario) {
      await persistScenarioRecord(dataset.scenario);
    }
    return _buildSession();
  }

  ReplaySession pauseReplay() {
    _state = ReplayPlaybackState.paused;
    return _buildSession();
  }

  ReplaySession resumeReplay() {
    _state = ReplayPlaybackState.running;
    return _buildSession();
  }

  ReplaySession stopReplay() {
    _state = ReplayPlaybackState.stopped;
    return _buildSession();
  }

  ReplaySession seekTimeline(Duration offset) {
    _timelineEngine?.seekTimeline(offset);
    return _buildSession();
  }

  ReplaySession stepForward() {
    _timelineEngine?.stepForward();
    return _buildSession();
  }

  ReplaySession stepBackward() {
    _timelineEngine?.stepBackward();
    return _buildSession();
  }

  Future<void> persistScenarioRecord(ReplayScenario scenario) async {
    await _database
        .into(_database.replayScenariosTable)
        .insertOnConflictUpdate(
          ReplayScenariosTableCompanion.insert(
            id: scenario.id,
            title: scenario.title,
            description: scenario.description,
            generatedAt: scenario.generatedAt,
            durationSeconds: scenario.duration.inSeconds,
            sampleCount: scenario.sampleCount,
            scenarioType: scenario.scenarioType.name,
            expectedEscalationLevel: scenario.expectedEscalationLevel,
            contextualFactors: scenario.contextualFactors.join('|'),
            safetyCopy: scenario.safetyCopy,
          ),
        );
  }

  Future<List<ReplayScenario>> loadScenarios({int limit = 20}) async {
    final query = _database.select(_database.replayScenariosTable)
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.generatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_scenarioFromRow).toList(growable: false);
  }

  ReplaySession _buildSession() {
    final scenario =
        _scenario ??
        ReplayScenario(
          id: 'empty-replay',
          title: 'Empty replay',
          description: 'simulação experimental vazia',
          generatedAt: _now(),
          duration: Duration.zero,
          sampleCount: 0,
          scenarioType: ReplayScenarioType.syntheticMixed,
          expectedEscalationLevel: 'unknown',
          contextualFactors: const [],
        );
    final state =
        _timelineEngine?.currentState() ??
        ReplayTimelineState(
          timestamp: scenario.generatedAt,
          sample: null,
          markers: const [],
          contextualEvents: const [],
          forecast: null,
          progress: 0,
          index: 0,
        );
    return ReplaySession(
      scenario: scenario,
      state: _state,
      playbackSpeed: _playbackSpeed,
      timelineState: state,
      updatedAt: _now(),
    );
  }

  ReplayScenario _scenarioFromRow(ReplayScenariosTableData row) {
    return ReplayScenario(
      id: row.id,
      title: row.title,
      description: row.description,
      generatedAt: row.generatedAt,
      duration: Duration(seconds: row.durationSeconds),
      sampleCount: row.sampleCount,
      scenarioType: ReplayScenarioType.values.byName(row.scenarioType),
      expectedEscalationLevel: row.expectedEscalationLevel,
      contextualFactors: row.contextualFactors.isEmpty
          ? const []
          : row.contextualFactors.split('|'),
    );
  }
}
