import 'package:drift/drift.dart';

import '../adaptive_baseline/adaptive_baseline_models.dart';
import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../data/crisis_detection/intervention_history_entry.dart';
import '../database/signalflow_database.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../sensor_quality/sensor_confidence_score.dart';
import '../session_timeline/session_timeline_models.dart';
import 'dashboard_metrics.dart';
import 'dashboard_statistics.dart';
import 'longitudinal_insights.dart';
import 'research_dashboard_models.dart';

class ResearchDashboardService {
  final SignalFlowDatabase _database;
  final DateTime Function() _now;

  ResearchDashboardService({
    SignalFlowDatabase? database,
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _now = now ?? DateTime.now;

  Future<ResearchDashboardSnapshot> generateDashboard({
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<InterventionHistoryEntry> interventions = const [],
    List<SessionTimeline> timelines = const [],
    List<SensorConfidenceScore> confidenceScores = const [],
    AdaptiveBaselineProfile? adaptiveBaseline,
    bool persist = false,
  }) async {
    final metrics = calculateDashboardMetrics(
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      interventions: interventions,
      timelines: timelines,
      confidenceScores: confidenceScores,
      adaptiveBaseline: adaptiveBaseline,
    );
    final insights = generateLongitudinalInsights(
      metrics: metrics,
      trends: trends,
      recoveryProfiles: recoveryProfiles,
    );
    final generatedAt = _now();
    final snapshot = ResearchDashboardSnapshot(
      id: 'dashboard-${generatedAt.microsecondsSinceEpoch}',
      generatedAt: generatedAt,
      metrics: metrics,
      insights: insights,
    );

    if (persist) {
      await persistSnapshot(snapshot);
    }

    return snapshot;
  }

  DashboardMetrics calculateDashboardMetrics({
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<InterventionHistoryEntry> interventions = const [],
    List<SessionTimeline> timelines = const [],
    List<SensorConfidenceScore> confidenceScores = const [],
    AdaptiveBaselineProfile? adaptiveBaseline,
  }) {
    return DashboardStatistics.calculateMetrics(
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      interventions: interventions,
      timelines: timelines,
      confidenceScores: confidenceScores,
      adaptiveBaseline: adaptiveBaseline,
    );
  }

  LongitudinalInsights generateLongitudinalInsights({
    required DashboardMetrics metrics,
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
  }) {
    return DashboardStatistics.calculateInsights(
      metrics: metrics,
      trends: trends,
      recoveryProfiles: recoveryProfiles,
    );
  }

  Future<void> persistSnapshot(ResearchDashboardSnapshot snapshot) async {
    await _database
        .into(_database.researchDashboardSnapshotsTable)
        .insert(
          ResearchDashboardSnapshotsTableCompanion.insert(
            id: snapshot.id,
            generatedAt: snapshot.generatedAt,
            averageHeartRate: Value(snapshot.metrics.averageHeartRate),
            averageHrv: Value(snapshot.metrics.averageHrv),
            averageConfidence: snapshot.metrics.averageConfidence,
            escalationCount: snapshot.metrics.escalationCount,
            interventionCount: snapshot.metrics.interventionCount,
            recoveryEfficiency: snapshot.metrics.recoveryEfficiency,
            resilienceScore: snapshot.metrics.resilienceScore,
            fatigueScore: snapshot.metrics.fatigueScore,
            activationDensity: snapshot.metrics.activationDensity,
            baselineStability: snapshot.metrics.baselineStability,
            stressCarryover: snapshot.metrics.stressCarryover,
            improvingTrend: snapshot.insights.improvingTrend,
            worseningTrend: snapshot.insights.worseningTrend,
            recoveryTrend: snapshot.insights.recoveryTrend,
            confidenceTrend: snapshot.insights.confidenceTrend,
            circadianStability: snapshot.insights.circadianStability,
            autonomicLoad: snapshot.insights.autonomicLoad,
          ),
        );
  }

  Future<List<ResearchDashboardSnapshot>> loadSnapshots({
    int limit = 20,
  }) async {
    final query = _database.select(_database.researchDashboardSnapshotsTable)
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.generatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows.map(_fromRow).toList();
  }

  ResearchDashboardSnapshot _fromRow(ResearchDashboardSnapshotsTableData row) {
    return ResearchDashboardSnapshot(
      id: row.id,
      generatedAt: row.generatedAt,
      metrics: DashboardMetrics(
        averageHeartRate: row.averageHeartRate,
        averageHrv: row.averageHrv,
        averageConfidence: row.averageConfidence,
        escalationCount: row.escalationCount,
        interventionCount: row.interventionCount,
        recoveryEfficiency: row.recoveryEfficiency,
        resilienceScore: row.resilienceScore,
        fatigueScore: row.fatigueScore,
        activationDensity: row.activationDensity,
        baselineStability: row.baselineStability,
        stressCarryover: row.stressCarryover,
      ),
      insights: LongitudinalInsights(
        improvingTrend: row.improvingTrend,
        worseningTrend: row.worseningTrend,
        recoveryTrend: row.recoveryTrend,
        confidenceTrend: row.confidenceTrend,
        circadianStability: row.circadianStability,
        autonomicLoad: row.autonomicLoad,
      ),
    );
  }
}
