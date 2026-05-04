import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/domain/weekly_planning/week_day_summary.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

class WeeklyPlanningPreviewCard extends StatelessWidget {
  final List<WeekDaySummary> summaries;
  final VoidCallback? onTap;

  const WeeklyPlanningPreviewCard({
    super.key,
    required this.summaries,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sortedSummaries = [...summaries]
      ..sort((a, b) => a.weekday.compareTo(b.weekday));
    final todaySummary = _todaySummary(sortedSummaries);

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(UiTokens.spacingSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(UiTokens.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiTokens.spacingXs,
                    vertical: UiTokens.spacingXs,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Planejamento semanal',
                              style: textTheme.titleSmall?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Brinquedos programados por dia',
                              style: textTheme.bodySmall?.copyWith(
                                color: UiTokens.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(width: UiTokens.spacingSm),
                        const Icon(
                          Icons.chevron_right,
                          color: UiTokens.textSecondary,
                          size: 22,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              if (sortedSummaries.isEmpty)
                Text(
                  'Nenhum planejamento encontrado.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: UiTokens.textSecondary,
                  ),
                )
              else ...[
                _TodayPlanningSummary(summary: todaySummary),
                const SizedBox(height: UiTokens.spacingSm),
                _WeekSummaryStrip(summaries: sortedSummaries),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekSummaryStrip extends StatelessWidget {
  final List<WeekDaySummary> summaries;

  const _WeekSummaryStrip({
    required this.summaries,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: summaries
          .map((summary) =>
              '${summary.fullLabel}: ${summary.totalToys} brinquedos')
          .join(', '),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(
          horizontal: UiTokens.spacingXs,
          vertical: UiTokens.spacingXs,
        ),
        decoration: BoxDecoration(
          color: UiTokens.secondarySoft,
          borderRadius: BorderRadius.circular(UiTokens.radiusSm),
          border: Border.all(color: UiTokens.border),
        ),
        child: Row(
          children: [
            for (var index = 0; index < summaries.length; index++) ...[
              if (index > 0) const SizedBox(width: UiTokens.spacingXs),
              Expanded(
                child: _WeekSummaryCell(summary: summaries[index]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeekSummaryCell extends StatelessWidget {
  final WeekDaySummary summary;

  const _WeekSummaryCell({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dayColor =
        summary.isToday ? UiTokens.primaryStrong : UiTokens.textSecondary;
    final numberColor =
        summary.isToday ? UiTokens.primaryStrong : UiTokens.textPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            summary.shortLabel,
            maxLines: 1,
            style: textTheme.labelMedium?.copyWith(
              color: dayColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: UiTokens.spacingXs),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: Text(
            '${summary.totalToys}',
            key: ValueKey<int>(summary.totalToys),
            maxLines: 1,
            style: textTheme.titleMedium?.copyWith(
              color: numberColor,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayPlanningSummary extends StatelessWidget {
  final WeekDaySummary summary;

  const _TodayPlanningSummary({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: UiTokens.spacingSm,
        vertical: UiTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: UiTokens.primarySoft,
        borderRadius: BorderRadius.circular(UiTokens.radiusMd),
        border:
            Border.all(color: UiTokens.primaryStrong.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: UiTokens.spacingXs,
              runSpacing: 2,
              children: [
                Text(
                  'HOJE',
                  style: UiTokens.textMicro.copyWith(
                    color: UiTokens.primaryStrong,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '·',
                  style: textTheme.bodySmall?.copyWith(
                    color: UiTokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Text(
                    _formatToyCount(summary.totalToys),
                    key: ValueKey<int>(summary.totalToys),
                    style: textTheme.bodyMedium?.copyWith(
                      color: UiTokens.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '·',
                  style: textTheme.bodySmall?.copyWith(
                    color: UiTokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _planningMoodLabel(summary.totalToys),
                  style: textTheme.bodySmall?.copyWith(
                    color: UiTokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: UiTokens.spacingSm),
        ],
      ),
    );
  }
}

WeekDaySummary _todaySummary(List<WeekDaySummary> summaries) {
  final today = DateTime.now().weekday;
  for (final summary in summaries) {
    if (summary.isToday) return summary;
  }
  for (final summary in summaries) {
    if (summary.weekday == today) return summary;
  }
  return summaries.first;
}

String _planningMoodLabel(int total) {
  if (total <= 0) return 'Nenhum brinquedo planejado';
  if (total <= 4) return 'Dia leve';
  if (total <= 8) return 'Dia equilibrado';
  return 'Dia cheio';
}

String _formatToyCount(int total) {
  return total == 1 ? '1 brinquedo' : '$total brinquedos';
}
