import 'package:flutter/material.dart';

import '../../core/crisis_detection/baseline_session_result.dart';
import '../../core/crisis_detection/baseline_session_service.dart';
import '../../core/crisis_detection/crisis_sample_simulator.dart';
import '../../data/crisis_detection/baseline_profile_repository.dart';

class BaselineCalibrationDebugPage extends StatefulWidget {
  const BaselineCalibrationDebugPage({super.key});

  @override
  State<BaselineCalibrationDebugPage> createState() =>
      _BaselineCalibrationDebugPageState();
}

class _BaselineCalibrationDebugPageState
    extends State<BaselineCalibrationDebugPage> {
  final CrisisSampleSimulator _simulator = const CrisisSampleSimulator();
  final BaselineSessionService _service = const BaselineSessionService();
  final BaselineProfileRepository _repository = BaselineProfileRepository();
  BaselineSessionResult? _result;

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Calibragem inicial')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Esta calibragem cria um padrão fisiológico inicial do usuário.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Fluxo interno com amostras simuladas para preparar a arquitetura de sinais de ativação.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _generateSimulatedBaseline,
            child: const Text('Gerar baseline simulado'),
          ),
          if (result != null) ...[
            const SizedBox(height: 16),
            _BaselineResultCard(result: result),
          ],
        ],
      ),
    );
  }

  void _generateSimulatedBaseline() {
    final samples = _simulator.scenarios
        .map((scenario) => scenario.sample)
        .where(
          (sample) =>
              sample.heartRateBpm >= 35 &&
              sample.heartRateBpm <= 220 &&
              sample.movementIntensity >= 0 &&
              sample.movementIntensity <= 1,
        )
        .toList();
    final result = _service.createInitialBaseline(samples: samples);

    _repository.save(result.baseline);

    setState(() {
      _result = result;
    });
  }
}

class _BaselineResultCard extends StatelessWidget {
  const _BaselineResultCard({required this.result});

  final BaselineSessionResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Padrão fisiológico inicial',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _BaselineLine(
              label: 'FC basal',
              value: result.baseline.restingHeartRateBpm.toStringAsFixed(1),
            ),
            _BaselineLine(
              label: 'HRV basal',
              value: result.baseline.hrvRmssdMs.toStringAsFixed(1),
            ),
            _BaselineLine(
              label: 'Frequência respiratória basal',
              value: result.baseline.respiratoryRate.toStringAsFixed(1),
            ),
            _BaselineLine(
              label: 'Movimento basal',
              value: result.baseline.movementIntensity.toStringAsFixed(2),
            ),
            _BaselineLine(
              label: 'Amostras',
              value: result.sampleCount.toString(),
            ),
            _BaselineLine(
              label: 'Fallback default',
              value: result.usedFallbackDefaults ? 'sim' : 'não',
            ),
            _BaselineLine(
              label: 'Criado em',
              value: result.createdAt.toIso8601String(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BaselineLine extends StatelessWidget {
  const _BaselineLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
