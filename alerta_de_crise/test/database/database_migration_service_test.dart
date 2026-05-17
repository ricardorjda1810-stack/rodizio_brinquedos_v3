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

      expect(service.currentSchemaVersion, 2);
    });

    test('registers initial Drift persistence migration', () {
      final service = DatabaseMigrationService(database: database);
      final migrations = service.registeredMigrations;

      expect(migrations, hasLength(2));
      expect(migrations.first.fromVersion, 0);
      expect(migrations.first.toVersion, 1);
      expect(migrations.first.description, contains('Drift persistence'));
      expect(migrations.last.fromVersion, 1);
      expect(migrations.last.toVersion, 2);
      expect(migrations.last.description, contains('Adaptive baseline'));
    });

    test('has migration for current schema version', () {
      final service = DatabaseMigrationService(database: database);

      expect(service.hasMigrationForCurrentVersion, isTrue);
    });
  });
}
