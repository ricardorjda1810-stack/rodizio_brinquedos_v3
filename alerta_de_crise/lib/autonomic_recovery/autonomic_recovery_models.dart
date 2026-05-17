enum AutonomicResilienceLevel { resilient, stable, fatigued, overloaded }

class AutonomicRecoveryProfile {
  final double recoveryRate;
  final double hrvRecoverySlope;
  final double heartRateNormalization;
  final Duration? baselineReturnTime;
  final int resilienceScore;
  final int fatigueScore;
  final double stressCarryover;
  final DateTime generatedAt;
  final AutonomicResilienceLevel resilienceLevel;

  const AutonomicRecoveryProfile({
    required this.recoveryRate,
    required this.hrvRecoverySlope,
    required this.heartRateNormalization,
    required this.baselineReturnTime,
    required this.resilienceScore,
    required this.fatigueScore,
    required this.stressCarryover,
    required this.generatedAt,
    required this.resilienceLevel,
  });
}

class ResilienceScoreResult {
  final int resilienceScore;
  final int fatigueScore;
  final double stressCarryover;
  final double recoveryEfficiency;
  final AutonomicResilienceLevel level;

  const ResilienceScoreResult({
    required this.resilienceScore,
    required this.fatigueScore,
    required this.stressCarryover,
    required this.recoveryEfficiency,
    required this.level,
  });
}
