import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/calibration_lab/calibration_benchmark_service.dart';
import 'package:signalflow/calibration_lab/calibration_profile.dart';
import 'package:signalflow/calibration_lab/calibration_result_analysis.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/replay_benchmark/replay_benchmark_runner.dart';

void main() {
  group('CalibrationBenchmarkService', () {
    late SignalFlowDatabase database;
    late CalibrationBenchmarkService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = CalibrationBenchmarkService(
        database: database,
        runner: ReplayBenchmarkRunner(
          database: database,
          now: () => DateTime.utc(2026, 5, 18, 12),
        ),
        now: () => DateTime.utc(2026, 5, 18, 12, 1),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('runs benchmark by profile', () async {
      final result = await service.runCalibrationBenchmark(
        profile: CalibrationProfiles.balanced,
        sessionId: 'session-1',
      );

      expect(result.profile.id, 'balanced');
      expect(result.benchmarkScore, inInclusiveRange(0, 100));
      expect(result.forecastConsistency, greaterThan(80));
      expect(result.safetyCopy, contains('comparação de configuração'));
    });

    test('compares profiles and selects best profile', () async {
      final results = await service.compareProfiles(
        profiles: CalibrationProfiles.presets(),
        sessionId: 'session-1',
      );
      final best = await service.selectBestProfile(
        profiles: CalibrationProfiles.presets(),
        sessionId: 'session-1',
      );

      expect(results, hasLength(4));
      expect(results.first.rankingPosition, 1);
      expect(best.id, results.first.profile.id);
    });

    test('persists Drift profiles and benchmark results', () async {
      final result = await service.runCalibrationBenchmark(
        profile: CalibrationProfiles.recoveryFocused,
        sessionId: 'session-1',
        persist: true,
      );
      final profiles = await database
          .select(database.calibrationProfilesTable)
          .get();
      final results = await database
          .select(database.calibrationBenchmarkResultsTable)
          .get();
      final loaded = await service.loadResults();

      expect(profiles, hasLength(1));
      expect(results, hasLength(1));
      expect(results.single.id, result.id);
      expect(loaded, hasLength(1));
      expect(
        results.single.safetyCopy,
        contains('não representa validação clínica'),
      );
    });

    test('migration 19 to 20 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 21);
      final calibrationMigration = migrationService.registeredMigrations
          .firstWhere((migration) => migration.toVersion == 20);

      expect(calibrationMigration.fromVersion, 19);
      expect(calibrationMigration.toVersion, 20);
      expect(calibrationMigration.description, contains('Calibration lab'));
    });

    test('ranking is consistent', () async {
      final results = await service.compareProfiles(
        profiles: CalibrationProfiles.presets(),
        sessionId: 'session-1',
      );
      const analysis = CalibrationResultAnalysis();
      final ranked = analysis.rankResults(results);
      final summary = analysis.generateExperimentalSummary(results);

      expect(
        ranked.first.benchmarkScore,
        greaterThanOrEqualTo(ranked.last.benchmarkScore),
      );
      expect(
        analysis.calculateFinalScore(ranked.first),
        inInclusiveRange(0, 100),
      );
      expect(summary.join(' '), contains('validação offline'));
    });
  });
}
