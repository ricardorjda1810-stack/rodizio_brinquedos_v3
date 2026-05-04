import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/services/premium_gate.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

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
  static const String _paywallSeenAfterFirstRoundKey =
      'paywall_seen_after_first_round';

  bool _startingRound = false;
  bool _checkingAutoPaywall = false;
  bool _autoPaywallQueued = false;

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

  Future<void> _startRound() async {
    if (_startingRound) return;
    final allowed = await PremiumGate.ensurePremium(
      context: context,
      purchaseService: widget.purchaseService,
    );
    if (!allowed) return;

    setState(() => _startingRound = true);
    try {
      final result = await widget.roundRepository.startRound();
      if (!mounted) return;

      if (!result.created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nenhum brinquedo dispon\u00edvel para iniciar a rodada.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Rodada criada com ${result.selectedCount} brinquedos.'),
        ),
      );
      widget.onOpenRodizioTab();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'N\u00e3o foi poss\u00edvel iniciar o rod\u00edzio: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _startingRound = false);
      }
    }
  }

  void _schedulePaywallAfterFirstRound() {
    if (_autoPaywallQueued || _checkingAutoPaywall) return;
    if (widget.purchaseService.isPremium) return;

    _autoPaywallQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPaywallAfterFirstRoundIfNeeded();
    });
  }

  Future<void> _showPaywallAfterFirstRoundIfNeeded() async {
    if (!mounted || _checkingAutoPaywall) return;
    if (widget.purchaseService.isPremium) return;

    _checkingAutoPaywall = true;
    try {
      final preferences = await SharedPreferences.getInstance();
      final hasSeen =
          preferences.getBool(_paywallSeenAfterFirstRoundKey) ?? false;

      if (hasSeen || widget.purchaseService.isPremium) return;

      await preferences.setBool(_paywallSeenAfterFirstRoundKey, true);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaywallPage(
            purchaseService: widget.purchaseService,
          ),
        ),
      );
    } finally {
      _checkingAutoPaywall = false;
    }
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
        if (items.isNotEmpty) {
          _schedulePaywallAfterFirstRound();
        }

        return StreamBuilder<List<CategoryDefinition>>(
          stream: widget.toyRepository.watchCategories(),
          builder: (context, categoriesSnapshot) {
            final categories =
                categoriesSnapshot.data ?? const <CategoryDefinition>[];
            final categoryNamesById = <String, String>{
              for (final category in categories) category.id: category.name,
            };

            return LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = MediaQuery.sizeOf(context).height;
                final maxGridHeight = math.min(
                  screenHeight * 0.5,
                  constraints.maxHeight * 0.56,
                );

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    UiTokens.spacingMd,
                    0,
                    UiTokens.spacingMd,
                    bottomNavigationReserve,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _HomeStatCard(
                              icon: Icons.play_circle_outline,
                              label: 'Rodada ativa',
                              value: '${items.length}',
                              helper: items.isEmpty
                                  ? 'nenhum item agora'
                                  : 'itens dispon\u00edveis',
                            ),
                          ),
                          const SizedBox(width: UiTokens.spacingSm),
                          Expanded(
                            child: _HomeStatCard(
                              icon: Icons.auto_awesome_outlined,
                              label: 'Clima do dia',
                              value: items.isEmpty ? 'Livre' : 'Pronto',
                              helper: items.isEmpty
                                  ? 'organize com calma'
                                  : 'tudo separado',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: UiTokens.spacingSm),
                      _RoundMomentCard(
                        itemCount: items.length,
                        onOpenBrinquedosTab: widget.onOpenBrinquedosTab,
                        onOpenSettings: widget.onOpenSettings,
                      ),
                      const SizedBox(height: UiTokens.spacingSm),
                      Flexible(
                        child: LayoutBuilder(
                          builder: (context, gridConstraints) {
                            final gridHeight = math.min(
                              maxGridHeight,
                              gridConstraints.maxHeight,
                            );

                            return Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: double.infinity,
                                height: gridHeight,
                                child: _AvailableToysGridCard(
                                  items: items,
                                  categoryNamesById: categoryNamesById,
                                  onOpenToy: _openToyDetail,
                                  emptyState: _RodadaEmptyState(
                                    onAction:
                                        _startingRound ? null : _startRound,
                                    actionText: 'Criar rodada',
                                  ),
                                ),
                              ),
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

class _HomeStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String helper;

  const _HomeStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: UiTokens.primarySoft,
              borderRadius: BorderRadius.circular(UiTokens.radiusLg),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: UiTokens.primaryStrong,
            ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          Text(
            label,
            style: UiTokens.textCaption.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: UiTokens.spacingXs),
          Text(
            value,
            style: UiTokens.textSectionTitle.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            helper,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundMomentCard extends StatelessWidget {
  final int itemCount;
  final VoidCallback onOpenBrinquedosTab;
  final VoidCallback onOpenSettings;

  const _RoundMomentCard({
    required this.itemCount,
    required this.onOpenBrinquedosTab,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingSm),
      color: colorScheme.surface,
      child: Row(
        children: [
          Container(
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
          ),
          const SizedBox(width: UiTokens.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rodada do momento',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textSectionTitle.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: UiTokens.spacingXs),
                Text(
                  itemCount == 0
                      ? 'Crie uma rodada para come\u00e7ar.'
                      : '$itemCount brinquedos prontos para brincar.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: UiTokens.spacingXs),
          PopupMenuButton<String>(
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
          ),
        ],
      ),
    );
  }
}

class _AvailableToysGridCard extends StatelessWidget {
  final List<RoundToyWithBox> items;
  final Map<String, String> categoryNamesById;
  final ValueChanged<String> onOpenToy;
  final Widget emptyState;

  const _AvailableToysGridCard({
    required this.items,
    required this.categoryNamesById,
    required this.onOpenToy,
    required this.emptyState,
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
                  'Brinquedos dispon\u00edveis',
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
                  '${items.length} itens',
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
                ? Center(child: emptyState)
                : GridView.builder(
                    padding: const EdgeInsets.only(top: UiTokens.spacingXs),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.56,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _RoundToyGridItem(
                        item: item,
                        categoryLabel: _categoryLabelFor(item),
                        boxLabel: _boxLabelFor(item),
                        onTap: () => onOpenToy(item.toy.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _categoryLabelFor(RoundToyWithBox item) {
    final categoryId = item.toy.categoryId.trim();
    final label = categoryNamesById[categoryId]?.trim();
    if (label == null || label.isEmpty) return 'Outros';
    return label;
  }

  String _boxLabelFor(RoundToyWithBox item) {
    final box = item.box;
    if (box == null) return 'Sem caixa';

    return 'Caixa ${box.number}';
  }
}

class _RoundToyGridItem extends StatelessWidget {
  final RoundToyWithBox item;
  final String categoryLabel;
  final String boxLabel;
  final VoidCallback onTap;

  const _RoundToyGridItem({
    required this.item,
    required this.categoryLabel,
    required this.boxLabel,
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
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GridToyPhoto(imagePath: item.toy.photoPath),
              const SizedBox(height: 5),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textMicro.copyWith(
                  fontSize: 13,
                  height: 1.12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: UiTokens.primarySoft,
                  borderRadius: BorderRadius.circular(UiTokens.radiusSm),
                ),
                child: Text(
                  categoryLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: UiTokens.primaryStrong,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 11,
                    color: UiTokens.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      boxLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textMicro.copyWith(
                        fontSize: 11,
                        height: 1.1,
                        color: colorScheme.onSurfaceVariant,
                      ),
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

class _GridToyPhoto extends StatelessWidget {
  final String? imagePath;

  const _GridToyPhoto({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final path = imagePath?.trim();

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiTokens.radiusSm),
        child: path == null || path.isEmpty
            ? const _GridToyPlaceholder()
            : Image.file(
                File(path),
                fit: BoxFit.cover,
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

class _RodadaEmptyState extends StatelessWidget {
  final VoidCallback? onAction;
  final String actionText;

  const _RodadaEmptyState({
    required this.onAction,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UiTokens.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: UiTokens.primarySoft,
              borderRadius: BorderRadius.circular(UiTokens.radiusLg),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.toys_outlined,
              size: 30,
              color: UiTokens.primaryStrong,
            ),
          ),
          const SizedBox(height: UiTokens.spacingMd),
          Text(
            'Nenhuma rodada ativa',
            textAlign: TextAlign.center,
            style: UiTokens.textSectionTitle.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          Text(
            'Crie uma rodada para come\u00e7ar com os brinquedos dispon\u00edveis.',
            textAlign: TextAlign.center,
            style: UiTokens.textBody.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: UiTokens.spacingMd),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: UiTokens.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UiTokens.radiusMd),
                ),
                textStyle: UiTokens.textButton,
              ),
              child: Text(actionText),
            ),
          ),
        ],
      ),
    );
  }
}
