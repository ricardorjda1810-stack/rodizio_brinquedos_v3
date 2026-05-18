import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/research_dashboard/research_dashboard_service.dart';

void main() {
  group('ResearchDashboardService', () {
    late SignalFlowDatabase database;
    late ResearchDashboardService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = ResearchDashboardService(
        database: database,
        now: () => DateTime.utc(2026, 5, 17, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('generates consolidated dashboard metrics', () async {
      final snapshot = await service.generateDashboard(
        trends: [_trend(70, 44, 0.1, 20), _trend(90, 36, 0.5, 70)],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.8, resilience: 82, fatigue: 18),
        ],
      );

      expect(snapshot.metrics.averageHeartRate, 80);
      expect(snapshot.metrics.escalationCount, 1);
      expect(snapshot.metrics.recoveryEfficiency, 80);
      expect(snapshot.metrics.resilienceScore, 82);
      expect(snapshot.metrics.fatigueScore, 18);
    });

    test('persists dashboard snapshot', () async {
      final snapshot = await service.generateDashboard(
        trends: [_trend(82, 38, 0.4, 55)],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.5, resilience: 62, fatigue: 34),
        ],
        persist: true,
      );

      final rows = await database
          .select(database.researchDashboardSnapshotsTable)
          .get();
      final loaded = await service.loadSnapshots();

      expect(rows.single.id, snapshot.id);
      expect(loaded.single.metrics.escalationCount, 1);
      expect(loaded.single.insights.autonomicLoad, greaterThan(0));
    });

    test('migration 5 to 6 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 8);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 5 &&
              migration.toVersion == 6 &&
              migration.description.contains('Research dashboard'),
        ),
        isTrue,
      );
    });
  });
}

PhysiologicalTrend _trend(
  double heartRate,
  double hrv,
  double activationDensity,
  int escalationScore,
) {
  return PhysiologicalTrend(
    averageHeartRate: heartRate,
    averageHrv: hrv,
    hrvSlope: -0.2,
    heartRateSlope: 0.5,
    activationDensity: activationDensity,
    escalationScore: escalationScore,
    generatedAt: DateTime.utc(2026, 5, 17),
    window: TrendWindow.mediumTerm,
  );
}

AutonomicRecoveryProfile _recovery({
  required double recoveryRate,
  required int resilience,
  required int fatigue,
}) {
  return AutonomicRecoveryProfile(
    recoveryRate: recoveryRate,
    hrvRecoverySlope: 0.4,
    heartRateNormalization: recoveryRate,
    baselineReturnTime: const Duration(minutes: 15),
    resilienceScore: resilience,
    fatigueScore: fatigue,
    stressCarryover: fatigue / 100,
    generatedAt: DateTime.utc(2026, 5, 17),
    resilienceLevel: AutonomicResilienceLevel.stable,
  );
}
