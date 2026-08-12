import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/paywall_analytics_context.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'resposta antiga concorrente não substitui a resposta mais nova',
    () async {
      final firstResult = Completer<Map<String, ProductDetails>>();
      final secondResult = Completer<Map<String, ProductDetails>>();
      var loadCount = 0;
      final service = PurchaseService.forTesting(
        preferences: await SharedPreferences.getInstance(),
        productDetailsLoader: () {
          loadCount++;
          return loadCount == 1 ? firstResult.future : secondResult.future;
        },
      );

      final firstRefresh = service.refreshProductDetails();
      final secondRefresh = service.refreshProductDetails();
      expect(loadCount, 2);

      final brlProducts = _products(
        yearlyPrice: r'R$ 120,00',
        monthlyPrice: r'R$ 18,00',
        currencyCode: 'BRL',
      );
      secondResult.complete(brlProducts);
      await secondRefresh;
      expect(
        service.productDetailsFor(PurchaseService.yearlyProductId),
        same(brlProducts[PurchaseService.yearlyProductId]),
      );

      firstResult.complete(
        _products(
          yearlyPrice: r'$14.99',
          monthlyPrice: r'$1.99',
          currencyCode: 'USD',
        ),
      );
      await firstRefresh;

      expect(
        service.productDetailsFor(PurchaseService.yearlyProductId),
        same(brlProducts[PurchaseService.yearlyProductId]),
      );
      expect(
        service.productDetailsFor(PurchaseService.monthlyProductId),
        same(brlProducts[PurchaseService.monthlyProductId]),
      );
    },
  );

  test('compra sempre atualiza e lança com o ProductDetails novo', () async {
    final oldProducts = _products(
      yearlyPrice: r'$14.99',
      monthlyPrice: r'$1.99',
      currencyCode: 'USD',
    );
    final newProducts = _products(
      yearlyPrice: r'R$ 120,00',
      monthlyPrice: r'R$ 18,00',
      currencyCode: 'BRL',
    );
    ProductDetails? launchedProduct;
    var loadCount = 0;
    final service = PurchaseService.forTesting(
      preferences: await SharedPreferences.getInstance(),
      productDetailsById: oldProducts,
      productDetailsLoader: () async {
        loadCount++;
        return newProducts;
      },
      purchaseLauncher: (productDetails) async {
        launchedProduct = productDetails;
        return true;
      },
    );

    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );

    expect(loadCount, 1);
    expect(launchedProduct, same(newProducts[PurchaseService.yearlyProductId]));
    expect(
      launchedProduct,
      isNot(same(oldProducts[PurchaseService.yearlyProductId])),
    );
  });

  test(
    'falha na atualização limpa produtos antigos e impede o launcher',
    () async {
      var launchCount = 0;
      final service = PurchaseService.forTesting(
        preferences: await SharedPreferences.getInstance(),
        productDetailsById: _products(
          yearlyPrice: r'$14.99',
          monthlyPrice: r'$1.99',
          currencyCode: 'USD',
        ),
        productDetailsLoader: () async => throw StateError('falha simulada'),
        purchaseLauncher: (_) async {
          launchCount++;
          return true;
        },
      );

      await service.startPurchase(
        productId: PurchaseService.yearlyProductId,
        paywallContext: _paywall,
      );

      expect(launchCount, 0);
      expect(service.hasLoadedSubscriptionProducts, isFalse);
      expect(
        service.productDetailsFor(PurchaseService.yearlyProductId),
        isNull,
      );
      expect(
        service.productDetailsFor(PurchaseService.monthlyProductId),
        isNull,
      );
      expect(service.errorMessage, isNotNull);
    },
  );

  test('resposta sem os dois Product IDs é rejeitada', () async {
    var launchCount = 0;
    final yearly = _product(
      id: PurchaseService.yearlyProductId,
      price: r'R$ 120,00',
      currencyCode: 'BRL',
    );
    final service = PurchaseService.forTesting(
      preferences: await SharedPreferences.getInstance(),
      productDetailsLoader: () async => <String, ProductDetails>{
        PurchaseService.yearlyProductId: yearly,
      },
      purchaseLauncher: (_) async {
        launchCount++;
        return true;
      },
    );

    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );

    expect(launchCount, 0);
    expect(service.hasLoadedSubscriptionProducts, isFalse);
    expect(service.errorMessage, 'Assinaturas não encontradas na loja.');
  });
}

final PaywallAnalyticsContext _paywall = PaywallAnalyticsContext.create(
  source: PaywallSource.settings,
  idGenerator: () => 'paywall-product-refresh',
);

Map<String, ProductDetails> _products({
  required String yearlyPrice,
  required String monthlyPrice,
  required String currencyCode,
}) {
  return <String, ProductDetails>{
    PurchaseService.yearlyProductId: _product(
      id: PurchaseService.yearlyProductId,
      price: yearlyPrice,
      currencyCode: currencyCode,
    ),
    PurchaseService.monthlyProductId: _product(
      id: PurchaseService.monthlyProductId,
      price: monthlyPrice,
      currencyCode: currencyCode,
    ),
  };
}

ProductDetails _product({
  required String id,
  required String price,
  required String currencyCode,
}) {
  return ProductDetails(
    id: id,
    title: id,
    description: id,
    price: price,
    rawPrice: id == PurchaseService.yearlyProductId ? 120 : 18,
    currencyCode: currencyCode,
    currencySymbol: currencyCode == 'BRL' ? r'R$' : r'$',
  );
}
