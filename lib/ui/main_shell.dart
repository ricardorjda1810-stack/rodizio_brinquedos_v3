import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/first_round_analytics_coordinator.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/age_preset.dart';
import 'package:rodizio_brinquedos_v3/domain/weekly_planning/week_day_summary.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/services/app_trial_service.dart';
import 'package:rodizio_brinquedos_v3/services/premium_gate.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/categories_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_category_form_options.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/round_suggestion_sheet.dart';
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
  final AppTrialStatus trialStatus;
  final Future<void> Function() onTrialIntroAcknowledged;

  const MainShell({
    super.key,
    required this.toyRepository,
    required this.roundRepository,
    required this.settingsRepository,
    required this.purchaseService,
    required this.trialStatus,
    required this.onTrialIntroAcknowledged,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _requestedBoxFilterId;
  int _requestedBoxFilterVersion = 0;
  int _roundSuggestionRefreshToken = 0;
  WeeklyPlanningRepository? _weeklyPlanningRepository;
  bool _mobileLoadingSuggestion = false;
  bool _trialIntroDialogScheduled = false;
  @override
  void initState() {
    super.initState();
    widget.roundRepository.attachFirstRoundAnalytics(
      AppAnalytics.firstRoundCreatedCoordinator,
    );
    final db = widget.roundRepository.db;
    if (db != null) {
      _weeklyPlanningRepository = WeeklyPlanningRepository(
        db: db,
        settingsRepository: widget.settingsRepository,
      );
    }
    _scheduleTrialIntroIfNeeded();
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roundRepository != widget.roundRepository) {
      widget.roundRepository.attachFirstRoundAnalytics(
        AppAnalytics.firstRoundCreatedCoordinator,
      );
    }
    if (!oldWidget.trialStatus.introPending &&
        widget.trialStatus.introPending) {
      _trialIntroDialogScheduled = false;
    }
    _scheduleTrialIntroIfNeeded();
  }

  void _scheduleTrialIntroIfNeeded() {
    if (_trialIntroDialogScheduled || !widget.trialStatus.introPending) {
      return;
    }
    _trialIntroDialogScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.trialStatus.introPending) return;
      unawaited(_showTrialIntroDialog());
    });
  }

  Future<void> _showTrialIntroDialog() async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            l10n.isEn ? 'You have 7 free days' : 'Você tem 7 dias grátis',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.isEn
                    ? 'Use all Toy Rotation features to organize toys at home.'
                    : 'Use todos os recursos do Rodízio de Brinquedos para organizar os brinquedos da casa.',
              ),
              const SizedBox(height: 12),
              Text(
                l10n.isEn
                    ? 'After 7 days, a subscription is required to keep using the app.'
                    : 'Depois de 7 dias, será necessário assinar para continuar usando.',
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.isEn ? 'Start' : 'Começar'),
            ),
          ],
        );
      },
    );
    await widget.onTrialIntroAcknowledged();
  }

  void _goTo(int index) {
    if (_currentIndex == index) {
      if (index == 3) {
        setState(() {
          _roundSuggestionRefreshToken++;
        });
      }
      return;
    }
    setState(() {
      if (index == 3) {
        _roundSuggestionRefreshToken++;
      }
      _currentIndex = index;
    });
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
      hasTrialAccess: widget.trialStatus.isTrialActive,
    );
    if (!allowed || !mounted) return;

    unawaited(AppAnalytics.logWeeklyPlanningOpened(source: 'home'));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WeeklyPlanningOverviewPage(
          settingsRepository: widget.settingsRepository,
          weeklyPlanningRepository: weeklyPlanningRepository,
          roundRepository: widget.roundRepository,
          toyRepository: widget.toyRepository,
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

  String _currentDateLabel(BuildContext context) {
    final l10n = context.l10n;
    return DateFormat.yMMMMd(l10n.dateLocale).format(DateTime.now());
  }

  Future<void> _openMobileRoundSuggestionSheet() async {
    if (_mobileLoadingSuggestion) return;
    final l10n = context.l10n;

    setState(() {
      _mobileLoadingSuggestion = true;
    });

    try {
      final categories =
          await widget.toyRepository.watchCategories(activeOnly: true).first;
      final categoryNamesById = <String, String>{
        for (final category in categories)
          category.id: _categoryDisplayName(l10n, category.id, category),
      };
      final suggestedToys = await widget.roundRepository.suggestRoundForToday();
      final boxes = await widget.toyRepository.watchBoxes().first;
      if (!mounted) return;

      unawaited(AppAnalytics.logSuggestionOpened(source: 'home'));
      final selectedToys = await showRoundSuggestionPicker(
        context: context,
        toys: suggestedToys,
        categoryNamesById: categoryNamesById,
        boxesById: {for (final box in boxes) box.id: box},
      );
      if (selectedToys == null || selectedToys.isEmpty) return;

      await widget.roundRepository.setActiveRoundFromToyIds(
        selectedToys.map((toy) => toy.id).toList(growable: false),
        source: RoundCreationSource.homeSuggestion,
      );
      await AppAnalytics.logSuggestionUsed(
        toyCount: selectedToys.length,
        source: 'home',
      );
      await AppAnalytics.logRoundCreated(
        toyCount: selectedToys.length,
        source: 'home_suggestion',
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isEn
                ? 'Rotation created with ${selectedToys.length} toys.'
                : 'Rodada criada com ${selectedToys.length} brinquedos.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isEn
                ? 'Could not build the rotation: $e'
                : 'Não foi possível montar a rodada: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _mobileLoadingSuggestion = false;
        });
      }
    }
  }

  Widget _buildMobileHomePage() {
    return _IphoneHomeDashboard(
      roundRepository: widget.roundRepository,
      toyRepository: widget.toyRepository,
      weeklyPlanningRepository: _weeklyPlanningRepository,
      dateLabel: _currentDateLabel(context),
      loadingSuggestion: _mobileLoadingSuggestion,
      onBuildRound: _openMobileRoundSuggestionSheet,
      onOpenNewToy: _openToyCreate,
      onOpenWeeklyPlanning: _openWeeklyPlanning,
      onOpenSettings: _openSettings,
      trialStatus: widget.trialStatus,
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final isTablet = context.usesTabletPresentation;
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
      trialStatus: widget.trialStatus,
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
          fillAvailableHeight: true,
          suggestionRefreshToken: _roundSuggestionRefreshToken,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildStandardAppBar(
    BuildContext context,
    int currentIndex,
  ) {
    final l10n = context.l10n;
    return AppBar(
      title: Text(
        switch (currentIndex) {
          0 => l10n.home,
          1 => l10n.toys,
          2 => l10n.boxes,
          3 => l10n.rotation,
          _ => l10n.appName,
        },
      ),
      actions: [
        IconButton(
          tooltip: l10n.settings,
          icon: const Icon(Icons.settings_outlined),
          onPressed: _openSettings,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.usesTabletPresentation;
    final effectiveIndex = isTablet || _currentIndex <= 3 ? _currentIndex : 0;
    final body = IndexedStack(
      index: effectiveIndex,
      children: [
        _buildHomePage(context),
        brinquedos.BrinquedosPage(
          toyRepository: widget.toyRepository,
          roundRepository: widget.roundRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
          onOpenRodizioTab: () => _goTo(3),
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

class _IphoneHomeDashboard extends StatelessWidget {
  final RoundRepository roundRepository;
  final ToyRepository toyRepository;
  final WeeklyPlanningRepository? weeklyPlanningRepository;
  final String dateLabel;
  final bool loadingSuggestion;
  final VoidCallback onBuildRound;
  final VoidCallback onOpenNewToy;
  final VoidCallback onOpenWeeklyPlanning;
  final VoidCallback onOpenSettings;
  final AppTrialStatus trialStatus;

  const _IphoneHomeDashboard({
    required this.roundRepository,
    required this.toyRepository,
    required this.weeklyPlanningRepository,
    required this.dateLabel,
    required this.loadingSuggestion,
    required this.onBuildRound,
    required this.onOpenNewToy,
    required this.onOpenWeeklyPlanning,
    required this.onOpenSettings,
    required this.trialStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _IpadHomePalette.bg,
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Toy>>(
          stream: toyRepository.watchAll(),
          builder: (context, toysSnapshot) {
            final toyCount = toysSnapshot.data?.length ?? 0;

            return StreamBuilder<List<RoundToyWithBox>>(
              stream: roundRepository.watchActiveRoundToysWithBox(),
              builder: (context, roundSnapshot) {
                final activeCount =
                    (roundSnapshot.data ?? const <RoundToyWithBox>[]).length;
                final repository = weeklyPlanningRepository;

                if (repository == null) {
                  return _IphoneHomeContent(
                    toyRepository: toyRepository,
                    dateLabel: dateLabel,
                    todayCount: toyCount == 0
                        ? 0
                        : activeCount > 0
                            ? activeCount
                            : 7,
                    weeklySummaries: const <WeekDaySummary>[],
                    weeklyLoading: false,
                    loadingSuggestion: loadingSuggestion,
                    onBuildRound: onBuildRound,
                    onOpenNewToy: onOpenNewToy,
                    onOpenWeeklyPlanning: onOpenWeeklyPlanning,
                    onSettingsTap: onOpenSettings,
                    trialStatus: trialStatus,
                  );
                }

                return StreamBuilder<List<WeekDaySummary>>(
                  stream: repository.watchWeekSummary(),
                  builder: (context, planningSnapshot) {
                    final summaries =
                        planningSnapshot.data ?? const <WeekDaySummary>[];
                    final displaySummaries = toyCount == 0
                        ? _zeroToySummaries(summaries)
                        : summaries;
                    final todaySummary = _todaySummary(displaySummaries);
                    final todayCount = toyCount == 0
                        ? 0
                        : activeCount > 0
                            ? activeCount
                            : todaySummary?.totalToys ?? 7;

                    return _IphoneHomeContent(
                      toyRepository: toyRepository,
                      dateLabel: dateLabel,
                      todayCount: todayCount,
                      weeklySummaries: displaySummaries,
                      weeklyLoading: planningSnapshot.connectionState ==
                          ConnectionState.waiting,
                      loadingSuggestion: loadingSuggestion,
                      onBuildRound: onBuildRound,
                      onOpenNewToy: onOpenNewToy,
                      onOpenWeeklyPlanning: onOpenWeeklyPlanning,
                      onSettingsTap: onOpenSettings,
                      trialStatus: trialStatus,
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

class _IphoneHomeContent extends StatelessWidget {
  final ToyRepository toyRepository;
  final String dateLabel;
  final int todayCount;
  final List<WeekDaySummary> weeklySummaries;
  final bool weeklyLoading;
  final bool loadingSuggestion;
  final VoidCallback onBuildRound;
  final VoidCallback onOpenNewToy;
  final VoidCallback onOpenWeeklyPlanning;
  final VoidCallback onSettingsTap;
  final AppTrialStatus trialStatus;

  const _IphoneHomeContent({
    required this.toyRepository,
    required this.dateLabel,
    required this.todayCount,
    required this.weeklySummaries,
    required this.weeklyLoading,
    required this.loadingSuggestion,
    required this.onBuildRound,
    required this.onOpenNewToy,
    required this.onOpenWeeklyPlanning,
    required this.onSettingsTap,
    required this.trialStatus,
  });

  @override
  Widget build(BuildContext context) {
    final bottomReserve =
        AppBottomNavigation.reservedScrollPadding(context) + UiTokens.spacingSm;
    final trialNotice = context.l10n.trialHomeNotice(trialStatus);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        UiTokens.spacingMd,
        UiTokens.spacingSm,
        UiTokens.spacingMd,
        bottomReserve,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        _IphoneHomeTopBar(
          dateLabel: dateLabel,
          onSettingsTap: onSettingsTap,
        ),
        const SizedBox(height: 10),
        if (trialNotice.isNotEmpty) ...[
          _TrialNoticeBanner(message: trialNotice),
          const SizedBox(height: 10),
        ],
        _IphoneRoundTodayHero(
          itemCount: todayCount,
          loadingSuggestion: loadingSuggestion,
          onBuildRound: onBuildRound,
        ),
        const SizedBox(height: 14),
        _IphoneEssentialActions(
          onOpenNewToy: onOpenNewToy,
          onOpenWeeklyPlanning: onOpenWeeklyPlanning,
        ),
        const SizedBox(height: 14),
        _IphoneOrganizationCard(toyRepository: toyRepository),
        const SizedBox(height: 14),
        _IphoneWeeklyPlanningCompactCard(
          summaries: weeklySummaries,
          todayCount: todayCount,
          loading: weeklyLoading,
          onTap: onOpenWeeklyPlanning,
        ),
      ],
    );
  }
}

class _IphoneHomeTopBar extends StatelessWidget {
  final String dateLabel;
  final VoidCallback onSettingsTap;

  const _IphoneHomeTopBar({
    required this.dateLabel,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.timeToPlay,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTypography.sectionTitle.copyWith(
                  color: _IpadHomePalette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: _IpadHomePalette.orange,
                  ),
                  const SizedBox(width: UiTokens.spacingXs),
                  Flexible(
                    child: Text(
                      dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appTypography.micro.copyWith(
                        color: _IpadHomePalette.textMuted,
                        fontWeight: FontWeight.w700,
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
          tooltip: l10n.settings,
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings_outlined, size: 20),
        ),
      ],
    );
  }
}

class _TrialNoticeBanner extends StatelessWidget {
  final String message;

  const _TrialNoticeBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD7AA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_outlined,
            size: 18,
            color: _IpadHomePalette.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.appTypography.caption.copyWith(
                color: _IpadHomePalette.text,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IphoneRoundTodayHero extends StatelessWidget {
  final int itemCount;
  final bool loadingSuggestion;
  final VoidCallback onBuildRound;

  const _IphoneRoundTodayHero({
    required this.itemCount,
    required this.loadingSuggestion,
    required this.onBuildRound,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_IpadHomePalette.orange, Color(0xFFFBBF24)],
        ),
        borderRadius: BorderRadius.circular(UiTokens.radiusXl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40F97316),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.todaysRotation,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appTypography.sectionTitle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$itemCount',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTypography.pageTitle.copyWith(
                  color: Colors.white,
                  fontSize: 74,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.toysForToday,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.appTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loadingSuggestion ? null : onBuildRound,
              icon: loadingSuggestion
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _IpadHomePalette.orange,
                      ),
                    )
                  : const Icon(Icons.shuffle_rounded, size: 20),
              label: Text(l10n.buildRotation),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _IpadHomePalette.orange,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.72),
                disabledForegroundColor:
                    _IpadHomePalette.orange.withValues(alpha: 0.62),
                minimumSize: const Size.fromHeight(54),
                textStyle: context.appTypography.button.copyWith(
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IphoneEssentialActions extends StatelessWidget {
  final VoidCallback onOpenNewToy;
  final VoidCallback onOpenWeeklyPlanning;

  const _IphoneEssentialActions({
    required this.onOpenNewToy,
    required this.onOpenWeeklyPlanning,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (context.appTextScale >= 1.5) {
      return Column(
        children: [
          _IphoneActionTile(
            label: l10n.newToy,
            icon: Icons.add_rounded,
            foreground: _IpadHomePalette.orange,
            background: _IpadHomePalette.orangeLight,
            border: _IpadHomePalette.orangeBorder,
            onTap: onOpenNewToy,
          ),
          const SizedBox(height: 12),
          _IphoneActionTile(
            label: l10n.isEn ? 'Weekly planning' : 'Planejamento semanal',
            icon: Icons.calendar_month_outlined,
            foreground: const Color(0xFF2563EB),
            background: const Color(0xFFEFF6FF),
            border: const Color(0xFFBFDBFE),
            onTap: onOpenWeeklyPlanning,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _IphoneActionTile(
            label: l10n.newToy,
            icon: Icons.add_rounded,
            foreground: _IpadHomePalette.orange,
            background: _IpadHomePalette.orangeLight,
            border: _IpadHomePalette.orangeBorder,
            onTap: onOpenNewToy,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _IphoneActionTile(
            label: l10n.isEn ? 'Weekly\nplanning' : 'Planejamento\nsemanal',
            icon: Icons.calendar_month_outlined,
            foreground: const Color(0xFF2563EB),
            background: const Color(0xFFEFF6FF),
            border: const Color(0xFFBFDBFE),
            onTap: onOpenWeeklyPlanning,
          ),
        ),
      ],
    );
  }
}

class _IphoneActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color border;
  final VoidCallback onTap;

  const _IphoneActionTile({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityLayout = context.appTextScale >= 1.5;

    Widget iconBox({required double size, required double iconSize}) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: foreground, size: iconSize),
      );
    }

    final textStyle = context.appTypography.caption.copyWith(
      color: _IpadHomePalette.text,
      fontSize: context.isTabletLayout ? null : 12,
      fontWeight: FontWeight.w900,
      height: 1,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: accessibilityLayout ? null : 90,
          constraints: const BoxConstraints(minHeight: 90),
          padding: EdgeInsets.all(accessibilityLayout ? 16 : 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0FAA6E32),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconBox(size: 32, iconSize: 19),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: accessibilityLayout ? null : 2,
                overflow: accessibilityLayout ? null : TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IphoneOrganizationCard extends StatelessWidget {
  final ToyRepository toyRepository;

  const _IphoneOrganizationCard({required this.toyRepository});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Toy>>(
      stream: toyRepository.watchAll(),
      builder: (context, toysSnapshot) {
        final toyCount = toysSnapshot.data?.length ?? 0;

        return StreamBuilder<List<Boxe>>(
          stream: toyRepository.watchBoxes(),
          builder: (context, boxesSnapshot) {
            final boxCount =
                toyCount == 0 ? 0 : boxesSnapshot.data?.length ?? 0;

            return StreamBuilder<List<LocationDefinition>>(
              stream: toyRepository.watchLocations(),
              builder: (context, locationsSnapshot) {
                final l10n = context.l10n;
                final locationCount =
                    toyCount == 0 ? 0 : locationsSnapshot.data?.length ?? 0;

                return Container(
                  padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F3A36),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26313A36),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeOrganization,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _IphoneDarkStat(
                              value: toyCount,
                              label: l10n.toys.toLowerCase(),
                            ),
                          ),
                          const _IphoneDarkDivider(),
                          Expanded(
                            child: _IphoneDarkStat(
                              value: boxCount,
                              label: l10n.boxes.toLowerCase(),
                            ),
                          ),
                          const _IphoneDarkDivider(),
                          Expanded(
                            child: _IphoneDarkStat(
                              value: locationCount,
                              label: l10n.locations,
                            ),
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

class _IphoneDarkStat extends StatelessWidget {
  final int value;
  final String label;

  const _IphoneDarkStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appTypography.pageTitle.copyWith(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appTypography.micro.copyWith(
            color: Colors.white.withValues(alpha: 0.64),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _IphoneDarkDivider extends StatelessWidget {
  const _IphoneDarkDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}

class _IphoneWeeklyPlanningCompactCard extends StatelessWidget {
  final List<WeekDaySummary> summaries;
  final int todayCount;
  final bool loading;
  final VoidCallback onTap;

  const _IphoneWeeklyPlanningCompactCard({
    required this.summaries,
    required this.todayCount,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = _upcomingSummaries(summaries, limit: 7);
    final l10n = context.l10n;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _IpadHomePalette.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0FAA6E32),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _IpadHomePalette.orangeLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      color: _IpadHomePalette.orange,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.weeklyPlanning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appTypography.caption.copyWith(
                        color: _IpadHomePalette.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _IpadHomePalette.textMuted,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (upcoming.isEmpty)
                Text(
                  loading
                      ? (l10n.isEn
                          ? 'Loading the next few days...'
                          : 'Carregando próximos dias...')
                      : (l10n.isEn
                          ? 'Tap to adjust the next few days.'
                          : 'Toque para ajustar os próximos dias.'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appTypography.micro.copyWith(
                    color: _IpadHomePalette.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      for (var index = 0; index < upcoming.length; index++) ...[
                        if (index > 0) const SizedBox(width: 8),
                        SizedBox(
                          width: 116,
                          child: _IphoneWeekPreviewCell(
                            summary: upcoming[index],
                            todayCount: todayCount,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IphoneWeekPreviewCell extends StatelessWidget {
  final WeekDaySummary summary;
  final int todayCount;

  const _IphoneWeekPreviewCell({
    required this.summary,
    required this.todayCount,
  });

  @override
  Widget build(BuildContext context) {
    final isToday =
        summary.isToday || summary.weekday == DateTime.now().weekday;
    final totalToys = isToday ? todayCount : summary.totalToys;
    final l10n = context.l10n;
    final background =
        isToday ? _IpadHomePalette.orangeLight : const Color(0xFFFFFBF6);
    final foreground =
        isToday ? _IpadHomePalette.orange : _IpadHomePalette.text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isToday ? _IpadHomePalette.orangeBorder : const Color(0xFFF3E2D0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.compactWeekdayLabel(summary.weekday, isToday: isToday),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appTypography.micro.copyWith(
              color: foreground,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              l10n.compactToysCount(totalToys),
              maxLines: 1,
              style: context.appTypography.micro.copyWith(
                color: _IpadHomePalette.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
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
  final AppTrialStatus trialStatus;

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
    required this.trialStatus,
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
    final l10n = context.l10n;

    setState(() {
      _loadingSuggestion = true;
    });
    try {
      final categories =
          await widget.toyRepository.watchCategories(activeOnly: true).first;
      final categoryNamesById = <String, String>{
        for (final category in categories)
          category.id: _categoryDisplayName(l10n, category.id, category),
      };
      final suggestedToys = await widget.roundRepository.suggestRoundForToday();
      final boxes = await widget.toyRepository.watchBoxes().first;
      if (!mounted) return;

      unawaited(AppAnalytics.logSuggestionOpened(source: 'home_ipad'));
      final selectedToys = await showRoundSuggestionPicker(
        context: context,
        toys: suggestedToys,
        categoryNamesById: categoryNamesById,
        boxesById: {for (final box in boxes) box.id: box},
      );
      if (selectedToys == null || selectedToys.isEmpty) return;

      await widget.roundRepository.setActiveRoundFromToyIds(
        selectedToys.map((toy) => toy.id).toList(growable: false),
        source: RoundCreationSource.homeIpadSuggestion,
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

      _refreshHomeSuggestion();
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
        setState(() {
          _loadingSuggestion = false;
        });
      }
    }
  }

  Future<void> _startRound(List<RoundToyWithBox> selection) async {
    if (_startingRound) return;

    setState(() {
      _startingRound = true;
    });
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

      await widget.roundRepository.setActiveRoundFromToyIds(
        toyIds,
        source: RoundCreationSource.homeIpadStart,
      );
      await AppAnalytics.logSuggestionUsed(
        toyCount: toyIds.length,
        source: 'home_ipad',
      );
      await AppAnalytics.logRoundCreated(
        toyCount: toyIds.length,
        source: 'home_ipad_start',
      );
      if (!mounted) return;

      _refreshHomeSuggestion();
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
        setState(() {
          _startingRound = false;
        });
      }
    }
  }

  void _refreshHomeSuggestion() {
    final suggestionFuture = _loadHomeSuggestion();
    setState(() {
      _suggestionFuture = suggestionFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _IpadHomePalette.bg,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = width >= 700;
            final isWideTablet = width >= 1024;
            final useTwoColumnLayout = isWideTablet;
            final horizontalPadding = isWideTablet
                ? UiTokens.spacingLg
                : isTablet
                    ? 24.0
                    : 16.0;
            final verticalPadding =
                constraints.maxHeight >= 900 ? UiTokens.spacingMd : 12.0;
            final gap = isWideTablet ? 24.0 : 18.0;
            final maxContentWidth = isWideTablet ? 1180.0 : 900.0;

            final activeRoundStream =
                widget.roundRepository.watchActiveRoundToysWithBox();
            final suggestionFuture =
                _suggestionFuture ??= _loadHomeSuggestion();

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
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
                      if (widget.trialStatus.homeNotice != null) ...[
                        SizedBox(height: gap),
                        _TrialNoticeBanner(
                          message: context.l10n.trialHomeNotice(
                            widget.trialStatus,
                          ),
                        ),
                      ],
                      SizedBox(height: gap),
                      Expanded(
                        child: StreamBuilder<List<Toy>>(
                          stream: widget.toyRepository.watchAll(),
                          builder: (context, toysSnapshot) {
                            final toyCount = toysSnapshot.data?.length ?? 0;

                            return StreamBuilder<List<RoundToyWithBox>>(
                              stream: activeRoundStream,
                              builder: (context, activeSnapshot) {
                                final activeItems = activeSnapshot.data ??
                                    const <RoundToyWithBox>[];
                                final activeCount = activeItems.length;

                                return FutureBuilder<List<RoundToyWithBox>>(
                                  future: suggestionFuture,
                                  builder: (context, suggestionSnapshot) {
                                    final suggestionCount = toyCount == 0
                                        ? 0
                                        : suggestionSnapshot.data?.length;
                                    final todayCount = toyCount == 0
                                        ? 0
                                        : activeCount > 0
                                            ? activeCount
                                            : suggestionCount;
                                    final roundTodayCard = _IpadRoundTodayCard(
                                      activeStream: activeRoundStream,
                                      categoriesStream: widget.toyRepository
                                          .watchCategories(activeOnly: true),
                                      suggestionFuture: suggestionFuture,
                                      hasToys: toyCount > 0,
                                      startingRound: _startingRound,
                                      onStartRound: _startRound,
                                      onOpenToy: widget.onOpenToy,
                                    );
                                    final rightColumn = _IpadRightColumn(
                                      toyRepository: widget.toyRepository,
                                      weeklyPlanningRepository:
                                          widget.weeklyPlanningRepository,
                                      todayCountOverride: todayCount,
                                      fillHeight: useTwoColumnLayout,
                                      onOpenWeeklyPlanning:
                                          widget.onOpenWeeklyPlanning,
                                      onOpenNewToy: widget.onOpenNewToy,
                                      onOpenBoxes: widget.onOpenBoxes,
                                      onOpenCategories: widget.onOpenCategories,
                                      onOpenSettings: widget.onOpenSettings,
                                    );

                                    if (useTwoColumnLayout) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: roundTodayCard,
                                          ),
                                          SizedBox(width: gap),
                                          Expanded(
                                            flex: 4,
                                            child: rightColumn,
                                          ),
                                        ],
                                      );
                                    }

                                    return SingleChildScrollView(
                                      physics: const ClampingScrollPhysics(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          roundTodayCard,
                                          SizedBox(height: gap),
                                          rightColumn,
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
    final l10n = context.l10n;
    return _IpadPanelSurface(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactHeader = constraints.maxWidth < 760;
          final icon = Container(
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
          );
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.appNameUpper,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTypography.micro.copyWith(
                  color: _IpadHomePalette.textMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.isEn
                    ? "Organize today's play time"
                    : 'Organize a brincadeira de hoje',
                maxLines: compactHeader ? 2 : 1,
                overflow: TextOverflow.visible,
                style: context.appTypography.pageTitle.copyWith(
                  color: _IpadHomePalette.text,
                  fontSize: compactHeader ? 22 : 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.isEn
                    ? 'Build a balanced rotation and keep toys moving.'
                    : 'Monte uma rodada equilibrada e mantenha os brinquedos em movimento.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.appTypography.caption.copyWith(
                  color: _IpadHomePalette.textMuted,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
          final actions = Wrap(
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
                label: Text(l10n.buildRotation),
                style: FilledButton.styleFrom(
                  backgroundColor: _IpadHomePalette.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(152, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  textStyle: context.appTypography.button.copyWith(
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
                label: Text(l10n.newToy),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _IpadHomePalette.orangeLight,
                  foregroundColor: const Color(0xFFC2410C),
                  side: const BorderSide(
                    color: _IpadHomePalette.orangeBorder,
                    width: 1.5,
                  ),
                  minimumSize: const Size(156, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  textStyle: context.appTypography.button.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          );

          if (compactHeader) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    icon,
                    const SizedBox(width: 18),
                    Expanded(child: title),
                  ],
                ),
                const SizedBox(height: 18),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }

          return Row(
            children: [
              icon,
              const SizedBox(width: 20),
              Expanded(child: title),
              const SizedBox(width: 18),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _IpadRoundTodayCard extends StatelessWidget {
  final Stream<List<RoundToyWithBox>> activeStream;
  final Stream<List<CategoryDefinition>> categoriesStream;
  final Future<List<RoundToyWithBox>> suggestionFuture;
  final bool hasToys;
  final bool startingRound;
  final Future<void> Function(List<RoundToyWithBox> selection) onStartRound;
  final ValueChanged<String> onOpenToy;

  const _IpadRoundTodayCard({
    required this.activeStream,
    required this.categoriesStream,
    required this.suggestionFuture,
    required this.hasToys,
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

            if (!hasToys) {
              return _IpadRoundTodayContent(
                items: const <RoundToyWithBox>[],
                categoriesById: categoriesById,
                isSuggestion: true,
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
    final l10n = context.l10n;
    final countLabel = l10n.toysCount(items.length);
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
                            l10n.todaysRotation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.appTypography.sectionTitle.copyWith(
                              color: _IpadHomePalette.text,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          _IpadPill(
                            label: loading
                                ? (l10n.isEn ? 'loading' : 'carregando')
                                : countLabel,
                            background: _IpadHomePalette.orangeLight,
                            foreground: const Color(0xFFEA580C),
                            border: _IpadHomePalette.orangeBorder,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSuggestion
                            ? (l10n.isEn
                                ? 'Today · Balanced suggestion'
                                : 'Hoje · Sugestão equilibrada')
                            : (l10n.isEn
                                ? 'Today · Rotation ready to play'
                                : 'Hoje · Rodada pronta para brincar'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appTypography.caption.copyWith(
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
                        l10n.registerToysForToday,
                        textAlign: TextAlign.center,
                        style: context.appTypography.body.copyWith(
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
                          l10n,
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
          const SizedBox(height: 18),
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
    final name = context.l10n.toyDisplayNameForId(
      id: widget.item.toy.id,
      name: widget.item.toy.name,
    );

    return MouseRegion(
      onEnter: (_) => setState(() {
        _hovering = true;
      }),
      onExit: (_) => setState(() {
        _hovering = false;
      }),
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
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                          style: context.appTypography.micro.copyWith(
                            color: _IpadHomePalette.text,
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

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => const _IpadToyPhotoPlaceholder(),
      );
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
        ? context.l10n.selectionReasonEmpty
        : categories >= 3
            ? context.l10n.selectionReasonMixed
            : context.l10n.selectionReasonAvailable;

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
                  context.l10n.selectionReasonTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appTypography.micro.copyWith(
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
            style: context.appTypography.micro.copyWith(
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
    final l10n = context.l10n;
    final counter = l10n.markedToysCount(itemCount);

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
                  l10n.roundChecklist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appTypography.caption.copyWith(
                    color: _IpadHomePalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  counter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appTypography.micro.copyWith(
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
            label: Text(l10n.startRotation),
            style: FilledButton.styleFrom(
              backgroundColor: _IpadHomePalette.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(146, 48),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              textStyle: context.appTypography.button.copyWith(
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
          ready
              ? context.l10n.roundReadyToStart
              : context.l10n.roundWaitingForToys,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appTypography.micro.copyWith(
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
  final int? todayCountOverride;
  final bool fillHeight;
  final VoidCallback onOpenWeeklyPlanning;
  final VoidCallback onOpenNewToy;
  final VoidCallback onOpenBoxes;
  final VoidCallback onOpenCategories;
  final VoidCallback onOpenSettings;

  const _IpadRightColumn({
    required this.toyRepository,
    required this.weeklyPlanningRepository,
    required this.todayCountOverride,
    required this.fillHeight,
    required this.onOpenWeeklyPlanning,
    required this.onOpenNewToy,
    required this.onOpenBoxes,
    required this.onOpenCategories,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
      children: [
        _IpadWeeklyPlanningPanel(
          toyRepository: toyRepository,
          weeklyPlanningRepository: weeklyPlanningRepository,
          todayCountOverride: todayCountOverride,
          onTap: onOpenWeeklyPlanning,
        ),
        const SizedBox(height: 14),
        _IpadHomeStatsPanel(toyRepository: toyRepository),
        const SizedBox(height: 14),
        if (fillHeight)
          Expanded(
            child: _IpadQuickActionsPanel(
              fillHeight: true,
              onOpenNewToy: onOpenNewToy,
              onOpenBoxes: onOpenBoxes,
              onOpenCategories: onOpenCategories,
              onOpenSettings: onOpenSettings,
            ),
          )
        else
          _IpadQuickActionsPanel(
            fillHeight: false,
            onOpenNewToy: onOpenNewToy,
            onOpenBoxes: onOpenBoxes,
            onOpenCategories: onOpenCategories,
            onOpenSettings: onOpenSettings,
          ),
      ],
    );
  }
}

class _IpadWeeklyPlanningPanel extends StatelessWidget {
  final ToyRepository toyRepository;
  final WeeklyPlanningRepository? weeklyPlanningRepository;
  final int? todayCountOverride;
  final VoidCallback onTap;

  const _IpadWeeklyPlanningPanel({
    required this.toyRepository,
    required this.weeklyPlanningRepository,
    required this.todayCountOverride,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repository = weeklyPlanningRepository;
    if (repository == null) {
      return _IpadPanelSurface(
        padding: const EdgeInsets.all(22),
        child: Text(
          l10n.isEn ? 'Planning unavailable.' : 'Planejamento indisponível.',
        ),
      );
    }

    return StreamBuilder<List<ToyCatalogItem>>(
      stream: toyRepository.watchCatalog(),
      builder: (context, toysSnapshot) {
        final toyCount = toysSnapshot.data?.length ?? 0;
        return StreamBuilder<List<WeekDaySummary>>(
          stream: repository.watchWeekSummary(),
          builder: (context, snapshot) {
            final rawSummaries = snapshot.data ?? const <WeekDaySummary>[];
            final summaries =
                toyCount == 0 ? _zeroToySummaries(rawSummaries) : rawSummaries;
            final todayOverride = toyCount == 0 ? 0 : todayCountOverride;

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
                        l10n.weeklyPlanning,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appTypography.caption.copyWith(
                          color: _IpadHomePalette.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_monthLabel(l10n.dateLocale)} · ${l10n.toysCount(toyCount)} ${l10n.inCollection}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appTypography.micro.copyWith(
                          color: _IpadHomePalette.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (summaries.isEmpty)
                        Text(
                          l10n.planningLoading,
                          style: context.appTypography.caption.copyWith(
                            color: _IpadHomePalette.textMuted,
                          ),
                        )
                      else
                        _IpadWeekStrip(
                          summaries: summaries,
                          todayCountOverride: todayOverride,
                        ),
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
  final int? todayCountOverride;

  const _IpadWeekStrip({
    required this.summaries,
    required this.todayCountOverride,
  });

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
              todayCountOverride: todayCountOverride,
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
  final int? todayCountOverride;

  const _IpadWeekCell({
    required this.summary,
    required this.dayNumber,
    required this.todayCountOverride,
  });

  @override
  Widget build(BuildContext context) {
    final isToday =
        summary.isToday || summary.weekday == DateTime.now().weekday;
    final totalToys =
        isToday ? todayCountOverride ?? summary.totalToys : summary.totalToys;
    final l10n = context.l10n;

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
            l10n.compactWeekdayLabel(summary.weekday, isToday: false),
            maxLines: 1,
            style: context.appTypography.micro.copyWith(
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
            style: context.appTypography.caption.copyWith(
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
              l10n.compactToysCount(totalToys),
              maxLines: 1,
              style: context.appTypography.micro.copyWith(
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
            final boxCount =
                toyCount == 0 ? 0 : boxesSnapshot.data?.length ?? 0;

            return StreamBuilder<List<LocationDefinition>>(
              stream: toyRepository.watchLocations(),
              builder: (context, locationsSnapshot) {
                final l10n = context.l10n;
                final locationCount =
                    toyCount == 0 ? 0 : locationsSnapshot.data?.length ?? 0;

                return _IpadPanelSurface(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeOrganization,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appTypography.caption.copyWith(
                          color: _IpadHomePalette.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.isEn
                            ? 'Inventory overview'
                            : 'Visão geral do inventário',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appTypography.micro.copyWith(
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
                            label: l10n.toys,
                            foreground: _IpadHomePalette.orange,
                            background: _IpadHomePalette.orangeLight,
                            border: _IpadHomePalette.orangeBorder,
                          ),
                          _IpadStatTile(
                            value: boxCount,
                            label: l10n.boxes,
                            foreground: const Color(0xFF8B5CF6),
                            background: const Color(0xFFF5F3FF),
                            border: const Color(0xFFDDD6FE),
                          ),
                          _IpadStatTile(
                            value: locationCount,
                            label: l10n.locationsTitle,
                            foreground: const Color(0xFF16A34A),
                            background: const Color(0xFFDCFCE7),
                            border: const Color(0xFF86EFAC),
                          ),
                          _IpadStatTile(
                            value: AgePresetCatalog.officialCategories.length,
                            label: l10n.categories,
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
            style: context.appTypography.pageTitle.copyWith(
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
            style: context.appTypography.micro.copyWith(
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
  final bool fillHeight;
  final VoidCallback onOpenNewToy;
  final VoidCallback onOpenBoxes;
  final VoidCallback onOpenCategories;
  final VoidCallback onOpenSettings;

  const _IpadQuickActionsPanel({
    required this.fillHeight,
    required this.onOpenNewToy,
    required this.onOpenBoxes,
    required this.onOpenCategories,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actions = <_IpadQuickActionData>[
      _IpadQuickActionData(
        label: l10n.newToy,
        icon: Icons.add_rounded,
        foreground: _IpadHomePalette.orange,
        background: _IpadHomePalette.orangeLight,
        onTap: onOpenNewToy,
      ),
      _IpadQuickActionData(
        label: l10n.boxesAndLocations,
        icon: Icons.inventory_2_outlined,
        foreground: const Color(0xFF8B5CF6),
        background: const Color(0xFFF5F3FF),
        onTap: onOpenBoxes,
      ),
      _IpadQuickActionData(
        label: l10n.categories,
        icon: Icons.sell_outlined,
        foreground: const Color(0xFFC2410C),
        background: const Color(0xFFFFF7ED),
        onTap: onOpenCategories,
      ),
      _IpadQuickActionData(
        label: l10n.settings,
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
            l10n.quickActions,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appTypography.caption.copyWith(
              color: _IpadHomePalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          if (fillHeight)
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
            )
          else
            Column(
              children: [
                for (var index = 0; index < actions.length; index++) ...[
                  _IpadQuickActionTile(data: actions[index]),
                  if (index < actions.length - 1)
                    const Divider(height: 1, color: _IpadHomePalette.border),
                ],
              ],
            ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _IpadHomePalette.border),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appTypography.micro.copyWith(
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
                  l10n.upToDate,
                  maxLines: 1,
                  style: context.appTypography.micro.copyWith(
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
      onEnter: (_) => setState(() {
        _hovering = true;
      }),
      onExit: (_) => setState(() {
        _hovering = false;
      }),
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
                    style: context.appTypography.caption.copyWith(
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
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: context.appTypography.micro.copyWith(
          color: foreground,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          height: 1.05,
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

String _categoryDisplayName(
  AppLocalizations l10n,
  String categoryId,
  CategoryDefinition? category,
) {
  if (category != null) {
    final official = officialToyFormCategory(category);
    if (official != null) {
      return l10n.categoryNameById(categoryId, official.name);
    }
    return l10n.categoryNameById(categoryId, category.name);
  }
  return l10n.categoryNameById(
    categoryId,
    _legacyCategoryLabel(categoryId) ?? 'Sentidos e Exploração',
  );
}

String? _legacyCategoryLabel(String categoryId) {
  switch (categoryId.trim().toLowerCase()) {
    case 'corpo':
    case 'movimento':
      return 'Corpo e Respiração';
    case 'exploracao':
    case 'exploração':
    case 'coordenacao':
      return 'Sentidos e Exploração';
    case 'maos':
    case 'mãos':
    case 'construcao':
      return 'Mãos e Construção';
    case 'imaginacao':
    case 'imaginação':
    case 'faz_de_conta':
      return 'Imaginação e Criatividade';
    case 'comunicacao':
    case 'comunicação':
    case 'livros':
      return 'Comunicação e Histórias';
  }
  return null;
}

_CategoryVisualStyle _styleForCategory(String categoryLabel) {
  switch (categoryLabel.trim().toLowerCase()) {
    case 'corpo e respiração':
    case 'corpo e respiracao':
    case 'body and breathing':
    case 'corpo':
      return const _CategoryVisualStyle(
        background: Color(0xFFFFF1F2),
        foreground: Color(0xFFBE123C),
      );
    case 'sentidos e exploração':
    case 'sentidos e exploracao':
    case 'senses and exploration':
    case 'exploração':
    case 'exploracao':
      return const _CategoryVisualStyle(
        background: Color(0xFFFFF7ED),
        foreground: Color(0xFFC2410C),
      );
    case 'mãos e construção':
    case 'maos e construcao':
    case 'hands and building':
    case 'mãos':
    case 'maos':
      return const _CategoryVisualStyle(
        background: Color(0xFFFFFBEB),
        foreground: Color(0xFF92400E),
      );
    case 'imaginação e criatividade':
    case 'imaginacao e criatividade':
    case 'imagination and creativity':
    case 'imaginação':
    case 'imaginacao':
      return const _CategoryVisualStyle(
        background: Color(0xFFF5F3FF),
        foreground: Color(0xFF5B21B6),
      );
    case 'comunicação e histórias':
    case 'comunicacao e historias':
    case 'communication and stories':
    case 'comunicação':
    case 'comunicacao':
      return const _CategoryVisualStyle(
        background: Color(0xFFEFF6FF),
        foreground: Color(0xFF1D4ED8),
      );
  }
  return const _CategoryVisualStyle(
    background: _IpadHomePalette.orangeLight,
    foreground: _IpadHomePalette.orange,
  );
}

WeekDaySummary? _todaySummary(List<WeekDaySummary> summaries) {
  for (final summary in summaries) {
    if (summary.isToday) return summary;
  }

  final today = DateTime.now().weekday;
  for (final summary in summaries) {
    if (summary.weekday == today) return summary;
  }

  return null;
}

List<WeekDaySummary> _zeroToySummaries(List<WeekDaySummary> summaries) {
  return summaries
      .map(
        (summary) => WeekDaySummary(
          weekday: summary.weekday,
          shortLabel: summary.shortLabel,
          fullLabel: summary.fullLabel,
          totalToys: 0,
          usesDefault: summary.usesDefault,
          isToday: summary.isToday,
        ),
      )
      .toList(growable: false);
}

List<WeekDaySummary> _upcomingSummaries(
  List<WeekDaySummary> summaries, {
  required int limit,
}) {
  if (summaries.isEmpty || limit <= 0) return const <WeekDaySummary>[];

  final byWeekday = <int, WeekDaySummary>{
    for (final summary in summaries) summary.weekday: summary,
  };
  final today = DateTime.now().weekday;
  final upcoming = <WeekDaySummary>[];

  for (var offset = 0; offset < 7 && upcoming.length < limit; offset++) {
    final weekday = ((today - 1 + offset) % 7) + 1;
    final summary = byWeekday[weekday];
    if (summary != null) upcoming.add(summary);
  }

  if (upcoming.isNotEmpty) return upcoming;

  final sorted = [...summaries]..sort((a, b) => a.weekday.compareTo(b.weekday));
  return sorted.take(limit).toList(growable: false);
}

String _monthLabel(String locale) {
  final month = DateFormat.MMMM(locale).format(DateTime.now());
  if (month.isEmpty) return '';
  return '${month[0].toUpperCase()}${month.substring(1)}';
}
