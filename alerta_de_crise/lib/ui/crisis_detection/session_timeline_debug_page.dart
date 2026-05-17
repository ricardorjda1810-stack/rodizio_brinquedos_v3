import 'package:flutter/material.dart';

import '../../core/crisis_detection/physiological_sample.dart';
import '../../session_timeline/physiological_event_marker.dart';
import '../../session_timeline/session_timeline_models.dart';
import '../../session_timeline/session_timeline_service.dart';
import '../../session_timeline/session_timeline_statistics.dart';

class SessionTimelineDebugPage extends StatefulWidget {
  const SessionTimelineDebugPage({super.key});

  @override
  State<SessionTimelineDebugPage> createState() =>
      _SessionTimelineDebugPageState();
}

class _SessionTimelineDebugPageState extends State<SessionTimelineDebugPage> {
  final _service = SessionTimelineService();
  SessionTimeline? _timeline;
  SessionTimelineStatistics? _statistics;
  List<PhysiologicalEventMarker> _markers = const [];

  Future<void> _startTimeline() async {
    final timeline = await _service.startTimeline();
    final now = timeline.startedAt;
    await _service.addSample(
      PhysiologicalSample(
        timestamp: now,
        heartRateBpm: 72,
        hrvRmssdMs: 45,
        movementIntensity: 0.12,
      ),
    );
    _refresh(timeline);
  }

  Future<void> _addFakeMarker() async {
    if (_timeline == null) {
      await _startTimeline();
    }
    final timestamp = DateTime.now();
    await _service.addSample(
      PhysiologicalSample(
        timestamp: timestamp,
        heartRateBpm: 92,
        hrvRmssdMs: 32,
        movementIntensity: 0.18,
      ),
    );
    await _service.addMarker(
      PhysiologicalEventMarker(
        id: 'manual-${timestamp.microsecondsSinceEpoch}',
        timestamp: timestamp,
        type: EventType.elevatedHeartRate,
        title: 'Sinal de ativação',
        description: 'Evento fake para validar a timeline temporal.',
        severity: Severity.medium,
        source: 'debug',
      ),
    );
    _refresh(_service.currentTimeline);
  }

  Future<void> _addManualMarker() async {
    if (_timeline == null) {
      await _startTimeline();
    }
    final timestamp = DateTime.now();
    await _service.addMarker(
      PhysiologicalEventMarker(
        id: 'manual-note-${timestamp.microsecondsSinceEpoch}',
        timestamp: timestamp,
        type: EventType.manualMarker,
        title: 'Marcador manual',
        description: 'Observação contextual adicionada no debug.',
        severity: Severity.low,
        source: 'debug',
      ),
    );
    _refresh(_service.currentTimeline);
  }

  Future<void> _completeTimeline() async {
    final timeline = await _service.completeTimeline();
    _refresh(timeline);
  }

  void _refresh(SessionTimeline? timeline) {
    setState(() {
      _timeline = timeline;
      _statistics = _service.getTimelineStatistics();
      _markers = _service.markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeline = _timeline;
    final statistics = _statistics;

    return Scaffold(
      appBar: AppBar(title: const Text('Session Timeline')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Timeline experimental para pesquisa/autoconhecimento. '
            'Não substitui avaliação médica.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _startTimeline,
                child: const Text('Iniciar timeline'),
              ),
              OutlinedButton(
                onPressed: _addFakeMarker,
                child: const Text('Adicionar ativação fake'),
              ),
              OutlinedButton(
                onPressed: _addManualMarker,
                child: const Text('Adicionar marcador manual'),
              ),
              OutlinedButton(
                onPressed: timeline?.isActive == true
                    ? _completeTimeline
                    : null,
                child: const Text('Finalizar'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MetricTile(
            label: 'Estado',
            value: timeline == null
                ? 'sem timeline'
                : timeline.isActive
                ? 'ativa'
                : 'finalizada',
          ),
          _MetricTile(
            label: 'Samples',
            value: '${timeline?.totalSamples ?? 0}',
          ),
          _MetricTile(label: 'Eventos', value: '${timeline?.totalEvents ?? 0}'),
          _MetricTile(
            label: 'Duração',
            value: '${statistics?.durationSeconds ?? 0}s',
          ),
          _MetricTile(
            label: 'Activation density',
            value: (statistics?.activationDensity ?? 0).toStringAsFixed(2),
          ),
          const SizedBox(height: 16),
          Text('Eventos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_markers.isEmpty)
            const Text('Nenhum evento marcado ainda.')
          else
            ..._markers.map(
              (marker) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(marker.title),
                subtitle: Text(
                  '${marker.timestamp.toIso8601String()}\n'
                  '${marker.type.name} • ${marker.severity.name}',
                ),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      trailing: Text(value),
    );
  }
}
