import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/toy_row_item.dart';

class RodadaPage extends StatefulWidget {
  final RoundRepository roundRepository;
  final ToyRepository toyRepository;
  final VoidCallback onOpenRodizioTab;
  final VoidCallback onOpenBrinquedosTab;
  final VoidCallback onOpenSettings;

  const RodadaPage({
    super.key,
    required this.roundRepository,
    required this.toyRepository,
    required this.onOpenRodizioTab,
    required this.onOpenBrinquedosTab,
    required this.onOpenSettings,
  });

  @override
  State<RodadaPage> createState() => _RodadaPageState();
}

class _RodadaPageState extends State<RodadaPage> {
  static const double _radiusLg = 16.0;
  bool _startingRound = false;

  void _openToyDetail(String toyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToyDetailPage(
          toyId: toyId,
          toyRepository: widget.toyRepository,
        ),
      ),
    );
  }

  Future<void> _startRound() async {
    if (_startingRound) return;

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
          content: Text('Rodada criada com ${result.selectedCount} brinquedos.'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: UiTokens.bg,
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: UiTokens.bg.withValues(alpha: 0.96),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: UiTokens.spacingMd,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: colorScheme.outlineVariant,
          ),
        ),
        title: Text(
          'Rod\u00edzio',
          style: UiTokens.textTitle.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
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
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<List<RoundToyWithBox>>(
          stream: widget.roundRepository.watchActiveRoundToysWithBox(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data ?? const <RoundToyWithBox>[];

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                UiTokens.spacingMd,
                12,
                UiTokens.spacingMd,
                UiTokens.spacingMd,
              ),
              child: _RodadaMainCard(
                radius: _radiusLg,
                itemCount: items.length,
                child: items.isEmpty
                    ? _RodadaEmptyState(
                        radius: _radiusLg,
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
            );
          },
        ),
      ),
    );
  }
}

class _RodadaMainCard extends StatelessWidget {
  final double radius;
  final int itemCount;
  final Widget child;

  const _RodadaMainCard({
    required this.radius,
    required this.itemCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.3 : 0.05,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Rodada ativa',
                    style: UiTokens.textBody.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '$itemCount ITENS',
                  style: UiTokens.textCaption.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UiTokens.spacingXs),
            Text(
              'Toque para ver detalhes.',
              style: UiTokens.textBody.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _RodadaEmptyState extends StatelessWidget {
  final double radius;
  final VoidCallback? onAction;
  final String actionText;

  const _RodadaEmptyState({
    required this.radius,
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(radius),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.toys_outlined,
              size: 28,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: UiTokens.spacingMd),
          Text(
            'Nenhuma rodada ativa',
            textAlign: TextAlign.center,
            style: UiTokens.textBody.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          Text(
            'Crie uma rodada para come\u00e7ar.',
            textAlign: TextAlign.center,
            style: UiTokens.textButton.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
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
