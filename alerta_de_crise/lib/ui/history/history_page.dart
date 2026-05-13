import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/export/csv_exporter.dart';
import '../../domain/models/risk_event.dart';
import '../../domain/models/risk_state.dart';
import '../theme/ui_tokens.dart';

final class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final events = AppStateScope.of(context).events;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          TextButton(
            onPressed: () => _showCsvDialog(context, events),
            child: const Text('Exportar CSV'),
          ),
        ],
      ),
      body: events.isEmpty
          ? const Center(
              child: Text(
                'Nenhum evento registrado ainda.',
                style: TextStyle(color: UiTokens.textSoft),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(UiTokens.m),
              itemBuilder: (context, index) =>
                  _RiskEventCard(event: events[index]),
              separatorBuilder: (_, _) => const SizedBox(height: UiTokens.s),
              itemCount: events.length,
            ),
    );
  }

  void _showCsvDialog(BuildContext context, List<RiskEvent> events) {
    const exporter = CsvExporter();
    final csv = exporter.exportEvents(events);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exportar CSV'),
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

final class _RiskEventCard extends StatelessWidget {
  const _RiskEventCard({required this.event});

  final RiskEvent event;

  @override
  Widget build(BuildContext context) {
    final color = UiTokens.riskColor(event.state.key);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateTime(event.startedAt),
                        style: const TextStyle(color: UiTokens.textFaint),
                      ),
                      const SizedBox(height: UiTokens.xs),
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(UiTokens.radiusPill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiTokens.m,
                      vertical: UiTokens.s,
                    ),
                    child: Text(
                      event.state.label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UiTokens.s),
            Text(
              event.description,
              style: const TextStyle(color: UiTokens.textSoft, height: 1.35),
            ),
            const SizedBox(height: UiTokens.m),
            Wrap(
              spacing: UiTokens.s,
              runSpacing: UiTokens.s,
              children: [
                _MeasurePill(
                  label: 'Antes',
                  value: 'FC ${event.beforeHeartRate} / HRV ${event.beforeHrv}',
                ),
                _MeasurePill(label: 'Depois', value: _afterMeasureText(event)),
              ],
            ),
            const SizedBox(height: UiTokens.m),
            Text(
              'Feedback: ${event.feedback.isEmpty ? 'Pendente' : event.feedback}',
              style: const TextStyle(
                color: UiTokens.textSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
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

  static String _afterMeasureText(RiskEvent event) {
    final heartRate = event.afterHeartRate;
    final hrv = event.afterHrv;
    if (heartRate == null || hrv == null) {
      return 'Pendente';
    }

    return 'FC $heartRate / HRV $hrv';
  }
}

final class _MeasurePill extends StatelessWidget {
  const _MeasurePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: UiTokens.bg,
        borderRadius: BorderRadius.circular(UiTokens.radiusButton),
        border: Border.all(color: UiTokens.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiTokens.m,
          vertical: UiTokens.s,
        ),
        child: Text(
          '$label: $value',
          style: const TextStyle(color: UiTokens.textSoft),
        ),
      ),
    );
  }
}
