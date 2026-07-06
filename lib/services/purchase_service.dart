import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/services/paywall_bypass.dart';
import 'package:rodizio_brinquedos_v3/services/paywall_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService extends ChangeNotifier {
  static const String monthlyProductId =
      'com.rodiziobrinquedos.premium.monthly';
  static const String yearlyProductId = 'com.rodiziobrinquedos.premium.yearly';
  static const String productId = monthlyProductId;
  static const Set<String> productIds = <String>{
    monthlyProductId,
    yearlyProductId,
  };
  static const String _premiumStorageKey = 'premium_active';
  static const Object _noValue = Object();

  static String planForProductId(String productId) {
    switch (productId) {
      case monthlyProductId:
        return 'monthly';
      case yearlyProductId:
        return 'annual';
      default:
        return 'unknown';
    }
  }

  final InAppPurchase _inAppPurchase;
  final SharedPreferences _preferences;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _isPremium = false;
  bool _isLoading = false;
  ProductDetails? _productDetails;
  Map<String, ProductDetails> _productDetailsById =
      const <String, ProductDetails>{};
  final Map<String, String> _purchaseSourceByProductId = <String, String>{};
  String _lastRestoreSource = 'unknown';
  String? _errorMessage;
  bool _storeAvailable = false;
  bool _initialized = false;

  PurchaseService._({
    required InAppPurchase inAppPurchase,
    required SharedPreferences preferences,
  })  : _inAppPurchase = inAppPurchase,
        _preferences = preferences;

  @visibleForTesting
  factory PurchaseService.forTesting({
    required SharedPreferences preferences,
    bool isPremium = false,
  }) {
    final service = PurchaseService._(
      inAppPurchase: InAppPurchase.instance,
      preferences: preferences,
    );
    service._initialized = true;
    service._isPremium = isPremium;
    service._isLoading = false;
    service._storeAvailable = true;
    return service;
  }

  static Future<PurchaseService> create() async {
    final preferences = await SharedPreferences.getInstance();
    final service = PurchaseService._(
      inAppPurchase: InAppPurchase.instance,
      preferences: preferences,
    );
    await service.initialize();
    return service;
  }

  bool get isPremium => _isPremium;
  bool get hasPremiumAccess =>
      _isPremium || kBypassPaywall || !isPaywallEnabledForCurrentPlatform;
  bool get isLoading => _isLoading;
  ProductDetails? get productDetails => _productDetails;
  ProductDetails? productDetailsFor(String productId) =>
      _productDetailsById[productId];
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugLogPaywallBypassIfEnabled();
    _isPremium = _preferences.getBool(_premiumStorageKey) ?? false;

    if (!isPaywallEnabledForCurrentPlatform) {
      _isLoading = false;
      _storeAvailable = false;
      _productDetails = null;
      _productDetailsById = const <String, ProductDetails>{};
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        _setState(
          isLoading: false,
          errorMessage: 'Falha ao ouvir atualizações de compra: $error',
        );
      },
    );

    notifyListeners();
    await refreshProductDetails();
  }

  Future<void> refreshProductDetails() async {
    if (!isPaywallEnabledForCurrentPlatform) {
      _setState(
        isLoading: false,
        errorMessage: null,
        productDetails: null,
        productDetailsById: <String, ProductDetails>{},
        storeAvailable: false,
      );
      return;
    }

    _setState(isLoading: true, errorMessage: null);

    try {
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        _setState(
          isLoading: false,
          errorMessage: 'Compras no app indisponíveis neste dispositivo.',
          productDetails: null,
          productDetailsById: <String, ProductDetails>{},
          storeAvailable: false,
        );
        return;
      }

      final response = await _inAppPurchase.queryProductDetails(productIds);
      if (response.error != null) {
        _setState(
          isLoading: false,
          errorMessage: response.error!.message,
          productDetails: null,
          productDetailsById: <String, ProductDetails>{},
          storeAvailable: true,
        );
        return;
      }

      final detailsById = <String, ProductDetails>{
        for (final details in response.productDetails) details.id: details,
      };
      final details = detailsById[monthlyProductId] ??
          detailsById[yearlyProductId] ??
          (response.productDetails.isEmpty
              ? null
              : response.productDetails.first);

      _setState(
        isLoading: false,
        errorMessage:
            details == null ? 'Assinaturas não encontradas na loja.' : null,
        productDetails: details,
        productDetailsById: detailsById,
        storeAvailable: true,
      );
    } catch (error) {
      _setState(
        isLoading: false,
        errorMessage: 'Falha ao carregar assinatura: $error',
        productDetails: null,
        productDetailsById: <String, ProductDetails>{},
        storeAvailable: false,
      );
    }
  }

  Future<void> startPurchase({
    String productId = PurchaseService.productId,
    String source = 'unknown',
  }) async {
    final plan = planForProductId(productId);
    _purchaseSourceByProductId[productId] = source;
    if (!isPaywallEnabledForCurrentPlatform) {
      _setState(isLoading: false, errorMessage: null, storeAvailable: false);
      return;
    }

    _setState(isLoading: true, errorMessage: null);

    if (!_storeAvailable || !_productDetailsById.containsKey(productId)) {
      await refreshProductDetails();
    }

    final details = _productDetailsById[productId] ??
        (productId == PurchaseService.productId ? _productDetails : null);
    if (!_storeAvailable || details == null) {
      await AppAnalytics.logPurchaseFailed(
        plan: plan,
        source: source,
        reason: 'product_unavailable',
      );
      _setState(
        isLoading: false,
        errorMessage:
            _errorMessage ?? 'Não foi possível carregar a assinatura.',
      );
      return;
    }

    try {
      final param = PurchaseParam(productDetails: details);
      await AppAnalytics.logPurchaseStarted(
        plan: plan,
        source: source,
      );
      final started = await _inAppPurchase.buyNonConsumable(
        purchaseParam: param,
      );

      if (started) {
        return;
      }
    } catch (error) {
      await AppAnalytics.logPurchaseFailed(
        plan: plan,
        source: source,
        reason: 'start_error',
      );
      _setState(
        isLoading: false,
        errorMessage: 'A compra não pôde ser iniciada: $error',
      );
      return;
    }

    await AppAnalytics.logPurchaseFailed(
      plan: plan,
      source: source,
      reason: 'start_failed',
    );
    _setState(
      isLoading: false,
      errorMessage: 'A compra não pôde ser iniciada.',
    );
  }

  Future<void> restorePurchases({
    String source = 'unknown',
  }) async {
    _lastRestoreSource = source;
    if (!isPaywallEnabledForCurrentPlatform) {
      _setState(isLoading: false, errorMessage: null, storeAvailable: false);
      return;
    }

    _setState(isLoading: true, errorMessage: null);

    final available = _storeAvailable || await _inAppPurchase.isAvailable();
    if (!available) {
      _setState(
        isLoading: false,
        errorMessage: 'Compras no app indisponíveis neste dispositivo.',
        storeAvailable: false,
      );
      return;
    }

    _storeAvailable = true;
    notifyListeners();
    try {
      await _inAppPurchase.restorePurchases();
      _setState(isLoading: false, errorMessage: null, storeAvailable: true);
    } catch (error) {
      await AppAnalytics.logPurchaseFailed(
        plan: 'unknown',
        source: source,
        reason: 'restore_error',
      );
      _setState(
        isLoading: false,
        errorMessage: 'Falha ao restaurar compras: $error',
        storeAvailable: true,
      );
    }
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    var shouldNotify = false;
    var nextLoading = _isLoading;
    String? nextError = _errorMessage;

    for (final purchaseDetails in purchaseDetailsList) {
      if (!productIds.contains(purchaseDetails.productID)) continue;

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          nextLoading = true;
          nextError = null;
          shouldNotify = true;
          break;
        case PurchaseStatus.purchased:
          await _setPremiumActive(true, notify: false);
          await AppAnalytics.logPurchaseCompleted(
            plan: planForProductId(purchaseDetails.productID),
            source: _purchaseSourceByProductId[purchaseDetails.productID] ??
                'unknown',
          );
          nextLoading = false;
          nextError = null;
          shouldNotify = true;
          break;
        case PurchaseStatus.restored:
          await _setPremiumActive(true, notify: false);
          await AppAnalytics.logPurchaseRestored(
            source: _lastRestoreSource,
          );
          nextLoading = false;
          nextError = null;
          shouldNotify = true;
          break;
        case PurchaseStatus.error:
          await AppAnalytics.logPurchaseFailed(
            plan: planForProductId(purchaseDetails.productID),
            source: _purchaseSourceByProductId[purchaseDetails.productID] ??
                'unknown',
            reason: 'purchase_error',
          );
          nextLoading = false;
          nextError = purchaseDetails.error?.message ??
              'Não foi possível concluir a compra.';
          shouldNotify = true;
          break;
        case PurchaseStatus.canceled:
          nextLoading = false;
          nextError = 'Compra cancelada.';
          shouldNotify = true;
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }

    if (shouldNotify) {
      _isLoading = nextLoading;
      _errorMessage = nextError;
      notifyListeners();
    }
  }

  Future<void> _setPremiumActive(bool value, {bool notify = true}) async {
    _isPremium = value;
    await _preferences.setBool(_premiumStorageKey, value);
    if (notify) {
      notifyListeners();
    }
  }

  void _setState({
    bool? isLoading,
    String? errorMessage,
    Object? productDetails = _noValue,
    Object? productDetailsById = _noValue,
    bool? storeAvailable,
  }) {
    if (isLoading != null) {
      _isLoading = isLoading;
    }
    _errorMessage = errorMessage;
    if (!identical(productDetails, _noValue)) {
      _productDetails = productDetails as ProductDetails?;
    }
    if (!identical(productDetailsById, _noValue)) {
      _productDetailsById = Map<String, ProductDetails>.unmodifiable(
        productDetailsById as Map<String, ProductDetails>,
      );
    }
    if (storeAvailable != null) {
      _storeAvailable = storeAvailable;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
