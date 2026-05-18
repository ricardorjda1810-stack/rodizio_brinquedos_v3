import 'package:flutter/material.dart';

import '../../autonomic_recovery/autonomic_recovery_models.dart';
import '../../cognitive_feedback/cognitive_feedback_models.dart';
import '../../cognitive_feedback/perceived_state_models.dart';
import '../../contextual_triggers/contextual_event.dart';
import '../../contextual_triggers/contextual_trigger_models.dart';
import '../../cross_modal_fusion/cross_modal_models.dart';
import '../../cross_modal_fusion/physiological_fusion_service.dart';
import '../../physiological_trends/physiological_trend_models.dart';
import '../../physiological_trends/trend_window.dart';
import '../../predictive_forecasting/physiological_forecast_window.dart';
import '../../predictive_forecasting/predictive_forecast_models.dart';
import '../../sensor_quality/sensor_confidence_score.dart';

class CrossModalFusionDebugPage extends StatefulWidget {
  const CrossModalFusionDebugPage({super.key});

  @override
  State<CrossModalFusionDebugPage> createState() =>
      _CrossModalFusionDebugPageState();
}

class _CrossModalFusionDebugPageState extends State<CrossModalFusionDebugPage> {
  final PhysiologicalFusionService _service = PhysiologicalFusionService();
  PhysiologicalFusionResult? _result;
  bool _simulateConflict = false;

  @override
  void initState() {
    super.initState();
    _recalculateConsensus();
  }

  Future<void> _recalculateConsensus() async {
    final result = await _service.generateFusion(
      sensorConfidence: _sensorConfidence(conflict: _simulateConflict),
      trends: _trends(),
      recoveryProfiles: _recovery(conflict: _simulateConflict),
      contextualCorrelations: _contextual(),
      subjectiveFeedback: _feedback(conflict: _simulateConflict),
      forecasts: _forecasts(conflict: _simulateConflict),
      persist: false,
    );
    setState(() => _result = result);
  }

  void _toggleConflict() {
    setState(() => _simulateConflict = !_simulateConflict);
    _recalculateConsensus();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final consensus = result?.consensus;

    return Scaffold(
      appBar: AppBar(title: const Text('Cross-Modal Fusion')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'consenso experimental; fusão multimodal; não representa avaliação clínica.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _recalculateConsensus,
                child: const Text('Recalculate consensus'),
              ),
              FilledButton.tonal(
                onPressed: _toggleConflict,
                child: Text(
                  _simulateConflict
                      ? 'Use aligned signals'
                      : 'Simulate conflict',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricTile(
            title: 'Integrated stress',
            value: consensus?.integratedStressLoad.toStringAsFixed(0) ?? '-',
            subtitle: 'sinais combinados em fusão experimental',
          ),
          _MetricTile(
            title: 'Integrated recovery',
            value: consensus?.integratedRecoveryState.toStringAsFixed(0) ?? '-',
            subtitle: 'estado integrado sem inferência clínica determinística',
          ),
          _MetricTile(
            title: 'Multimodal confidence',
            value:
                consensus?.multimodalConfidence.level.name ??
                MultimodalConfidenceLevel.low.name,
            subtitle:
                consensus?.multimodalConfidence.factors.join(', ') ??
                'confiança experimental',
          ),
          _MetricTile(
            title: 'Signal agreement',
            value: consensus?.signalAgreement.toStringAsFixed(0) ?? '-',
            subtitle: 'consenso fisiológico integrado',
          ),
          _MetricTile(
            title: 'Conflicts',
            value: '${result?.signalConflicts.length ?? 0}',
            subtitle: result?.signalConflicts.join(', ') ?? 'sem conflito',
          ),
          _MetricTile(
            title: 'Contributing signals',
            value: '${consensus?.contributingSignals.length ?? 0}',
            subtitle:
                consensus?.contributingSignals.join(', ') ??
                'integração multimodal',
          ),
          if (result != null)
            _MetricTile(
              title: 'Weights',
              value: result.weights.trends.toStringAsFixed(2),
              subtitle: result.weights
                  .toMap()
                  .entries
                  .map(
                    (entry) => '${entry.key}=${entry.value.toStringAsFixed(2)}',
                  )
                  .join(', '),
            ),
        ],
      ),
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

SensorConfidenceScore _sensorConfidence({required bool conflict}) {
  return SensorConfidenceScore(
    overallScore: conflict ? 42 : 82,
    rrQuality: conflict ? 38 : 86,
    hrQuality: conflict ? 52 : 84,
    movementConfidence: 76,
    contactConfidence: conflict ? 44 : 88,
    hasArtifacts: conflict,
    warnings: conflict ? const ['signal conflict'] : const [],
  );
}

List<PhysiologicalTrend> _trends() {
  return [
    PhysiologicalTrend(
      averageHeartRate: 92,
      averageHrv: 28,
      hrvSlope: -4,
      heartRateSlope: 7,
      activationDensity: 66,
      escalationScore: 70,
      generatedAt: DateTime.now(),
      window: TrendWindow.shortTerm,
    ),
  ];
}

List<AutonomicRecoveryProfile> _recovery({required bool conflict}) {
  return [
    AutonomicRecoveryProfile(
      recoveryRate: conflict ? 88 : 42,
      hrvRecoverySlope: 1,
      heartRateNormalization: conflict ? 82 : 44,
      baselineReturnTime: const Duration(minutes: 30),
      resilienceScore: conflict ? 84 : 48,
      fatigueScore: conflict ? 12 : 66,
      stressCarryover: conflict ? 20 : 60,
      generatedAt: DateTime.now(),
      resilienceLevel: conflict
          ? AutonomicResilienceLevel.resilient
          : AutonomicResilienceLevel.fatigued,
    ),
  ];
}

List<EscalationForecast> _forecasts({required bool conflict}) {
  return [
    EscalationForecast(
      id: 'debug-fusion-forecast',
      generatedAt: DateTime.now(),
      forecastWindow: PhysiologicalForecastWindow.nearFuture,
      escalationProbability: conflict ? 76 : 68,
      forecastConfidence: const ForecastConfidenceResult(
        score: 68,
        level: ForecastConfidenceLevel.mediumConfidence,
        factors: ['integração multimodal'],
      ),
      escalationRiskLevel: ForecastRiskLevel.elevated,
      contributingFactors: const ['sinais combinados'],
      recoveryProtection: conflict ? 20 : 34,
      autonomicLoad: conflict ? 78 : 70,
    ),
  ];
}

List<ContextualTriggerCorrelation> _contextual() {
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

List<SubjectiveFeedbackEntry> _feedback({required bool conflict}) {
  return [
    SubjectiveFeedbackEntry(
      id: 'debug-feedback',
      generatedAt: DateTime.now(),
      perceivedState: PerceivedState(
        timestamp: DateTime.now(),
        perceivedStress: conflict ? 1 : 7,
        perceivedFatigue: conflict ? 1 : 7,
        perceivedControl: conflict ? 9 : 4,
        perceivedRecovery: conflict ? 9 : 3,
        emotionalIntensity: conflict ? 1 : 7,
        notes: 'feedback experimental',
      ),
      contextualFactors: const ['contexto'],
      physiologicalCorrelation: conflict ? 25 : 72,
      confidence: conflict ? 40 : 68,
    ),
  ];
}
