import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/features/paywall/paywall_display_prices.dart';
import 'package:rodizio_brinquedos_v3/services/paywall_platform.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

const String _privacyPolicyUrl =
    'https://first-lime-7b2.notion.site/Pol-tica-de-Privacidade-Rod-zio-de-Brinquedos-d40b83abf35f4d089e1ae5f46423b4ca?pvs=143';
const String _termsOfUseUrl =
    'https://first-lime-7b2.notion.site/Termos-de-Uso-Rod-zio-de-Brinquedos-34c496b60a598015ba29cb3322ebfbc6?pvs=143';

class PaywallPage extends StatefulWidget {
  final PurchaseService purchaseService;
  final String source;

  const PaywallPage({
    super.key,
    required this.purchaseService,
    this.source = 'direct',
  });

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  String? _lastErrorMessage;
  bool _lastPremiumState = false;
  String _selectedProductId = PurchaseService.yearlyProductId;

  PurchaseService get _purchaseService => widget.purchaseService;

  @override
  void initState() {
    super.initState();
    unawaited(AppAnalytics.logPaywallViewed(source: widget.source));
    _lastPremiumState = _purchaseService.isPremium;
    _lastErrorMessage = _purchaseService.errorMessage;
    _purchaseService.addListener(_handlePurchaseStateChanged);
  }

  @override
  void dispose() {
    _purchaseService.removeListener(_handlePurchaseStateChanged);
    super.dispose();
  }

  void _handlePurchaseStateChanged() {
    if (!mounted) return;

    final errorMessage = _purchaseService.errorMessage;
    if (errorMessage != null && errorMessage != _lastErrorMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    if (_purchaseService.isPremium && !_lastPremiumState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium ativado com sucesso.'),
        ),
      );
    }

    _lastPremiumState = _purchaseService.isPremium;
    _lastErrorMessage = errorMessage;
    setState(() {});
  }

  Future<void> _startPurchase() async {
    if (!isPaywallEnabledForCurrentPlatform) return;
    await _purchaseService.startPurchase(
      productId: _selectedProductId,
      source: 'paywall',
    );
  }

  Future<void> _restorePurchases() async {
    if (!isPaywallEnabledForCurrentPlatform) return;
    await _purchaseService.restorePurchases(source: 'paywall');
  }

  Future<void> _openExternalLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link ainda não configurado.')),
      );
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  void _selectPlan(String productId) {
    if (_selectedProductId == productId) return;
    setState(() => _selectedProductId = productId);
    unawaited(
      AppAnalytics.logPremiumPlanSelected(
        plan: PurchaseService.planForProductId(productId),
        source: 'paywall',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: UiTokens.bg,
      appBar: AppBar(
        title: const Text('Premium'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(UiTokens.spacingMd),
          children: [
            AppSurfaceCard(
              padding: const EdgeInsets.all(UiTokens.spacingMd),
              color: UiTokens.primarySoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planeje a semana com mais calma.',
                    style: textTheme.headlineSmall?.copyWith(
                      color: UiTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UiTokens.spacingSm),
                  Text(
                    'Prepare o rod\u00EDzio com anteced\u00EAncia e deixe a rotina de brincadeiras mais previs\u00EDvel.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UiTokens.spacingMd),
            const AppSurfaceCard(
              padding: EdgeInsets.all(UiTokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BenefitRow(label: 'Planejamento semanal completo'),
                  SizedBox(height: UiTokens.spacingSm),
                  _BenefitRow(label: 'Organize cada dia da semana'),
                  SizedBox(height: UiTokens.spacingSm),
                  _BenefitRow(label: 'Ajuste categorias por dia'),
                  SizedBox(height: UiTokens.spacingSm),
                  _BenefitRow(
                    label: 'Prepare a rotina com mais previsibilidade',
                  ),
                  SizedBox(height: UiTokens.spacingSm),
                  _BenefitRow(
                    label: 'Tenha mais controle sobre o rod\u00EDzio',
                  ),
                ],
              ),
            ),
            const SizedBox(height: UiTokens.spacingMd),
            _PlanCard(
              badge: '\u{2B50} Mais popular',
              title: 'Rod\u00EDzio Premium Anual',
              price: paywallYearlyDisplayPrice,
              description: paywallYearlyMonthlyEquivalent,
              isFeatured: true,
              isSelected: _selectedProductId == PurchaseService.yearlyProductId,
              onTap: () => _selectPlan(PurchaseService.yearlyProductId),
            ),
            const SizedBox(height: UiTokens.spacingSm),
            _PlanCard(
              title: 'Rod\u00EDzio Premium Mensal',
              price: paywallMonthlyDisplayPrice,
              isSelected:
                  _selectedProductId == PurchaseService.monthlyProductId,
              onTap: () => _selectPlan(PurchaseService.monthlyProductId),
            ),
            const SizedBox(height: UiTokens.spacingLg),
            FilledButton(
              onPressed: _purchaseService.isLoading ? null : _startPurchase,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: _purchaseService.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Come\u00E7ar agora'),
            ),
            const SizedBox(height: UiTokens.spacingSm),
            Center(
              child: TextButton(
                onPressed:
                    _purchaseService.isLoading ? null : _restorePurchases,
                child: const Text('Restaurar compra'),
              ),
            ),
            const SizedBox(height: UiTokens.spacingSm),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => _openExternalLink(_termsOfUseUrl),
                    child: const Text('Termos de uso'),
                  ),
                  Text(
                    '|',
                    style: textTheme.bodySmall?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openExternalLink(_privacyPolicyUrl),
                    child: const Text('Pol\u00EDtica de privacidade'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String? badge;
  final String title;
  final String price;
  final String? description;
  final bool isFeatured;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    this.badge,
    required this.title,
    required this.price,
    this.description,
    this.isFeatured = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderColor = isSelected ? UiTokens.primaryStrong : UiTokens.border;
    final backgroundColor =
        isFeatured ? UiTokens.primarySoft : UiTokens.surfaceLight;

    return Semantics(
      button: true,
      selected: isSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(UiTokens.radiusCard),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: UiTokens.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(UiTokens.radiusCard),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(UiTokens.spacingMd),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (badge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UiTokens.spacingSm,
                              vertical: UiTokens.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: UiTokens.accent.withValues(alpha: 0.16),
                              borderRadius:
                                  BorderRadius.circular(UiTokens.radiusSm),
                            ),
                            child: Text(
                              badge!,
                              style: textTheme.labelSmall?.copyWith(
                                color: UiTokens.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: UiTokens.spacingSm),
                        ],
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            color: UiTokens.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: UiTokens.spacingXs),
                        Text(
                          price,
                          style: textTheme.titleSmall?.copyWith(
                            color: UiTokens.primaryStrong,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: UiTokens.spacingXs),
                          Text(
                            description!,
                            style: textTheme.bodySmall?.copyWith(
                              color: UiTokens.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: UiTokens.spacingMd),
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? UiTokens.primaryStrong
                        : UiTokens.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String label;

  const _BenefitRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_outline,
            size: 20,
            color: UiTokens.primaryStrong,
          ),
        ),
        const SizedBox(width: UiTokens.spacingSm),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: UiTokens.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}
