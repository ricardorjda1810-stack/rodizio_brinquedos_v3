import 'package:flutter/material.dart';

import '../../core/crisis_detection/baseline_builder.dart';
import '../../core/crisis_detection/baseline_profile.dart';
import '../../core/crisis_detection/crisis_detection_service.dart';
import '../../core/crisis_detection/crisis_risk_engine.dart';
import '../../core/crisis_detection/crisis_risk_result.dart';
import '../../core/crisis_detection/crisis_sample_simulator.dart';
import '../../data/crisis_detection/crisis_risk_event.dart';
import '../../data/crisis_detection/crisis_risk_event_repository.dart';
import '../theme/ui_tokens.dart';

class CrisisRiskDebugPage extends StatefulWidget {
  const CrisisRiskDebugPage({super.key});

  @override
  State<CrisisRiskDebugPage> createState() => _CrisisRiskDebugPageState();
}

class _CrisisRiskDebugPageState extends State<CrisisRiskDebugPage> {
  final CrisisSampleSimulator _simulator = const CrisisSampleSimulator();
  final BaselineBuilder _baselineBuilder = const BaselineBuilder();
  final CrisisRiskEventRepository _repository = CrisisRiskEventRepository();
  late final CrisisDetectionService _service = CrisisDetectionService(
    engine: const CrisisRiskEngine(),
    repository: _repository,
  );
  late CrisisSimulationCase _selectedCase = _simulator.scenarios.first;
  late CrisisRiskResult _result = _evaluateAndRecord(_selectedCase);
  BaselineProfile? _simulatedBaseline;

  @override
  Widget build(BuildContext context) {
    final scenarios = _simulator.scenarios;
    final simulatedBaseline = _simulatedBaseline;

    return Scaffold(
      appBar: AppBar(title: const Text('Debug de ativação fisiológica')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Cenários simulados',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Ferramenta interna para testar sinais de ativação acima do padrão. Não realiza diagnóstico.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final scenario in scenarios) ...[
            _ScenarioTile(
              simulationCase: scenario,
              isSelected: scenario.scenario == _selectedCase.scenario,
              onTap: () => _selectScenario(scenario),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _calculateSimulatedBaseline,
            child: const Text('Calcular baseline simulado'),
          ),
          if (simulatedBaseline != null) ...[
            const SizedBox(height: 12),
            _BaselineCard(baseline: simulatedBaseline),
          ],
          const SizedBox(height: 16),
          _ResultCard(result: _result),
          const SizedBox(height: 16),
          _RecentEventsCard(events: _repository.listRecent()),
        ],
      ),
    );
  }

  void _selectScenario(CrisisSimulationCase simulationCase) {
    setState(() {
      _selectedCase = simulationCase;
      _result = _evaluateAndRecord(simulationCase);
    });
  }

  CrisisRiskResult _evaluateAndRecord(CrisisSimulationCase simulationCase) {
    return _service.evaluateAndRecord(
      sample: simulationCase.sample,
      baseline: simulationCase.baseline,
      cognitiveResponse: simulationCase.cognitiveResponse,
      source: 'simulator:${simulationCase.scenario.name}',
    );
  }

  void _calculateSimulatedBaseline() {
    setState(() {
      _simulatedBaseline = _baselineBuilder.build(
        _simulator.scenarios.map((scenario) => scenario.sample).toList(),
      );
    });
  }
}

class _ScenarioTile extends StatelessWidget {
  const _ScenarioTile({
    required this.simulationCase,
    required this.isSelected,
    required this.onTap,
  });

  final CrisisSimulationCase simulationCase;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        selected: isSelected,
        title: Text(simulationCase.title),
        subtitle: Text(simulationCase.description),
        trailing: isSelected ? const Icon(Icons.check_circle) : null,
        onTap: onTap,
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
            const SizedBox(height: 12),
            _DebugLine(label: 'Score', value: result.score.toString()),
            _DebugLine(label: 'Level', value: result.level.name),
            _DebugLine(
              label: 'Pergunta cognitiva',
              value: result.shouldAskCognitiveCheck ? 'true' : 'false',
            ),
            const SizedBox(height: 12),
            Text(
              'Ação sugerida',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(result.recommendedAction),
            const SizedBox(height: 12),
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

class _BaselineCard extends StatelessWidget {
  const _BaselineCard({required this.baseline});

  final BaselineProfile baseline;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Baseline simulado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _DebugLine(
              label: 'FC repouso',
              value: baseline.restingHeartRateBpm.toStringAsFixed(1),
            ),
            _DebugLine(
              label: 'HRV RMSSD',
              value: baseline.hrvRmssdMs.toStringAsFixed(1),
            ),
            _DebugLine(
              label: 'Respiração',
              value: baseline.respiratoryRate.toStringAsFixed(1),
            ),
            _DebugLine(
              label: 'Movimento',
              value: baseline.movementIntensity.toStringAsFixed(2),
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

class _RecentEventsCard extends StatelessWidget {
  const _RecentEventsCard({required this.events});

  final List<CrisisRiskEvent> events;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eventos recentes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              const Text('Nenhum evento salvo nesta sessão debug.')
            else
              for (final event in events.take(5)) ...[
                _DebugLine(
                  label: '${event.source} · ${event.level.name}',
                  value: event.score.toString(),
                ),
                if (event.reasonCodes.isNotEmpty)
                  Text(
                    event.reasonCodes.join(', '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}
