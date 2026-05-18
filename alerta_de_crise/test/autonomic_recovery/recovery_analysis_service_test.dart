import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/autonomic_recovery/recovery_analysis_service.dart';
import 'package:signalflow/core/crisis_detection/baseline_profile.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/session_timeline/physiological_event_marker.dart';

void main() {
  group('RecoveryAnalysisService', () {
    late SignalFlowDatabase database;
    late DateTime now;
    late RecoveryAnalysisService service;
    late BaselineProfile baseline;

    setUp(() {
      database = SignalFlowDatabase.memory();
      now = DateTime.utc(2026, 5, 17, 12);
      service = RecoveryAnalysisService(database: database, now: () => now);
      baseline = BaselineProfile.safeDefault();
    });

    tearDown(() async {
      await database.close();
    });

    test('detects return to baseline', () {
      final returnTime = service.calculateBaselineReturn(
        samples: [
          _sample(now.subtract(const Duration(minutes: 4)), 104, 28),
          _sample(now.subtract(const Duration(minutes: 2)), 82, 38),
          _sample(now, 74, 42),
        ],
        baseline: baseline,
      );

      expect(returnTime, const Duration(minutes: 4));
    });

    test('models fast recovery', () async {
      final profile = await service.analyzeRecovery(
        samples: [
          _sample(now.subtract(const Duration(minutes: 5)), 104, 28),
          _sample(now.subtract(const Duration(minutes: 3)), 84, 37),
          _sample(now, 74, 42),
        ],
        baseline: baseline,
        timelineId: 'fast',
      );

      expect(profile.baselineReturnTime, isNotNull);
      expect(profile.recoveryRate, greaterThan(0.5));
      expect(
        profile.resilienceLevel,
        isNot(AutonomicResilienceLevel.overloaded),
      );
    });

    test('models slow recovery', () async {
      final profile = await service.analyzeRecovery(
        samples: [
          _sample(now.subtract(const Duration(minutes: 25)), 108, 28),
          _sample(now.subtract(const Duration(minutes: 15)), 101, 29),
          _sample(now, 96, 30),
        ],
        baseline: baseline,
        markers: [
          _marker(now.subtract(const Duration(minutes: 20))),
          _marker(now.subtract(const Duration(minutes: 10))),
        ],
        timelineId: 'slow',
        previousStressCarryover: 0.4,
      );

      expect(profile.baselineReturnTime, isNull);
      expect(profile.recoveryRate, lessThan(0.5));
      expect(profile.fatigueScore, greaterThan(40));
    });

    test('persists recovery profile in Drift', () async {
      final profile = await service.analyzeRecovery(
        samples: [
          _sample(now.subtract(const Duration(minutes: 5)), 104, 28),
          _sample(now, 74, 42),
        ],
        baseline: baseline,
        timelineId: 'persisted',
      );

      final rows = await database
          .select(database.autonomicRecoveryProfilesTable)
          .get();
      final loaded = await service.loadProfiles(timelineId: 'persisted');

      expect(rows, hasLength(1));
      expect(loaded.single.resilienceScore, profile.resilienceScore);
    });

    test('migration 4 to 5 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 18);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 4 &&
              migration.toVersion == 5 &&
              migration.description.contains('Autonomic recovery'),
        ),
        isTrue,
      );
    });
  });
}

PhysiologicalSample _sample(DateTime timestamp, double heartRate, double hrv) {
  return PhysiologicalSample(
    timestamp: timestamp,
    heartRateBpm: heartRate,
    hrvRmssdMs: hrv,
    movementIntensity: 0.15,
  );
}

PhysiologicalEventMarker _marker(DateTime timestamp) {
  return PhysiologicalEventMarker(
    id: 'marker-${timestamp.microsecondsSinceEpoch}',
    timestamp: timestamp,
    type: EventType.elevatedHeartRate,
    title: 'Ativação',
    description: 'Marker de teste.',
    severity: Severity.medium,
    source: 'test',
  );
}
