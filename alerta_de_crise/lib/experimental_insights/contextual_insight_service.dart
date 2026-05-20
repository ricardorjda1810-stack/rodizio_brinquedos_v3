import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../contextual_triggers/contextual_trigger_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import 'experimental_insight_models.dart';
import 'insight_generation_rules.dart';

class ContextualInsightService {
  final InsightGenerationRules _rules;
  final DateTime Function() _now;

  ContextualInsightService({
    InsightGenerationRules rules = const InsightGenerationRules(),
    DateTime Function()? now,
  }) : _rules = rules,
       _now = now ?? DateTime.now;

  List<ExperimentalPhysiologicalInsight> generateContextualInsights({
    List<ContextualTriggerCorrelation> correlations = const [],
    List<EscalationForecast> forecasts = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<PhysiologicalEventMarker> markers = const [],
  }) {
    final generatedAt = _now();
    if (!_rules.hasContextualPattern(correlations)) {
      return const [];
    }
    final confidence = _rules.contextualConfidence(correlations);
    final summary = generateBehavioralSummary(
      correlations: correlations,
      forecasts: forecasts,
      recoveryProfiles: recoveryProfiles,
    );
    return [
      ExperimentalPhysiologicalInsight(
        id: 'insight-contextual-${generatedAt.microsecondsSinceEpoch}',
        generatedAt: generatedAt,
        title: 'Padrão contextual observado',
        summary: summary,
        confidence: confidence,
        insightType: InsightType.contextualPattern,
        contributingFactors: _rules.factorsForInsight(
          InsightType.contextualPattern,
        ),
        relatedMarkers: markers,
        relatedForecasts: forecasts,
      ),
    ];
  }

  String explainCorrelation(ContextualTriggerCorrelation correlation) {
    return 'Interpretação experimental: ${correlation.category.name} aparece como mudança contextual associada a padrões observados; correlação não implica causalidade e não representa diagnóstico.';
  }

  String generateBehavioralSummary({
    List<ContextualTriggerCorrelation> correlations = const [],
    List<EscalationForecast> forecasts = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
  }) {
    final contexts = correlations
        .map((correlation) => correlation.category.name)
        .toSet();
    final maxForecast = forecasts.isEmpty
        ? 0
        : forecasts
              .map((forecast) => forecast.escalationProbability)
              .reduce((a, b) => a > b ? a : b);
    final fatigue = recoveryProfiles.isEmpty
        ? 0
        : recoveryProfiles
              .map((profile) => profile.fatigueScore)
              .reduce((a, b) => a > b ? a : b);
    return 'Insight experimental baseado em padrões observados: mudança contextual e mudanças contextuais em ${contexts.join(', ')} aparecem junto de tendência fisiológica, forecast máximo ${maxForecast.toStringAsFixed(0)} e fadiga ${fatigue.toStringAsFixed(0)}. Não representa diagnóstico.';
  }
}
