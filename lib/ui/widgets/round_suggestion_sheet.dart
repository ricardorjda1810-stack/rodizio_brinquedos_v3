import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

Future<List<Toy>?> showRoundSuggestionPicker({
  required BuildContext context,
  required List<Toy> toys,
  required Map<String, String> categoryNamesById,
  required Map<String, Boxe> boxesById,
}) {
  final isIpad = context.usesTabletPresentation;
  final content = RoundSuggestionSheet(
    toys: toys,
    categoryNamesById: categoryNamesById,
    boxesById: boxesById,
  );

  if (isIpad) {
    return showDialog<List<Toy>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => content,
    );
  }

  return showModalBottomSheet<List<Toy>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => content,
  );
}

class RoundSuggestionSheet extends StatelessWidget {
  final List<Toy> toys;
  final Map<String, String> categoryNamesById;
  final Map<String, Boxe> boxesById;

  const RoundSuggestionSheet({
    super.key,
    required this.toys,
    required this.categoryNamesById,
    required this.boxesById,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isIpad = context.usesTabletPresentation;

    if (isIpad) {
      return _buildIpadDialog(context, size);
    }

    return _buildMobileSheet(context, size);
  }

  Widget _buildMobileSheet(BuildContext context, Size size) {
    final colorScheme = Theme.of(context).colorScheme;
    final height = size.height * 0.7;

    return SafeArea(
      top: false,
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: UiTokens.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            UiTokens.spacingMd,
            UiTokens.spacingSm,
            UiTokens.spacingMd,
            UiTokens.spacingMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: UiTokens.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: UiTokens.spacingMd),
              Text(
                'Sugest\u00e3o de rodada',
                style: context.appTypography.pageTitle.copyWith(
                  fontSize: 22,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              Text(
                'Com base no planejamento de hoje',
                style: context.appTypography.body.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: UiTokens.spacingMd),
              _SuggestionSummary(count: toys.length),
              const SizedBox(height: UiTokens.spacingMd),
              Expanded(
                child: toys.isEmpty
                    ? const _EmptySuggestionState()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 840
                              ? 5
                              : constraints.maxWidth >= 390
                                  ? 4
                                  : 3;
                          const gridSpacing = 12.0;
                          final tileWidth = (constraints.maxWidth -
                                  gridSpacing * (columns - 1)) /
                              columns;
                          final tileExtent =
                              (tileWidth + 56).clamp(132.0, 224.0);

                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: gridSpacing,
                              mainAxisSpacing: gridSpacing,
                              mainAxisExtent: tileExtent.toDouble(),
                            ),
                            itemCount: toys.length,
                            itemBuilder: (context, index) {
                              final toy = toys[index];
                              return _SuggestedToyCard(toy: toy);
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: UiTokens.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: UiTokens.actionOrangeDark,
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: UiTokens.spacingSm),
                  Expanded(
                    child: FilledButton(
                      onPressed: toys.isEmpty
                          ? null
                          : () => Navigator.of(context).pop(toys),
                      style: FilledButton.styleFrom(
                        backgroundColor: UiTokens.actionOrange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            UiTokens.actionOrange.withValues(alpha: 0.32),
                        disabledForegroundColor:
                            Colors.white.withValues(alpha: 0.82),
                      ),
                      child: const Text('Usar sugest\u00e3o'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIpadDialog(BuildContext context, Size size) {
    final dialogWidth = math.min(size.width - 64, 1040.0);
    final maxDialogHeight = math.max(520.0, size.height - 64);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        width: dialogWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxDialogHeight),
          child: Container(
            decoration: BoxDecoration(
              color: _RoundSuggestionPalette.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _RoundSuggestionPalette.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x260C1A12),
                  blurRadius: 34,
                  offset: Offset(0, 18),
                  spreadRadius: -18,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IpadSuggestionHeader(count: toys.length),
                  const SizedBox(height: 22),
                  Flexible(
                    child: toys.isEmpty
                        ? const _IpadEmptySuggestionState()
                        : _IpadSuggestionBody(
                            toys: toys,
                            categoryNamesById: categoryNamesById,
                            boxesById: boxesById,
                          ),
                  ),
                  const SizedBox(height: 22),
                  _IpadSuggestionFooter(hasToys: toys.isNotEmpty, toys: toys),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionSummary extends StatelessWidget {
  final int count;

  const _SuggestionSummary({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: UiTokens.spacingMd,
        vertical: UiTokens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: _RoundSuggestionPalette.surfaceWarm,
        borderRadius: BorderRadius.circular(UiTokens.radiusMd),
        border: Border.all(color: _RoundSuggestionPalette.border),
      ),
      child: Text(
        count == 1 ? '1 brinquedo' : '$count brinquedos',
        style: context.appTypography.pageTitle.copyWith(
          color: _RoundSuggestionPalette.orangeDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SuggestedToyCard extends StatelessWidget {
  final Toy toy;

  const _SuggestedToyCard({required this.toy});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = toy.name.trim().isEmpty ? 'Sem nome' : toy.name.trim();

    return Container(
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
            child: _SuggestionToyPhoto(imagePath: toy.photoPath),
          ),
          const SizedBox(height: UiTokens.spacingXs),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.appTypography.micro.copyWith(
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundSuggestionPalette {
  _RoundSuggestionPalette._();

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceWarm = Color(0xFFFFF8F1);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeDark = Color(0xFFC2410C);
  static const Color orangeLight = Color(0xFFFFF3E8);
  static const Color orangeBorder = Color(0xFFFFD2AE);
  static const Color text = Color(0xFF25180A);
  static const Color textMid = Color(0xFF6B4F30);
  static const Color textMuted = Color(0xFFA8896A);
  static const Color border = Color(0xFFF3E2D0);
}

class _IpadSuggestionHeader extends StatelessWidget {
  final int count;

  const _IpadSuggestionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final badgeText = count == 1 ? '1 brinquedo' : '$count brinquedos';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: _RoundSuggestionPalette.orangeLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _RoundSuggestionPalette.orangeBorder),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: _RoundSuggestionPalette.orange,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sugestão de rodada',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTypography.pageTitle.copyWith(
                  color: _RoundSuggestionPalette.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Com base no planejamento de hoje',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTypography.body.copyWith(
                  color: _RoundSuggestionPalette.textMid,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _RoundSuggestionPalette.orangeLight,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _RoundSuggestionPalette.orangeBorder),
          ),
          child: Text(
            badgeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appTypography.caption.copyWith(
              color: _RoundSuggestionPalette.orangeDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _IpadSuggestionBody extends StatelessWidget {
  final List<Toy> toys;
  final Map<String, String> categoryNamesById;
  final Map<String, Boxe> boxesById;

  const _IpadSuggestionBody({
    required this.toys,
    required this.categoryNamesById,
    required this.boxesById,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showSidePanel = constraints.maxWidth >= 780;
        if (!showSidePanel) {
          return _IpadSuggestedToyGrid(
            toys: toys,
            categoryNamesById: categoryNamesById,
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _IpadSuggestedToyGrid(
                toys: toys,
                categoryNamesById: categoryNamesById,
              ),
            ),
            const SizedBox(width: 18),
            SizedBox(
              width: 268,
              child: _IpadSuggestionSidePanel(
                toys: toys,
                boxesById: boxesById,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IpadSuggestedToyGrid extends StatelessWidget {
  final List<Toy> toys;
  final Map<String, String> categoryNamesById;

  const _IpadSuggestedToyGrid({
    required this.toys,
    required this.categoryNamesById,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620
            ? 4
            : constraints.maxWidth >= 470
                ? 3
                : 2;
        const gridSpacing = 14.0;
        final tileWidth =
            (constraints.maxWidth - gridSpacing * (columns - 1)) / columns;
        final tileExtent = (tileWidth * 1.22).clamp(214.0, 246.0);
        final rowCount = (toys.length / columns).ceil();
        final naturalHeight =
            rowCount * tileExtent + math.max(0, rowCount - 1) * gridSpacing;
        final maxHeight = math.max(260.0, constraints.maxHeight);
        final gridHeight = math.min(naturalHeight, maxHeight);

        return SizedBox(
          height: gridHeight,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: naturalHeight > gridHeight
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: gridSpacing,
              mainAxisSpacing: gridSpacing,
              mainAxisExtent: tileExtent.toDouble(),
            ),
            itemCount: toys.length,
            itemBuilder: (context, index) {
              final toy = toys[index];
              final categoryId = toy.categoryId.trim();
              final categoryLabel = categoryId.isEmpty
                  ? 'Sem categoria'
                  : categoryNamesById[categoryId] ?? categoryId;

              return _IpadSuggestedToyCard(
                toy: toy,
                categoryLabel: categoryLabel,
              );
            },
          ),
        );
      },
    );
  }
}

class _IpadSuggestedToyCard extends StatelessWidget {
  final Toy toy;
  final String categoryLabel;

  const _IpadSuggestedToyCard({
    required this.toy,
    required this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final name = toy.name.trim().isEmpty ? 'Sem nome' : toy.name.trim();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _RoundSuggestionPalette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _RoundSuggestionPalette.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120C1A12),
            blurRadius: 16,
            offset: Offset(0, 8),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _SuggestionToyPhoto(imagePath: toy.photoPath)),
          const SizedBox(height: 10),
          SizedBox(
            height: 78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 34,
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.appTypography.caption.copyWith(
                      color: _RoundSuggestionPalette.text,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  categoryLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.appTypography.micro.copyWith(
                    color: _RoundSuggestionPalette.textMuted,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
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

class _IpadSuggestionSidePanel extends StatelessWidget {
  final List<Toy> toys;
  final Map<String, Boxe> boxesById;

  const _IpadSuggestionSidePanel({
    required this.toys,
    required this.boxesById,
  });

  @override
  Widget build(BuildContext context) {
    final categoryCount = toys
        .map((toy) => toy.categoryId.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .length;
    final boxCount = toys
        .map((toy) => toy.boxId?.trim())
        .where((id) => id != null && id.isNotEmpty && boxesById.containsKey(id))
        .toSet()
        .length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _RoundSuggestionPalette.surfaceWarm,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _RoundSuggestionPalette.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _RoundSuggestionPalette.orangeLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _RoundSuggestionPalette.orangeBorder,
                  ),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: _RoundSuggestionPalette.orange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Resumo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appTypography.sectionTitle.copyWith(
                    color: _RoundSuggestionPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _IpadSuggestionMetric(
            label: 'Brinquedos',
            value: toys.length.toString(),
          ),
          const SizedBox(height: 10),
          _IpadSuggestionMetric(
            label: 'Categorias',
            value: categoryCount.toString(),
          ),
          if (boxCount > 0) ...[
            const SizedBox(height: 10),
            _IpadSuggestionMetric(
              label: 'Caixas',
              value: boxCount.toString(),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _RoundSuggestionPalette.orangeLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _RoundSuggestionPalette.orangeBorder),
            ),
            child: Text(
              'Uma seleção pronta para começar a brincadeira de hoje.',
              style: context.appTypography.caption.copyWith(
                color: _RoundSuggestionPalette.textMid,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IpadSuggestionMetric extends StatelessWidget {
  final String label;
  final String value;

  const _IpadSuggestionMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appTypography.caption.copyWith(
              color: _RoundSuggestionPalette.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appTypography.caption.copyWith(
            color: _RoundSuggestionPalette.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _IpadSuggestionFooter extends StatelessWidget {
  final bool hasToys;
  final List<Toy> toys;

  const _IpadSuggestionFooter({
    required this.hasToys,
    required this.toys,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(132, 52),
            foregroundColor: _RoundSuggestionPalette.orangeDark,
            side: const BorderSide(
              color: _RoundSuggestionPalette.orangeBorder,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: context.appTypography.button.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: hasToys ? () => Navigator.of(context).pop(toys) : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size(168, 52),
            backgroundColor: _RoundSuggestionPalette.orange,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                _RoundSuggestionPalette.orange.withValues(alpha: 0.32),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.82),
            elevation: 4,
            shadowColor: const Color(0x59F97316),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: context.appTypography.button.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          child: const Text('Usar sugestão'),
        ),
      ],
    );
  }
}

class _IpadEmptySuggestionState extends StatelessWidget {
  const _IpadEmptySuggestionState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _RoundSuggestionPalette.surfaceWarm,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _RoundSuggestionPalette.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _RoundSuggestionPalette.orangeLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _RoundSuggestionPalette.orangeBorder),
            ),
            child: const Icon(
              Icons.toys_outlined,
              color: _RoundSuggestionPalette.orange,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum brinquedo disponível',
            textAlign: TextAlign.center,
            style: context.appTypography.sectionTitle.copyWith(
              color: _RoundSuggestionPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionToyPhoto extends StatelessWidget {
  final String? imagePath;

  const _SuggestionToyPhoto({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final path = imagePath?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox.expand(
        child: path == null || path.isEmpty
            ? const _SuggestionToyPlaceholder()
            : path.startsWith('assets/')
                ? Image.asset(
                    path,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        const _SuggestionToyPlaceholder(),
                  )
                : Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        const _SuggestionToyPlaceholder(),
                  ),
      ),
    );
  }
}

class _SuggestionToyPlaceholder extends StatelessWidget {
  const _SuggestionToyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F0E6),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 22,
        color: Color(0xFFA8896A),
      ),
    );
  }
}

class _EmptySuggestionState extends StatelessWidget {
  const _EmptySuggestionState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nenhum brinquedo dispon\u00edvel',
        textAlign: TextAlign.center,
        style: context.appTypography.body.copyWith(
          color: UiTokens.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
