import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService extends ChangeNotifier {
  static const String productId = 'com.rodiziobrinquedos.premium.monthly';
  static const String _premiumStorageKey = 'premium_active';
  static const Object _noValue = Object();

  final InAppPurchase _inAppPurchase;
  final SharedPreferences _preferences;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _isPremium = false;
  bool _isLoading = false;
  ProductDetails? _productDetails;
  String? _errorMessage;
  bool _storeAvailable = false;
  bool _initialized = false;

  PurchaseService._({
    required InAppPurchase inAppPurchase,
    required SharedPreferences preferences,
  })  : _inAppPurchase = inAppPurchase,
        _preferences = preferences;

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
  bool get isLoading => _isLoading;
  ProductDetails? get productDetails => _productDetails;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _isPremium = _preferences.getBool(_premiumStorageKey) ?? false;

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
    _setState(isLoading: true, errorMessage: null);

    try {
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        _setState(
          isLoading: false,
          errorMessage: 'Compras no app indisponíveis neste dispositivo.',
          productDetails: null,
          storeAvailable: false,
        );
        return;
      }

      final response = await _inAppPurchase.queryProductDetails({productId});
      if (response.error != null) {
        _setState(
          isLoading: false,
          errorMessage: response.error!.message,
          productDetails: null,
          storeAvailable: true,
        );
        return;
      }

      final details = response.productDetails.isEmpty
          ? null
          : response.productDetails.first;

      _setState(
        isLoading: false,
        errorMessage: details == null
            ? 'Assinatura premium não encontrada na App Store.'
            : null,
        productDetails: details,
        storeAvailable: true,
      );
    } catch (error) {
      _setState(
        isLoading: false,
        errorMessage: 'Falha ao carregar assinatura: $error',
        productDetails: null,
        storeAvailable: false,
      );
    }
  }

  Future<void> startPurchase() async {
    _setState(isLoading: true, errorMessage: null);

    if (!_storeAvailable || _productDetails == null) {
      await refreshProductDetails();
    }

    final details = _productDetails;
    if (!_storeAvailable || details == null) {
      _setState(
        isLoading: false,
        errorMessage: _errorMessage ??
            'Não foi possível carregar a assinatura premium.',
      );
      return;
    }

    try {
      final param = PurchaseParam(productDetails: details);
      final started = await _inAppPurchase.buyNonConsumable(
        purchaseParam: param,
      );

      if (started) {
        return;
      }
    } catch (error) {
      _setState(
        isLoading: false,
        errorMessage: 'A compra não pôde ser iniciada: $error',
      );
      return;
    }

    _setState(
      isLoading: false,
      errorMessage: 'A compra não pôde ser iniciada.',
    );
  }

  Future<void> restorePurchases() async {
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
      if (purchaseDetails.productID != productId) continue;

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          nextLoading = true;
          nextError = null;
          shouldNotify = true;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _setPremiumActive(true, notify: false);
          nextLoading = false;
          nextError = null;
          shouldNotify = true;
          break;
        case PurchaseStatus.error:
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
    bool? storeAvailable,
  }) {
    if (isLoading != null) {
      _isLoading = isLoading;
    }
    _errorMessage = errorMessage;
    if (!identical(productDetails, _noValue)) {
      _productDetails = productDetails as ProductDetails?;
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
