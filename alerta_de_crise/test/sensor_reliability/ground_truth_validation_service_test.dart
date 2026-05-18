import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/sensor_reliability/ground_truth_validation_service.dart';
import 'package:signalflow/sensor_reliability/sensor_reliability_models.dart';

void main() {
  group('GroundTruthValidationService', () {
    late SignalFlowDatabase database;
    late GroundTruthValidationService service;
    late List<SensorReading> reference;
    late List<SensorReading> primary;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = GroundTruthValidationService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12, 1),
      );
      final start = DateTime.utc(2026, 5, 18, 12);
      reference = [
        SensorReading(
          sensorType: 'Polar H10',
          timestamp: start,
          heartRate: 72,
          hrv: 42,
          confidence: 94,
        ),
        SensorReading(
          sensorType: 'Polar H10',
          timestamp: start.add(const Duration(seconds: 10)),
          heartRate: 74,
          hrv: 40,
          confidence: 95,
        ),
      ];
      primary = [
        SensorReading(
          sensorType: 'Apple Health',
          timestamp: start.add(const Duration(milliseconds: 120)),
          heartRate: 73,
          hrv: 41,
          confidence: 88,
        ),
        SensorReading(
          sensorType: 'Apple Health',
          timestamp: start.add(const Duration(seconds: 10, milliseconds: 150)),
          heartRate: 75,
          hrv: 39,
          confidence: 87,
        ),
      ];
    });

    tearDown(() async {
      await database.close();
    });

    test('validates against experimental reference', () async {
      final report = await service.validateAgainstReference(
        primarySensor: 'Apple Health',
        primaryReadings: primary,
        referenceReadings: reference,
      );

      expect(report.comparison.referenceSensor, 'Polar H10');
      expect(report.profile.agreementWithReference, greaterThan(90));
      expect(report.profile.reliabilityScore, greaterThan(70));
      expect(report.summary.join(' '), contains('referência experimental'));
    });

    test('persists Drift reliability profile and comparison result', () async {
      await service.validateAgainstReference(
        primarySensor: 'Apple Health',
        primaryReadings: primary,
        referenceReadings: reference,
        persist: true,
      );

      final profiles = await database
          .select(database.sensorReliabilityProfilesTable)
          .get();
      final comparisons = await database
          .select(database.sensorComparisonResultsTable)
          .get();
      final loaded = await service.loadProfiles();

      expect(profiles, hasLength(1));
      expect(comparisons, hasLength(1));
      expect(loaded, hasLength(1));
      expect(
        profiles.single.safetyCopy,
        contains('não representa validação clínica'),
      );
      expect(
        comparisons.single.safetyCopy,
        contains('comparação técnica de sinais'),
      );
    });

    test('migration 20 to 21 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 21);
      expect(migrationService.registeredMigrations.last.fromVersion, 20);
      expect(migrationService.registeredMigrations.last.toVersion, 21);
      expect(
        migrationService.registeredMigrations.last.description,
        contains('Sensor reliability validation'),
      );
    });
  });
}
