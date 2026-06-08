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
      backgroundColor: UiTokens.bg,
      appBar: AppBar(
        title: const Text('Planejamento semanal'),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                  );
                },
              ),
            ),
            _EditButtonBar(onPressed: _openEditor),
          ],
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
        final isWide = constraints.maxWidth >= 700;
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            UiTokens.spacingMd,
            UiTokens.spacingMd,
            UiTokens.spacingMd,
            UiTokens.spacingLg,
          ),
          children: [
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
            ),
          ],
        );
      },
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
      constraints: const BoxConstraints(minWidth: 148, maxWidth: 240),
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

  const _WeekScheduleCard({
    required this.overview,
    required this.onOpenEditor,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingLg),
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
          width: 42,
          height: 42,
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
      width: 42,
      height: 42,
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
        color: UiTokens.bg,
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
