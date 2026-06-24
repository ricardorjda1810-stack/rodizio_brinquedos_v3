import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/round/category_distribution_suggestion.dart';
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
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    if (isTablet) {
      return _WeeklyPlanningIpadEditor(
        settingsRepository: settingsRepository,
        weeklyPlanningRepository: weeklyPlanningRepository,
      );
    }

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
              color: UiTokens.actionOrangeSoft,
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

class _WeeklyPlanningIpadEditor extends StatelessWidget {
  final SettingsRepository settingsRepository;
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const _WeeklyPlanningIpadEditor({
    required this.settingsRepository,
    required this.weeklyPlanningRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _PlanningEditorPalette.bg,
      body: SafeArea(
        child: StreamBuilder<bool>(
          stream: settingsRepository.watchWeeklyPlanningEnabled(),
          initialData: settingsRepository.weeklyPlanningEnabled,
          builder: (context, enabledSnapshot) {
            final planningEnabled = enabledSnapshot.data ?? false;

            return StreamBuilder<List<WeeklyPlanningCategoryConfig>>(
              stream: weeklyPlanningRepository.watchDefaultCategoryConfig(),
              initialData: const <WeeklyPlanningCategoryConfig>[],
              builder: (context, defaultSnapshot) {
                final defaultCategories = defaultSnapshot.data ??
                    const <WeeklyPlanningCategoryConfig>[];

                return StreamBuilder<List<WeeklyPlanningDayConfig>>(
                  stream: weeklyPlanningRepository.watchAll(),
                  initialData: const <WeeklyPlanningDayConfig>[],
                  builder: (context, daysSnapshot) {
                    final dayConfigs =
                        daysSnapshot.data ?? const <WeeklyPlanningDayConfig>[];

                    return _WeeklyPlanningIpadDashboard(
                      planningEnabled: planningEnabled,
                      defaultCategories: defaultCategories,
                      dayConfigs: dayConfigs,
                      settingsRepository: settingsRepository,
                      weeklyPlanningRepository: weeklyPlanningRepository,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _WeeklyPlanningIpadDashboard extends StatelessWidget {
  final bool planningEnabled;
  final List<WeeklyPlanningCategoryConfig> defaultCategories;
  final List<WeeklyPlanningDayConfig> dayConfigs;
  final SettingsRepository settingsRepository;
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const _WeeklyPlanningIpadDashboard({
    required this.planningEnabled,
    required this.defaultCategories,
    required this.dayConfigs,
    required this.settingsRepository,
    required this.weeklyPlanningRepository,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 980 ? 32.0 : 24.0;
        final dashboardHeight =
            (constraints.maxHeight - 190).clamp(760.0, 1040.0).toDouble();

        return ListView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            22,
            horizontalPadding,
            40,
          ),
          physics: const BouncingScrollPhysics(),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1032),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PlanningEditorIpadHeader(
                      planningEnabled: planningEnabled,
                      onBack: () => Navigator.of(context).maybePop(),
                      onRestore: () async {
                        await weeklyPlanningRepository.restoreDefaultWeek();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Planejamento restaurado.'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: dashboardHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _PlanningEditorIpadMainColumn(
                              planningEnabled: planningEnabled,
                              defaultCategories: defaultCategories,
                              dayConfigs: dayConfigs,
                              settingsRepository: settingsRepository,
                              weeklyPlanningRepository:
                                  weeklyPlanningRepository,
                            ),
                          ),
                          const SizedBox(width: 18),
                          SizedBox(
                            width: 338,
                            child: _PlanningEditorIpadSideColumn(
                              planningEnabled: planningEnabled,
                              defaultCategories: defaultCategories,
                              dayConfigs: dayConfigs,
                              settingsRepository: settingsRepository,
                              weeklyPlanningRepository:
                                  weeklyPlanningRepository,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlanningEditorIpadHeader extends StatelessWidget {
  final bool planningEnabled;
  final VoidCallback onBack;
  final Future<void> Function() onRestore;

  const _PlanningEditorIpadHeader({
    required this.planningEnabled,
    required this.onBack,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return _PlanningEditorSurface(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      child: Row(
        children: [
          const _PlanningEditorHeaderIcon(),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RODÍZIO DE BRINQUEDOS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _PlanningEditorPalette.orange,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Planejamento semanal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textTitle.copyWith(
                    color: _PlanningEditorPalette.text,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Defina como a rodada distribui os brinquedos ao longo da semana.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _PlanningEditorPalette.textMid,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          _PlanningEditorStatusPill(enabled: planningEnabled),
          const SizedBox(width: 12),
          _PlanningEditorHeaderButton(
            label: 'Restaurar',
            icon: Icons.restore_rounded,
            primary: false,
            onTap: () => onRestore(),
          ),
          const SizedBox(width: 10),
          _PlanningEditorHeaderButton(
            label: 'Voltar',
            icon: Icons.arrow_back_rounded,
            primary: true,
            onTap: onBack,
          ),
        ],
      ),
    );
  }
}

class _PlanningEditorHeaderIcon extends StatelessWidget {
  const _PlanningEditorHeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _PlanningEditorPalette.orange,
            Color(0xFFFBBF24),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33F97316),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.calendar_month_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class _PlanningEditorHeaderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _PlanningEditorHeaderButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: primary
          ? FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: _PlanningEditorPalette.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                textStyle: UiTokens.textButton.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: _PlanningEditorPalette.orange,
                backgroundColor: _PlanningEditorPalette.orangeLight,
                side: const BorderSide(
                  color: _PlanningEditorPalette.orangeBorder,
                  width: 1.4,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: UiTokens.textButton.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
    );
  }
}

class _PlanningEditorStatusPill extends StatelessWidget {
  final bool enabled;

  const _PlanningEditorStatusPill({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: enabled
            ? _PlanningEditorPalette.orangeLight
            : const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: enabled
              ? _PlanningEditorPalette.orangeBorder
              : _PlanningEditorPalette.border,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_circle_rounded : Icons.pause_circle_outline,
            size: 16,
            color: enabled
                ? _PlanningEditorPalette.orange
                : _PlanningEditorPalette.textMuted,
          ),
          const SizedBox(width: 7),
          Text(
            enabled ? 'Ativo' : 'Desativado',
            style: UiTokens.textMicro.copyWith(
              color: enabled
                  ? _PlanningEditorPalette.orange
                  : _PlanningEditorPalette.textMid,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanningEditorIpadMainColumn extends StatelessWidget {
  final bool planningEnabled;
  final List<WeeklyPlanningCategoryConfig> defaultCategories;
  final List<WeeklyPlanningDayConfig> dayConfigs;
  final SettingsRepository settingsRepository;
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const _PlanningEditorIpadMainColumn({
    required this.planningEnabled,
    required this.defaultCategories,
    required this.dayConfigs,
    required this.settingsRepository,
    required this.weeklyPlanningRepository,
  });

  @override
  Widget build(BuildContext context) {
    final configs = _configsByWeekday(dayConfigs);

    return _PlanningEditorSurface(
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        physics: const BouncingScrollPhysics(),
        children: [
          _PlanningEditorIpadFeatureSwitch(
            enabled: planningEnabled,
            onChanged: settingsRepository.setWeeklyPlanningEnabled,
          ),
          const SizedBox(height: 14),
          _PlanningEditorIpadDefaultCard(categories: defaultCategories),
          const SizedBox(height: 14),
          _PlanningEditorIpadBalanceCard(
            weeklyPlanningRepository: weeklyPlanningRepository,
          ),
          const SizedBox(height: 16),
          _PlanningEditorSectionHeader(
            title: 'Dias da semana',
            subtitle:
                'Personalize apenas os dias que precisam fugir do padrão.',
            trailing: _PlanningEditorMiniPill(
              label: '${_customDayCount(dayConfigs)} personalizados',
              foreground: _PlanningEditorPalette.orange,
              background: _PlanningEditorPalette.orangeLight,
              border: _PlanningEditorPalette.orangeBorder,
            ),
          ),
          const SizedBox(height: 12),
          for (var weekday = DateTime.monday;
              weekday <= DateTime.sunday;
              weekday++) ...[
            _PlanningEditorIpadWeekdayCard(
              config: configs[weekday] ??
                  WeeklyPlanningDayConfig(
                    weekday: weekday,
                    useDefault: true,
                    categories: const <WeeklyPlanningCategoryConfig>[],
                  ),
              defaultCategories: defaultCategories,
              onUseDefaultChanged: (value) =>
                  weeklyPlanningRepository.setUseDefault(
                weekday: weekday,
                useDefault: value,
              ),
              onCategoryChanged: weeklyPlanningRepository.updateCategoryConfig,
            ),
            if (weekday != DateTime.sunday) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PlanningEditorIpadSideColumn extends StatelessWidget {
  final bool planningEnabled;
  final List<WeeklyPlanningCategoryConfig> defaultCategories;
  final List<WeeklyPlanningDayConfig> dayConfigs;
  final SettingsRepository settingsRepository;
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const _PlanningEditorIpadSideColumn({
    required this.planningEnabled,
    required this.defaultCategories,
    required this.dayConfigs,
    required this.settingsRepository,
    required this.weeklyPlanningRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PlanningEditorIpadSummaryCard(
          planningEnabled: planningEnabled,
          defaultCategories: defaultCategories,
          dayConfigs: dayConfigs,
        ),
        const SizedBox(height: 14),
        const _PlanningEditorIpadTipCard(),
        const SizedBox(height: 14),
        Expanded(
          child: _PlanningEditorIpadQuickActionsCard(
            planningEnabled: planningEnabled,
            settingsRepository: settingsRepository,
            weeklyPlanningRepository: weeklyPlanningRepository,
          ),
        ),
      ],
    );
  }
}

class _PlanningEditorIpadFeatureSwitch extends StatelessWidget {
  final bool enabled;
  final Future<void> Function(bool value) onChanged;

  const _PlanningEditorIpadFeatureSwitch({
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: enabled
            ? _PlanningEditorPalette.orangeLight
            : const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: enabled
              ? _PlanningEditorPalette.orangeBorder
              : _PlanningEditorPalette.border,
          width: 1.25,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: enabled ? Colors.white : _PlanningEditorPalette.bg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              enabled ? Icons.event_available_rounded : Icons.event_busy,
              color: enabled
                  ? _PlanningEditorPalette.orange
                  : _PlanningEditorPalette.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usar planejamento semanal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _PlanningEditorPalette.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quando desligado, a rodada usa a configuração padrão de categorias.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _PlanningEditorPalette.textMid,
                    fontWeight: FontWeight.w700,
                    height: 1.28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: enabled,
            activeThumbColor: _PlanningEditorPalette.orange,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PlanningEditorIpadDefaultCard extends StatelessWidget {
  final List<WeeklyPlanningCategoryConfig> categories;

  const _PlanningEditorIpadDefaultCard({required this.categories});

  @override
  Widget build(BuildContext context) {
    final total = _totalFor(categories);
    final included = categories
        .where((category) => category.isIncluded && category.safeQuota > 0)
        .toList(growable: false);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _PlanningEditorPalette.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0FAA6E32),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _PlanningEditorSectionHeader(
                  title: 'Configuração padrão',
                  subtitle: 'Base usada pelos dias sem personalização.',
                ),
              ),
              const SizedBox(width: 12),
              _PlanningEditorStatBadge(
                value: '$total',
                label: 'brinquedos',
                color: _PlanningEditorPalette.orange,
                background: _PlanningEditorPalette.orangeLight,
                border: _PlanningEditorPalette.orangeBorder,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (included.isEmpty)
            const _PlanningEditorEmptyState(
              icon: Icons.category_outlined,
              label: 'Nenhuma categoria incluída.',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in included)
                  _PlanningEditorMiniPill(
                    label: '${category.categoryName} · ${category.safeQuota}',
                    foreground: _PlanningEditorPalette.orange,
                    background: _PlanningEditorPalette.orangeLight,
                    border: _PlanningEditorPalette.orangeBorder,
                  ),
              ],
            ),
          if (included.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final category in included.take(5)) ...[
              _PlanningEditorDistributionLine(
                label: category.categoryName,
                value: category.safeQuota,
                total: total,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _PlanningEditorIpadBalanceCard extends StatefulWidget {
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const _PlanningEditorIpadBalanceCard({
    required this.weeklyPlanningRepository,
  });

  @override
  State<_PlanningEditorIpadBalanceCard> createState() =>
      _PlanningEditorIpadBalanceCardState();
}

class _PlanningEditorIpadBalanceCardState
    extends State<_PlanningEditorIpadBalanceCard> {
  late Future<CategoryBalanceAdjustmentSuggestion?> _future;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _future =
        widget.weeklyPlanningRepository.suggestCategoryBalanceAdjustment();
  }

  void _reload() {
    setState(() {
      _dismissed = false;
      _future =
          widget.weeklyPlanningRepository.suggestCategoryBalanceAdjustment();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return FutureBuilder<CategoryBalanceAdjustmentSuggestion?>(
      future: _future,
      builder: (context, snapshot) {
        final suggestion = snapshot.data;
        if (suggestion == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
          decoration: BoxDecoration(
            color: _PlanningEditorPalette.orangeLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _PlanningEditorPalette.orangeBorder,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: _PlanningEditorPalette.orange,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Equilibrar a brincadeira',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textCaption.copyWith(
                        color: _PlanningEditorPalette.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                suggestion.message,
                style: UiTokens.textMicro.copyWith(
                  color: _PlanningEditorPalette.textMid,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _dismissed = true),
                    child: const Text('Agora não'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      await widget.weeklyPlanningRepository
                          .applyCategoryBalanceAdjustment(suggestion);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Planejamento ajustado.'),
                        ),
                      );
                      _reload();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _PlanningEditorPalette.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text('Usar sugestão'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlanningEditorIpadWeekdayCard extends StatelessWidget {
  final WeeklyPlanningDayConfig config;
  final List<WeeklyPlanningCategoryConfig> defaultCategories;
  final Future<void> Function(bool value) onUseDefaultChanged;
  final Future<void> Function({
    required int weekday,
    required String categoryId,
    required bool isIncluded,
    required int quota,
  }) onCategoryChanged;

  const _PlanningEditorIpadWeekdayCard({
    required this.config,
    required this.defaultCategories,
    required this.onUseDefaultChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayCategories =
        config.useDefault ? defaultCategories : config.categories;
    final total = _totalFor(displayCategories);
    final includedDisplayCategories = displayCategories
        .where((category) => category.isIncluded && category.safeQuota > 0)
        .toList(growable: false);
    final showDistributionSuggestion = !config.useDefault &&
        config.categories.length >= 2 &&
        config.categories.any((category) => category.isIncluded);

    return Container(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _PlanningEditorPalette.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0FAA6E32),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: config.useDefault
                      ? _PlanningEditorPalette.orangeLight
                      : _PlanningEditorPalette.blueLight,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  config.useDefault
                      ? Icons.calendar_today_rounded
                      : Icons.tune_rounded,
                  color: config.useDefault
                      ? _PlanningEditorPalette.orange
                      : _PlanningEditorPalette.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _weekdayName(config.weekday),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textCaption.copyWith(
                        color: _PlanningEditorPalette.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _PlanningEditorMiniPill(
                          label: config.useDefault ? 'Padrão' : 'Personalizado',
                          foreground: config.useDefault
                              ? _PlanningEditorPalette.orange
                              : _PlanningEditorPalette.blue,
                          background: config.useDefault
                              ? _PlanningEditorPalette.orangeLight
                              : _PlanningEditorPalette.blueLight,
                          border: config.useDefault
                              ? _PlanningEditorPalette.orangeBorder
                              : const Color(0xFFBFDBFE),
                        ),
                        _PlanningEditorMiniPill(
                          label: '$total brinquedos',
                          foreground: _PlanningEditorPalette.textMid,
                          background: const Color(0xFFFFFBF6),
                          border: _PlanningEditorPalette.border,
                        ),
                        if (showDistributionSuggestion)
                          const _PlanningEditorMiniPill(
                            label: 'Sugestão disponível',
                            foreground: _PlanningEditorPalette.orange,
                            background: _PlanningEditorPalette.orangeLight,
                            border: _PlanningEditorPalette.orangeBorder,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Usar padrão',
                    style: UiTokens.textMicro.copyWith(
                      color: _PlanningEditorPalette.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Switch.adaptive(
                    value: config.useDefault,
                    activeThumbColor: _PlanningEditorPalette.orange,
                    onChanged: onUseDefaultChanged,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 13),
          if (config.useDefault)
            if (includedDisplayCategories.isEmpty)
              const _PlanningEditorSummaryBox(
                text: 'Nenhuma categoria incluída no padrão.',
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlanningEditorSummaryBox(
                    text:
                        'Usando padrão: ${_categorySummary(includedDisplayCategories)}',
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in includedDisplayCategories.take(5))
                        _PlanningEditorMiniPill(
                          label:
                              '${category.categoryName} · ${category.safeQuota}',
                          foreground: _PlanningEditorPalette.orange,
                          background: _PlanningEditorPalette.orangeLight,
                          border: _PlanningEditorPalette.orangeBorder,
                        ),
                    ],
                  ),
                ],
              )
          else ...[
            if (showDistributionSuggestion) ...[
              _PlanningEditorIpadDistributionSuggestion(
                total: total,
                categories: config.categories,
                onApply: (category) => onCategoryChanged(
                  weekday: config.weekday,
                  categoryId: category.categoryId,
                  isIncluded: category.isIncluded,
                  quota: category.quota,
                ),
              ),
              const SizedBox(height: 13),
            ],
            for (final category in config.categories) ...[
              _PlanningEditorIpadCategoryRow(
                weekday: config.weekday,
                category: category,
                onChanged: onCategoryChanged,
              ),
              const SizedBox(height: 9),
            ],
          ],
        ],
      ),
    );
  }
}

class _PlanningEditorIpadDistributionSuggestion extends StatelessWidget {
  final int total;
  final List<WeeklyPlanningCategoryConfig> categories;
  final Future<void> Function(_CategorySuggestionApplyItem category) onApply;

  const _PlanningEditorIpadDistributionSuggestion({
    required this.total,
    required this.categories,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final suggestion = buildDistribution(
      total,
      categories.map((category) => category.categoryId),
    );
    final applicableCategories = _applicableSuggestionCategories(
      categories,
      suggestion.distribution,
    );
    final visibleEntries = applicableCategories
        .where((category) => category.quota > 0)
        .toList(growable: false);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: _PlanningEditorPalette.orangeLight,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _PlanningEditorPalette.orangeBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: _PlanningEditorPalette.orange,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Distribuição sugerida',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _PlanningEditorPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: applicableCategories.isEmpty
                    ? null
                    : () async {
                        for (final category in applicableCategories) {
                          await onApply(category);
                        }
                      },
                child: const Text('Usar sugestão'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (visibleEntries.isEmpty)
            Text(
              'Nenhuma categoria sugerida para este total.',
              style: UiTokens.textMicro.copyWith(
                color: _PlanningEditorPalette.textMid,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in visibleEntries)
                  _PlanningEditorMiniPill(
                    label: '${entry.categoryName} · ${entry.quota}',
                    foreground: _PlanningEditorPalette.orange,
                    background: Colors.white,
                    border: _PlanningEditorPalette.orangeBorder,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PlanningEditorIpadCategoryRow extends StatelessWidget {
  final int weekday;
  final WeeklyPlanningCategoryConfig category;
  final Future<void> Function({
    required int weekday,
    required String categoryId,
    required bool isIncluded,
    required int quota,
  }) onChanged;

  const _PlanningEditorIpadCategoryRow({
    required this.weekday,
    required this.category,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
      decoration: BoxDecoration(
        color: category.isIncluded
            ? const Color(0xFFFFFBF6)
            : const Color(0xFFF8F2EA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.isIncluded
              ? _PlanningEditorPalette.orangeBorder
              : _PlanningEditorPalette.border,
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category.categoryName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UiTokens.textCaption.copyWith(
                color: category.isIncluded
                    ? _PlanningEditorPalette.text
                    : _PlanningEditorPalette.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _IpadQuantityStepper(
            value: category.safeQuota,
            enabled: category.isIncluded,
            onChanged: (value) => onChanged(
              weekday: weekday,
              categoryId: category.categoryId,
              isIncluded: category.isIncluded,
              quota: value,
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: category.isIncluded,
            activeThumbColor: _PlanningEditorPalette.orange,
            onChanged: (value) => onChanged(
              weekday: weekday,
              categoryId: category.categoryId,
              isIncluded: value,
              quota: category.safeQuota,
            ),
          ),
        ],
      ),
    );
  }
}

class _IpadQuantityStepper extends StatelessWidget {
  final int value;
  final bool enabled;
  final Future<void> Function(int value) onChanged;

  const _IpadQuantityStepper({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = _clampQuantity(value);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _PlanningEditorPalette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlanningEditorStepperButton(
            icon: Icons.remove_rounded,
            tooltip: 'Diminuir',
            enabled: enabled && safeValue > 0,
            onTap: () => onChanged(safeValue - 1),
          ),
          SizedBox(
            width: 42,
            child: Text(
              '$safeValue',
              textAlign: TextAlign.center,
              style: UiTokens.textCaption.copyWith(
                color: enabled
                    ? _PlanningEditorPalette.text
                    : _PlanningEditorPalette.textMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _PlanningEditorStepperButton(
            icon: Icons.add_rounded,
            tooltip: 'Aumentar',
            enabled: enabled && safeValue < 15,
            onTap: () => onChanged(safeValue + 1),
          ),
        ],
      ),
    );
  }
}

class _PlanningEditorStepperButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  const _PlanningEditorStepperButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onTap : null,
      style: IconButton.styleFrom(
        backgroundColor: enabled
            ? _PlanningEditorPalette.orangeLight
            : const Color(0xFFF5ECE2),
        foregroundColor: enabled
            ? _PlanningEditorPalette.orange
            : _PlanningEditorPalette.textMuted,
        fixedSize: const Size(31, 31),
        minimumSize: const Size(31, 31),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
      ),
      icon: Icon(icon, size: 17),
    );
  }
}

class _PlanningEditorIpadSummaryCard extends StatelessWidget {
  final bool planningEnabled;
  final List<WeeklyPlanningCategoryConfig> defaultCategories;
  final List<WeeklyPlanningDayConfig> dayConfigs;

  const _PlanningEditorIpadSummaryCard({
    required this.planningEnabled,
    required this.defaultCategories,
    required this.dayConfigs,
  });

  @override
  Widget build(BuildContext context) {
    final customDays = _customDayCount(dayConfigs);
    final activeCategories = defaultCategories
        .where((category) => category.isIncluded && category.safeQuota > 0)
        .length;
    final totalAdjustments = _customCategoryAdjustmentCount(dayConfigs);

    return _PlanningEditorSurface(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo',
            style: UiTokens.textCaption.copyWith(
              color: _PlanningEditorPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estado atual da programação',
            style: UiTokens.textMicro.copyWith(
              color: _PlanningEditorPalette.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _PlanningEditorSummaryStat(
            value: planningEnabled ? 'Ativo' : 'Off',
            label: 'Planejamento semanal',
            color: planningEnabled
                ? _PlanningEditorPalette.orange
                : _PlanningEditorPalette.textMuted,
            background: planningEnabled
                ? _PlanningEditorPalette.orangeLight
                : const Color(0xFFF8F2EA),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PlanningEditorSummaryStat(
                  value: '${_totalFor(defaultCategories)}',
                  label: 'Total padrão',
                  color: _PlanningEditorPalette.orange,
                  background: _PlanningEditorPalette.orangeLight,
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PlanningEditorSummaryStat(
                  value: '$customDays',
                  label: 'Dias próprios',
                  color: _PlanningEditorPalette.blue,
                  background: _PlanningEditorPalette.blueLight,
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PlanningEditorSummaryStat(
                  value: '$activeCategories',
                  label: 'Categorias',
                  color: _PlanningEditorPalette.purple,
                  background: _PlanningEditorPalette.purpleLight,
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PlanningEditorSummaryStat(
                  value: '$totalAdjustments',
                  label: 'Ajustes',
                  color: _PlanningEditorPalette.warmAccent,
                  background: _PlanningEditorPalette.warmLight,
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanningEditorSummaryStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color background;
  final bool compact;

  const _PlanningEditorSummaryStat({
    required this.value,
    required this.label,
    required this.color,
    required this.background,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 82 : 76),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textTitle.copyWith(
              color: color,
              fontSize: compact ? 23 : 21,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _PlanningEditorPalette.textMid,
              fontWeight: FontWeight.w900,
              height: 1.18,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanningEditorIpadTipCard extends StatelessWidget {
  const _PlanningEditorIpadTipCard();

  @override
  Widget build(BuildContext context) {
    return _PlanningEditorSurface(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _PlanningEditorPalette.orangeLight,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _PlanningEditorPalette.orangeBorder),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: _PlanningEditorPalette.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dica',
                  style: UiTokens.textCaption.copyWith(
                    color: _PlanningEditorPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Use a configuração padrão para manter consistência na semana. Personalize apenas os dias que precisam fugir do padrão.',
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _PlanningEditorPalette.textMid,
                    fontWeight: FontWeight.w700,
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanningEditorIpadQuickActionsCard extends StatelessWidget {
  final bool planningEnabled;
  final SettingsRepository settingsRepository;
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const _PlanningEditorIpadQuickActionsCard({
    required this.planningEnabled,
    required this.settingsRepository,
    required this.weeklyPlanningRepository,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _PlanningEditorActionData(
        label:
            planningEnabled ? 'Desativar planejamento' : 'Ativar planejamento',
        icon: planningEnabled ? Icons.pause_rounded : Icons.play_arrow_rounded,
        foreground: planningEnabled
            ? _PlanningEditorPalette.orange
            : _PlanningEditorPalette.orange,
        background: planningEnabled
            ? _PlanningEditorPalette.orangeLight
            : _PlanningEditorPalette.orangeLight,
        onTap: () => settingsRepository.setWeeklyPlanningEnabled(
          !planningEnabled,
        ),
      ),
      _PlanningEditorActionData(
        label: 'Restaurar semana',
        icon: Icons.restore_rounded,
        foreground: _PlanningEditorPalette.orange,
        background: _PlanningEditorPalette.orangeLight,
        onTap: () async {
          await weeklyPlanningRepository.restoreDefaultWeek();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Planejamento restaurado.')),
          );
        },
      ),
      _PlanningEditorActionData(
        label: 'Voltar à visão',
        icon: Icons.dashboard_customize_outlined,
        foreground: _PlanningEditorPalette.blue,
        background: _PlanningEditorPalette.blueLight,
        onTap: () => Navigator.of(context).maybePop(),
      ),
    ];

    return _PlanningEditorSurface(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações rápidas',
            style: UiTokens.textCaption.copyWith(
              color: _PlanningEditorPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < actions.length; index++) ...[
            _PlanningEditorActionTile(data: actions[index]),
            if (index < actions.length - 1)
              const Divider(height: 11, color: _PlanningEditorPalette.border),
          ],
          const Spacer(),
          _PlanningEditorIpadSuggestionAction(
            weeklyPlanningRepository: weeklyPlanningRepository,
          ),
        ],
      ),
    );
  }
}

class _PlanningEditorIpadSuggestionAction extends StatefulWidget {
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const _PlanningEditorIpadSuggestionAction({
    required this.weeklyPlanningRepository,
  });

  @override
  State<_PlanningEditorIpadSuggestionAction> createState() =>
      _PlanningEditorIpadSuggestionActionState();
}

class _PlanningEditorIpadSuggestionActionState
    extends State<_PlanningEditorIpadSuggestionAction> {
  late Future<CategoryBalanceAdjustmentSuggestion?> _future;

  @override
  void initState() {
    super.initState();
    _future =
        widget.weeklyPlanningRepository.suggestCategoryBalanceAdjustment();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CategoryBalanceAdjustmentSuggestion?>(
      future: _future,
      builder: (context, snapshot) {
        final suggestion = snapshot.data;
        if (suggestion == null) {
          return Text(
            'Sem sugestão de equilíbrio pendente.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _PlanningEditorPalette.textMuted,
              fontWeight: FontWeight.w700,
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async {
              await widget.weeklyPlanningRepository
                  .applyCategoryBalanceAdjustment(suggestion);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Planejamento ajustado.')),
              );
              setState(() {
                _future = widget.weeklyPlanningRepository
                    .suggestCategoryBalanceAdjustment();
              });
            },
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text('Equilibrar brincadeira'),
            style: FilledButton.styleFrom(
              backgroundColor: _PlanningEditorPalette.orange,
              foregroundColor: Colors.white,
              textStyle: UiTokens.textButton.copyWith(
                fontWeight: FontWeight.w900,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlanningEditorActionData {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final Future<void> Function()? onTap;

  const _PlanningEditorActionData({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });
}

class _PlanningEditorActionTile extends StatelessWidget {
  final _PlanningEditorActionData data;

  const _PlanningEditorActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap == null ? null : () => data.onTap!(),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: data.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.foreground, size: 19),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _PlanningEditorPalette.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _PlanningEditorPalette.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanningEditorSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _PlanningEditorSectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textSectionTitle.copyWith(
                  color: _PlanningEditorPalette.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textMicro.copyWith(
                  color: _PlanningEditorPalette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.28,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

class _PlanningEditorSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _PlanningEditorSurface({
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _PlanningEditorPalette.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12AA6E32),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x08AA6E32),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class _PlanningEditorMiniPill extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  const _PlanningEditorMiniPill({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1.1),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: UiTokens.textMicro.copyWith(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PlanningEditorStatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color background;
  final Color border;

  const _PlanningEditorStatBadge({
    required this.value,
    required this.label,
    required this.color,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            style: UiTokens.textTitle.copyWith(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _PlanningEditorPalette.textMid,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanningEditorDistributionLine extends StatelessWidget {
  final String label;
  final int value;
  final int total;

  const _PlanningEditorDistributionLine({
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total <= 0 ? 0.0 : (value / total).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 132,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _PlanningEditorPalette.textMid,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: _PlanningEditorPalette.orangeLight,
              color: _PlanningEditorPalette.orange,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          '$value',
          style: UiTokens.textMicro.copyWith(
            color: _PlanningEditorPalette.orange,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _PlanningEditorSummaryBox extends StatelessWidget {
  final String text;

  const _PlanningEditorSummaryBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _PlanningEditorPalette.border),
      ),
      child: Text(
        text,
        style: UiTokens.textMicro.copyWith(
          color: _PlanningEditorPalette.textMid,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
  }
}

class _PlanningEditorEmptyState extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlanningEditorEmptyState({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _PlanningEditorPalette.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _PlanningEditorPalette.textMuted, size: 19),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: UiTokens.textMicro.copyWith(
                color: _PlanningEditorPalette.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanningEditorPalette {
  _PlanningEditorPalette._();

  static const Color bg = Color(0xFFFDF7F0);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFF5E8);
  static const Color orangeBorder = Color(0xFFFDDCBA);
  static const Color text = Color(0xFF25180A);
  static const Color textMid = Color(0xFF6B4F30);
  static const Color textMuted = Color(0xFFA8896A);
  static const Color border = Color(0x1FB98750);
  static const Color warmAccent = Color(0xFF9A5A1E);
  static const Color warmLight = Color(0xFFFFFBF6);
  static const Color blue = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF5F3FF);
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
              const SizedBox(height: UiTokens.spacingSm),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: weeklyPlanningRepository.restoreDefaultWeek,
                  child: const Text('Restaurar'),
                ),
              ),
              _BalanceSuggestionCard(
                weeklyPlanningRepository: weeklyPlanningRepository,
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

class _BalanceSuggestionCard extends StatefulWidget {
  final WeeklyPlanningRepository weeklyPlanningRepository;

  const _BalanceSuggestionCard({required this.weeklyPlanningRepository});

  @override
  State<_BalanceSuggestionCard> createState() => _BalanceSuggestionCardState();
}

class _BalanceSuggestionCardState extends State<_BalanceSuggestionCard> {
  late Future<CategoryBalanceAdjustmentSuggestion?> _future;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _future =
        widget.weeklyPlanningRepository.suggestCategoryBalanceAdjustment();
  }

  void _reload() {
    setState(() {
      _dismissed = false;
      _future =
          widget.weeklyPlanningRepository.suggestCategoryBalanceAdjustment();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return FutureBuilder<CategoryBalanceAdjustmentSuggestion?>(
      future: _future,
      builder: (context, snapshot) {
        final suggestion = snapshot.data;
        if (suggestion == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: UiTokens.spacingMd),
          child: Container(
            padding: const EdgeInsets.all(UiTokens.spacingMd),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(UiTokens.radiusMd),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Equilibrar a brincadeira',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: UiTokens.spacingXs),
                Text(
                  suggestion.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: UiTokens.textSecondary,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: UiTokens.spacingSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _dismissed = true),
                      child: const Text('N\u00E3o'),
                    ),
                    const SizedBox(width: UiTokens.spacingXs),
                    FilledButton(
                      onPressed: () async {
                        await widget.weeklyPlanningRepository
                            .applyCategoryBalanceAdjustment(suggestion);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Planejamento ajustado.'),
                          ),
                        );
                        _reload();
                      },
                      child: const Text('Sim, ajustar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
    final showDistributionSuggestion = !config.useDefault &&
        config.categories.length >= 2 &&
        config.categories.any((category) => category.isIncluded);

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
            if (showDistributionSuggestion) ...[
              const SizedBox(height: UiTokens.spacingMd),
              _DistributionSuggestionBlock(
                total: total,
                categories: config.categories,
                onApply: (category) => onCategoryChanged(
                  weekday: config.weekday,
                  categoryId: category.categoryId,
                  isIncluded: category.isIncluded,
                  quota: category.quota,
                ),
              ),
            ],
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

class _DistributionSuggestionBlock extends StatelessWidget {
  final int total;
  final List<WeeklyPlanningCategoryConfig> categories;
  final Future<void> Function(_CategorySuggestionApplyItem category) onApply;

  const _DistributionSuggestionBlock({
    required this.total,
    required this.categories,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final suggestion = buildDistribution(
      total,
      categories.map((category) => category.categoryId),
    );
    final applicableCategories = _applicableSuggestionCategories(
      categories,
      suggestion.distribution,
    );
    final visibleEntries = applicableCategories
        .where((category) => category.quota > 0)
        .toList(growable: false);

    return Container(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(UiTokens.radiusMd),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Distribui\u00E7\u00E3o sugerida',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              TextButton(
                onPressed: applicableCategories.isEmpty
                    ? null
                    : () async {
                        for (final category in applicableCategories) {
                          await onApply(category);
                        }
                      },
                child: const Text('Usar sugest\u00E3o'),
              ),
            ],
          ),
          const SizedBox(height: UiTokens.spacingXs),
          Wrap(
            spacing: UiTokens.spacingSm,
            runSpacing: UiTokens.spacingXs,
            children: [
              for (final entry in visibleEntries)
                Text(
                  '${entry.categoryName}: ${entry.quota}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: UiTokens.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategorySuggestionApplyItem {
  final String categoryId;
  final String categoryName;
  final bool isIncluded;
  final int quota;

  const _CategorySuggestionApplyItem({
    required this.categoryId,
    required this.categoryName,
    required this.isIncluded,
    required this.quota,
  });
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final useStackedLayout = constraints.maxWidth < 520;
        final name = Text(
          category.categoryName,
          maxLines: useStackedLayout ? 2 : 1,
          overflow:
              useStackedLayout ? TextOverflow.visible : TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.18,
              ),
        );
        final controls = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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

        if (useStackedLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: double.infinity, child: name),
              const SizedBox(height: UiTokens.spacingSm),
              Row(
                children: [
                  controls,
                  const Spacer(),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: name),
            const SizedBox(width: UiTokens.spacingSm),
            controls,
          ],
        );
      },
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

int _customDayCount(List<WeeklyPlanningDayConfig> configs) {
  return configs.where((config) => !config.useDefault).length;
}

int _customCategoryAdjustmentCount(List<WeeklyPlanningDayConfig> configs) {
  var total = 0;
  for (final config in configs) {
    if (config.useDefault) continue;
    total += config.categories.length;
  }
  return total;
}

int _clampQuantity(int value) => value.clamp(0, 15).toInt();

List<_CategorySuggestionApplyItem> _applicableSuggestionCategories(
  List<WeeklyPlanningCategoryConfig> categories,
  Map<String, int> distribution,
) {
  return categories.map((category) {
    final quota = distribution[category.categoryId] ?? 0;
    return _CategorySuggestionApplyItem(
      categoryId: category.categoryId,
      categoryName: category.categoryName,
      isIncluded: quota > 0,
      quota: quota,
    );
  }).toList(growable: false);
}

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
