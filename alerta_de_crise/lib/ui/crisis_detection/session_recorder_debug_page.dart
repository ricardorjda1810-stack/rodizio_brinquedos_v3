import 'package:flutter/material.dart';

import '../../session_recorder/session_recording_service.dart';
import '../../session_recorder/session_recorder_models.dart';
import '../../session_recorder/session_snapshot_models.dart';

class SessionRecorderDebugPage extends StatefulWidget {
  const SessionRecorderDebugPage({super.key});

  @override
  State<SessionRecorderDebugPage> createState() =>
      _SessionRecorderDebugPageState();
}

class _SessionRecorderDebugPageState extends State<SessionRecorderDebugPage> {
  final SessionRecordingService _service = SessionRecordingService();
  RecordingSessionState? _state;
  Map<String, Object?>? _export;

  Future<void> _start() async {
    final state = await _service.createRecording(
      protocolId: 'debug-protocol',
      persist: false,
    );
    setState(() {
      _state = state;
      _export = null;
    });
  }

  void _recordSnapshot() {
    final state = _service.recordSnapshot(
      SessionSnapshot(
        timestamp: DateTime.now(),
        heartRate: 76 + ((_state?.snapshots.length ?? 0) * 2),
        hrv: 42,
        confidence: 86,
        escalationLevel: (_state?.snapshots.length ?? 0) > 1
            ? 'moderate'
            : 'low',
        forecastProbability: 28,
        recoveryState: 'recovering',
        resilience: 72,
        contextualState: 'contexto experimental',
        multimodalConsensus: 'consenso experimental',
      ),
      forecasts: 1,
    );
    setState(() => _state = state);
  }

  void _pause() {
    setState(() => _state = _service.pauseRecording());
  }

  void _resume() {
    setState(() => _state = _service.resumeRecording());
  }

  Future<void> _stop() async {
    final state = await _service.finalizeRecording(persist: false);
    setState(() => _state = state);
  }

  void _exportDataset() {
    final state = _state;
    if (state == null) return;
    setState(() => _export = _service.buildReplayDataset(state));
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final session = state?.session;

    return Scaffold(
      appBar: AppBar(title: const Text('Session Recorder')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'registro experimental; dataset fisiológico; não representa monitoramento clínico.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: _start, child: const Text('Start')),
              OutlinedButton(
                onPressed: state?.state == RecordingState.recording
                    ? _recordSnapshot
                    : null,
                child: const Text('Record snapshot'),
              ),
              OutlinedButton(
                onPressed: state?.state == RecordingState.recording
                    ? _pause
                    : null,
                child: const Text('Pause'),
              ),
              OutlinedButton(
                onPressed: state?.state == RecordingState.paused
                    ? _resume
                    : null,
                child: const Text('Resume'),
              ),
              FilledButton.tonal(
                onPressed: state?.isActive == true ? _stop : null,
                child: const Text('Stop'),
              ),
              OutlinedButton(
                onPressed: state == null ? null : _exportDataset,
                child: const Text('Export replay dataset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricTile(
            title: 'Duration',
            value: '${session?.duration.inSeconds ?? 0}s',
            subtitle: 'sessão experimental',
          ),
          _MetricTile(
            title: 'Snapshots',
            value: '${state?.snapshots.length ?? 0}',
            subtitle: 'coleta fisiológica',
          ),
          _MetricTile(
            title: 'Forecasts',
            value: '${session?.totalForecasts ?? 0}',
            subtitle: 'registro experimental',
          ),
          _MetricTile(
            title: 'Markers',
            value: '${session?.totalMarkers ?? 0}',
            subtitle: state?.markers.join(', ') ?? 'sem gravação',
          ),
          _MetricTile(
            title: 'Average confidence',
            value: session?.averageConfidence.toStringAsFixed(0) ?? '0',
            subtitle: 'dataset reproduzível',
          ),
          _MetricTile(
            title: 'Replay export',
            value: _export == null ? '-' : 'ready',
            subtitle: 'replay experimental',
          ),
          if (_export != null)
            Card(
              child: ListTile(
                title: const Text('Session summary'),
                subtitle: Text('${_export?['summary']}'),
              ),
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
