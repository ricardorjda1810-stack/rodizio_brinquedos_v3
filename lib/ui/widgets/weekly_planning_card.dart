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
    final today = _todayConfig(days);
    final todayTotal = today?.total ?? 0;
    final todayMode = !enabled
        ? 'Planejamento semanal desativado'
        : today?.useDefault ?? true
            ? 'Hoje: usando configura\u00e7\u00e3o padr\u00e3o'
            : 'Hoje: configura\u00e7\u00e3o pr\u00f3pria';

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
                enabled ? 'Planejamento semanal ativo' : 'Desativado',
                style: textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: UiTokens.spacingSm),
          Text(
            todayMode,
            style: textTheme.bodyMedium?.copyWith(
              color: UiTokens.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: UiTokens.spacingXs),
          Text(
            'Total de hoje: $todayTotal brinquedos',
            style: textTheme.bodyMedium?.copyWith(
              color: UiTokens.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

WeeklyPlanningDayConfig? _todayConfig(List<WeeklyPlanningDayConfig> days) {
  final weekday = DateTime.now().weekday;
  for (final day in days) {
    if (day.weekday == weekday) return day;
  }
  return null;
}
