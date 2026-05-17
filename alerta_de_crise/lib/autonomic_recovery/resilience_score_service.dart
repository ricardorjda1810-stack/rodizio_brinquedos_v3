import 'autonomic_recovery_models.dart';
import 'physiological_fatigue_model.dart';

class ResilienceScoreService {
  final PhysiologicalFatigueModel _fatigueModel;

  const ResilienceScoreService({
    PhysiologicalFatigueModel fatigueModel = const PhysiologicalFatigueModel(),
  }) : _fatigueModel = fatigueModel;

  ResilienceScoreResult calculate({
    required double recoveryRate,
    required double heartRateNormalization,
    required double hrvRecoverySlope,
    required double activationDensity,
    required bool incompleteRecovery,
    Duration? baselineReturnTime,
    double previousStressCarryover = 0,
  }) {
    final stressCarryover = _fatigueModel.stressCarryover(
      activationDensity: activationDensity,
      incompleteRecovery: incompleteRecovery,
      previousCarryover: previousStressCarryover,
    );
    final fatigueScore = _fatigueModel.fatigueScore(
      stressCarryover: stressCarryover,
      activationDensity: activationDensity,
      incompleteRecovery: incompleteRecovery,
    );
    final returnBonus = baselineReturnTime == null
        ? 0
        : baselineReturnTime.inMinutes <= 5
        ? 15
        : baselineReturnTime.inMinutes <= 30
        ? 8
        : 0;
    final rawScore =
        45 +
        (recoveryRate * 20).round() +
        (heartRateNormalization * 20).round() +
        (hrvRecoverySlope > 0 ? 10 : 0) +
        returnBonus -
        fatigueScore;
    final resilienceScore = rawScore.clamp(0, 100);

    return ResilienceScoreResult(
      resilienceScore: resilienceScore,
      fatigueScore: fatigueScore,
      stressCarryover: stressCarryover,
      recoveryEfficiency: ((recoveryRate + heartRateNormalization) / 2).clamp(
        0,
        1,
      ),
      level: _levelFromScore(
        resilienceScore: resilienceScore,
        fatigueScore: fatigueScore,
      ),
    );
  }

  AutonomicResilienceLevel _levelFromScore({
    required int resilienceScore,
    required int fatigueScore,
  }) {
    if (fatigueScore >= 75 || resilienceScore < 30) {
      return AutonomicResilienceLevel.overloaded;
    }
    if (fatigueScore >= 55 || resilienceScore < 50) {
      return AutonomicResilienceLevel.fatigued;
    }
    if (resilienceScore >= 75 && fatigueScore < 35) {
      return AutonomicResilienceLevel.resilient;
    }
    return AutonomicResilienceLevel.stable;
  }
}
