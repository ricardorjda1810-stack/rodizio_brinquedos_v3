import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';

void main() {
  group('DatabaseMigrationService', () {
    late SignalFlowDatabase database;

    setUp(() {
      database = SignalFlowDatabase.memory();
    });

    tearDown(() async {
      await database.close();
    });

    test('exposes current schema version', () {
      final service = DatabaseMigrationService(database: database);

      expect(service.currentSchemaVersion, 11);
    });

    test('registers initial Drift persistence migration', () {
      final service = DatabaseMigrationService(database: database);
      final migrations = service.registeredMigrations;

      expect(migrations, hasLength(11));
      expect(migrations.first.fromVersion, 0);
      expect(migrations.first.toVersion, 1);
      expect(migrations.first.description, contains('Drift persistence'));
      expect(migrations[1].fromVersion, 1);
      expect(migrations[1].toVersion, 2);
      expect(migrations[1].description, contains('Adaptive baseline'));
      expect(migrations[2].fromVersion, 2);
      expect(migrations[2].toVersion, 3);
      expect(migrations[2].description, contains('timeline'));
      expect(migrations[3].fromVersion, 3);
      expect(migrations[3].toVersion, 4);
      expect(migrations[3].description, contains('Trend analysis'));
      expect(migrations[4].fromVersion, 4);
      expect(migrations[4].toVersion, 5);
      expect(migrations[4].description, contains('Autonomic recovery'));
      expect(migrations[5].fromVersion, 5);
      expect(migrations[5].toVersion, 6);
      expect(migrations[5].description, contains('Research dashboard'));
      expect(migrations[6].fromVersion, 6);
      expect(migrations[6].toVersion, 7);
      expect(migrations[6].description, contains('Predictive forecasting'));
      expect(migrations[7].fromVersion, 7);
      expect(migrations[7].toVersion, 8);
      expect(migrations[7].description, contains('Contextual trigger'));
      expect(migrations[8].fromVersion, 8);
      expect(migrations[8].toVersion, 9);
      expect(migrations[8].description, contains('Personalized intervention'));
      expect(migrations[9].fromVersion, 9);
      expect(migrations[9].toVersion, 10);
      expect(
        migrations[9].description,
        contains('Longitudinal cohort analysis'),
      );
      expect(migrations.last.fromVersion, 10);
      expect(migrations.last.toVersion, 11);
      expect(migrations.last.description, contains('Realtime streaming'));
    });

    test('has migration for current schema version', () {
      final service = DatabaseMigrationService(database: database);

      expect(service.hasMigrationForCurrentVersion, isTrue);
    });
  });
}
