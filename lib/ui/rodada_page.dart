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
            const gridTileHeight = 132.0;
            const gridCardPadding = 14.0;
            const gridHeaderReserve = 32.0;
            const twoRowsGridHeight =
                UiTokens.spacingXs + (gridTileHeight * 2) + gridSpacing;
            const desiredGridCardHeight = (gridCardPadding * 2) +
                gridHeaderReserve +
                UiTokens.spacingSm +
                twoRowsGridHeight;
            const emptyGridCardHeight = desiredGridCardHeight * 0.68;
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
                        : _AvailableToysGridCard(
                            items: items,
                            onOpenToy: _openToyDetail,
                            emptyTitle: 'Sugest\u00e3o para hoje',
                            emptyCounterText: '',
                            emptyState: _HomeSuggestionEmptyState(
                              suggestionFuture: homeSuggestionFuture,
                              onOpenToy: _openToyDetail,
                              onUseSuggestion:
                                  _startingRound ? null : _useHomeSuggestion,
                              usingSuggestion: _startingRound,
                            ),
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

  const _AvailableToysGridCard({
    required this.items,
    required this.onOpenToy,
    required this.emptyState,
    required this.emptyTitle,
    required this.emptyCounterText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  items.isEmpty ? emptyTitle : 'Brinquedos dispon\u00edveis',
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
                  items.isEmpty ? emptyCounterText : '${items.length} itens',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
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
                          return _RoundToyGridItem(
                            item: item,
                            onTap: () => onOpenToy(item.toy.id),
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
  final VoidCallback onTap;

  const _RoundToyGridItem({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name =
        item.toy.name.trim().isEmpty ? 'Sem nome' : item.toy.name.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
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
                child: _GridToyPhoto(imagePath: item.toy.photoPath),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textMicro.copyWith(
                  fontSize: 13,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
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

  const _GridToyPhoto({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final path = imagePath?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(UiTokens.radiusSm),
      child: SizedBox.expand(
        child: path == null || path.isEmpty
            ? const _GridToyPlaceholder()
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const _GridToyPlaceholder(),
              ),
      ),
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
