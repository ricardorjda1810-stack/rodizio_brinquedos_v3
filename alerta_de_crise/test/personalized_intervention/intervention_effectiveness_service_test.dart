import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/contextual_triggers/contextual_event.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/data/crisis_detection/intervention_history_entry.dart';
import 'package:signalflow/personalized_intervention/intervention_effectiveness_service.dart';

void main() {
  group('InterventionEffectivenessService', () {
    const service = InterventionEffectivenessService();

    test('calculates consistent success rate', () {
      final result = service
          .analyzeInterventionEffectiveness(
            interventions: [
              _intervention('guided-pause', delta: -20, improved: true),
              _intervention('guided-pause', delta: -10, improved: true),
              _intervention('guided-pause', delta: 4, improved: false),
            ],
          )
          .single;

      expect(result.successRate, closeTo(66.6, 0.2));
      expect(result.effectivenessScore, greaterThan(0));
    });

    test('calculates recovery benefit from score and recovery profiles', () {
      final benefit = service.calculateRecoveryBenefit(
        interventions: [_intervention('paced-breathing', delta: -35)],
        recoveryProfiles: [_recovery()],
      );

      expect(benefit, greaterThan(25));
    });

    test('calculates contextual performance', () {
      final completedAt = DateTime.utc(2026, 5, 18, 12);
      final performance = service.calculateContextualPerformance(
        interventions: [
          _intervention(
            'grounding',
            completedAt: completedAt,
            delta: -18,
            improved: true,
          ),
        ],
        contextEvents: [
          _context(completedAt.subtract(const Duration(minutes: 30))),
        ],
      );

      expect(performance, greaterThan(50));
    });

    test('confidence is consistent with observed data volume', () {
      final low = service
          .analyzeInterventionEffectiveness(
            interventions: [_intervention('guided-pause')],
          )
          .single;
      final higher = service
          .analyzeInterventionEffectiveness(
            interventions: [
              _intervention('guided-pause', id: 'a'),
              _intervention('guided-pause', id: 'b'),
              _intervention('guided-pause', id: 'c'),
            ],
            recoveryProfiles: [_recovery(), _recovery()],
          )
          .single;

      expect(higher.confidence, greaterThan(low.confidence));
    });
  });
}

InterventionHistoryEntry _intervention(
  String type, {
  String id = 'intervention',
  DateTime? completedAt,
  int delta = -20,
  bool improved = true,
}) {
  final end = completedAt ?? DateTime.utc(2026, 5, 18, 12);
  return InterventionHistoryEntry(
    id: id,
    protocolId: type,
    startedAt: end.subtract(const Duration(minutes: 5)),
    completedAt: end,
    durationSeconds: 300,
    completed: true,
    userReportedImprovement: improved,
    finalResponse: CognitiveCheckResponse.feelingOk,
    preInterventionScore: 70,
    postInterventionScore: 70 + delta,
    scoreDelta: delta,
  );
}

AutonomicRecoveryProfile _recovery() {
  return AutonomicRecoveryProfile(
    recoveryRate: 0.64,
    hrvRecoverySlope: 0.3,
    heartRateNormalization: 0.58,
    baselineReturnTime: const Duration(minutes: 15),
    resilienceScore: 66,
    fatigueScore: 34,
    stressCarryover: 0.24,
    generatedAt: DateTime.utc(2026, 5, 18, 12, 10),
    resilienceLevel: AutonomicResilienceLevel.stable,
  );
}

ContextualEvent _context(DateTime timestamp) {
  return ContextualEvent(
    id: 'context',
    timestamp: timestamp,
    category: ContextualCategory.work,
    label: 'Work',
    description: 'contexto',
    intensity: ContextualIntensity.medium,
    source: 'test',
  );
}
