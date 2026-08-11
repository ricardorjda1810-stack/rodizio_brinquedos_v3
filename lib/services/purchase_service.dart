import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/apple_transaction_analytics_coordinator.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/paywall_analytics_context.dart';
import 'package:rodizio_brinquedos_v3/services/paywall_bypass.dart';
import 'package:rodizio_brinquedos_v3/services/paywall_platform.dart';
import 'package:rodizio_brinquedos_v3/services/storekit_pricing_diagnostics.dart';
import 'package:rodizio_brinquedos_v3/services/storekit_reconciliation.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef StoreKitReconciliationDiagnosticsLogger = void Function(String message);

class PurchaseService extends ChangeNotifier {
  static const Duration _defaultCompletePurchaseTimeout = Duration(seconds: 20);
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
  static const bool _defaultStoreKitDiagnosticsEnabled =
      String.fromEnvironment('FIREBASE_ENV') == 'staging';

  static PremiumPlan planForProductId(String productId) {
    switch (productId) {
      case monthlyProductId:
        return PremiumPlan.monthly;
      case yearlyProductId:
        return PremiumPlan.yearly;
      default:
        throw ArgumentError.value(
          productId,
          'productId',
          'Unsupported subscription product.',
        );
    }
  }

  final InAppPurchase? _inAppPurchase;
  final SharedPreferences _preferences;
  final AppleTransactionAnalyticsCoordinator
      _appleTransactionAnalyticsCoordinator;
  final bool Function() _isIosPlatform;
  final Future<void> Function(PurchaseDetails purchaseDetails)?
      _completePurchase;
  final Duration _completePurchaseTimeout;
  final Future<bool> Function(ProductDetails productDetails)? _purchaseLauncher;
  final PurchaseFunnelAnalytics _purchaseFunnelAnalytics;
  final AnalyticsOpaqueIdGenerator _analyticsIdGenerator;
  final bool Function() _isPaywallEnabled;
  final StoreKitReconciliationClient? _storeKitReconciliationClient;
  final StoreKitPricingDiagnostics? _storeKitPricingDiagnostics;
  final Future<Map<String, ProductDetails>> Function()? _productDetailsLoader;
  final bool _storeKitDiagnosticsEnabled;
  final StoreKitReconciliationDiagnosticsLogger _storeKitDiagnosticsLogger;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _isPremium = false;
  bool _isLoading = false;
  ProductDetails? _productDetails;
  Map<String, ProductDetails> _productDetailsById =
      const <String, ProductDetails>{};
  final Map<String, PurchaseAttemptContext> _activePurchaseAttemptsByProductId =
      <String, PurchaseAttemptContext>{};
  final Map<String, _StoreKitTransactionSessionState>
      _storeKitTransactionsById = <String, _StoreKitTransactionSessionState>{};
  final List<List<PurchaseDetails>> _queuedInitialPurchaseUpdates =
      <List<PurchaseDetails>>[];
  final Set<String> _uncertainCompletionProductIds = <String>{};
  final Set<String> _uncertainCompletionTransactionIds = <String>{};
  Future<void> _storeKitReconciliationTail = Future<void>.value();
  bool _initialStoreKitReconciliationComplete;
  bool _drainingInitialPurchaseUpdates = false;
  bool _disposed = false;
  int _nextStoreKitTransactionOrdinal = 0;
  String _lastRestoreSource = 'unknown';
  String? _errorMessage;
  bool _storeAvailable = false;
  bool _initialized = false;

  PurchaseService._({
    required InAppPurchase? inAppPurchase,
    required SharedPreferences preferences,
    required AppleTransactionAnalyticsCoordinator
        appleTransactionAnalyticsCoordinator,
    required bool Function() isIosPlatform,
    required Future<void> Function(PurchaseDetails purchaseDetails)?
        completePurchase,
    required Duration completePurchaseTimeout,
    required Future<bool> Function(ProductDetails productDetails)?
        purchaseLauncher,
    required PurchaseFunnelAnalytics purchaseFunnelAnalytics,
    required AnalyticsOpaqueIdGenerator analyticsIdGenerator,
    required bool Function() isPaywallEnabled,
    required StoreKitReconciliationClient? storeKitReconciliationClient,
    required StoreKitPricingDiagnostics? storeKitPricingDiagnostics,
    required Future<Map<String, ProductDetails>> Function()?
        productDetailsLoader,
    required bool storeKitDiagnosticsEnabled,
    required StoreKitReconciliationDiagnosticsLogger storeKitDiagnosticsLogger,
    required bool initialStoreKitReconciliationComplete,
  })  : _inAppPurchase = inAppPurchase,
        _preferences = preferences,
        _appleTransactionAnalyticsCoordinator =
            appleTransactionAnalyticsCoordinator,
        _isIosPlatform = isIosPlatform,
        _completePurchase = completePurchase,
        _completePurchaseTimeout = completePurchaseTimeout,
        _purchaseLauncher = purchaseLauncher,
        _purchaseFunnelAnalytics = purchaseFunnelAnalytics,
        _analyticsIdGenerator = analyticsIdGenerator,
        _isPaywallEnabled = isPaywallEnabled,
        _storeKitReconciliationClient = storeKitReconciliationClient,
        _storeKitPricingDiagnostics = storeKitPricingDiagnostics,
        _productDetailsLoader = productDetailsLoader,
        _storeKitDiagnosticsEnabled = storeKitDiagnosticsEnabled,
        _storeKitDiagnosticsLogger = storeKitDiagnosticsLogger,
        _initialStoreKitReconciliationComplete =
            initialStoreKitReconciliationComplete;

  @visibleForTesting
  factory PurchaseService.forTesting({
    required SharedPreferences preferences,
    bool isPremium = false,
    Map<String, ProductDetails> productDetailsById =
        const <String, ProductDetails>{},
    AppleTransactionAnalyticsCoordinator? appleTransactionAnalyticsCoordinator,
    bool isIosPlatform = false,
    Future<void> Function(PurchaseDetails purchaseDetails)? completePurchase,
    Duration completePurchaseTimeout = _defaultCompletePurchaseTimeout,
    Future<bool> Function(ProductDetails productDetails)? purchaseLauncher,
    PurchaseFunnelAnalytics purchaseFunnelAnalytics =
        const FirebasePurchaseFunnelAnalytics(),
    AnalyticsOpaqueIdGenerator analyticsIdGenerator = generateAnalyticsOpaqueId,
    bool paywallEnabled = true,
    StoreKitReconciliationClient? storeKitReconciliationClient,
    StoreKitPricingDiagnostics? storeKitPricingDiagnostics,
    Future<Map<String, ProductDetails>> Function()? productDetailsLoader,
    bool storeKitDiagnosticsEnabled = false,
    StoreKitReconciliationDiagnosticsLogger? storeKitDiagnosticsLogger,
    bool initialStoreKitReconciliationComplete = true,
  }) {
    final service = PurchaseService._(
      inAppPurchase: null,
      preferences: preferences,
      appleTransactionAnalyticsCoordinator:
          appleTransactionAnalyticsCoordinator ??
              AppleTransactionAnalyticsCoordinator(
                preferencesProvider: () async => preferences,
                isAnalyticsConfigured: () => false,
                sendTransaction: (_) async {},
              ),
      isIosPlatform: () => isIosPlatform,
      completePurchase: completePurchase,
      completePurchaseTimeout: completePurchaseTimeout,
      purchaseLauncher: purchaseLauncher,
      purchaseFunnelAnalytics: purchaseFunnelAnalytics,
      analyticsIdGenerator: analyticsIdGenerator,
      isPaywallEnabled: () => paywallEnabled,
      storeKitReconciliationClient: storeKitReconciliationClient,
      storeKitPricingDiagnostics: storeKitPricingDiagnostics,
      productDetailsLoader: productDetailsLoader,
      storeKitDiagnosticsEnabled: storeKitDiagnosticsEnabled,
      storeKitDiagnosticsLogger: storeKitDiagnosticsLogger ?? debugPrint,
      initialStoreKitReconciliationComplete:
          initialStoreKitReconciliationComplete,
    );
    service._initialized = true;
    service._isPremium = isPremium;
    service._isLoading = false;
    service._storeAvailable = true;
    service._productDetailsById = Map<String, ProductDetails>.unmodifiable(
      productDetailsById,
    );
    service._productDetails = productDetailsById[monthlyProductId] ??
        productDetailsById[yearlyProductId] ??
        (productDetailsById.isEmpty ? null : productDetailsById.values.first);
    return service;
  }

  static Future<PurchaseService> create() async {
    final preferences = await SharedPreferences.getInstance();
    final inAppPurchase = InAppPurchase.instance;
    final isIosPlatform =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final service = PurchaseService._(
      inAppPurchase: inAppPurchase,
      preferences: preferences,
      appleTransactionAnalyticsCoordinator:
          AppAnalytics.appleTransactionAnalyticsCoordinator,
      isIosPlatform: () => isIosPlatform,
      completePurchase: inAppPurchase.completePurchase,
      completePurchaseTimeout: _defaultCompletePurchaseTimeout,
      purchaseLauncher: (productDetails) {
        return inAppPurchase.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: productDetails),
        );
      },
      purchaseFunnelAnalytics: const FirebasePurchaseFunnelAnalytics(),
      analyticsIdGenerator: generateAnalyticsOpaqueId,
      isPaywallEnabled: () => isPaywallEnabledForCurrentPlatform,
      storeKitReconciliationClient: isIosPlatform
          ? const MethodChannelStoreKitReconciliationClient()
          : null,
      storeKitPricingDiagnostics: isIosPlatform
          ? StoreKitPricingDiagnostics(
              client: const MethodChannelStoreKitPricingDiagnosticsClient(
                supportedProductIds: productIds,
              ),
              supportedProductIds: productIds,
            )
          : null,
      productDetailsLoader: null,
      storeKitDiagnosticsEnabled: _defaultStoreKitDiagnosticsEnabled,
      storeKitDiagnosticsLogger: debugPrint,
      initialStoreKitReconciliationComplete: !isIosPlatform,
    );
    await service.initialize();
    return service;
  }

  bool get isPremium => _isPremium;
  bool get hasPremiumAccess =>
      _isPremium || kBypassPaywall || !_isPaywallEnabled();
  bool get isLoading => _isLoading;
  ProductDetails? get productDetails => _productDetails;
  ProductDetails? productDetailsFor(String productId) =>
      _productDetailsById[productId];
  bool get hasLoadedSubscriptionProducts => _productDetailsById.isNotEmpty;
  String? get errorMessage => _errorMessage;

  void logStoreKitPricingPaywallDisplay({required String flutterLocale}) {
    _storeKitPricingDiagnostics?.logPaywallDisplay(
      flutterLocale: flutterLocale,
      productsById: _productDetailsById,
    );
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugLogPaywallBypassIfEnabled();
    _isPremium = _preferences.getBool(_premiumStorageKey) ?? false;

    if (!_isPaywallEnabled()) {
      _isLoading = false;
      _storeAvailable = false;
      _productDetails = null;
      _productDetailsById = const <String, ProductDetails>{};
      _errorMessage = null;
      notifyListeners();
      return;
    }

    final inAppPurchase = _inAppPurchase;
    if (inAppPurchase == null) return;

    _purchaseSubscription = inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        unawaited(_handlePurchaseStreamFailure());
        _setState(
          isLoading: false,
          errorMessage: 'Falha ao ouvir atualizações de compra: $error',
        );
      },
    );

    notifyListeners();
    await refreshProductDetails();
    await _runInitialStoreKitReconciliation();
  }

  Future<void> _runInitialStoreKitReconciliation() async {
    try {
      await _reconcileStoreKitSubscription();
    } finally {
      await _completeInitialStoreKitReconciliation();
    }
  }

  Future<void> _completeInitialStoreKitReconciliation() async {
    _initialStoreKitReconciliationComplete = true;
    if (_disposed) {
      _queuedInitialPurchaseUpdates.clear();
      return;
    }

    _drainingInitialPurchaseUpdates = true;
    try {
      while (_queuedInitialPurchaseUpdates.isNotEmpty && !_disposed) {
        final purchaseDetails = _queuedInitialPurchaseUpdates.removeAt(0);
        await _processPurchaseUpdates(purchaseDetails);
      }
    } finally {
      _drainingInitialPurchaseUpdates = false;
      if (_disposed) {
        _queuedInitialPurchaseUpdates.clear();
      }
    }
  }

  Future<void> refreshProductDetails() async {
    if (!_isPaywallEnabled()) {
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
      final inAppPurchase = _inAppPurchase;
      if (inAppPurchase == null) {
        _setState(
          isLoading: false,
          errorMessage: 'Compras no app indisponíveis neste dispositivo.',
          productDetails: null,
          productDetailsById: <String, ProductDetails>{},
          storeAvailable: false,
        );
        return;
      }

      final available = await inAppPurchase.isAvailable();
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

      final pricingQuerySequence = _storeKitPricingDiagnostics?.logQueryStart();
      final response = await inAppPurchase.queryProductDetails(productIds);
      if (pricingQuerySequence != null) {
        unawaited(
          _storeKitPricingDiagnostics!.logQueryResult(
            sequence: pricingQuerySequence,
            flutterProducts: response.productDetails,
            flutterNotFoundProductIds: response.notFoundIDs,
          ),
        );
      }
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

  Future<void> _refreshProductsForPurchase() async {
    final loader = _productDetailsLoader;
    if (loader == null) {
      await refreshProductDetails();
      return;
    }

    try {
      final detailsById = await loader();
      final details = detailsById[monthlyProductId] ??
          detailsById[yearlyProductId] ??
          (detailsById.isEmpty ? null : detailsById.values.first);
      _setState(
        isLoading: false,
        errorMessage:
            details == null ? 'Assinaturas não encontradas na loja.' : null,
        productDetails: details,
        productDetailsById: detailsById,
        storeAvailable: true,
      );
    } catch (_) {
      _setState(
        isLoading: false,
        errorMessage: 'Falha ao carregar assinatura.',
        productDetails: null,
        productDetailsById: <String, ProductDetails>{},
        storeAvailable: false,
      );
    }
  }

  Future<void> startPurchase({
    String productId = PurchaseService.productId,
    required PaywallAnalyticsContext paywallContext,
  }) async {
    if (!_isPaywallEnabled()) {
      _setState(isLoading: false, errorMessage: null, storeAvailable: false);
      return;
    }

    if (_uncertainCompletionProductIds.contains(productId)) {
      return;
    }

    if (_activePurchaseAttemptsByProductId.containsKey(productId)) {
      return;
    }

    final attempt = PurchaseAttemptContext.create(
      plan: planForProductId(productId),
      productId: productId,
      paywall: paywallContext,
      idGenerator: _analyticsIdGenerator,
    );
    _activePurchaseAttemptsByProductId[productId] = attempt;
    _setState(isLoading: true, errorMessage: null);

    if ((!_storeAvailable || !_productDetailsById.containsKey(productId)) &&
        (_inAppPurchase != null || _productDetailsLoader != null)) {
      await _refreshProductsForPurchase();
    }

    final details = _productDetailsById[productId] ??
        (productId == PurchaseService.productId ? _productDetails : null);
    if (!_storeAvailable || details == null) {
      _consumePurchaseAttempt(productId, expected: attempt);
      await _logPurchaseFailed(
        context: attempt,
        failureStage: PurchaseFailureStage.productResolution,
        failureCode: _storeAvailable
            ? PurchaseFailureCode.productNotFound
            : PurchaseFailureCode.storeUnavailable,
      );
      _setState(
        isLoading: false,
        errorMessage:
            _errorMessage ?? 'Não foi possível carregar a assinatura.',
      );
      return;
    }

    final purchaseLauncher = _purchaseLauncher;
    if (purchaseLauncher == null) {
      _consumePurchaseAttempt(productId, expected: attempt);
      await _logPurchaseFailed(
        context: attempt,
        failureStage: PurchaseFailureStage.purchaseLaunch,
        failureCode: PurchaseFailureCode.storeUnavailable,
      );
      _setState(
        isLoading: false,
        errorMessage: 'Não foi possível carregar a assinatura.',
      );
      return;
    }

    try {
      await _runAnalyticsSafely(
        () => _purchaseFunnelAnalytics.logPurchaseStarted(attempt),
      );
      _logPurchaseFlow(
        'launcher_begin plan=${_purchaseFlowPlan(productId)} '
        'context_present=${_activePurchaseAttemptsByProductId.containsKey(productId)}',
      );
      final started = await purchaseLauncher(details);
      _logPurchaseFlow('launcher_result accepted=$started');

      if (started) {
        return;
      }
    } catch (error) {
      _logPurchaseFlow('launcher_exception code=store_error');
      _consumePurchaseAttempt(productId, expected: attempt);
      await _logPurchaseFailed(
        context: attempt,
        failureStage: PurchaseFailureStage.purchaseLaunch,
        failureCode: PurchaseFailureCode.storeError,
      );
      _setState(
        isLoading: false,
        errorMessage: 'A compra não pôde ser iniciada: $error',
      );
      return;
    }

    _consumePurchaseAttempt(productId, expected: attempt);
    await _logPurchaseFailed(
      context: attempt,
      failureStage: PurchaseFailureStage.purchaseLaunch,
      failureCode: PurchaseFailureCode.launchRejected,
    );
    _setState(
      isLoading: false,
      errorMessage: 'A compra não pôde ser iniciada.',
    );
  }

  Future<void> restorePurchases({String source = 'unknown'}) async {
    if (_uncertainCompletionProductIds.isNotEmpty) {
      return;
    }

    _lastRestoreSource = source;
    if (!_isPaywallEnabled()) {
      _setState(isLoading: false, errorMessage: null, storeAvailable: false);
      return;
    }

    final inAppPurchase = _inAppPurchase;
    if (inAppPurchase == null) {
      _setState(
        isLoading: false,
        errorMessage: 'Compras no app indisponíveis neste dispositivo.',
        storeAvailable: false,
      );
      return;
    }

    _setState(isLoading: true, errorMessage: null);

    final available = _storeAvailable || await inAppPurchase.isAvailable();
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
      await inAppPurchase.restorePurchases();
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
    if (_disposed) return;
    if (_isIosPlatform() &&
        (!_initialStoreKitReconciliationComplete ||
            _drainingInitialPurchaseUpdates)) {
      _queuedInitialPurchaseUpdates.add(
        List<PurchaseDetails>.of(purchaseDetailsList),
      );
      return;
    }
    await _processPurchaseUpdates(purchaseDetailsList);
  }

  Future<void> _processPurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    if (_disposed) return;
    var shouldNotify = false;
    var nextLoading = _isLoading;
    String? nextError = _errorMessage;

    for (final purchaseDetails in purchaseDetailsList) {
      final callbackTransactionId = purchaseDetails.purchaseID;
      final transactionState = _isIosPlatform() &&
              productIds.contains(purchaseDetails.productID) &&
              _isValidTransactionId(callbackTransactionId)
          ? _observeStoreKitTransaction(
              callbackTransactionId!,
              _StoreKitTransactionSource.purchaseStream,
            )
          : null;
      final transactionDiagnostic = _storeKitTransactionDiagnostic(
        transactionState,
      );
      final contextPresent = _activePurchaseAttemptsByProductId.containsKey(
        purchaseDetails.productID,
      );
      _logPurchaseFlow(
        'callback transaction=$transactionDiagnostic '
        'status=${_purchaseFlowStatus(purchaseDetails.status)} '
        'plan=${_purchaseFlowPlan(purchaseDetails.productID)} '
        'purchase_id_present=${_hasPurchaseId(purchaseDetails)} '
        'pending_complete=${purchaseDetails.pendingCompletePurchase} '
        'context_present=$contextPresent '
        'error_code=${purchaseDetails.status == PurchaseStatus.error ? 'store_error' : 'none'}',
      );
      if (!productIds.contains(purchaseDetails.productID)) continue;
      if (purchaseDetails.status == PurchaseStatus.purchased &&
          (_uncertainCompletionProductIds.contains(purchaseDetails.productID) ||
              (_isValidTransactionId(callbackTransactionId) &&
                  _uncertainCompletionTransactionIds.contains(
                    callbackTransactionId,
                  )))) {
        _logPurchaseFlow(
          'callback_coalesced transaction=$transactionDiagnostic '
          'reason=completion_uncertain',
        );
        nextLoading = false;
        nextError = null;
        shouldNotify = true;
        continue;
      }
      var completionHandled = false;
      var completionUncertain = false;
      var analyticsResult = 'not_applicable';
      var analyticsResultLogged = false;
      var completePurchaseResultLogged = false;
      var contextConsumed = false;

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          nextLoading = true;
          nextError = null;
          shouldNotify = true;
          break;
        case PurchaseStatus.purchased:
          final transactionId = purchaseDetails.purchaseID;
          if (_isIosPlatform() && _isValidTransactionId(transactionId)) {
            _PurchaseCompletionResolution? completionResolution;
            try {
              final terminalResult = await _coordinateTransactionTerminal(
                transactionState!,
                () async {
                  await _setPremiumActive(true, notify: false);
                  final analytics = await _coordinateTransactionAnalytics(
                    transactionState,
                    () => _recordAppleTransactionId(transactionId!),
                  );
                  _logPurchaseFlow(
                    'analytics_result transaction=$transactionDiagnostic '
                    'result=${analytics.coalesced ? 'coalesced' : analytics.value ? 'success' : 'failure'}',
                  );
                  analyticsResultLogged = true;
                  if (purchaseDetails.pendingCompletePurchase) {
                    final finish = await _coordinateTransactionFinish(
                      transactionState,
                      () async {
                        final resolution =
                            await _completePurchaseWithDiagnostics(
                          purchaseDetails,
                        );
                        return _TransactionFinishOutcome.fromCompletion(
                          resolution,
                        );
                      },
                    );
                    if (finish.coalesced) {
                      _logPurchaseFlow(
                        'complete_purchase_result '
                        'transaction=$transactionDiagnostic result=coalesced',
                      );
                    }
                    completionResolution = finish.value.completionResolution;
                  } else {
                    _logPurchaseFlow(
                      'complete_purchase_result '
                      'transaction=$transactionDiagnostic '
                      'result=not_applicable',
                    );
                    completionResolution =
                        _PurchaseCompletionResolution.notApplicable;
                  }
                  completePurchaseResultLogged = true;
                  if (completionResolution?.isUncertain ?? false) {
                    throw _PurchaseCompletionUncertainException(
                      completionResolution!,
                    );
                  }
                  contextConsumed =
                      _consumePurchaseAttempt(purchaseDetails.productID) !=
                          null;
                },
              );
              if (terminalResult.coalesced) {
                _logPurchaseFlow(
                  'callback_coalesced transaction=$transactionDiagnostic '
                  'reason=terminal',
                );
                nextLoading = false;
                nextError = null;
                shouldNotify = true;
                continue;
              }
            } on _PurchaseCompletionUncertainException catch (error) {
              completionResolution = error.resolution;
              completePurchaseResultLogged = true;
            }
            if (completionResolution?.isUncertain ?? false) {
              completionUncertain = true;
            } else {
              completionHandled = true;
            }
          } else {
            await _setPremiumActive(true, notify: false);
            await _recordAppleTransaction(purchaseDetails);
            if (purchaseDetails.pendingCompletePurchase) {
              final completionResolution =
                  await _completePurchaseWithDiagnostics(purchaseDetails);
              completionUncertain = completionResolution.isUncertain;
            } else {
              _logPurchaseFlow(
                'complete_purchase_result result=not_applicable',
              );
            }
            completePurchaseResultLogged = true;
            completionHandled = true;
          }
          if (completionUncertain) {
            _markCompletionUncertain(purchaseDetails);
            nextLoading = false;
            nextError = null;
            shouldNotify = true;
            break;
          }
          if (!_isIosPlatform() || !_isValidTransactionId(transactionId)) {
            contextConsumed =
                _consumePurchaseAttempt(purchaseDetails.productID) != null;
          }
          nextLoading = false;
          nextError = null;
          shouldNotify = true;
          break;
        case PurchaseStatus.restored:
          if (transactionState != null) {
            _PurchaseCompletionResolution? completionResolution;
            final terminalResult = await _coordinateTransactionTerminal(
              transactionState,
              () async {
                await _setPremiumActive(true, notify: false);
                try {
                  await AppAnalytics.logPurchaseRestored(
                    source: _lastRestoreSource,
                  );
                  analyticsResult = 'success';
                } catch (_) {
                  _logPurchaseFlow(
                    'analytics_result transaction=$transactionDiagnostic '
                    'result=failure',
                  );
                  rethrow;
                }
                if (purchaseDetails.pendingCompletePurchase) {
                  final finish = await _coordinateTransactionFinish(
                    transactionState,
                    () async {
                      final resolution = await _completePurchaseWithDiagnostics(
                        purchaseDetails,
                      );
                      return _TransactionFinishOutcome.fromCompletion(
                        resolution,
                      );
                    },
                  );
                  if (finish.coalesced) {
                    _logPurchaseFlow(
                      'complete_purchase_result '
                      'transaction=$transactionDiagnostic result=coalesced',
                    );
                  }
                  completionResolution = finish.value.completionResolution;
                }
              },
            );
            if (terminalResult.coalesced) {
              _logPurchaseFlow(
                'callback_coalesced transaction=$transactionDiagnostic '
                'reason=terminal',
              );
              nextLoading = false;
              nextError = null;
              shouldNotify = true;
              continue;
            }
            if (completionResolution?.isUncertain ?? false) {
              _markCompletionUncertain(purchaseDetails);
              nextLoading = false;
              nextError = null;
              shouldNotify = true;
              continue;
            }
            completionHandled = purchaseDetails.pendingCompletePurchase;
            analyticsResultLogged = true;
            completePurchaseResultLogged =
                purchaseDetails.pendingCompletePurchase;
          } else {
            await _setPremiumActive(true, notify: false);
            try {
              await AppAnalytics.logPurchaseRestored(
                source: _lastRestoreSource,
              );
              analyticsResult = 'success';
            } catch (_) {
              _logPurchaseFlow(
                'analytics_result transaction=$transactionDiagnostic '
                'result=failure',
              );
              rethrow;
            }
          }
          nextLoading = false;
          nextError = null;
          shouldNotify = true;
          break;
        case PurchaseStatus.error:
          Future<void> processError() async {
            final attempt = _consumePurchaseAttempt(purchaseDetails.productID);
            contextConsumed = attempt != null;
            if (attempt != null) {
              final analyticsSucceeded = await _logPurchaseFailed(
                context: attempt,
                failureStage: PurchaseFailureStage.purchaseStream,
                failureCode: PurchaseFailureCode.storeError,
              );
              analyticsResult = analyticsSucceeded ? 'success' : 'failure';
            }
          }

          if (transactionState != null) {
            final terminalResult = await _coordinateTransactionTerminal(
              transactionState,
              processError,
            );
            if (terminalResult.coalesced) {
              _logPurchaseFlow(
                'callback_coalesced transaction=$transactionDiagnostic '
                'reason=terminal',
              );
              nextLoading = false;
              shouldNotify = true;
              continue;
            }
          } else {
            await processError();
          }
          nextLoading = false;
          nextError = purchaseDetails.error?.message ??
              'Não foi possível concluir a compra.';
          shouldNotify = true;
          break;
        case PurchaseStatus.canceled:
          Future<void> processCancellation() async {
            final attempt = _consumePurchaseAttempt(purchaseDetails.productID);
            contextConsumed = attempt != null;
            if (attempt != null) {
              final analyticsSucceeded = await _runAnalyticsSafely(
                () => _purchaseFunnelAnalytics.logPurchaseCanceled(attempt),
              );
              analyticsResult = analyticsSucceeded ? 'success' : 'failure';
            }
          }

          if (transactionState != null) {
            final terminalResult = await _coordinateTransactionTerminal(
              transactionState,
              processCancellation,
            );
            if (terminalResult.coalesced) {
              _logPurchaseFlow(
                'callback_coalesced transaction=$transactionDiagnostic '
                'reason=terminal',
              );
              nextLoading = false;
              nextError = 'Compra cancelada.';
              shouldNotify = true;
              continue;
            }
          } else {
            await processCancellation();
          }
          nextLoading = false;
          nextError = 'Compra cancelada.';
          shouldNotify = true;
          break;
      }

      if (completionUncertain) {
        continue;
      }

      if (!analyticsResultLogged) {
        _logPurchaseFlow(
          'analytics_result transaction=$transactionDiagnostic '
          'result=$analyticsResult',
        );
      }
      if (purchaseDetails.pendingCompletePurchase && !completionHandled) {
        final _PurchaseCompletionResolution? completionResolution;
        if (transactionState != null) {
          final finish = await _coordinateTransactionFinish(
            transactionState,
            () async {
              final resolution = await _completePurchaseWithDiagnostics(
                purchaseDetails,
              );
              return _TransactionFinishOutcome.fromCompletion(resolution);
            },
          );
          if (finish.coalesced) {
            _logPurchaseFlow(
              'complete_purchase_result transaction=$transactionDiagnostic '
              'result=coalesced',
            );
          }
          completionResolution = finish.value.completionResolution;
        } else {
          completionResolution = await _completePurchaseWithDiagnostics(
            purchaseDetails,
          );
        }
        completePurchaseResultLogged = true;
        if (completionResolution?.isUncertain ?? false) {
          _markCompletionUncertain(purchaseDetails);
          nextLoading = false;
          nextError = null;
          shouldNotify = true;
          continue;
        }
      }
      if (!completePurchaseResultLogged) {
        _logPurchaseFlow(
          'complete_purchase_result transaction=$transactionDiagnostic '
          'result=not_applicable',
        );
      }
      _logPurchaseFlow(
        'terminal_result transaction=$transactionDiagnostic '
        'status=${_purchaseFlowStatus(purchaseDetails.status)} '
        'premium=${_isPremium ? 'active' : 'inactive'} '
        'context_consumed=$contextConsumed',
      );
    }

    if (shouldNotify) {
      _isLoading = nextLoading;
      _errorMessage = nextError;
      notifyListeners();
    }
  }

  Future<void> _handlePurchaseStreamFailure() async {
    final attempts = _activePurchaseAttemptsByProductId.values.toList(
      growable: false,
    );
    _activePurchaseAttemptsByProductId.clear();
    for (final attempt in attempts) {
      await _logPurchaseFailed(
        context: attempt,
        failureStage: PurchaseFailureStage.purchaseStream,
        failureCode: PurchaseFailureCode.storeError,
      );
    }
  }

  Future<bool> _logPurchaseFailed({
    required PurchaseAttemptContext context,
    required PurchaseFailureStage failureStage,
    required PurchaseFailureCode failureCode,
  }) {
    return _runAnalyticsSafely(
      () => _purchaseFunnelAnalytics.logPurchaseFailed(
        context: context,
        failureStage: failureStage,
        failureCode: failureCode,
      ),
    );
  }

  Future<bool> _runAnalyticsSafely(Future<void> Function() operation) async {
    try {
      await operation();
      return true;
    } catch (_) {
      debugPrint('Purchase funnel Analytics skipped.');
      return false;
    }
  }

  Future<_PurchaseCompletionResolution> _completePurchaseWithDiagnostics(
    PurchaseDetails purchaseDetails,
  ) async {
    final transactionDiagnostic = _purchaseDetailsTransactionDiagnostic(
      purchaseDetails,
    );
    final completePurchase = _completePurchase;
    if (completePurchase == null) {
      _logPurchaseFlow(
        'complete_purchase_result transaction=$transactionDiagnostic '
        'result=not_applicable',
      );
      return _PurchaseCompletionResolution.notApplicable;
    }

    try {
      final completion = completePurchase(purchaseDetails);
      if (_isIosPlatform()) {
        await completion.timeout(
          _completePurchaseTimeout,
          onTimeout: () => throw const _CompletePurchaseTimeoutException(),
        );
      } else {
        await completion;
      }
      _logPurchaseFlow(
        'complete_purchase_result transaction=$transactionDiagnostic '
        'result=success',
      );
      return _PurchaseCompletionResolution.success;
    } on _CompletePurchaseTimeoutException {
      _logPurchaseFlow(
        'complete_purchase_result transaction=$transactionDiagnostic '
        'result=timeout',
      );
      final resolution = await _resolveTimedOutPurchase(purchaseDetails);
      _logPurchaseFlow(
        'complete_purchase_result transaction=$transactionDiagnostic '
        'result=${resolution.diagnosticValue}',
      );
      return resolution;
    } catch (_) {
      _logPurchaseFlow(
        'complete_purchase_result transaction=$transactionDiagnostic '
        'result=failure',
      );
      rethrow;
    }
  }

  Future<_PurchaseCompletionResolution> _resolveTimedOutPurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    final transactionId = purchaseDetails.purchaseID;
    final client = _storeKitReconciliationClient;
    if (!_isIosPlatform() ||
        client == null ||
        !_isValidTransactionId(transactionId) ||
        !productIds.contains(purchaseDetails.productID)) {
      return _PurchaseCompletionResolution.timeoutInconclusive;
    }
    _observeStoreKitTransaction(
      transactionId!,
      _StoreKitTransactionSource.timeoutRecovery,
    );

    try {
      final snapshot = await client.loadSnapshot();
      if (snapshot.status != StoreKitReconciliationStatus.success) {
        return _PurchaseCompletionResolution.timeoutInconclusive;
      }
      if (snapshot.unfinished.any(
        (transaction) => transaction.transactionId == transactionId,
      )) {
        return _PurchaseCompletionResolution.timeoutUnfinished;
      }
      final entitlementConfirmed = snapshot.currentEntitlements.any(
        (transaction) =>
            transaction.transactionId == transactionId &&
            transaction.productId == purchaseDetails.productID &&
            productIds.contains(transaction.productId) &&
            transaction.verified &&
            transaction.active &&
            !transaction.expired &&
            !transaction.revoked,
      );
      return entitlementConfirmed
          ? _PurchaseCompletionResolution.confirmedBySnapshot
          : _PurchaseCompletionResolution.timeoutInconclusive;
    } catch (_) {
      return _PurchaseCompletionResolution.timeoutInconclusive;
    }
  }

  void _markCompletionUncertain(PurchaseDetails purchaseDetails) {
    _uncertainCompletionProductIds.add(purchaseDetails.productID);
    final transactionId = purchaseDetails.purchaseID;
    if (_isValidTransactionId(transactionId)) {
      _uncertainCompletionTransactionIds.add(transactionId!);
    }
  }

  PurchaseAttemptContext? _consumePurchaseAttempt(
    String productId, {
    PurchaseAttemptContext? expected,
  }) {
    final current = _activePurchaseAttemptsByProductId[productId];
    if (current == null ||
        (expected != null && !identical(current, expected))) {
      return null;
    }
    _activePurchaseAttemptsByProductId.remove(productId);
    return current;
  }

  Future<void> _recordAppleTransaction(PurchaseDetails purchaseDetails) async {
    if (!_isIosPlatform()) return;

    final transactionId = purchaseDetails.purchaseID;
    if (!_isValidTransactionId(transactionId)) return;

    await _recordAppleTransactionId(transactionId!);
  }

  Future<bool> _recordAppleTransactionId(String transactionId) async {
    try {
      await _appleTransactionAnalyticsCoordinator.recordNewPurchase(
        transactionId,
      );
      return true;
    } catch (_) {
      debugPrint('Apple transaction Analytics remains pending.');
      return false;
    }
  }

  Future<void> _reconcileStoreKitSubscription() {
    final operation = _storeKitReconciliationTail.then(
      (_) => _performStoreKitReconciliation(),
    );
    _storeKitReconciliationTail = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return operation;
  }

  Future<void> _performStoreKitReconciliation() async {
    final client = _storeKitReconciliationClient;
    if (!_isIosPlatform() || client == null) return;

    _logStoreKitReconciliation('startup_begin');
    final snapshot = await client.loadSnapshot();
    if (snapshot.status != StoreKitReconciliationStatus.success) {
      final malformed =
          snapshot.status == StoreKitReconciliationStatus.malformed;
      final failureCode = switch (snapshot.status) {
        StoreKitReconciliationStatus.unavailable => 'unavailable',
        StoreKitReconciliationStatus.malformed => 'malformed_snapshot',
        _ => 'platform_error',
      };
      _logStoreKitReconciliation('snapshot_failure code=$failureCode');
      _logStoreKitReconciliation(
        'premium_decision result=preserved '
        'reason=${malformed ? 'malformed_snapshot' : 'snapshot_failure'}',
      );
      _logStoreKitReconciliation(
        'startup_end processed=0 deduplicated=0 finished=0 '
        'finish_failed=0',
      );
      return;
    }

    _logStoreKitReconciliation(
      'snapshot_success unfinished_count=${snapshot.unfinished.length} '
      'current_entitlement_count=${snapshot.currentEntitlements.length}',
    );
    final activeEntitlements = snapshot.currentEntitlements
        .where(_isActiveKnownStoreKitTransaction)
        .toList(growable: false);
    final candidates = <String, _StoreKitReconciliationCandidate>{};
    var deduplicatedCount = 0;

    for (final transaction in activeEntitlements) {
      candidates[transaction.transactionId] = _StoreKitReconciliationCandidate(
        transaction: transaction,
        shouldFinish: false,
        fromUnfinished: false,
        fromCurrentEntitlement: true,
      );
    }
    for (final transaction in snapshot.unfinished) {
      if (!_isKnownVerifiedStoreKitTransaction(transaction)) continue;
      final existing = candidates[transaction.transactionId];
      final deduplicated = existing != null &&
          existing.fromCurrentEntitlement &&
          !existing.fromUnfinished;
      if (deduplicated) deduplicatedCount++;
      candidates[transaction.transactionId] = _StoreKitReconciliationCandidate(
        transaction: transaction,
        shouldFinish: true,
        fromUnfinished: true,
        fromCurrentEntitlement: existing?.fromCurrentEntitlement ?? false,
      );
    }

    var processedCount = 0;
    var finishedCount = 0;
    var finishFailedCount = 0;
    for (final candidate in candidates.values) {
      processedCount++;
      final transactionState = _observeStoreKitTransaction(
        candidate.transaction.transactionId,
        candidate.fromUnfinished
            ? _StoreKitTransactionSource.unfinished
            : _StoreKitTransactionSource.currentEntitlement,
      );
      if (candidate.fromCurrentEntitlement) {
        transactionState.sources.add(
          _StoreKitTransactionSource.currentEntitlement,
        );
      }
      final transactionDiagnostic = _storeKitTransactionDiagnostic(
        transactionState,
      );
      final ledgerBefore = _storeKitDiagnosticsEnabled
          ? await _appleTransactionAnalyticsCoordinator.stateForTransaction(
              candidate.transaction.transactionId,
            )
          : null;
      _logStoreKitReconciliation(
        'transaction=$transactionDiagnostic source=${candidate.source} '
        'plan=${_storeKitDiagnosticPlan(candidate.transaction.productId)} '
        'verified=${candidate.transaction.verified} '
        'active=${candidate.transaction.active} '
        'revoked=${candidate.transaction.revoked} '
        'expired=${candidate.transaction.expired} '
        'ledger_before=${_storeKitLedgerState(ledgerBefore)} '
        'deduplicated=${candidate.deduplicated}',
      );
      final analytics = await _coordinateTransactionAnalytics(
        transactionState,
        () => _recordAppleTransactionId(candidate.transaction.transactionId),
      );
      final ledgerAfter = _storeKitDiagnosticsEnabled
          ? await _appleTransactionAnalyticsCoordinator.stateForTransaction(
              candidate.transaction.transactionId,
            )
          : null;
      _logStoreKitReconciliation(
        'analytics_result transaction=$transactionDiagnostic '
        'result=${analytics.coalesced ? 'coalesced' : _storeKitAnalyticsResult(ledgerBefore, ledgerAfter)}',
      );

      if (!candidate.shouldFinish) {
        _logStoreKitReconciliation(
          'finish_result transaction=$transactionDiagnostic '
          'result=not_required_current_entitlement',
        );
        continue;
      }

      final finish = await _coordinateTransactionFinish(
        transactionState,
        () async {
          final status = await client.finish(candidate.transaction);
          return switch (status) {
            StoreKitFinishStatus.finished =>
              const _TransactionFinishOutcome.success(),
            StoreKitFinishStatus.alreadyFinished =>
              const _TransactionFinishOutcome.alreadyFinished(),
            StoreKitFinishStatus.rejected ||
            StoreKitFinishStatus.unavailable ||
            StoreKitFinishStatus.failed =>
              const _TransactionFinishOutcome.failure(),
          };
        },
      );
      if (finish.coalesced) {
        _logStoreKitReconciliation(
          'finish_result transaction=$transactionDiagnostic result=coalesced',
        );
        continue;
      }
      switch (finish.value.result) {
        case _TransactionFinishResult.success:
          finishedCount++;
          _logStoreKitReconciliation(
            'finish_result transaction=$transactionDiagnostic result=success',
          );
          break;
        case _TransactionFinishResult.alreadyFinished:
          _logStoreKitReconciliation(
            'finish_result transaction=$transactionDiagnostic '
            'result=already_finished',
          );
          break;
        case _TransactionFinishResult.failure:
          finishFailedCount++;
          _logStoreKitReconciliation(
            'finish_result transaction=$transactionDiagnostic result=failure',
          );
      }
    }

    final premiumActive = activeEntitlements.isNotEmpty;
    final containsUnknownProduct = <StoreKitReconciliationTransaction>[
      ...snapshot.unfinished,
      ...snapshot.currentEntitlements,
    ].any((transaction) => !productIds.contains(transaction.productId));
    await _synchronizePremium(premiumActive);
    _logStoreKitReconciliation(
      'premium_decision result=${premiumActive ? 'active' : 'inactive'} '
      'reason=${premiumActive ? 'active_entitlement' : containsUnknownProduct ? 'unknown_product' : 'conclusive_empty_snapshot'}',
    );
    _logStoreKitReconciliation(
      'startup_end processed=$processedCount '
      'deduplicated=$deduplicatedCount finished=$finishedCount '
      'finish_failed=$finishFailedCount',
    );
  }

  void _logStoreKitReconciliation(String message) {
    if (!_storeKitDiagnosticsEnabled) return;
    _storeKitDiagnosticsLogger('[StoreKitReconciliation] $message');
  }

  void _logPurchaseFlow(String message) {
    if (!_storeKitDiagnosticsEnabled || !_isIosPlatform()) return;
    try {
      _storeKitDiagnosticsLogger('[PurchaseFlow] $message');
    } catch (_) {
      // Diagnostics must never alter purchase behavior.
    }
  }

  String _purchaseFlowPlan(String productId) {
    return switch (productId) {
      monthlyProductId => 'monthly',
      yearlyProductId => 'yearly',
      _ => 'unknown',
    };
  }

  String _purchaseFlowStatus(PurchaseStatus status) {
    return switch (status) {
      PurchaseStatus.pending => 'pending',
      PurchaseStatus.purchased => 'purchased',
      PurchaseStatus.restored => 'restored',
      PurchaseStatus.error => 'error',
      PurchaseStatus.canceled => 'canceled',
    };
  }

  bool _hasPurchaseId(PurchaseDetails purchaseDetails) {
    return purchaseDetails.purchaseID?.trim().isNotEmpty ?? false;
  }

  String _storeKitDiagnosticPlan(String productId) {
    return switch (productId) {
      monthlyProductId => 'monthly',
      yearlyProductId => 'yearly',
      _ => 'unknown',
    };
  }

  String _storeKitLedgerState(AppleTransactionAnalyticsState? state) {
    return switch (state) {
      AppleTransactionAnalyticsState.pending => 'pending',
      AppleTransactionAnalyticsState.sent => 'sent',
      null => 'absent',
    };
  }

  String _storeKitAnalyticsResult(
    AppleTransactionAnalyticsState? before,
    AppleTransactionAnalyticsState? after,
  ) {
    if (before == AppleTransactionAnalyticsState.sent) {
      return 'skipped_already_sent';
    }
    return after == AppleTransactionAnalyticsState.sent ? 'sent' : 'pending';
  }

  bool _isActiveKnownStoreKitTransaction(
    StoreKitReconciliationTransaction transaction,
  ) {
    return _isKnownVerifiedStoreKitTransaction(transaction) &&
        transaction.active &&
        !transaction.revoked &&
        !transaction.expired;
  }

  bool _isKnownVerifiedStoreKitTransaction(
    StoreKitReconciliationTransaction transaction,
  ) {
    return transaction.verified &&
        productIds.contains(transaction.productId) &&
        _isValidTransactionId(transaction.transactionId);
  }

  bool _isValidTransactionId(String? transactionId) {
    if (transactionId == null || transactionId.isEmpty) return false;
    final parsed = int.tryParse(transactionId);
    return parsed != null && parsed > 0;
  }

  _StoreKitTransactionSessionState _observeStoreKitTransaction(
    String transactionId,
    _StoreKitTransactionSource source,
  ) {
    final state = _storeKitTransactionsById.putIfAbsent(
      transactionId,
      () => _StoreKitTransactionSessionState(
        ordinal: _storeKitDiagnosticsEnabled && _isIosPlatform()
            ? ++_nextStoreKitTransactionOrdinal
            : null,
      ),
    );
    state.sources.add(source);
    return state;
  }

  String _storeKitTransactionDiagnostic(
    _StoreKitTransactionSessionState? state,
  ) {
    return state?.ordinal?.toString() ?? 'none';
  }

  String _purchaseDetailsTransactionDiagnostic(
    PurchaseDetails purchaseDetails,
  ) {
    final transactionId = purchaseDetails.purchaseID;
    if (!_isValidTransactionId(transactionId)) return 'none';
    return _storeKitTransactionDiagnostic(
      _storeKitTransactionsById[transactionId],
    );
  }

  Future<_CoordinatedResult<bool>> _coordinateTransactionAnalytics(
    _StoreKitTransactionSessionState state,
    Future<bool> Function() operation,
  ) async {
    final existing = state.analyticsOperation;
    if (existing != null) {
      return _CoordinatedResult<bool>(value: await existing, coalesced: true);
    }

    final processing = Future<bool>.sync(operation).whenComplete(() {
      state.analyticsCompleted = true;
    });
    state.analyticsOperation = processing;
    return _CoordinatedResult<bool>(value: await processing, coalesced: false);
  }

  Future<_CoordinatedResult<_TransactionFinishOutcome>>
      _coordinateTransactionFinish(
    _StoreKitTransactionSessionState state,
    Future<_TransactionFinishOutcome> Function() operation,
  ) async {
    final existing = state.finishOperation;
    if (existing != null) {
      return _CoordinatedResult<_TransactionFinishOutcome>(
        value: await existing,
        coalesced: true,
      );
    }

    final processing =
        Future<_TransactionFinishOutcome>.sync(operation).whenComplete(() {
      state.finishCompleted = true;
    });
    state.finishOperation = processing;
    return _CoordinatedResult<_TransactionFinishOutcome>(
      value: await processing,
      coalesced: false,
    );
  }

  Future<_CoordinatedResult<void>> _coordinateTransactionTerminal(
    _StoreKitTransactionSessionState state,
    Future<void> Function() operation,
  ) async {
    final existing = state.terminalOperation;
    if (existing != null) {
      await existing;
      return const _CoordinatedResult<void>(value: null, coalesced: true);
    }

    final processing = Future<void>.sync(operation).whenComplete(() {
      state.terminalCompleted = true;
    });
    state.terminalOperation = processing;
    await processing;
    return const _CoordinatedResult<void>(value: null, coalesced: false);
  }

  Future<void> _synchronizePremium(bool value) async {
    if (_isPremium == value) return;
    await _setPremiumActive(value);
  }

  @visibleForTesting
  Future<void> reconcileStoreKitForTesting() {
    return _reconcileStoreKitSubscription();
  }

  @visibleForTesting
  Future<void> runInitialStoreKitReconciliationForTesting() {
    return _runInitialStoreKitReconciliation();
  }

  @visibleForTesting
  Future<void> handlePurchaseUpdatesForTesting(
    List<PurchaseDetails> purchaseDetailsList,
  ) {
    return _handlePurchaseUpdates(purchaseDetailsList);
  }

  @visibleForTesting
  Future<void> handlePurchaseStreamFailureForTesting() {
    return _handlePurchaseStreamFailure();
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
    _disposed = true;
    _queuedInitialPurchaseUpdates.clear();
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}

class _StoreKitReconciliationCandidate {
  const _StoreKitReconciliationCandidate({
    required this.transaction,
    required this.shouldFinish,
    required this.fromUnfinished,
    required this.fromCurrentEntitlement,
  });

  final StoreKitReconciliationTransaction transaction;
  final bool shouldFinish;
  final bool fromUnfinished;
  final bool fromCurrentEntitlement;

  bool get deduplicated => fromUnfinished && fromCurrentEntitlement;

  String get source {
    if (deduplicated) return 'unfinished,current_entitlement';
    return fromUnfinished ? 'unfinished' : 'current_entitlement';
  }
}

enum _StoreKitTransactionSource {
  unfinished,
  currentEntitlement,
  purchaseStream,
  timeoutRecovery,
}

class _StoreKitTransactionSessionState {
  _StoreKitTransactionSessionState({required this.ordinal});

  final int? ordinal;
  final Set<_StoreKitTransactionSource> sources =
      <_StoreKitTransactionSource>{};
  Future<bool>? analyticsOperation;
  Future<_TransactionFinishOutcome>? finishOperation;
  Future<void>? terminalOperation;
  bool analyticsCompleted = false;
  bool finishCompleted = false;
  bool terminalCompleted = false;
}

class _CoordinatedResult<T> {
  const _CoordinatedResult({required this.value, required this.coalesced});

  final T value;
  final bool coalesced;
}

enum _TransactionFinishResult { success, alreadyFinished, failure }

class _TransactionFinishOutcome {
  const _TransactionFinishOutcome.success({this.completionResolution})
      : result = _TransactionFinishResult.success;

  const _TransactionFinishOutcome.alreadyFinished()
      : result = _TransactionFinishResult.alreadyFinished,
        completionResolution = null;

  const _TransactionFinishOutcome.failure()
      : result = _TransactionFinishResult.failure,
        completionResolution = null;

  factory _TransactionFinishOutcome.fromCompletion(
    _PurchaseCompletionResolution resolution,
  ) {
    return _TransactionFinishOutcome.success(completionResolution: resolution);
  }

  final _TransactionFinishResult result;
  final _PurchaseCompletionResolution? completionResolution;
}

enum _PurchaseCompletionResolution {
  success('success', isUncertain: false),
  notApplicable('not_applicable', isUncertain: false),
  confirmedBySnapshot('confirmed_by_snapshot', isUncertain: false),
  timeoutUnfinished('timeout_unfinished', isUncertain: true),
  timeoutInconclusive('timeout_inconclusive', isUncertain: true);

  const _PurchaseCompletionResolution(
    this.diagnosticValue, {
    required this.isUncertain,
  });

  final String diagnosticValue;
  final bool isUncertain;
}

class _CompletePurchaseTimeoutException implements Exception {
  const _CompletePurchaseTimeoutException();
}

class _PurchaseCompletionUncertainException implements Exception {
  const _PurchaseCompletionUncertainException(this.resolution);

  final _PurchaseCompletionResolution resolution;
}
