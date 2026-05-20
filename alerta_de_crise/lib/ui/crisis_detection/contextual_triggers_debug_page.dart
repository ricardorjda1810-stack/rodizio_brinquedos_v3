import 'package:flutter/material.dart';

import '../../autonomic_recovery/autonomic_recovery_models.dart';
import '../../contextual_triggers/behavioral_correlation_service.dart';
import '../../contextual_triggers/contextual_event.dart';
import '../../contextual_triggers/contextual_trigger_models.dart';
import '../../contextual_triggers/contextual_trigger_service.dart';
import '../../physiological_trends/physiological_trend_models.dart';
import '../../physiological_trends/trend_window.dart';
import '../../session_timeline/physiological_event_marker.dart';

class ContextualTriggersDebugPage extends StatefulWidget {
  const ContextualTriggersDebugPage({super.key});

  @override
  State<ContextualTriggersDebugPage> createState() =>
      _ContextualTriggersDebugPageState();
}

class _ContextualTriggersDebugPageState
    extends State<ContextualTriggersDebugPage> {
  final _triggerService = ContextualTriggerService();
  final _correlationService = const BehavioralCorrelationService();
  final List<ContextualEvent> _events = [];
  List<ContextualTriggerCorrelation> _correlations = const [];
  List<ContextualInsight> _insights = const [];

  @override
  void initState() {
    super.initState();
    _simulateWorkContext();
  }

  Future<void> _addManualEvent() async {
    final now = DateTime.now();
    final event = await _triggerService.registerEvent(
      timestamp: now,
      category: ContextualCategory.manual,
      label: 'Manual context',
      description: 'Contexto manual para análise experimental.',
      intensity: ContextualIntensity.medium,
    );
    _events.insert(0, event);
    _recalculate();
  }

  Future<void> _simulateWorkContext() async {
    final now = DateTime.now();
    _events
      ..clear()
      ..addAll([
        _event(
          'work-1',
          now.subtract(const Duration(hours: 3)),
          ContextualCategory.work,
          'Work block',
        ),
        _event(
          'work-2',
          now.subtract(const Duration(hours: 2)),
          ContextualCategory.work,
          'Meeting',
        ),
        _event(
          'noise-1',
          now.subtract(const Duration(hours: 2, minutes: -10)),
          ContextualCategory.noise,
          'Noise',
        ),
        _event(
          'work-3',
          now.subtract(const Duration(minutes: 40)),
          ContextualCategory.work,
          'Deadline',
        ),
      ]);
    _recalculate();
  }

  Future<void> _simulateRecoveryContext() async {
    final now = DateTime.now();
    _events
      ..clear()
      ..addAll([
        _event(
          'sleep-1',
          now.subtract(const Duration(hours: 7)),
          ContextualCategory.sleep,
          'Short sleep',
        ),
        _event(
          'caffeine-1',
          now.subtract(const Duration(hours: 4)),
          ContextualCategory.caffeine,
          'Coffee',
        ),
        _event(
          'exercise-1',
          now.subtract(const Duration(hours: 1)),
          ContextualCategory.exercise,
          'Walk',
        ),
      ]);
    _recalculate();
  }

  void _recalculate() {
    final now = DateTime.now();
    final markers = [
      _marker(now.subtract(const Duration(hours: 2, minutes: -20))),
      _marker(now.subtract(const Duration(minutes: 20))),
    ];
    final trends = [
      _trend(now.subtract(const Duration(hours: 2)), 62),
      _trend(now.subtract(const Duration(minutes: 15)), 70),
    ];
    final recovery = [
      _recovery(now.subtract(const Duration(minutes: 10)), fatigue: 58),
    ];
    final correlations = _correlationService.analyzeCorrelations(
      events: _events,
      markers: markers,
      trends: trends,
      recoveryProfiles: recovery,
    );
    final patterns = _correlationService.detectRecurringPatterns(
      events: _events,
      markers: markers,
    );
    final insights = _correlationService.generateContextualInsights(
      correlations: correlations,
      patterns: patterns,
    );
    setState(() {
      _correlations = correlations;
      _insights = insights;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contextual Triggers')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Análise experimental de contexto: correlação não implica '
            'causalidade. Gatilhos potenciais representam padrões observados '
            'junto a sinais fisiológicos.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _addManualEvent,
                child: const Text('Adicionar manual'),
              ),
              OutlinedButton(
                onPressed: _simulateWorkContext,
                child: const Text('Simular trabalho'),
              ),
              OutlinedButton(
                onPressed: _simulateRecoveryContext,
                child: const Text('Simular recuperação'),
              ),
              OutlinedButton(
                onPressed: _recalculate,
                child: const Text('Recalcular'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Eventos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final event in _events)
            Card(
              child: ListTile(
                title: Text('${event.category.name}: ${event.label}'),
                subtitle: Text(event.description),
                trailing: Text(event.intensity.name),
              ),
            ),
          const SizedBox(height: 16),
          Text('Correlações', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final correlation in _correlations)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      correlation.category.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text('Occurrence count: ${correlation.occurrenceCount}'),
                    Text(
                      'Escalation correlation: ${correlation.escalationCorrelation.toStringAsFixed(1)}',
                    ),
                    Text(
                      'Recovery impact: ${correlation.recoveryImpact.toStringAsFixed(1)}',
                    ),
                    Text(
                      'Confidence: ${correlation.confidence.toStringAsFixed(1)}',
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Insights', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final insight in _insights)
            Card(
              child: ListTile(
                title: Text(insight.title),
                subtitle: Text(insight.description),
                trailing: Text(insight.confidence.toStringAsFixed(0)),
              ),
            ),
        ],
      ),
    );
  }

  ContextualEvent _event(
    String id,
    DateTime timestamp,
    ContextualCategory category,
    String label,
  ) {
    return ContextualEvent(
      id: id,
      timestamp: timestamp,
      category: category,
      label: label,
      description: 'Contexto simulado para correlação experimental.',
      intensity: ContextualIntensity.medium,
      source: 'debug',
    );
  }

  PhysiologicalEventMarker _marker(DateTime timestamp) {
    return PhysiologicalEventMarker(
      id: 'marker-${timestamp.microsecondsSinceEpoch}',
      timestamp: timestamp,
      type: EventType.contextualEscalationPattern,
      title: 'Sinais fisiológicos próximos',
      description: 'Marcador simulado para padrões observados.',
      severity: Severity.medium,
      source: 'debug',
    );
  }

  PhysiologicalTrend _trend(DateTime generatedAt, int escalationScore) {
    return PhysiologicalTrend(
      averageHeartRate: 72 + escalationScore * 0.2,
      averageHrv: 44 - escalationScore * 0.1,
      hrvSlope: -0.2,
      heartRateSlope: 0.4,
      activationDensity: 0.42,
      escalationScore: escalationScore,
      generatedAt: generatedAt,
      window: TrendWindow.shortTerm,
    );
  }

  AutonomicRecoveryProfile _recovery(
    DateTime generatedAt, {
    required int fatigue,
  }) {
    return AutonomicRecoveryProfile(
      recoveryRate: 0.42,
      hrvRecoverySlope: 0.2,
      heartRateNormalization: 0.4,
      baselineReturnTime: const Duration(minutes: 20),
      resilienceScore: 48,
      fatigueScore: fatigue,
      stressCarryover: fatigue / 100,
      generatedAt: generatedAt,
      resilienceLevel: AutonomicResilienceLevel.fatigued,
    );
  }
}
