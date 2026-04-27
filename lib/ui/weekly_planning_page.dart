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
                    'Defina uma quantidade base para a rodada e ajuste apenas os dias que pedem outro ritmo.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UiTokens.spacingMd),
            _FeatureSwitchCard(
              settingsRepository: settingsRepository,
            ),
            const SizedBox(height: UiTokens.spacingMd),
            _DefaultSizeCard(settingsRepository: settingsRepository),
            const SizedBox(height: UiTokens.spacingMd),
            _WeekDaysCard(
              settingsRepository: settingsRepository,
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

  const _FeatureSwitchCard({
    required this.settingsRepository,
  });

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
              'Quando desligado, todas as rodadas usam a quantidade padr\u00e3o.',
            ),
            value: enabled,
            onChanged: (value) async =>
                settingsRepository.setWeeklyPlanningEnabled(value),
          );
        },
      ),
    );
  }
}

class _DefaultSizeCard extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const _DefaultSizeCard({required this.settingsRepository});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: StreamBuilder<int>(
        stream: settingsRepository.watchRoundSize(),
        initialData: settingsRepository.roundSize,
        builder: (context, snapshot) {
          final value =
              _clampSize(snapshot.data ?? settingsRepository.roundSize);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quantidade padr\u00e3o',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              Text(
                'Usada nos dias marcados como "Usar padr\u00e3o".',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
              ),
              const SizedBox(height: UiTokens.spacingMd),
              _QuantityStepper(
                value: value,
                onChanged: (next) => settingsRepository.setRoundSize(next),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WeekDaysCard extends StatelessWidget {
  final SettingsRepository settingsRepository;
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const _WeekDaysCard({
    required this.settingsRepository,
    required this.weeklyPlanningRepository,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: StreamBuilder<int>(
        stream: settingsRepository.watchRoundSize(),
        initialData: settingsRepository.roundSize,
        builder: (context, sizeSnapshot) {
          final defaultSize =
              _clampSize(sizeSnapshot.data ?? settingsRepository.roundSize);

          return StreamBuilder<List<WeeklyPlanningDayConfig>>(
            stream: weeklyPlanningRepository.watchAll(),
            initialData: const <WeeklyPlanningDayConfig>[],
            builder: (context, snapshot) {
              final configs = _configsByWeekday(
                  snapshot.data ?? const <WeeklyPlanningDayConfig>[]);

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
                    'Ajuste somente os dias que fogem do padr\u00e3o.',
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
                            customSize: null,
                          ),
                      defaultSize: defaultSize,
                      onChanged: weeklyPlanningRepository.updateDayConfig,
                    ),
                    if (weekday != DateTime.sunday)
                      const SizedBox(height: UiTokens.spacingSm),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _WeekdayTile extends StatelessWidget {
  final WeeklyPlanningDayConfig config;
  final int defaultSize;
  final Future<void> Function({
    required int weekday,
    required bool useDefault,
    required int? customSize,
  }) onChanged;

  const _WeekdayTile({
    required this.config,
    required this.defaultSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final customSize = config.hasValidCustomSize
        ? config.customSize!
        : _clampSize(defaultSize);

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
                onChanged: (value) {
                  onChanged(
                    weekday: config.weekday,
                    useDefault: value,
                    customSize: value ? null : customSize,
                  );
                },
              ),
            ],
          ),
          Text(
            'Usar padr\u00e3o',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: UiTokens.textSecondary,
                ),
          ),
          if (!config.useDefault) ...[
            const SizedBox(height: UiTokens.spacingMd),
            _QuantityStepper(
              value: customSize,
              onChanged: (value) => onChanged(
                weekday: config.weekday,
                useDefault: false,
                customSize: value,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int value;
  final Future<void> Function(int value) onChanged;

  const _QuantityStepper({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = _clampSize(value);

    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Diminuir',
          onPressed: safeValue <= 1 ? null : () => onChanged(safeValue - 1),
          icon: const Icon(Icons.remove),
        ),
        const SizedBox(width: UiTokens.spacingSm),
        SizedBox(
          width: 76,
          child: TextFormField(
            key: ValueKey(safeValue),
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
              final next = _clampSize(parsed);
              if (next != safeValue) {
                onChanged(next);
              }
            },
          ),
        ),
        const SizedBox(width: UiTokens.spacingSm),
        IconButton.filledTonal(
          tooltip: 'Aumentar',
          onPressed: safeValue >= 15 ? null : () => onChanged(safeValue + 1),
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

int _clampSize(int value) => value.clamp(1, 15).toInt();

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
