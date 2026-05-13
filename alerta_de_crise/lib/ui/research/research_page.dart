import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/export/csv_exporter.dart';
import '../../domain/models/research_session.dart';
import '../../domain/models/risk_state.dart';
import '../../domain/models/session_sample.dart';
import '../theme/ui_tokens.dart';

final class ResearchPage extends StatelessWidget {
  const ResearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final session = appState.currentResearchSession;
    final lastSample = session?.samples.lastOrNull;
    final lastEndedSession = appState.lastResearchSession;

    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa')),
      body: ListView(
        padding: const EdgeInsets.all(UiTokens.m),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(UiTokens.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.hasActiveResearchSession
                        ? 'Sessão ativa'
                        : 'Sem sessão ativa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  Text(
                    'Amostras coletadas: ${session?.samples.length ?? 0}',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                  if (session != null) ...[
                    const SizedBox(height: UiTokens.s),
                    Text(
                      'Início: ${_formatDateTime(session.startedAt)}',
                      style: const TextStyle(color: UiTokens.textSoft),
                    ),
                  ],
                  const SizedBox(height: UiTokens.m),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: appState.hasActiveResearchSession
                              ? null
                              : appState.startResearchSession,
                          child: const Text('Iniciar sessão'),
                        ),
                      ),
                      const SizedBox(width: UiTokens.s),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: appState.hasActiveResearchSession
                              ? appState.endResearchSession
                              : null,
                          child: const Text('Encerrar sessão'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UiTokens.s),
                  OutlinedButton(
                    onPressed: appState.isSimulationRunning
                        ? appState.stopSimulation
                        : appState.startSimulation,
                    child: Text(
                      appState.isSimulationRunning
                          ? 'Parar simulação'
                          : 'Iniciar simulação',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: UiTokens.m),
          _LastSampleCard(sample: lastSample),
          const SizedBox(height: UiTokens.m),
          _EndedSessionsCard(session: lastEndedSession),
          const SizedBox(height: UiTokens.m),
          OutlinedButton(
            onPressed: session == null
                ? null
                : () => _showSessionCsv(context, session),
            child: const Text('Exportar CSV da sessão'),
          ),
          const SizedBox(height: UiTokens.s),
          OutlinedButton(
            onPressed: lastEndedSession == null
                ? null
                : () => _showSessionCsv(context, lastEndedSession),
            child: const Text('Exportar CSV da última sessão encerrada'),
          ),
        ],
      ),
    );
  }

  void _showSessionCsv(BuildContext context, ResearchSession session) {
    const exporter = CsvExporter();
    final csv = exporter.exportSessionSamples(session.samples);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('CSV da sessão'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                csv,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: UiTokens.textSoft,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    final day = twoDigits(dateTime.day);
    final month = twoDigits(dateTime.month);
    final hour = twoDigits(dateTime.hour);
    final minute = twoDigits(dateTime.minute);

    return '$day/$month/${dateTime.year} $hour:$minute';
  }
}

final class _EndedSessionsCard extends StatelessWidget {
  const _EndedSessionsCard({required this.session});

  final ResearchSession? session;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final session = this.session;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sessões encerradas: ${appState.researchSessions.length}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.s),
            if (session == null)
              const Text(
                'Nenhuma sessão encerrada ainda.',
                style: TextStyle(color: UiTokens.textSoft),
              )
            else ...[
              Text(
                'Última sessão encerrada',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: UiTokens.textFaint),
              ),
              const SizedBox(height: UiTokens.xs),
              Text(
                'Amostras: ${session.samples.length}',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _LastSampleCard extends StatelessWidget {
  const _LastSampleCard({required this.sample});

  final SessionSample? sample;

  @override
  Widget build(BuildContext context) {
    final sample = this.sample;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: sample == null
            ? const Text(
                'Nenhuma amostra coletada ainda.',
                style: TextStyle(color: UiTokens.textSoft),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última amostra',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  Text(
                    'FC ${sample.heartRate} bpm • HRV ${sample.hrv} ms',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                  const SizedBox(height: UiTokens.xs),
                  Text(
                    'Score ${sample.riskScore}/100 • ${sample.riskState.label}',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                  const SizedBox(height: UiTokens.xs),
                  Text(
                    'Movimento: ${sample.motionState}',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                ],
              ),
      ),
    );
  }
}
