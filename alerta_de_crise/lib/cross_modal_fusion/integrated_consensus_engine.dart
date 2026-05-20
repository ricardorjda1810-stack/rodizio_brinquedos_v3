import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../cognitive_feedback/cognitive_feedback_models.dart';
import '../contextual_triggers/contextual_trigger_models.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../sensor_quality/sensor_confidence_score.dart';
import 'cross_modal_models.dart';
import 'multimodal_confidence_service.dart';
import 'signal_weighting_service.dart';

class IntegratedConsensusEngine {
  final SignalWeightingService _weightingService;
  final MultimodalConfidenceService _confidenceService;
  final DateTime Function() _now;

  const IntegratedConsensusEngine({
    SignalWeightingService weightingService = const SignalWeightingService(),
    MultimodalConfidenceService confidenceService =
        const MultimodalConfidenceService(),
    DateTime Function()? now,
  }) : _weightingService = weightingService,
       _confidenceService = confidenceService,
       _now = now ?? DateTime.now;

  IntegratedPhysiologicalConsensus buildConsensus({
    SensorConfidenceScore? sensorConfidence,
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<ContextualTriggerCorrelation> contextualCorrelations = const [],
    List<SubjectiveFeedbackEntry> subjectiveFeedback = const [],
    List<EscalationForecast> forecasts = const [],
    SignalWeights? weights,
  }) {
    final generatedAt = _now();
    final normalizedWeights =
        weights ??
        _weightingService.calculateSignalWeights(
          sensorConfidence: sensorConfidence,
          trends: trends,
          recoveryProfiles: recoveryProfiles,
          contextualCorrelations: contextualCorrelations,
          subjectiveFeedback: subjectiveFeedback,
          forecasts: forecasts,
        );
    final stress = calculateIntegratedStress(
      sensorConfidence: sensorConfidence,
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      contextualCorrelations: contextualCorrelations,
      subjectiveFeedback: subjectiveFeedback,
      forecasts: forecasts,
      weights: normalizedWeights,
    );
    final recovery = calculateIntegratedRecovery(
      recoveryProfiles: recoveryProfiles,
      forecasts: forecasts,
      subjectiveFeedback: subjectiveFeedback,
      weights: normalizedWeights,
    );
    final confidence = _confidenceService.calculateMultimodalConfidence(
      sensorConfidence: sensorConfidence,
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      contextualCorrelations: contextualCorrelations,
      subjectiveFeedback: subjectiveFeedback,
      forecasts: forecasts,
    );
    final conflicts = _weightingService.detectSignalConflict(
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      subjectiveFeedback: subjectiveFeedback,
      forecasts: forecasts,
    );
    final agreement =
        (100 - (conflicts.length * 22) - (100 - confidence.score) * 0.2)
            .clamp(0, 100)
            .toDouble();
    return IntegratedPhysiologicalConsensus(
      id: 'consensus-${generatedAt.microsecondsSinceEpoch}',
      generatedAt: generatedAt,
      integratedStressLoad: stress,
      integratedRecoveryState: recovery,
      integratedResilience: _integratedResilience(recoveryProfiles, recovery),
      multimodalConfidence: confidence,
      signalAgreement: agreement,
      contributingSignals: _contributingSignals(
        sensorConfidence: sensorConfidence,
        trends: trends,
        recoveryProfiles: recoveryProfiles,
        contextualCorrelations: contextualCorrelations,
        subjectiveFeedback: subjectiveFeedback,
        forecasts: forecasts,
      ),
      disagreementFactors: conflicts,
    );
  }

  double calculateIntegratedStress({
    SensorConfidenceScore? sensorConfidence,
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<ContextualTriggerCorrelation> contextualCorrelations = const [],
    List<SubjectiveFeedbackEntry> subjectiveFeedback = const [],
    List<EscalationForecast> forecasts = const [],
    required SignalWeights weights,
  }) {
    final rrStress = 100 - (sensorConfidence?.rrQuality ?? 65);
    final hrvStress = trends.isEmpty
        ? 45.0
        : _average(
            trends.map(
              (trend) => trend.averageHrv == null
                  ? 50
                  : 80 - trend.averageHrv!.clamp(0, 80),
            ),
          );
    final recoveryStress = recoveryProfiles.isEmpty
        ? 45.0
        : _average(
            recoveryProfiles.map((profile) => profile.fatigueScore.toDouble()),
          );
    final trendStress = trends.isEmpty
        ? 45.0
        : _average(trends.map((trend) => trend.escalationScore.toDouble()));
    final contextStress = contextualCorrelations.isEmpty
        ? 35.0
        : _average(
            contextualCorrelations.map(
              (correlation) => correlation.escalationCorrelation,
            ),
          );
    final subjectiveStress = subjectiveFeedback.isEmpty
        ? 40.0
        : _average(
            subjectiveFeedback.map(
              (entry) => entry.perceivedState.perceivedLoad * 10.0,
            ),
          );
    final forecastStress = forecasts.isEmpty
        ? 45.0
        : _average(forecasts.map((forecast) => forecast.escalationProbability));

    final weighted =
        rrStress * weights.rrQuality +
        hrvStress * weights.hrv +
        recoveryStress * weights.recovery +
        trendStress * weights.trends +
        contextStress * weights.context +
        subjectiveStress * weights.subjectiveFeedback +
        forecastStress * weights.confidenceScore;
    return weighted.clamp(0, 100).toDouble();
  }

  double calculateIntegratedRecovery({
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
    List<SubjectiveFeedbackEntry> subjectiveFeedback = const [],
    required SignalWeights weights,
  }) {
    final physiologicalRecovery = recoveryProfiles.isEmpty
        ? 50.0
        : _average(
            recoveryProfiles.map(
              (profile) =>
                  (profile.recoveryRate + profile.heartRateNormalization) / 2,
            ),
          );
    final forecastProtection = forecasts.isEmpty
        ? 50.0
        : _average(forecasts.map((forecast) => forecast.recoveryProtection));
    final perceivedRecovery = subjectiveFeedback.isEmpty
        ? 50.0
        : _average(
            subjectiveFeedback.map(
              (entry) => entry.perceivedState.perceivedRecovery * 10.0,
            ),
          );
    final totalWeight =
        weights.recovery + weights.confidenceScore + weights.subjectiveFeedback;
    if (totalWeight <= 0) return 0;
    final weighted =
        physiologicalRecovery * weights.recovery +
        forecastProtection * weights.confidenceScore +
        perceivedRecovery * weights.subjectiveFeedback;
    return (weighted / totalWeight).clamp(0, 100).toDouble();
  }

  double _integratedResilience(
    List<AutonomicRecoveryProfile> recoveryProfiles,
    double recovery,
  ) {
    if (recoveryProfiles.isEmpty) return recovery;
    final resilience = _average(
      recoveryProfiles.map((profile) => profile.resilienceScore.toDouble()),
    );
    return ((resilience * 0.65) + (recovery * 0.35)).clamp(0, 100).toDouble();
  }

  List<String> _contributingSignals({
    required SensorConfidenceScore? sensorConfidence,
    required List<PhysiologicalTrend> trends,
    required List<AutonomicRecoveryProfile> recoveryProfiles,
    required List<ContextualTriggerCorrelation> contextualCorrelations,
    required List<SubjectiveFeedbackEntry> subjectiveFeedback,
    required List<EscalationForecast> forecasts,
  }) {
    return [
      if (sensorConfidence != null) 'RR intervals',
      if (trends.any((trend) => trend.averageHrv != null)) 'HRV',
      if (trends.isNotEmpty) 'tendências fisiológicas',
      if (forecasts.isNotEmpty) 'previsão experimental',
      if (recoveryProfiles.isNotEmpty) 'padrões de recuperação',
      if (contextualCorrelations.isNotEmpty) 'contexto',
      if (subjectiveFeedback.isNotEmpty) 'percepção subjetiva',
      'fusão experimental',
      'sinais combinados',
    ];
  }

  double _average(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    return list.fold<double>(0, (sum, value) => sum + value) / list.length;
  }
}
