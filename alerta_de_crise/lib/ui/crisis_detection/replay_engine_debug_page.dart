import 'package:flutter/material.dart';

import '../../replay_engine/advanced_replay_service.dart';
import '../../replay_engine/replay_engine_models.dart';
import '../../replay_engine/replay_validation_service.dart';
import '../../replay_engine/synthetic_scenario_generator.dart';

class ReplayEngineDebugPage extends StatefulWidget {
  const ReplayEngineDebugPage({super.key});

  @override
  State<ReplayEngineDebugPage> createState() => _ReplayEngineDebugPageState();
}

class _ReplayEngineDebugPageState extends State<ReplayEngineDebugPage> {
  final SyntheticScenarioGenerator _generator =
      const SyntheticScenarioGenerator();
  final AdvancedReplayService _replayService = AdvancedReplayService();
  final ReplayValidationService _validationService = ReplayValidationService();
  ReplayScenarioType _scenarioType = ReplayScenarioType.escalating;
  SyntheticReplayDataset? _dataset;
  ReplaySession? _session;
  ReplayValidationResult? _validation;
  double _speed = 1;

  @override
  void initState() {
    super.initState();
    _generateScenario();
  }

  void _generateScenario() {
    final dataset = _generator.generateSyntheticScenario(type: _scenarioType);
    setState(() {
      _dataset = dataset;
      _session = null;
      _validation = null;
    });
  }

  Future<void> _startReplay() async {
    final dataset = _dataset;
    if (dataset == null) return;
    final session = await _replayService.startReplay(
      dataset: dataset,
      playbackSpeed: _speed,
      persistScenario: true,
    );
    setState(() => _session = session);
  }

  void _pauseReplay() {
    setState(() => _session = _replayService.pauseReplay());
  }

  void _resumeReplay() {
    setState(() => _session = _replayService.resumeReplay());
  }

  void _stopReplay() {
    setState(() => _session = _replayService.stopReplay());
  }

  void _stepForward() {
    setState(() => _session = _replayService.stepForward());
  }

  void _stepBackward() {
    setState(() => _session = _replayService.stepBackward());
  }

  Future<void> _validateReplay() async {
    final dataset = _dataset;
    if (dataset == null) return;
    final result = _validationService.validateReplay(dataset);
    await _validationService.persistValidationResult(result);
    setState(() => _validation = result);
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final state = session?.timelineState;
    final sample = state?.sample;
    final forecast = state?.forecast;

    return Scaffold(
      appBar: AppBar(title: const Text('Replay Engine')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'simulação experimental; cenário sintético; não representa evento real.',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ReplayScenarioType>(
            initialValue: _scenarioType,
            decoration: const InputDecoration(labelText: 'Synthetic scenario'),
            items: ReplayScenarioType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.name)),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _scenarioType = value);
              _generateScenario();
            },
          ),
          const SizedBox(height: 12),
          Text('Speed ${_speed.toStringAsFixed(2)}x'),
          Slider(
            value: _speed,
            min: 0.25,
            max: 4,
            divisions: 15,
            label: '${_speed.toStringAsFixed(2)}x',
            onChanged: (value) => setState(() => _speed = value),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _generateScenario,
                child: const Text('Generate scenario'),
              ),
              FilledButton(
                onPressed: _startReplay,
                child: const Text('Start replay'),
              ),
              OutlinedButton(
                onPressed: session == null ? null : _pauseReplay,
                child: const Text('Pause'),
              ),
              OutlinedButton(
                onPressed: session == null ? null : _resumeReplay,
                child: const Text('Resume'),
              ),
              OutlinedButton(
                onPressed: session == null ? null : _stopReplay,
                child: const Text('Stop'),
              ),
              OutlinedButton(
                onPressed: session == null ? null : _stepBackward,
                child: const Text('Back'),
              ),
              OutlinedButton(
                onPressed: session == null ? null : _stepForward,
                child: const Text('Forward'),
              ),
              FilledButton.tonal(
                onPressed: _validateReplay,
                child: const Text('Validate offline'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricTile(
            title: 'Replay fisiológico',
            value: session?.state.name ?? 'stopped',
            subtitle: _dataset?.scenario.title ?? 'No scenario',
          ),
          _MetricTile(
            title: 'Timeline',
            value: state == null
                ? '0%'
                : '${(state.progress * 100).toStringAsFixed(0)}%',
            subtitle: state?.timestamp.toIso8601String() ?? '-',
          ),
          _MetricTile(
            title: 'HR / HRV',
            value: sample == null
                ? '-'
                : '${sample.heartRateBpm.toStringAsFixed(0)} / ${(sample.hrvRmssdMs ?? 0).toStringAsFixed(0)}',
            subtitle: 'rolling sync para validação offline',
          ),
          _MetricTile(
            title: 'Forecast',
            value: forecast == null
                ? '-'
                : '${forecast.escalationProbability.toStringAsFixed(0)}%',
            subtitle: forecast?.escalationRiskLevel.name ?? 'sem forecast',
          ),
          _MetricTile(
            title: 'Markers / Context',
            value:
                '${state?.markers.length ?? 0} / ${state?.contextualEvents.length ?? 0}',
            subtitle: 'cenários sintéticos sincronizados',
          ),
          _MetricTile(
            title: 'Validation',
            value: _validation == null
                ? '-'
                : _validation!.replayConsistency.toStringAsFixed(0),
            subtitle:
                _validation?.findings.join(', ') ?? 'modelagem experimental',
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
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
      ),
    );
  }
}
