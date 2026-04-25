import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

const String _privacyPolicyUrl =
    'https://first-lime-7b2.notion.site/Pol-tica-de-Privacidade-Rod-zio-de-Brinquedos-d40b83abf35f4d089e1ae5f46423b4ca?pvs=143';
const String _termsOfUseUrl =
    'https://first-lime-7b2.notion.site/Termos-de-Uso-Rod-zio-de-Brinquedos-34c496b60a598015ba29cb3322ebfbc6?pvs=143';

class PaywallPage extends StatefulWidget {
  final PurchaseService purchaseService;

  const PaywallPage({
    super.key,
    required this.purchaseService,
  });

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  String? _lastErrorMessage;
  bool _lastPremiumState = false;

  PurchaseService get _purchaseService => widget.purchaseService;

  @override
  void initState() {
    super.initState();
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
          content: Text('Premium ativado neste aparelho.'),
        ),
      );
    }

    _lastPremiumState = _purchaseService.isPremium;
    _lastErrorMessage = errorMessage;
    setState(() {});
  }

  Future<void> _startPurchase() async {
    await _purchaseService.startPurchase();
  }

  Future<void> _restorePurchases() async {
    await _purchaseService.restorePurchases();
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

  String _priceText() {
    final details = _purchaseService.productDetails;
    if (details == null) {
      return 'Depois R\$9,90/m\u00EAs';
    }
    return 'Depois ${details.price}/m\u00EAs';
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
              padding: const EdgeInsets.all(UiTokens.spacingLg),
              color: UiTokens.primarySoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menos bagun\u00E7a. Mais brincadeiras de verdade.',
                    style: textTheme.headlineSmall?.copyWith(
                      color: UiTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UiTokens.spacingSm),
                  Text(
                    'Organize os brinquedos e veja a diferen\u00E7a em poucos dias',
                    style: textTheme.bodyLarge?.copyWith(
                      color: UiTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UiTokens.spacingMd),
            AppSurfaceCard(
              padding: const EdgeInsets.all(UiTokens.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BenefitRow(label: 'Menos brinquedos espalhados'),
                  const SizedBox(height: UiTokens.spacingSm),
                  const _BenefitRow(label: 'Crian\u00E7a mais focada'),
                  const SizedBox(height: UiTokens.spacingSm),
                  const _BenefitRow(label: 'Rotina mais leve para os pais'),
                  const SizedBox(height: UiTokens.spacingLg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(UiTokens.spacingMd),
                    decoration: BoxDecoration(
                      color: UiTokens.secondarySoft,
                      borderRadius: BorderRadius.circular(UiTokens.radiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u{1F381} 1 m\u00EAs gr\u00E1tis',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: UiTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: UiTokens.spacingXs),
                        Text(
                          _priceText(),
                          style: textTheme.bodyMedium?.copyWith(
                            color: UiTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_purchaseService.productDetails == null)
                    Padding(
                      padding: const EdgeInsets.only(top: UiTokens.spacingSm),
                      child: Text(
                        'Produto: ${PurchaseService.productId}',
                        style: textTheme.bodySmall?.copyWith(
                          color: UiTokens.textSecondary,
                        ),
                      ),
                    ),
                  if (_purchaseService.isPremium)
                    Padding(
                      padding: const EdgeInsets.only(top: UiTokens.spacingMd),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(UiTokens.spacingMd),
                        decoration: BoxDecoration(
                          color: UiTokens.primarySoft,
                          borderRadius: BorderRadius.circular(UiTokens.radiusLg),
                        ),
                        child: Text(
                          'Premium ativo neste aparelho.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: UiTokens.primaryStrong,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: UiTokens.spacingLg),
                  FilledButton(
                    onPressed:
                        _purchaseService.isLoading ? null : _startPurchase,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: _purchaseService.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Come\u00E7ar teste gr\u00E1tis'),
                  ),
                  const SizedBox(height: UiTokens.spacingSm),
                  Center(
                    child: Text(
                      'Cancele quando quiser',
                      style: textTheme.bodySmall?.copyWith(
                        color: UiTokens.textSecondary,
                      ),
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
                ],
              ),
            ),
            const SizedBox(height: UiTokens.spacingMd),
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
