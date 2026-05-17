import '../core/crisis_detection/physiological_sample.dart';

class PhysiologicalDriftAnalysis {
  final double heartRateSlope;
  final double hrvSlope;
  final bool heartRateIncreasing;
  final bool hrvDecreasing;
  final bool activationDensityIncreasing;
  final bool confidenceDegrading;

  const PhysiologicalDriftAnalysis({
    required this.heartRateSlope,
    required this.hrvSlope,
    required this.heartRateIncreasing,
    required this.hrvDecreasing,
    required this.activationDensityIncreasing,
    required this.confidenceDegrading,
  });

  factory PhysiologicalDriftAnalysis.fromSamples({
    required List<PhysiologicalSample> samples,
    required double activationDensity,
    double previousActivationDensity = 0,
    int? currentConfidenceScore,
    int? previousConfidenceScore,
  }) {
    final ordered = [...samples]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final heartRateSlope = _slope(
      ordered.map((sample) => sample.heartRateBpm).toList(),
    );
    final hrvSlope = _slope(
      ordered.map((sample) => sample.hrvRmssdMs).whereType<double>().toList(),
    );

    return PhysiologicalDriftAnalysis(
      heartRateSlope: heartRateSlope,
      hrvSlope: hrvSlope,
      heartRateIncreasing: heartRateSlope >= 0.08,
      hrvDecreasing: hrvSlope <= -0.08,
      activationDensityIncreasing:
          activationDensity > previousActivationDensity + 0.10,
      confidenceDegrading:
          currentConfidenceScore != null &&
          previousConfidenceScore != null &&
          currentConfidenceScore < previousConfidenceScore - 10,
    );
  }

  static double _slope(List<double> values) {
    if (values.length < 2) {
      return 0;
    }
    final n = values.length;
    final meanX = (n - 1) / 2;
    final meanY = values.reduce((a, b) => a + b) / n;
    var numerator = 0.0;
    var denominator = 0.0;
    for (var i = 0; i < n; i += 1) {
      final dx = i - meanX;
      numerator += dx * (values[i] - meanY);
      denominator += dx * dx;
    }
    if (denominator == 0) {
      return 0;
    }
    return numerator / denominator;
  }
}
