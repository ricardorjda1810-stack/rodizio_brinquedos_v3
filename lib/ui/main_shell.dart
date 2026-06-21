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
import 'package:rodizio_brinquedos_v3/domain/child_age/age_preset.dart';
import 'package:rodizio_brinquedos_v3/domain/weekly_planning/week_day_summary.dart';
import 'package:rodizio_brinquedos_v3/services/premium_gate.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/categories_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_category_form_options.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/round_suggestion_sheet.dart';
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
    'Rodada',
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
          onOpenHomeTab: () => _openTopNavigationTab(0),
          onOpenRoundTab: () => _openTopNavigationTab(3),
          onOpenWeeklyPlanning: _openTopNavigationWeeklyPlanning,
          onOpenToysTab: () => _openTopNavigationTab(1),
          onOpenBoxesTab: () => _openTopNavigationTab(2),
        ),
      ),
    );
  }

  Future<void> _openToyCreate() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ToyCreatePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
          onOpenHomeTab: () => _openTopNavigationTab(0),
          onOpenRoundTab: () => _openTopNavigationTab(3),
          onOpenWeeklyPlanning: _openTopNavigationWeeklyPlanning,
          onOpenToysTab: () => _openTopNavigationTab(1),
          onOpenBoxesTab: () => _openTopNavigationTab(2),
          onOpenSettings: _openTopNavigationSettings,
        ),
      ),
    );
  }

  void _openTopNavigationTab(int index) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
    _goTo(index);
  }

  void _openTopNavigationWeeklyPlanning() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_openWeeklyPlanning());
    });
  }

  void _openTopNavigationSettings() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openSettings();
    });
  }

  void _openCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoriesManagePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
        ),
      ),
    );
  }

  void _openToyDetail(String toyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToyDetailPage(
          toyId: toyId,
          toyRepository: widget.toyRepository,
          purchaseService: widget.purchaseService,
          topNavigationIndex: 0,
          onOpenHomeTab: () => _openTopNavigationTab(0),
          onOpenRoundTab: () => _openTopNavigationTab(3),
          onOpenWeeklyPlanning: _openTopNavigationWeeklyPlanning,
          onOpenToysTab: () => _openTopNavigationTab(1),
          onOpenBoxesTab: () => _openTopNavigationTab(2),
          onOpenSettings: _openTopNavigationSettings,
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
          onOpenHomeTab: () => _openTopNavigationTab(0),
          onOpenRoundTab: () => _openTopNavigationTab(3),
          onOpenWeeklyPlanning: () {},
          onOpenToysTab: () => _openTopNavigationTab(1),
          onOpenBoxesTab: () => _openTopNavigationTab(2),
          onOpenSettings: _openTopNavigationSettings,
        ),
      ),
    );
  }

  Widget _buildWeeklyPlanningCard() {
    final weeklyPlanningRepository = _weeklyPlanningRepository;
    if (weeklyPlanningRepository == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(UiTokens.m, 0, UiTokens.m, UiTokens.s),
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

  Widget _buildMobileHomePage() {
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
              onOpenHomeTab: () => _openTopNavigationTab(0),
              onOpenRoundTab: () => _openTopNavigationTab(3),
              onOpenWeeklyPlanning: _openTopNavigationWeeklyPlanning,
              onOpenToysTab: () => _openTopNavigationTab(1),
              onOpenBoxesTab: () => _openTopNavigationTab(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    if (!isTablet) return _buildMobileHomePage();

    return _IpadHomeDashboard(
      roundRepository: widget.roundRepository,
      toyRepository: widget.toyRepository,
      weeklyPlanningRepository: _weeklyPlanningRepository,
      onOpenWeeklyPlanning: _openWeeklyPlanning,
      onOpenNewToy: _openToyCreate,
      onOpenBoxes: () => _goTo(2),
      onOpenCategories: _openCategories,
      onOpenSettings: _openSettings,
      onOpenToy: _openToyDetail,
    );
  }

  Widget _buildRodadaTab(BuildContext context) {
    return ColoredBox(
      color: UiTokens.bg,
      child: SafeArea(
        child: RodadaPage(
          roundRepository: widget.roundRepository,
          toyRepository: widget.toyRepository,
          purchaseService: widget.purchaseService,
          onOpenRodizioTab: () => _goTo(3),
          onOpenBrinquedosTab: () => _goTo(1),
          onOpenSettings: _openSettings,
          onOpenHomeTab: () => _openTopNavigationTab(0),
          onOpenRoundTab: () => _openTopNavigationTab(3),
          onOpenWeeklyPlanning: _openTopNavigationWeeklyPlanning,
          onOpenToysTab: () => _openTopNavigationTab(1),
          onOpenBoxesTab: () => _openTopNavigationTab(2),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildStandardAppBar(
    BuildContext context,
    int currentIndex,
  ) {
    return AppBar(
      title: Text(_titles[currentIndex]),
      actions: [
        IconButton(
          tooltip: 'Configura\u00e7\u00f5es',
          icon: const Icon(Icons.settings_outlined),
          onPressed: _openSettings,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final effectiveIndex = isTablet || _currentIndex <= 2 ? _currentIndex : 0;
    final body = IndexedStack(
      index: effectiveIndex,
      children: [
        _buildHomePage(context),
        brinquedos.BrinquedosPage(
          toyRepository: widget.toyRepository,
          roundRepository: widget.roundRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
          onOpenRodizioTab: () => _goTo(isTablet ? 3 : 0),
          onOpenHomeTab: () => _openTopNavigationTab(0),
          onOpenRoundTab: () => _openTopNavigationTab(3),
          onOpenWeeklyPlanning: _openTopNavigationWeeklyPlanning,
          onOpenToysTab: () => _openTopNavigationTab(1),
          onOpenBoxesTab: () => _openTopNavigationTab(2),
          onOpenSettings: _openTopNavigationSettings,
          requestedBoxFilterId: _requestedBoxFilterId,
          requestedBoxFilterVersion: _requestedBoxFilterVersion,
        ),
        CaixasPage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
          onOpenBrinquedosForBox: _openBrinquedosForBox,
          onOpenHomeTab: () => _openTopNavigationTab(0),
          onOpenRoundTab: () => _openTopNavigationTab(3),
          onOpenWeeklyPlanning: _openTopNavigationWeeklyPlanning,
          onOpenToysTab: () => _openTopNavigationTab(1),
          onOpenBoxesTab: () => _openTopNavigationTab(2),
          onOpenSettings: _openTopNavigationSettings,
        ),
        _buildRodadaTab(context),
      ],
    );

    if (isTablet) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF7F0),
        extendBody: false,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  UiTokens.spacingLg,
                  UiTokens.spacingSm,
                  UiTokens.spacingLg,
                  UiTokens.spacingSm,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1032),
                    child: AppTopNavigation(
                      currentIndex: effectiveIndex,
                      onHomeTap: () => _goTo(0),
                      onRoundTap: () => _goTo(3),
                      onWeeklyPlanningTap: _openWeeklyPlanning,
                      onToysTap: () => _goTo(1),
                      onBoxesTap: () => _goTo(2),
                      onSettingsTap: _openSettings,
                    ),
                  ),
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: UiTokens.bg,
      extendBody: false,
      appBar: effectiveIndex == 0
          ? null
          : _buildStandardAppBar(context, effectiveIndex),
      body: body,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: effectiveIndex,
        onTap: _goTo,
      ),
    );
  }
}

class _WeeklyPlanningPreviewState extends StatelessWidget {
  final String message;

  const _WeeklyPlanningPreviewState({required this.message});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: UiTokens.textSecondary),
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
        color: const Color(0xFFFFF5E8),
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
                      color: Color(0xFFF97316),
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

class _IpadHomeDashboard extends StatefulWidget {
  final RoundRepository roundRepository;
  final ToyRepository toyRepository;
  final WeeklyPlanningRepository? weeklyPlanningRepository;
  final VoidCallback onOpenWeeklyPlanning;
  final VoidCallback onOpenNewToy;
  final VoidCallback onOpenBoxes;
  final VoidCallback onOpenCategories;
  final VoidCallback onOpenSettings;
  final ValueChanged<String> onOpenToy;

  const _IpadHomeDashboard({
    required this.roundRepository,
    required this.toyRepository,
    required this.weeklyPlanningRepository,
    required this.onOpenWeeklyPlanning,
    required this.onOpenNewToy,
    required this.onOpenBoxes,
    required this.onOpenCategories,
    required this.onOpenSettings,
    required this.onOpenToy,
  });

  @override
  State<_IpadHomeDashboard> createState() => _IpadHomeDashboardState();
}

class _IpadHomeDashboardState extends State<_IpadHomeDashboard> {
  bool _loadingSuggestion = false;
  bool _startingRound = false;
  Future<List<RoundToyWithBox>>? _suggestionFuture;

  Future<List<RoundToyWithBox>> _loadHomeSuggestion() async {
    final toys = await widget.roundRepository.suggestRoundForToday();
    final boxes = await widget.toyRepository.watchBoxes().first;
    final boxesById = {for (final box in boxes) box.id: box};

    return toys.asMap().entries.map((entry) {
      final toy = entry.value;
      final boxId = toy.boxId;
      return RoundToyWithBox(
        toy: toy,
        box: boxId == null ? null : boxesById[boxId],
        position: entry.key,
      );
    }).toList(growable: false);
  }

  Future<void> _openRoundSuggestionSheet() async {
    if (_loadingSuggestion) return;

    setState(() => _loadingSuggestion = true);
    try {
      final categories =
          await widget.toyRepository.watchCategories(activeOnly: true).first;
      final categoryNamesById = <String, String>{
        for (final category in categories)
          category.id: _categoryDisplayName(category.id, category),
      };
      final suggestedToys = await widget.roundRepository.suggestRoundForToday();
      final boxes = await widget.toyRepository.watchBoxes().first;
      if (!mounted) return;

      unawaited(AppAnalytics.logSuggestionOpened(source: 'home_ipad'));
      final selectedToys = await showModalBottomSheet<List<Toy>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => RoundSuggestionSheet(
          toys: suggestedToys,
          categoryNamesById: categoryNamesById,
          boxesById: {for (final box in boxes) box.id: box},
        ),
      );
      if (selectedToys == null || selectedToys.isEmpty) return;

      await widget.roundRepository.setActiveRoundFromToyIds(
        selectedToys.map((toy) => toy.id).toList(growable: false),
      );
      await AppAnalytics.logSuggestionUsed(
        toyCount: selectedToys.length,
        source: 'home_ipad',
      );
      await AppAnalytics.logRoundCreated(
        toyCount: selectedToys.length,
        source: 'home_ipad_suggestion',
      );
      if (!mounted) return;

      setState(() => _suggestionFuture = _loadHomeSuggestion());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rodada atualizada com ${selectedToys.length} brinquedos.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível montar o rodízio: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingSuggestion = false);
      }
    }
  }

  Future<void> _startRound(List<RoundToyWithBox> selection) async {
    if (_startingRound) return;

    setState(() => _startingRound = true);
    try {
      final toyIds = selection
          .map((item) => item.toy.id)
          .where((id) => id.trim().isNotEmpty)
          .toList(growable: false);
      if (toyIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastre brinquedos para iniciar a rodada.'),
          ),
        );
        return;
      }

      await widget.roundRepository.setActiveRoundFromToyIds(toyIds);
      await AppAnalytics.logSuggestionUsed(
        toyCount: toyIds.length,
        source: 'home_ipad',
      );
      await AppAnalytics.logRoundCreated(
        toyCount: toyIds.length,
        source: 'home_ipad_start',
      );
      if (!mounted) return;

      setState(() => _suggestionFuture = _loadHomeSuggestion());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rodada pronta com ${toyIds.length} brinquedos.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível iniciar a rodada: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _startingRound = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _IpadHomePalette.bg,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth >= 980 ? UiTokens.spacingLg : 18.0;
            final verticalPadding =
                constraints.maxHeight >= 900 ? UiTokens.spacingMd : 12.0;
            final gap = constraints.maxWidth >= 900 ? 18.0 : 14.0;
            final rightWidth = (constraints.maxWidth * 0.40).clamp(
              306.0,
              390.0,
            );

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding,
              ),
              child: Column(
                children: [
                  _IpadHomeHeader(
                    loadingSuggestion: _loadingSuggestion,
                    onBuildRound: _openRoundSuggestionSheet,
                    onOpenNewToy: widget.onOpenNewToy,
                  ),
                  SizedBox(height: gap),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _IpadRoundTodayCard(
                            activeStream: widget.roundRepository
                                .watchActiveRoundToysWithBox(),
                            categoriesStream: widget.toyRepository
                                .watchCategories(activeOnly: true),
                            suggestionFuture: _suggestionFuture ??=
                                _loadHomeSuggestion(),
                            startingRound: _startingRound,
                            onStartRound: _startRound,
                            onOpenToy: widget.onOpenToy,
                          ),
                        ),
                        SizedBox(width: gap),
                        SizedBox(
                          width: rightWidth,
                          child: _IpadRightColumn(
                            toyRepository: widget.toyRepository,
                            weeklyPlanningRepository:
                                widget.weeklyPlanningRepository,
                            onOpenWeeklyPlanning: widget.onOpenWeeklyPlanning,
                            onOpenNewToy: widget.onOpenNewToy,
                            onOpenBoxes: widget.onOpenBoxes,
                            onOpenCategories: widget.onOpenCategories,
                            onOpenSettings: widget.onOpenSettings,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IpadHomeHeader extends StatelessWidget {
  final bool loadingSuggestion;
  final VoidCallback onBuildRound;
  final VoidCallback onOpenNewToy;

  const _IpadHomeHeader({
    required this.loadingSuggestion,
    required this.onBuildRound,
    required this.onOpenNewToy,
  });

  @override
  Widget build(BuildContext context) {
    return _IpadPanelSurface(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_IpadHomePalette.orange, Color(0xFFFBBF24)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4DF97316),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.toys_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RODÍZIO DE BRINQUEDOS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _IpadHomePalette.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Organize a brincadeira de hoje',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textTitle.copyWith(
                    color: _IpadHomePalette.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monte uma rodada equilibrada e mantenha os brinquedos em movimento.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _IpadHomePalette.textMuted,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: loadingSuggestion ? null : onBuildRound,
                icon: loadingSuggestion
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shuffle_rounded, size: 18),
                label: const Text('Montar rodízio'),
                style: FilledButton.styleFrom(
                  backgroundColor: _IpadHomePalette.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(152, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  textStyle: UiTokens.textButton.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  elevation: 4,
                  shadowColor: const Color(0x59F97316),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onOpenNewToy,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Novo brinquedo'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _IpadHomePalette.orangeLight,
                  foregroundColor: const Color(0xFFC2410C),
                  side: const BorderSide(
                    color: _IpadHomePalette.orangeBorder,
                    width: 1.5,
                  ),
                  minimumSize: const Size(156, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  textStyle: UiTokens.textButton.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IpadRoundTodayCard extends StatelessWidget {
  final Stream<List<RoundToyWithBox>> activeStream;
  final Stream<List<CategoryDefinition>> categoriesStream;
  final Future<List<RoundToyWithBox>> suggestionFuture;
  final bool startingRound;
  final Future<void> Function(List<RoundToyWithBox> selection) onStartRound;
  final ValueChanged<String> onOpenToy;

  const _IpadRoundTodayCard({
    required this.activeStream,
    required this.categoriesStream,
    required this.suggestionFuture,
    required this.startingRound,
    required this.onStartRound,
    required this.onOpenToy,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryDefinition>>(
      stream: categoriesStream,
      builder: (context, categoriesSnapshot) {
        final categories =
            categoriesSnapshot.data ?? const <CategoryDefinition>[];
        final categoriesById = {
          for (final category in categories) category.id: category,
        };

        return StreamBuilder<List<RoundToyWithBox>>(
          stream: activeStream,
          builder: (context, activeSnapshot) {
            final activeItems =
                activeSnapshot.data ?? const <RoundToyWithBox>[];

            if (activeItems.isNotEmpty) {
              return _IpadRoundTodayContent(
                items: activeItems,
                categoriesById: categoriesById,
                isSuggestion: false,
                loading: false,
                startingRound: startingRound,
                onStartRound: onStartRound,
                onOpenToy: onOpenToy,
              );
            }

            return FutureBuilder<List<RoundToyWithBox>>(
              future: suggestionFuture,
              builder: (context, suggestionSnapshot) {
                final suggestion =
                    suggestionSnapshot.data ?? const <RoundToyWithBox>[];
                final loading = suggestionSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    suggestion.isEmpty;

                return _IpadRoundTodayContent(
                  items: suggestion,
                  categoriesById: categoriesById,
                  isSuggestion: true,
                  loading: loading,
                  startingRound: startingRound,
                  onStartRound: onStartRound,
                  onOpenToy: onOpenToy,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _IpadRoundTodayContent extends StatelessWidget {
  final List<RoundToyWithBox> items;
  final Map<String, CategoryDefinition> categoriesById;
  final bool isSuggestion;
  final bool loading;
  final bool startingRound;
  final Future<void> Function(List<RoundToyWithBox> selection) onStartRound;
  final ValueChanged<String> onOpenToy;

  const _IpadRoundTodayContent({
    required this.items,
    required this.categoriesById,
    required this.isSuggestion,
    required this.loading,
    required this.startingRound,
    required this.onStartRound,
    required this.onOpenToy,
  });

  @override
  Widget build(BuildContext context) {
    final countLabel =
        items.length == 1 ? '1 brinquedo' : '${items.length} brinquedos';
    final ready = items.isNotEmpty && !loading;
    final visibleItems = items.take(6).toList(growable: false);

    return _IpadPanelSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 20, 26, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          Text(
                            'Rodada de hoje',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: UiTokens.textSectionTitle.copyWith(
                              color: _IpadHomePalette.text,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          _IpadPill(
                            label: loading ? 'carregando' : countLabel,
                            background: _IpadHomePalette.orangeLight,
                            foreground: const Color(0xFFEA580C),
                            border: _IpadHomePalette.orangeBorder,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSuggestion
                            ? 'Hoje · Sugestão equilibrada'
                            : 'Hoje · Rodada pronta para brincar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textCaption.copyWith(
                          color: _IpadHomePalette.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _IpadRoundStatus(ready: ready),
              ],
            ),
          ),
          const Divider(height: 1, color: _IpadHomePalette.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 20, 26, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gridGap = constraints.maxWidth >= 520 ? 13.0 : 10.0;
                final tileWidth = (constraints.maxWidth - (gridGap * 2)) / 3;
                final photoHeight = (tileWidth * 0.70).clamp(92.0, 130.0);
                final tileHeight = photoHeight + 78;
                final gridHeight = (tileHeight * 2) + gridGap;

                if (loading) {
                  return SizedBox(
                    height: gridHeight,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (visibleItems.isEmpty) {
                  return SizedBox(
                    height: gridHeight,
                    child: Center(
                      child: Text(
                        'Cadastre brinquedos para montar a rodada de hoje.',
                        textAlign: TextAlign.center,
                        style: UiTokens.textBody.copyWith(
                          color: _IpadHomePalette.textMuted,
                        ),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: gridHeight,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: gridGap,
                      mainAxisSpacing: gridGap,
                      mainAxisExtent: tileHeight,
                    ),
                    itemCount: visibleItems.length,
                    itemBuilder: (context, index) {
                      final item = visibleItems[index];
                      final category = categoriesById[item.toy.categoryId];
                      return _IpadToyTile(
                        item: item,
                        categoryLabel: _categoryDisplayName(
                          item.toy.categoryId,
                          category,
                        ),
                        onTap: () => onOpenToy(item.toy.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 0, 26, 0),
            child: _IpadSelectionReason(items: visibleItems),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 16, 26, 24),
            child: _IpadRoundChecklistBar(
              itemCount: items.length,
              startingRound: startingRound,
              onStart: ready ? () => onStartRound(items) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _IpadToyTile extends StatefulWidget {
  final RoundToyWithBox item;
  final String categoryLabel;
  final VoidCallback onTap;

  const _IpadToyTile({
    required this.item,
    required this.categoryLabel,
    required this.onTap,
  });

  @override
  State<_IpadToyTile> createState() => _IpadToyTileState();
}

class _IpadToyTileState extends State<_IpadToyTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final style = _styleForCategory(widget.categoryLabel);
    final name = widget.item.toy.name.trim().isEmpty
        ? 'Sem nome'
        : widget.item.toy.name.trim();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovering ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: _hovering
                ? _IpadHomePalette.orangeBorder
                : _IpadHomePalette.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  _hovering ? const Color(0x21AA6E32) : const Color(0x0FAA6E32),
              blurRadius: _hovering ? 20 : 6,
              offset: Offset(0, _hovering ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(17),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox.expand(
                      child: _IpadToyPhoto(path: widget.item.toy.photoPath),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 9, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: UiTokens.textMicro.copyWith(
                            color: _IpadHomePalette.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        _IpadPill(
                          label: widget.categoryLabel,
                          background: style.background,
                          foreground: style.foreground,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IpadToyPhoto extends StatelessWidget {
  final String? path;

  const _IpadToyPhoto({required this.path});

  @override
  Widget build(BuildContext context) {
    final imagePath = path?.trim();
    if (imagePath == null || imagePath.isEmpty) {
      return const _IpadToyPhotoPlaceholder();
    }

    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => const _IpadToyPhotoPlaceholder(),
    );
  }
}

class _IpadToyPhotoPlaceholder extends StatelessWidget {
  const _IpadToyPhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F0E6),
      alignment: Alignment.center,
      child: const Icon(
        Icons.toys_outlined,
        color: _IpadHomePalette.textMuted,
        size: 28,
      ),
    );
  }
}

class _IpadSelectionReason extends StatelessWidget {
  final List<RoundToyWithBox> items;

  const _IpadSelectionReason({required this.items});

  @override
  Widget build(BuildContext context) {
    final categories = items
        .map((item) => _legacyCategoryLabel(item.toy.categoryId))
        .toSet()
        .length;
    final detail = items.isEmpty
        ? 'A sugestão aparece assim que houver brinquedos cadastrados.'
        : categories >= 3
            ? 'Mistura categorias diferentes e prioriza brinquedos menos usados.'
            : 'Prioriza brinquedos disponíveis para manter a brincadeira variada.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _IpadHomePalette.orangeBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: _IpadHomePalette.orange,
                size: 15,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Por que esta seleção?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _IpadHomePalette.textMid,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _IpadHomePalette.textMuted,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _IpadRoundChecklistBar extends StatelessWidget {
  final int itemCount;
  final bool startingRound;
  final VoidCallback? onStart;

  const _IpadRoundChecklistBar({
    required this.itemCount,
    required this.startingRound,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final counter = itemCount == 1
        ? '0 de 1 brinquedo marcado'
        : '0 de $itemCount brinquedos marcados';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _IpadHomePalette.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _IpadHomePalette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Checklist da rodada',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _IpadHomePalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  counter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _IpadHomePalette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: startingRound ? null : onStart,
            icon: startingRound
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Iniciar rodada'),
            style: FilledButton.styleFrom(
              backgroundColor: _IpadHomePalette.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(146, 48),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              textStyle: UiTokens.textButton.copyWith(
                fontWeight: FontWeight.w800,
              ),
              elevation: 3,
              shadowColor: const Color(0x47F97316),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IpadRoundStatus extends StatelessWidget {
  final bool ready;

  const _IpadRoundStatus({required this.ready});

  @override
  Widget build(BuildContext context) {
    final color = ready ? const Color(0xFF16A34A) : _IpadHomePalette.orange;
    final soft = ready ? const Color(0xFFDCFCE7) : _IpadHomePalette.orangeLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: soft, spreadRadius: 3)],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          ready ? 'Pronta para iniciar' : 'Aguardando brinquedos',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: UiTokens.textMicro.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _IpadRightColumn extends StatelessWidget {
  final ToyRepository toyRepository;
  final WeeklyPlanningRepository? weeklyPlanningRepository;
  final VoidCallback onOpenWeeklyPlanning;
  final VoidCallback onOpenNewToy;
  final VoidCallback onOpenBoxes;
  final VoidCallback onOpenCategories;
  final VoidCallback onOpenSettings;

  const _IpadRightColumn({
    required this.toyRepository,
    required this.weeklyPlanningRepository,
    required this.onOpenWeeklyPlanning,
    required this.onOpenNewToy,
    required this.onOpenBoxes,
    required this.onOpenCategories,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _IpadWeeklyPlanningPanel(
          toyRepository: toyRepository,
          weeklyPlanningRepository: weeklyPlanningRepository,
          onTap: onOpenWeeklyPlanning,
        ),
        const SizedBox(height: 14),
        _IpadHomeStatsPanel(toyRepository: toyRepository),
        const SizedBox(height: 14),
        Expanded(
          child: _IpadQuickActionsPanel(
            onOpenNewToy: onOpenNewToy,
            onOpenBoxes: onOpenBoxes,
            onOpenCategories: onOpenCategories,
            onOpenSettings: onOpenSettings,
          ),
        ),
      ],
    );
  }
}

class _IpadWeeklyPlanningPanel extends StatelessWidget {
  final ToyRepository toyRepository;
  final WeeklyPlanningRepository? weeklyPlanningRepository;
  final VoidCallback onTap;

  const _IpadWeeklyPlanningPanel({
    required this.toyRepository,
    required this.weeklyPlanningRepository,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final repository = weeklyPlanningRepository;
    if (repository == null) {
      return const _IpadPanelSurface(
        padding: EdgeInsets.all(22),
        child: Text('Planejamento indisponível.'),
      );
    }

    return StreamBuilder<List<ToyCatalogItem>>(
      stream: toyRepository.watchCatalog(),
      builder: (context, toysSnapshot) {
        final toyCount = toysSnapshot.data?.length ?? 0;
        return StreamBuilder<List<WeekDaySummary>>(
          stream: repository.watchWeekSummary(),
          builder: (context, snapshot) {
            final summaries = snapshot.data ?? const <WeekDaySummary>[];

            return _IpadPanelSurface(
              padding: const EdgeInsets.all(22),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Planejamento da semana',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textCaption.copyWith(
                          color: _IpadHomePalette.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_monthLabel()} · $toyCount brinquedos no acervo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textMicro.copyWith(
                          color: _IpadHomePalette.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (summaries.isEmpty)
                        Text(
                          'Carregando planejamento...',
                          style: UiTokens.textCaption.copyWith(
                            color: _IpadHomePalette.textMuted,
                          ),
                        )
                      else
                        _IpadWeekStrip(summaries: summaries),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _IpadWeekStrip extends StatelessWidget {
  final List<WeekDaySummary> summaries;

  const _IpadWeekStrip({required this.summaries});

  @override
  Widget build(BuildContext context) {
    final sorted = [...summaries]
      ..sort((a, b) => a.weekday.compareTo(b.weekday));
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - DateTime.monday));

    return Row(
      children: [
        for (var index = 0; index < sorted.length; index++) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(
            child: _IpadWeekCell(
              summary: sorted[index],
              dayNumber: monday.add(Duration(days: index)).day,
            ),
          ),
        ],
      ],
    );
  }
}

class _IpadWeekCell extends StatelessWidget {
  final WeekDaySummary summary;
  final int dayNumber;

  const _IpadWeekCell({required this.summary, required this.dayNumber});

  @override
  Widget build(BuildContext context) {
    final isToday = summary.isToday;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isToday ? _IpadHomePalette.orange : _IpadHomePalette.bg,
        borderRadius: BorderRadius.circular(14),
        border: isToday ? null : Border.all(color: _IpadHomePalette.border),
        boxShadow: isToday
            ? const [
                BoxShadow(
                  color: Color(0x4DF97316),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _weekdayShortLabel(summary.weekday),
            maxLines: 1,
            style: UiTokens.textMicro.copyWith(
              fontSize: 10,
              color: isToday
                  ? Colors.white.withValues(alpha: 0.78)
                  : _IpadHomePalette.textMuted,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$dayNumber',
            maxLines: 1,
            style: UiTokens.textCaption.copyWith(
              color: isToday ? Colors.white : _IpadHomePalette.text,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isToday
                  ? Colors.white.withValues(alpha: 0.55)
                  : _IpadHomePalette.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${summary.totalToys} itens',
              maxLines: 1,
              style: UiTokens.textMicro.copyWith(
                fontSize: 10,
                color: isToday
                    ? Colors.white.withValues(alpha: 0.74)
                    : _IpadHomePalette.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IpadHomeStatsPanel extends StatelessWidget {
  final ToyRepository toyRepository;

  const _IpadHomeStatsPanel({required this.toyRepository});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ToyCatalogItem>>(
      stream: toyRepository.watchCatalog(),
      builder: (context, toysSnapshot) {
        final toyCount = toysSnapshot.data?.length ?? 0;

        return StreamBuilder<List<Boxe>>(
          stream: toyRepository.watchBoxes(),
          builder: (context, boxesSnapshot) {
            final boxCount = boxesSnapshot.data?.length ?? 0;

            return StreamBuilder<List<LocationDefinition>>(
              stream: toyRepository.watchLocations(),
              builder: (context, locationsSnapshot) {
                final locationCount = locationsSnapshot.data?.length ?? 0;

                return _IpadPanelSurface(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organização da casa',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textCaption.copyWith(
                          color: _IpadHomePalette.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visão geral do inventário',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textMicro.copyWith(
                          color: _IpadHomePalette.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 11,
                        mainAxisSpacing: 11,
                        childAspectRatio: 1.72,
                        children: [
                          _IpadStatTile(
                            value: toyCount,
                            label: 'Brinquedos',
                            foreground: _IpadHomePalette.orange,
                            background: _IpadHomePalette.orangeLight,
                            border: _IpadHomePalette.orangeBorder,
                          ),
                          _IpadStatTile(
                            value: boxCount,
                            label: 'Caixas',
                            foreground: const Color(0xFF8B5CF6),
                            background: const Color(0xFFF5F3FF),
                            border: const Color(0xFFDDD6FE),
                          ),
                          _IpadStatTile(
                            value: locationCount,
                            label: 'Locais',
                            foreground: const Color(0xFF16A34A),
                            background: const Color(0xFFDCFCE7),
                            border: const Color(0xFF86EFAC),
                          ),
                          _IpadStatTile(
                            value: AgePresetCatalog.officialCategories.length,
                            label: 'Categorias',
                            foreground: const Color(0xFF2563EB),
                            background: const Color(0xFFEFF6FF),
                            border: const Color(0xFFBFDBFE),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _IpadStatTile extends StatelessWidget {
  final int value;
  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  const _IpadStatTile({
    required this.value,
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            maxLines: 1,
            style: UiTokens.textTitle.copyWith(
              color: foreground,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _IpadHomePalette.textMid,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IpadQuickActionsPanel extends StatelessWidget {
  final VoidCallback onOpenNewToy;
  final VoidCallback onOpenBoxes;
  final VoidCallback onOpenCategories;
  final VoidCallback onOpenSettings;

  const _IpadQuickActionsPanel({
    required this.onOpenNewToy,
    required this.onOpenBoxes,
    required this.onOpenCategories,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <_IpadQuickActionData>[
      _IpadQuickActionData(
        label: 'Novo brinquedo',
        icon: Icons.add_rounded,
        foreground: _IpadHomePalette.orange,
        background: _IpadHomePalette.orangeLight,
        onTap: onOpenNewToy,
      ),
      _IpadQuickActionData(
        label: 'Caixas e locais',
        icon: Icons.inventory_2_outlined,
        foreground: const Color(0xFF8B5CF6),
        background: const Color(0xFFF5F3FF),
        onTap: onOpenBoxes,
      ),
      _IpadQuickActionData(
        label: 'Categorias',
        icon: Icons.sell_outlined,
        foreground: const Color(0xFFC2410C),
        background: const Color(0xFFFFF7ED),
        onTap: onOpenCategories,
      ),
      _IpadQuickActionData(
        label: 'Configurações',
        icon: Icons.settings_outlined,
        foreground: const Color(0xFF78716C),
        background: const Color(0xFFF5F5F4),
        onTap: onOpenSettings,
      ),
    ];

    return _IpadPanelSurface(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações rápidas',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textCaption.copyWith(
              color: _IpadHomePalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Column(
              children: [
                for (var index = 0; index < actions.length; index++) ...[
                  Expanded(child: _IpadQuickActionTile(data: actions[index])),
                  if (index < actions.length - 1)
                    const Divider(height: 1, color: _IpadHomePalette.border),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _IpadHomePalette.border),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rodízio de Brinquedos',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _IpadHomePalette.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _IpadHomePalette.orangeLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Em dia',
                  maxLines: 1,
                  style: UiTokens.textMicro.copyWith(
                    color: _IpadHomePalette.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IpadQuickActionTile extends StatefulWidget {
  final _IpadQuickActionData data;

  const _IpadQuickActionTile({required this.data});

  @override
  State<_IpadQuickActionTile> createState() => _IpadQuickActionTileState();
}

class _IpadQuickActionTileState extends State<_IpadQuickActionTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: data.onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _hovering ? data.background : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: data.background,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: data.foreground.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(data.icon, color: data.foreground, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: UiTokens.textCaption.copyWith(
                      color: _IpadHomePalette.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _IpadHomePalette.textMuted,
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IpadQuickActionData {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;

  const _IpadQuickActionData({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });
}

class _IpadPanelSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _IpadPanelSurface({
    required this.child,
    this.padding = const EdgeInsets.all(UiTokens.spacingMd),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _IpadHomePalette.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12AA6E32),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
          BoxShadow(color: Color(0x0EAA6E32), spreadRadius: 1),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _IpadPill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final Color? border;

  const _IpadPill({
    required this.label,
    required this.background,
    required this.foreground,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: border == null ? null : Border.all(color: border!, width: 1.2),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: UiTokens.textMicro.copyWith(
          color: foreground,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CategoryVisualStyle {
  final Color background;
  final Color foreground;

  const _CategoryVisualStyle({
    required this.background,
    required this.foreground,
  });
}

class _IpadHomePalette {
  _IpadHomePalette._();

  static const Color bg = Color(0xFFFDF7F0);
  static const Color card = Colors.white;
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFF5E8);
  static const Color orangeBorder = Color(0xFFFDDCBA);
  static const Color text = Color(0xFF25180A);
  static const Color textMid = Color(0xFF6B4F30);
  static const Color textMuted = Color(0xFFA8896A);
  static const Color border = Color(0x1FB98750);
}

String _categoryDisplayName(String categoryId, CategoryDefinition? category) {
  if (category != null) {
    final official = officialToyFormCategory(category);
    if (official != null) return official.name;
  }
  return _legacyCategoryLabel(categoryId) ?? 'Exploração';
}

String? _legacyCategoryLabel(String categoryId) {
  switch (categoryId.trim().toLowerCase()) {
    case 'corpo':
    case 'movimento':
      return 'Corpo';
    case 'maos':
    case 'mãos':
    case 'construcao':
      return 'Mãos';
    case 'imaginacao':
    case 'imaginação':
    case 'faz_de_conta':
      return 'Imaginação';
    case 'comunicacao':
    case 'comunicação':
    case 'livros':
      return 'Comunicação';
    case 'exploracao':
    case 'exploração':
    case 'coordenacao':
      return 'Exploração';
  }
  return null;
}

_CategoryVisualStyle _styleForCategory(String categoryLabel) {
  switch (categoryLabel.trim().toLowerCase()) {
    case 'corpo':
      return const _CategoryVisualStyle(
        background: Color(0xFFFFF1F2),
        foreground: Color(0xFFBE123C),
      );
    case 'mãos':
    case 'maos':
      return const _CategoryVisualStyle(
        background: Color(0xFFFFFBEB),
        foreground: Color(0xFF92400E),
      );
    case 'imaginação':
    case 'imaginacao':
      return const _CategoryVisualStyle(
        background: Color(0xFFF5F3FF),
        foreground: Color(0xFF5B21B6),
      );
    case 'comunicação':
    case 'comunicacao':
      return const _CategoryVisualStyle(
        background: Color(0xFFEFF6FF),
        foreground: Color(0xFF1D4ED8),
      );
    case 'exploração':
    case 'exploracao':
      return const _CategoryVisualStyle(
        background: Color(0xFFFFF7ED),
        foreground: Color(0xFFC2410C),
      );
  }
  return const _CategoryVisualStyle(
    background: _IpadHomePalette.orangeLight,
    foreground: _IpadHomePalette.orange,
  );
}

String _weekdayShortLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'SEG';
    case DateTime.tuesday:
      return 'TER';
    case DateTime.wednesday:
      return 'QUA';
    case DateTime.thursday:
      return 'QUI';
    case DateTime.friday:
      return 'SEX';
    case DateTime.saturday:
      return 'SÁB';
    case DateTime.sunday:
      return 'DOM';
  }
  return '';
}

String _monthLabel() {
  final month = DateFormat.MMMM('pt_BR').format(DateTime.now());
  if (month.isEmpty) return '';
  return '${month[0].toUpperCase()}${month.substring(1)}';
}
