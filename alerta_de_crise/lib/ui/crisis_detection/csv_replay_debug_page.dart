import 'package:flutter/material.dart';

import '../../core/crisis_detection/crisis_detection_service.dart';
import '../../core/crisis_detection/crisis_risk_engine.dart';
import '../../data/crisis_detection/crisis_risk_event_repository.dart';
import '../../replay/csv_replay_parser.dart';
import '../../replay/csv_replay_session.dart';
import '../../replay/csv_replay_service.dart';

class CsvReplayDebugPage extends StatefulWidget {
  const CsvReplayDebugPage({super.key});

  @override
  State<CsvReplayDebugPage> createState() => _CsvReplayDebugPageState();
}

class _CsvReplayDebugPageState extends State<CsvReplayDebugPage> {
  final TextEditingController _controller = TextEditingController(
    text:
        'timestamp,heartRate,hrv,spo2,movement,respiratoryRate\n'
        '2026-05-16T10:00:00Z,72,45,98,0.10,16\n'
        '2026-05-16T10:00:05Z,88,30,98,0.12,20',
  );
  final CsvReplayParser _parser = const CsvReplayParser();
  final CsvReplayService _service = CsvReplayService(
    detectionService: CrisisDetectionService(
      engine: const CrisisRiskEngine(),
      repository: CrisisRiskEventRepository(persistSyncWrites: true),
    ),
  );

  CsvReplaySession? _session;
  int _validLines = 0;
  int _invalidLines = 0;
  String _statusMessage = 'Cole um CSV para executar replay local.';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    return Scaffold(
      appBar: AppBar(title: const Text('CSV replay debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Replay local para validar sinais de ativação fisiológica com dados históricos.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 8,
            maxLines: 12,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'CSV',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _runReplay,
            child: const Text('Executar replay'),
          ),
          const SizedBox(height: 12),
          Text(_statusMessage),
          const SizedBox(height: 12),
          _MetricRow(label: 'Linhas válidas', value: '$_validLines'),
          _MetricRow(label: 'Linhas inválidas', value: '$_invalidLines'),
          if (session != null) ...[
            const Divider(height: 32),
            _MetricRow(
              label: 'Total samples',
              value: '${session.totalSamples}',
            ),
            _MetricRow(
              label: 'Average score',
              value: session.averageScore.toStringAsFixed(1),
            ),
            _MetricRow(
              label: 'Highest score',
              value: '${session.highestScore}',
            ),
            _MetricRow(
              label: 'High intervention count',
              value: '${session.highInterventionCount}',
            ),
            _MetricRow(
              label: 'FC média',
              value: session.statistics.averageHeartRate.toStringAsFixed(1),
            ),
            _MetricRow(
              label: 'HRV média',
              value:
                  session.statistics.averageHrv?.toStringAsFixed(1) ??
                  'não disponível',
            ),
          ],
        ],
      ),
    );
  }

  void _runReplay() {
    final parsed = _parser.parseCsv(_controller.text);
    final session = _service.runReplay(samples: parsed.samples);

    setState(() {
      _session = session;
      _validLines = parsed.validLineCount;
      _invalidLines = parsed.invalidLineCount;
      _statusMessage = parsed.samples.isEmpty
          ? 'Nenhuma amostra válida encontrada.'
          : 'Replay executado localmente.';
    });
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
