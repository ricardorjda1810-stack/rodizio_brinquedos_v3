import 'package:flutter/material.dart';

import '../../core/crisis_detection/physiological_sample.dart';
import '../../physiological_trends/escalation_detection_service.dart';
import '../../physiological_trends/physiological_trend_models.dart';
import '../../physiological_trends/physiological_trend_service.dart';
import '../../physiological_trends/trend_window.dart';
import '../../session_timeline/physiological_event_marker.dart';

class PhysiologicalTrendDebugPage extends StatefulWidget {
  const PhysiologicalTrendDebugPage({super.key});

  @override
  State<PhysiologicalTrendDebugPage> createState() =>
      _PhysiologicalTrendDebugPageState();
}

class _PhysiologicalTrendDebugPageState
    extends State<PhysiologicalTrendDebugPage> {
  final _trendService = const PhysiologicalTrendService();
  final _escalationService = const EscalationDetectionService();
  PhysiologicalTrend? _trend;
  EscalationDetectionResult? _detection;

  Future<void> _simulateEscalation() async {
    final now = DateTime.now();
    final samples = List.generate(8, (index) {
      return PhysiologicalSample(
        timestamp: now.subtract(Duration(minutes: 7 - index)),
        heartRateBpm: 72 + (index * 4),
        hrvRmssdMs: 48 - (index * 3),
        movementIntensity: 0.18,
      );
    });
    final markers = [
      PhysiologicalEventMarker(
        id: 'debug-activation-1',
        timestamp: now.subtract(const Duration(minutes: 3)),
        type: EventType.elevatedHeartRate,
        title: 'FC acima do padrão',
        description: 'Marcador simulado de ativação.',
        severity: Severity.medium,
        source: 'debug',
      ),
      PhysiologicalEventMarker(
        id: 'debug-hrv-1',
        timestamp: now.subtract(const Duration(minutes: 1)),
        type: EventType.hrvDrop,
        title: 'HRV abaixo do padrão',
        description: 'Marcador simulado de HRV.',
        severity: Severity.medium,
        source: 'debug',
      ),
    ];
    final trend = await _trendService.analyzeRecentSamples(
      samples: samples,
      markers: markers,
      window: TrendWindow.shortTerm,
      timelineId: 'trend-debug',
    );
    setState(() {
      _trend = trend;
      _detection = _escalationService.detectEscalation(
        trend: trend,
        timelineId: 'trend-debug',
      );
    });
  }

  void _simulateStable() {
    final now = DateTime.now();
    final samples = List.generate(8, (index) {
      return PhysiologicalSample(
        timestamp: now.subtract(Duration(minutes: 7 - index)),
        heartRateBpm: 72 + (index.isEven ? 1 : 0),
        hrvRmssdMs: 44 + (index.isEven ? 1 : 0),
        movementIntensity: 0.12,
      );
    });
    final trend = _trendService.calculateTrend(
      samples: samples,
      window: TrendWindow.shortTerm,
    );
    setState(() {
      _trend = trend;
      _detection = _escalationService.detectEscalation(
        trend: trend,
        timelineId: 'trend-debug',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final trend = _trend;
    final detection = _detection;

    return Scaffold(
      appBar: AppBar(title: const Text('Physiological Trends')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Análise experimental de tendências fisiológicas para '
            'pesquisa/autoconhecimento. Não é diagnóstico médico.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _simulateEscalation,
                child: const Text('Simular escalada gradual'),
              ),
              OutlinedButton(
                onPressed: _simulateStable,
                child: const Text('Simular estável'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MetricTile(
            label: 'HR slope',
            value: trend?.heartRateSlope.toStringAsFixed(2) ?? '-',
          ),
          _MetricTile(
            label: 'HRV slope',
            value: trend?.hrvSlope.toStringAsFixed(2) ?? '-',
          ),
          _MetricTile(
            label: 'Escalation score',
            value: '${trend?.escalationScore ?? '-'}',
          ),
          _MetricTile(
            label: 'Escalation level',
            value: detection?.level.name ?? '-',
          ),
          _MetricTile(
            label: 'Activation density',
            value: trend?.activationDensity.toStringAsFixed(2) ?? '-',
          ),
          if (detection != null) ...[
            const SizedBox(height: 16),
            Text('Markers', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (detection.markers.isEmpty)
              const Text('Nenhum marker gerado.')
            else
              ...detection.markers.map(
                (marker) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(marker.title),
                  subtitle: Text('${marker.type.name} • ${marker.source}'),
                ),
              ),
          ],
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
