import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

class WeeklyPlanningCard extends StatelessWidget {
  final bool enabled;
  final List<WeeklyPlanningDayConfig> days;
  final VoidCallback onEdit;

  const WeeklyPlanningCard({
    super.key,
    required this.enabled,
    required this.days,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusColor =
        enabled ? UiTokens.primaryStrong : UiTokens.textSecondary;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Planejamento semanal',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
              ),
            ],
          ),
          const SizedBox(height: UiTokens.spacingXs),
          Row(
            children: [
              Icon(
                enabled
                    ? Icons.check_circle_outline
                    : Icons.pause_circle_outline,
                size: 18,
                color: statusColor,
              ),
              const SizedBox(width: UiTokens.spacingXs),
              Text(
                enabled ? 'Ativado' : 'Desativado',
                style: textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: UiTokens.spacingSm),
          Text(
            _summaryText(days),
            style: textTheme.bodyMedium?.copyWith(
              color: UiTokens.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

String _summaryText(List<WeeklyPlanningDayConfig> days) {
  final byWeekday = {
    for (final day in days)
      if (day.weekday >= DateTime.monday && day.weekday <= DateTime.sunday)
        day.weekday: day,
  };

  return List.generate(DateTime.daysPerWeek, (index) {
    final weekday = DateTime.monday + index;
    final config = byWeekday[weekday];
    final value =
        config == null || config.useDefault || !config.hasValidCustomSize
            ? 'P'
            : '${config.customSize}';
    return '${_weekdayLabel(weekday)} $value';
  }).join(' \u00b7 ');
}

String _weekdayLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Seg';
    case DateTime.tuesday:
      return 'Ter';
    case DateTime.wednesday:
      return 'Qua';
    case DateTime.thursday:
      return 'Qui';
    case DateTime.friday:
      return 'Sex';
    case DateTime.saturday:
      return 'Sab';
    case DateTime.sunday:
      return 'Dom';
    default:
      return '';
  }
}
