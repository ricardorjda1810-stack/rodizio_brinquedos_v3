import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../sensor_quality/sensor_confidence_score.dart';

class ForecastProbabilityModel {
  const ForecastProbabilityModel();

  double calculate({
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<SensorConfidenceScore> confidenceScores = const [],
  }) {
    final trendAverage = _average(
      trends.map((trend) => trend.escalationScore.toDouble()).toList(),
    );
    final trendMomentum = _secondHalfDelta(
      trends.map((trend) => trend.escalationScore.toDouble()).toList(),
    );
    final heartRateSlope = _average(
      trends.map((trend) => trend.heartRateSlope).toList(),
    );
    final hrvSuppression = _average(
      trends.map((trend) => -trend.hrvSlope).toList(),
    );
    final activationDensity = _average(
      trends.map((trend) => trend.activationDensity).toList(),
    );

    final recoveryEfficiency = _average(
      recoveryProfiles.map((profile) => profile.recoveryRate * 100).toList(),
    );
    final fatigueScore = _average(
      recoveryProfiles
          .map((profile) => profile.fatigueScore.toDouble())
          .toList(),
    );
    final stressCarryover = _average(
      recoveryProfiles.map((profile) => profile.stressCarryover * 100).toList(),
    );
    final confidenceScore = _average(
      confidenceScores.map((score) => score.overallScore.toDouble()).toList(),
    );

    final recoveryProtection =
        ((recoveryEfficiency * 0.18) + ((100 - fatigueScore) * 0.08)).clamp(
          0,
          28,
        );
    final confidencePenalty = confidenceScore < 60
        ? (60 - confidenceScore) * 0.2
        : 0;

    final probability =
        8 +
        trendAverage * 0.28 +
        trendMomentum.clamp(0, 35) * 0.32 +
        _positiveScale(heartRateSlope, threshold: 0.25, multiplier: 10) +
        _positiveScale(hrvSuppression, threshold: 0.15, multiplier: 12) +
        activationDensity * 24 +
        fatigueScore * 0.2 +
        stressCarryover * 0.16 +
        confidencePenalty -
        recoveryProtection;

    return probability.clamp(0, 100).toDouble();
  }

  double _positiveScale(
    double value, {
    required double threshold,
    required double multiplier,
  }) {
    if (value <= threshold) {
      return 0;
    }
    return (value - threshold) * multiplier;
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }

  double _secondHalfDelta(List<double> values) {
    if (values.length < 2) {
      return 0;
    }
    final midpoint = values.length ~/ 2;
    final first = values.take(midpoint).toList();
    final second = values.skip(midpoint).toList();
    return _average(second) - _average(first);
  }
}
