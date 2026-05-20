import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/crisis_detection/baseline_profile.dart';
import '../../core/crisis_detection/simulated_sensor_provider.dart';
import '../../realtime_streaming/physiological_stream_buffer.dart';
import '../../realtime_streaming/realtime_ingestion_controller.dart';
import '../../realtime_streaming/realtime_pipeline_service.dart';
import '../../realtime_streaming/realtime_stream_models.dart';

class RealtimeStreamingDebugPage extends StatefulWidget {
  const RealtimeStreamingDebugPage({super.key});

  @override
  State<RealtimeStreamingDebugPage> createState() =>
      _RealtimeStreamingDebugPageState();
}

class _RealtimeStreamingDebugPageState
    extends State<RealtimeStreamingDebugPage> {
  late final PhysiologicalStreamBuffer _buffer = PhysiologicalStreamBuffer(
    maxSize: 120,
  );
  late final RealtimeIngestionController _controller =
      RealtimeIngestionController(
        provider: SimulatedSensorProvider(),
        buffer: _buffer,
        pipelineService: RealtimePipelineService(),
        frequency: const Duration(seconds: 2),
        baseline: const BaselineProfile(
          restingHeartRateBpm: 68,
          hrvRmssdMs: 42,
          respiratoryRate: 15,
          movementIntensity: 0.12,
        ),
      );

  Timer? _uiTimer;

  RealtimePipelineSnapshot? get _snapshot => _controller.latestSnapshot;

  @override
  void dispose() {
    _uiTimer?.cancel();
    _controller.stopStreaming();
    super.dispose();
  }

  Future<void> _start() async {
    await _controller.startStreaming();
    _startUiTimer();
    setState(() {});
  }

  void _pause() {
    _controller.pauseStreaming();
    setState(() {});
  }

  Future<void> _resume() async {
    await _controller.resumeStreaming();
    _startUiTimer();
    setState(() {});
  }

  void _stop() {
    _controller.stopStreaming();
    _uiTimer?.cancel();
    setState(() {});
  }

  void _startUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return Scaffold(
      appBar: AppBar(title: const Text('Realtime Streaming')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Streaming experimental para pesquisa/autoconhecimento. Não é '
            'monitoramento médico contínuo; o pipeline usa ingestão controlada, '
            'buffers temporais e processamento incremental.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: _start, child: const Text('Iniciar')),
              OutlinedButton(onPressed: _pause, child: const Text('Pausar')),
              OutlinedButton(onPressed: _resume, child: const Text('Retomar')),
              OutlinedButton(onPressed: _stop, child: const Text('Parar')),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pipeline',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('State: ${_controller.state.name}'),
                  Text('Buffer size: ${_buffer.samples.length}'),
                  Text(
                    'Rolling HR: ${snapshot?.rollingHeartRate.toStringAsFixed(1) ?? '--'}',
                  ),
                  Text(
                    'Rolling HRV: ${snapshot?.rollingHrv.toStringAsFixed(1) ?? '--'}',
                  ),
                  Text(
                    'Rolling confidence: ${snapshot?.rollingConfidence.toStringAsFixed(1) ?? '--'}',
                  ),
                  Text(
                    'Rolling escalation: ${snapshot?.rollingEscalationDensity.toStringAsFixed(1) ?? '--'}',
                  ),
                  Text(
                    'Latest forecast: ${snapshot?.latestEscalationProbability.toStringAsFixed(1) ?? '--'}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Samples', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final sample in _buffer.samples.reversed.take(8))
            Card(
              child: ListTile(
                title: Text('HR ${sample.heartRateBpm.toStringAsFixed(1)}'),
                subtitle: Text(
                  'HRV ${sample.hrvRmssdMs?.toStringAsFixed(1) ?? '--'} | '
                  'movement ${sample.movementIntensity.toStringAsFixed(2)}',
                ),
                trailing: Text(
                  '${sample.timestamp.hour.toString().padLeft(2, '0')}:'
                  '${sample.timestamp.minute.toString().padLeft(2, '0')}:'
                  '${sample.timestamp.second.toString().padLeft(2, '0')}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
