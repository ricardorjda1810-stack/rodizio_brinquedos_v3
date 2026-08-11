import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rodizio_brinquedos_v3/services/storekit_pricing_diagnostics.dart';

const _monthlyProductId = 'com.rodiziobrinquedos.premium.monthly';
const _yearlyProductId = 'com.rodiziobrinquedos.premium.yearly';
const _productIds = <String>{_monthlyProductId, _yearlyProductId};
const _channel = MethodChannel(
  'com.rodiziobrinquedos.v3/storekit_reconciliation',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('parser aceita storefront Brasil e produto StoreKit em BRL', () {
    final snapshot = StoreKitPricingSnapshot.tryParse(
      _nativeResponse(
        storefront: <String, Object?>{
          'status': 'available',
          'countryCode': 'BRA',
          'id': '143503',
        },
        products: <Object?>[
          _nativeProduct(
            productId: _yearlyProductId,
            displayPrice: 'R\$ 99,90',
            rawPrice: '99.9',
            currencyCode: 'BRL',
          ),
        ],
        notFoundProductIds: <Object?>[_monthlyProductId],
      ),
      supportedProductIds: _productIds,
    );

    expect(snapshot.status, StoreKitPricingSnapshotStatus.success);
    expect(
      snapshot.storefront!.status,
      StoreKitPricingStorefrontStatus.available,
    );
    expect(snapshot.storefront!.countryCode, 'BRA');
    expect(snapshot.storefront!.id, '143503');
    expect(snapshot.products.single.currencyCode, 'BRL');
    expect(snapshot.products.single.displayPrice, 'R\$ 99,90');
  });

  test('produto Flutter em BRL registra todos os campos de preço', () async {
    final logs = <String>[];
    final diagnostics = _diagnostics(
      logs: logs,
      snapshot: const StoreKitPricingSnapshot.unavailable(),
    );

    final sequence = diagnostics.logQueryStart();
    await diagnostics.logQueryResult(
      sequence: sequence,
      flutterProducts: <ProductDetails>[
        _flutterProduct(
          productId: _monthlyProductId,
          price: 'R\$ 14,90',
          rawPrice: 14.9,
          currencyCode: 'BRL',
        ),
      ],
      flutterNotFoundProductIds: const <String>[_yearlyProductId],
    );

    final fields = _singlePhase(logs, 'flutter_product');
    expect(fields['product_id'], _monthlyProductId);
    expect(fields['price'], 'R\$ 14,90');
    expect(fields['raw_price'], 14.9);
    expect(fields['currency_code'], 'BRL');
  });

  test('produto Flutter em USD permanece diagnóstico sem conversão', () async {
    final logs = <String>[];
    final diagnostics = _diagnostics(
      logs: logs,
      snapshot: const StoreKitPricingSnapshot.unavailable(),
    );

    await diagnostics.logQueryResult(
      sequence: diagnostics.logQueryStart(),
      flutterProducts: <ProductDetails>[
        _flutterProduct(
          productId: _yearlyProductId,
          price: r'$14.99',
          rawPrice: 14.99,
          currencyCode: 'USD',
        ),
      ],
      flutterNotFoundProductIds: const <String>[_monthlyProductId],
    );

    final fields = _singlePhase(logs, 'flutter_product');
    expect(fields['price'], r'$14.99');
    expect(fields['raw_price'], 14.99);
    expect(fields['currency_code'], 'USD');
  });

  test(
    'storefront indisponível é aceito e registrado explicitamente',
    () async {
      final snapshot = StoreKitPricingSnapshot.tryParse(
        _nativeResponse(
          storefront: <String, Object?>{'status': 'unavailable'},
          products: const <Object?>[],
          notFoundProductIds: const <Object?>[
            _monthlyProductId,
            _yearlyProductId,
          ],
        ),
        supportedProductIds: _productIds,
      );
      final logs = <String>[];
      final diagnostics = _diagnostics(logs: logs, snapshot: snapshot);

      await diagnostics.logQueryResult(
        sequence: diagnostics.logQueryStart(),
        flutterProducts: const <ProductDetails>[],
        flutterNotFoundProductIds: _productIds,
      );

      final fields = _singlePhase(logs, 'storefront');
      expect(fields['status'], 'unavailable');
      expect(fields['country_code'], '<unavailable>');
      expect(fields['storefront_id'], '<unavailable>');
    },
  );

  test('resposta nativa malformada falha de forma fechada', () {
    final snapshot = StoreKitPricingSnapshot.tryParse(<String, Object?>{
      'status': 'success',
      'storefront': <String, Object?>{
        'status': 'available',
        'countryCode': 'BR',
        'id': '143503',
      },
      'products': const <Object?>[],
      'notFoundProductIds': const <Object?>[],
    }, supportedProductIds: _productIds);

    expect(snapshot.status, StoreKitPricingSnapshotStatus.malformed);
  });

  test('falha do método nativo retorna status failed sem propagar', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (_) async {
      throw PlatformException(code: 'storekit_pricing_failed');
    });
    const client = MethodChannelStoreKitPricingDiagnosticsClient(
      channel: _channel,
      supportedProductIds: _productIds,
    );

    final snapshot = await client.loadPricingSnapshot();

    expect(snapshot.status, StoreKitPricingSnapshotStatus.failed);

    final logs = <String>[];
    final diagnostics = StoreKitPricingDiagnostics(
      client: client,
      supportedProductIds: _productIds,
      logger: logs.add,
      deviceLocaleTags: () => const <String>['pt-BR'],
    );
    await diagnostics.logQueryResult(
      sequence: diagnostics.logQueryStart(),
      flutterProducts: const <ProductDetails>[],
      flutterNotFoundProductIds: _productIds,
    );
    expect(_singlePhase(logs, 'native_result')['status'], 'failed');
  });

  test(
    'logs são de linha única e não incluem título ou descrição pessoal',
    () async {
      final logs = <String>[];
      final diagnostics = StoreKitPricingDiagnostics(
        client: const _FakeClient(StoreKitPricingSnapshot.unavailable()),
        supportedProductIds: _productIds,
        logger: logs.add,
        deviceLocaleTags: () => <String>['pt-BR\nuser@example.com'],
      );

      await diagnostics.logQueryResult(
        sequence: diagnostics.logQueryStart(),
        flutterProducts: <ProductDetails>[
          ProductDetails(
            id: _monthlyProductId,
            title: 'user@example.com',
            description: 'private receipt',
            price: 'R\$ 14,90',
            rawPrice: 14.9,
            currencyCode: 'BRL',
            currencySymbol: r'R$',
          ),
        ],
        flutterNotFoundProductIds: const <String>[_yearlyProductId],
      );

      expect(logs, isNotEmpty);
      for (final log in logs) {
        expect(log, startsWith('[StoreKitPricing] {'));
        expect(log, isNot(contains('\n')));
        expect(log, isNot(contains('\r')));
        expect(log, isNot(contains('user@example.com')));
        expect(log, isNot(contains('private receipt')));
      }
    },
  );

  test('produtos Flutter e StoreKit têm ordenação determinística', () async {
    final logs = <String>[];
    final diagnostics = _diagnostics(
      logs: logs,
      snapshot: const StoreKitPricingSnapshot.success(
        storefront: StoreKitPricingStorefront.available(
          countryCode: 'BRA',
          id: '143503',
        ),
        products: <StoreKitPricingNativeProduct>[
          StoreKitPricingNativeProduct(
            productId: _yearlyProductId,
            displayPrice: 'R\$ 99,90',
            rawPrice: '99.9',
            currencyCode: 'BRL',
          ),
          StoreKitPricingNativeProduct(
            productId: _monthlyProductId,
            displayPrice: 'R\$ 14,90',
            rawPrice: '14.9',
            currencyCode: 'BRL',
          ),
        ],
        notFoundProductIds: <String>[],
      ),
    );

    await diagnostics.logQueryResult(
      sequence: diagnostics.logQueryStart(),
      flutterProducts: <ProductDetails>[
        _flutterProduct(
          productId: _yearlyProductId,
          price: 'R\$ 99,90',
          rawPrice: 99.9,
          currencyCode: 'BRL',
        ),
        _flutterProduct(
          productId: _monthlyProductId,
          price: 'R\$ 14,90',
          rawPrice: 14.9,
          currencyCode: 'BRL',
        ),
      ],
      flutterNotFoundProductIds: const <String>[],
    );

    expect(_productsForPhase(logs, 'flutter_product'), <String>[
      _monthlyProductId,
      _yearlyProductId,
    ]);
    expect(_productsForPhase(logs, 'storekit_product'), <String>[
      _monthlyProductId,
      _yearlyProductId,
    ]);
  });

  test('primeiro paywall registra locale, device locales e preços uma vez', () {
    final logs = <String>[];
    final diagnostics = _diagnostics(
      logs: logs,
      snapshot: const StoreKitPricingSnapshot.unavailable(),
    );
    final products = <String, ProductDetails>{
      _yearlyProductId: _flutterProduct(
        productId: _yearlyProductId,
        price: 'R\$ 99,90',
        rawPrice: 99.9,
        currencyCode: 'BRL',
      ),
      _monthlyProductId: _flutterProduct(
        productId: _monthlyProductId,
        price: 'R\$ 14,90',
        rawPrice: 14.9,
        currencyCode: 'BRL',
      ),
    };

    diagnostics.logPaywallDisplay(
      flutterLocale: 'pt-BR',
      productsById: products,
    );
    diagnostics.logPaywallDisplay(
      flutterLocale: 'en-US',
      productsById: products,
    );

    final paywallLogs = logs
        .map(_fields)
        .where((fields) => fields['phase'] == 'paywall_display')
        .toList(growable: false);
    expect(paywallLogs, hasLength(2));
    expect(paywallLogs.first['flutter_locale'], 'pt-BR');
    expect(paywallLogs.first['device_locales'], <Object?>['pt-BR', 'en-US']);
    expect(paywallLogs.map((fields) => fields['product_id']), <Object?>[
      _monthlyProductId,
      _yearlyProductId,
    ]);
    expect(paywallLogs.map((fields) => fields['price']), <Object?>[
      'R\$ 14,90',
      'R\$ 99,90',
    ]);
  });
}

StoreKitPricingDiagnostics _diagnostics({
  required List<String> logs,
  required StoreKitPricingSnapshot snapshot,
}) {
  return StoreKitPricingDiagnostics(
    client: _FakeClient(snapshot),
    supportedProductIds: _productIds,
    logger: logs.add,
    deviceLocaleTags: () => <String>['pt-BR', 'en-US'],
  );
}

Map<String, Object?> _nativeResponse({
  required Map<String, Object?> storefront,
  required List<Object?> products,
  required List<Object?> notFoundProductIds,
}) {
  return <String, Object?>{
    'status': 'success',
    'storefront': storefront,
    'products': products,
    'notFoundProductIds': notFoundProductIds,
  };
}

Map<String, Object?> _nativeProduct({
  required String productId,
  required String displayPrice,
  required String rawPrice,
  required String currencyCode,
}) {
  return <String, Object?>{
    'productId': productId,
    'displayPrice': displayPrice,
    'rawPrice': rawPrice,
    'currencyCode': currencyCode,
  };
}

ProductDetails _flutterProduct({
  required String productId,
  required String price,
  required double rawPrice,
  required String currencyCode,
}) {
  return ProductDetails(
    id: productId,
    title: productId,
    description: productId,
    price: price,
    rawPrice: rawPrice,
    currencyCode: currencyCode,
    currencySymbol: currencyCode == 'BRL' ? r'R$' : r'$',
  );
}

Map<String, Object?> _singlePhase(List<String> logs, String phase) {
  return logs.map(_fields).singleWhere((fields) => fields['phase'] == phase);
}

List<String> _productsForPhase(List<String> logs, String phase) {
  return logs
      .map(_fields)
      .where((fields) => fields['phase'] == phase)
      .map((fields) => fields['product_id']! as String)
      .toList(growable: false);
}

Map<String, Object?> _fields(String log) {
  return (jsonDecode(log.substring('[StoreKitPricing] '.length))
          as Map<String, Object?>)
      .cast<String, Object?>();
}

class _FakeClient implements StoreKitPricingDiagnosticsClient {
  const _FakeClient(this.snapshot);

  final StoreKitPricingSnapshot snapshot;

  @override
  Future<StoreKitPricingSnapshot> loadPricingSnapshot() async => snapshot;
}
