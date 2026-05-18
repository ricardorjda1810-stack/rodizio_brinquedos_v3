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
      SignalFlowMigrationInfo(
        fromVersion: 2,
        toVersion: 3,
        description: 'Adaptive baseline + timeline persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 3,
        toVersion: 4,
        description: 'Trend analysis persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 4,
        toVersion: 5,
        description: 'Autonomic recovery persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 5,
        toVersion: 6,
        description: 'Research dashboard persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 6,
        toVersion: 7,
        description: 'Predictive forecasting persistence.',
      ),
    ];
  }

  bool get hasMigrationForCurrentVersion {
    return registeredMigrations.any(
      (migration) => migration.toVersion == currentSchemaVersion,
    );
  }
}
