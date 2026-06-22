import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/round_suggestion_sheet.dart';

class RodadaPage extends StatefulWidget {
  final RoundRepository roundRepository;
  final ToyRepository toyRepository;
  final PurchaseService purchaseService;
  final VoidCallback onOpenRodizioTab;
  final VoidCallback onOpenBrinquedosTab;
  final VoidCallback onOpenSettings;
  final VoidCallback? onOpenHomeTab;
  final VoidCallback? onOpenRoundTab;
  final VoidCallback? onOpenWeeklyPlanning;
  final VoidCallback? onOpenToysTab;
  final VoidCallback? onOpenBoxesTab;
  final bool fillAvailableHeight;
  final String activeItemsTitle;

  const RodadaPage({
    super.key,
    required this.roundRepository,
    required this.toyRepository,
    required this.purchaseService,
    required this.onOpenRodizioTab,
    required this.onOpenBrinquedosTab,
    required this.onOpenSettings,
    this.onOpenHomeTab,
    this.onOpenRoundTab,
    this.onOpenWeeklyPlanning,
    this.onOpenToysTab,
    this.onOpenBoxesTab,
    this.fillAvailableHeight = false,
    this.activeItemsTitle = 'Brinquedos disponíveis',
  });

  @override
  State<RodadaPage> createState() => _RodadaPageState();
}

class _RodadaPageState extends State<RodadaPage> {
  static const String _firstRoundCreatedLoggedKey =
      'analytics_first_round_created_logged';

  bool _startingRound = false;
  bool _loadingSuggestion = false;
  bool _assemblyMode = false;
  List<RoundToyWithBox> _immediateRoundItems = const <RoundToyWithBox>[];
  Future<List<RoundToyWithBox>>? _homeSuggestionFuture;

  void _openToyDetail(String toyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToyDetailPage(
          toyId: toyId,
          toyRepository: widget.toyRepository,
          purchaseService: widget.purchaseService,
          topNavigationIndex: 3,
          onOpenHomeTab: widget.onOpenHomeTab,
          onOpenRoundTab: widget.onOpenRoundTab,
          onOpenWeeklyPlanning: widget.onOpenWeeklyPlanning,
          onOpenToysTab: widget.onOpenToysTab ?? widget.onOpenBrinquedosTab,
          onOpenBoxesTab: widget.onOpenBoxesTab,
          onOpenSettings: widget.onOpenSettings,
        ),
      ),
    );
  }

  Future<List<RoundToyWithBox>> _loadHomeSuggestion() async {
    final toys = await widget.roundRepository.suggestRoundForToday();
    final boxes = await widget.toyRepository.watchBoxes().first;
    final boxesById = {for (final box in boxes) box.id: box};

    return _roundItemsFromToys(toys, boxesById);
  }

  List<RoundToyWithBox> _roundItemsFromToys(
    List<Toy> toys,
    Map<String, Boxe> boxesById,
  ) {
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

  void _openAssemblyModeWith(List<RoundToyWithBox> items) {
    if (items.isEmpty) return;
    setState(() {
      _immediateRoundItems = items;
      _assemblyMode = true;
    });
  }

  void _clearImmediateRoundItemsAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _immediateRoundItems.isEmpty) return;
      setState(() {
        _immediateRoundItems = const <RoundToyWithBox>[];
      });
    });
  }

  Future<void> _useHomeSuggestion(List<RoundToyWithBox> suggestion) async {
    if (_startingRound) return;

    setState(() {
      _startingRound = true;
    });
    try {
      final toyIds = suggestion
          .map((item) => item.toy.id)
          .where((id) => id.trim().isNotEmpty)
          .toList(growable: false);
      if (toyIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nenhum brinquedo dispon\u00edvel para iniciar a rodada.',
            ),
          ),
        );
        return;
      }

      await widget.roundRepository.setActiveRoundFromToyIds(toyIds);
      await AppAnalytics.logSuggestionUsed(
        toyCount: toyIds.length,
        source: 'home',
      );
      await AppAnalytics.logRoundCreated(
        toyCount: toyIds.length,
        source: 'home_suggestion',
      );
      await _logFirstRoundCreatedOnce(toyIds.length);
      if (!mounted) return;

      _openAssemblyModeWith(suggestion);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rodada criada com ${toyIds.length} brinquedos.'),
        ),
      );
      widget.onOpenRodizioTab();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'N\u00e3o foi poss\u00edvel usar a sugest\u00e3o: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _startingRound = false;
        });
      }
    }
  }

  Future<void> _openRoundSuggestionSheet(
    Map<String, String> categoryNamesById,
  ) async {
    if (_loadingSuggestion) return;

    setState(() {
      _loadingSuggestion = true;
    });
    try {
      final suggestedToys = await widget.roundRepository.suggestRoundForToday();
      final boxes = await widget.toyRepository.watchBoxes().first;
      final boxesById = {for (final box in boxes) box.id: box};
      if (!mounted) return;

      unawaited(AppAnalytics.logSuggestionOpened(source: 'round_page'));
      final selectedToys = await showRoundSuggestionPicker(
        context: context,
        toys: suggestedToys,
        categoryNamesById: categoryNamesById,
        boxesById: boxesById,
      );
      if (selectedToys == null || selectedToys.isEmpty) return;

      await widget.roundRepository.setActiveRoundFromToyIds(
        selectedToys.map((toy) => toy.id).toList(growable: false),
      );
      await AppAnalytics.logSuggestionUsed(
        toyCount: selectedToys.length,
        source: 'round_page',
      );
      await AppAnalytics.logRoundCreated(
        toyCount: selectedToys.length,
        source: 'round_suggestion',
      );
      await _logFirstRoundCreatedOnce(selectedToys.length);
      if (!mounted) return;

      _openAssemblyModeWith(_roundItemsFromToys(selectedToys, boxesById));
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
        SnackBar(
          content: Text('N\u00e3o foi poss\u00edvel sugerir a rodada: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingSuggestion = false;
        });
      }
    }
  }

  Future<void> _logFirstRoundCreatedOnce(int toyCount) async {
    final preferences = await SharedPreferences.getInstance();
    final alreadyLogged =
        preferences.getBool(_firstRoundCreatedLoggedKey) ?? false;

    if (alreadyLogged) return;

    await preferences.setBool(_firstRoundCreatedLoggedKey, true);
    await AppAnalytics.logFirstRoundCreated(toyCount: toyCount);
  }

  String _categoryNameFor(
    RoundToyWithBox item,
    Map<String, String> categoryNamesById,
  ) {
    final categoryId = item.toy.categoryId.trim();
    if (categoryId.isEmpty) return 'Sem categoria';

    final categoryName = categoryNamesById[categoryId]?.trim();
    if (categoryName != null && categoryName.isNotEmpty) {
      return categoryName;
    }

    final fallback = categoryId.replaceAll('_', ' ').trim();
    if (fallback.isEmpty) return 'Sem categoria';
    return fallback[0].toUpperCase() + fallback.substring(1);
  }

  void _toggleCollectedForToy(String toyId) {
    unawaited(
      widget.roundRepository.toggleToyCollectedForDate(
        date: DateTime.now(),
        toyId: toyId,
      ),
    );
  }

  Future<void> _setCollectedForItems(
    List<RoundToyWithBox> items,
    bool collected,
  ) async {
    final toyIds = <String>{
      for (final item in items)
        if (item.toy.id.trim().isNotEmpty) item.toy.id.trim(),
    };
    if (toyIds.isEmpty) return;

    try {
      for (final toyId in toyIds) {
        await widget.roundRepository.setToyCollectedForDate(
          date: DateTime.now(),
          toyId: toyId,
          collected: collected,
        );
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            collected
                ? 'Rodada marcada como conclu\u00edda.'
                : 'Marca\u00e7\u00f5es da rodada removidas.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('N\u00e3o foi poss\u00edvel atualizar a rodada: $e'),
        ),
      );
    }
  }

  String _todayLabel() {
    const weekdays = [
      'segunda',
      'ter\u00e7a',
      'quarta',
      'quinta',
      'sexta',
      's\u00e1bado',
      'domingo',
    ];
    final now = DateTime.now();
    final weekday = weekdays[now.weekday - 1];
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$weekday \u00b7 $day/$month';
  }

  Widget _buildIpadLayout(BuildContext context) {
    final bottomReserve =
        AppBottomNavigation.reservedScrollPadding(context) + 18;

    return LayoutBuilder(
      builder: (context, viewportConstraints) {
        return ColoredBox(
          color: _RodadaIpadPalette.bg,
          child: StreamBuilder<List<RoundToyWithBox>>(
            stream: widget.roundRepository.watchActiveRoundToysWithBox(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final activeItems = snapshot.data ?? const <RoundToyWithBox>[];
              final items =
                  activeItems.isNotEmpty ? activeItems : _immediateRoundItems;
              if (activeItems.isNotEmpty && _immediateRoundItems.isNotEmpty) {
                _clearImmediateRoundItemsAfterFrame();
              }

              return StreamBuilder<List<CategoryDefinition>>(
                stream: widget.toyRepository.watchCategories(),
                builder: (context, categoriesSnapshot) {
                  final categories =
                      categoriesSnapshot.data ?? const <CategoryDefinition>[];
                  final categoryNamesById = <String, String>{
                    for (final category in categories)
                      category.id: category.name,
                  };
                  final homeSuggestionFuture =
                      _homeSuggestionFuture ??= _loadHomeSuggestion();
                  final checklistStream = items.isEmpty
                      ? Stream.value(const <String, bool>{})
                      : widget.roundRepository
                          .watchRoundChecklistForDate(DateTime.now());

                  return StreamBuilder<Map<String, bool>>(
                    stream: checklistStream,
                    builder: (context, checklistSnapshot) {
                      final checklistByToyId =
                          checklistSnapshot.data ?? const <String, bool>{};
                      final progress = RoundChecklistProgress.fromToyIds(
                        items.map((item) => item.toy.id),
                        checklistByToyId,
                      );

                      final primaryLabel = items.isEmpty
                          ? 'Sugerir rodada'
                          : progress.isReady
                              ? 'Rodada conclu\u00edda'
                              : 'Concluir rodada';
                      final primaryAction = items.isEmpty
                          ? (_loadingSuggestion
                              ? null
                              : () => _openRoundSuggestionSheet(
                                    categoryNamesById,
                                  ))
                          : progress.isReady
                              ? null
                              : () => unawaited(
                                    _setCollectedForItems(items, true),
                                  );
                      final secondaryLabel = items.isEmpty
                          ? 'Ver brinquedos'
                          : 'Trocar sugest\u00e3o';
                      final secondaryAction = items.isEmpty
                          ? widget.onOpenBrinquedosTab
                          : (_loadingSuggestion
                              ? null
                              : () => _openRoundSuggestionSheet(
                                    categoryNamesById,
                                  ));

                      final horizontalPadding =
                          viewportConstraints.maxWidth >= 980 ? 32.0 : 24.0;
                      final desiredColumnHeight = viewportConstraints
                              .maxHeight.isFinite
                          ? viewportConstraints.maxHeight - bottomReserve - 196
                          : 780.0;
                      final columnHeight =
                          desiredColumnHeight.clamp(760.0, 1010.0).toDouble();

                      return ListView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          20,
                          horizontalPadding,
                          bottomReserve,
                        ),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 1032,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _RodadaIpadHeader(
                                    todayLabel: _todayLabel(),
                                    itemCount: items.length,
                                    progress: progress,
                                    primaryLabel: primaryLabel,
                                    primaryAction: primaryAction,
                                    primaryLoading:
                                        items.isEmpty && _loadingSuggestion,
                                    secondaryLabel: secondaryLabel,
                                    secondaryAction: secondaryAction,
                                  ),
                                  const SizedBox(height: 18),
                                  LayoutBuilder(
                                    builder: (context, contentConstraints) {
                                      final sideColumnWidth = math.min(
                                        334.0,
                                        math.max(
                                          292.0,
                                          contentConstraints.maxWidth * 0.34,
                                        ),
                                      );

                                      return SizedBox(
                                        height: columnHeight,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: _RodadaIpadChecklistCard(
                                                items: items,
                                                progress: progress,
                                                checklistByToyId:
                                                    checklistByToyId,
                                                categoryNamesById:
                                                    categoryNamesById,
                                                suggestionFuture:
                                                    homeSuggestionFuture,
                                                usingSuggestion: _startingRound,
                                                onOpenToy: _openToyDetail,
                                                onUseSuggestion: _startingRound
                                                    ? null
                                                    : _useHomeSuggestion,
                                                onToggleCollected:
                                                    _toggleCollectedForToy,
                                                categoryNameFor:
                                                    _categoryNameFor,
                                              ),
                                            ),
                                            const SizedBox(width: 18),
                                            SizedBox(
                                              width: sideColumnWidth,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    flex: 8,
                                                    child:
                                                        _RodadaIpadOrganizationCard(
                                                      items: items,
                                                      categoryNamesById:
                                                          categoryNamesById,
                                                      categoryNameFor:
                                                          _categoryNameFor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 14),
                                                  const _RodadaIpadTipCard(),
                                                  const SizedBox(height: 14),
                                                  Expanded(
                                                    flex: 5,
                                                    child:
                                                        _RodadaIpadQuickActionsCard(
                                                      hasItems:
                                                          items.isNotEmpty,
                                                      isReady: progress.isReady,
                                                      loadingSuggestion:
                                                          _loadingSuggestion,
                                                      onMarkAll: items.isEmpty
                                                          ? null
                                                          : () => unawaited(
                                                                _setCollectedForItems(
                                                                  items,
                                                                  true,
                                                                ),
                                                              ),
                                                      onSuggestRound: () =>
                                                          _openRoundSuggestionSheet(
                                                        categoryNamesById,
                                                      ),
                                                      onOpenToys: widget
                                                          .onOpenBrinquedosTab,
                                                      onOpenSettings:
                                                          widget.onOpenSettings,
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    if (isTablet) {
      return _buildIpadLayout(context);
    }

    final bottomNavigationReserve =
        AppBottomNavigation.reservedScrollPadding(context) + UiTokens.spacingLg;

    return LayoutBuilder(
      builder: (context, viewportConstraints) {
        return StreamBuilder<List<RoundToyWithBox>>(
          stream: widget.roundRepository.watchActiveRoundToysWithBox(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final activeItems = snapshot.data ?? const <RoundToyWithBox>[];
            final items =
                activeItems.isNotEmpty ? activeItems : _immediateRoundItems;
            if (activeItems.isNotEmpty && _immediateRoundItems.isNotEmpty) {
              _clearImmediateRoundItemsAfterFrame();
            }

            return StreamBuilder<List<CategoryDefinition>>(
              stream: widget.toyRepository.watchCategories(),
              builder: (context, categoriesSnapshot) {
                final categories =
                    categoriesSnapshot.data ?? const <CategoryDefinition>[];
                final categoryNamesById = <String, String>{
                  for (final category in categories) category.id: category.name,
                };

                const gridSpacing = 12.0;
                final gridTileHeight = _assemblyMode ? 168.0 : 148.0;
                const gridCardPadding = 14.0;
                final gridHeaderReserve = _assemblyMode ? 78.0 : 40.0;
                final twoRowsGridHeight =
                    UiTokens.spacingXs + (gridTileHeight * 2) + gridSpacing;
                final desiredGridCardHeight = (gridCardPadding * 2) +
                    gridHeaderReserve +
                    UiTokens.spacingSm +
                    twoRowsGridHeight;
                final viewportHeight = viewportConstraints.maxHeight;
                final preferSingleRowGrid = widget.fillAvailableHeight &&
                    viewportConstraints.maxWidth >= 560 &&
                    items.isNotEmpty &&
                    items.length <= 5;
                final maxFilledGridCardHeight =
                    preferSingleRowGrid ? 460.0 : 660.0;
                final expandedGridCardHeight =
                    widget.fillAvailableHeight && viewportHeight.isFinite
                        ? (viewportHeight - 74).clamp(
                            desiredGridCardHeight,
                            maxFilledGridCardHeight,
                          )
                        : desiredGridCardHeight;
                final gridCardHeight = expandedGridCardHeight.toDouble();
                final emptyGridCardHeight = widget.fillAvailableHeight
                    ? gridCardHeight
                    : desiredGridCardHeight * 0.68;
                final homeSuggestionFuture =
                    _homeSuggestionFuture ??= _loadHomeSuggestion();

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    UiTokens.spacingMd,
                    0,
                    UiTokens.spacingMd,
                    widget.fillAvailableHeight ? 0 : bottomNavigationReserve,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RoundMomentCard(
                        itemCount: items.length,
                        loadingSuggestion: _loadingSuggestion,
                        onSuggestRound: () => _openRoundSuggestionSheet(
                          categoryNamesById,
                        ),
                        onOpenBrinquedosTab: widget.onOpenBrinquedosTab,
                        onOpenSettings: widget.onOpenSettings,
                      ),
                      const SizedBox(height: UiTokens.spacingSm),
                      SizedBox(
                        width: double.infinity,
                        height: items.isEmpty
                            ? emptyGridCardHeight
                            : gridCardHeight,
                        child: items.isEmpty
                            ? FutureBuilder<List<RoundToyWithBox>>(
                                future: homeSuggestionFuture,
                                builder: (context, snapshot) {
                                  final suggestionCount = snapshot.data?.length;
                                  final counterText = suggestionCount == null
                                      ? '...'
                                      : suggestionCount == 1
                                          ? '1 item'
                                          : '$suggestionCount itens';

                                  return _AvailableToysGridCard(
                                    items: items,
                                    onOpenToy: _openToyDetail,
                                    emptyTitle: 'Sugest\u00e3o para hoje',
                                    emptyCounterText: counterText,
                                    emptyState: _HomeSuggestionEmptyState(
                                      suggestionFuture: homeSuggestionFuture,
                                      onOpenToy: _openToyDetail,
                                      onUseSuggestion: _startingRound
                                          ? null
                                          : _useHomeSuggestion,
                                      usingSuggestion: _startingRound,
                                    ),
                                  );
                                },
                              )
                            : StreamBuilder<Map<String, bool>>(
                                stream: widget.roundRepository
                                    .watchRoundChecklistForDate(DateTime.now()),
                                builder: (context, checklistSnapshot) {
                                  final checklistByToyId =
                                      checklistSnapshot.data ??
                                          const <String, bool>{};

                                  return _AvailableToysGridCard(
                                    items: items,
                                    onOpenToy: _openToyDetail,
                                    emptyTitle: 'Sugest\u00e3o para hoje',
                                    emptyCounterText: '',
                                    emptyState: _HomeSuggestionEmptyState(
                                      suggestionFuture: homeSuggestionFuture,
                                      onOpenToy: _openToyDetail,
                                      onUseSuggestion: _startingRound
                                          ? null
                                          : _useHomeSuggestion,
                                      usingSuggestion: _startingRound,
                                    ),
                                    activeItemsTitle: widget.activeItemsTitle,
                                    preferSingleRowLayout: preferSingleRowGrid,
                                    assemblyMode: _assemblyMode,
                                    checklistByToyId: checklistByToyId,
                                    categoryNamesById: categoryNamesById,
                                    onToggleAssemblyMode: () {
                                      setState(
                                        () => _assemblyMode = !_assemblyMode,
                                      );
                                    },
                                    onToggleCollected: (toyId) {
                                      unawaited(
                                        widget.roundRepository
                                            .toggleToyCollectedForDate(
                                          date: DateTime.now(),
                                          toyId: toyId,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
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

class _RodadaIpadPalette {
  _RodadaIpadPalette._();

  static const Color bg = Color(0xFFFDF7F0);
  static const Color card = Colors.white;
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFF5E8);
  static const Color orangeBorder = Color(0xFFFDDCBA);
  static const Color text = Color(0xFF25180A);
  static const Color textMid = Color(0xFF6B4F30);
  static const Color textMuted = Color(0xFFA8896A);
  static const Color border = Color(0x1FB98750);
  static const Color green = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFEAF7EE);
  static const Color greenBorder = Color(0xFFB7E4C7);
  static const Color blue = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF5F3FF);
}

class _RodadaIpadSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _RodadaIpadSurface({
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _RodadaIpadPalette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _RodadaIpadPalette.border, width: 1.2),
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

class _RodadaIpadHeader extends StatelessWidget {
  final String todayLabel;
  final int itemCount;
  final RoundChecklistProgress progress;
  final String primaryLabel;
  final VoidCallback? primaryAction;
  final bool primaryLoading;
  final String secondaryLabel;
  final VoidCallback? secondaryAction;

  const _RodadaIpadHeader({
    required this.todayLabel,
    required this.itemCount,
    required this.progress,
    required this.primaryLabel,
    required this.primaryAction,
    required this.primaryLoading,
    required this.secondaryLabel,
    required this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return _RodadaIpadSurface(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          final copy = Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      _RodadaIpadPalette.orange,
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
                  Icons.checklist_rtl_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROD\u00cdZIO DE BRINQUEDOS \u00b7 ${todayLabel.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textMicro.copyWith(
                        color: _RodadaIpadPalette.orange,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Rodada de hoje',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textTitle.copyWith(
                        color: _RodadaIpadPalette.text,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      itemCount == 0
                          ? 'Monte uma sugest\u00e3o para separar os brinquedos de hoje.'
                          : 'Separe os brinquedos sugeridos e acompanhe o que j\u00e1 foi marcado.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textCaption.copyWith(
                        color: _RodadaIpadPalette.textMid,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RodadaIpadSecondaryButton(
                label: secondaryLabel,
                icon: itemCount == 0
                    ? Icons.toys_outlined
                    : Icons.swap_horiz_rounded,
                onPressed: secondaryAction,
              ),
              const SizedBox(width: 12),
              _RodadaIpadPrimaryButton(
                label: primaryLabel,
                icon: progress.isReady && itemCount > 0
                    ? Icons.check_circle_rounded
                    : Icons.done_all_rounded,
                onPressed: primaryAction,
                loading: primaryLoading,
                ready: progress.isReady && itemCount > 0,
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                copy,
                const SizedBox(height: 18),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 22),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _RodadaIpadPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool ready;

  const _RodadaIpadPrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.loading,
    required this.ready,
  });

  @override
  Widget build(BuildContext context) {
    final background =
        ready ? _RodadaIpadPalette.green : _RodadaIpadPalette.orange;

    return SizedBox(
      height: 46,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 19),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor:
              ready ? _RodadaIpadPalette.green : const Color(0xFFE8DED2),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
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
      ),
    );
  }
}

class _RodadaIpadSecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _RodadaIpadSecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: _RodadaIpadPalette.orange,
          disabledForegroundColor: _RodadaIpadPalette.textMuted,
          backgroundColor: _RodadaIpadPalette.orangeLight,
          side: const BorderSide(
            color: _RodadaIpadPalette.orangeBorder,
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

class _RodadaIpadChecklistCard extends StatelessWidget {
  final List<RoundToyWithBox> items;
  final RoundChecklistProgress progress;
  final Map<String, bool> checklistByToyId;
  final Map<String, String> categoryNamesById;
  final Future<List<RoundToyWithBox>> suggestionFuture;
  final bool usingSuggestion;
  final ValueChanged<String> onOpenToy;
  final Future<void> Function(List<RoundToyWithBox> suggestion)?
      onUseSuggestion;
  final ValueChanged<String> onToggleCollected;
  final String Function(RoundToyWithBox item, Map<String, String> categories)
      categoryNameFor;

  const _RodadaIpadChecklistCard({
    required this.items,
    required this.progress,
    required this.checklistByToyId,
    required this.categoryNamesById,
    required this.suggestionFuture,
    required this.usingSuggestion,
    required this.onOpenToy,
    required this.onUseSuggestion,
    required this.onToggleCollected,
    required this.categoryNameFor,
  });

  @override
  Widget build(BuildContext context) {
    final countLabel = items.isEmpty
        ? 'Nenhuma rodada ativa'
        : '${progress.collectedCount} de ${progress.totalCount} brinquedos marcados';
    final percent = (progress.fraction * 100).round();

    return _RodadaIpadSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            countLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: UiTokens.textSectionTitle.copyWith(
                              color: _RodadaIpadPalette.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            items.isEmpty
                                ? 'Escolha uma sugest\u00e3o para come\u00e7ar.'
                                : 'Hoje \u00b7 ${items.length} brinquedos na rodada',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: UiTokens.textMicro.copyWith(
                              color: _RodadaIpadPalette.textMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (items.isNotEmpty) ...[
                      const SizedBox(width: 14),
                      _RodadaIpadPercentPill(
                        value: '$percent%',
                        ready: progress.isReady,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.fraction,
                    minHeight: 9,
                    backgroundColor: _RodadaIpadPalette.orangeLight,
                    color: progress.isReady
                        ? _RodadaIpadPalette.green
                        : _RodadaIpadPalette.orange,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _RodadaIpadPalette.border),
          Expanded(
            child: items.isEmpty
                ? _RodadaIpadEmptyChecklist(
                    suggestionFuture: suggestionFuture,
                    usingSuggestion: usingSuggestion,
                    onOpenToy: onOpenToy,
                    onUseSuggestion: onUseSuggestion,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isCollected = checklistByToyId[item.toy.id] == true;
                      return _RodadaIpadChecklistItem(
                        item: item,
                        categoryLabel: categoryNameFor(
                          item,
                          categoryNamesById,
                        ),
                        isCollected: isCollected,
                        onOpenToy: () => onOpenToy(item.toy.id),
                        onToggle: () => onToggleCollected(item.toy.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RodadaIpadPercentPill extends StatelessWidget {
  final String value;
  final bool ready;

  const _RodadaIpadPercentPill({
    required this.value,
    required this.ready,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        ready ? _RodadaIpadPalette.green : _RodadaIpadPalette.orange;
    final background =
        ready ? _RodadaIpadPalette.greenLight : _RodadaIpadPalette.orangeLight;
    final border = ready
        ? _RodadaIpadPalette.greenBorder
        : _RodadaIpadPalette.orangeBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Text(
        value,
        style: UiTokens.textMicro.copyWith(
          color: foreground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RodadaIpadChecklistItem extends StatelessWidget {
  final RoundToyWithBox item;
  final String categoryLabel;
  final bool isCollected;
  final VoidCallback onOpenToy;
  final VoidCallback onToggle;

  const _RodadaIpadChecklistItem({
    required this.item,
    required this.categoryLabel,
    required this.isCollected,
    required this.onOpenToy,
    required this.onToggle,
  });

  String _boxLabel() {
    final box = item.box;
    if (box == null) return 'Sem caixa';

    final name = box.name.trim();
    if (name.isNotEmpty) return name;
    return 'Caixa ${box.number}';
  }

  String _locationLabel() {
    final box = item.box;
    if (box != null) {
      final local = box.local.trim();
      return local.isEmpty ? 'Sem local definido' : local;
    }

    final location = (item.toy.locationText ?? '').trim();
    return location.isEmpty ? 'Sem local' : location;
  }

  @override
  Widget build(BuildContext context) {
    final name =
        item.toy.name.trim().isEmpty ? 'Sem nome' : item.toy.name.trim();
    final location = '${_boxLabel()} \u00b7 ${_locationLabel()}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isCollected ? _RodadaIpadPalette.greenLight : Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: isCollected
              ? _RodadaIpadPalette.greenBorder
              : _RodadaIpadPalette.border,
          width: 1.35,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10AA6E32),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(19),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _RodadaIpadToyThumb(path: item.toy.photoPath, size: 66),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: UiTokens.textCaption.copyWith(
                                color: _RodadaIpadPalette.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _RodadaIpadMiniPill(
                            label: isCollected ? 'Marcado' : 'Pendente',
                            foreground: isCollected
                                ? _RodadaIpadPalette.green
                                : _RodadaIpadPalette.orange,
                            background: isCollected
                                ? Colors.white
                                : _RodadaIpadPalette.orangeLight,
                            border: isCollected
                                ? _RodadaIpadPalette.greenBorder
                                : _RodadaIpadPalette.orangeBorder,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _RodadaIpadMiniPill(
                            label: categoryLabel,
                            foreground: _RodadaIpadPalette.orange,
                            background: _RodadaIpadPalette.orangeLight,
                            border: _RodadaIpadPalette.orangeBorder,
                          ),
                          _RodadaIpadMiniPill(
                            label: location,
                            foreground: _RodadaIpadPalette.textMid,
                            background: const Color(0xFFFFFBF6),
                            border: _RodadaIpadPalette.border,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: onToggle,
                  tooltip: isCollected ? 'Desmarcar' : 'Marcar',
                  style: IconButton.styleFrom(
                    backgroundColor: isCollected
                        ? _RodadaIpadPalette.green
                        : _RodadaIpadPalette.orangeLight,
                    foregroundColor:
                        isCollected ? Colors.white : _RodadaIpadPalette.orange,
                    fixedSize: const Size(40, 40),
                    shape: const CircleBorder(),
                  ),
                  icon: Icon(
                    isCollected
                        ? Icons.check_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 22,
                  ),
                ),
                IconButton(
                  onPressed: onOpenToy,
                  tooltip: 'Abrir brinquedo',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _RodadaIpadPalette.textMuted,
                    fixedSize: const Size(38, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.chevron_right_rounded, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RodadaIpadToyThumb extends StatelessWidget {
  final String? path;
  final double size;

  const _RodadaIpadToyThumb({
    required this.path,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = path?.trim();
    final image = imagePath == null || imagePath.isEmpty
        ? const _RodadaIpadToyPlaceholder()
        : Image.file(
            File(imagePath),
            width: size,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => const _RodadaIpadToyPlaceholder(),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: SizedBox(width: size, height: size, child: image),
    );
  }
}

class _RodadaIpadToyPlaceholder extends StatelessWidget {
  const _RodadaIpadToyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _RodadaIpadPalette.orangeLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.extension_outlined,
        color: _RodadaIpadPalette.orange,
        size: 24,
      ),
    );
  }
}

class _RodadaIpadMiniPill extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  const _RodadaIpadMiniPill({
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

class _RodadaIpadEmptyChecklist extends StatelessWidget {
  final Future<List<RoundToyWithBox>> suggestionFuture;
  final bool usingSuggestion;
  final ValueChanged<String> onOpenToy;
  final Future<void> Function(List<RoundToyWithBox> suggestion)?
      onUseSuggestion;

  const _RodadaIpadEmptyChecklist({
    required this.suggestionFuture,
    required this.usingSuggestion,
    required this.onOpenToy,
    required this.onUseSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RoundToyWithBox>>(
      future: suggestionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final suggestion = snapshot.data ?? const <RoundToyWithBox>[];
        if (suggestion.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                'Cadastre brinquedos para montar uma sugest\u00e3o.',
                textAlign: TextAlign.center,
                style: UiTokens.textCaption.copyWith(
                  color: _RodadaIpadPalette.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }

        final preview = suggestion.take(8).toList(growable: false);

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final item in preview)
                    Tooltip(
                      message: item.toy.name.trim().isEmpty
                          ? 'Brinquedo sugerido'
                          : item.toy.name.trim(),
                      child: InkWell(
                        onTap: () => onOpenToy(item.toy.id),
                        borderRadius: BorderRadius.circular(18),
                        child: _RodadaIpadToyThumb(
                          path: item.toy.photoPath,
                          size: 70,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                '${suggestion.length} brinquedos sugeridos para hoje',
                textAlign: TextAlign.center,
                style: UiTokens.textSectionTitle.copyWith(
                  color: _RodadaIpadPalette.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use a sugest\u00e3o para transformar esta tela em checklist.',
                textAlign: TextAlign.center,
                style: UiTokens.textCaption.copyWith(
                  color: _RodadaIpadPalette.textMid,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onUseSuggestion == null || usingSuggestion
                    ? null
                    : () => onUseSuggestion!(suggestion),
                icon: usingSuggestion
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Usar sugest\u00e3o'),
                style: FilledButton.styleFrom(
                  backgroundColor: _RodadaIpadPalette.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  textStyle: UiTokens.textButton.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RodadaIpadOrganizationCard extends StatelessWidget {
  final List<RoundToyWithBox> items;
  final Map<String, String> categoryNamesById;
  final String Function(RoundToyWithBox item, Map<String, String> categories)
      categoryNameFor;

  const _RodadaIpadOrganizationCard({
    required this.items,
    required this.categoryNamesById,
    required this.categoryNameFor,
  });

  Map<String, int> _boxCounts() {
    final counts = <String, int>{};
    for (final item in items) {
      final box = item.box;
      final label = box == null
          ? 'Sem caixa'
          : box.name.trim().isNotEmpty
              ? box.name.trim()
              : 'Caixa ${box.number}';
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> _locationCounts() {
    final counts = <String, int>{};
    for (final item in items) {
      final box = item.box;
      final toyLocation = (item.toy.locationText ?? '').trim();
      final label = box != null && box.local.trim().isNotEmpty
          ? box.local.trim()
          : toyLocation.isNotEmpty
              ? toyLocation
              : 'Sem local';
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> _categoryCounts() {
    final counts = <String, int>{};
    for (final item in items) {
      final label = categoryNameFor(item, categoryNamesById);
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final allBoxCounts = _sortedCounts(_boxCounts());
    final allLocationCounts = _sortedCounts(_locationCounts());
    final allCategoryCounts = _sortedCounts(_categoryCounts());
    final boxCounts = allBoxCounts.take(3).toList();
    final locationCounts = allLocationCounts.take(3).toList();
    final categoryCounts = allCategoryCounts.take(4).toList();

    return _RodadaIpadSurface(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Organiza\u00e7\u00e3o',
            style: UiTokens.textCaption.copyWith(
              color: _RodadaIpadPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Onde buscar cada brinquedo',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _RodadaIpadPalette.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'A organiza\u00e7\u00e3o aparece quando houver uma rodada ativa.',
                  textAlign: TextAlign.center,
                  style: UiTokens.textMicro.copyWith(
                    color: _RodadaIpadPalette.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else ...[
            const _RodadaIpadSideLabel('Caixas envolvidas'),
            const SizedBox(height: 8),
            for (final entry in boxCounts) ...[
              _RodadaIpadCountRow(
                icon: Icons.inventory_2_outlined,
                label: entry.key,
                count: entry.value,
                color: _RodadaIpadPalette.orange,
              ),
              const SizedBox(height: 7),
            ],
            if (allBoxCounts.length > boxCounts.length) ...[
              _RodadaIpadMiniPill(
                label: '+${allBoxCounts.length - boxCounts.length} caixa',
                foreground: _RodadaIpadPalette.orange,
                background: _RodadaIpadPalette.orangeLight,
                border: _RodadaIpadPalette.orangeBorder,
              ),
              const SizedBox(height: 7),
            ],
            const SizedBox(height: 4),
            const Divider(height: 1, color: _RodadaIpadPalette.border),
            const SizedBox(height: 12),
            const _RodadaIpadSideLabel('Locais'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in locationCounts)
                  _RodadaIpadMiniPill(
                    label: '${entry.key} · ${entry.value}',
                    foreground: _RodadaIpadPalette.green,
                    background: _RodadaIpadPalette.greenLight,
                    border: _RodadaIpadPalette.greenBorder,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const _RodadaIpadSideLabel('Categorias presentes'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in categoryCounts)
                  _RodadaIpadMiniPill(
                    label: '${entry.key} · ${entry.value}',
                    foreground: _RodadaIpadPalette.blue,
                    background: _RodadaIpadPalette.blueLight,
                    border: const Color(0xFFBFDBFE),
                  ),
                if (allCategoryCounts.length > categoryCounts.length)
                  _RodadaIpadMiniPill(
                    label:
                        '+${allCategoryCounts.length - categoryCounts.length} categoria',
                    foreground: _RodadaIpadPalette.blue,
                    background: _RodadaIpadPalette.blueLight,
                    border: const Color(0xFFBFDBFE),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RodadaIpadSideLabel extends StatelessWidget {
  final String label;

  const _RodadaIpadSideLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: UiTokens.textMicro.copyWith(
        color: _RodadaIpadPalette.textMid,
        fontSize: 11.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _RodadaIpadCountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _RodadaIpadCountRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _RodadaIpadPalette.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UiTokens.textMicro.copyWith(
                color: _RodadaIpadPalette.text,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: UiTokens.textMicro.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RodadaIpadTipCard extends StatelessWidget {
  const _RodadaIpadTipCard();

  @override
  Widget build(BuildContext context) {
    return _RodadaIpadSurface(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _RodadaIpadPalette.orangeLight,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _RodadaIpadPalette.orangeBorder),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: _RodadaIpadPalette.orange,
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
                    color: _RodadaIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Depois de brincar, marque os brinquedos usados para melhorar as pr\u00f3ximas sugest\u00f5es.',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _RodadaIpadPalette.textMid,
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

class _RodadaIpadQuickActionsCard extends StatelessWidget {
  final bool hasItems;
  final bool isReady;
  final bool loadingSuggestion;
  final VoidCallback? onMarkAll;
  final VoidCallback onSuggestRound;
  final VoidCallback onOpenToys;
  final VoidCallback onOpenSettings;

  const _RodadaIpadQuickActionsCard({
    required this.hasItems,
    required this.isReady,
    required this.loadingSuggestion,
    required this.onMarkAll,
    required this.onSuggestRound,
    required this.onOpenToys,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <_RodadaIpadActionData>[
      if (hasItems)
        _RodadaIpadActionData(
          label: isReady ? 'Tudo marcado' : 'Marcar todos',
          icon: Icons.done_all_rounded,
          foreground: _RodadaIpadPalette.green,
          background: _RodadaIpadPalette.greenLight,
          enabled: !isReady,
          onTap: onMarkAll,
        ),
      _RodadaIpadActionData(
        label: hasItems ? 'Trocar sugest\u00e3o' : 'Sugerir rodada',
        icon: Icons.swap_horiz_rounded,
        foreground: _RodadaIpadPalette.orange,
        background: _RodadaIpadPalette.orangeLight,
        enabled: !loadingSuggestion,
        onTap: onSuggestRound,
      ),
      _RodadaIpadActionData(
        label: 'Ver brinquedos',
        icon: Icons.toys_outlined,
        foreground: _RodadaIpadPalette.blue,
        background: _RodadaIpadPalette.blueLight,
        onTap: onOpenToys,
      ),
      _RodadaIpadActionData(
        label: 'Configura\u00e7\u00f5es',
        icon: Icons.tune_rounded,
        foreground: _RodadaIpadPalette.purple,
        background: _RodadaIpadPalette.purpleLight,
        onTap: onOpenSettings,
      ),
    ];

    return _RodadaIpadSurface(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A\u00e7\u00f5es r\u00e1pidas',
            style: UiTokens.textCaption.copyWith(
              color: _RodadaIpadPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < actions.length; index++) ...[
            _RodadaIpadActionTile(data: actions[index]),
            if (index < actions.length - 1)
              const Divider(height: 11, color: _RodadaIpadPalette.border),
          ],
          const Spacer(),
          Text(
            hasItems
                ? 'Use o checklist sem sair da rodada.'
                : 'Comece por uma sugest\u00e3o ou revise o cat\u00e1logo.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _RodadaIpadPalette.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RodadaIpadActionData {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final bool enabled;
  final VoidCallback? onTap;

  const _RodadaIpadActionData({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
    this.enabled = true,
  });
}

class _RodadaIpadActionTile extends StatelessWidget {
  final _RodadaIpadActionData data;

  const _RodadaIpadActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final enabled = data.enabled && data.onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? data.onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: enabled ? data.background : const Color(0xFFF6EFE8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  data.icon,
                  color:
                      enabled ? data.foreground : _RodadaIpadPalette.textMuted,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: enabled
                        ? _RodadaIpadPalette.text
                        : _RodadaIpadPalette.textMuted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: enabled
                    ? _RodadaIpadPalette.textMuted
                    : const Color(0xFFD8C7B4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<MapEntry<String, int>> _sortedCounts(Map<String, int> counts) {
  final entries = counts.entries.toList();
  entries.sort((a, b) {
    final byCount = b.value.compareTo(a.value);
    if (byCount != 0) return byCount;
    return a.key.compareTo(b.key);
  });
  return entries;
}

class _RoundMomentCard extends StatelessWidget {
  final int itemCount;
  final bool loadingSuggestion;
  final VoidCallback onSuggestRound;
  final VoidCallback onOpenBrinquedosTab;
  final VoidCallback onOpenSettings;

  const _RoundMomentCard({
    required this.itemCount,
    required this.loadingSuggestion,
    required this.onSuggestRound,
    required this.onOpenBrinquedosTab,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemCountText = itemCount == 0
        ? 'Crie uma rodada para come\u00e7ar.'
        : itemCount == 1
            ? '1 item dispon\u00edvel'
            : '$itemCount itens dispon\u00edveis';

    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingSm),
      color: colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 330;
          final icon = Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: UiTokens.secondarySoft,
              borderRadius: BorderRadius.circular(UiTokens.radiusMd),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.local_activity_outlined,
              size: 19,
              color: UiTokens.primaryStrong,
            ),
          );
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Brincadeira',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textSectionTitle.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              Text(
                itemCountText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: UiTokens.textCaption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
          final suggestButton = OutlinedButton(
            onPressed: loadingSuggestion ? null : onSuggestRound,
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(
                horizontal: UiTokens.spacingSm,
              ),
              textStyle: UiTokens.textButton.copyWith(fontSize: 13),
            ),
            child: loadingSuggestion
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Sugerir',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          );
          final menuButton = PopupMenuButton<String>(
            tooltip: 'Mais op\u00e7\u00f5es',
            onSelected: (value) {
              if (value == 'toys') {
                onOpenBrinquedosTab();
                return;
              }
              if (value == 'settings') {
                onOpenSettings();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'toys',
                child: Text('Ver brinquedos'),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Text('Configura\u00e7\u00f5es'),
              ),
            ],
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: UiTokens.primarySoft,
                borderRadius: BorderRadius.circular(UiTokens.radiusLg),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.more_horiz,
                color: colorScheme.onSurface,
              ),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    icon,
                    const SizedBox(width: UiTokens.spacingSm),
                    Expanded(child: copy),
                    const SizedBox(width: UiTokens.spacingXs),
                    menuButton,
                  ],
                ),
                const SizedBox(height: UiTokens.spacingXs),
                Align(
                  alignment: Alignment.centerRight,
                  child: suggestButton,
                ),
              ],
            );
          }

          return Row(
            children: [
              icon,
              const SizedBox(width: UiTokens.spacingSm),
              Expanded(child: copy),
              const SizedBox(width: UiTokens.spacingSm),
              suggestButton,
              const SizedBox(width: UiTokens.spacingXs),
              menuButton,
            ],
          );
        },
      ),
    );
  }
}

class _AvailableToysGridCard extends StatelessWidget {
  final List<RoundToyWithBox> items;
  final ValueChanged<String> onOpenToy;
  final Widget emptyState;
  final String emptyTitle;
  final String emptyCounterText;
  final String activeItemsTitle;
  final bool preferSingleRowLayout;
  final bool assemblyMode;
  final Map<String, bool> checklistByToyId;
  final Map<String, String> categoryNamesById;
  final VoidCallback? onToggleAssemblyMode;
  final ValueChanged<String>? onToggleCollected;

  const _AvailableToysGridCard({
    required this.items,
    required this.onOpenToy,
    required this.emptyState,
    required this.emptyTitle,
    required this.emptyCounterText,
    this.activeItemsTitle = 'Brinquedos disponíveis',
    this.preferSingleRowLayout = false,
    this.assemblyMode = false,
    this.checklistByToyId = const <String, bool>{},
    this.categoryNamesById = const <String, String>{},
    this.onToggleAssemblyMode,
    this.onToggleCollected,
  });

  String _categoryNameFor(RoundToyWithBox item) {
    final categoryId = item.toy.categoryId.trim();
    if (categoryId.isEmpty) return 'Sem categoria';

    final categoryName = categoryNamesById[categoryId]?.trim();
    if (categoryName != null && categoryName.isNotEmpty) return categoryName;

    final fallback = categoryId.replaceAll('_', ' ').trim();
    if (fallback.isEmpty) return 'Sem categoria';
    return fallback[0].toUpperCase() + fallback.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = RoundChecklistProgress.fromToyIds(
      items.map((item) => item.toy.id),
      checklistByToyId,
    );
    final hasItems = items.isNotEmpty;
    final title = items.isEmpty
        ? emptyTitle
        : assemblyMode
            ? 'Montar rodada'
            : activeItemsTitle;
    final counterText = items.isEmpty
        ? emptyCounterText
        : assemblyMode
            ? progress.label
            : '${items.length} itens';

    Widget buildTitle() {
      return Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: UiTokens.textTitle.copyWith(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurface,
        ),
      );
    }

    Widget buildCounterChip() {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UiTokens.spacingSm,
          vertical: UiTokens.spacingXs,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(UiTokens.radiusLg),
        ),
        child: Text(
          counterText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: UiTokens.textCaption.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    Widget? buildModeButton() {
      if (!hasItems || onToggleAssemblyMode == null) return null;
      return TextButton.icon(
        onPressed: onToggleAssemblyMode,
        icon: Icon(
          assemblyMode ? Icons.list_alt_rounded : Icons.checklist_rtl_rounded,
          size: 18,
        ),
        label: Text(assemblyMode ? 'Detalhes' : 'Montar'),
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(
            horizontal: UiTokens.spacingXs,
          ),
          textStyle: UiTokens.textButton.copyWith(fontSize: 12),
        ),
      );
    }

    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 390;
              final modeButton = buildModeButton();

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: buildTitle()),
                        if (modeButton != null) ...[
                          const SizedBox(width: UiTokens.spacingXs),
                          modeButton,
                        ],
                      ],
                    ),
                    const SizedBox(height: UiTokens.spacingXs),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      child: buildCounterChip(),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: buildTitle()),
                  const SizedBox(width: UiTokens.spacingXs),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: buildCounterChip(),
                    ),
                  ),
                  if (modeButton != null) ...[
                    const SizedBox(width: UiTokens.spacingXs),
                    modeButton,
                  ],
                ],
              );
            },
          ),
          if (assemblyMode && hasItems) ...[
            const SizedBox(height: UiTokens.spacingXs),
            ClipRRect(
              borderRadius: BorderRadius.circular(UiTokens.radiusSm),
              child: LinearProgressIndicator(
                value: progress.fraction,
                minHeight: 6,
                backgroundColor: UiTokens.primarySoft,
                color: progress.isReady
                    ? UiTokens.success
                    : UiTokens.primaryStrong,
              ),
            ),
          ],
          const SizedBox(height: UiTokens.spacingSm),
          Expanded(
            child: items.isEmpty
                ? emptyState
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          preferSingleRowLayout && constraints.maxWidth >= 560
                              ? math.min(5, math.max(items.length, 1))
                              : constraints.maxWidth >= 840
                                  ? 5
                                  : constraints.maxWidth >= 390
                                      ? 4
                                      : 3;
                      const gridSpacing = 12.0;
                      final tileWidth =
                          (constraints.maxWidth - gridSpacing * (columns - 1)) /
                              columns;
                      final tileExtent = (tileWidth + 52).clamp(132.0, 224.0);

                      return GridView.builder(
                        padding: const EdgeInsets.only(top: UiTokens.spacingXs),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: gridSpacing,
                          mainAxisSpacing: gridSpacing,
                          mainAxisExtent: tileExtent.toDouble(),
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isCollected =
                              checklistByToyId[item.toy.id] == true;
                          return _RoundToyGridItem(
                            item: item,
                            categoryName: _categoryNameFor(item),
                            isCollected: assemblyMode && isCollected,
                            onTap: () {
                              if (assemblyMode) {
                                onToggleCollected?.call(item.toy.id);
                                return;
                              }
                              onOpenToy(item.toy.id);
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

class _RoundToyGridItem extends StatelessWidget {
  final RoundToyWithBox item;
  final String categoryName;
  final bool isCollected;
  final VoidCallback onTap;

  const _RoundToyGridItem({
    required this.item,
    required this.categoryName,
    required this.isCollected,
    required this.onTap,
  });

  String _locationLabel() {
    final box = item.box;
    final locationText = (item.toy.locationText ?? '').trim();

    if (box != null) {
      final local = box.local.trim();
      if (local.isEmpty) return 'Caixa ${box.number}';
      return 'Caixa ${box.number} - $local';
    }

    if (locationText.isNotEmpty) return locationText;
    return 'Sem caixa';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name =
        item.toy.name.trim().isEmpty ? 'Sem nome' : item.toy.name.trim();
    final locationLabel = _locationLabel();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCollected ? UiTokens.primaryStrong : Colors.transparent,
              width: isCollected ? 1.4 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: UiTokens.shadow,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(UiTokens.spacingXs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _GridToyPhoto(
                  imagePath: item.toy.photoPath,
                  isCollected: isCollected,
                ),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textMicro.copyWith(
                  fontSize: 13,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                categoryName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textMicro.copyWith(
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: UiTokens.primaryStrong,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                locationLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textMicro.copyWith(
                  fontSize: 11,
                  height: 1.15,
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

class _GridToyPhoto extends StatelessWidget {
  final String? imagePath;
  final bool isCollected;

  const _GridToyPhoto({
    required this.imagePath,
    this.isCollected = false,
  });

  @override
  Widget build(BuildContext context) {
    final path = imagePath?.trim();
    final image = SizedBox.expand(
      child: path == null || path.isEmpty
          ? const _GridToyPlaceholder()
          : Image.file(
              File(path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => const _GridToyPlaceholder(),
            ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(UiTokens.radiusSm),
      child: isCollected
          ? Stack(
              fit: StackFit.expand,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: image,
                ),
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.24),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: UiTokens.primaryStrong,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: UiTokens.shadow,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            )
          : image,
    );
  }
}

class _GridToyPlaceholder extends StatelessWidget {
  const _GridToyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: UiTokens.primarySoft,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 22,
        color: UiTokens.textSecondary,
      ),
    );
  }
}

class _HomeSuggestionEmptyState extends StatelessWidget {
  final Future<List<RoundToyWithBox>> suggestionFuture;
  final ValueChanged<String> onOpenToy;
  final Future<void> Function(List<RoundToyWithBox> suggestion)?
      onUseSuggestion;
  final bool usingSuggestion;

  const _HomeSuggestionEmptyState({
    required this.suggestionFuture,
    required this.onOpenToy,
    required this.onUseSuggestion,
    required this.usingSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<RoundToyWithBox>>(
      future: suggestionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final suggestion = snapshot.data ?? const <RoundToyWithBox>[];
        if (suggestion.isEmpty) {
          return Center(
            child: Text(
              'Cadastre brinquedos para montar uma sugest\u00e3o.',
              textAlign: TextAlign.center,
              style: UiTokens.textBody.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final preview = suggestion.take(8).toList(growable: false);

        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tileSize = math.min(
                    58.0,
                    (constraints.maxWidth - 30) / 4,
                  );

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final item in preview)
                          _SuggestionToyThumb(
                            item: item,
                            size: tileSize,
                            onTap: () => onOpenToy(item.toy.id),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: UiTokens.spacingSm),
            SizedBox(
              height: 40,
              child: FilledButton.icon(
                onPressed: onUseSuggestion == null || usingSuggestion
                    ? null
                    : () => onUseSuggestion!(suggestion),
                icon: usingSuggestion
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Usar sugest\u00e3o'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiTokens.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UiTokens.radiusMd),
                  ),
                  textStyle: UiTokens.textButton.copyWith(fontSize: 13),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SuggestionToyThumb extends StatelessWidget {
  final RoundToyWithBox item;
  final double size;
  final VoidCallback onTap;

  const _SuggestionToyThumb({
    required this.item,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        item.toy.name.trim().isEmpty ? 'Brinquedo sugerido' : item.toy.name;

    return Tooltip(
      message: name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UiTokens.radiusMd),
          child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(UiTokens.radiusMd),
              boxShadow: const [
                BoxShadow(
                  color: UiTokens.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: _GridToyPhoto(imagePath: item.toy.photoPath),
          ),
        ),
      ),
    );
  }
}
