import 'dart:async';

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

  testWidgets(
    'abertura oculta USD e publica preços e equivalente mensal em BRL',
    (tester) async {
      await _setIphoneViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final result = Completer<Map<String, ProductDetails>>();
      var loadCount = 0;
      final purchaseService = PurchaseService.forTesting(
        preferences: preferences,
        productDetailsById: _products(
          yearlyPrice: r'$14.99',
          yearlyRawPrice: 14.99,
          monthlyPrice: r'$1.99',
          monthlyRawPrice: 1.99,
          currencyCode: 'USD',
          currencySymbol: r'$',
        ),
        productDetailsLoader: () {
          loadCount++;
          return result.future;
        },
      );

      await _pumpPaywallWithoutSettling(
        tester,
        purchaseService: purchaseService,
      );

      expect(loadCount, 1);
      expect(find.text(r'$14.99'), findsNothing);
      expect(find.text(r'$1.99'), findsNothing);
      expect(find.text('Plano indisponível'), findsWidgets);

      result.complete(
        _products(
          yearlyPrice: r'R$ 120,00',
          yearlyRawPrice: 120,
          monthlyPrice: r'R$ 18,00',
          monthlyRawPrice: 18,
          currencyCode: 'BRL',
          currencySymbol: r'R$',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'R$ 120,00'), findsOneWidget);
      expect(find.text(r'R$ 18,00'), findsOneWidget);
      expect(find.textContaining('10,00/mês'), findsOneWidget);
      expect(find.text(r'$14.99'), findsNothing);
      expect(find.text(r'$1.99'), findsNothing);
    },
  );

  testWidgets('somente resumed atualiza e observer é removido no descarte', (
    tester,
  ) async {
    await _setIphoneViewport(tester);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    var loadCount = 0;
    final products = _products(
      yearlyPrice: r'R$ 120,00',
      yearlyRawPrice: 120,
      monthlyPrice: r'R$ 18,00',
      monthlyRawPrice: 18,
      currencyCode: 'BRL',
      currencySymbol: r'R$',
    );
    final purchaseService = PurchaseService.forTesting(
      preferences: preferences,
      productDetailsLoader: () async {
        loadCount++;
        return products;
      },
    );

    await _pumpPaywall(tester, purchaseService: purchaseService);
    expect(loadCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(loadCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(loadCount, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(loadCount, 2);
  });
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

Map<String, ProductDetails> _products({
  required String yearlyPrice,
  required double yearlyRawPrice,
  required String monthlyPrice,
  required double monthlyRawPrice,
  required String currencyCode,
  required String currencySymbol,
}) {
  return <String, ProductDetails>{
    PurchaseService.yearlyProductId: ProductDetails(
      id: PurchaseService.yearlyProductId,
      title: PurchaseService.yearlyProductId,
      description: PurchaseService.yearlyProductId,
      price: yearlyPrice,
      rawPrice: yearlyRawPrice,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
    ),
    PurchaseService.monthlyProductId: ProductDetails(
      id: PurchaseService.monthlyProductId,
      title: PurchaseService.monthlyProductId,
      description: PurchaseService.monthlyProductId,
      price: monthlyPrice,
      rawPrice: monthlyRawPrice,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
    ),
  };
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

Future<void> _pumpPaywallWithoutSettling(
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
  await tester.pump();
}

Future<void> _setIphoneViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
