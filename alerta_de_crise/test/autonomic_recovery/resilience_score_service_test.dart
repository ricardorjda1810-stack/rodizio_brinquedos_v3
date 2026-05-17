import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/autonomic_recovery/physiological_fatigue_model.dart';
import 'package:signalflow/autonomic_recovery/resilience_score_service.dart';

void main() {
  group('ResilienceScoreService', () {
    const service = ResilienceScoreService();

    test('calculates consistent fatigue score', () {
      final result = service.calculate(
        recoveryRate: 0.2,
        heartRateNormalization: 0.2,
        hrvRecoverySlope: -1,
        activationDensity: 0.8,
        incompleteRecovery: true,
        previousStressCarryover: 0.4,
      );

      expect(result.fatigueScore, greaterThan(50));
      expect(result.resilienceScore, lessThan(50));
    });

    test('accumulates stress carryover', () {
      const fatigueModel = PhysiologicalFatigueModel();

      final carryover = fatigueModel.stressCarryover(
        activationDensity: 0.8,
        incompleteRecovery: true,
        previousCarryover: 0.4,
      );

      expect(carryover, greaterThan(0.4));
    });

    test('classifies resilient level', () {
      final result = service.calculate(
        recoveryRate: 0.95,
        heartRateNormalization: 0.95,
        hrvRecoverySlope: 2,
        activationDensity: 0,
        incompleteRecovery: false,
        baselineReturnTime: const Duration(minutes: 2),
      );

      expect(result.level, AutonomicResilienceLevel.resilient);
    });

    test('classifies overloaded level', () {
      final result = service.calculate(
        recoveryRate: 0,
        heartRateNormalization: 0,
        hrvRecoverySlope: -2,
        activationDensity: 1,
        incompleteRecovery: true,
        previousStressCarryover: 0.8,
      );

      expect(result.level, AutonomicResilienceLevel.overloaded);
    });
  });
}
