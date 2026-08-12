import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/apple_transaction_analytics_coordinator.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/paywall_analytics_context.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('canceled sem ID consome contexto sem ativar Premium ou ledger',
      () async {
    final logs = <String>[];
    final coordinator = _coordinator();
    final service = await _service(logs: logs, coordinator: coordinator);

    await _startYearly(service);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(status: PurchaseStatus.canceled, purchaseId: null),
    ]);

    expect(
      logs,
      contains(
        _log(
          'callback transaction=none status=canceled plan=yearly '
          'purchase_id_present=false pending_complete=false '
          'context_present=true error_code=none',
        ),
      ),
    );
    expect(
      logs,
      contains(_log('analytics_result transaction=none result=success')),
    );
    expect(
      logs,
      contains(
        _log(
          'complete_purchase_result transaction=none result=not_applicable',
        ),
      ),
    );
    expect(
      logs,
      contains(
        _log(
          'terminal_result transaction=none status=canceled premium=inactive '
          'context_consumed=true',
        ),
      ),
    );
    expect(service.isPremium, isFalse);
    expect(await coordinator.readStoredCount(), 0);
  });

  test('pending registra pendingCompletePurchase falso e verdadeiro', () async {
    final logs = <String>[];
    var completeCount = 0;
    final service = await _service(
      logs: logs,
      completePurchase: (_) async => completeCount++,
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(
        status: PurchaseStatus.pending,
        purchaseId: null,
        pendingCompletePurchase: false,
      ),
      _purchase(
        status: PurchaseStatus.pending,
        purchaseId: null,
        pendingCompletePurchase: true,
      ),
    ]);

    expect(
      logs,
      contains(
        _log(
          'callback transaction=none status=pending plan=yearly '
          'purchase_id_present=false pending_complete=false '
          'context_present=false error_code=none',
        ),
      ),
    );
    expect(
      logs,
      contains(
        _log(
          'callback transaction=none status=pending plan=yearly '
          'purchase_id_present=false pending_complete=true '
          'context_present=false error_code=none',
        ),
      ),
    );
    expect(completeCount, 1);
    expect(
      logs.where(
        (line) =>
            line ==
            _log(
              'complete_purchase_result transaction=none result=success',
            ),
      ),
      hasLength(1),
    );
  });

  test('purchased registra presença do ID e Analytics antes de conclusão',
      () async {
    final logs = <String>[];
    final order = <String>[];
    final coordinator = _coordinator(
      sendTransaction: (_) async => order.add('analytics'),
    );
    final service = await _service(
      logs: logs,
      coordinator: coordinator,
      completePurchase: (_) async => order.add('complete'),
    );

    await _startYearly(service);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(
        status: PurchaseStatus.purchased,
        purchaseId: '9000000000000101',
        pendingCompletePurchase: true,
      ),
    ]);

    expect(order, <String>['analytics', 'complete']);
    expect(
      logs,
      contains(
        _log(
          'callback transaction=1 status=purchased plan=yearly '
          'purchase_id_present=true pending_complete=true '
          'context_present=true error_code=none',
        ),
      ),
    );
    final analyticsIndex =
        logs.indexOf(_log('analytics_result transaction=1 result=success'));
    final completeIndex = logs.indexOf(
      _log('complete_purchase_result transaction=1 result=success'),
    );
    expect(analyticsIndex, greaterThanOrEqualTo(0));
    expect(analyticsIndex, lessThan(completeIndex));
    expect(
      logs,
      contains(
        _log(
          'terminal_result transaction=1 status=purchased premium=active '
          'context_consumed=true',
        ),
      ),
    );
  });

  test('restored é observado sem inventar contexto ou identificadores',
      () async {
    final logs = <String>[];
    final service = await _service(logs: logs);

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(status: PurchaseStatus.restored, purchaseId: null),
    ]);

    expect(
      logs,
      contains(
        _log(
          'callback transaction=none status=restored plan=yearly '
          'purchase_id_present=false pending_complete=false '
          'context_present=false error_code=none',
        ),
      ),
    );
    expect(
      logs,
      contains(
        _log(
          'terminal_result transaction=none status=restored premium=active '
          'context_consumed=false',
        ),
      ),
    );
  });

  test('error usa código controlado e não vaza payloads sensíveis', () async {
    const secretPurchaseId = '9000000000000777';
    const secretMessage =
        'receipt JWS user@example.com transaction-secret full message';
    final logs = <String>[];
    final analytics = _FakePurchaseFunnelAnalytics(throwOnFailure: true);
    final service = await _service(logs: logs, analytics: analytics);

    await _startYearly(service);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(
        status: PurchaseStatus.error,
        purchaseId: secretPurchaseId,
        errorMessage: secretMessage,
        verificationData: 'receipt-token JWS-token user@example.com',
      ),
    ]);

    expect(
      logs,
      contains(
        _log(
          'callback transaction=1 status=error plan=yearly '
          'purchase_id_present=true '
          'pending_complete=false context_present=true '
          'error_code=store_error',
        ),
      ),
    );
    expect(
      logs,
      contains(_log('analytics_result transaction=1 result=failure')),
    );
    final joined = logs.join('\n');
    for (final forbidden in <String>[
      secretPurchaseId,
      secretMessage,
      'receipt-token',
      'JWS-token',
      'user@example.com',
      PurchaseService.yearlyProductId,
    ]) {
      expect(joined, isNot(contains(forbidden)));
    }
  });

  test('launcher false registra uma rejeição sem exceção', () async {
    final logs = <String>[];
    var launchCount = 0;
    final service = await _service(
      logs: logs,
      purchaseLauncher: (_) async {
        launchCount++;
        return false;
      },
    );

    await _startYearly(service);

    expect(launchCount, 1);
    expect(
      logs,
      contains(
        _log('launcher_begin plan=yearly context_present=true'),
      ),
    );
    expect(logs, contains(_log('launcher_result accepted=false')));
    expect(logs.where((line) => line.contains('launcher_exception')), isEmpty);
  });

  test('exceção do launcher emite somente código controlado', () async {
    const secret = 'card user@example.com receipt JWS full exception';
    final logs = <String>[];
    final service = await _service(
      logs: logs,
      purchaseLauncher: (_) async => throw StateError(secret),
    );

    await _startYearly(service);

    expect(logs, contains(_log('launcher_exception code=store_error')));
    expect(logs.join('\n'), isNot(contains(secret)));
    expect(logs.where((line) => line.contains('launcher_result')), isEmpty);
  });

  test('produção e Android permanecem silenciosos', () async {
    final productionLogs = <String>[];
    final production = await _service(
      logs: productionLogs,
      diagnosticsEnabled: false,
    );
    await _startYearly(production);
    await production.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(status: PurchaseStatus.canceled, purchaseId: null),
    ]);

    final androidLogs = <String>[];
    final android = await _service(
      logs: androidLogs,
      isIos: false,
      diagnosticsEnabled: true,
    );
    await _startYearly(android);
    await android.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(status: PurchaseStatus.canceled, purchaseId: null),
    ]);

    expect(productionLogs, isEmpty);
    expect(androidLogs, isEmpty);
  });

  test('uma tentativa concorrente gera um launcher e um callback terminal',
      () async {
    final logs = <String>[];
    final launcherResult = Completer<bool>();
    var launchCount = 0;
    final service = await _service(
      logs: logs,
      purchaseLauncher: (_) {
        launchCount++;
        return launcherResult.future;
      },
    );

    final first = _startYearly(service);
    final second = _startYearly(service);
    await Future<void>.delayed(Duration.zero);
    launcherResult.complete(true);
    await Future.wait(<Future<void>>[first, second]);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(status: PurchaseStatus.canceled, purchaseId: null),
    ]);

    expect(launchCount, 1);
    expect(_countContaining(logs, 'launcher_begin'), 1);
    expect(_countContaining(logs, 'launcher_result'), 1);
    expect(_countContaining(logs, 'callback transaction='), 1);
    expect(_countContaining(logs, 'terminal_result transaction='), 1);
  });
}

final PaywallAnalyticsContext _paywall = PaywallAnalyticsContext.create(
  source: PaywallSource.settings,
  idGenerator: () => 'paywall-observability',
);

Future<PurchaseService> _service({
  required List<String> logs,
  AppleTransactionAnalyticsCoordinator? coordinator,
  PurchaseFunnelAnalytics? analytics,
  Future<bool> Function(ProductDetails productDetails)? purchaseLauncher,
  Future<void> Function(PurchaseDetails purchaseDetails)? completePurchase,
  bool diagnosticsEnabled = true,
  bool isIos = true,
}) async {
  final preferences = await SharedPreferences.getInstance();
  return PurchaseService.forTesting(
    preferences: preferences,
    productDetailsById: <String, ProductDetails>{
      PurchaseService.yearlyProductId:
          _product(PurchaseService.yearlyProductId),
      PurchaseService.monthlyProductId:
          _product(PurchaseService.monthlyProductId),
    },
    appleTransactionAnalyticsCoordinator: coordinator ?? _coordinator(),
    isIosPlatform: isIos,
    purchaseLauncher: purchaseLauncher ?? (_) async => true,
    completePurchase: completePurchase,
    purchaseFunnelAnalytics: analytics ?? _FakePurchaseFunnelAnalytics(),
    analyticsIdGenerator: () => 'attempt-observability',
    storeKitDiagnosticsEnabled: diagnosticsEnabled,
    storeKitDiagnosticsLogger: logs.add,
  );
}

Future<void> _startYearly(PurchaseService service) {
  return service.startPurchase(
    productId: PurchaseService.yearlyProductId,
    paywallContext: _paywall,
  );
}

AppleTransactionAnalyticsCoordinator _coordinator({
  Future<void> Function(String transactionId)? sendTransaction,
}) {
  return AppleTransactionAnalyticsCoordinator(
    preferencesProvider: SharedPreferences.getInstance,
    isAnalyticsConfigured: () => true,
    sendTransaction: sendTransaction ?? (_) async {},
  );
}

ProductDetails _product(String id) {
  return ProductDetails(
    id: id,
    title: 'Annual plan',
    description: 'Annual plan',
    price: r'$19.99',
    rawPrice: 19.99,
    currencyCode: 'USD',
    currencySymbol: r'$',
  );
}

PurchaseDetails _purchase({
  required PurchaseStatus status,
  required String? purchaseId,
  bool pendingCompletePurchase = false,
  String errorMessage = 'controlled test error',
  String verificationData = '',
}) {
  final purchase = PurchaseDetails(
    purchaseID: purchaseId,
    productID: PurchaseService.yearlyProductId,
    verificationData: PurchaseVerificationData(
      localVerificationData: verificationData,
      serverVerificationData: verificationData,
      source: 'test',
    ),
    transactionDate: null,
    status: status,
  );
  purchase.pendingCompletePurchase = pendingCompletePurchase;
  if (status == PurchaseStatus.error) {
    purchase.error = IAPError(
      source: 'test',
      code: 'sensitive-provider-code',
      message: errorMessage,
    );
  }
  return purchase;
}

String _log(String message) => '[PurchaseFlow] $message';

int _countContaining(List<String> logs, String fragment) {
  return logs.where((line) => line.contains(fragment)).length;
}

class _FakePurchaseFunnelAnalytics implements PurchaseFunnelAnalytics {
  _FakePurchaseFunnelAnalytics({this.throwOnFailure = false});

  final bool throwOnFailure;

  @override
  Future<void> logPaywallViewed(PaywallAnalyticsContext context) async {}

  @override
  Future<void> logPremiumPlanSelected({
    required PaywallAnalyticsContext context,
    required PremiumPlan plan,
    required String productId,
    required PlanSelectionMethod selectionMethod,
  }) async {}

  @override
  Future<void> logPurchaseStarted(PurchaseAttemptContext context) async {}

  @override
  Future<void> logPurchaseCanceled(PurchaseAttemptContext context) async {}

  @override
  Future<void> logPurchaseFailed({
    required PurchaseAttemptContext context,
    required PurchaseFailureStage failureStage,
    required PurchaseFailureCode failureCode,
  }) async {
    if (throwOnFailure) {
      throw StateError('private receipt JWS user@example.com');
    }
  }
}
