import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/toy_row_item.dart';

class RodadaPage extends StatefulWidget {
  final RoundRepository roundRepository;
  final SettingsRepository settingsRepository;
  final ToyRepository toyRepository;
  final VoidCallback onOpenRodizioTab;

  const RodadaPage({
    super.key,
    required this.roundRepository,
    required this.settingsRepository,
    required this.toyRepository,
    required this.onOpenRodizioTab,
  });

  @override
  State<RodadaPage> createState() => _RodadaPageState();
}

class _RodadaPageState extends State<RodadaPage> {
  static const Color _pageBackground = Color(0xFFFDFCFB);
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
      await widget.roundRepository.startRound(
        size: widget.settingsRepository.roundSize,
      );
      if (mounted) {
        widget.onOpenRodizioTab();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel iniciar o rodizio: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _startingRound = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: UiTokens.surface.withValues(alpha: 0.84),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: UiTokens.spacingMd,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: UiTokens.border,
          ),
        ),
        title: Text(
          'Rodízio',
          style: UiTokens.textTitle.copyWith(
            color: UiTokens.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: UiTokens.spacingMd),
            child: SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                splashRadius: 20,
                iconSize: 20,
                color: UiTokens.textSecondary,
                icon: const Icon(Icons.more_vert),
              ),
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
    return Material(
      color: UiTokens.surface,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: BoxDecoration(
          color: UiTokens.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: UiTokens.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
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
                      color: UiTokens.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '$itemCount ITENS',
                  style: UiTokens.textCaption.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: UiTokens.textSecondary,
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
                color: UiTokens.textSecondary,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UiTokens.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: UiTokens.playfulSoft,
              borderRadius: BorderRadius.circular(radius),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.toys_outlined,
              size: 28,
              color: UiTokens.primary,
            ),
          ),
          const SizedBox(height: UiTokens.spacingMd),
          Text(
            'Nenhuma rodada ativa',
            textAlign: TextAlign.center,
            style: UiTokens.textBody.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: UiTokens.textPrimary,
            ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          Text(
            'Crie uma rodada para começar.',
            textAlign: TextAlign.center,
            style: UiTokens.textButton.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: UiTokens.textSecondary,
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
