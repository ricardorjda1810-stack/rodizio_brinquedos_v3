import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/weekly_planning/weekly_planning_overview.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/weekly_planning_page.dart';

class WeeklyPlanningOverviewPage extends StatefulWidget {
  final SettingsRepository settingsRepository;
  final WeeklyPlanningRepository weeklyPlanningRepository;
  final RoundRepository roundRepository;
  final ToyRepository toyRepository;
  final VoidCallback? onOpenHomeTab;
  final VoidCallback? onOpenRoundTab;
  final VoidCallback? onOpenWeeklyPlanning;
  final VoidCallback? onOpenToysTab;
  final VoidCallback? onOpenBoxesTab;
  final VoidCallback? onOpenSettings;

  const WeeklyPlanningOverviewPage({
    super.key,
    required this.settingsRepository,
    required this.weeklyPlanningRepository,
    required this.roundRepository,
    required this.toyRepository,
    this.onOpenHomeTab,
    this.onOpenRoundTab,
    this.onOpenWeeklyPlanning,
    this.onOpenToysTab,
    this.onOpenBoxesTab,
    this.onOpenSettings,
  });

  @override
  State<WeeklyPlanningOverviewPage> createState() =>
      _WeeklyPlanningOverviewPageState();
}

class _WeeklyPlanningOverviewPageState
    extends State<WeeklyPlanningOverviewPage> {
  late Future<WeeklyPlanningOverview> _overviewFuture;

  @override
  void initState() {
    super.initState();
    _overviewFuture = _loadOverview();
  }

  void _refresh() {
    setState(() {
      _overviewFuture = _loadOverview();
    });
  }

  Future<WeeklyPlanningOverview> _loadOverview() async {
    await widget.settingsRepository.load();
    final planningEnabled = widget.settingsRepository.weeklyPlanningEnabled;
    final weekStart = startOfPlanningWeek(DateTime.now());
    final dayConfigs = await widget.weeklyPlanningRepository.getAll();
    final dayConfigByWeekday = <int, WeeklyPlanningDayConfig>{
      for (final config in dayConfigs) config.weekday: config,
    };
    final activeRoundItems = await _loadActiveRoundToys();
    final activeRoundToys =
        activeRoundItems.map((item) => item.toy).toList(growable: false);
    final hasToys = (await widget.toyRepository.getAllToysOnce()).isNotEmpty;
    final weeklySuggestions =
        await widget.roundRepository.suggestWeeklyPlanningForWeek(weekStart);

    final days = <WeeklyPlanningOverviewDayInput>[];
    List<WeeklyPlanningOverviewToyInput>? todayVisualToys;
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final date = weekStart.add(Duration(days: weekday - 1));
      final dayConfig = dayConfigByWeekday[weekday];
      final effectiveCategories =
          await widget.weeklyPlanningRepository.resolveCategoryConfigForDate(
        date,
      );
      final toys = weeklySuggestions[weekday] ?? const <Toy>[];
      final isToday = _isSameDate(date, DateTime.now());
      final visualToys =
          isToday && activeRoundToys.isNotEmpty ? activeRoundToys : toys;
      final customConfigIsEffective = planningEnabled &&
          hasToys &&
          dayConfig != null &&
          !dayConfig.useDefault &&
          _hasIncludedQuota(dayConfig.categories);

      if (isToday) {
        todayVisualToys = visualToys.map(_toyToPreview).toList(growable: false);
      }

      days.add(
        WeeklyPlanningOverviewDayInput(
          date: date,
          weekday: weekday,
          weekdayLabel: weeklyPlanningWeekdayLabel(weekday),
          categories: hasToys
              ? effectiveCategories
                  .map(
                    (category) => WeeklyPlanningOverviewCategoryInput(
                      categoryId: category.categoryId,
                      categoryName: category.categoryName,
                      isIncluded: category.isIncluded,
                      quota: category.safeQuota,
                    ),
                  )
                  .toList(growable: false)
              : const <WeeklyPlanningOverviewCategoryInput>[],
          toys: visualToys.map(_toyToPreview).toList(growable: false),
          isDefaultConfig: !customConfigIsEffective,
          isCustomConfig: customConfigIsEffective,
        ),
      );
    }

    final overview = buildWeeklyPlanningOverview(
      planningEnabled: planningEnabled,
      days: days,
    );
    if (todayVisualToys == null) return overview;

    return _overviewWithTodayVisualCount(
      overview,
      todayToys: todayVisualToys,
    );
  }

  Future<List<RoundToyWithBox>> _loadActiveRoundToys() async {
    try {
      return await widget.roundRepository.watchActiveRoundToysWithBox().first;
    } on Object {
      return const <RoundToyWithBox>[];
    }
  }

  Future<void> _openEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WeeklyPlanningPage(
          settingsRepository: widget.settingsRepository,
          weeklyPlanningRepository: widget.weeklyPlanningRepository,
        ),
      ),
    );
    if (!mounted) return;
    _refresh();
  }

  void _openToyDetail(String toyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToyDetailPage(
          toyId: toyId,
          toyRepository: widget.toyRepository,
          topNavigationIndex: AppTopNavigation.weeklyPlanningIndex,
          onOpenHomeTab: widget.onOpenHomeTab ?? _closeRoute,
          onOpenRoundTab: widget.onOpenRoundTab ?? _closeRoute,
          onOpenWeeklyPlanning: widget.onOpenWeeklyPlanning ?? () {},
          onOpenToysTab: widget.onOpenToysTab ?? _closeRoute,
          onOpenBoxesTab: widget.onOpenBoxesTab ?? _closeRoute,
          onOpenSettings: widget.onOpenSettings ?? _closeRoute,
        ),
      ),
    );
  }

  Future<List<_WeeklyDayToyListItem>> _loadDayToyItems(
    WeeklyPlanningDayOverview day,
    AppLocalizations l10n,
  ) async {
    final catalog = await widget.toyRepository.watchCatalog().first;
    final catalogByToyId = <String, ToyCatalogItem>{
      for (final item in catalog) item.toy.id: item,
    };

    return day.toys
        .map((toy) => _WeeklyDayToyListItem.fromPreview(
              toy,
              catalogByToyId[toy.id],
              l10n,
            ))
        .toList(growable: false);
  }

  Future<void> _openDayToys(WeeklyPlanningDayOverview day) async {
    final itemsFuture = _loadDayToyItems(day, context.l10n);
    final width = MediaQuery.sizeOf(context).width;

    void openToyFromOverlay(BuildContext overlayContext, String toyId) {
      Navigator.of(overlayContext).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openToyDetail(toyId);
      });
    }

    if (width >= 700) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            insetPadding: const EdgeInsets.all(32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 620,
                maxHeight: 720,
              ),
              child: _DayToyListPanel(
                day: day,
                itemsFuture: itemsFuture,
                onOpenToy: (toyId) => openToyFromOverlay(
                  dialogContext,
                  toyId,
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.82,
          child: _DayToyListPanel(
            day: day,
            itemsFuture: itemsFuture,
            onOpenToy: (toyId) => openToyFromOverlay(sheetContext, toyId),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIpad = MediaQuery.sizeOf(context).width >= 860;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: _FigmaPlanningPalette.bg,
      appBar: isIpad
          ? null
          : AppBar(
              backgroundColor: _FigmaPlanningPalette.bg,
              title: Text(l10n.weeklyPlanning),
            ),
      body: SafeArea(
        child: Column(
          children: [
            if (isIpad) _buildIpadTopNavigation(),
            Expanded(
              child: FutureBuilder<WeeklyPlanningOverview>(
                future: _overviewFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _OverviewMessage(
                      title: 'Não foi possível carregar o planejamento.',
                      message: '${snapshot.error}',
                    );
                  }

                  final overview = snapshot.data;
                  if (overview == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return _OverviewContent(
                    overview: overview,
                    onOpenEditor: _openEditor,
                    onOpenToy: _openToyDetail,
                    onOpenDayToys: _openDayToys,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIpadTopNavigation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1032),
          child: AppTopNavigation(
            currentIndex: AppTopNavigation.weeklyPlanningIndex,
            onHomeTap: widget.onOpenHomeTab ?? _closeRoute,
            onRoundTap: widget.onOpenRoundTab ?? _closeRoute,
            onWeeklyPlanningTap: widget.onOpenWeeklyPlanning ?? () {},
            onToysTap: widget.onOpenToysTab ?? _closeRoute,
            onBoxesTap: widget.onOpenBoxesTab ?? _closeRoute,
            onSettingsTap: widget.onOpenSettings ?? _closeRoute,
          ),
        ),
      ),
    );
  }

  void _closeRoute() {
    Navigator.of(context).maybePop();
  }
}

class _OverviewContent extends StatelessWidget {
  final WeeklyPlanningOverview overview;
  final VoidCallback onOpenEditor;
  final ValueChanged<String> onOpenToy;
  final ValueChanged<WeeklyPlanningDayOverview> onOpenDayToys;

  const _OverviewContent({
    required this.overview,
    required this.onOpenEditor,
    required this.onOpenToy,
    required this.onOpenDayToys,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isIpad = constraints.maxWidth >= 860;

        if (isIpad) {
          final gridHeight =
              (constraints.maxHeight - 24 - 40 - 112 - 18).clamp(760.0, 1120.0);
          return ListView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1032),
                  child: _buildIpadWeeklyPlanningFigmaLayout(
                    context,
                    overview: overview,
                    onOpenEditor: onOpenEditor,
                    onOpenToy: onOpenToy,
                    onOpenDayToys: onOpenDayToys,
                    gridHeight: gridHeight,
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  UiTokens.spacingMd,
                  UiTokens.spacingMd,
                  UiTokens.spacingMd,
                  UiTokens.spacingLg,
                ),
                children: [
                  _CompactPlanningLayout(
                    overview: overview,
                    onOpenEditor: onOpenEditor,
                    onOpenToy: onOpenToy,
                    onOpenDayToys: onOpenDayToys,
                  ),
                ],
              ),
            ),
            _EditButtonBar(onPressed: onOpenEditor),
          ],
        );
      },
    );
  }
}

Widget _buildIpadWeeklyPlanningFigmaLayout(
  BuildContext context, {
  required WeeklyPlanningOverview overview,
  required VoidCallback onOpenEditor,
  required ValueChanged<String> onOpenToy,
  required ValueChanged<WeeklyPlanningDayOverview> onOpenDayToys,
  required double gridHeight,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _FigmaPlanningHeader(
        overview: overview,
        onOpenEditor: onOpenEditor,
      ),
      const SizedBox(height: 18),
      if (!overview.planningEnabled) ...[
        _PlanningDisabledNotice(onOpenEditor: onOpenEditor),
        const SizedBox(height: 18),
      ],
      SizedBox(
        height: gridHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _FigmaWeekPlanCard(
                overview: overview,
                onOpenToy: onOpenToy,
                onOpenDayToys: onOpenDayToys,
              ),
            ),
            const SizedBox(width: 18),
            SizedBox(
              width: 370,
              child: _FigmaRightColumn(
                overview: overview,
                onOpenEditor: onOpenEditor,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _FigmaPlanningHeader extends StatelessWidget {
  final WeeklyPlanningOverview overview;
  final VoidCallback onOpenEditor;

  const _FigmaPlanningHeader({
    required this.overview,
    required this.onOpenEditor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _FigmaSurface(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
      child: Row(
        children: [
          const _FigmaHeaderIcon(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appNameUpper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _FigmaPlanningPalette.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.weeklyPlanning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textSectionTitle.copyWith(
                    color: _FigmaPlanningPalette.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  overview.planningEnabled
                      ? (l10n.isEn
                          ? 'See toy organization for the next few days.'
                          : 'Veja a organização dos brinquedos para os próximos dias.')
                      : (l10n.isEn
                          ? 'Enable the schedule to customize the next few days.'
                          : 'Ative a programação para personalizar os próximos dias.'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _FigmaPlanningPalette.textMuted,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FigmaHeaderButton(
                label: l10n.editSchedule,
                icon: Icons.shuffle_rounded,
                primary: true,
                onTap: onOpenEditor,
              ),
              const SizedBox(width: 10),
              _FigmaHeaderButton(
                label: l10n.adjustCategories,
                icon: Icons.tune_rounded,
                primary: false,
                onTap: onOpenEditor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FigmaHeaderIcon extends StatelessWidget {
  const _FigmaHeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_FigmaPlanningPalette.orange, Color(0xFFFBBF24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4DF97316),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.calendar_month_rounded,
        color: Colors.white,
        size: 29,
      ),
    );
  }
}

class _FigmaHeaderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _FigmaHeaderButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = primary ? Colors.white : const Color(0xFFC2410C);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: primary ? null : _FigmaPlanningPalette.orangeLight,
            gradient: primary
                ? const LinearGradient(
                    colors: [
                      _FigmaPlanningPalette.orange,
                      Color(0xFFFB923C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(13),
            border: primary
                ? null
                : Border.all(
                    color: _FigmaPlanningPalette.orangeBorder,
                    width: 1.5,
                  ),
            boxShadow: primary
                ? const [
                    BoxShadow(
                      color: Color(0x59F97316),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor, size: 15),
              const SizedBox(width: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textButton.copyWith(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: primary ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FigmaWeekPlanCard extends StatelessWidget {
  final WeeklyPlanningOverview overview;
  final ValueChanged<String> onOpenToy;
  final ValueChanged<WeeklyPlanningDayOverview> onOpenDayToys;

  const _FigmaWeekPlanCard({
    required this.overview,
    required this.onOpenToy,
    required this.onOpenDayToys,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final readyDays = overview.days.where((day) => day.total > 0).length;

    return _FigmaSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.currentWeek,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textSectionTitle.copyWith(
                          color: _FigmaPlanningPalette.text,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_weekRangeLabel(overview.days, l10n)} · $readyDays ${l10n.daysPlanned}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textMicro.copyWith(
                          color: _FigmaPlanningPalette.textMuted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _FigmaStatusPill(
                  label: l10n.isEn
                      ? '$readyDays of ${overview.days.length} ${l10n.daysReady}'
                      : '$readyDays de ${overview.days.length} ${l10n.daysReady}',
                  foreground: _FigmaPlanningPalette.orange,
                  background: _FigmaPlanningPalette.orangeLight,
                  border: _FigmaPlanningPalette.orangeBorder,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _FigmaPlanningPalette.border),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  for (var index = 0;
                      index < overview.days.length;
                      index++) ...[
                    Expanded(
                      child: _FigmaDayPlanRow(
                        day: overview.days[index],
                        onOpenToy: onOpenToy,
                        onOpenDayToys: onOpenDayToys,
                      ),
                    ),
                    if (index != overview.days.length - 1)
                      const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _FigmaWeekFooter(overview: overview),
          ),
        ],
      ),
    );
  }
}

class _FigmaDayPlanRow extends StatelessWidget {
  final WeeklyPlanningDayOverview day;
  final ValueChanged<String> onOpenToy;
  final ValueChanged<WeeklyPlanningDayOverview> onOpenDayToys;

  const _FigmaDayPlanRow({
    required this.day,
    required this.onOpenToy,
    required this.onOpenDayToys,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = _figmaStatusFor(day, l10n);

    return Material(
      color: Colors.transparent,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: status.today
              ? _FigmaPlanningPalette.orangeLight
              : _FigmaPlanningPalette.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status.today
                ? _FigmaPlanningPalette.orangeBorder
                : _FigmaPlanningPalette.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: status.today
                  ? const Color(0x21F97316)
                  : const Color(0x0DAA6E32),
              blurRadius: status.today ? 10 : 3,
              offset: Offset(0, status.today ? 2 : 1),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _weekdayAbbr(day.weekday, l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UiTokens.textCaption.copyWith(
                      color: status.today
                          ? _FigmaPlanningPalette.orange
                          : _FigmaPlanningPalette.text,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${day.date.day} ${_shortMonth(day.date.month, l10n)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UiTokens.textMicro.copyWith(
                      color: _FigmaPlanningPalette.textMuted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FigmaStatusPill(
                    label: status.label,
                    foreground: status.foreground,
                    background: status.background,
                    border: status.border,
                    compact: true,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    day.total == 1 ? '1 brinquedo' : '${day.total} brinquedos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UiTokens.textMicro.copyWith(
                      color: _FigmaPlanningPalette.textMid,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _FigmaToyStack(
                day: day,
                onOpenToy: onOpenToy,
                onOpenDayToys: onOpenDayToys,
              ),
            ),
            const SizedBox(width: 8),
            _DayTotalTextButton(
              day: day,
              onPressed: () => onOpenDayToys(day),
              figma: true,
            ),
            const SizedBox(width: 2),
            _DayChevronButton(
              day: day,
              onPressed: () => onOpenDayToys(day),
              color: status.today
                  ? _FigmaPlanningPalette.orange
                  : _FigmaPlanningPalette.textMuted,
              figma: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _FigmaToyStack extends StatelessWidget {
  final WeeklyPlanningDayOverview day;
  final ValueChanged<String> onOpenToy;
  final ValueChanged<WeeklyPlanningDayOverview> onOpenDayToys;

  const _FigmaToyStack({
    required this.day,
    required this.onOpenToy,
    required this.onOpenDayToys,
  });

  @override
  Widget build(BuildContext context) {
    final visible = day.toys.take(3).toList(growable: false);
    final overflow =
        day.total > visible.length ? day.total - visible.length : 0;

    if (visible.isEmpty && day.total == 0) {
      return Text(
        'Aguardando configuração',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: UiTokens.textMicro.copyWith(
          color: _FigmaPlanningPalette.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return SizedBox(
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < visible.length; index++)
            Positioned(
              left: index * 23,
              top: 1,
              child: _FigmaToyAvatar(
                toy: visible[index],
                onTap: () => onOpenToy(visible[index].id),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: visible.length * 23,
              top: 1,
              child: _FigmaOverflowAvatar(
                count: overflow,
                onTap: () => onOpenDayToys(day),
              ),
            ),
        ],
      ),
    );
  }
}

class _FigmaToyAvatar extends StatelessWidget {
  final WeeklyPlanningOverviewToyInput toy;
  final VoidCallback onTap;

  const _FigmaToyAvatar({
    required this.toy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final path = toy.photoPath?.trim();

    return Semantics(
      button: true,
      label: _openToySemanticLabel(toy, l10n),
      child: Tooltip(
        message: _openToySemanticLabel(toy, l10n),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: path == null || path.isEmpty
                        ? const _FigmaToyAvatarPlaceholder()
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const _FigmaToyAvatarPlaceholder(),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FigmaToyAvatarPlaceholder extends StatelessWidget {
  const _FigmaToyAvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F0E6),
      child: const Icon(
        Icons.toys_outlined,
        size: 15,
        color: _FigmaPlanningPalette.textMuted,
      ),
    );
  }
}

class _FigmaOverflowAvatar extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _FigmaOverflowAvatar({
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Ver mais brinquedos',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _FigmaPlanningPalette.orangeLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '+$count',
                  style: UiTokens.textMicro.copyWith(
                    color: _FigmaPlanningPalette.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FigmaWeekFooter extends StatelessWidget {
  final WeeklyPlanningOverview overview;

  const _FigmaWeekFooter({required this.overview});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = overview.categoryDistribution.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _FigmaPlanningPalette.bg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _FigmaPlanningPalette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: l10n.isEn ? 'Week total: ' : 'Total da semana: ',
                children: [
                  TextSpan(
                    text: l10n.toysForWeekCount(overview.totalToysInWeek),
                    style: const TextStyle(
                      color: _FigmaPlanningPalette.textMid,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UiTokens.textMicro.copyWith(
                color: _FigmaPlanningPalette.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$categories categorias cobertas',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _FigmaPlanningPalette.textMid,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaRightColumn extends StatelessWidget {
  final WeeklyPlanningOverview overview;
  final VoidCallback onOpenEditor;

  const _FigmaRightColumn({
    required this.overview,
    required this.onOpenEditor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FigmaSummaryCard(overview: overview),
        const SizedBox(height: 14),
        _FigmaCategoriesCard(overview: overview),
        const SizedBox(height: 14),
        Expanded(
          child: _FigmaQuickActionsCard(
            overview: overview,
            onOpenEditor: onOpenEditor,
          ),
        ),
      ],
    );
  }
}

class _FigmaSummaryCard extends StatelessWidget {
  final WeeklyPlanningOverview overview;

  const _FigmaSummaryCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = [
      _FigmaStatData(
        value: '${overview.totalToysInWeek}',
        label: l10n.toysThisWeek,
        foreground: _FigmaPlanningPalette.orange,
        background: _FigmaPlanningPalette.orangeLight,
        border: _FigmaPlanningPalette.orangeBorder,
      ),
      _FigmaStatData(
        value: _formatAverage(overview.averagePerDay, l10n),
        label: l10n.averagePerDay,
        foreground: const Color(0xFF8B5CF6),
        background: const Color(0xFFF5F3FF),
        border: const Color(0xFFDDD6FE),
      ),
      _FigmaStatData(
        value: '${overview.categoryDistribution.length}',
        label: l10n.isEn ? 'balanced categories' : 'categorias equilibradas',
        foreground: _FigmaPlanningPalette.warmAccent,
        background: _FigmaPlanningPalette.warmLight,
        border: _FigmaPlanningPalette.warmBorder,
      ),
    ];

    return _FigmaSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FigmaSideCardTitle(
            title: l10n.weeklySummary,
            subtitle: l10n.isEn
                ? 'Consolidated view of the period'
                : 'Visão consolidada do período',
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < stats.length; index++) ...[
            _FigmaStatTile(data: stats[index]),
            if (index != stats.length - 1) const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _FigmaStatData {
  final String value;
  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  const _FigmaStatData({
    required this.value,
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });
}

class _FigmaStatTile extends StatelessWidget {
  final _FigmaStatData data;

  const _FigmaStatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: data.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.border, width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              data.value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UiTokens.textTitle.copyWith(
                color: data.foreground,
                fontSize: 25.5,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              data.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: UiTokens.textCaption.copyWith(
                color: _FigmaPlanningPalette.textMid,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaCategoriesCard extends StatelessWidget {
  final WeeklyPlanningOverview overview;

  const _FigmaCategoriesCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = overview.categoryDistribution;
    final categoryTotal =
        items.fold<int>(0, (total, item) => total + item.total);

    return _FigmaSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FigmaSideCardTitle(
            title: l10n.isEn ? 'Week categories' : 'Categorias da semana',
            subtitle: l10n.categoryDistribution,
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text(
              l10n.isEn
                  ? 'Include at least one category to see the distribution.'
                  : 'Inclua pelo menos uma categoria para ver a distribuição.',
              style: UiTokens.textMicro.copyWith(
                color: _FigmaPlanningPalette.textMuted,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            for (var index = 0; index < items.length; index++) ...[
              _FigmaCategoryProgressRow(
                item: items[index],
                total: categoryTotal,
                style: _figmaCategoryStyle(index),
              ),
              if (index != items.length - 1) const SizedBox(height: 9),
            ],
        ],
      ),
    );
  }
}

class _FigmaCategoryProgressRow extends StatelessWidget {
  final WeeklyPlanningCategoryDistribution item;
  final int total;
  final _FigmaVisualStyle style;

  const _FigmaCategoryProgressRow({
    required this.item,
    required this.total,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percent = total <= 0 ? 0 : ((item.total / total) * 100).round();
    final widthFactor = total <= 0 ? 0.0 : (item.total / total).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: style.foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                l10n.categoryName(item.categoryName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textMicro.copyWith(
                  color: _FigmaPlanningPalette.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.compactToysCount(item.total),
              maxLines: 1,
              style: UiTokens.textMicro.copyWith(
                color: _FigmaPlanningPalette.textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            _FigmaStatusPill(
              label: '$percent%',
              foreground: style.foreground,
              background: style.background,
              border: style.border,
              compact: true,
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Container(
            height: 6,
            color: const Color(0xFFF0E8DE),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: style.foreground.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FigmaQuickActionsCard extends StatelessWidget {
  final WeeklyPlanningOverview overview;
  final VoidCallback onOpenEditor;

  const _FigmaQuickActionsCard({
    required this.overview,
    required this.onOpenEditor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actions = [
      _FigmaActionData(
        label: l10n.editSchedule,
        icon: Icons.edit_calendar_outlined,
        foreground: _FigmaPlanningPalette.orange,
        background: _FigmaPlanningPalette.orangeLight,
        onTap: onOpenEditor,
      ),
      _FigmaActionData(
        label: l10n.adjustCategories,
        icon: Icons.tune_rounded,
        foreground: const Color(0xFF8B5CF6),
        background: const Color(0xFFF5F3FF),
        onTap: onOpenEditor,
      ),
      _FigmaActionData(
        label: l10n.isEn ? 'Review quotas' : 'Revisar cotas',
        icon: Icons.rule_rounded,
        foreground: _FigmaPlanningPalette.warmAccent,
        background: _FigmaPlanningPalette.warmLight,
        onTap: onOpenEditor,
      ),
    ];

    return _FigmaSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.isEn ? 'Quick actions' : 'Ações rápidas',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textCaption.copyWith(
              color: _FigmaPlanningPalette.text,
              fontSize: 14.8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < actions.length; index++) ...[
            _FigmaQuickActionTile(data: actions[index]),
            if (index != actions.length - 1)
              const Divider(height: 1, color: _FigmaPlanningPalette.border),
          ],
          const Spacer(),
          const Divider(height: 1, color: _FigmaPlanningPalette.border),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  _weekRangeLabel(overview.days, l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _FigmaPlanningPalette.textMuted,
                    fontSize: 11.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _FigmaStatusPill(
                label: l10n.isEn
                    ? '${overview.days.where((day) => day.total > 0).length} of ${overview.days.length} days'
                    : '${overview.days.where((day) => day.total > 0).length} de ${overview.days.length} dias',
                foreground: _FigmaPlanningPalette.orange,
                background: _FigmaPlanningPalette.orangeLight,
                border: _FigmaPlanningPalette.orangeLight,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FigmaActionData {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;

  const _FigmaActionData({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });
}

class _FigmaQuickActionTile extends StatelessWidget {
  final _FigmaActionData data;

  const _FigmaQuickActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: data.background,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: data.foreground.withValues(alpha: 0.14),
                    width: 1.5,
                  ),
                ),
                child: Icon(data.icon, color: data.foreground, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textButton.copyWith(
                    color: _FigmaPlanningPalette.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: _FigmaPlanningPalette.textMuted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FigmaSideCardTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FigmaSideCardTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: UiTokens.textCaption.copyWith(
            color: _FigmaPlanningPalette.text,
            fontSize: 14.8,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: UiTokens.textMicro.copyWith(
            color: _FigmaPlanningPalette.textMuted,
            fontSize: 12.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FigmaStatusPill extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final Color border;
  final bool compact;

  const _FigmaStatusPill({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 2.5 : 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: compact ? 1 : 1.5),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: UiTokens.textMicro.copyWith(
          color: foreground,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FigmaSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _FigmaSurface({
    required this.child,
    this.padding = const EdgeInsets.all(UiTokens.spacingMd),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _FigmaPlanningPalette.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12AA6E32),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x0EAA6E32),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _FigmaDayStatus {
  final String label;
  final Color foreground;
  final Color background;
  final Color border;
  final bool today;

  const _FigmaDayStatus({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
    this.today = false,
  });
}

class _FigmaVisualStyle {
  final Color foreground;
  final Color background;
  final Color border;

  const _FigmaVisualStyle({
    required this.foreground,
    required this.background,
    required this.border,
  });
}

class _CompactPlanningLayout extends StatelessWidget {
  final WeeklyPlanningOverview overview;
  final VoidCallback onOpenEditor;
  final ValueChanged<String> onOpenToy;
  final ValueChanged<WeeklyPlanningDayOverview> onOpenDayToys;

  const _CompactPlanningLayout({
    required this.overview,
    required this.onOpenEditor,
    required this.onOpenToy,
    required this.onOpenDayToys,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PlanningHeroCard(
          overview: overview,
          onOpenEditor: onOpenEditor,
          isWide: false,
        ),
        const SizedBox(height: UiTokens.spacingMd),
        if (!overview.planningEnabled) ...[
          _PlanningDisabledNotice(onOpenEditor: onOpenEditor),
          const SizedBox(height: UiTokens.spacingMd),
        ],
        _WeekSummaryCard(overview: overview, isWide: isWide),
        const SizedBox(height: UiTokens.spacingMd),
        _CategoryDistributionCard(overview: overview),
        const SizedBox(height: UiTokens.spacingMd),
        _WeekScheduleCard(
          overview: overview,
          onOpenToy: onOpenToy,
          onOpenDayToys: onOpenDayToys,
          isIpad: false,
        ),
      ],
    );
  }
}

class _PlanningHeroCard extends StatelessWidget {
  final WeeklyPlanningOverview overview;
  final VoidCallback onOpenEditor;
  final bool isWide;

  const _PlanningHeroCard({
    required this.overview,
    required this.onOpenEditor,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = overview.planningEnabled
        ? (l10n.isEn
            ? 'Plan the week with confidence'
            : 'Planeje a semana sem improviso')
        : (l10n.isEn
            ? 'Enable weekly planning'
            : 'Ative o planejamento semanal');
    final subtitle = overview.planningEnabled
        ? (l10n.isEn
            ? 'See the next few days and adjust quantities by category.'
            : 'Veja os próximos dias e ajuste quantidades por categoria.')
        : (l10n.isEn
            ? 'The week uses the default setup until you enable scheduling.'
            : 'A semana usa o padrão até você ativar a programação.');
    final action = FilledButton.icon(
      onPressed: onOpenEditor,
      icon: const Icon(Icons.edit_calendar_outlined),
      label: Text(l10n.editSchedule),
      style: FilledButton.styleFrom(
        backgroundColor: UiTokens.actionOrange,
        foregroundColor: Colors.white,
        minimumSize: Size(isWide ? 196 : 0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: UiTokens.textButton.copyWith(fontWeight: FontWeight.w800),
        elevation: 0,
        shadowColor: UiTokens.actionOrange.withValues(alpha: 0.24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiTokens.radiusLg),
        ),
      ),
    );

    return AppSurfaceCard(
      padding: const EdgeInsets.all(22),
      child: isWide
          ? Row(
              children: [
                const _PlanningHeroIcon(),
                const SizedBox(width: 18),
                Expanded(
                  child: _PlanningHeroCopy(
                    title: title,
                    subtitle: subtitle,
                    total: overview.totalToysInWeek,
                  ),
                ),
                const SizedBox(width: 18),
                action,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PlanningHeroIcon(),
                const SizedBox(height: UiTokens.spacingMd),
                _PlanningHeroCopy(
                  title: title,
                  subtitle: subtitle,
                  total: overview.totalToysInWeek,
                ),
                const SizedBox(height: UiTokens.spacingMd),
                SizedBox(width: double.infinity, child: action),
              ],
            ),
    );
  }
}

class _PlanningHeroIcon extends StatelessWidget {
  const _PlanningHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: _WeeklyIpadPalette.orange,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x34F97316),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.calendar_month_outlined,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class _PlanningHeroCopy extends StatelessWidget {
  final String title;
  final String subtitle;
  final int total;

  const _PlanningHeroCopy({
    required this.title,
    required this.subtitle,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final totalLabel = total == 1 ? '1 brinquedo' : '$total brinquedos';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _PlanningPill(
              label: '$totalLabel nesta semana',
              foreground: _WeeklyIpadPalette.orange,
              background: _WeeklyIpadPalette.orangeSoft,
              border: _WeeklyIpadPalette.orangeBorder,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: UiTokens.textTitle.copyWith(
            color: _WeeklyIpadPalette.text,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: UiTokens.textCaption.copyWith(
            color: _WeeklyIpadPalette.textMid,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PlanningDisabledNotice extends StatelessWidget {
  final VoidCallback onOpenEditor;

  const _PlanningDisabledNotice({required this.onOpenEditor});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      color: UiTokens.actionOrangeSoft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: UiTokens.actionOrange),
          const SizedBox(width: UiTokens.spacingSm),
          Expanded(
            child: Text(
              l10n.isEn
                  ? 'Weekly planning is disabled. The week below uses the default setup until you enable scheduling.'
                  : 'Planejamento semanal desativado. A semana abaixo usa a configuração padrão até você ativar a programação.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: UiTokens.textSecondary,
                    height: 1.35,
                  ),
            ),
          ),
          const SizedBox(width: UiTokens.spacingSm),
          TextButton(
            onPressed: onOpenEditor,
            child: Text(l10n.isEn ? 'Configure' : 'Configurar'),
          ),
        ],
      ),
    );
  }
}

class _WeekSummaryCard extends StatelessWidget {
  final WeeklyPlanningOverview overview;
  final bool isWide;

  const _WeekSummaryCard({
    required this.overview,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final metrics = [
      _MetricData(
        icon: Icons.toys_outlined,
        label: l10n.toysThisWeek,
        value: '${overview.totalToysInWeek}',
      ),
      _MetricData(
        icon: Icons.calendar_today_outlined,
        label: l10n.averagePerDay,
        value: _formatAverage(overview.averagePerDay, l10n),
      ),
      _MetricData(
        icon: Icons.inventory_2_outlined,
        label: l10n.boxesInUse,
        value: '${overview.boxesInUse}',
      ),
    ];

    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklySummary,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          Text(
            overview.hasConfiguredToys
                ? l10n.weeklyTotalsSubtitle
                : (l10n.isEn
                    ? 'No category has an active quantity this week.'
                    : 'Nenhuma categoria com quantidade ativa nesta semana.'),
            style: textTheme.bodySmall?.copyWith(
              color: UiTokens.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: UiTokens.spacingMd),
          if (isWide)
            Row(
              children: [
                for (var index = 0; index < metrics.length; index++) ...[
                  Expanded(child: _MetricTile(data: metrics[index])),
                  if (index != metrics.length - 1)
                    const SizedBox(width: UiTokens.spacingSm),
                ],
              ],
            )
          else
            Column(
              children: [
                for (var index = 0; index < metrics.length; index++) ...[
                  _MetricTile(data: metrics[index]),
                  if (index != metrics.length - 1)
                    const SizedBox(height: UiTokens.spacingSm),
                ],
              ],
            ),
          if (overview.hasInsufficientToys) ...[
            const SizedBox(height: UiTokens.spacingMd),
            const _InlineNotice(
              icon: Icons.warning_amber_rounded,
              text:
                  'Alguns dias têm menos brinquedos disponíveis do que o total planejado.',
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricData {
  final IconData icon;
  final String label;
  final String value;

  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _MetricTile extends StatelessWidget {
  final _MetricData data;

  const _MetricTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      decoration: BoxDecoration(
        color: UiTokens.actionOrangeSoft,
        borderRadius: BorderRadius.circular(UiTokens.radiusMd),
        border: Border.all(color: UiTokens.border),
      ),
      child: Row(
        children: [
          Icon(data.icon, color: UiTokens.actionOrange),
          const SizedBox(width: UiTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: UiTokens.actionOrange,
                      ),
                ),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: UiTokens.textSecondary,
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

class _CategoryDistributionCard extends StatelessWidget {
  final WeeklyPlanningOverview overview;

  const _CategoryDistributionCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = overview.categoryDistribution;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categoryDistribution,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          if (items.isEmpty)
            Text(
              l10n.isEn
                  ? 'Include at least one category to see the distribution.'
                  : 'Inclua pelo menos uma categoria para ver a distribuição.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: UiTokens.textSecondary,
                  ),
            )
          else
            Wrap(
              spacing: UiTokens.spacingSm,
              runSpacing: UiTokens.spacingSm,
              children: [
                for (final item in items)
                  _CategoryChip(
                    item: item,
                    icon: _iconForCategory(item.categoryId),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final WeeklyPlanningCategoryDistribution item;
  final IconData icon;

  const _CategoryChip({
    required this.item,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      constraints: const BoxConstraints(minWidth: 142, maxWidth: 250),
      padding: const EdgeInsets.symmetric(
        horizontal: UiTokens.spacingMd,
        vertical: UiTokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: UiTokens.actionOrangeSoft,
        borderRadius: BorderRadius.circular(UiTokens.radiusMd),
        border: Border.all(color: UiTokens.actionOrangeBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: UiTokens.actionOrange),
          const SizedBox(width: UiTokens.spacingSm),
          Flexible(
            child: Text(
              l10n.categoryName(item.categoryName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: UiTokens.spacingSm),
          Text(
            '${item.total}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: UiTokens.actionOrange,
                ),
          ),
        ],
      ),
    );
  }
}

class _WeekScheduleCard extends StatelessWidget {
  final WeeklyPlanningOverview overview;
  final ValueChanged<String> onOpenToy;
  final ValueChanged<WeeklyPlanningDayOverview> onOpenDayToys;
  final bool isIpad;

  const _WeekScheduleCard({
    required this.overview,
    required this.onOpenToy,
    required this.onOpenDayToys,
    required this.isIpad,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSurfaceCard(
      padding: EdgeInsets.all(isIpad ? 26 : UiTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weekSchedule,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          if (!overview.hasConfiguredToys) ...[
            Text(
              l10n.isEn
                  ? 'Set quantities by category to build the week.'
                  : 'Defina quantidades por categoria para montar a semana.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: UiTokens.textSecondary,
                  ),
            ),
            const SizedBox(height: UiTokens.spacingMd),
          ],
          for (var index = 0; index < overview.days.length; index++) ...[
            _DayScheduleRow(
              day: overview.days[index],
              onOpenToy: onOpenToy,
              onOpenDayToys: onOpenDayToys,
            ),
            if (index != overview.days.length - 1)
              const Divider(height: UiTokens.spacingLg),
          ],
        ],
      ),
    );
  }
}

class _DayScheduleRow extends StatelessWidget {
  final WeeklyPlanningDayOverview day;
  final ValueChanged<String> onOpenToy;
  final ValueChanged<WeeklyPlanningDayOverview> onOpenDayToys;

  const _DayScheduleRow({
    required this.day,
    required this.onOpenToy,
    required this.onOpenDayToys,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final maxVisibleToys = constraints.maxWidth >= 760 ? 6 : 4;

        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: UiTokens.spacingXs,
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _DayLabelBlock(day: day)),
                        _DayTotalBadge(
                          day: day,
                          onPressed: () => onOpenDayToys(day),
                        ),
                        const SizedBox(width: UiTokens.spacingXs),
                        _DayChevronButton(
                          day: day,
                          onPressed: () => onOpenDayToys(day),
                        ),
                      ],
                    ),
                    const SizedBox(height: UiTokens.spacingSm),
                    _ToyThumbnailStrip(
                      toys: day.toys,
                      total: day.total,
                      maxVisible: maxVisibleToys,
                      onOpenToy: onOpenToy,
                      onOpenDayToys: () => onOpenDayToys(day),
                    ),
                  ],
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 124,
                      child: _DayLabelBlock(day: day),
                    ),
                    const SizedBox(width: UiTokens.spacingSm),
                    Expanded(
                      child: _ToyThumbnailStrip(
                        toys: day.toys,
                        total: day.total,
                        maxVisible: maxVisibleToys,
                        onOpenToy: onOpenToy,
                        onOpenDayToys: () => onOpenDayToys(day),
                      ),
                    ),
                    const SizedBox(width: UiTokens.spacingSm),
                    _DayTotalBadge(
                      day: day,
                      onPressed: () => onOpenDayToys(day),
                    ),
                    const SizedBox(width: UiTokens.spacingXs),
                    _DayChevronButton(
                      day: day,
                      onPressed: () => onOpenDayToys(day),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _DayLabelBlock extends StatelessWidget {
  final WeeklyPlanningDayOverview day;

  const _DayLabelBlock({required this.day});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateLabel = DateFormat.yMd(l10n.dateLocale).format(day.date);
    final configLabel = day.isCustomConfig ? l10n.custom : l10n.standard;
    final weekdayLabel = DateFormat.EEEE(l10n.dateLocale).format(day.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          weekdayLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          '$dateLabel · $configLabel',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: UiTokens.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _ToyThumbnailStrip extends StatelessWidget {
  final List<WeeklyPlanningOverviewToyInput> toys;
  final int total;
  final int maxVisible;
  final ValueChanged<String> onOpenToy;
  final VoidCallback onOpenDayToys;

  const _ToyThumbnailStrip({
    required this.toys,
    required this.total,
    required this.maxVisible,
    required this.onOpenToy,
    required this.onOpenDayToys,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (toys.isEmpty) {
      return Text(
        total == 0 ? l10n.noPlannedToys : l10n.notEnoughToys,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: UiTokens.textSecondary,
            ),
      );
    }

    final visible = toys.take(maxVisible).toList(growable: false);
    final remaining = toys.length - visible.length;

    return Wrap(
      spacing: UiTokens.spacingXs,
      runSpacing: UiTokens.spacingXs,
      children: [
        for (final toy in visible)
          _ToyThumbnail(
            toy: toy,
            onTap: () => onOpenToy(toy.id),
          ),
        if (remaining > 0)
          _MoreToysBadge(
            count: remaining,
            onTap: onOpenDayToys,
          ),
      ],
    );
  }
}

class _ToyThumbnail extends StatelessWidget {
  final WeeklyPlanningOverviewToyInput toy;
  final VoidCallback onTap;

  const _ToyThumbnail({
    required this.toy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final path = toy.photoPath?.trim();

    return Semantics(
      button: true,
      label: _openToySemanticLabel(toy, l10n),
      child: Tooltip(
        message: _openToySemanticLabel(toy, l10n),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(UiTokens.radiusSm),
          child: InkWell(
            key: ValueKey('weekly-toy-thumbnail-${toy.id}'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(UiTokens.radiusSm),
            child: SizedBox(
              width: 54,
              height: 54,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(UiTokens.radiusSm),
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: path == null || path.isEmpty
                        ? const _ToyThumbnailPlaceholder()
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const _ToyThumbnailPlaceholder(),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToyThumbnailPlaceholder extends StatelessWidget {
  const _ToyThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F0E6),
      child: const Icon(
        Icons.toys_outlined,
        size: 20,
        color: UiTokens.textSecondary,
      ),
    );
  }
}

class _MoreToysBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _MoreToysBadge({
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Ver mais brinquedos',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(UiTokens.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UiTokens.radiusSm),
          child: Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            child: Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: UiTokens.actionOrangeSoft,
                borderRadius: BorderRadius.circular(UiTokens.radiusSm),
              ),
              child: Text(
                '+$count',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: UiTokens.actionOrange,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayTotalBadge extends StatelessWidget {
  final WeeklyPlanningDayOverview day;
  final VoidCallback onPressed;

  const _DayTotalBadge({
    required this.day,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = l10n.itemsCount(day.total);

    return Semantics(
      button: true,
      label: _openDayToysSemanticLabel(day, l10n),
      child: Tooltip(
        message: _openDayToysSemanticLabel(day, l10n),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(UiTokens.radiusSm),
          child: InkWell(
            key: ValueKey('weekly-day-total-${day.weekday}'),
            onTap: onPressed,
            borderRadius: BorderRadius.circular(UiTokens.radiusSm),
            child: Container(
              constraints: const BoxConstraints(minWidth: 70, minHeight: 44),
              padding: const EdgeInsets.symmetric(
                horizontal: UiTokens.spacingSm,
                vertical: UiTokens.spacingXs,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: day.hasInsufficientToys
                    ? UiTokens.secondarySoft
                    : UiTokens.bg,
                borderRadius: BorderRadius.circular(UiTokens.radiusSm),
                border: Border.all(color: UiTokens.border),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: day.hasInsufficientToys
                          ? UiTokens.danger
                          : UiTokens.textSecondary,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayTotalTextButton extends StatelessWidget {
  final WeeklyPlanningDayOverview day;
  final VoidCallback onPressed;
  final bool figma;

  const _DayTotalTextButton({
    required this.day,
    required this.onPressed,
    this.figma = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = l10n.itemsCount(day.total);

    return Semantics(
      button: true,
      label: _openDayToysSemanticLabel(day, l10n),
      child: Tooltip(
        message: _openDayToysSemanticLabel(day, l10n),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: figma
                    ? UiTokens.textMicro.copyWith(
                        color: _FigmaPlanningPalette.textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      )
                    : Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: UiTokens.textSecondary,
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayChevronButton extends StatelessWidget {
  final WeeklyPlanningDayOverview day;
  final VoidCallback onPressed;
  final Color? color;
  final bool figma;

  const _DayChevronButton({
    required this.day,
    required this.onPressed,
    this.color,
    this.figma = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: _openDayToysSemanticLabel(day, l10n),
      child: Tooltip(
        message: _openDayToysSemanticLabel(day, l10n),
        child: SizedBox(
          width: figma ? 34 : 44,
          height: figma ? 34 : 44,
          child: IconButton(
            key: ValueKey('weekly-day-chevron-${day.weekday}'),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              figma ? Icons.chevron_right_rounded : Icons.chevron_right,
              size: figma ? 20 : 24,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayToyListPanel extends StatelessWidget {
  final WeeklyPlanningDayOverview day;
  final Future<List<_WeeklyDayToyListItem>> itemsFuture;
  final ValueChanged<String> onOpenToy;

  const _DayToyListPanel({
    required this.day,
    required this.itemsFuture,
    required this.onOpenToy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: _FigmaPlanningPalette.card,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: FutureBuilder<List<_WeeklyDayToyListItem>>(
        future: itemsFuture,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <_WeeklyDayToyListItem>[];
          final isLoading = !snapshot.hasData && !snapshot.hasError;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: UiTokens.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _dayListTitle(day, l10n),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: _FigmaPlanningPalette.text,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _scheduledToyCountLabel(day.toys.length, l10n),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: UiTokens.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Voltar',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : snapshot.hasError
                          ? _DayToyListMessage(
                              message:
                                  'Não foi possível carregar os brinquedos.',
                              detail: '${snapshot.error}',
                            )
                          : items.isEmpty
                              ? const _DayToyListMessage(
                                  message: 'Nenhum brinquedo programado.',
                                  detail:
                                      'Ajuste a programação para incluir brinquedos neste dia.',
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    12,
                                    16,
                                    20,
                                  ),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    return _DayToyListTile(
                                      item: item,
                                      onTap: () => onOpenToy(item.id),
                                    );
                                  },
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemCount: items.length,
                                ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DayToyListMessage extends StatelessWidget {
  final String message;
  final String detail;

  const _DayToyListMessage({
    required this.message,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: UiTokens.spacingXs),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: UiTokens.textSecondary,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayToyListTile extends StatelessWidget {
  final _WeeklyDayToyListItem item;
  final VoidCallback onTap;

  const _DayToyListTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final storageLabel = item.storageLabel;

    return Semantics(
      button: true,
      label:
          l10n.isEn ? 'Open toy ${item.name}' : 'Abrir brinquedo ${item.name}',
      child: Material(
        color: UiTokens.bg,
        borderRadius: BorderRadius.circular(UiTokens.radiusMd),
        child: InkWell(
          key: ValueKey('weekly-day-list-toy-${item.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(UiTokens.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(UiTokens.spacingSm),
            child: Row(
              children: [
                _DayToyListPhoto(item: item),
                const SizedBox(width: UiTokens.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: UiTokens.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.categoryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: UiTokens.actionOrange,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (storageLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          storageLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: UiTokens.textSecondary,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: UiTokens.spacingSm),
                const Icon(
                  Icons.chevron_right,
                  color: UiTokens.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayToyListPhoto extends StatelessWidget {
  final _WeeklyDayToyListItem item;

  const _DayToyListPhoto({required this.item});

  @override
  Widget build(BuildContext context) {
    final path = item.photoPath?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(UiTokens.radiusSm),
      child: SizedBox(
        width: 58,
        height: 58,
        child: path == null || path.isEmpty
            ? const _ToyThumbnailPlaceholder()
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ToyThumbnailPlaceholder(),
              ),
      ),
    );
  }
}

class _WeeklyDayToyListItem {
  final String id;
  final String name;
  final String categoryLabel;
  final String? boxLabel;
  final String? locationLabel;
  final String? photoPath;

  const _WeeklyDayToyListItem({
    required this.id,
    required this.name,
    required this.categoryLabel,
    this.boxLabel,
    this.locationLabel,
    this.photoPath,
  });

  factory _WeeklyDayToyListItem.fromPreview(
    WeeklyPlanningOverviewToyInput toy,
    ToyCatalogItem? catalogItem,
    AppLocalizations l10n,
  ) {
    final sourceToy = catalogItem?.toy;
    final box = catalogItem?.box;
    final category = catalogItem?.category;
    final boxName = _boxLabel(box, l10n);
    final location = l10n
        .value(_cleanText(box?.local) ?? _cleanText(sourceToy?.locationText));

    return _WeeklyDayToyListItem(
      id: toy.id,
      name: l10n.toyDisplayNameForId(
        id: sourceToy?.id ?? toy.id,
        name: _cleanText(sourceToy?.name) ?? _cleanText(toy.name),
      ),
      categoryLabel: l10n.categoryName(
        _cleanText(category?.name) ??
            _fallbackCategoryLabel(
                sourceToy?.categoryId ?? toy.categoryId, l10n),
      ),
      boxLabel: boxName,
      locationLabel: location.isEmpty ? null : location,
      photoPath: _cleanText(sourceToy?.photoPath) ?? _cleanText(toy.photoPath),
    );
  }

  String? get storageLabel {
    final box = _cleanText(boxLabel);
    final location = _cleanText(locationLabel);
    if (box != null && location != null && box != location) {
      return '$box · $location';
    }
    return box ?? location;
  }
}

class _InlineNotice extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InlineNotice({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: UiTokens.warning),
        const SizedBox(width: UiTokens.spacingXs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: UiTokens.textSecondary,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }
}

class _EditButtonBar extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditButtonBar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        UiTokens.spacingMd,
        UiTokens.spacingSm,
        UiTokens.spacingMd,
        UiTokens.spacingMd,
      ),
      decoration: BoxDecoration(
        color: _WeeklyIpadPalette.bg,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.edit_calendar_outlined),
          label: Text(l10n.editSchedule),
          style: FilledButton.styleFrom(
            backgroundColor: UiTokens.actionOrange,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            textStyle: UiTokens.textButton.copyWith(
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewMessage extends StatelessWidget {
  final String title;
  final String message;

  const _OverviewMessage({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      children: [
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

WeeklyPlanningOverviewToyInput _toyToPreview(Toy toy) {
  return WeeklyPlanningOverviewToyInput(
    id: toy.id,
    name: toy.name,
    categoryId: toy.categoryId,
    boxId: toy.boxId,
    photoPath: toy.photoPath,
  );
}

String _openToySemanticLabel(
  WeeklyPlanningOverviewToyInput toy,
  AppLocalizations l10n,
) {
  final name = l10n.toyDisplayNameForId(id: toy.id, name: toy.name);
  return l10n.isEn ? 'Open toy $name' : 'Abrir brinquedo $name';
}

String _openDayToysSemanticLabel(
  WeeklyPlanningDayOverview day,
  AppLocalizations l10n,
) {
  final countLabel = l10n.toysCount(day.total);
  final weekday = DateFormat.EEEE(l10n.dateLocale).format(day.date);
  return l10n.isEn
      ? 'View $countLabel for $weekday'
      : 'Ver $countLabel de $weekday';
}

String _dayListTitle(WeeklyPlanningDayOverview day, AppLocalizations l10n) {
  return '${DateFormat.EEEE(l10n.dateLocale).format(day.date)}, ${DateFormat.yMd(l10n.dateLocale).format(day.date)}';
}

String _scheduledToyCountLabel(int count, AppLocalizations l10n) {
  return l10n.plannedToyCount(count);
}

String? _cleanText(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

String? _boxLabel(Boxe? box, AppLocalizations l10n) {
  if (box == null) return null;
  if (box.number > 0) return l10n.boxNumber(box.number);
  final name = _cleanText(box.name);
  if (name != null) return l10n.value(name);
  return null;
}

String _fallbackCategoryLabel(String categoryId, AppLocalizations l10n) {
  final normalized = categoryId.trim();
  if (normalized.isEmpty) return l10n.noCategory;
  final fallback = normalized
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
  return l10n.categoryName(fallback);
}

WeeklyPlanningOverview _overviewWithTodayVisualCount(
  WeeklyPlanningOverview overview, {
  required List<WeeklyPlanningOverviewToyInput> todayToys,
}) {
  var replacedToday = false;
  final today = DateTime.now();
  final days = overview.days.map((day) {
    if (!_isSameDate(day.date, today)) return day;

    replacedToday = true;
    return WeeklyPlanningDayOverview(
      date: day.date,
      weekday: day.weekday,
      weekdayLabel: day.weekdayLabel,
      toys: todayToys,
      total: todayToys.length,
      isDefaultConfig: day.isDefaultConfig,
      isCustomConfig: day.isCustomConfig,
    );
  }).toList(growable: false);

  if (!replacedToday) return overview;

  final totalToysInWeek = days.fold<int>(0, (total, day) => total + day.total);
  final boxesInUse = <String>{};
  for (final day in days) {
    for (final toy in day.toys) {
      final boxId = toy.boxId?.trim();
      if (boxId != null && boxId.isNotEmpty) {
        boxesInUse.add(boxId);
      }
    }
  }

  return WeeklyPlanningOverview(
    planningEnabled: overview.planningEnabled,
    totalToysInWeek: totalToysInWeek,
    averagePerDay: days.isEmpty ? 0 : totalToysInWeek / days.length,
    boxesInUse: boxesInUse.length,
    categoryDistribution: overview.categoryDistribution,
    days: days,
  );
}

bool _hasIncludedQuota(List<WeeklyPlanningCategoryConfig> categories) {
  return categories.any((category) {
    return category.isIncluded && category.safeQuota > 0;
  });
}

IconData _iconForCategory(String categoryId) {
  switch (categoryId) {
    case 'corpo':
    case 'movimento':
      return Icons.directions_run_outlined;
    case 'exploracao':
    case 'coordenacao':
      return Icons.back_hand_outlined;
    case 'maos':
    case 'construcao':
      return Icons.extension_outlined;
    case 'imaginacao':
    case 'faz_de_conta':
      return Icons.theater_comedy_outlined;
    case 'comunicacao':
    case 'livros':
      return Icons.menu_book_outlined;
    case 'arte_musica':
      return Icons.music_note_outlined;
    default:
      return Icons.category_outlined;
  }
}

String _formatAverage(double value, AppLocalizations l10n) {
  if (value == value.roundToDouble()) return '${value.round()}';
  final formatted = value.toStringAsFixed(1);
  return l10n.isEn ? formatted : formatted.replaceAll('.', ',');
}

_FigmaDayStatus _figmaStatusFor(
  WeeklyPlanningDayOverview day,
  AppLocalizations l10n,
) {
  if (_isSameDate(day.date, DateTime.now())) {
    return _FigmaDayStatus(
      label: l10n.today,
      foreground: const Color(0xFFEA580C),
      background: _FigmaPlanningPalette.orangeLight,
      border: _FigmaPlanningPalette.orangeBorder,
      today: true,
    );
  }

  if (day.total > 0) {
    return _FigmaDayStatus(
      label: l10n.planned,
      foreground: const Color(0xFF1D4ED8),
      background: const Color(0xFFEFF6FF),
      border: const Color(0xFFBFDBFE),
    );
  }

  return _FigmaDayStatus(
    label: l10n.toPlan,
    foreground: const Color(0xFF78716C),
    background: const Color(0xFFF5F5F4),
    border: const Color(0xFFE7E5E4),
  );
}

_FigmaVisualStyle _figmaCategoryStyle(int index) {
  const styles = [
    _FigmaVisualStyle(
      foreground: Color(0xFF5B21B6),
      background: Color(0xFFF5F3FF),
      border: Color(0xFFDDD6FE),
    ),
    _FigmaVisualStyle(
      foreground: Color(0xFF92400E),
      background: Color(0xFFFFFBEB),
      border: Color(0xFFFDE68A),
    ),
    _FigmaVisualStyle(
      foreground: Color(0xFF1D4ED8),
      background: Color(0xFFEFF6FF),
      border: Color(0xFFBFDBFE),
    ),
    _FigmaVisualStyle(
      foreground: Color(0xFFBE123C),
      background: Color(0xFFFFF1F2),
      border: Color(0xFFFECDD3),
    ),
    _FigmaVisualStyle(
      foreground: Color(0xFF9A5A1E),
      background: Color(0xFFFFFBF6),
      border: Color(0xFFF3E2D0),
    ),
  ];

  return styles[index % styles.length];
}

String _weekRangeLabel(
  List<WeeklyPlanningDayOverview> days,
  AppLocalizations l10n,
) {
  if (days.isEmpty) return l10n.currentWeek;
  final start = days.first.date;
  final end = days.last.date;

  if (start.month == end.month && start.year == end.year) {
    final month = _monthName(end.month, l10n);
    return l10n.isEn
        ? '$month ${start.day}-${end.day}, ${end.year}'
        : '${start.day} a ${end.day} de $month de ${end.year}';
  }

  final startMonth = _shortMonth(start.month, l10n);
  final endMonth = _shortMonth(end.month, l10n);
  return l10n.isEn
      ? '$startMonth ${start.day} to $endMonth ${end.day}, ${end.year}'
      : '${start.day} $startMonth a ${end.day} $endMonth de ${end.year}';
}

String _weekdayAbbr(int weekday, AppLocalizations l10n) {
  if (l10n.isEn) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return 'Day';
    }
  }

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
      return 'Sáb';
    case DateTime.sunday:
      return 'Dom';
    default:
      return 'Dia';
  }
}

String _shortMonth(int month, AppLocalizations l10n) {
  if (l10n.isEn) {
    return DateFormat.MMM(l10n.dateLocale).format(DateTime(2026, month));
  }

  switch (month) {
    case DateTime.january:
      return 'jan';
    case DateTime.february:
      return 'fev';
    case DateTime.march:
      return 'mar';
    case DateTime.april:
      return 'abr';
    case DateTime.may:
      return 'mai';
    case DateTime.june:
      return 'jun';
    case DateTime.july:
      return 'jul';
    case DateTime.august:
      return 'ago';
    case DateTime.september:
      return 'set';
    case DateTime.october:
      return 'out';
    case DateTime.november:
      return 'nov';
    case DateTime.december:
      return 'dez';
    default:
      return '';
  }
}

String _monthName(int month, AppLocalizations l10n) {
  if (l10n.isEn) {
    return DateFormat.MMMM(l10n.dateLocale).format(DateTime(2026, month));
  }

  switch (month) {
    case DateTime.january:
      return 'janeiro';
    case DateTime.february:
      return 'fevereiro';
    case DateTime.march:
      return 'março';
    case DateTime.april:
      return 'abril';
    case DateTime.may:
      return 'maio';
    case DateTime.june:
      return 'junho';
    case DateTime.july:
      return 'julho';
    case DateTime.august:
      return 'agosto';
    case DateTime.september:
      return 'setembro';
    case DateTime.october:
      return 'outubro';
    case DateTime.november:
      return 'novembro';
    case DateTime.december:
      return 'dezembro';
    default:
      return '';
  }
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class _PlanningPill extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  const _PlanningPill({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.2),
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

class _WeeklyIpadPalette {
  _WeeklyIpadPalette._();

  static const Color bg = Color(0xFFFDF7F0);
  static const Color text = Color(0xFF25180A);
  static const Color textMid = Color(0xFF6B4F30);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeSoft = Color(0xFFFFF5E8);
  static const Color orangeBorder = Color(0xFFFDDCBA);
}

class _FigmaPlanningPalette {
  _FigmaPlanningPalette._();

  static const Color bg = Color(0xFFFDF7F0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFF5E8);
  static const Color orangeBorder = Color(0xFFFDDCBA);
  static const Color warmAccent = Color(0xFF9A5A1E);
  static const Color warmLight = Color(0xFFFFFBF6);
  static const Color warmBorder = Color(0xFFF3E2D0);
  static const Color text = Color(0xFF25180A);
  static const Color textMid = Color(0xFF6B4F30);
  static const Color textMuted = Color(0xFFA8896A);
  static const Color border = Color(0x1FB98750);
}
