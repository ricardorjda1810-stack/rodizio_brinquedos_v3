import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/services/premium_gate.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/toy_row_item.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            UiTokens.spacingMd,
            0,
            UiTokens.spacingMd,
            bottomNavigationReserve,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: UiTokens.spacingMd),
              AppSurfaceCard(
                padding: const EdgeInsets.all(UiTokens.spacingMd),
                color: colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rodada do momento',
                            style: UiTokens.textSectionTitle.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: UiTokens.spacingXs),
                          Text(
                            items.isEmpty
                                ? 'Escolha os brinquedos dispon\u00edveis e monte uma rodada simples para o dia.'
                                : 'Abra a rodada, veja os itens ativos e acompanhe com toque leve.',
                            style: UiTokens.textBody.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: UiTokens.spacingSm),
                    PopupMenuButton<String>(
                      tooltip: 'Mais op\u00e7\u00f5es',
                      onSelected: (value) {
                        if (value == 'toys') {
                          widget.onOpenBrinquedosTab();
                          return;
                        }
                        if (value == 'settings') {
                          widget.onOpenSettings();
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: UiTokens.primarySoft,
                          borderRadius:
                              BorderRadius.circular(UiTokens.radiusLg),
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
              ),
              const SizedBox(height: UiTokens.spacingMd),
              _RodadaMainCard(
                itemCount: items.length,
                child: items.isEmpty
                    ? _RodadaEmptyState(
                        onAction: _startingRound ? null : _startRound,
                        actionText: 'Criar rodada',
                      )
                    : Column(
                        children: List<Widget>.generate(items.length, (index) {
                          final item = items[index];
                          final name = item.toy.name.trim().isEmpty
                              ? 'Sem nome'
                              : item.toy.name.trim();

                          return ToyRowItem(
                            name: name,
                            imagePath: item.toy.photoPath,
                            onTap: () => _openToyDetail(item.toy.id),
                            showDivider: index < items.length - 1,
                          );
                        }),
                      ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
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
          const SizedBox(height: UiTokens.spacingMd),
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
            style: UiTokens.textTitle.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: UiTokens.spacingXs),
          Text(
            helper,
            style: UiTokens.textCaption.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _RodadaMainCard extends StatelessWidget {
  final int itemCount;
  final Widget child;

  const _RodadaMainCard({
    required this.itemCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lista da rodada',
                  style: UiTokens.textSectionTitle.copyWith(
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
                  '$itemCount itens',
                  style: UiTokens.textCaption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UiTokens.spacingXs),
          Text(
            'Tudo em uma lista limpa para consultar rapidinho.',
            style: UiTokens.textBody.copyWith(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: UiTokens.spacingMd),
          child,
        ],
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
