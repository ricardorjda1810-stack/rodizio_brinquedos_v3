import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';

class ActiveRoundList extends StatelessWidget {
  static const double _categoryColumnWidth = 196;
  static const double _categoryColumnGap = UiTokens.l;
  final RoundRepository roundRepository;
  final ToyRepository toyRepository;
  final bool dense;
  final int? maxItems;
  final String title;
  final bool showPickupSwitch;
  final Set<String> pickedToyIds;
  final ValueChanged<String>? onTogglePicked;

  const ActiveRoundList({
    super.key,
    required this.roundRepository,
    required this.toyRepository,
    this.dense = false,
    this.maxItems,
    this.title = 'Rodada ativa',
    this.showPickupSwitch = false,
    this.pickedToyIds = const <String>{},
    this.onTogglePicked,
  });

  void _openToyDetail(BuildContext context, String toyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToyDetailPage(
          toyId: toyId,
          toyRepository: toyRepository,
        ),
      ),
    );
  }

  Widget _thumb(BuildContext context, String? path, {required bool isPicked}) {
    return RoundToyThumb(
      path: path,
      dense: dense,
      isPicked: isPicked,
    );
  }

  String _subtitle(RoundToyWithBox item) {
    final box = item.box;
    final localExtra = (item.toy.locationText ?? '').trim();

    if (box != null) {
      final local = box.local.trim();
      if (local.isEmpty) return 'Caixa ${box.number}';
      return 'Caixa ${box.number} - $local';
    }

    if (localExtra.isNotEmpty) return localExtra;
    return 'Sem caixa';
  }

  _CategoryVisual _categoryVisualFor(
    BuildContext context,
    String categoryId,
    String categoryName,
  ) {
    final normalized = categoryId.trim().toLowerCase();

    switch (normalized) {
      case 'veiculos':
        return _CategoryVisual(
          icon: Icons.directions_car_filled_outlined,
          color: Colors.blue.shade600,
          name: categoryName,
        );
      case 'bonecos':
        return _CategoryVisual(
          icon: Icons.face_3_outlined,
          color: Colors.pink.shade500,
          name: categoryName,
        );
      case 'montagem':
        return _CategoryVisual(
          icon: Icons.extension_outlined,
          color: Colors.orange.shade700,
          name: categoryName,
        );
      case 'livros':
        return _CategoryVisual(
          icon: Icons.menu_book_outlined,
          color: Colors.teal.shade600,
          name: categoryName,
        );
      case 'jogos':
        return _CategoryVisual(
          icon: Icons.sports_esports_outlined,
          color: Colors.deepPurple.shade400,
          name: categoryName,
        );
      case 'faz_de_conta':
        return _CategoryVisual(
          icon: Icons.theater_comedy_outlined,
          color: Colors.indigo.shade400,
          name: categoryName,
        );
      case 'artes':
        return _CategoryVisual(
          icon: Icons.palette_outlined,
          color: Colors.redAccent.shade200,
          name: categoryName,
        );
      case 'musica':
        return _CategoryVisual(
          icon: Icons.music_note_outlined,
          color: Colors.green.shade600,
          name: categoryName,
        );
      case 'banho':
        return _CategoryVisual(
          icon: Icons.bathtub_outlined,
          color: Colors.cyan.shade700,
          name: categoryName,
        );
      default:
        return _CategoryVisual(
          icon: Icons.category_outlined,
          color: Theme.of(context).colorScheme.secondary,
          name: categoryName,
        );
    }
  }

  Widget _categoryInfo(
    BuildContext context,
    RoundToyWithBox item,
    Map<String, String> categoryNamesById,
  ) {
    final categoryId = item.toy.categoryId.trim();
    final fallbackName = categoryId.isEmpty
        ? 'Sem categoria'
        : 'Categoria ${item.toy.categoryId}';
    final categoryName = categoryNamesById[categoryId] ?? fallbackName;
    final visual = _categoryVisualFor(context, categoryId, categoryName);
    final monoTextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: _categoryColumnWidth,
        child: Row(
          children: [
            SizedBox(
              width: dense ? 18 : 20,
              child: Icon(
                visual.icon,
                size: dense ? 16 : 18,
                color: visual.color,
              ),
            ),
            const SizedBox(width: UiTokens.xs),
            Expanded(
              child: Text(
                visual.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: monoTextColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryHeader(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: _categoryColumnWidth,
        child: Text(
          'Categoria',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  Widget _categoryHeaderRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? UiTokens.xs : UiTokens.s),
      child: Row(
        children: [
          SizedBox(width: dense ? 40.0 : 52.0),
          const SizedBox(width: UiTokens.s),
          const Expanded(flex: 5, child: SizedBox()),
          const SizedBox(width: _categoryColumnGap),
          Expanded(
            flex: 4,
            child: _categoryHeader(context),
          ),
          if (showPickupSwitch) const SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryDefinition>>(
      stream: toyRepository.watchCategories(),
      builder: (context, categoriesSnapshot) {
        final categories =
            categoriesSnapshot.data ?? const <CategoryDefinition>[];
        final categoryNamesById = <String, String>{
          for (final c in categories) c.id: c.name.trim(),
        };

        return StreamBuilder<List<RoundToyWithBox>>(
          stream: roundRepository.watchActiveRoundToysWithBox(),
          builder: (context, snapshot) {
            final allItems = snapshot.data ?? const <RoundToyWithBox>[];
            if (allItems.isEmpty) return const SizedBox.shrink();

            final orderedItems = showPickupSwitch
                ? <RoundToyWithBox>[
                    ...allItems
                        .where((it) => !pickedToyIds.contains(it.toy.id)),
                    ...allItems.where((it) => pickedToyIds.contains(it.toy.id)),
                  ]
                : allItems;
            final items = maxItems == null
                ? orderedItems
                : orderedItems
                    .take(maxItems!.clamp(0, orderedItems.length))
                    .toList();

            return Padding(
              padding: EdgeInsets.only(bottom: dense ? UiTokens.s : UiTokens.m),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(dense ? UiTokens.s : UiTokens.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      SizedBox(height: dense ? UiTokens.xs : UiTokens.s),
                      _categoryHeaderRow(context),
                      ...List<Widget>.generate(items.length, (index) {
                        final item = items[index];
                        final isPicked = pickedToyIds.contains(item.toy.id);
                        final name = item.toy.name.trim().isEmpty
                            ? 'Sem nome'
                            : item.toy.name.trim();

                        return Column(
                          children: [
                            InkWell(
                              borderRadius:
                                  BorderRadius.circular(UiTokens.radiusButton),
                              onTap: () => _openToyDetail(context, item.toy.id),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: dense ? UiTokens.xs : UiTokens.s,
                                ),
                                child: Row(
                                  children: [
                                    _thumb(
                                      context,
                                      item.toy.photoPath,
                                      isPicked: isPicked,
                                    ),
                                    const SizedBox(width: UiTokens.s),
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _subtitle(item),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: _categoryColumnGap),
                                    Expanded(
                                      flex: 4,
                                      child: _categoryInfo(
                                        context,
                                        item,
                                        categoryNamesById,
                                      ),
                                    ),
                                    if (showPickupSwitch)
                                      Checkbox(
                                        value: isPicked,
                                        onChanged: (_) =>
                                            onTogglePicked?.call(item.toy.id),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < items.length - 1)
                              const Divider(height: 1, thickness: 0.6),
                          ],
                        );
                      }),
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

class _CategoryVisual {
  final IconData icon;
  final Color color;
  final String name;

  const _CategoryVisual({
    required this.icon,
    required this.color,
    required this.name,
  });
}

class RoundToyThumb extends StatelessWidget {
  final String? path;
  final bool dense;
  final bool isPicked;

  const RoundToyThumb({
    super.key,
    required this.path,
    this.dense = false,
    this.isPicked = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = (path ?? '').trim();
    final size = dense ? 40.0 : 52.0;

    Widget wrapWithPickedStyle(Widget child) {
      if (!isPicked) return child;
      return ColorFiltered(
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
        child: child,
      );
    }

    if (p.isEmpty) {
      return wrapWithPickedStyle(Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(UiTokens.radiusPhoto),
        ),
        child: Icon(Icons.image_outlined, size: dense ? 18 : 22),
      ));
    }

    return wrapWithPickedStyle(ClipRRect(
      borderRadius: BorderRadius.circular(UiTokens.radiusPhoto),
      child: Image.file(
        File(p),
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) {
          return Container(
            width: size,
            height: size,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(Icons.broken_image_outlined, size: dense ? 18 : 22),
          );
        },
      ),
    ));
  }
}
