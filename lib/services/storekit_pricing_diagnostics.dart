import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

typedef StoreKitPricingLogger = void Function(String message);

enum StoreKitPricingSnapshotStatus { success, unavailable, malformed, failed }

enum StoreKitPricingStorefrontStatus { available, unavailable }

class StoreKitPricingStorefront {
  const StoreKitPricingStorefront._({
    required this.status,
    this.countryCode,
    this.id,
  });

  const StoreKitPricingStorefront.available({
    required String countryCode,
    required String id,
  }) : this._(
          status: StoreKitPricingStorefrontStatus.available,
          countryCode: countryCode,
          id: id,
        );

  const StoreKitPricingStorefront.unavailable()
      : this._(status: StoreKitPricingStorefrontStatus.unavailable);

  final StoreKitPricingStorefrontStatus status;
  final String? countryCode;
  final String? id;

  static StoreKitPricingStorefront? tryParse(Object? value) {
    if (value is! Map<Object?, Object?>) return null;
    switch (value['status']) {
      case 'available':
        final countryCode = value['countryCode'];
        final id = value['id'];
        if (countryCode is! String ||
            !RegExp(r'^[A-Z]{3}$').hasMatch(countryCode) ||
            id is! String ||
            id.isEmpty ||
            _containsControlCharacter(id)) {
          return null;
        }
        return StoreKitPricingStorefront.available(
          countryCode: countryCode,
          id: id,
        );
      case 'unavailable':
        return const StoreKitPricingStorefront.unavailable();
      default:
        return null;
    }
  }
}

class StoreKitPricingNativeProduct {
  const StoreKitPricingNativeProduct({
    required this.productId,
    required this.displayPrice,
    required this.rawPrice,
    required this.currencyCode,
  });

  final String productId;
  final String displayPrice;
  final String rawPrice;
  final String currencyCode;

  static StoreKitPricingNativeProduct? tryParse(
    Object? value, {
    required Set<String> supportedProductIds,
  }) {
    if (value is! Map<Object?, Object?>) return null;
    final productId = value['productId'];
    final displayPrice = value['displayPrice'];
    final rawPrice = value['rawPrice'];
    final currencyCode = value['currencyCode'];
    if (productId is! String ||
        !supportedProductIds.contains(productId) ||
        displayPrice is! String ||
        displayPrice.isEmpty ||
        _containsControlCharacter(displayPrice) ||
        rawPrice is! String ||
        !RegExp(r'^\d+(?:\.\d+)?$').hasMatch(rawPrice) ||
        currencyCode is! String ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)) {
      return null;
    }
    return StoreKitPricingNativeProduct(
      productId: productId,
      displayPrice: displayPrice,
      rawPrice: rawPrice,
      currencyCode: currencyCode,
    );
  }
}

class StoreKitPricingSnapshot {
  const StoreKitPricingSnapshot._({
    required this.status,
    this.storefront,
    this.products = const <StoreKitPricingNativeProduct>[],
    this.notFoundProductIds = const <String>[],
  });

  const StoreKitPricingSnapshot.success({
    required StoreKitPricingStorefront storefront,
    required List<StoreKitPricingNativeProduct> products,
    required List<String> notFoundProductIds,
  }) : this._(
          status: StoreKitPricingSnapshotStatus.success,
          storefront: storefront,
          products: products,
          notFoundProductIds: notFoundProductIds,
        );

  const StoreKitPricingSnapshot.unavailable()
      : this._(status: StoreKitPricingSnapshotStatus.unavailable);

  const StoreKitPricingSnapshot.malformed()
      : this._(status: StoreKitPricingSnapshotStatus.malformed);

  const StoreKitPricingSnapshot.failed()
      : this._(status: StoreKitPricingSnapshotStatus.failed);

  final StoreKitPricingSnapshotStatus status;
  final StoreKitPricingStorefront? storefront;
  final List<StoreKitPricingNativeProduct> products;
  final List<String> notFoundProductIds;

  static StoreKitPricingSnapshot tryParse(
    Object? value, {
    required Set<String> supportedProductIds,
  }) {
    if (value is! Map<Object?, Object?>) {
      return const StoreKitPricingSnapshot.malformed();
    }
    if (value['status'] == 'unavailable') {
      return const StoreKitPricingSnapshot.unavailable();
    }
    if (value['status'] != 'success') {
      return const StoreKitPricingSnapshot.malformed();
    }

    final storefront = StoreKitPricingStorefront.tryParse(value['storefront']);
    final rawProducts = value['products'];
    final rawNotFoundProductIds = value['notFoundProductIds'];
    if (storefront == null ||
        rawProducts is! List<Object?> ||
        rawNotFoundProductIds is! List<Object?>) {
      return const StoreKitPricingSnapshot.malformed();
    }

    final products = <StoreKitPricingNativeProduct>[];
    final foundProductIds = <String>{};
    for (final rawProduct in rawProducts) {
      final product = StoreKitPricingNativeProduct.tryParse(
        rawProduct,
        supportedProductIds: supportedProductIds,
      );
      if (product == null || !foundProductIds.add(product.productId)) {
        return const StoreKitPricingSnapshot.malformed();
      }
      products.add(product);
    }

    final notFoundProductIds = <String>[];
    final notFoundSet = <String>{};
    for (final rawProductId in rawNotFoundProductIds) {
      if (rawProductId is! String ||
          !supportedProductIds.contains(rawProductId) ||
          foundProductIds.contains(rawProductId) ||
          !notFoundSet.add(rawProductId)) {
        return const StoreKitPricingSnapshot.malformed();
      }
      notFoundProductIds.add(rawProductId);
    }

    if (!setEquals(<String>{
      ...foundProductIds,
      ...notFoundSet,
    }, supportedProductIds)) {
      return const StoreKitPricingSnapshot.malformed();
    }

    products.sort((left, right) => left.productId.compareTo(right.productId));
    notFoundProductIds.sort();
    return StoreKitPricingSnapshot.success(
      storefront: storefront,
      products: List<StoreKitPricingNativeProduct>.unmodifiable(products),
      notFoundProductIds: List<String>.unmodifiable(notFoundProductIds),
    );
  }
}

abstract interface class StoreKitPricingDiagnosticsClient {
  Future<StoreKitPricingSnapshot> loadPricingSnapshot();
}

class MethodChannelStoreKitPricingDiagnosticsClient
    implements StoreKitPricingDiagnosticsClient {
  const MethodChannelStoreKitPricingDiagnosticsClient({
    MethodChannel channel = _defaultChannel,
    Set<String> supportedProductIds = const <String>{},
  })  : _channel = channel,
        _supportedProductIds = supportedProductIds;

  static const MethodChannel _defaultChannel = MethodChannel(
    'com.rodiziobrinquedos.v3/storekit_reconciliation',
  );

  final MethodChannel _channel;
  final Set<String> _supportedProductIds;

  @override
  Future<StoreKitPricingSnapshot> loadPricingSnapshot() async {
    try {
      final response = await _channel.invokeMethod<Object?>(
        'pricingDiagnostics',
      );
      return StoreKitPricingSnapshot.tryParse(
        response,
        supportedProductIds: _supportedProductIds,
      );
    } on MissingPluginException {
      return const StoreKitPricingSnapshot.unavailable();
    } on PlatformException {
      return const StoreKitPricingSnapshot.failed();
    }
  }
}

class StoreKitPricingDiagnostics {
  StoreKitPricingDiagnostics({
    required StoreKitPricingDiagnosticsClient client,
    required Set<String> supportedProductIds,
    StoreKitPricingLogger? logger,
    List<String> Function()? deviceLocaleTags,
  })  : _client = client,
        _supportedProductIds = Set<String>.unmodifiable(supportedProductIds),
        _logger = logger ?? debugPrint,
        _deviceLocaleTags = deviceLocaleTags ?? _currentDeviceLocaleTags;

  final StoreKitPricingDiagnosticsClient _client;
  final Set<String> _supportedProductIds;
  final StoreKitPricingLogger _logger;
  final List<String> Function() _deviceLocaleTags;

  int _querySequence = 0;
  bool _paywallDisplayLogged = false;

  int logQueryStart() {
    final sequence = ++_querySequence;
    final locales = _safeDeviceLocaleTags();
    _emit(<String, Object?>{
      'phase': 'query_start',
      'sequence': sequence,
      'device_locale': locales.isEmpty ? 'und' : locales.first,
      'preferred_languages': locales,
    });
    return sequence;
  }

  Future<void> logQueryResult({
    required int sequence,
    required Iterable<ProductDetails> flutterProducts,
    required Iterable<String> flutterNotFoundProductIds,
  }) async {
    final products = flutterProducts
        .where((product) => _supportedProductIds.contains(product.id))
        .toList(growable: false)
      ..sort((left, right) => left.id.compareTo(right.id));
    for (final product in products) {
      _emit(<String, Object?>{
        'phase': 'flutter_product',
        'sequence': sequence,
        'product_id': product.id,
        'price': product.price,
        'raw_price': product.rawPrice,
        'currency_code': product.currencyCode,
      });
    }

    final notFoundProductIds = flutterNotFoundProductIds
        .where(_supportedProductIds.contains)
        .toSet()
        .toList(growable: false)
      ..sort();
    for (final productId in notFoundProductIds) {
      _emit(<String, Object?>{
        'phase': 'flutter_not_found',
        'sequence': sequence,
        'product_id': productId,
      });
    }

    StoreKitPricingSnapshot snapshot;
    try {
      snapshot = await _client.loadPricingSnapshot();
    } catch (_) {
      snapshot = const StoreKitPricingSnapshot.failed();
    }
    _logNativeSnapshot(sequence: sequence, snapshot: snapshot);
  }

  void logPaywallDisplay({
    required String flutterLocale,
    required Map<String, ProductDetails> productsById,
  }) {
    if (_paywallDisplayLogged) return;
    _paywallDisplayLogged = true;
    final deviceLocales = _safeDeviceLocaleTags();
    final productIds = _supportedProductIds.toList(growable: false)..sort();
    for (final productId in productIds) {
      _emit(<String, Object?>{
        'phase': 'paywall_display',
        'flutter_locale': flutterLocale,
        'device_locales': deviceLocales,
        'product_id': productId,
        'price': productsById[productId]?.price ?? '<unavailable>',
      });
    }
  }

  void _logNativeSnapshot({
    required int sequence,
    required StoreKitPricingSnapshot snapshot,
  }) {
    if (snapshot.status != StoreKitPricingSnapshotStatus.success) {
      _emit(<String, Object?>{
        'phase': 'native_result',
        'sequence': sequence,
        'status': snapshot.status.name,
      });
      return;
    }

    final storefront = snapshot.storefront!;
    _emit(<String, Object?>{
      'phase': 'storefront',
      'sequence': sequence,
      'status': storefront.status.name,
      'country_code': storefront.countryCode ?? '<unavailable>',
      'storefront_id': storefront.id ?? '<unavailable>',
    });
    final products = snapshot.products.toList(growable: false)
      ..sort((left, right) => left.productId.compareTo(right.productId));
    for (final product in products) {
      _emit(<String, Object?>{
        'phase': 'storekit_product',
        'sequence': sequence,
        'product_id': product.productId,
        'display_price': product.displayPrice,
        'raw_price': product.rawPrice,
        'currency_code': product.currencyCode,
      });
    }
    final notFoundProductIds = snapshot.notFoundProductIds.toList(
      growable: false,
    )..sort();
    for (final productId in notFoundProductIds) {
      _emit(<String, Object?>{
        'phase': 'storekit_not_found',
        'sequence': sequence,
        'product_id': productId,
      });
    }
  }

  List<String> _safeDeviceLocaleTags() {
    try {
      return _deviceLocaleTags()
          .map(_sanitizeString)
          .where((locale) => locale.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const <String>[];
    }
  }

  void _emit(Map<String, Object?> fields) {
    final sanitized = <String, Object?>{
      for (final entry in fields.entries)
        entry.key: switch (entry.value) {
          String value => _sanitizeString(value),
          List<String> value => value.map(_sanitizeString).toList(),
          _ => entry.value,
        },
    };
    try {
      _logger('[StoreKitPricing] ${jsonEncode(sanitized)}');
    } catch (_) {
      // Diagnostics must never alter purchase or paywall behavior.
    }
  }

  static List<String> _currentDeviceLocaleTags() {
    return PlatformDispatcher.instance.locales
        .map((locale) => locale.toLanguageTag())
        .toList(growable: false);
  }
}

bool _containsControlCharacter(String value) {
  return RegExp(r'[\u0000-\u001f\u007f]').hasMatch(value);
}

String _sanitizeString(String value) {
  final withoutControls = value
      .replaceAll(RegExp(r'[\u0000-\u001f\u007f]'), ' ')
      .replaceAll(
        RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'),
        '<redacted>',
      )
      .trim();
  return withoutControls.length <= 200
      ? withoutControls
      : withoutControls.substring(0, 200);
}
