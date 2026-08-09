import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/paywall_analytics_context.dart';
import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'paywall sem produtos desabilita assinatura e mantém restore e links',
    (tester) async {
      await _setIphoneViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final purchaseService = PurchaseService.forTesting(
        preferences: preferences,
      );

      await _pumpPaywall(tester, purchaseService: purchaseService);

      await tester.scrollUntilVisible(
        find.textContaining('Não foi possível carregar os planos'),
        260,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.text(
          'Não foi possível carregar os planos. Verifique sua conexão e tente novamente.',
        ),
        findsOneWidget,
      );
      expect(find.text('Plano indisponível'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('Restaurar compra'),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Restaurar compra'), findsOneWidget);
      expect(find.text('Termos de uso'), findsOneWidget);
      expect(find.text('Política de privacidade'), findsOneWidget);

      final subscribeButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Continuar com assinatura'),
      );
      expect(subscribeButton.onPressed, isNull);
    },
  );

  testWidgets(
    'paywall com produtos usa preços da loja e mantém assinatura ativa',
    (tester) async {
      await _setIphoneViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final purchaseService = PurchaseService.forTesting(
        preferences: preferences,
        productDetailsById: <String, ProductDetails>{
          PurchaseService.yearlyProductId: _product(
            id: PurchaseService.yearlyProductId,
            price: r'$19.99',
            rawPrice: 19.99,
          ),
          PurchaseService.monthlyProductId: _product(
            id: PurchaseService.monthlyProductId,
            price: r'$2.99',
            rawPrice: 2.99,
          ),
        },
      );

      await _pumpPaywall(tester, purchaseService: purchaseService);

      expect(
        find.text(
          'Não foi possível carregar os planos. Verifique sua conexão e tente novamente.',
        ),
        findsNothing,
      );
      expect(find.text(r'$19.99'), findsOneWidget);
      expect(find.text(r'$2.99'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Continuar com assinatura'),
        260,
        scrollable: find.byType(Scrollable).first,
      );

      final subscribeButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Continuar com assinatura'),
      );
      expect(subscribeButton.onPressed, isNotNull);
    },
  );
}

ProductDetails _product({
  required String id,
  required String price,
  required double rawPrice,
}) {
  return ProductDetails(
    id: id,
    title: id,
    description: id,
    price: price,
    rawPrice: rawPrice,
    currencyCode: 'USD',
    currencySymbol: r'$',
  );
}

Future<void> _pumpPaywall(
  WidgetTester tester, {
  required PurchaseService purchaseService,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: PaywallPage(
        purchaseService: purchaseService,
        source: PaywallSource.appTrialExpired,
        blocking: true,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _setIphoneViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
