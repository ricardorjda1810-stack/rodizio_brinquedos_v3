import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/domain/weekly_planning/week_day_summary.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

class WeeklyPlanningPreviewCard extends StatelessWidget {
  final List<WeekDaySummary> summaries;
  final VoidCallback? onTap;
  final ValueChanged<int>? onDayTap;

  const WeeklyPlanningPreviewCard({
    super.key,
    required this.summaries,
    this.onTap,
    this.onDayTap,
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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UiTokens.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(UiTokens.spacingMd),
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
                            'Planejamento semanal',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: UiTokens.spacingXs),
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
                const SizedBox(height: UiTokens.spacingMd),
                if (sortedSummaries.isEmpty)
                  Text(
                    'Nenhum planejamento encontrado.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
                  )
                else ...[
                  _TodayPlanningSummary(summary: todaySummary),
                  const SizedBox(height: UiTokens.spacingMd),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 380;
                      return Row(
                        children: [
                          for (final summary in sortedSummaries)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: summary == sortedSummaries.last
                                      ? 0
                                      : UiTokens.spacingXs,
                                ),
                                child: _WeekDayMiniCard(
                                  summary: summary,
                                  compact: compact,
                                  onTap: onDayTap == null
                                      ? onTap
                                      : () => onDayTap!(summary.weekday),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
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
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      decoration: BoxDecoration(
        color: UiTokens.primarySoft,
        borderRadius: BorderRadius.circular(UiTokens.radiusLg),
        border:
            Border.all(color: UiTokens.primaryStrong.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOJE',
                  style: UiTokens.textMicro.copyWith(
                    color: UiTokens.primaryStrong,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: UiTokens.spacingXs),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Text(
                    _formatToyCount(summary.totalToys),
                    key: ValueKey<int>(summary.totalToys),
                    style: textTheme.headlineSmall?.copyWith(
                      color: UiTokens.textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: UiTokens.spacingXs),
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
          const SizedBox(width: UiTokens.spacingMd),
          _PlanningModeDot(usesDefault: summary.usesDefault, large: true),
        ],
      ),
    );
  }
}

class _WeekDayMiniCard extends StatelessWidget {
  final WeekDaySummary summary;
  final bool compact;
  final VoidCallback? onTap;

  const _WeekDayMiniCard({
    required this.summary,
    required this.compact,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final background =
        summary.isToday ? UiTokens.primarySoft : UiTokens.secondarySoft;
    final borderColor =
        summary.isToday ? UiTokens.primaryStrong : UiTokens.border;
    final numberStyle =
        (compact ? textTheme.titleMedium : textTheme.titleLarge)?.copyWith(
      color: summary.isToday ? UiTokens.primaryStrong : UiTokens.textPrimary,
      fontWeight: FontWeight.w800,
      height: 1,
    );

    return Semantics(
      button: onTap != null,
      label:
          '${summary.fullLabel}: ${summary.totalToys} brinquedos programados',
      selected: summary.isToday,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiTokens.radiusSm),
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? UiTokens.spacingXs : UiTokens.spacingSm,
            vertical: UiTokens.spacingSm,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(UiTokens.radiusSm),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      summary.shortLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: summary.isToday
                            ? UiTokens.primaryStrong
                            : UiTokens.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: UiTokens.spacingXs),
                  _PlanningModeDot(usesDefault: summary.usesDefault),
                ],
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
                  style: numberStyle,
                ),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'brinquedos',
                  maxLines: 1,
                  style: textTheme.labelSmall?.copyWith(
                    color: UiTokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanningModeDot extends StatelessWidget {
  final bool usesDefault;
  final bool large;

  const _PlanningModeDot({
    required this.usesDefault,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = large ? 12.0 : 7.0;
    return Tooltip(
      message: usesDefault ? 'Configuração padrão' : 'Configuração própria',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: usesDefault ? UiTokens.border : UiTokens.primaryStrong,
          shape: BoxShape.circle,
        ),
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
