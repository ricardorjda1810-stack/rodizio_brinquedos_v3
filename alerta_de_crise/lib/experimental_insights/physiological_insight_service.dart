import 'package:drift/drift.dart';

import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../database/signalflow_database.dart';
import '../longitudinal_analysis/longitudinal_analysis_models.dart';
import '../longitudinal_analysis/physiological_evolution_models.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import 'experimental_insight_models.dart';
import 'insight_generation_rules.dart';

class PhysiologicalInsightService {
  final SignalFlowDatabase _database;
  final InsightGenerationRules _rules;
  final DateTime Function() _now;

  PhysiologicalInsightService({
    SignalFlowDatabase? database,
    InsightGenerationRules rules = const InsightGenerationRules(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _rules = rules,
       _now = now ?? DateTime.now;

  List<ExperimentalPhysiologicalInsight> generateInsights({
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
    List<CohortAnalysisResult> cohortAnalyses = const [],
    List<PhysiologicalEvolutionProfile> evolutionProfiles = const [],
    List<PhysiologicalEventMarker> markers = const [],
  }) {
    return [
      ...generateRealtimeInsights(
        trends: trends,
        recoveryProfiles: recoveryProfiles,
        forecasts: forecasts,
        markers: markers,
      ),
      ...generateLongitudinalInsights(
        cohortAnalyses: cohortAnalyses,
        evolutionProfiles: evolutionProfiles,
        recoveryProfiles: recoveryProfiles,
        markers: markers,
      ),
    ];
  }

  List<ExperimentalPhysiologicalInsight> generateRealtimeInsights({
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
    List<PhysiologicalEventMarker> markers = const [],
  }) {
    final generatedAt = _now();
    final confidence = _rules.physiologicalConfidence(
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      forecasts: forecasts,
    );
    final insights = <ExperimentalPhysiologicalInsight>[];
    if (_rules.hasRecurringEscalation(trends)) {
      insights.add(
        _insight(
          generatedAt: generatedAt,
          type: InsightType.escalationPattern,
          title: 'Padrão recorrente de escalada fisiológica',
          summary:
              'Insights experimentais sugerem tendência fisiológica recorrente em padrões observados de ativação. Não representa diagnóstico.',
          confidence: confidence,
          markers: markers,
          forecasts: forecasts,
        ),
      );
    }
    if (_rules.hasIncompleteRecovery(recoveryProfiles)) {
      insights.add(
        _insight(
          generatedAt: generatedAt,
          type: InsightType.recoveryPattern,
          title: 'Padrão de recuperação incompleta observado',
          summary:
              'Interpretação experimental indica recuperação possivelmente incompleta em parte do histórico autonômico. Não representa diagnóstico.',
          confidence: confidence,
          markers: markers,
          forecasts: forecasts,
        ),
      );
    }
    if (_rules.hasHighForecastLoad(forecasts)) {
      insights.add(
        _insight(
          generatedAt: generatedAt,
          type: InsightType.forecastPattern,
          title: 'Forecast com carga autonômica elevada',
          summary:
              'Padrões observados em forecasts apontam maior probabilidade experimental de ativação fisiológica. Não representa diagnóstico.',
          confidence: confidence,
          markers: markers,
          forecasts: forecasts,
        ),
      );
    }
    return insights.isEmpty
        ? [
            _insight(
              generatedAt: generatedAt,
              type: InsightType.resiliencePattern,
              title: 'Estabilidade fisiológica observada',
              summary:
                  'Insights experimentais indicam estabilidade relativa nos dados fornecidos, com interpretação experimental limitada.',
              confidence: confidence,
              markers: markers,
              forecasts: forecasts,
            ),
          ]
        : insights;
  }

  List<ExperimentalPhysiologicalInsight> generateLongitudinalInsights({
    List<CohortAnalysisResult> cohortAnalyses = const [],
    List<PhysiologicalEvolutionProfile> evolutionProfiles = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<PhysiologicalEventMarker> markers = const [],
  }) {
    final generatedAt = _now();
    final insights = <ExperimentalPhysiologicalInsight>[];
    if (_rules.hasLongitudinalShift(
      cohorts: cohortAnalyses,
      profiles: evolutionProfiles,
    )) {
      insights.add(
        _insight(
          generatedAt: generatedAt,
          type: InsightType.longitudinalPattern,
          title: 'Mudança longitudinal observada',
          summary:
              'Resumo experimental aponta mudanças contextuais ou fisiológicas em padrões ao longo do tempo. Não representa diagnóstico.',
          confidence: _longitudinalConfidence(cohortAnalyses),
          markers: markers,
        ),
      );
    }
    if (_rules.hasRecoveryImprovement(recoveryProfiles)) {
      insights.add(
        _insight(
          generatedAt: generatedAt,
          type: InsightType.recoveryPattern,
          title: 'Melhora de recuperação observada',
          summary:
              'Padrões observados sugerem possível melhora longitudinal de recuperação autonômica em parte do histórico.',
          confidence: _longitudinalConfidence(cohortAnalyses),
          markers: markers,
        ),
      );
    }
    return insights;
  }

  Future<void> persistInsight(ExperimentalPhysiologicalInsight insight) async {
    await _database
        .into(_database.experimentalInsightsTable)
        .insertOnConflictUpdate(_companionFor(insight));
  }

  Future<void> persistInsights(
    List<ExperimentalPhysiologicalInsight> insights,
  ) async {
    for (final insight in insights) {
      await persistInsight(insight);
    }
  }

  Future<List<ExperimentalPhysiologicalInsight>> loadInsights({
    int limit = 20,
  }) async {
    final query = _database.select(_database.experimentalInsightsTable)
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.generatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  ExperimentalPhysiologicalInsight _insight({
    required DateTime generatedAt,
    required InsightType type,
    required String title,
    required String summary,
    required double confidence,
    List<PhysiologicalEventMarker> markers = const [],
    List<EscalationForecast> forecasts = const [],
  }) {
    return ExperimentalPhysiologicalInsight(
      id: 'insight-${type.name}-${generatedAt.microsecondsSinceEpoch}-${title.length}',
      generatedAt: generatedAt,
      title: title,
      summary: summary,
      confidence: confidence.clamp(0, 100),
      insightType: type,
      contributingFactors: _rules.factorsForInsight(type),
      relatedMarkers: markers,
      relatedForecasts: forecasts,
    );
  }

  double _longitudinalConfidence(List<CohortAnalysisResult> cohortAnalyses) {
    if (cohortAnalyses.isEmpty) return 45;
    return cohortAnalyses
            .map((cohort) => cohort.longitudinalConfidence)
            .reduce((a, b) => a + b) /
        cohortAnalyses.length;
  }

  ExperimentalInsightsTableCompanion _companionFor(
    ExperimentalPhysiologicalInsight insight,
  ) {
    return ExperimentalInsightsTableCompanion.insert(
      id: insight.id,
      generatedAt: insight.generatedAt,
      title: insight.title,
      summary: insight.summary,
      confidence: insight.confidence,
      insightType: insight.insightType.name,
      contributingFactors: insight.contributingFactors.join('|'),
      relatedMarkers: insight.relatedMarkers
          .map((marker) => marker.id)
          .join('|'),
      relatedForecasts: insight.relatedForecasts
          .map((forecast) => forecast.id)
          .join('|'),
      safetyCopy: insight.safetyCopy,
    );
  }

  ExperimentalPhysiologicalInsight _fromRow(ExperimentalInsightsTableData row) {
    return ExperimentalPhysiologicalInsight(
      id: row.id,
      generatedAt: row.generatedAt,
      title: row.title,
      summary: row.summary,
      confidence: row.confidence,
      insightType: InsightType.values.byName(row.insightType),
      contributingFactors: row.contributingFactors.isEmpty
          ? const []
          : row.contributingFactors.split('|'),
    );
  }
}
