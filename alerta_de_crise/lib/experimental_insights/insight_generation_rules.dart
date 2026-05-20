import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../contextual_triggers/contextual_trigger_models.dart';
import '../longitudinal_analysis/longitudinal_analysis_models.dart';
import '../longitudinal_analysis/physiological_evolution_models.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import 'experimental_insight_models.dart';

class InsightGenerationRules {
  const InsightGenerationRules();

  double physiologicalConfidence({
    required List<PhysiologicalTrend> trends,
    required List<AutonomicRecoveryProfile> recoveryProfiles,
    required List<EscalationForecast> forecasts,
  }) {
    final dataVolume =
        (trends.length + recoveryProfiles.length + forecasts.length).clamp(
          0,
          12,
        );
    final forecastSignal = forecasts.isEmpty
        ? 0
        : forecasts
                  .map((forecast) => forecast.forecastConfidence.score)
                  .reduce((a, b) => a + b) /
              forecasts.length;
    return (35 + (dataVolume * 4) + (forecastSignal * 0.25)).clamp(0, 100);
  }

  bool hasRecurringEscalation(List<PhysiologicalTrend> trends) {
    return trends.where((trend) => trend.escalationScore >= 60).length >= 2 ||
        trends.where((trend) => trend.activationDensity >= 55).length >= 2;
  }

  bool hasIncompleteRecovery(List<AutonomicRecoveryProfile> recoveryProfiles) {
    return recoveryProfiles.any(
      (profile) =>
          profile.fatigueScore >= 60 ||
          profile.stressCarryover >= 55 ||
          profile.resilienceLevel == AutonomicResilienceLevel.overloaded,
    );
  }

  bool hasRecoveryImprovement(List<AutonomicRecoveryProfile> recoveryProfiles) {
    if (recoveryProfiles.length < 2) return false;
    final ordered = [...recoveryProfiles]
      ..sort((a, b) => a.generatedAt.compareTo(b.generatedAt));
    return ordered.last.resilienceScore > ordered.first.resilienceScore &&
        ordered.last.fatigueScore <= ordered.first.fatigueScore;
  }

  bool hasHighForecastLoad(List<EscalationForecast> forecasts) {
    return forecasts.any(
      (forecast) =>
          forecast.escalationProbability >= 65 ||
          forecast.autonomicLoad >= 70 ||
          forecast.escalationRiskLevel == ForecastRiskLevel.high,
    );
  }

  bool hasContextualPattern(List<ContextualTriggerCorrelation> correlations) {
    return correlations.any(
      (correlation) =>
          correlation.occurrenceCount >= 2 &&
          correlation.escalationCorrelation >= 55 &&
          correlation.confidence >= 45,
    );
  }

  bool hasLongitudinalShift({
    required List<CohortAnalysisResult> cohorts,
    required List<PhysiologicalEvolutionProfile> profiles,
  }) {
    return cohorts.any((cohort) => cohort.variabilityScore >= 55) ||
        profiles.any(
          (profile) =>
              profile.escalationTrend == LongitudinalEvolutionTrend.worsening ||
              profile.recoveryTrend == LongitudinalEvolutionTrend.improving ||
              profile.resilienceTrend == LongitudinalEvolutionTrend.mixed,
        );
  }

  List<String> factorsForInsight(InsightType type) {
    return switch (type) {
      InsightType.escalationPattern => const [
        'tendência fisiológica',
        'escalada recorrente',
        'padrões observados',
      ],
      InsightType.recoveryPattern => const [
        'padrões de recuperação',
        'carga autonômica',
        'interpretação experimental',
      ],
      InsightType.contextualPattern => const [
        'mudanças contextuais',
        'correlação contextual',
        'padrões observados',
      ],
      InsightType.longitudinalPattern => const [
        'tendência longitudinal',
        'mudança observada',
        'estabilidade fisiológica',
      ],
      InsightType.forecastPattern => const [
        'forecast experimental',
        'probabilidade observada',
        'sinais fisiológicos',
      ],
      _ => const ['insights experimentais', 'padrões observados'],
    };
  }

  double contextualConfidence(List<ContextualTriggerCorrelation> correlations) {
    if (correlations.isEmpty) return 25;
    final average =
        correlations
            .map((correlation) => correlation.confidence)
            .reduce((a, b) => a + b) /
        correlations.length;
    final recurrenceBoost =
        correlations
            .where((correlation) => correlation.occurrenceCount >= 2)
            .length *
        8;
    return (average + recurrenceBoost).clamp(0, 100);
  }
}
