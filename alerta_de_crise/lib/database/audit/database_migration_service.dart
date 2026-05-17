import '../signalflow_database.dart';
import 'database_audit_models.dart';

class DatabaseMigrationService {
  final SignalFlowDatabase _database;

  DatabaseMigrationService({SignalFlowDatabase? database})
    : _database = database ?? SignalFlowDatabase.instance;

  int get currentSchemaVersion => _database.schemaVersion;

  List<SignalFlowMigrationInfo> get registeredMigrations {
    return const [
      SignalFlowMigrationInfo(
        fromVersion: 0,
        toVersion: 1,
        description: 'Initial Drift persistence layer for SignalFlow data.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 1,
        toVersion: 2,
        description: 'Adaptive baseline and circadian profile persistence.',
      ),
    ];
  }

  bool get hasMigrationForCurrentVersion {
    return registeredMigrations.any(
      (migration) => migration.toVersion == currentSchemaVersion,
    );
  }
}
