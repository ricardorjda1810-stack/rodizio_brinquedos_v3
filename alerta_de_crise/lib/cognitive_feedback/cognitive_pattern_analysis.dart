import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import 'cognitive_feedback_models.dart';
import 'perceived_state_models.dart';

class CognitivePatternAnalysis {
  const CognitivePatternAnalysis();

  bool detectPhysiologyPerceptionMismatch({
    required PerceivedState perceivedState,
    List<PhysiologicalTrend> trends = const [],
    List<EscalationForecast> forecasts = const [],
  }) {
    final physiologicalLoad = _physiologicalLoad(trends, forecasts);
    final perceivedLoad = perceivedState.perceivedLoad * 10;
    return (physiologicalLoad - perceivedLoad).abs() >= 35;
  }

  bool detectsPerceivedRecovery(PerceivedState perceivedState) {
    return perceivedState.perceivedRecovery >= 7 &&
        perceivedState.perceivedControl >= 6;
  }

  bool detectsRecurringSubjectiveFatigue(
    List<SubjectiveFeedbackEntry> entries,
  ) {
    return entries
            .where((entry) => entry.perceivedState.perceivedFatigue >= 7)
            .length >=
        2;
  }

  bool detectsHighPerceivedLoad(PerceivedState perceivedState) {
    return perceivedState.perceivedStress >= 7 ||
        perceivedState.emotionalIntensity >= 7 ||
        perceivedState.perceivedLoad >= 7;
  }

  bool detectsInconsistency({
    required PerceivedState perceivedState,
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
  }) {
    if (recoveryProfiles.isEmpty) return false;
    final latest = recoveryProfiles.last;
    final objectiveRecovery = latest.resilienceScore - latest.fatigueScore;
    final perceivedRecovery = perceivedState.perceivedRecovery * 10;
    return (objectiveRecovery - perceivedRecovery).abs() >= 45;
  }

  List<String> detectPatterns({
    required PerceivedState perceivedState,
    List<SubjectiveFeedbackEntry> history = const [],
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
  }) {
    return [
      if (detectsHighPerceivedLoad(perceivedState))
        'alta carga de percepção subjetiva',
      if (detectsPerceivedRecovery(perceivedState))
        'recuperação percebida por autoavaliação',
      if (detectsRecurringSubjectiveFatigue(history))
        'fadiga subjetiva recorrente',
      if (detectPhysiologyPerceptionMismatch(
        perceivedState: perceivedState,
        trends: trends,
        forecasts: forecasts,
      ))
        'inconsistência percepção/fisiologia',
      if (detectsInconsistency(
        perceivedState: perceivedState,
        recoveryProfiles: recoveryProfiles,
      ))
        'discrepância entre recuperação percebida e fisiologia',
    ];
  }

  double physiologicalLoadScore({
    List<PhysiologicalTrend> trends = const [],
    List<EscalationForecast> forecasts = const [],
  }) {
    return _physiologicalLoad(trends, forecasts);
  }

  double _physiologicalLoad(
    List<PhysiologicalTrend> trends,
    List<EscalationForecast> forecasts,
  ) {
    final trendLoad = trends.isEmpty
        ? 0
        : trends
                  .map(
                    (trend) => trend.escalationScore + trend.activationDensity,
                  )
                  .reduce((a, b) => a + b) /
              (trends.length * 2);
    final forecastLoad = forecasts.isEmpty
        ? 0
        : forecasts
                  .map((forecast) => forecast.autonomicLoad)
                  .reduce((a, b) => a + b) /
              forecasts.length;
    if (trends.isEmpty && forecasts.isEmpty) return 0;
    if (trends.isEmpty) return forecastLoad.clamp(0, 100).toDouble();
    if (forecasts.isEmpty) return trendLoad.clamp(0, 100).toDouble();
    return ((trendLoad + forecastLoad) / 2).clamp(0, 100).toDouble();
  }
}
