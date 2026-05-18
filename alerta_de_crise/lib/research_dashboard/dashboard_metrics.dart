class DashboardMetrics {
  final double? averageHeartRate;
  final double? averageHrv;
  final double averageConfidence;
  final int escalationCount;
  final int interventionCount;
  final double recoveryEfficiency;
  final int resilienceScore;
  final int fatigueScore;
  final double activationDensity;
  final double baselineStability;
  final double stressCarryover;

  const DashboardMetrics({
    required this.averageHeartRate,
    required this.averageHrv,
    required this.averageConfidence,
    required this.escalationCount,
    required this.interventionCount,
    required this.recoveryEfficiency,
    required this.resilienceScore,
    required this.fatigueScore,
    required this.activationDensity,
    required this.baselineStability,
    required this.stressCarryover,
  });

  static const empty = DashboardMetrics(
    averageHeartRate: null,
    averageHrv: null,
    averageConfidence: 0,
    escalationCount: 0,
    interventionCount: 0,
    recoveryEfficiency: 0,
    resilienceScore: 0,
    fatigueScore: 0,
    activationDensity: 0,
    baselineStability: 100,
    stressCarryover: 0,
  );
}
