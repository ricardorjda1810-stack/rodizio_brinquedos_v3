import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/crisis_detection/cognitive_check_response.dart';
import '../../core/crisis_detection/crisis_risk_result.dart';
import '../../data/crisis_detection/crisis_risk_event.dart';
import '../../data/crisis_detection/intervention_history_entry.dart';
import '../../replay/csv_replay_session.dart';
import '../../replay/csv_replay_statistics.dart';
import '../../research_export/research_export_models.dart';
import '../../research_export/research_export_service.dart';

class ResearchExportDebugPage extends StatefulWidget {
  const ResearchExportDebugPage({super.key});

  @override
  State<ResearchExportDebugPage> createState() =>
      _ResearchExportDebugPageState();
}

class _ResearchExportDebugPageState extends State<ResearchExportDebugPage> {
  final ResearchExportService _service = const ResearchExportService();
  ResearchExportBundle? _bundle;
  String _statusMessage = 'Gere um export local com dados fake.';

  @override
  Widget build(BuildContext context) {
    final bundle = _bundle;
    final statistics = bundle?.statistics;
    final preview = bundle?.fullCsv ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Research export debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Export local para análise externa de dados fisiológicos e de recuperação.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _generateFakeExport,
                child: const Text('Gerar export fake'),
              ),
              OutlinedButton(
                onPressed: preview.isEmpty ? null : _copyCsv,
                child: const Text('Copiar CSV'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_statusMessage),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Total eventos',
            value: '${bundle?.totalEvents ?? 0}',
          ),
          _MetricRow(
            label: 'Total intervenções',
            value: '${bundle?.totalInterventions ?? 0}',
          ),
          _MetricRow(
            label: 'Média de score',
            value: (statistics?.averageScore ?? 0).toStringAsFixed(1),
          ),
          _MetricRow(
            label: 'Taxa de melhora',
            value:
                '${((statistics?.perceivedImprovementRate ?? 0) * 100).toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 12),
          Text('Preview CSV', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(preview.isEmpty ? 'Nenhum CSV gerado.' : preview),
        ],
      ),
    );
  }

  void _generateFakeExport() {
    final bundle = _service.generateResearchBundle(
      crisisEvents: _fakeEvents(),
      interventions: _fakeInterventions(),
      replaySessions: [_fakeReplaySession()],
    );

    setState(() {
      _bundle = bundle;
      _statusMessage = 'Export local gerado.';
    });
  }

  Future<void> _copyCsv() async {
    final csv = _bundle?.csvContents[ResearchExportType.fullBundle];
    if (csv == null || csv.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: csv));
    setState(() {
      _statusMessage = 'CSV copiado para a área de transferência.';
    });
  }

  List<CrisisRiskEvent> _fakeEvents() {
    return [
      CrisisRiskEvent(
        id: 'risk-1',
        timestamp: DateTime(2026, 5, 16, 10),
        score: 42,
        level: CrisisRiskLevel.mildAttention,
        reasonCodes: const ['heart_rate_above_baseline_without_movement'],
        recommendedAction: 'Observar por mais alguns instantes.',
        cognitiveResponse: CognitiveCheckResponse.notAsked,
        source: 'debug',
      ),
      CrisisRiskEvent(
        id: 'risk-2',
        timestamp: DateTime(2026, 5, 16, 10, 5),
        score: 74,
        level: CrisisRiskLevel.highIntervention,
        reasonCodes: const ['user_requests_help'],
        recommendedAction:
            'Iniciar protocolo de respiração guiada e oferecer ajuda.',
        cognitiveResponse: CognitiveCheckResponse.needsHelp,
        source: 'debug',
      ),
    ];
  }

  List<InterventionHistoryEntry> _fakeInterventions() {
    return [
      InterventionHistoryEntry(
        id: 'intervention-1',
        protocolId: 'standard',
        startedAt: DateTime(2026, 5, 16, 10, 6),
        completedAt: DateTime(2026, 5, 16, 10, 11),
        durationSeconds: 300,
        completed: true,
        userReportedImprovement: true,
        finalResponse: CognitiveCheckResponse.feelingOk,
        preInterventionScore: 74,
        postInterventionScore: 40,
        scoreDelta: -34,
      ),
    ];
  }

  CsvReplaySession _fakeReplaySession() {
    return CsvReplaySession(
      id: 'replay-1',
      createdAt: DateTime(2026, 5, 16, 11),
      totalSamples: 2,
      processedSamples: 2,
      startedAt: DateTime(2026, 5, 16, 10),
      completedAt: DateTime(2026, 5, 16, 10, 1),
      averageScore: 28,
      highestScore: 46,
      highInterventionCount: 0,
      statistics: const CsvReplayStatistics(
        averageScore: 28,
        highestScore: 46,
        mildAttentionCount: 1,
        moderateAlertCount: 0,
        highInterventionCount: 0,
        averageHeartRate: 82,
        averageHrv: 37,
      ),
    );
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
