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
  final bool blocking;

  const PaywallPage({
    super.key,
    required this.purchaseService,
    this.source = 'direct',
    this.blocking = false,
  });

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  String? _lastErrorMessage;
  bool _lastPremiumState = false;
  String _selectedProductId = PurchaseService.yearlyProductId;

  PurchaseService get _purchaseService => widget.purchaseService;

  bool get _isTrialExpiredPaywall =>
      widget.blocking || widget.source == 'app_trial_expired';

  String get _headline => _isTrialExpiredPaywall
      ? 'Seu teste grátis terminou'
      : 'Planeje a semana com mais calma.';

  String get _subtitle => _isTrialExpiredPaywall
      ? 'Para continuar organizando os brinquedos da casa, escolha um plano Premium.'
      : 'Prepare o rod\u00EDzio com anteced\u00EAncia e deixe a rotina de brincadeiras mais previs\u00EDvel.';

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
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    if (isTablet) return _buildIpadScaffold(context);

    return _buildMobileScaffold(context);
  }

  Widget _buildMobileScaffold(BuildContext context) {
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
                    _headline,
                    style: textTheme.headlineSmall?.copyWith(
                      color: UiTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UiTokens.spacingSm),
                  Text(
                    _subtitle,
                    style: textTheme.bodyLarge?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UiTokens.spacingMd),
            AppSurfaceCard(
              padding: const EdgeInsets.all(UiTokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final benefit in _isTrialExpiredPaywall
                      ? const [
                          'App completo liberado',
                          'Cadastro, fotos, caixas e locais',
                          'Rodízio diário e sugestão de rodada',
                          'Planejamento semanal completo',
                          'Restaurar compra sempre acessível',
                        ]
                      : const [
                          'Planejamento semanal completo',
                          'Organize cada dia da semana',
                          'Ajuste categorias por dia',
                          'Prepare a rotina com mais previsibilidade',
                          'Tenha mais controle sobre o rod\u00EDzio',
                        ]) ...[
                    _BenefitRow(label: benefit),
                    if (benefit !=
                        (_isTrialExpiredPaywall
                            ? 'Restaurar compra sempre acessível'
                            : 'Tenha mais controle sobre o rod\u00EDzio'))
                      const SizedBox(height: UiTokens.spacingSm),
                  ],
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
                  : Text(
                      _isTrialExpiredPaywall
                          ? 'Assinar Premium'
                          : 'Come\u00E7ar agora',
                    ),
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

  Widget _buildIpadScaffold(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 32;

    return Scaffold(
      backgroundColor: _PaywallIpadPalette.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(24, 18, 24, bottomPadding),
          physics: const BouncingScrollPhysics(),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1032),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PaywallIpadHeader(
                      isBlocking: _isTrialExpiredPaywall,
                      title: _headline,
                      subtitle: _subtitle,
                      onClose: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useColumns = constraints.maxWidth >= 820;
                        final valueCard = _PaywallIpadValueCard(
                          isTrialExpired: _isTrialExpiredPaywall,
                        );
                        final plansPanel = _PaywallIpadPlansPanel(
                          isBlocking: _isTrialExpiredPaywall,
                          selectedProductId: _selectedProductId,
                          isLoading: _purchaseService.isLoading,
                          onSelectMonthly: () =>
                              _selectPlan(PurchaseService.monthlyProductId),
                          onSelectYearly: () =>
                              _selectPlan(PurchaseService.yearlyProductId),
                          onPurchase: _startPurchase,
                          onRestore: _restorePurchases,
                          onClose: () => Navigator.of(context).maybePop(),
                          onTerms: () => _openExternalLink(_termsOfUseUrl),
                          onPrivacy: () => _openExternalLink(_privacyPolicyUrl),
                        );

                        if (!useColumns) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              valueCard,
                              const SizedBox(height: 18),
                              plansPanel,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 11, child: valueCard),
                            const SizedBox(width: 22),
                            Expanded(flex: 9, child: plansPanel),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaywallIpadPalette {
  _PaywallIpadPalette._();

  static const Color bg = Color(0xFFFDF7F0);
  static const Color ink = Color(0xFF25180A);
  static const Color muted = Color(0xFF6B4F30);
  static const Color soft = Color(0xFFFFF3E7);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeDark = Color(0xFFC2410C);
  static const Color border = Color(0xFFF0DEC8);
}

class _PaywallIpadHeader extends StatelessWidget {
  final bool isBlocking;
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  const _PaywallIpadHeader({
    required this.isBlocking,
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: UiTokens.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _PaywallIpadPalette.border),
        boxShadow: UiTokens.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _PaywallIpadPalette.orange.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: _PaywallIpadPalette.orange,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBlocking ? 'ASSINATURA NECESSÁRIA' : 'RODÍZIO PREMIUM',
                  style: UiTokens.textMicro.copyWith(
                    color: _PaywallIpadPalette.orangeDark,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    color: _PaywallIpadPalette.ink,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: UiTokens.textBody.copyWith(
                    color: _PaywallIpadPalette.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (!isBlocking) ...[
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Agora não'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _PaywallIpadPalette.muted,
                side: const BorderSide(color: _PaywallIpadPalette.border),
                minimumSize: const Size(132, 46),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaywallIpadValueCard extends StatelessWidget {
  final bool isTrialExpired;

  const _PaywallIpadValueCard({required this.isTrialExpired});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: UiTokens.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _PaywallIpadPalette.border),
        boxShadow: UiTokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _PaywallIpadPalette.soft,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: _PaywallIpadPalette.orange.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              isTrialExpired
                  ? 'Premium libera o app completo'
                  : 'Premium desbloqueia Planejamento Semanal',
              style: UiTokens.textCaption.copyWith(
                color: _PaywallIpadPalette.orangeDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            isTrialExpired
                ? 'Continue usando todos os recursos que organizaram sua rotina.'
                : 'Uma semana organizada antes da rotina começar.',
            style: textTheme.headlineSmall?.copyWith(
              color: _PaywallIpadPalette.ink,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isTrialExpired
                ? 'Assine para manter Home, brinquedos, caixas, rodízio, sugestão de rodada e planejamento semanal liberados.'
                : 'Monte a programação com antecedência, distribua categorias e veja a rotina de brinquedos com mais clareza.',
            style: UiTokens.textBody.copyWith(
              color: _PaywallIpadPalette.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          const _PaywallIpadBenefit(
            icon: Icons.calendar_month_outlined,
            title: 'Planejamento da semana',
            text: 'Prepare os dias com antecedência e reduza decisões na hora.',
          ),
          const SizedBox(height: 14),
          const _PaywallIpadBenefit(
            icon: Icons.category_outlined,
            title: 'Categorias equilibradas',
            text: 'Ajuste a variedade das brincadeiras ao longo da semana.',
          ),
          const SizedBox(height: 14),
          const _PaywallIpadBenefit(
            icon: Icons.lightbulb_outline,
            title: 'Menos improviso no dia a dia',
            text: 'Tenha uma rotina mais previsível sem perder flexibilidade.',
          ),
          const SizedBox(height: 14),
          const _PaywallIpadBenefit(
            icon: Icons.view_week_outlined,
            title: 'Visão clara da rotina',
            text: 'Acompanhe dias, quantidades e distribuição dos brinquedos.',
          ),
        ],
      ),
    );
  }
}

class _PaywallIpadBenefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _PaywallIpadBenefit({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _PaywallIpadPalette.orange.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _PaywallIpadPalette.orange, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: UiTokens.textBody.copyWith(
                  color: _PaywallIpadPalette.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: UiTokens.textCaption.copyWith(
                  color: _PaywallIpadPalette.muted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaywallIpadPlansPanel extends StatelessWidget {
  final bool isBlocking;
  final String selectedProductId;
  final bool isLoading;
  final VoidCallback onSelectMonthly;
  final VoidCallback onSelectYearly;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;
  final VoidCallback onClose;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  const _PaywallIpadPlansPanel({
    required this.isBlocking,
    required this.selectedProductId,
    required this.isLoading,
    required this.onSelectMonthly,
    required this.onSelectYearly,
    required this.onPurchase,
    required this.onRestore,
    required this.onClose,
    required this.onTerms,
    required this.onPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: UiTokens.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _PaywallIpadPalette.border),
        boxShadow: UiTokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Escolha seu plano',
            style: UiTokens.textSectionTitle.copyWith(
              color: _PaywallIpadPalette.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isBlocking
                ? 'Assine para continuar usando o Rodízio de Brinquedos.'
                : 'Assine para liberar o Planejamento Semanal.',
            style: UiTokens.textCaption.copyWith(
              color: _PaywallIpadPalette.muted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          _PlanCard(
            badge: 'Plano anual',
            title: 'Rodízio Premium Anual',
            price: paywallYearlyDisplayPrice,
            description: paywallYearlyMonthlyEquivalent,
            isFeatured: true,
            isSelected: selectedProductId == PurchaseService.yearlyProductId,
            onTap: onSelectYearly,
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Rodízio Premium Mensal',
            price: paywallMonthlyDisplayPrice,
            isSelected: selectedProductId == PurchaseService.monthlyProductId,
            onTap: onSelectMonthly,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: isLoading ? null : onPurchase,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.workspace_premium_outlined),
            label: Text(isLoading ? 'Processando...' : 'Assinar Premium'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: _PaywallIpadPalette.orange,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isLoading ? null : onRestore,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Restaurar compras'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: _PaywallIpadPalette.orangeDark,
              side: BorderSide(
                color: _PaywallIpadPalette.orange.withValues(alpha: 0.26),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (!isBlocking) ...[
            TextButton(
              onPressed: isLoading ? null : onClose,
              child: const Text('Agora não'),
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                onPressed: onTerms,
                child: const Text('Termos de uso'),
              ),
              Text(
                '|',
                style: UiTokens.textCaption.copyWith(
                  color: _PaywallIpadPalette.muted,
                ),
              ),
              TextButton(
                onPressed: onPrivacy,
                child: const Text('Política de privacidade'),
              ),
            ],
          ),
        ],
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
