import 'package:flutter/material.dart';

import '../../autonomic_recovery/autonomic_recovery_models.dart';
import '../../contextual_triggers/contextual_event.dart';
import '../../core/crisis_detection/cognitive_check_response.dart';
import '../../data/crisis_detection/intervention_history_entry.dart';
import '../../personalized_intervention/intervention_adaptation_service.dart';
import '../../personalized_intervention/intervention_effectiveness_service.dart';
import '../../personalized_intervention/personalized_intervention_models.dart';

class PersonalizedInterventionDebugPage extends StatefulWidget {
  const PersonalizedInterventionDebugPage({super.key});

  @override
  State<PersonalizedInterventionDebugPage> createState() =>
      _PersonalizedInterventionDebugPageState();
}

class _PersonalizedInterventionDebugPageState
    extends State<PersonalizedInterventionDebugPage> {
  final _adaptationService = InterventionAdaptationService();
  final _effectivenessService = const InterventionEffectivenessService();

  List<InterventionHistoryEntry> _interventions = const [];
  List<ContextualEvent> _contexts = const [];
  List<InterventionEffectivenessResult> _effectiveness = const [];
  List<ContextualInterventionRecommendation> _recommendations = const [];

  @override
  void initState() {
    super.initState();
    _simulateBalancedContext();
  }

  Future<void> _simulateBalancedContext() async {
    final now = DateTime.now();
    _interventions = [
      _intervention('pause-1', 'guided-pause', now, -24, true),
      _intervention(
        'breath-1',
        'paced-breathing',
        now.subtract(const Duration(hours: 3)),
        -32,
        true,
      ),
      _intervention(
        'breath-2',
        'paced-breathing',
        now.subtract(const Duration(days: 1)),
        -20,
        true,
      ),
      _intervention(
        'ground-1',
        'grounding',
        now.subtract(const Duration(days: 2)),
        -5,
        false,
      ),
    ];
    _contexts = [
      _context('work', now.subtract(const Duration(hours: 3, minutes: 20))),
      _context('social', now.subtract(const Duration(days: 1, minutes: 30))),
    ];
    await _recalculate();
  }

  Future<void> _simulateFatigueContext() async {
    final now = DateTime.now();
    _interventions = [
      _intervention('pause-1', 'guided-pause', now, -8, false),
      _intervention(
        'body-1',
        'body-scan',
        now.subtract(const Duration(hours: 4)),
        -22,
        true,
      ),
      _intervention(
        'body-2',
        'body-scan',
        now.subtract(const Duration(days: 1)),
        -18,
        true,
      ),
    ];
    _contexts = [
      _context('sleep', now.subtract(const Duration(hours: 6))),
      _context('caffeine', now.subtract(const Duration(hours: 2))),
    ];
    await _recalculate();
  }

  Future<void> _recalculate() async {
    final recovery = [
      AutonomicRecoveryProfile(
        recoveryRate: 0.56,
        hrvRecoverySlope: 0.24,
        heartRateNormalization: 0.58,
        baselineReturnTime: const Duration(minutes: 18),
        resilienceScore: 62,
        fatigueScore: 42,
        stressCarryover: 0.32,
        generatedAt: DateTime.now(),
        resilienceLevel: AutonomicResilienceLevel.stable,
      ),
    ];
    final effectiveness = _effectivenessService
        .analyzeInterventionEffectiveness(
          interventions: _interventions,
          recoveryProfiles: recovery,
          contextEvents: _contexts,
        );
    final recommendations = await _adaptationService.generateRecommendations(
      interventions: _interventions,
      recoveryProfiles: recovery,
      contextEvents: _contexts,
    );
    setState(() {
      _effectiveness = effectiveness;
      _recommendations = recommendations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalized Interventions')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Adaptação experimental de intervenções observadas: sugestão '
            'experimental baseada em padrões observados, resposta fisiológica '
            'e padrões de recuperação. Não garante eficácia.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _simulateBalancedContext,
                child: const Text('Simular contexto estável'),
              ),
              OutlinedButton(
                onPressed: _simulateFatigueContext,
                child: const Text('Simular fadiga'),
              ),
              FilledButton(
                onPressed: _recalculate,
                child: const Text('Recalcular'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Best interventions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final recommendation in _recommendations)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.interventionType,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'Recommendation score: ${recommendation.recommendationScore.toStringAsFixed(1)}',
                    ),
                    Text(
                      'Recovery benefit: ${recommendation.expectedRecoveryBenefit.toStringAsFixed(1)}',
                    ),
                    Text(
                      'Confidence: ${recommendation.confidence.toStringAsFixed(1)}',
                    ),
                    Text(
                      'Contextual performance: ${recommendation.contextualFactors.join(', ')}',
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Learning', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final result in _effectiveness)
            Card(
              child: ListTile(
                title: Text(result.interventionType),
                subtitle: Text(
                  'Success rates ${result.successRate.toStringAsFixed(1)} | '
                  'recovery benefit ${result.recoveryBenefit.toStringAsFixed(1)} | '
                  'contextual performance ${result.contextualPerformance.toStringAsFixed(1)}',
                ),
                trailing: Text(result.effectivenessScore.toStringAsFixed(0)),
              ),
            ),
        ],
      ),
    );
  }

  InterventionHistoryEntry _intervention(
    String id,
    String type,
    DateTime completedAt,
    int delta,
    bool improved,
  ) {
    return InterventionHistoryEntry(
      id: id,
      protocolId: type,
      startedAt: completedAt.subtract(const Duration(minutes: 5)),
      completedAt: completedAt,
      durationSeconds: 300,
      completed: true,
      userReportedImprovement: improved,
      finalResponse: CognitiveCheckResponse.feelingOk,
      preInterventionScore: 70,
      postInterventionScore: 70 + delta,
      scoreDelta: delta,
    );
  }

  ContextualEvent _context(String category, DateTime timestamp) {
    return ContextualEvent(
      id: 'context-${timestamp.microsecondsSinceEpoch}',
      timestamp: timestamp,
      category: ContextualCategory.values.byName(category),
      label: category,
      description: 'Contexto simulado para sugestões contextuais.',
      intensity: ContextualIntensity.medium,
      source: 'debug',
    );
  }
}
