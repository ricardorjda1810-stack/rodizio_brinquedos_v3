import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
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

  bool get _hasLoadedSubscriptionPlans =>
      _purchaseService.hasLoadedSubscriptionProducts;

  bool get _canStartPurchase =>
      !_purchaseService.isLoading &&
      _purchaseService.productDetailsFor(_selectedProductId) != null;

  String _headline(AppLocalizations l10n) => _isTrialExpiredPaywall
      ? l10n.trialEndedTitle
      : l10n.isEn
          ? 'Plan the week with more calm.'
          : 'Planeje a semana com mais calma.';

  String _subtitle(AppLocalizations l10n) => _isTrialExpiredPaywall
      ? l10n.trialEndedSubtitle
      : l10n.isEn
          ? 'Prepare the rotation ahead of time and make play routines easier to follow.'
          : 'Prepare o rod\u00EDzio com anteced\u00EAncia e deixe a rotina de brincadeiras mais previs\u00EDvel.';

  String _planPrice(String productId, AppLocalizations l10n) {
    final details = _purchaseService.productDetailsFor(productId);
    if (details != null && details.price.trim().isNotEmpty) {
      return details.price;
    }

    return l10n.planUnavailable;
  }

  String? _yearlyDescription(AppLocalizations l10n) {
    final details =
        _purchaseService.productDetailsFor(PurchaseService.yearlyProductId);
    if (details != null && details.rawPrice > 0) {
      final monthly = details.rawPrice / 12;
      final formatted = NumberFormat.simpleCurrency(
        locale: l10n.dateLocale,
        name: details.currencyCode,
      ).format(monthly);
      return l10n.isEn
          ? 'about $formatted/month'
          : 'equivalente a $formatted/m\u00eas';
    }
    return null;
  }

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
        SnackBar(
          content: Text(
            context.l10n.isEn
                ? 'Subscription activated successfully.'
                : 'Assinatura ativada com sucesso.',
          ),
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

  Future<void> _retryLoadingProducts() async {
    if (!isPaywallEnabledForCurrentPlatform) return;
    await _purchaseService.refreshProductDetails();
  }

  Future<void> _openExternalLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.isEn
                ? 'Link is not configured yet.'
                : 'Link ainda n\u00e3o configurado.',
          ),
        ),
      );
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.isEn
                ? 'Could not open the link.'
                : 'N\u00e3o foi poss\u00edvel abrir o link.',
          ),
        ),
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
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: UiTokens.bg,
      appBar: AppBar(
        title: Text(l10n.subscription),
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
                    _headline(l10n),
                    style: textTheme.headlineSmall?.copyWith(
                      color: UiTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UiTokens.spacingSm),
                  Text(
                    _subtitle(l10n),
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
                      ? [
                          l10n.appFullAccess,
                          l10n.isEn
                              ? 'Toys, photos, boxes, and locations'
                              : 'Cadastro, fotos, caixas e locais',
                          l10n.isEn
                              ? 'Daily rotation and suggestions'
                              : 'Rod\u00edzio di\u00e1rio e sugest\u00e3o de rodada',
                          l10n.weeklyPlanning,
                          l10n.isEn
                              ? 'Restore purchase always available'
                              : 'Restaurar compra sempre acess\u00edvel',
                        ]
                      : [
                          l10n.weeklyPlanning,
                          l10n.isEn
                              ? 'Organize each day of the week'
                              : 'Organize cada dia da semana',
                          l10n.isEn
                              ? 'Adjust categories by day'
                              : 'Ajuste categorias por dia',
                          l10n.isEn
                              ? 'Prepare routines with more predictability'
                              : 'Prepare a rotina com mais previsibilidade',
                          l10n.isEn
                              ? 'Keep more control over the rotation'
                              : 'Tenha mais controle sobre o rod\u00edzio',
                        ]) ...[
                    _BenefitRow(label: benefit),
                    if (benefit !=
                        (_isTrialExpiredPaywall
                            ? (l10n.isEn
                                ? 'Restore purchase always available'
                                : 'Restaurar compra sempre acess\u00edvel')
                            : (l10n.isEn
                                ? 'Keep more control over the rotation'
                                : 'Tenha mais controle sobre o rod\u00edzio')))
                      const SizedBox(height: UiTokens.spacingSm),
                  ],
                ],
              ),
            ),
            const SizedBox(height: UiTokens.spacingMd),
            _PlanCard(
              badge: '\u{2B50} ${l10n.mostPopular}',
              title: l10n.annualPlan,
              price: _planPrice(PurchaseService.yearlyProductId, l10n),
              description: _yearlyDescription(l10n),
              isFeatured: true,
              isSelected: _selectedProductId == PurchaseService.yearlyProductId,
              onTap: () => _selectPlan(PurchaseService.yearlyProductId),
            ),
            const SizedBox(height: UiTokens.spacingSm),
            _PlanCard(
              title: l10n.monthlyPlan,
              price: _planPrice(PurchaseService.monthlyProductId, l10n),
              isSelected:
                  _selectedProductId == PurchaseService.monthlyProductId,
              onTap: () => _selectPlan(PurchaseService.monthlyProductId),
            ),
            if (!_hasLoadedSubscriptionPlans) ...[
              const SizedBox(height: UiTokens.spacingMd),
              _PlanLoadErrorCard(onRetry: _retryLoadingProducts),
            ],
            const SizedBox(height: UiTokens.spacingLg),
            FilledButton(
              onPressed: _canStartPurchase ? _startPurchase : null,
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
                          ? l10n.continueWithSubscription
                          : l10n.startNow,
                    ),
            ),
            const SizedBox(height: UiTokens.spacingSm),
            Center(
              child: TextButton(
                onPressed:
                    _purchaseService.isLoading ? null : _restorePurchases,
                child: Text(l10n.restorePurchase),
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
                    child: Text(l10n.termsOfUse),
                  ),
                  Text(
                    '|',
                    style: textTheme.bodySmall?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openExternalLink(_privacyPolicyUrl),
                    child: Text(l10n.privacyPolicy),
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
    final l10n = context.l10n;

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
                      title: _headline(l10n),
                      subtitle: _subtitle(l10n),
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
                          purchaseService: _purchaseService,
                          selectedProductId: _selectedProductId,
                          isLoading: _purchaseService.isLoading,
                          hasLoadedSubscriptionPlans:
                              _hasLoadedSubscriptionPlans,
                          onSelectMonthly: () =>
                              _selectPlan(PurchaseService.monthlyProductId),
                          onSelectYearly: () =>
                              _selectPlan(PurchaseService.yearlyProductId),
                          onPurchase: _startPurchase,
                          onRetry: _retryLoadingProducts,
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
    final l10n = context.l10n;

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
                  isBlocking
                      ? l10n.subscriptionRequired
                      : l10n.subscription.toUpperCase(),
                  style: context.appTypography.micro.copyWith(
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
                  style: context.appTypography.body.copyWith(
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
              label: Text(l10n.notNow),
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
    final l10n = context.l10n;

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
                  ? l10n.appFullAccess
                  : l10n.isEn
                      ? 'Subscription unlocks weekly planning'
                      : 'Assinatura libera o planejamento semanal',
              style: context.appTypography.caption.copyWith(
                color: _PaywallIpadPalette.orangeDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            isTrialExpired
                ? (l10n.isEn
                    ? 'Keep using the features that organized your routine.'
                    : 'Continue usando todos os recursos que organizaram sua rotina.')
                : (l10n.isEn
                    ? 'An organized week before the routine begins.'
                    : 'Uma semana organizada antes da rotina começar.'),
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
                ? l10n.appFullAccessDescription
                : (l10n.isEn
                    ? 'Plan ahead, distribute categories, and view the toy routine more clearly.'
                    : 'Monte a programação com antecedência, distribua categorias e veja a rotina de brinquedos com mais clareza.'),
            style: context.appTypography.body.copyWith(
              color: _PaywallIpadPalette.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          _PaywallIpadBenefit(
            icon: Icons.calendar_month_outlined,
            title: l10n.weeklyPlanning,
            text: l10n.isEn
                ? 'Prepare days ahead of time and reduce last-minute decisions.'
                : 'Prepare os dias com antecedência e reduza decisões na hora.',
          ),
          const SizedBox(height: 14),
          _PaywallIpadBenefit(
            icon: Icons.category_outlined,
            title:
                l10n.isEn ? 'Balanced categories' : 'Categorias equilibradas',
            text: l10n.isEn
                ? 'Adjust play variety throughout the week.'
                : 'Ajuste a variedade das brincadeiras ao longo da semana.',
          ),
          const SizedBox(height: 14),
          _PaywallIpadBenefit(
            icon: Icons.lightbulb_outline,
            title: l10n.isEn
                ? 'Less daily improvising'
                : 'Menos improviso no dia a dia',
            text: l10n.isEn
                ? 'Keep a more predictable routine without losing flexibility.'
                : 'Tenha uma rotina mais previsível sem perder flexibilidade.',
          ),
          const SizedBox(height: 14),
          _PaywallIpadBenefit(
            icon: Icons.view_week_outlined,
            title: l10n.isEn ? 'Clear routine view' : 'Visão clara da rotina',
            text: l10n.isEn
                ? 'Track days, quantities, and toy distribution.'
                : 'Acompanhe dias, quantidades e distribuição dos brinquedos.',
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
                style: context.appTypography.body.copyWith(
                  color: _PaywallIpadPalette.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: context.appTypography.caption.copyWith(
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
  final PurchaseService purchaseService;
  final String selectedProductId;
  final bool isLoading;
  final bool hasLoadedSubscriptionPlans;
  final VoidCallback onSelectMonthly;
  final VoidCallback onSelectYearly;
  final VoidCallback onPurchase;
  final VoidCallback onRetry;
  final VoidCallback onRestore;
  final VoidCallback onClose;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  const _PaywallIpadPlansPanel({
    required this.isBlocking,
    required this.purchaseService,
    required this.selectedProductId,
    required this.isLoading,
    required this.hasLoadedSubscriptionPlans,
    required this.onSelectMonthly,
    required this.onSelectYearly,
    required this.onPurchase,
    required this.onRetry,
    required this.onRestore,
    required this.onClose,
    required this.onTerms,
    required this.onPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String planPrice(String productId) {
      final details = purchaseService.productDetailsFor(productId);
      if (details != null && details.price.trim().isNotEmpty) {
        return details.price;
      }
      return l10n.planUnavailable;
    }

    String? yearlyDescription() {
      final details = purchaseService.productDetailsFor(
        PurchaseService.yearlyProductId,
      );
      if (details != null && details.rawPrice > 0) {
        final monthly = details.rawPrice / 12;
        final formatted = NumberFormat.simpleCurrency(
          locale: l10n.dateLocale,
          name: details.currencyCode,
        ).format(monthly);
        return l10n.isEn
            ? 'about $formatted/month'
            : 'equivalente a $formatted/m\u00eas';
      }
      return null;
    }

    final canPurchase = !isLoading &&
        purchaseService.productDetailsFor(selectedProductId) != null;

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
            l10n.choosePlan,
            style: context.appTypography.sectionTitle.copyWith(
              color: _PaywallIpadPalette.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isBlocking
                ? l10n.selectAPlanSubtitle
                : (l10n.isEn
                    ? 'Subscribe to unlock weekly planning.'
                    : 'Assine para liberar o planejamento semanal.'),
            style: context.appTypography.caption.copyWith(
              color: _PaywallIpadPalette.muted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          _PlanCard(
            badge: l10n.annualPlan,
            title: l10n.annualPlan,
            price: planPrice(PurchaseService.yearlyProductId),
            description: yearlyDescription(),
            isFeatured: true,
            isSelected: selectedProductId == PurchaseService.yearlyProductId,
            onTap: onSelectYearly,
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: l10n.monthlyPlan,
            price: planPrice(PurchaseService.monthlyProductId),
            isSelected: selectedProductId == PurchaseService.monthlyProductId,
            onTap: onSelectMonthly,
          ),
          if (!hasLoadedSubscriptionPlans) ...[
            const SizedBox(height: 14),
            _PlanLoadErrorCard(onRetry: onRetry),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: canPurchase ? onPurchase : null,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.workspace_premium_outlined),
            label: Text(
              isLoading ? l10n.processing : l10n.continueWithSubscription,
            ),
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
            label: Text(l10n.restorePurchases),
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
              child: Text(l10n.notNow),
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                onPressed: onTerms,
                child: Text(l10n.termsOfUse),
              ),
              Text(
                '|',
                style: context.appTypography.caption.copyWith(
                  color: _PaywallIpadPalette.muted,
                ),
              ),
              TextButton(
                onPressed: onPrivacy,
                child: Text(l10n.privacyPolicy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanLoadErrorCard extends StatelessWidget {
  final VoidCallback onRetry;

  const _PlanLoadErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(UiTokens.spacingMd),
      decoration: BoxDecoration(
        color: UiTokens.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(UiTokens.radiusMd),
        border: Border.all(
          color: UiTokens.warning.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.subscriptionPlansUnavailable,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: UiTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: UiTokens.spacingSm),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.tryAgain),
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
