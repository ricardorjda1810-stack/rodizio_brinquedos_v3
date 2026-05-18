import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'adaptive_baseline_tables.dart';
import 'autonomic_recovery_tables.dart';
import 'baseline_tables.dart';
import 'cognitive_feedback_tables.dart';
import 'consent_tables.dart';
import 'contextual_trigger_tables.dart';
import 'cross_modal_fusion_tables.dart';
import 'crisis_tables.dart';
import 'experimental_insight_tables.dart';
import 'intervention_tables.dart';
import 'longitudinal_analysis_tables.dart';
import 'personalized_intervention_tables.dart';
import 'physiological_trend_tables.dart';
import 'predictive_forecast_tables.dart';
import 'realtime_streaming_tables.dart';
import 'replay_engine_tables.dart';
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
    ContextualEventsTable,
    ContextualTriggerCorrelationsTable,
    InterventionLearningProfilesTable,
    ContextualInterventionRecommendationsTable,
    CohortAnalysisResultsTable,
    PhysiologicalEvolutionProfilesTable,
    RealtimePipelineSnapshotsTable,
    ReplayScenariosTable,
    ReplayValidationResultsTable,
    ExperimentalInsightsTable,
    SubjectiveFeedbackEntriesTable,
    IntegratedConsensusSnapshotsTable,
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
  int get schemaVersion => 15;

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
        if (from < 8) {
          await migrator.createTable(contextualEventsTable);
          await migrator.createTable(contextualTriggerCorrelationsTable);
        }
        if (from < 9) {
          await migrator.createTable(interventionLearningProfilesTable);
          await migrator.createTable(
            contextualInterventionRecommendationsTable,
          );
        }
        if (from < 10) {
          await migrator.createTable(cohortAnalysisResultsTable);
          await migrator.createTable(physiologicalEvolutionProfilesTable);
        }
        if (from < 11) {
          await migrator.createTable(realtimePipelineSnapshotsTable);
        }
        if (from < 12) {
          await migrator.createTable(replayScenariosTable);
          await migrator.createTable(replayValidationResultsTable);
        }
        if (from < 13) {
          await migrator.createTable(experimentalInsightsTable);
        }
        if (from < 14) {
          await migrator.createTable(subjectiveFeedbackEntriesTable);
        }
        if (from < 15) {
          await migrator.createTable(integratedConsensusSnapshotsTable);
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
      batch.deleteAll(contextualEventsTable);
      batch.deleteAll(contextualTriggerCorrelationsTable);
      batch.deleteAll(interventionLearningProfilesTable);
      batch.deleteAll(contextualInterventionRecommendationsTable);
      batch.deleteAll(cohortAnalysisResultsTable);
      batch.deleteAll(physiologicalEvolutionProfilesTable);
      batch.deleteAll(realtimePipelineSnapshotsTable);
      batch.deleteAll(replayScenariosTable);
      batch.deleteAll(replayValidationResultsTable);
      batch.deleteAll(experimentalInsightsTable);
      batch.deleteAll(subjectiveFeedbackEntriesTable);
      batch.deleteAll(integratedConsensusSnapshotsTable);
    });
  }
}
