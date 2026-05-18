import 'package:flutter/material.dart';

import '../../autonomic_recovery/autonomic_recovery_models.dart';
import '../../cognitive_feedback/cognitive_feedback_models.dart';
import '../../cognitive_feedback/feedback_correlation_service.dart';
import '../../cognitive_feedback/perceived_state_models.dart';
import '../../cognitive_feedback/subjective_feedback_service.dart';
import '../../contextual_triggers/contextual_event.dart';
import '../../contextual_triggers/contextual_trigger_models.dart';
import '../../physiological_trends/physiological_trend_models.dart';
import '../../physiological_trends/trend_window.dart';
import '../../predictive_forecasting/physiological_forecast_window.dart';
import '../../predictive_forecasting/predictive_forecast_models.dart';

class CognitiveFeedbackDebugPage extends StatefulWidget {
  const CognitiveFeedbackDebugPage({super.key});

  @override
  State<CognitiveFeedbackDebugPage> createState() =>
      _CognitiveFeedbackDebugPageState();
}

class _CognitiveFeedbackDebugPageState
    extends State<CognitiveFeedbackDebugPage> {
  final SubjectiveFeedbackService _feedbackService =
      SubjectiveFeedbackService();
  final FeedbackCorrelationService _correlationService =
      const FeedbackCorrelationService();
  final TextEditingController _notesController = TextEditingController(
    text: 'autoavaliação debug',
  );

  int _stress = 6;
  int _fatigue = 5;
  int _control = 6;
  int _recovery = 5;
  int _emotionalIntensity = 6;
  List<SubjectiveFeedbackEntry> _history = const [];
  FeedbackCorrelationResult? _correlation;

  @override
  void initState() {
    super.initState();
    _recalculateCorrelation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final entry = await _feedbackService.submitFeedback(
      perceivedState: _currentState(),
      contextualFactors: const ['contexto emocional percebido', 'debug'],
      trends: _mockTrends(),
      recoveryProfiles: _mockRecovery(),
      contextualCorrelations: _mockCorrelations(),
      forecasts: _mockForecasts(),
      history: _history,
      persist: false,
    );
    setState(() => _history = [entry, ..._history].take(6).toList());
    _recalculateCorrelation();
  }

  void _simulateHighStress() {
    setState(() {
      _stress = 9;
      _fatigue = 8;
      _control = 3;
      _recovery = 2;
      _emotionalIntensity = 8;
      _notesController.text = 'sensação percebida de alta ativação';
    });
    _recalculateCorrelation();
  }

  void _recalculateCorrelation() {
    final result = _correlationService.correlateFeedback(
      perceivedState: _currentState(),
      trends: _mockTrends(),
      recoveryProfiles: _mockRecovery(),
      contextualCorrelations: _mockCorrelations(),
      forecasts: _mockForecasts(),
      history: _history,
    );
    setState(() => _correlation = result);
  }

  PerceivedState _currentState() {
    return PerceivedState(
      timestamp: DateTime.now(),
      perceivedStress: _stress,
      perceivedFatigue: _fatigue,
      perceivedControl: _control,
      perceivedRecovery: _recovery,
      emotionalIntensity: _emotionalIntensity,
      notes: _notesController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _correlation;
    final perceivedRecovery = _feedbackService.calculatePerceivedRecovery(
      _history,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Cognitive Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'feedback subjetivo experimental; autoavaliação; não representa avaliação clínica.',
          ),
          const SizedBox(height: 16),
          _ScaleSlider(
            label: 'Percepção subjetiva de stress',
            value: _stress,
            onChanged: (value) => setState(() => _stress = value),
          ),
          _ScaleSlider(
            label: 'Fadiga percebida',
            value: _fatigue,
            onChanged: (value) => setState(() => _fatigue = value),
          ),
          _ScaleSlider(
            label: 'Controle percebido',
            value: _control,
            onChanged: (value) => setState(() => _control = value),
          ),
          _ScaleSlider(
            label: 'Recovery percebida',
            value: _recovery,
            onChanged: (value) => setState(() => _recovery = value),
          ),
          _ScaleSlider(
            label: 'Intensidade emocional percebida',
            value: _emotionalIntensity,
            onChanged: (value) => setState(() => _emotionalIntensity = value),
          ),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _submitFeedback,
                child: const Text('Register feedback'),
              ),
              FilledButton.tonal(
                onPressed: _simulateHighStress,
                child: const Text('Simulate state'),
              ),
              OutlinedButton(
                onPressed: _recalculateCorrelation,
                child: const Text('Recalculate'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricTile(
            title: 'Percepção vs fisiologia',
            value: result == null
                ? '-'
                : '${result.subjectiveCorrelation.toStringAsFixed(0)}%',
            subtitle: 'correlação experimental da sensação percebida',
          ),
          _MetricTile(
            title: 'Recovery percebida',
            value: perceivedRecovery.toStringAsFixed(0),
            subtitle: 'autoavaliação longitudinal recente',
          ),
          _MetricTile(
            title: 'Inconsistência percebida',
            value: result?.hasMismatch == true ? 'observada' : 'baixa',
            subtitle: result?.patterns.join(', ') ?? 'sem padrões observados',
          ),
          _MetricTile(
            title: 'Correlação contextual',
            value: result == null ? '-' : result.confidence.toStringAsFixed(0),
            subtitle: 'contexto emocional percebido e sinais fisiológicos',
          ),
          const SizedBox(height: 8),
          for (final entry in _history)
            Card(
              child: ListTile(
                title: Text(
                  'Stress ${entry.perceivedState.perceivedStress} / Fatigue ${entry.perceivedState.perceivedFatigue}',
                ),
                subtitle: Text(
                  '${entry.perceivedState.notes}\n${entry.safetyCopy}',
                ),
                trailing: Text(entry.confidence.toStringAsFixed(0)),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _ScaleSlider extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _ScaleSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value/10'),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: value.toString(),
          onChanged: (next) => onChanged(next.round()),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(value),
      ),
    );
  }
}

List<PhysiologicalTrend> _mockTrends() {
  return [
    PhysiologicalTrend(
      averageHeartRate: 91,
      averageHrv: 28,
      hrvSlope: -4,
      heartRateSlope: 7,
      activationDensity: 68,
      escalationScore: 70,
      generatedAt: DateTime.now(),
      window: TrendWindow.shortTerm,
    ),
  ];
}

List<AutonomicRecoveryProfile> _mockRecovery() {
  return [
    AutonomicRecoveryProfile(
      recoveryRate: 44,
      hrvRecoverySlope: 1,
      heartRateNormalization: 48,
      baselineReturnTime: const Duration(minutes: 32),
      resilienceScore: 50,
      fatigueScore: 62,
      stressCarryover: 58,
      generatedAt: DateTime.now(),
      resilienceLevel: AutonomicResilienceLevel.fatigued,
    ),
  ];
}

List<EscalationForecast> _mockForecasts() {
  return [
    EscalationForecast(
      id: 'debug-subjective-forecast',
      generatedAt: DateTime.now(),
      forecastWindow: PhysiologicalForecastWindow.nearFuture,
      escalationProbability: 68,
      forecastConfidence: const ForecastConfidenceResult(
        score: 66,
        level: ForecastConfidenceLevel.mediumConfidence,
        factors: ['feedback experimental'],
      ),
      escalationRiskLevel: ForecastRiskLevel.elevated,
      contributingFactors: const ['sinais fisiológicos'],
      recoveryProtection: 34,
      autonomicLoad: 72,
    ),
  ];
}

List<ContextualTriggerCorrelation> _mockCorrelations() {
  return [
    ContextualTriggerCorrelation(
      category: ContextualCategory.work,
      occurrenceCount: 3,
      escalationCorrelation: 62,
      recoveryImpact: 38,
      confidence: 64,
      lastOccurrence: DateTime.now(),
      associatedMarkers: const [],
    ),
  ];
}
