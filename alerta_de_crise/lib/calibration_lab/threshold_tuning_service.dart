import 'calibration_models.dart';
import 'calibration_profile.dart';

class ThresholdTuningService {
  const ThresholdTuningService();

  CalibrationProfile applyProfile(CalibrationProfile profile) {
    final weights = normalizeWeights({
      'confidence': profile.confidenceWeight,
      'fusion': profile.fusionWeight,
    });
    return profile.copyWith(
      heartRateSensitivity: _bounded(profile.heartRateSensitivity, 0.1, 2),
      hrvSuppressionSensitivity: _bounded(
        profile.hrvSuppressionSensitivity,
        0.1,
        2,
      ),
      recoverySensitivity: _bounded(profile.recoverySensitivity, 0.1, 2),
      forecastSensitivity: _bounded(profile.forecastSensitivity, 0.1, 2),
      confidenceWeight: weights['confidence'] ?? 0.5,
      fusionWeight: weights['fusion'] ?? 0.5,
      escalationThreshold: _bounded(profile.escalationThreshold, 0, 100),
      recoveryThreshold: _bounded(profile.recoveryThreshold, 0, 100),
    );
  }

  List<CalibrationProfile> generateVariants(CalibrationProfile profile) {
    final applied = applyProfile(profile);
    return [
      applied.copyWith(
        id: '${applied.id}-stable',
        name: '${applied.name} Stable',
      ),
      applyProfile(
        applied.copyWith(
          id: '${applied.id}-sensitive',
          name: '${applied.name} Sensitive',
          forecastSensitivity: applied.forecastSensitivity + 0.08,
          escalationThreshold: applied.escalationThreshold - 4,
        ),
      ),
      applyProfile(
        applied.copyWith(
          id: '${applied.id}-recovery',
          name: '${applied.name} Recovery',
          recoverySensitivity: applied.recoverySensitivity + 0.1,
          recoveryThreshold: applied.recoveryThreshold + 3,
        ),
      ),
    ];
  }

  Map<String, double> normalizeWeights(Map<String, double> weights) {
    if (weights.isEmpty) return const {};
    final positive = weights.map(
      (key, value) => MapEntry(key, value < 0 ? 0.0 : value),
    );
    final total = positive.values.fold<double>(0, (sum, value) => sum + value);
    if (total == 0) {
      final equal = 1 / positive.length;
      return positive.map((key, _) => MapEntry(key, equal));
    }
    return positive.map((key, value) => MapEntry(key, value / total));
  }

  List<CalibrationThresholdComparison> compareThresholds({
    required CalibrationProfile baseline,
    required CalibrationProfile candidate,
  }) {
    return [
      _compare(
        'escalation threshold',
        baseline.escalationThreshold,
        candidate.escalationThreshold,
      ),
      _compare(
        'recovery threshold',
        baseline.recoveryThreshold,
        candidate.recoveryThreshold,
      ),
      _compare(
        'forecast sensitivity',
        baseline.forecastSensitivity,
        candidate.forecastSensitivity,
      ),
      _compare(
        'recovery sensitivity',
        baseline.recoverySensitivity,
        candidate.recoverySensitivity,
      ),
    ];
  }

  CalibrationThresholdComparison _compare(
    String label,
    double baseline,
    double candidate,
  ) {
    final delta = candidate - baseline;
    final direction = delta.abs() < 0.001
        ? 'sem mudança observada'
        : delta > 0
        ? 'ajuste de parâmetros mais alto'
        : 'ajuste de parâmetros mais baixo';
    return CalibrationThresholdComparison(
      label: label,
      baselineValue: baseline,
      candidateValue: candidate,
      delta: delta,
      interpretation: '$direction em calibração experimental.',
    );
  }

  double _bounded(double value, double min, double max) {
    return value.clamp(min, max).toDouble();
  }
}
