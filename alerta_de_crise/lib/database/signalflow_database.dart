import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'adaptive_baseline_tables.dart';
import 'autonomic_recovery_tables.dart';
import 'baseline_tables.dart';
import 'consent_tables.dart';
import 'crisis_tables.dart';
import 'intervention_tables.dart';
import 'physiological_trend_tables.dart';
import 'predictive_forecast_tables.dart';
import 'research_dashboard_tables.dart';
import 'session_timeline_tables.dart';

part 'signalflow_database.g.dart';

@DriftDatabase(
  tables: [
    BaselineProfilesTable,
    CrisisRiskEventsTable,
    InterventionHistoryTable,
    ResearchConsentTable,
    AdaptiveBaselineStateTable,
    CircadianProfilesTable,
    SessionTimelineTable,
    PhysiologicalEventMarkersTable,
    PhysiologicalTrendsTable,
    AutonomicRecoveryProfilesTable,
    ResearchDashboardSnapshotsTable,
    EscalationForecastsTable,
  ],
)
final class SignalFlowDatabase extends _$SignalFlowDatabase {
  SignalFlowDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'signalflow'));

  factory SignalFlowDatabase.memory() {
    return SignalFlowDatabase(NativeDatabase.memory());
  }

  static final SignalFlowDatabase instance = SignalFlowDatabase();

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(adaptiveBaselineStateTable);
          await migrator.createTable(circadianProfilesTable);
        }
        if (from < 3) {
          await migrator.createTable(sessionTimelineTable);
          await migrator.createTable(physiologicalEventMarkersTable);
        }
        if (from < 4) {
          await migrator.createTable(physiologicalTrendsTable);
        }
        if (from < 5) {
          await migrator.createTable(autonomicRecoveryProfilesTable);
        }
        if (from < 6) {
          await migrator.createTable(researchDashboardSnapshotsTable);
        }
        if (from < 7) {
          await migrator.createTable(escalationForecastsTable);
        }
      },
    );
  }

  Future<void> clearAllSignalFlowTables() async {
    await batch((batch) {
      batch.deleteAll(baselineProfilesTable);
      batch.deleteAll(crisisRiskEventsTable);
      batch.deleteAll(interventionHistoryTable);
      batch.deleteAll(researchConsentTable);
      batch.deleteAll(adaptiveBaselineStateTable);
      batch.deleteAll(circadianProfilesTable);
      batch.deleteAll(sessionTimelineTable);
      batch.deleteAll(physiologicalEventMarkersTable);
      batch.deleteAll(physiologicalTrendsTable);
      batch.deleteAll(autonomicRecoveryProfilesTable);
      batch.deleteAll(researchDashboardSnapshotsTable);
      batch.deleteAll(escalationForecastsTable);
    });
  }
}
