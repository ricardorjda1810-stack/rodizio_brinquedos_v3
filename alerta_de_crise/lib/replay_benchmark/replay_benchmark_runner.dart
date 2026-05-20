import 'package:drift/drift.dart';

import '../database/signalflow_database.dart';
import 'replay_benchmark_models.dart';
import 'replay_validation_metrics.dart';

class ReplayBenchmarkRunner {
  final SignalFlowDatabase _database;
  final ReplayValidationMetrics _metrics;
  final DateTime Function() _now;

  ReplayBenchmarkRunner({
    SignalFlowDatabase? database,
    ReplayValidationMetrics metrics = const ReplayValidationMetrics(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _metrics = metrics,
       _now = now ?? DateTime.now;

  Future<ReplayBenchmarkResult> runBenchmark({
    required String sessionId,
    required String replayScenario,
    required List<double> expectedForecasts,
    required List<double> replayForecasts,
    required List<double> expectedRecovery,
    required List<double> replayRecovery,
    required List<double> confidenceScores,
    required List<double> multimodalAgreementScores,
    int falseEscalations = 0,
    int totalReplays = 1,
    bool persist = false,
  }) async {
    final forecastConsistency = _metrics.forecastAgreement(
      expectedForecasts,
      replayForecasts,
    );
    final recoveryConsistency = _metrics.recoveryAgreement(
      expectedRecovery,
      replayRecovery,
    );
    final falseEscalationRate = _metrics.falseEscalationRate(
      falseEscalations: falseEscalations,
      totalReplays: totalReplays,
    );
    final confidenceConsistency = _metrics.confidenceStability(
      confidenceScores,
    );
    final multimodalAgreement = _metrics.multimodalConsistency(
      multimodalAgreementScores,
    );
    final escalationDetectionRate = (100 - falseEscalationRate)
        .clamp(0, 100)
        .toDouble();
    final benchmarkScore = calculateBenchmarkScore(
      forecastConsistency: forecastConsistency,
      recoveryConsistency: recoveryConsistency,
      escalationDetectionRate: escalationDetectionRate,
      falseEscalationRate: falseEscalationRate,
      multimodalAgreement: multimodalAgreement,
      confidenceConsistency: confidenceConsistency,
    );
    final createdAt = _now();
    final result = ReplayBenchmarkResult(
      id: 'benchmark-$sessionId-${createdAt.microsecondsSinceEpoch}',
      createdAt: createdAt,
      sessionId: sessionId,
      replayScenario: replayScenario,
      forecastConsistency: forecastConsistency,
      recoveryConsistency: recoveryConsistency,
      escalationDetectionRate: escalationDetectionRate,
      falseEscalationRate: falseEscalationRate,
      multimodalAgreement: multimodalAgreement,
      confidenceConsistency: confidenceConsistency,
      benchmarkScore: benchmarkScore,
    );
    if (persist) {
      await persistResult(result);
    }
    return result;
  }

  Future<List<ReplayBenchmarkResult>> compareReplayStrategies({
    required String sessionId,
    required Map<String, List<double>> strategyForecasts,
    required List<double> expectedForecasts,
  }) async {
    final results = <ReplayBenchmarkResult>[];
    for (final entry in strategyForecasts.entries) {
      results.add(
        await runBenchmark(
          sessionId: sessionId,
          replayScenario: entry.key,
          expectedForecasts: expectedForecasts,
          replayForecasts: entry.value,
          expectedRecovery: const [80, 78, 76],
          replayRecovery: const [79, 77, 75],
          confidenceScores: const [82, 84, 83],
          multimodalAgreementScores: const [80, 82, 81],
        ),
      );
    }
    return results;
  }

  double calculateBenchmarkScore({
    required double forecastConsistency,
    required double recoveryConsistency,
    required double escalationDetectionRate,
    required double falseEscalationRate,
    required double multimodalAgreement,
    required double confidenceConsistency,
  }) {
    final weighted =
        (forecastConsistency * 0.22) +
        (recoveryConsistency * 0.18) +
        (escalationDetectionRate * 0.18) +
        ((100 - falseEscalationRate) * 0.12) +
        (multimodalAgreement * 0.15) +
        (confidenceConsistency * 0.15);
    return weighted.clamp(0, 100).toDouble();
  }

  Future<void> persistResult(ReplayBenchmarkResult result) async {
    await _database
        .into(_database.replayBenchmarkResultsTable)
        .insertOnConflictUpdate(_companion(result));
  }

  Future<List<ReplayBenchmarkResult>> loadResults({int limit = 20}) async {
    final query = _database.select(_database.replayBenchmarkResultsTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  ReplayBenchmarkResultsTableCompanion _companion(
    ReplayBenchmarkResult result,
  ) {
    return ReplayBenchmarkResultsTableCompanion.insert(
      id: result.id,
      createdAt: result.createdAt,
      sessionId: result.sessionId,
      replayScenario: result.replayScenario,
      forecastConsistency: result.forecastConsistency,
      recoveryConsistency: result.recoveryConsistency,
      escalationDetectionRate: result.escalationDetectionRate,
      falseEscalationRate: result.falseEscalationRate,
      multimodalAgreement: result.multimodalAgreement,
      confidenceConsistency: result.confidenceConsistency,
      benchmarkScore: result.benchmarkScore,
      safetyCopy: result.safetyCopy,
    );
  }

  ReplayBenchmarkResult _fromRow(ReplayBenchmarkResultsTableData row) {
    return ReplayBenchmarkResult(
      id: row.id,
      createdAt: row.createdAt,
      sessionId: row.sessionId,
      replayScenario: row.replayScenario,
      forecastConsistency: row.forecastConsistency,
      recoveryConsistency: row.recoveryConsistency,
      escalationDetectionRate: row.escalationDetectionRate,
      falseEscalationRate: row.falseEscalationRate,
      multimodalAgreement: row.multimodalAgreement,
      confidenceConsistency: row.confidenceConsistency,
      benchmarkScore: row.benchmarkScore,
    );
  }
}
