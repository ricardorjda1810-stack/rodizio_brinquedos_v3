import 'package:flutter/material.dart';

import '../../core/crisis_detection/crisis_sample_simulator.dart';
import '../../core/crisis_detection/simulated_sensor_provider.dart';
import '../../watch_session/watch_live_session.dart';
import '../../watch_session/watch_session_manager.dart';
import '../../watch_session/watch_session_models.dart';

class WatchLiveSessionDebugPage extends StatefulWidget {
  const WatchLiveSessionDebugPage({super.key});

  @override
  State<WatchLiveSessionDebugPage> createState() =>
      _WatchLiveSessionDebugPageState();
}

class _WatchLiveSessionDebugPageState extends State<WatchLiveSessionDebugPage> {
  final WatchSessionManager _manager = WatchSessionManager();
  final SimulatedSensorProvider _simulatedProvider = SimulatedSensorProvider(
    initialScenario: CrisisSimulationScenario.elevatedHeartRate,
  );

  WatchLiveSession get _session => _manager.currentSession;

  @override
  Widget build(BuildContext context) {
    final session = _session;

    return Scaffold(
      appBar: AppBar(title: const Text('Watch session debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Sessão fisiológica temporária para pesquisa autonômica.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _startSession,
                child: const Text('Iniciar sessão'),
              ),
              OutlinedButton(
                onPressed: _pauseSession,
                child: const Text('Pausar'),
              ),
              OutlinedButton(
                onPressed: _resumeSession,
                child: const Text('Resumir'),
              ),
              OutlinedButton(
                onPressed: _completeSession,
                child: const Text('Finalizar'),
              ),
              FilledButton.tonal(
                onPressed: _ingestFakeSample,
                child: const Text('Ingerir sample fake'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricRow(label: 'Estado atual', value: session.state.name),
          _MetricRow(
            label: 'Duração',
            value: '${session.duration().inSeconds}s',
          ),
          _MetricRow(
            label: 'Quantidade de amostras',
            value: '${session.sampleCount}',
          ),
          _MetricRow(
            label: 'FC mais recente',
            value: _formatNumber(session.lastHeartRate, suffix: 'bpm'),
          ),
          _MetricRow(
            label: 'HRV mais recente',
            value: _formatNumber(session.lastHrv, suffix: 'ms'),
          ),
          const SizedBox(height: 16),
          Text(
            'Esta tela usa dados simulados e não ativa coleta contínua.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _startSession() {
    setState(() {
      _manager.startSession(source: 'simulatedWatch');
    });
  }

  void _pauseSession() {
    setState(_manager.pauseSession);
  }

  void _resumeSession() {
    setState(_manager.resumeSession);
  }

  void _completeSession() {
    setState(_manager.completeSession);
  }

  Future<void> _ingestFakeSample() async {
    final sample = await _simulatedProvider.getLatestSample();
    if (sample == null) {
      return;
    }

    setState(() {
      _manager.ingestWatchSample(
        WatchSessionSample.fromPhysiologicalSample(sample),
      );
    });
  }

  String _formatNumber(double? value, {required String suffix}) {
    if (value == null) {
      return 'não disponível';
    }

    return '${value.toStringAsFixed(1)} $suffix';
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: $value'),
    );
  }
}
