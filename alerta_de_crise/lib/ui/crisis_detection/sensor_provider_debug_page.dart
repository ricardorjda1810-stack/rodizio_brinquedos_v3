import 'package:flutter/material.dart';

import '../../core/crisis_detection/baseline_profile.dart';
import '../../core/crisis_detection/cognitive_check_response.dart';
import '../../core/crisis_detection/crisis_detection_service.dart';
import '../../core/crisis_detection/crisis_risk_engine.dart';
import '../../core/crisis_detection/crisis_risk_result.dart';
import '../../core/crisis_detection/crisis_sample_simulator.dart';
import '../../core/crisis_detection/physiological_ingestion_service.dart';
import '../../core/crisis_detection/physiological_sample.dart';
import '../../core/crisis_detection/sensor_provider_registry.dart';
import '../../core/crisis_detection/simulated_sensor_provider.dart';
import '../../data/crisis_detection/crisis_risk_event_repository.dart';
import '../theme/ui_tokens.dart';

class SensorProviderDebugPage extends StatefulWidget {
  const SensorProviderDebugPage({super.key});

  @override
  State<SensorProviderDebugPage> createState() =>
      _SensorProviderDebugPageState();
}

class _SensorProviderDebugPageState extends State<SensorProviderDebugPage> {
  final SimulatedSensorProvider _simulatedProvider = SimulatedSensorProvider();
  late final SensorProviderRegistry _registry = SensorProviderRegistry(
    defaultProvider: _simulatedProvider,
  );
  late final PhysiologicalIngestionService _ingestionService =
      PhysiologicalIngestionService(
        registry: _registry,
        detectionService: CrisisDetectionService(
          engine: const CrisisRiskEngine(),
          repository: CrisisRiskEventRepository(),
        ),
      );

  PhysiologicalSample? _latestSample;
  CrisisRiskResult? _latestResult;

  @override
  Widget build(BuildContext context) {
    final provider = _registry.getCurrent();
    final latestSample = _latestSample;
    final latestResult = _latestResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Provider de sensores debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Origem atual: ${provider.type.name}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tela interna para testar ingestão de sinais fisiológicos simulados.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Cenário do simulador',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final scenario in CrisisSimulationScenario.values)
                ChoiceChip(
                  label: Text(scenario.name),
                  selected: _simulatedProvider.currentScenario == scenario,
                  onSelected: (_) => _setScenario(scenario),
                ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _processLatestSample,
            child: const Text('Processar latest sample'),
          ),
          if (latestSample != null) ...[
            const SizedBox(height: 16),
            _SampleCard(sample: latestSample),
          ],
          if (latestResult != null) ...[
            const SizedBox(height: 16),
            _ResultCard(result: latestResult),
          ],
        ],
      ),
    );
  }

  void _setScenario(CrisisSimulationScenario scenario) {
    setState(() {
      _simulatedProvider.setScenario(scenario);
      _latestSample = null;
      _latestResult = null;
    });
  }

  Future<void> _processLatestSample() async {
    final sample = await _simulatedProvider.getLatestSample();
    final result = await _ingestionService.processLatestSample(
      baseline: BaselineProfile.safeDefault(),
      cognitiveResponse: CognitiveCheckResponse.notAsked,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _latestSample = sample;
      _latestResult = result;
    });
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.sample});

  final PhysiologicalSample sample;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sample', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _DebugLine(label: 'FC', value: sample.heartRateBpm.toString()),
            _DebugLine(
              label: 'HRV',
              value: sample.hrvRmssdMs?.toString() ?? 'n/a',
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final CrisisRiskResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resultado', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _DebugLine(label: 'Score', value: result.score.toString()),
            _DebugLine(label: 'Level', value: result.level.name),
            const SizedBox(height: 8),
            Text('Reason codes', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            if (result.reasonCodes.isEmpty)
              const Text('Nenhum reasonCode.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final reason in result.reasonCodes)
                    Chip(
                      label: Text(reason),
                      backgroundColor: UiTokens.primary.withValues(alpha: 0.08),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DebugLine extends StatelessWidget {
  const _DebugLine({required this.label, required this.value});

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
