import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

class WeeklyPlanningPage extends StatelessWidget {
  final SettingsRepository settingsRepository;
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const WeeklyPlanningPage({
    super.key,
    required this.settingsRepository,
    required this.weeklyPlanningRepository,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: UiTokens.bg,
      appBar: AppBar(
        title: const Text('Planejamento semanal'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(UiTokens.m),
          children: [
            AppSurfaceCard(
              color: UiTokens.primarySoft,
              padding: const EdgeInsets.all(UiTokens.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planejamento semanal',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: UiTokens.spacingSm),
                  Text(
                    'Escolha quando a rodada usa as categorias padr\u00e3o e quando cada dia precisa de quantidades pr\u00f3prias por categoria.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UiTokens.spacingMd),
            _FeatureSwitchCard(settingsRepository: settingsRepository),
            const SizedBox(height: UiTokens.spacingMd),
            _DefaultSummaryCard(
              weeklyPlanningRepository: weeklyPlanningRepository,
            ),
            const SizedBox(height: UiTokens.spacingMd),
            _WeekDaysCard(
              weeklyPlanningRepository: weeklyPlanningRepository,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureSwitchCard extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const _FeatureSwitchCard({required this.settingsRepository});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: StreamBuilder<bool>(
        stream: settingsRepository.watchWeeklyPlanningEnabled(),
        initialData: settingsRepository.weeklyPlanningEnabled,
        builder: (context, snapshot) {
          final enabled = snapshot.data ?? false;

          return SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Usar planejamento semanal'),
            subtitle: const Text(
              'Quando desligado, a rodada usa a configura\u00e7\u00e3o padr\u00e3o de categorias.',
            ),
            value: enabled,
            onChanged: settingsRepository.setWeeklyPlanningEnabled,
          );
        },
      ),
    );
  }
}

class _DefaultSummaryCard extends StatelessWidget {
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const _DefaultSummaryCard({required this.weeklyPlanningRepository});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: StreamBuilder<List<WeeklyPlanningCategoryConfig>>(
        stream: weeklyPlanningRepository.watchDefaultCategoryConfig(),
        initialData: const <WeeklyPlanningCategoryConfig>[],
        builder: (context, snapshot) {
          final categories =
              snapshot.data ?? const <WeeklyPlanningCategoryConfig>[];
          final total = _totalFor(categories);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configura\u00e7\u00e3o padr\u00e3o',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              Text(
                'Total padr\u00e3o: $total brinquedos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
              ),
              const SizedBox(height: UiTokens.spacingSm),
              Text(
                _categorySummary(categories),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: UiTokens.textSecondary,
                      height: 1.35,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WeekDaysCard extends StatelessWidget {
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const _WeekDaysCard({required this.weeklyPlanningRepository});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: StreamBuilder<List<WeeklyPlanningDayConfig>>(
        stream: weeklyPlanningRepository.watchAll(),
        initialData: const <WeeklyPlanningDayConfig>[],
        builder: (context, snapshot) {
          final configs = _configsByWeekday(
            snapshot.data ?? const <WeeklyPlanningDayConfig>[],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dias da semana',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              Text(
                'Ajuste apenas os dias que precisam fugir do padr\u00e3o.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
              ),
              const SizedBox(height: UiTokens.spacingMd),
              for (var weekday = DateTime.monday;
                  weekday <= DateTime.sunday;
                  weekday++) ...[
                _WeekdayTile(
                  config: configs[weekday] ??
                      WeeklyPlanningDayConfig(
                        weekday: weekday,
                        useDefault: true,
                        categories: const <WeeklyPlanningCategoryConfig>[],
                      ),
                  onUseDefaultChanged: (value) =>
                      weeklyPlanningRepository.setUseDefault(
                    weekday: weekday,
                    useDefault: value,
                  ),
                  onCategoryChanged:
                      weeklyPlanningRepository.updateCategoryConfig,
                ),
                if (weekday != DateTime.sunday)
                  const SizedBox(height: UiTokens.spacingSm),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WeekdayTile extends StatelessWidget {
  final WeeklyPlanningDayConfig config;
  final Future<void> Function(bool value) onUseDefaultChanged;
  final Future<void> Function({
    required int weekday,
    required String categoryId,
    required bool isIncluded,
    required int quota,
  }) onCategoryChanged;

  const _WeekdayTile({
    required this.config,
    required this.onUseDefaultChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final total = config.total;

    return Container(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(UiTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _weekdayName(config.weekday),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Switch(
                value: config.useDefault,
                onChanged: onUseDefaultChanged,
              ),
            ],
          ),
          Text(
            'Usar padr\u00e3o',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: UiTokens.textSecondary,
                ),
          ),
          const SizedBox(height: UiTokens.spacingXs),
          Text(
            config.useDefault
                ? 'Usando configura\u00e7\u00e3o padr\u00e3o'
                : 'Configura\u00e7\u00e3o pr\u00f3pria por categoria',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: UiTokens.textSecondary,
                ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          Text(
            'Total do dia: $total brinquedos',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (!config.useDefault) ...[
            const SizedBox(height: UiTokens.spacingMd),
            for (final category in config.categories) ...[
              _CategoryRow(
                weekday: config.weekday,
                category: category,
                onChanged: onCategoryChanged,
              ),
              const SizedBox(height: UiTokens.spacingSm),
            ],
          ] else ...[
            const SizedBox(height: UiTokens.spacingSm),
            Text(
              _categorySummary(config.categories),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: UiTokens.textSecondary,
                    height: 1.35,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final int weekday;
  final WeeklyPlanningCategoryConfig category;
  final Future<void> Function({
    required int weekday,
    required String categoryId,
    required bool isIncluded,
    required int quota,
  }) onChanged;

  const _CategoryRow({
    required this.weekday,
    required this.category,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            category.categoryName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(width: UiTokens.spacingSm),
        _QuantityStepper(
          value: category.safeQuota,
          enabled: category.isIncluded,
          onChanged: (value) => onChanged(
            weekday: weekday,
            categoryId: category.categoryId,
            isIncluded: category.isIncluded,
            quota: value,
          ),
        ),
        const SizedBox(width: UiTokens.spacingSm),
        Switch(
          value: category.isIncluded,
          onChanged: (value) => onChanged(
            weekday: weekday,
            categoryId: category.categoryId,
            isIncluded: value,
            quota: category.safeQuota,
          ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int value;
  final bool enabled;
  final Future<void> Function(int value) onChanged;

  const _QuantityStepper({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = _clampQuantity(value);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: 'Diminuir',
          onPressed: !enabled || safeValue <= 0
              ? null
              : () => onChanged(safeValue - 1),
          icon: const Icon(Icons.remove),
        ),
        const SizedBox(width: UiTokens.spacingXs),
        SizedBox(
          width: 64,
          child: TextFormField(
            key: ValueKey('${enabled}_$safeValue'),
            enabled: enabled,
            initialValue: '$safeValue',
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Qtd.',
            ),
            onChanged: (raw) {
              final parsed = int.tryParse(raw);
              if (parsed == null) return;
              final next = _clampQuantity(parsed);
              if (next != safeValue) {
                onChanged(next);
              }
            },
          ),
        ),
        const SizedBox(width: UiTokens.spacingXs),
        IconButton.filledTonal(
          tooltip: 'Aumentar',
          onPressed: !enabled || safeValue >= 15
              ? null
              : () => onChanged(safeValue + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

Map<int, WeeklyPlanningDayConfig> _configsByWeekday(
  List<WeeklyPlanningDayConfig> configs,
) {
  return {
    for (final config in configs)
      if (config.weekday >= DateTime.monday &&
          config.weekday <= DateTime.sunday)
        config.weekday: config,
  };
}

int _totalFor(List<WeeklyPlanningCategoryConfig> categories) {
  var total = 0;
  for (final category in categories) {
    if (category.isIncluded) total += category.safeQuota;
  }
  return total;
}

int _clampQuantity(int value) => value.clamp(0, 15).toInt();

String _categorySummary(List<WeeklyPlanningCategoryConfig> categories) {
  final included = categories
      .where((category) => category.isIncluded && category.safeQuota > 0)
      .map((category) => '${category.categoryName} ${category.safeQuota}')
      .toList(growable: false);
  if (included.isEmpty) return 'Nenhuma categoria inclu\u00edda.';
  return included.join(' \u00b7 ');
}

String _weekdayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Segunda-feira';
    case DateTime.tuesday:
      return 'Ter\u00e7a-feira';
    case DateTime.wednesday:
      return 'Quarta-feira';
    case DateTime.thursday:
      return 'Quinta-feira';
    case DateTime.friday:
      return 'Sexta-feira';
    case DateTime.saturday:
      return 'S\u00e1bado';
    case DateTime.sunday:
      return 'Domingo';
    default:
      return 'Dia';
  }
}
