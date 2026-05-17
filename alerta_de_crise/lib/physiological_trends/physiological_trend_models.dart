import 'trend_window.dart';

class PhysiologicalTrend {
  final double? averageHeartRate;
  final double? averageHrv;
  final double hrvSlope;
  final double heartRateSlope;
  final double activationDensity;
  final int escalationScore;
  final DateTime generatedAt;
  final TrendWindow window;

  const PhysiologicalTrend({
    required this.averageHeartRate,
    required this.averageHrv,
    required this.hrvSlope,
    required this.heartRateSlope,
    required this.activationDensity,
    required this.escalationScore,
    required this.generatedAt,
    required this.window,
  });
}
