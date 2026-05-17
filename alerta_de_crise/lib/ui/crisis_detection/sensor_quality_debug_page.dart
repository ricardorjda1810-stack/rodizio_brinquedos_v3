import 'package:flutter/material.dart';

import '../../core/crisis_detection/physiological_sample.dart';
import '../../sensor_quality/sensor_quality_models.dart';
import '../../sensor_quality/sensor_quality_service.dart';

enum _QualityScenario { validRr, invalidRr, highMovement, lostContact }

class SensorQualityDebugPage extends StatefulWidget {
  const SensorQualityDebugPage({super.key});

  @override
  State<SensorQualityDebugPage> createState() => _SensorQualityDebugPageState();
}

class _SensorQualityDebugPageState extends State<SensorQualityDebugPage> {
  final SensorQualityService _service = const SensorQualityService();
  _QualityScenario _scenario = _QualityScenario.validRr;
  SensorQualityEvaluation? _evaluation;

  @override
  Widget build(BuildContext context) {
    final evaluation = _evaluation;

    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Quality debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Qualidade fisiológica experimental',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tela interna para avaliar confiança do sinal antes de alimentar o motor estatístico. Não realiza diagnóstico.',
          ),
          const SizedBox(height: 16),
          Text('Cenários', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final scenario in _QualityScenario.values)
                ChoiceChip(
                  label: Text(_labelFor(scenario)),
                  selected: _scenario == scenario,
                  onSelected: (_) => _setScenario(scenario),
                ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _evaluate,
            child: const Text('Avaliar qualidade'),
          ),
          if (evaluation != null) ...[
            const SizedBox(height: 16),
            _EvaluationCard(evaluation: evaluation),
          ],
        ],
      ),
    );
  }

  void _setScenario(_QualityScenario scenario) {
    setState(() {
      _scenario = scenario;
      _evaluation = null;
    });
  }

  void _evaluate() {
    final data = _scenarioData(_scenario);
    setState(() {
      _evaluation = _service.evaluateSampleQuality(
        sample: data.sample,
        rrIntervalsMs: data.rrIntervalsMs,
        contactDetected: data.contactDetected,
      );
    });
  }

  String _labelFor(_QualityScenario scenario) {
    return switch (scenario) {
      _QualityScenario.validRr => 'RR válido',
      _QualityScenario.invalidRr => 'RR inválido',
      _QualityScenario.highMovement => 'Movimento',
      _QualityScenario.lostContact => 'Sem contato',
    };
  }

  _QualityScenarioData _scenarioData(_QualityScenario scenario) {
    final timestamp = DateTime(2026, 5, 17, 10);

    return switch (scenario) {
      _QualityScenario.validRr => _QualityScenarioData(
        sample: PhysiologicalSample(
          timestamp: timestamp,
          heartRateBpm: 74,
          movementIntensity: 0.1,
          hrvRmssdMs: 24,
        ),
        rrIntervalsMs: const [810, 790, 805, 800],
        contactDetected: true,
      ),
      _QualityScenario.invalidRr => _QualityScenarioData(
        sample: PhysiologicalSample(
          timestamp: timestamp,
          heartRateBpm: 250,
          movementIntensity: 0.1,
        ),
        rrIntervalsMs: const [810, 120, 2700, 760],
        contactDetected: true,
      ),
      _QualityScenario.highMovement => _QualityScenarioData(
        sample: PhysiologicalSample(
          timestamp: timestamp,
          heartRateBpm: 120,
          movementIntensity: 0.9,
        ),
        rrIntervalsMs: const [500, 520, 510],
        contactDetected: true,
      ),
      _QualityScenario.lostContact => _QualityScenarioData(
        sample: PhysiologicalSample(
          timestamp: timestamp,
          heartRateBpm: 76,
          movementIntensity: 0.1,
        ),
        rrIntervalsMs: const [800, 805, 795],
        contactDetected: false,
      ),
    };
  }
}

class _QualityScenarioData {
  final PhysiologicalSample sample;
  final List<double> rrIntervalsMs;
  final bool? contactDetected;

  const _QualityScenarioData({
    required this.sample,
    required this.rrIntervalsMs,
    required this.contactDetected,
  });
}

class _EvaluationCard extends StatelessWidget {
  const _EvaluationCard({required this.evaluation});

  final SensorQualityEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final score = evaluation.confidenceScore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resultado', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _Line(label: 'Confidence score', value: '${score.overallScore}'),
            _Line(
              label: 'Signal quality',
              value: evaluation.signalQuality.name,
            ),
            _Line(label: 'RR quality', value: '${score.rrQuality}'),
            _Line(label: 'HR quality', value: '${score.hrQuality}'),
            _Line(
              label: 'Movement confidence',
              value: '${score.movementConfidence}',
            ),
            _Line(
              label: 'Contact confidence',
              value: '${score.contactConfidence}',
            ),
            _Line(
              label: 'Artifacts',
              value: score.hasArtifacts ? 'sim' : 'não',
            ),
            const SizedBox(height: 8),
            Text('Warnings', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            if (score.warnings.isEmpty)
              const Text('Nenhum warning.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final warning in score.warnings)
                    Chip(label: Text(warning)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Text(value),
        ],
      ),
    );
  }
}
