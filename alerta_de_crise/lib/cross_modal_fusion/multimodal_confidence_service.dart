import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../cognitive_feedback/cognitive_feedback_models.dart';
import '../contextual_triggers/contextual_trigger_models.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../sensor_quality/sensor_confidence_score.dart';
import 'cross_modal_models.dart';
import 'signal_weighting_service.dart';

class MultimodalConfidenceService {
  final SignalWeightingService _weightingService;

  const MultimodalConfidenceService({
    SignalWeightingService weightingService = const SignalWeightingService(),
  }) : _weightingService = weightingService;

  MultimodalConfidenceResult calculateMultimodalConfidence({
    SensorConfidenceScore? sensorConfidence,
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<ContextualTriggerCorrelation> contextualCorrelations = const [],
    List<SubjectiveFeedbackEntry> subjectiveFeedback = const [],
    List<EscalationForecast> forecasts = const [],
  }) {
    final factors = <String>['confiança experimental'];
    var score = 45.0;

    if (sensorConfidence != null) {
      score += sensorConfidence.overallScore * 0.2;
      if (sensorConfidence.hasArtifacts) {
        score -= 15;
        factors.add('artefatos reduzem confiança multimodal');
      }
    }
    if (trends.isNotEmpty) score += 10;
    if (recoveryProfiles.isNotEmpty) score += 10;
    if (forecasts.isNotEmpty) score += 8;
    if (contextualCorrelations.isNotEmpty) score += 5;
    if (subjectiveFeedback.isNotEmpty) score += 5;

    final conflicts = _weightingService.detectSignalConflict(
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      subjectiveFeedback: subjectiveFeedback,
      forecasts: forecasts,
    );
    if (conflicts.isNotEmpty) {
      score -= conflicts.length * 12;
      factors.addAll(conflicts);
    }
    final coverage = [
      trends.isNotEmpty,
      recoveryProfiles.isNotEmpty,
      forecasts.isNotEmpty,
      contextualCorrelations.isNotEmpty,
      subjectiveFeedback.isNotEmpty,
    ].where((available) => available).length;
    if (coverage < 3) {
      score -= 12;
      factors.add('baixa cobertura de dados');
    }

    final clamped = score.clamp(0, 100).toDouble();
    return MultimodalConfidenceResult(
      score: clamped,
      level: _levelFor(clamped),
      factors: factors,
    );
  }

  MultimodalConfidenceLevel _levelFor(double score) {
    if (score >= 75) return MultimodalConfidenceLevel.high;
    if (score >= 45) return MultimodalConfidenceLevel.medium;
    return MultimodalConfidenceLevel.low;
  }
}
