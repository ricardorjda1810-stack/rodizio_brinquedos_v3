import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
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

  Widget _buildWeeklyPlanningCard() {
    final weeklyPlanningRepository = _weeklyPlanningRepository;
    if (weeklyPlanningRepository == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiTokens.m,
        0,
        UiTokens.m,
        UiTokens.s,
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiTokens.bg,
      extendBody: false,
      appBar: _currentIndex == 0 ? null : _buildStandardAppBar(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SafeArea(
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
          ),
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
