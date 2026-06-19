import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/weekly_planning/weekly_planning_overview.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/weekly_planning_page.dart';

class WeeklyPlanningOverviewPage extends StatefulWidget {
  final SettingsRepository settingsRepository;
  final WeeklyPlanningRepository weeklyPlanningRepository;
  final RoundRepository roundRepository;

  const WeeklyPlanningOverviewPage({
    super.key,
    required this.settingsRepository,
    required this.weeklyPlanningRepository,
    required this.roundRepository,
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

    final days = <WeeklyPlanningOverviewDayInput>[];
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final date = weekStart.add(Duration(days: weekday - 1));
      final dayConfig = dayConfigByWeekday[weekday];
      final effectiveCategories =
          await widget.weeklyPlanningRepository.resolveCategoryConfigForDate(
        date,
      );
      final toys = await widget.roundRepository.suggestRoundForDate(date);
      final customConfigIsEffective = planningEnabled &&
          dayConfig != null &&
          !dayConfig.useDefault &&
          _hasIncludedQuota(dayConfig.categories);

      days.add(
        WeeklyPlanningOverviewDayInput(
          date: date,
          weekday: weekday,
          weekdayLabel: weeklyPlanningWeekdayLabel(weekday),
          categories: effectiveCategories
              .map(
                (category) => WeeklyPlanningOverviewCategoryInput(
                  categoryId: category.categoryId,
                  categoryName: category.categoryName,
                  isIncluded: category.isIncluded,
                  quota: category.safeQuota,
                ),
              )
              .toList(growable: false),
          toys: toys.map(_toyToPreview).toList(growable: false),
          isDefaultConfig: !customConfigIsEffective,
          isCustomConfig: customConfigIsEffective,
        ),
      );
    }

    return buildWeeklyPlanningOverview(
      planningEnabled: planningEnabled,
      days: days,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FigmaPlanningPalette.bg,
      appBar: AppBar(
        backgroundColor: _FigmaPlanningPalette.bg,
        title: const Text('Planejamento semanal'),
      ),
      body: SafeArea(
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
            );
          },
        ),
      ),
    );
  }
}

class _OverviewContent extends StatelessWidget {
  final WeeklyPlanningOverview overview;
  final VoidCallback onOpenEditor;

  const _OverviewContent({
    required this.overview,
    required this.onOpenEditor,
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
                onOpenEditor: onOpenEditor,
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
                  'RODÍZIO DE BRINQUEDOS',
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
                  'Planejamento semanal',
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
                      ? 'Veja a organização dos brinquedos para os próximos dias.'
                      : 'Ative a programação para personalizar os próximos dias.',
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
                label: 'Editar programação',
                icon: Icons.shuffle_rounded,
                primary: true,
                onTap: onOpenEditor,
              ),
              const SizedBox(width: 10),
              _FigmaHeaderButton(
                label: 'Ajustar categorias',
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
  final VoidCallback onOpenEditor;

  const _FigmaWeekPlanCard({
    required this.overview,
    required this.onOpenEditor,
  });

  @override
  Widget build(BuildContext context) {
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
                        'Semana atual',
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
                        '${_weekRangeLabel(overview.days)} · $readyDays dias planejados',
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
                  label: '$readyDays de ${overview.days.length} dias prontos',
                  foreground: const Color(0xFF065F46),
                  background: const Color(0xFFECFDF5),
                  border: const Color(0xFFA7F3D0),
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
                        onTap: onOpenEditor,
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
  final VoidCallback onTap;

  const _FigmaDayPlanRow({
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _figmaStatusFor(day);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                      _weekdayAbbr(day.weekday),
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
                      '${day.date.day} ${_shortMonth(day.date.month)}',
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
                      day.total == 1
                          ? '1 brinquedo'
                          : '${day.total} brinquedos',
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
                child: _FigmaToyStack(day: day),
              ),
              const SizedBox(width: 8),
              Text(
                day.total == 1 ? '1 item' : '${day.total} itens',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textMicro.copyWith(
                  color: _FigmaPlanningPalette.textMuted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: status.today
                    ? _FigmaPlanningPalette.orange
                    : _FigmaPlanningPalette.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FigmaToyStack extends StatelessWidget {
  final WeeklyPlanningDayOverview day;

  const _FigmaToyStack({required this.day});

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
              child: _FigmaToyAvatar(toy: visible[index]),
            ),
          if (overflow > 0)
            Positioned(
              left: visible.length * 23,
              top: 1,
              child: _FigmaOverflowAvatar(count: overflow),
            ),
        ],
      ),
    );
  }
}

class _FigmaToyAvatar extends StatelessWidget {
  final WeeklyPlanningOverviewToyInput toy;

  const _FigmaToyAvatar({required this.toy});

  @override
  Widget build(BuildContext context) {
    final path = toy.photoPath?.trim();

    return Tooltip(
      message: toy.name.trim().isEmpty ? 'Brinquedo' : toy.name.trim(),
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

  const _FigmaOverflowAvatar({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _FigmaWeekFooter extends StatelessWidget {
  final WeeklyPlanningOverview overview;

  const _FigmaWeekFooter({required this.overview});

  @override
  Widget build(BuildContext context) {
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
                text: 'Total da semana: ',
                children: [
                  TextSpan(
                    text: '${overview.totalToysInWeek} brinquedos programados',
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
              color: const Color(0xFF065F46),
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
    final stats = [
      _FigmaStatData(
        value: '${overview.totalToysInWeek}',
        label: 'brinquedos na semana',
        foreground: _FigmaPlanningPalette.orange,
        background: _FigmaPlanningPalette.orangeLight,
        border: _FigmaPlanningPalette.orangeBorder,
      ),
      _FigmaStatData(
        value: _formatAverage(overview.averagePerDay),
        label: 'média por dia',
        foreground: const Color(0xFF8B5CF6),
        background: const Color(0xFFF5F3FF),
        border: const Color(0xFFDDD6FE),
      ),
      _FigmaStatData(
        value: '${overview.categoryDistribution.length}',
        label: 'categorias equilibradas',
        foreground: const Color(0xFF059669),
        background: const Color(0xFFECFDF5),
        border: const Color(0xFFA7F3D0),
      ),
    ];

    return _FigmaSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FigmaSideCardTitle(
            title: 'Resumo da semana',
            subtitle: 'Visão consolidada do período',
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
            width: 42,
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
    final items = overview.categoryDistribution;

    return _FigmaSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FigmaSideCardTitle(
            title: 'Categorias da semana',
            subtitle: 'Distribuição por tipo de brincadeira',
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text(
              'Inclua pelo menos uma categoria para ver a distribuição.',
              style: UiTokens.textMicro.copyWith(
                color: _FigmaPlanningPalette.textMuted,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            for (var index = 0; index < items.length; index++) ...[
              _FigmaCategoryProgressRow(
                item: items[index],
                total: overview.totalToysInWeek,
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
                item.categoryName,
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
              '${item.total} brinq.',
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
    final actions = [
      _FigmaActionData(
        label: 'Editar programação',
        icon: Icons.edit_calendar_outlined,
        foreground: _FigmaPlanningPalette.orange,
        background: _FigmaPlanningPalette.orangeLight,
        onTap: onOpenEditor,
      ),
      _FigmaActionData(
        label: 'Ajustar categorias',
        icon: Icons.tune_rounded,
        foreground: const Color(0xFF8B5CF6),
        background: const Color(0xFFF5F3FF),
        onTap: onOpenEditor,
      ),
      _FigmaActionData(
        label: 'Revisar cotas',
        icon: Icons.rule_rounded,
        foreground: const Color(0xFF059669),
        background: const Color(0xFFECFDF5),
        onTap: onOpenEditor,
      ),
    ];

    return _FigmaSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações rápidas',
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
                  _weekRangeLabel(overview.days),
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
                label:
                    '${overview.days.where((day) => day.total > 0).length} de ${overview.days.length} dias',
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

  const _CompactPlanningLayout({
    required this.overview,
    required this.onOpenEditor,
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
          onOpenEditor: onOpenEditor,
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
    final title = overview.planningEnabled
        ? 'Planeje a semana sem improviso'
        : 'Ative o planejamento semanal';
    final subtitle = overview.planningEnabled
        ? 'Organize quantidades por categoria e veja a semana inteira antes de montar as rodadas.'
        : 'A semana abaixo usa a configuração padrão até você ativar a programação personalizada.';
    final action = FilledButton.icon(
      onPressed: onOpenEditor,
      icon: const Icon(Icons.edit_calendar_outlined),
      label: const Text('Editar programação'),
      style: FilledButton.styleFrom(
        backgroundColor: _WeeklyIpadPalette.green,
        foregroundColor: Colors.white,
        minimumSize: Size(isWide ? 196 : 0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: UiTokens.textButton.copyWith(fontWeight: FontWeight.w800),
        elevation: 2,
        shadowColor: _WeeklyIpadPalette.green.withValues(alpha: 0.26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
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
            Text(
              'Premium',
              maxLines: 1,
              style: UiTokens.textMicro.copyWith(
                color: _WeeklyIpadPalette.orange,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            _PlanningPill(
              label: '$totalLabel nesta semana',
              foreground: _WeeklyIpadPalette.green,
              background: _WeeklyIpadPalette.greenSoft,
              border: _WeeklyIpadPalette.greenBorder,
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
    return AppSurfaceCard(
      color: UiTokens.primarySoft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: UiTokens.primaryStrong),
          const SizedBox(width: UiTokens.spacingSm),
          Expanded(
            child: Text(
              'Planejamento semanal desativado. A semana abaixo usa a configuração padrão até você ativar a programação.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: UiTokens.textSecondary,
                    height: 1.35,
                  ),
            ),
          ),
          const SizedBox(width: UiTokens.spacingSm),
          TextButton(
            onPressed: onOpenEditor,
            child: const Text('Configurar'),
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
    final metrics = [
      _MetricData(
        icon: Icons.toys_outlined,
        label: 'brinquedos na semana',
        value: '${overview.totalToysInWeek}',
      ),
      _MetricData(
        icon: Icons.calendar_today_outlined,
        label: 'média por dia',
        value: _formatAverage(overview.averagePerDay),
      ),
      _MetricData(
        icon: Icons.inventory_2_outlined,
        label: 'caixas em uso',
        value: '${overview.boxesInUse}',
      ),
    ];

    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo da semana',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          Text(
            overview.hasConfiguredToys
                ? 'Totais derivados das quantidades por categoria de cada dia.'
                : 'Nenhuma categoria com quantidade ativa nesta semana.',
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
        color: UiTokens.primarySoft,
        borderRadius: BorderRadius.circular(UiTokens.radiusMd),
        border: Border.all(color: UiTokens.border),
      ),
      child: Row(
        children: [
          Icon(data.icon, color: UiTokens.primaryStrong),
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
                        color: UiTokens.primaryStrong,
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
    final items = overview.categoryDistribution;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribuição por categoria',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          if (items.isEmpty)
            Text(
              'Inclua pelo menos uma categoria para ver a distribuição.',
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
    return Container(
      constraints: const BoxConstraints(minWidth: 142, maxWidth: 250),
      padding: const EdgeInsets.symmetric(
        horizontal: UiTokens.spacingMd,
        vertical: UiTokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(UiTokens.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: UiTokens.primaryStrong),
          const SizedBox(width: UiTokens.spacingSm),
          Flexible(
            child: Text(
              item.categoryName,
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
                  color: UiTokens.primaryStrong,
                ),
          ),
        ],
      ),
    );
  }
}

class _WeekScheduleCard extends StatelessWidget {
  final WeeklyPlanningOverview overview;
  final VoidCallback onOpenEditor;
  final bool isIpad;

  const _WeekScheduleCard({
    required this.overview,
    required this.onOpenEditor,
    required this.isIpad,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: EdgeInsets.all(isIpad ? 26 : UiTokens.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Programação da semana',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          if (!overview.hasConfiguredToys) ...[
            Text(
              'Defina quantidades por categoria para montar a semana.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: UiTokens.textSecondary,
                  ),
            ),
            const SizedBox(height: UiTokens.spacingMd),
          ],
          for (var index = 0; index < overview.days.length; index++) ...[
            _DayScheduleRow(
              day: overview.days[index],
              onTap: onOpenEditor,
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
  final VoidCallback onTap;

  const _DayScheduleRow({
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final maxVisibleToys = constraints.maxWidth >= 760 ? 6 : 4;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UiTokens.radiusMd),
          child: Padding(
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
                          _DayTotalBadge(day: day),
                          const SizedBox(width: UiTokens.spacingXs),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      const SizedBox(height: UiTokens.spacingSm),
                      _ToyThumbnailStrip(
                        toys: day.toys,
                        total: day.total,
                        maxVisible: maxVisibleToys,
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
                        ),
                      ),
                      const SizedBox(width: UiTokens.spacingSm),
                      _DayTotalBadge(day: day),
                      const SizedBox(width: UiTokens.spacingXs),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
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
    final dateLabel = DateFormat('dd/MM', 'pt_BR').format(day.date);
    final configLabel = day.isCustomConfig ? 'Personalizado' : 'Padrão';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day.weekdayLabel,
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

  const _ToyThumbnailStrip({
    required this.toys,
    required this.total,
    required this.maxVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (toys.isEmpty) {
      return Text(
        total == 0
            ? 'Nenhum brinquedo planejado'
            : 'Sem brinquedos suficientes',
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
        for (final toy in visible) _ToyThumbnail(toy: toy),
        if (remaining > 0) _MoreToysBadge(count: remaining),
      ],
    );
  }
}

class _ToyThumbnail extends StatelessWidget {
  final WeeklyPlanningOverviewToyInput toy;

  const _ToyThumbnail({required this.toy});

  @override
  Widget build(BuildContext context) {
    final path = toy.photoPath?.trim();

    return Tooltip(
      message: toy.name.trim().isEmpty ? 'Brinquedo' : toy.name.trim(),
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
    );
  }
}

class _ToyThumbnailPlaceholder extends StatelessWidget {
  const _ToyThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: UiTokens.primarySoft,
      child: const Icon(
        Icons.toys_outlined,
        size: 20,
        color: UiTokens.primaryStrong,
      ),
    );
  }
}

class _MoreToysBadge extends StatelessWidget {
  final int count;

  const _MoreToysBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: UiTokens.secondarySoft,
        borderRadius: BorderRadius.circular(UiTokens.radiusSm),
      ),
      child: Text(
        '+$count',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: UiTokens.primaryStrong,
            ),
      ),
    );
  }
}

class _DayTotalBadge extends StatelessWidget {
  final WeeklyPlanningDayOverview day;

  const _DayTotalBadge({required this.day});

  @override
  Widget build(BuildContext context) {
    final label = day.total == 1 ? '1 item' : '${day.total} itens';

    return Container(
      constraints: const BoxConstraints(minWidth: 70),
      padding: const EdgeInsets.symmetric(
        horizontal: UiTokens.spacingSm,
        vertical: UiTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: day.hasInsufficientToys ? UiTokens.secondarySoft : UiTokens.bg,
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
    );
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
          label: const Text('Editar programação'),
          style: FilledButton.styleFrom(
            backgroundColor: _WeeklyIpadPalette.green,
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

bool _hasIncludedQuota(List<WeeklyPlanningCategoryConfig> categories) {
  return categories.any((category) {
    return category.isIncluded && category.safeQuota > 0;
  });
}

IconData _iconForCategory(String categoryId) {
  switch (categoryId) {
    case 'livros':
      return Icons.menu_book_outlined;
    case 'construcao':
      return Icons.extension_outlined;
    case 'faz_de_conta':
      return Icons.theater_comedy_outlined;
    case 'movimento':
      return Icons.directions_run_outlined;
    case 'coordenacao':
      return Icons.back_hand_outlined;
    case 'arte_musica':
      return Icons.music_note_outlined;
    default:
      return Icons.category_outlined;
  }
}

String _formatAverage(double value) {
  if (value == value.roundToDouble()) return '${value.round()}';
  return value.toStringAsFixed(1).replaceAll('.', ',');
}

_FigmaDayStatus _figmaStatusFor(WeeklyPlanningDayOverview day) {
  if (_isSameDate(day.date, DateTime.now())) {
    return const _FigmaDayStatus(
      label: 'Hoje',
      foreground: Color(0xFFEA580C),
      background: _FigmaPlanningPalette.orangeLight,
      border: _FigmaPlanningPalette.orangeBorder,
      today: true,
    );
  }

  if (day.total > 0) {
    return const _FigmaDayStatus(
      label: 'Planejado',
      foreground: Color(0xFF1D4ED8),
      background: Color(0xFFEFF6FF),
      border: Color(0xFFBFDBFE),
    );
  }

  return const _FigmaDayStatus(
    label: 'A planejar',
    foreground: Color(0xFF78716C),
    background: Color(0xFFF5F5F4),
    border: Color(0xFFE7E5E4),
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
      foreground: Color(0xFF065F46),
      background: Color(0xFFECFDF5),
      border: Color(0xFFA7F3D0),
    ),
  ];

  return styles[index % styles.length];
}

String _weekRangeLabel(List<WeeklyPlanningDayOverview> days) {
  if (days.isEmpty) return 'Semana atual';
  final start = days.first.date;
  final end = days.last.date;

  if (start.month == end.month && start.year == end.year) {
    return '${start.day} a ${end.day} de ${_monthName(end.month)} de ${end.year}';
  }

  return '${start.day} ${_shortMonth(start.month)} a ${end.day} ${_shortMonth(end.month)} de ${end.year}';
}

String _weekdayAbbr(int weekday) {
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

String _shortMonth(int month) {
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

String _monthName(int month) {
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
  static const Color green = Color(0xFF5F806F);
  static const Color greenSoft = Color(0xFFEAF1EC);
  static const Color greenBorder = Color(0xFFD5E1D9);
}

class _FigmaPlanningPalette {
  _FigmaPlanningPalette._();

  static const Color bg = Color(0xFFFDF7F0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFF5E8);
  static const Color orangeBorder = Color(0xFFFDDCBA);
  static const Color text = Color(0xFF25180A);
  static const Color textMid = Color(0xFF6B4F30);
  static const Color textMuted = Color(0xFFA8896A);
  static const Color border = Color(0x1FB98750);
}
