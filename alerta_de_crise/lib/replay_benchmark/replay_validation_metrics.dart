import 'dart:math';

class ReplayValidationMetrics {
  const ReplayValidationMetrics();

  double forecastAgreement(List<double> expected, List<double> actual) {
    return _agreement(expected, actual);
  }

  double recoveryAgreement(List<double> expected, List<double> actual) {
    return _agreement(expected, actual);
  }

  double escalationTimingConsistency(
    List<DateTime> expected,
    List<DateTime> actual,
  ) {
    if (expected.isEmpty && actual.isEmpty) return 100;
    if (expected.isEmpty || actual.isEmpty) return 0;
    final count = min(expected.length, actual.length);
    var totalDeltaSeconds = 0;
    for (var index = 0; index < count; index += 1) {
      totalDeltaSeconds += expected[index]
          .difference(actual[index])
          .inSeconds
          .abs();
    }
    final averageDelta = totalDeltaSeconds / count;
    return (100 - averageDelta.clamp(0, 100)).toDouble();
  }

  double confidenceStability(List<double> confidenceScores) {
    if (confidenceScores.isEmpty) return 0;
    final average = _average(confidenceScores);
    final variance =
        confidenceScores
            .map((score) => (score - average) * (score - average))
            .fold<double>(0, (sum, value) => sum + value) /
        confidenceScores.length;
    return (100 - sqrt(variance).clamp(0, 100)).toDouble();
  }

  double replayConsistency(List<double> scores) {
    if (scores.isEmpty) return 0;
    return _average(scores).clamp(0, 100).toDouble();
  }

  double multimodalConsistency(List<double> agreementScores) {
    if (agreementScores.isEmpty) return 0;
    return _average(agreementScores).clamp(0, 100).toDouble();
  }

  double falseEscalationRate({
    required int falseEscalations,
    required int totalReplays,
  }) {
    if (totalReplays <= 0) return 0;
    return ((falseEscalations / totalReplays) * 100).clamp(0, 100).toDouble();
  }

  double _agreement(List<double> expected, List<double> actual) {
    if (expected.isEmpty && actual.isEmpty) return 100;
    if (expected.isEmpty || actual.isEmpty) return 0;
    final count = min(expected.length, actual.length);
    var totalDelta = 0.0;
    for (var index = 0; index < count; index += 1) {
      totalDelta += (expected[index] - actual[index]).abs();
    }
    final averageDelta = totalDelta / count;
    return (100 - averageDelta.clamp(0, 100)).toDouble();
  }

  double _average(List<double> values) {
    if (values.isEmpty) return 0;
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }
}
