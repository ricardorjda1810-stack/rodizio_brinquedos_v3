import 'dart:math';

import 'package:drift/drift.dart';

import '../database/signalflow_database.dart';
import 'replay_engine_models.dart';

class ReplayValidationService {
  final SignalFlowDatabase _database;
  final DateTime Function() _now;

  ReplayValidationService({
    SignalFlowDatabase? database,
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _now = now ?? DateTime.now;

  ReplayValidationResult validateReplay(SyntheticReplayDataset dataset) {
    final generatedAt = _now();
    final replayConsistency = _calculateReplayConsistency(dataset);
    final timelineConsistency = _calculateTimelineConsistency(dataset);
    final forecastConsistency = _calculateForecastConsistency(dataset);
    final escalationScore = _calculateEscalationDetection(dataset);
    final recoveryScore = _calculateRecoveryModeling(dataset);

    return ReplayValidationResult(
      id: 'validation-${generatedAt.microsecondsSinceEpoch}',
      scenarioId: dataset.scenario.id,
      generatedAt: generatedAt,
      replayConsistency: replayConsistency,
      timelineConsistency: timelineConsistency,
      forecastConsistency: forecastConsistency,
      escalationDetectionScore: escalationScore,
      recoveryModelingScore: recoveryScore,
      findings: _findings(
        replayConsistency: replayConsistency,
        timelineConsistency: timelineConsistency,
        forecastConsistency: forecastConsistency,
      ),
    );
  }

  Future<void> persistValidationResult(ReplayValidationResult result) async {
    await _database
        .into(_database.replayValidationResultsTable)
        .insertOnConflictUpdate(
          ReplayValidationResultsTableCompanion.insert(
            id: result.id,
            scenarioId: result.scenarioId,
            generatedAt: result.generatedAt,
            replayConsistency: result.replayConsistency,
            timelineConsistency: result.timelineConsistency,
            forecastConsistency: result.forecastConsistency,
            escalationDetectionScore: result.escalationDetectionScore,
            recoveryModelingScore: result.recoveryModelingScore,
            findings: result.findings.join('|'),
            safetyCopy: result.safetyCopy,
          ),
        );
  }

  Future<List<ReplayValidationResult>> loadValidationResults({
    int limit = 20,
  }) async {
    final query = _database.select(_database.replayValidationResultsTable)
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.generatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_resultFromRow).toList(growable: false);
  }

  double _calculateReplayConsistency(SyntheticReplayDataset dataset) {
    if (dataset.samples.length != dataset.scenario.sampleCount) {
      return 62;
    }
    if (dataset.samples.isEmpty) {
      return 0;
    }
    return 92;
  }

  double _calculateTimelineConsistency(SyntheticReplayDataset dataset) {
    if (dataset.samples.length < 2) {
      return dataset.samples.isEmpty ? 0 : 70;
    }
    var orderedPairs = 0;
    for (var i = 1; i < dataset.samples.length; i += 1) {
      if (!dataset.samples[i].timestamp.isBefore(
        dataset.samples[i - 1].timestamp,
      )) {
        orderedPairs += 1;
      }
    }
    return (orderedPairs / (dataset.samples.length - 1) * 100).clamp(0, 100);
  }

  double _calculateForecastConsistency(SyntheticReplayDataset dataset) {
    if (dataset.forecasts.isEmpty) {
      return 45;
    }
    final latest = dataset.forecasts.last.escalationProbability;
    final expected = switch (dataset.scenario.scenarioType) {
      ReplayScenarioType.stable => 20.0,
      ReplayScenarioType.recovery => 35.0,
      ReplayScenarioType.escalating ||
      ReplayScenarioType.contextualTrigger ||
      ReplayScenarioType.prolongedStress => 75.0,
      _ => 55.0,
    };
    return (100 - min((latest - expected).abs(), 100)).clamp(0, 100).toDouble();
  }

  double _calculateEscalationDetection(SyntheticReplayDataset dataset) {
    if (dataset.samples.length < 2) {
      return 0;
    }
    final first = dataset.samples.first;
    final last = dataset.samples.last;
    final hrRise = last.heartRateBpm - first.heartRateBpm;
    final hrvDrop = (first.hrvRmssdMs ?? 0) - (last.hrvRmssdMs ?? 0);
    return (50 + hrRise + hrvDrop).clamp(0, 100);
  }

  double _calculateRecoveryModeling(SyntheticReplayDataset dataset) {
    if (dataset.samples.length < 2) {
      return 0;
    }
    final first = dataset.samples.first;
    final last = dataset.samples.last;
    final hrRecovery = first.heartRateBpm - last.heartRateBpm;
    final hrvRecovery = (last.hrvRmssdMs ?? 0) - (first.hrvRmssdMs ?? 0);
    return (45 + hrRecovery + hrvRecovery).clamp(0, 100);
  }

  List<String> _findings({
    required double replayConsistency,
    required double timelineConsistency,
    required double forecastConsistency,
  }) {
    return [
      if (replayConsistency >= 80) 'replay fisiológico consistente',
      if (timelineConsistency >= 80) 'timeline ordenada para validação offline',
      if (forecastConsistency >= 70)
        'forecast compatível com cenário sintético',
      if (replayConsistency < 80 || timelineConsistency < 80)
        'revisar modelagem experimental',
    ];
  }

  ReplayValidationResult _resultFromRow(ReplayValidationResultsTableData row) {
    return ReplayValidationResult(
      id: row.id,
      scenarioId: row.scenarioId,
      generatedAt: row.generatedAt,
      replayConsistency: row.replayConsistency,
      timelineConsistency: row.timelineConsistency,
      forecastConsistency: row.forecastConsistency,
      escalationDetectionScore: row.escalationDetectionScore,
      recoveryModelingScore: row.recoveryModelingScore,
      findings: row.findings.isEmpty ? const [] : row.findings.split('|'),
    );
  }
}
