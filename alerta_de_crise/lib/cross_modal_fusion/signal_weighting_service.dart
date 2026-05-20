import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../cognitive_feedback/cognitive_feedback_models.dart';
import '../contextual_triggers/contextual_trigger_models.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../sensor_quality/sensor_confidence_score.dart';
import 'cross_modal_models.dart';

class SignalWeightingService {
  const SignalWeightingService();

  SignalWeights calculateSignalWeights({
    SensorConfidenceScore? sensorConfidence,
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<ContextualTriggerCorrelation> contextualCorrelations = const [],
    List<SubjectiveFeedbackEntry> subjectiveFeedback = const [],
    List<EscalationForecast> forecasts = const [],
  }) {
    final rrQuality = (sensorConfidence?.rrQuality ?? 60) / 100;
    final hrvCoverage = trends.any((trend) => trend.averageHrv != null)
        ? 0.9
        : 0.35;
    final recoveryCoverage = recoveryProfiles.isEmpty ? 0.25 : 0.85;
    final trendCoverage = trends.isEmpty ? 0.25 : 0.85;
    final contextCoverage = contextualCorrelations.isEmpty ? 0.2 : 0.65;
    final subjectiveCoverage = subjectiveFeedback.isEmpty ? 0.2 : 0.6;
    final confidenceCoverage =
        ((sensorConfidence?.overallScore ??
                    _averageForecastConfidence(forecasts)) /
                100)
            .clamp(0.2, 1.0)
            .toDouble();

    return normalizeWeights(
      SignalWeights(
        rrQuality: rrQuality,
        hrv: hrvCoverage,
        recovery: recoveryCoverage,
        trends: trendCoverage,
        context: contextCoverage,
        subjectiveFeedback: subjectiveCoverage,
        confidenceScore: confidenceCoverage,
      ),
    );
  }

  SignalWeights normalizeWeights(SignalWeights weights) {
    final values = weights.toMap();
    final total = values.values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) {
      return const SignalWeights(
        rrQuality: 1 / 7,
        hrv: 1 / 7,
        recovery: 1 / 7,
        trends: 1 / 7,
        context: 1 / 7,
        subjectiveFeedback: 1 / 7,
        confidenceScore: 1 / 7,
      );
    }
    return SignalWeights(
      rrQuality: weights.rrQuality / total,
      hrv: weights.hrv / total,
      recovery: weights.recovery / total,
      trends: weights.trends / total,
      context: weights.context / total,
      subjectiveFeedback: weights.subjectiveFeedback / total,
      confidenceScore: weights.confidenceScore / total,
    );
  }

  List<String> detectSignalConflict({
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<SubjectiveFeedbackEntry> subjectiveFeedback = const [],
    List<EscalationForecast> forecasts = const [],
  }) {
    final conflicts = <String>[];
    final physiologicalLoad = _physiologicalLoad(trends, forecasts);
    final subjectiveLoad = subjectiveFeedback.isEmpty
        ? physiologicalLoad
        : _average(
            subjectiveFeedback.map(
              (entry) => entry.perceivedState.perceivedLoad * 10.0,
            ),
          );
    if ((physiologicalLoad - subjectiveLoad).abs() >= 35) {
      conflicts.add('divergência fisiologia/percepção subjetiva');
    }

    if (recoveryProfiles.isNotEmpty && forecasts.isNotEmpty) {
      final latestRecovery = recoveryProfiles.last;
      final latestForecast = forecasts.last;
      if (latestRecovery.resilienceScore >= 75 &&
          latestForecast.escalationProbability >= 65) {
        conflicts.add('recovery alto com forecast elevado');
      }
      if (latestRecovery.fatigueScore >= 70 &&
          latestForecast.recoveryProtection >= 70) {
        conflicts.add('fadiga elevada com proteção de recovery alta');
      }
    }
    return conflicts;
  }

  double _averageForecastConfidence(List<EscalationForecast> forecasts) {
    if (forecasts.isEmpty) return 60;
    return _average(
      forecasts.map((forecast) => forecast.forecastConfidence.score.toDouble()),
    );
  }

  double _physiologicalLoad(
    List<PhysiologicalTrend> trends,
    List<EscalationForecast> forecasts,
  ) {
    final trendLoad = trends.isEmpty
        ? 0
        : _average(
            trends.map(
              (trend) => (trend.escalationScore + trend.activationDensity) / 2,
            ),
          );
    final forecastLoad = forecasts.isEmpty
        ? 0
        : _average(forecasts.map((forecast) => forecast.autonomicLoad));
    if (trends.isEmpty && forecasts.isEmpty) return 0;
    if (trends.isEmpty) return forecastLoad.clamp(0, 100).toDouble();
    if (forecasts.isEmpty) return trendLoad.clamp(0, 100).toDouble();
    return ((trendLoad + forecastLoad) / 2).clamp(0, 100).toDouble();
  }

  double _average(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    return list.fold<double>(0, (sum, value) => sum + value) / list.length;
  }
}
