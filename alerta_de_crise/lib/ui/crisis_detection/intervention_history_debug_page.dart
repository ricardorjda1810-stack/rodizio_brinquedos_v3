import 'package:flutter/material.dart';

import '../../data/crisis_detection/intervention_history_entry.dart';
import '../../data/crisis_detection/intervention_history_repository.dart';

class InterventionHistoryDebugPage extends StatelessWidget {
  const InterventionHistoryDebugPage({required this.repository, super.key});

  final InterventionHistoryRepository repository;

  @override
  Widget build(BuildContext context) {
    final entries = repository.listRecent();

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de protocolos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Registro longitudinal debug',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Acompanha resultados de pausas guiadas sem realizar diagnóstico.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const Text('Nenhum protocolo registrado nesta sessão debug.')
          else
            for (final entry in entries) ...[
              _HistoryEntryCard(entry: entry),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _HistoryEntryCard extends StatelessWidget {
  const _HistoryEntryCard({required this.entry});

  final InterventionHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.completedAt.toIso8601String(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _HistoryLine(label: 'Duração', value: '${entry.durationSeconds}s'),
            _HistoryLine(
              label: 'Melhora percebida',
              value: entry.userReportedImprovement ? 'sim' : 'não',
            ),
            _HistoryLine(
              label: 'Resposta final',
              value: entry.finalResponse.name,
            ),
            _HistoryLine(
              label: 'Score pré',
              value: entry.preInterventionScore?.toString() ?? 'n/a',
            ),
            _HistoryLine(
              label: 'Score pós',
              value: entry.postInterventionScore?.toString() ?? 'n/a',
            ),
            _HistoryLine(
              label: 'Delta',
              value: entry.scoreDelta?.toString() ?? 'n/a',
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryLine extends StatelessWidget {
  const _HistoryLine({required this.label, required this.value});

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
