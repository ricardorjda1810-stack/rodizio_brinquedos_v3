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

  const RodadaPage({
    super.key,
    required this.roundRepository,
    required this.toyRepository,
    required this.purchaseService,
    required this.onOpenRodizioTab,
    required this.onOpenBrinquedosTab,
    required this.onOpenSettings,
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
  Future<List<RoundToyWithBox>>? _homeSuggestionFuture;

  void _openToyDetail(String toyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToyDetailPage(
          toyId: toyId,
          toyRepository: widget.toyRepository,
          purchaseService: widget.purchaseService,
        ),
      ),
    );
  }

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

  Future<void> _useHomeSuggestion(List<RoundToyWithBox> suggestion) async {
    if (_startingRound) return;

    setState(() => _startingRound = true);
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
        setState(() => _startingRound = false);
      }
    }
  }

  Future<void> _openRoundSuggestionSheet(
    Map<String, String> categoryNamesById,
  ) async {
    if (_loadingSuggestion) return;

    setState(() => _loadingSuggestion = true);
    try {
      final suggestedToys = await widget.roundRepository.suggestRoundForToday();
      final boxes = await widget.toyRepository.watchBoxes().first;
      if (!mounted) return;

      unawaited(AppAnalytics.logSuggestionOpened(source: 'round_page'));
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
        source: 'round_page',
      );
      await AppAnalytics.logRoundCreated(
        toyCount: selectedToys.length,
        source: 'round_suggestion',
      );
      await _logFirstRoundCreatedOnce(selectedToys.length);
      if (!mounted) return;

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
        setState(() => _loadingSuggestion = false);
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

  @override
  Widget build(BuildContext context) {
    final bottomNavigationReserve =
        AppBottomNavigation.reservedScrollPadding(context) + UiTokens.spacingLg;

    return StreamBuilder<List<RoundToyWithBox>>(
      stream: widget.roundRepository.watchActiveRoundToysWithBox(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? const <RoundToyWithBox>[];

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
            final emptyGridCardHeight = desiredGridCardHeight * 0.68;
            final homeSuggestionFuture =
                _homeSuggestionFuture ??= _loadHomeSuggestion();

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                UiTokens.spacingMd,
                0,
                UiTokens.spacingMd,
                bottomNavigationReserve,
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
                        : desiredGridCardHeight,
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
                              final checklistByToyId = checklistSnapshot.data ??
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
  }
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
            : 'Brinquedos dispon\u00edveis';
    final counterText = items.isEmpty
        ? emptyCounterText
        : assemblyMode
            ? progress.label
            : '${items.length} itens';

    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textTitle.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
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
              ),
              if (hasItems && onToggleAssemblyMode != null) ...[
                const SizedBox(width: UiTokens.spacingXs),
                TextButton.icon(
                  onPressed: onToggleAssemblyMode,
                  icon: Icon(
                    assemblyMode
                        ? Icons.list_alt_rounded
                        : Icons.checklist_rtl_rounded,
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
                ),
              ],
            ],
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
                      final columns = constraints.maxWidth >= 840
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
