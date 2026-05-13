import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/export/csv_exporter.dart';
import '../../domain/models/calibration_feedback.dart';
import '../../domain/models/feeling_level.dart';
import '../../domain/models/risk_state.dart';
import '../theme/ui_tokens.dart';

final class CalibrationPage extends StatelessWidget {
  const CalibrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final lastFeedback = appState.lastCalibrationFeedback;

    return Scaffold(
      appBar: AppBar(title: const Text('Calibragem')),
      body: ListView(
        padding: const EdgeInsets.all(UiTokens.m),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(UiTokens.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Como você está se sentindo agora?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  const Text(
                    'Esse registro ajuda a relacionar sinais simulados com sua percepção subjetiva.',
                    style: TextStyle(color: UiTokens.textSoft, height: 1.35),
                  ),
                  const SizedBox(height: UiTokens.m),
                  for (final feelingLevel in FeelingLevel.values) ...[
                    FilledButton(
                      onPressed: () =>
                          appState.addCalibrationFeedback(feelingLevel),
                      child: Text(feelingLevel.label),
                    ),
                    const SizedBox(height: UiTokens.s),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: UiTokens.m),
          _LastFeedbackCard(feedback: lastFeedback),
          const SizedBox(height: UiTokens.m),
          OutlinedButton(
            onPressed: appState.calibrationFeedbacks.isEmpty
                ? null
                : () => _showFeedbackCsv(context, appState),
            child: const Text('Exportar CSV de feedbacks'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackCsv(BuildContext context, AppState appState) {
    const exporter = CsvExporter();
    final csv = exporter.exportCalibrationFeedbacks(
      appState.calibrationFeedbacks,
    );

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('CSV de feedbacks'),
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
}

final class _LastFeedbackCard extends StatelessWidget {
  const _LastFeedbackCard({required this.feedback});

  final CalibrationFeedback? feedback;

  @override
  Widget build(BuildContext context) {
    final feedback = this.feedback;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: feedback == null
            ? const Text(
                'Nenhuma percepção subjetiva registrada ainda.',
                style: TextStyle(color: UiTokens.textSoft),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última percepção subjetiva registrada',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  Text(
                    feedback.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: UiTokens.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  Text(
                    'FC ${feedback.heartRate} bpm • HRV ${feedback.hrv} ms',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                  const SizedBox(height: UiTokens.xs),
                  Text(
                    'Score ${feedback.riskScore}/100 • ${feedback.riskState.label}',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                ],
              ),
      ),
    );
  }
}
