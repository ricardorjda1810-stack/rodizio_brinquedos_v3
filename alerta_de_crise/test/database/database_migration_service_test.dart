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

      expect(service.currentSchemaVersion, 6);
    });

    test('registers initial Drift persistence migration', () {
      final service = DatabaseMigrationService(database: database);
      final migrations = service.registeredMigrations;

      expect(migrations, hasLength(6));
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
      expect(migrations.last.fromVersion, 5);
      expect(migrations.last.toVersion, 6);
      expect(migrations.last.description, contains('Research dashboard'));
    });

    test('has migration for current schema version', () {
      final service = DatabaseMigrationService(database: database);

      expect(service.hasMigrationForCurrentVersion, isTrue);
    });
  });
}
