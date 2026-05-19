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
      SignalFlowMigrationInfo(
        fromVersion: 7,
        toVersion: 8,
        description: 'Contextual trigger persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 8,
        toVersion: 9,
        description: 'Personalized intervention persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 9,
        toVersion: 10,
        description: 'Longitudinal cohort analysis persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 10,
        toVersion: 11,
        description: 'Realtime streaming persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 11,
        toVersion: 12,
        description: 'Advanced replay engine persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 12,
        toVersion: 13,
        description: 'Experimental insight persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 13,
        toVersion: 14,
        description: 'Subjective feedback persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 14,
        toVersion: 15,
        description: 'Cross-modal fusion persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 15,
        toVersion: 16,
        description: 'Research orchestrator persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 16,
        toVersion: 17,
        description: 'Experimental protocol persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 17,
        toVersion: 18,
        description: 'Experimental session recording persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 18,
        toVersion: 19,
        description: 'Replay benchmark persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 19,
        toVersion: 20,
        description: 'Calibration lab persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 20,
        toVersion: 21,
        description: 'Sensor reliability validation persistence.',
      ),
      SignalFlowMigrationInfo(
        fromVersion: 21,
        toVersion: 22,
        description: 'Experimental study persistence.',
      ),
    ];
  }

  bool get hasMigrationForCurrentVersion {
    return registeredMigrations.any(
      (migration) => migration.toVersion == currentSchemaVersion,
    );
  }
}
