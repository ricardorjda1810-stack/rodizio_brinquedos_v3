import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/replay_benchmark/benchmark_result_analysis.dart';
import 'package:signalflow/replay_benchmark/replay_benchmark_runner.dart';

void main() {
  group('ReplayBenchmarkRunner', () {
    late SignalFlowDatabase database;
    late ReplayBenchmarkRunner runner;

    setUp(() {
      database = SignalFlowDatabase.memory();
      runner = ReplayBenchmarkRunner(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('executes benchmark and calculates score', () async {
      final result = await runner.runBenchmark(
        sessionId: 'session-1',
        replayScenario: 'standard',
        expectedForecasts: const [20, 40, 60],
        replayForecasts: const [22, 42, 58],
        expectedRecovery: const [90, 80, 70],
        replayRecovery: const [88, 78, 72],
        confidenceScores: const [80, 82, 81],
        multimodalAgreementScores: const [84, 85, 86],
      );

      expect(result.sessionId, 'session-1');
      expect(result.forecastConsistency, greaterThan(95));
      expect(result.recoveryConsistency, greaterThan(95));
      expect(result.benchmarkScore, greaterThan(90));
      expect(result.safetyCopy, contains('benchmark experimental'));
    });

    test('calculates false escalation rate', () async {
      final result = await runner.runBenchmark(
        sessionId: 'session-1',
        replayScenario: 'strict',
        expectedForecasts: const [20, 40],
        replayForecasts: const [20, 40],
        expectedRecovery: const [80, 75],
        replayRecovery: const [80, 75],
        confidenceScores: const [80, 80],
        multimodalAgreementScores: const [80, 80],
        falseEscalations: 1,
        totalReplays: 4,
      );

      expect(result.falseEscalationRate, 25);
      expect(result.escalationDetectionRate, 75);
    });

    test('persists Drift benchmark result', () async {
      final result = await runner.runBenchmark(
        sessionId: 'session-1',
        replayScenario: 'persisted',
        expectedForecasts: const [20, 30],
        replayForecasts: const [21, 31],
        expectedRecovery: const [80, 70],
        replayRecovery: const [79, 71],
        confidenceScores: const [84, 85],
        multimodalAgreementScores: const [82, 83],
        persist: true,
      );

      final rows = await database
          .select(database.replayBenchmarkResultsTable)
          .get();
      expect(rows, hasLength(1));
      expect(rows.single.id, result.id);
      expect(
        rows.single.safetyCopy,
        contains('não representa validação clínica'),
      );
    });

    test('migration 18 to 19 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 21);
      final replayMigration = migrationService.registeredMigrations.firstWhere(
        (migration) => migration.toVersion == 19,
      );

      expect(replayMigration.fromVersion, 18);
      expect(replayMigration.toVersion, 19);
      expect(replayMigration.description, contains('Replay benchmark'));
    });

    test('multimodal agreement and analysis are consistent', () async {
      final result = await runner.runBenchmark(
        sessionId: 'session-1',
        replayScenario: 'fusion',
        expectedForecasts: const [20, 30],
        replayForecasts: const [20, 30],
        expectedRecovery: const [80, 70],
        replayRecovery: const [80, 70],
        confidenceScores: const [90, 90, 90],
        multimodalAgreementScores: const [88, 90, 92],
      );
      const analysis = BenchmarkResultAnalysis();

      expect(result.multimodalAgreement, 90);
      expect(
        analysis.generateReplayQualityInsights(result),
        contains('acordo multimodal consistente no replay experimental.'),
      );
      expect(analysis.calculateInferenceStability([result]), 100);
    });
  });
}
