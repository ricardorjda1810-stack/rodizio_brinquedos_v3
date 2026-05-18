import 'package:drift/drift.dart';

import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../contextual_triggers/contextual_event.dart';
import '../data/crisis_detection/intervention_history_entry.dart';
import '../database/signalflow_database.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import '../session_timeline/session_timeline_models.dart';
import 'longitudinal_analysis_models.dart';
import 'longitudinal_stability_service.dart';
import 'physiological_evolution_models.dart';
import 'session_comparison_service.dart';

class CohortAnalysisService {
  final SignalFlowDatabase _database;
  final LongitudinalStabilityService _stabilityService;
  final SessionComparisonService _comparisonService;
  final DateTime Function() _now;

  CohortAnalysisService({
    SignalFlowDatabase? database,
    LongitudinalStabilityService stabilityService =
        const LongitudinalStabilityService(),
    SessionComparisonService comparisonService =
        const SessionComparisonService(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _stabilityService = stabilityService,
       _comparisonService = comparisonService,
       _now = now ?? DateTime.now;

  Future<CohortAnalysisResult> generateCohortAnalysis({
    List<SessionTimeline> sessions = const [],
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
    List<ContextualEvent> contextEvents = const [],
    List<InterventionHistoryEntry> interventions = const [],
    bool persist = false,
  }) async {
    final generatedAt = _now();
    final result = CohortAnalysisResult(
      id: 'cohort-${generatedAt.microsecondsSinceEpoch}',
      generatedAt: generatedAt,
      comparedSessions: sessions.length,
      averageRecoveryEfficiency: _average(
        recoveryProfiles.map((profile) => profile.recoveryRate * 100).toList(),
      ),
      averageEscalationProbability: _average([
        ...forecasts.map((forecast) => forecast.escalationProbability),
        ...trends.map((trend) => trend.escalationScore.toDouble()),
      ]),
      averageResilience: _average(
        recoveryProfiles
            .map((profile) => profile.resilienceScore.toDouble())
            .toList(),
      ),
      stabilityScore: _stabilityService.calculateStability(
        sessions: sessions,
        trends: trends,
        recoveryProfiles: recoveryProfiles,
      ),
      variabilityScore: _stabilityService.calculateVariability(
        sessions: sessions,
        trends: trends,
        recoveryProfiles: recoveryProfiles,
      ),
      contextualConsistency: _contextualConsistency(contextEvents),
      longitudinalConfidence: calculateLongitudinalConfidence(
        sessions: sessions,
        trends: trends,
        recoveryProfiles: recoveryProfiles,
        forecasts: forecasts,
        contextEvents: contextEvents,
        interventions: interventions,
      ),
    );
    if (persist) {
      await persistCohortAnalysis(result);
    }
    return result;
  }

  PhysiologicalEvolutionProfile generateEvolutionProfile({
    List<SessionTimeline> sessions = const [],
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
  }) {
    final comparison = _comparisonService.compareSessions(
      sessions: sessions,
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      forecasts: forecasts,
    );
    return PhysiologicalEvolutionProfile(
      baselineTrend: _comparisonService.detectEvolutionTrend(
        sessions
            .map((session) => session.averageHeartRate)
            .whereType<double>()
            .toList(),
        higherIsBetter: false,
      ),
      recoveryTrend: comparison.recoveryTrend,
      resilienceTrend: comparison.resilienceTrend,
      escalationTrend: comparison.escalationTrend,
      autonomicLoadTrend: _comparisonService.detectEvolutionTrend(
        forecasts.map((forecast) => forecast.autonomicLoad).toList(),
        higherIsBetter: false,
      ),
      circadianStabilityTrend:
          _stabilityService.calculateCircadianConsistency(sessions) >= 70
          ? LongitudinalEvolutionTrend.stable
          : LongitudinalEvolutionTrend.mixed,
      generatedAt: _now(),
    );
  }

  double calculateLongitudinalConfidence({
    List<SessionTimeline> sessions = const [],
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
    List<ContextualEvent> contextEvents = const [],
    List<InterventionHistoryEntry> interventions = const [],
  }) {
    return ((sessions.length * 12) +
            (trends.length * 8) +
            (recoveryProfiles.length * 9) +
            (forecasts.length * 7) +
            (contextEvents.length * 5) +
            (interventions.length * 4))
        .clamp(0, 100)
        .toDouble();
  }

  List<String> generateEvolutionInsights({
    required CohortAnalysisResult cohort,
    required PhysiologicalEvolutionProfile profile,
  }) {
    final insights = <String>[
      'análise experimental de tendência longitudinal: mudanças observadas não representam diagnóstico.',
    ];
    if (cohort.stabilityScore >= 70) {
      insights.add(
        'estabilidade fisiológica sustentada em padrões ao longo do tempo.',
      );
    }
    if (cohort.variabilityScore >= 45) {
      insights.add(
        'variação contextual e fisiológica aumentada entre sessões.',
      );
    }
    if (profile.recoveryTrend == LongitudinalEvolutionTrend.improving) {
      insights.add('mudança observada favorável em padrões de recuperação.');
    }
    if (profile.escalationTrend == LongitudinalEvolutionTrend.worsening) {
      insights.add('tendência longitudinal de escalada fisiológica mais alta.');
    }
    return List.unmodifiable(insights);
  }

  List<PhysiologicalEventMarker> buildOptionalMarkers({
    required PhysiologicalEvolutionProfile profile,
    required CohortAnalysisResult cohort,
    required String timelineId,
  }) {
    final timestamp = _now();
    final markers = <PhysiologicalEventMarker>[];
    if (profile.recoveryTrend == LongitudinalEvolutionTrend.improving ||
        profile.resilienceTrend == LongitudinalEvolutionTrend.improving) {
      markers.add(
        _marker(
          timelineId: timelineId,
          timestamp: timestamp,
          type: EventType.persistentImprovement,
          title: 'Melhora longitudinal observada',
          description:
              'Mudança observada em padrões ao longo do tempo, sem representar diagnóstico.',
          severity: Severity.low,
        ),
      );
    }
    if (profile.escalationTrend == LongitudinalEvolutionTrend.worsening ||
        profile.recoveryTrend == LongitudinalEvolutionTrend.worsening) {
      markers.add(
        _marker(
          timelineId: timelineId,
          timestamp: timestamp,
          type: EventType.persistentDeterioration,
          title: 'Piora longitudinal observada',
          description:
              'Tendência longitudinal desfavorável em sinais fisiológicos observados.',
          severity: Severity.medium,
        ),
      );
    }
    if (cohort.variabilityScore >= 45) {
      markers.add(
        _marker(
          timelineId: timelineId,
          timestamp: timestamp,
          type: EventType.autonomicInstabilityPattern,
          title: 'Variação autonômica longitudinal',
          description:
              'Variação contextual e estabilidade fisiológica reduzida ao longo do tempo.',
          severity: Severity.medium,
        ),
      );
    }
    if (profile.recoveryTrend != LongitudinalEvolutionTrend.stable) {
      markers.add(
        _marker(
          timelineId: timelineId,
          timestamp: timestamp,
          type: EventType.longitudinalRecoveryPattern,
          title: 'Padrão longitudinal de recuperação',
          description:
              'Padrões de recuperação mudaram entre sessões comparadas.',
          severity: Severity.low,
        ),
      );
    }
    return List.unmodifiable(markers);
  }

  Future<void> persistCohortAnalysis(CohortAnalysisResult result) async {
    await _database
        .into(_database.cohortAnalysisResultsTable)
        .insertOnConflictUpdate(
          CohortAnalysisResultsTableCompanion.insert(
            id: result.id,
            generatedAt: result.generatedAt,
            comparedSessions: result.comparedSessions,
            averageRecoveryEfficiency: result.averageRecoveryEfficiency,
            averageEscalationProbability: result.averageEscalationProbability,
            averageResilience: result.averageResilience,
            stabilityScore: result.stabilityScore,
            variabilityScore: result.variabilityScore,
            contextualConsistency: result.contextualConsistency,
            longitudinalConfidence: result.longitudinalConfidence,
            safetyCopy: result.safetyCopy,
          ),
        );
  }

  Future<void> persistEvolutionProfile(
    PhysiologicalEvolutionProfile profile,
  ) async {
    final generatedAt = profile.generatedAt;
    await _database
        .into(_database.physiologicalEvolutionProfilesTable)
        .insertOnConflictUpdate(
          PhysiologicalEvolutionProfilesTableCompanion.insert(
            id: 'evolution-${generatedAt.microsecondsSinceEpoch}',
            generatedAt: generatedAt,
            baselineTrend: profile.baselineTrend.name,
            recoveryTrend: profile.recoveryTrend.name,
            resilienceTrend: profile.resilienceTrend.name,
            escalationTrend: profile.escalationTrend.name,
            autonomicLoadTrend: profile.autonomicLoadTrend.name,
            circadianStabilityTrend: profile.circadianStabilityTrend.name,
            safetyCopy: profile.safetyCopy,
          ),
        );
  }

  Future<List<CohortAnalysisResult>> loadCohortAnalyses({
    int limit = 20,
  }) async {
    final query = _database.select(_database.cohortAnalysisResultsTable)
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.generatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_cohortFromRow).toList(growable: false);
  }

  Future<List<PhysiologicalEvolutionProfile>> loadEvolutionProfiles({
    int limit = 20,
  }) async {
    final query =
        _database.select(_database.physiologicalEvolutionProfilesTable)
          ..orderBy([
            (table) => OrderingTerm(
              expression: table.generatedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit);
    final rows = await query.get();
    return rows.map(_profileFromRow).toList(growable: false);
  }

  CohortAnalysisResult _cohortFromRow(CohortAnalysisResultsTableData row) {
    return CohortAnalysisResult(
      id: row.id,
      generatedAt: row.generatedAt,
      comparedSessions: row.comparedSessions,
      averageRecoveryEfficiency: row.averageRecoveryEfficiency,
      averageEscalationProbability: row.averageEscalationProbability,
      averageResilience: row.averageResilience,
      stabilityScore: row.stabilityScore,
      variabilityScore: row.variabilityScore,
      contextualConsistency: row.contextualConsistency,
      longitudinalConfidence: row.longitudinalConfidence,
    );
  }

  PhysiologicalEvolutionProfile _profileFromRow(
    PhysiologicalEvolutionProfilesTableData row,
  ) {
    return PhysiologicalEvolutionProfile(
      baselineTrend: LongitudinalEvolutionTrend.values.byName(
        row.baselineTrend,
      ),
      recoveryTrend: LongitudinalEvolutionTrend.values.byName(
        row.recoveryTrend,
      ),
      resilienceTrend: LongitudinalEvolutionTrend.values.byName(
        row.resilienceTrend,
      ),
      escalationTrend: LongitudinalEvolutionTrend.values.byName(
        row.escalationTrend,
      ),
      autonomicLoadTrend: LongitudinalEvolutionTrend.values.byName(
        row.autonomicLoadTrend,
      ),
      circadianStabilityTrend: LongitudinalEvolutionTrend.values.byName(
        row.circadianStabilityTrend,
      ),
      generatedAt: row.generatedAt,
    );
  }

  double _contextualConsistency(List<ContextualEvent> events) {
    if (events.isEmpty) {
      return 0;
    }
    final grouped = <String, int>{};
    for (final event in events) {
      grouped[event.category.name] = (grouped[event.category.name] ?? 0) + 1;
    }
    final maxCount = grouped.values.reduce((a, b) => a > b ? a : b);
    return (maxCount / events.length * 100).clamp(0, 100).toDouble();
  }

  PhysiologicalEventMarker _marker({
    required String timelineId,
    required DateTime timestamp,
    required EventType type,
    required String title,
    required String description,
    required Severity severity,
  }) {
    return PhysiologicalEventMarker(
      id: '$timelineId-${type.name}-${timestamp.microsecondsSinceEpoch}',
      timestamp: timestamp,
      type: type,
      title: title,
      description: description,
      severity: severity,
      source: 'longitudinal_analysis',
    );
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }
}
