import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/weekly_planning/week_day_summary.dart';
import 'package:rodizio_brinquedos_v3/services/premium_gate.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/weekly_planning_preview_card.dart';
import 'weekly_planning_overview_page.dart';
import 'brinquedos_page.dart' as brinquedos;
import 'caixas_page.dart';
import 'rodada_page.dart';
import 'settings_page.dart';
import 'toy_create_page.dart';

class MainShell extends StatefulWidget {
  final ToyRepository toyRepository;
  final RoundRepository roundRepository;
  final SettingsRepository settingsRepository;
  final PurchaseService purchaseService;

  const MainShell({
    super.key,
    required this.toyRepository,
    required this.roundRepository,
    required this.settingsRepository,
    required this.purchaseService,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _requestedBoxFilterId;
  int _requestedBoxFilterVersion = 0;
  WeeklyPlanningRepository? _weeklyPlanningRepository;
  static const List<String> _titles = <String>[
    'Rod\u00edzio',
    'Brinquedos',
    'Caixas',
  ];

  @override
  void initState() {
    super.initState();
    final db = widget.roundRepository.db;
    if (db != null) {
      _weeklyPlanningRepository = WeeklyPlanningRepository(
        db: db,
        settingsRepository: widget.settingsRepository,
      );
    }
  }

  void _goTo(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  void _openBrinquedosForBox(String boxId) {
    setState(() {
      _requestedBoxFilterId = boxId;
      _requestedBoxFilterVersion++;
      _currentIndex = 1;
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          settingsRepository: widget.settingsRepository,
          toyRepository: widget.toyRepository,
          purchaseService: widget.purchaseService,
        ),
      ),
    );
  }

  Future<void> _openToyCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToyCreatePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
        ),
      ),
    );
  }

  Future<void> _openWeeklyPlanning() async {
    final weeklyPlanningRepository = _weeklyPlanningRepository;
    if (weeklyPlanningRepository == null) return;

    final allowed = await PremiumGate.ensureWeeklyPlanningPremium(
      context: context,
      purchaseService: widget.purchaseService,
    );
    if (!allowed || !mounted) return;

    unawaited(AppAnalytics.logWeeklyPlanningOpened(source: 'home'));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WeeklyPlanningOverviewPage(
          settingsRepository: widget.settingsRepository,
          weeklyPlanningRepository: weeklyPlanningRepository,
          roundRepository: widget.roundRepository,
        ),
      ),
    );
  }

  Widget _buildWeeklyPlanningCard({
    EdgeInsetsGeometry margin = const EdgeInsets.fromLTRB(
      UiTokens.m,
      0,
      UiTokens.m,
      UiTokens.s,
    ),
  }) {
    final weeklyPlanningRepository = _weeklyPlanningRepository;
    if (weeklyPlanningRepository == null) return const SizedBox.shrink();

    return Padding(
      padding: margin,
      child: StreamBuilder<List<WeekDaySummary>>(
        stream: weeklyPlanningRepository.watchWeekSummary(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _WeeklyPlanningPreviewState(
              message: 'Não foi possível carregar o planejamento semanal.',
            );
          }

          final summaries = snapshot.data ?? const <WeekDaySummary>[];
          if (summaries.isEmpty) {
            final waiting = snapshot.connectionState == ConnectionState.waiting;
            return _WeeklyPlanningPreviewState(
              message: waiting
                  ? 'Carregando planejamento semanal...'
                  : 'Nenhum planejamento semanal encontrado.',
            );
          }

          return WeeklyPlanningPreviewCard(
            summaries: summaries,
            onTap: _openWeeklyPlanning,
          );
        },
      ),
    );
  }

  String _currentDatePtBr() {
    return DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(DateTime.now());
  }

  Widget _buildHomeHeader() {
    return _CompactHomeHeader(
      title: 'Hora de brincar',
      dateLabel: _currentDatePtBr(),
      onSettingsTap: _openSettings,
    );
  }

  PreferredSizeWidget _buildStandardAppBar(BuildContext context) {
    return AppBar(
      title: Text(_titles[_currentIndex]),
      actions: [
        IconButton(
          tooltip: 'Configura\u00e7\u00f5es',
          icon: const Icon(Icons.settings_outlined),
          onPressed: _openSettings,
        ),
      ],
    );
  }

  Widget _buildPhoneHome() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHomeHeader(),
          _buildWeeklyPlanningCard(),
          Expanded(
            child: RodadaPage(
              roundRepository: widget.roundRepository,
              toyRepository: widget.toyRepository,
              purchaseService: widget.purchaseService,
              onOpenRodizioTab: () => _goTo(0),
              onOpenBrinquedosTab: () => _goTo(1),
              onOpenSettings: _openSettings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletHome() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          UiTokens.spacingLg,
          UiTokens.spacingSm,
          UiTokens.spacingLg,
          AppBottomNavigation.reservedScrollPadding(context),
        ),
        child: Column(
          children: [
            _TabletHomeHeader(
              dateLabel: _currentDatePtBr(),
              onSettingsTap: _openSettings,
              onNewToyTap: _openToyCreate,
            ),
            const SizedBox(height: UiTokens.spacingMd),
            _HomeMetricsStrip(
              toyRepository: widget.toyRepository,
              roundRepository: widget.roundRepository,
            ),
            const SizedBox(height: UiTokens.spacingMd),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final sideWidth =
                      (constraints.maxWidth * 0.34).clamp(330.0, 430.0);
                  final showCatalogPreview = constraints.maxHeight >= 620;

                  Widget buildRoundPage() {
                    return RodadaPage(
                      roundRepository: widget.roundRepository,
                      toyRepository: widget.toyRepository,
                      purchaseService: widget.purchaseService,
                      onOpenRodizioTab: () => _goTo(0),
                      onOpenBrinquedosTab: () => _goTo(1),
                      onOpenSettings: _openSettings,
                      fillAvailableHeight: true,
                      activeItemsTitle: 'Rodada de hoje',
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: showCatalogPreview
                            ? Column(
                                children: [
                                  Expanded(
                                    flex: 50,
                                    child: buildRoundPage(),
                                  ),
                                  const SizedBox(
                                    height: UiTokens.spacingMd,
                                  ),
                                  Expanded(
                                    flex: 50,
                                    child: _HomeCatalogPreviewCard(
                                      toyRepository: widget.toyRepository,
                                      onCatalog: () => _goTo(1),
                                    ),
                                  ),
                                ],
                              )
                            : buildRoundPage(),
                      ),
                      const SizedBox(width: UiTokens.spacingMd),
                      SizedBox(
                        width: sideWidth.toDouble(),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            bottom: AppBottomNavigation.reservedScrollPadding(
                              context,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildWeeklyPlanningCard(
                                margin: EdgeInsets.zero,
                              ),
                              const SizedBox(height: UiTokens.spacingMd),
                              _QuickActionsCard(
                                onNewToy: _openToyCreate,
                                onCatalog: () => _goTo(1),
                                onWeeklyPlanning: _openWeeklyPlanning,
                                onBoxes: () => _goTo(2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 820) {
          return _buildTabletHome();
        }
        return _buildPhoneHome();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiTokens.bg,
      extendBody: false,
      appBar: _currentIndex == 0 ? null : _buildStandardAppBar(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          brinquedos.BrinquedosPage(
            toyRepository: widget.toyRepository,
            roundRepository: widget.roundRepository,
            settingsRepository: widget.settingsRepository,
            purchaseService: widget.purchaseService,
            onOpenRodizioTab: () => _goTo(0),
            requestedBoxFilterId: _requestedBoxFilterId,
            requestedBoxFilterVersion: _requestedBoxFilterVersion,
          ),
          CaixasPage(
            toyRepository: widget.toyRepository,
            settingsRepository: widget.settingsRepository,
            purchaseService: widget.purchaseService,
            onOpenBrinquedosForBox: _openBrinquedosForBox,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _goTo,
      ),
    );
  }
}

class _WeeklyPlanningPreviewState extends StatelessWidget {
  final String message;

  const _WeeklyPlanningPreviewState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: UiTokens.textSecondary,
            ),
      ),
    );
  }
}

class _TabletHomeHeader extends StatelessWidget {
  final String dateLabel;
  final VoidCallback onSettingsTap;
  final VoidCallback onNewToyTap;

  const _TabletHomeHeader({
    required this.dateLabel,
    required this.onSettingsTap,
    required this.onNewToyTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UiTokens.spacingLg,
        vertical: UiTokens.spacingMd,
      ),
      decoration: BoxDecoration(
        color: UiTokens.primarySoft,
        borderRadius: BorderRadius.circular(UiTokens.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(UiTokens.radiusMd),
              boxShadow: UiTokens.softShadow,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.toys_outlined,
              color: UiTokens.primaryStrong,
              size: 25,
            ),
          ),
          const SizedBox(width: UiTokens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hora de brincar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textTitle.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: UiTokens.spacingXs),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: UiTokens.primaryStrong,
                    ),
                    const SizedBox(width: UiTokens.spacingXs),
                    Flexible(
                      child: Text(
                        dateLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textCaption.copyWith(
                          color: UiTokens.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: UiTokens.spacingMd),
          FilledButton.icon(
            onPressed: onNewToyTap,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Novo brinquedo'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(
                horizontal: UiTokens.spacingMd,
              ),
            ),
          ),
          const SizedBox(width: UiTokens.spacingSm),
          IconButton.filledTonal(
            tooltip: 'Configurações',
            onPressed: onSettingsTap,
            icon: const Icon(Icons.settings_outlined, size: 21),
          ),
        ],
      ),
    );
  }
}

class _HomeMetricsStrip extends StatelessWidget {
  final ToyRepository toyRepository;
  final RoundRepository roundRepository;

  const _HomeMetricsStrip({
    required this.toyRepository,
    required this.roundRepository,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingSm),
      child: Row(
        children: [
          _MetricStreamTile<ToyWithBox>(
            stream: toyRepository.watchAllWithBox(),
            icon: Icons.inventory_2_outlined,
            label: 'Brinquedos',
            valueBuilder: (count) => '$count',
          ),
          _MetricStreamTile<RoundToyWithBox>(
            stream: roundRepository.watchActiveRoundToysWithBox(),
            icon: Icons.today_outlined,
            label: 'Rodada hoje',
            valueBuilder: (count) => '$count',
          ),
          _MetricStreamTile<CategoryDefinition>(
            stream: toyRepository.watchCategories(activeOnly: true),
            icon: Icons.category_outlined,
            label: 'Categorias',
            valueBuilder: (count) => '$count',
          ),
          _MetricStreamTile<Boxe>(
            stream: toyRepository.watchBoxes(),
            icon: Icons.shelves,
            label: 'Caixas',
            valueBuilder: (count) => '$count',
          ),
        ],
      ),
    );
  }
}

class _MetricStreamTile<T> extends StatelessWidget {
  final Stream<List<T>> stream;
  final IconData icon;
  final String label;
  final String Function(int count) valueBuilder;

  const _MetricStreamTile({
    required this.stream,
    required this.icon,
    required this.label,
    required this.valueBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<T>>(
        stream: stream,
        builder: (context, snapshot) {
          final count = snapshot.data?.length;
          return _HomeMetricTile(
            icon: icon,
            label: label,
            value: count == null ? '...' : valueBuilder(count),
          );
        },
      ),
    );
  }
}

class _HomeMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HomeMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(
        horizontal: UiTokens.spacingSm,
        vertical: UiTokens.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: UiTokens.primarySoft,
              borderRadius: BorderRadius.circular(UiTokens.radiusMd),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: UiTokens.primaryStrong),
          ),
          const SizedBox(width: UiTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textSectionTitle.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
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

class _QuickActionsCard extends StatelessWidget {
  final VoidCallback onNewToy;
  final VoidCallback onCatalog;
  final VoidCallback onWeeklyPlanning;
  final VoidCallback onBoxes;

  const _QuickActionsCard({
    required this.onNewToy,
    required this.onCatalog,
    required this.onWeeklyPlanning,
    required this.onBoxes,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acesso rápido',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textSectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 360;
              const spacing = UiTokens.spacingSm;
              final itemWidth = twoColumns
                  ? (constraints.maxWidth - spacing) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _QuickActionButton(
                      icon: Icons.add_rounded,
                      label: 'Novo',
                      onPressed: onNewToy,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _QuickActionButton(
                      icon: Icons.grid_view_rounded,
                      label: 'Catálogo',
                      onPressed: onCatalog,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _QuickActionButton(
                      icon: Icons.calendar_month_outlined,
                      label: 'Planejar',
                      onPressed: onWeeklyPlanning,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _QuickActionButton(
                      icon: Icons.inventory_2_outlined,
                      label: 'Caixas',
                      onPressed: onBoxes,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: UiTokens.spacingSm),
        textStyle: UiTokens.textButton.copyWith(fontSize: 13),
      ),
    );
  }
}

class _HomeCatalogPreviewCard extends StatelessWidget {
  final ToyRepository toyRepository;
  final VoidCallback onCatalog;

  const _HomeCatalogPreviewCard({
    required this.toyRepository,
    required this.onCatalog,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Brinquedos disponíveis',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textSectionTitle.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: UiTokens.spacingSm),
              TextButton.icon(
                onPressed: onCatalog,
                icon: const Icon(Icons.grid_view_rounded, size: 18),
                label: const Text('Ver catálogo'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: UiTokens.textButton.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: UiTokens.spacingSm),
          Expanded(
            child: StreamBuilder<List<ToyWithBox>>(
              stream: toyRepository.watchAllWithBox(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final toys = snapshot.data ?? const <ToyWithBox>[];
                if (toys.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum brinquedo cadastrado.',
                      textAlign: TextAlign.center,
                      style: UiTokens.textCaption.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                final previewItems = toys.take(6).toList(growable: false);
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 620 ? 4 : 3;
                    const spacing = 12.0;
                    final tileWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                            columns;
                    final tileExtent = (tileWidth * 0.86).clamp(132.0, 170.0);

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        mainAxisExtent: tileExtent.toDouble(),
                      ),
                      itemCount: previewItems.length,
                      itemBuilder: (context, index) {
                        return _HomeCatalogToyTile(item: previewItems[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCatalogToyTile extends StatelessWidget {
  final ToyWithBox item;

  const _HomeCatalogToyTile({
    required this.item,
  });

  String _locationLabel() {
    final box = item.box;
    final locationText = (item.toy.locationText ?? '').trim();

    if (box != null) {
      final local = box.local.trim();
      if (local.isEmpty) return 'Caixa ${box.number}';
      return 'Caixa ${box.number} · $local';
    }

    if (locationText.isNotEmpty) return locationText;
    return 'Sem caixa';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name =
        item.toy.name.trim().isEmpty ? 'Sem nome' : item.toy.name.trim();

    return Semantics(
      label: 'Brinquedo $name',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(UiTokens.radiusMd),
          border: Border.all(color: UiTokens.border),
          boxShadow: const [
            BoxShadow(
              color: UiTokens.shadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(UiTokens.spacingXs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _HomeCatalogToyPhoto(imagePath: item.toy.photoPath),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textMicro.copyWith(
                  fontSize: 12,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _locationLabel(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textMicro.copyWith(
                  fontSize: 10.5,
                  height: 1.1,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCatalogToyPhoto extends StatelessWidget {
  final String? imagePath;

  const _HomeCatalogToyPhoto({
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final path = imagePath?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(UiTokens.radiusSm),
      child: SizedBox.expand(
        child: path == null || path.isEmpty
            ? const _HomeCatalogToyPlaceholder()
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const _HomeCatalogToyPlaceholder(),
              ),
      ),
    );
  }
}

class _HomeCatalogToyPlaceholder extends StatelessWidget {
  const _HomeCatalogToyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: UiTokens.primarySoft,
      child: Center(
        child: Icon(
          Icons.toys_outlined,
          size: 28,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _CompactHomeHeader extends StatelessWidget {
  final String title;
  final String dateLabel;
  final VoidCallback onSettingsTap;

  const _CompactHomeHeader({
    required this.title,
    required this.dateLabel,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        UiTokens.spacingMd,
        UiTokens.spacingSm,
        UiTokens.spacingMd,
        UiTokens.spacingSm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: UiTokens.spacingMd,
        vertical: UiTokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: UiTokens.primarySoft,
        borderRadius: BorderRadius.circular(UiTokens.radiusLg),
      ),
      child: Row(
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
                    color: UiTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: UiTokens.spacingXs),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: UiTokens.primaryStrong,
                    ),
                    const SizedBox(width: UiTokens.spacingXs),
                    Flexible(
                      child: Text(
                        dateLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textCaption.copyWith(
                          color: UiTokens.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: UiTokens.spacingSm),
          IconButton.filledTonal(
            tooltip: 'Configurações',
            onPressed: onSettingsTap,
            icon: const Icon(Icons.settings_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}
