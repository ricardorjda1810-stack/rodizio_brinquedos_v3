import 'dart:io';

import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height * 0.7;

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
                style: UiTokens.textTitle.copyWith(
                  fontSize: 22,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: UiTokens.spacingXs),
              Text(
                'Com base no planejamento de hoje',
                style: UiTokens.textBody.copyWith(
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
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: UiTokens.spacingSm),
                  Expanded(
                    child: FilledButton(
                      onPressed: toys.isEmpty
                          ? null
                          : () => Navigator.of(context).pop(toys),
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
        color: UiTokens.primarySoft,
        borderRadius: BorderRadius.circular(UiTokens.radiusMd),
      ),
      child: Text(
        count == 1 ? '1 brinquedo' : '$count brinquedos',
        style: UiTokens.textTitle.copyWith(
          color: UiTokens.primaryStrong,
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
            style: UiTokens.textMicro.copyWith(
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
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const _SuggestionToyPlaceholder(),
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

class _EmptySuggestionState extends StatelessWidget {
  const _EmptySuggestionState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nenhum brinquedo dispon\u00edvel',
        textAlign: TextAlign.center,
        style: UiTokens.textBody.copyWith(
          color: UiTokens.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
