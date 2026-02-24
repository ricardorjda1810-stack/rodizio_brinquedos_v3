import 'package:flutter/material.dart';

enum RoundSummaryStatus {
  none,
  active,
  done,
}

class RoundSummaryModel {
  final RoundSummaryStatus status;
  final String statusText;
  final String periodText;
  final String summaryText;
  final String ctaLabel;
  final VoidCallback onOpen;

  const RoundSummaryModel({
    required this.status,
    required this.statusText,
    required this.periodText,
    required this.summaryText,
    required this.ctaLabel,
    required this.onOpen,
  });
}

class RoundSummaryCard extends StatelessWidget {
  final RoundSummaryModel model;

  const RoundSummaryCard({
    super.key,
    required this.model,
  });

  IconData _iconForStatus(RoundSummaryStatus s) {
    switch (s) {
      case RoundSummaryStatus.none:
        return Icons.info_outline;
      case RoundSummaryStatus.active:
        return Icons.play_circle_outline;
      case RoundSummaryStatus.done:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconForStatus(model.status)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Rodada: ${model.statusText}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (model.periodText.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      model.periodText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    model.summaryText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: model.onOpen,
                      child: Text(model.ctaLabel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
