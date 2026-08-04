import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/apple_transaction_analytics_coordinator.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/paywall_analytics_context.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/services/storekit_reconciliation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('unfinished e entitlement ativo processam uma vez antes de finish',
      () async {
    final transaction = _transaction(1);
    final order = <String>[];
    final analytics = _TrackingPurchaseFunnelAnalytics();
    final coordinator = _coordinator((_) async => order.add('analytics'));
    final client = _FakeStoreKitReconciliationClient(
      snapshot: StoreKitReconciliationSnapshot.success(
        unfinished: <StoreKitReconciliationTransaction>[transaction],
        currentEntitlements: <StoreKitReconciliationTransaction>[transaction],
      ),
      onFinish: (_) async {
        order.add('finish');
        return StoreKitFinishStatus.finished;
      },
    );
    final service = await _service(
      coordinator: coordinator,
      client: client,
      funnelAnalytics: analytics,
    );

    await Future.wait(<Future<void>>[
      service.reconcileStoreKitForTesting(),
      service.reconcileStoreKitForTesting(),
    ]);

    expect(service.isPremium, isTrue);
    expect(order, <String>['analytics', 'finish']);
    expect(client.finishCount, 1);
    expect(
      await coordinator.readState(transaction.transactionId),
      AppleTransactionAnalyticsState.sent,
    );
    expect(analytics.purchaseEventCount, 0);
  });

  test('entitlement ativo finalizado é idempotente entre inicializações',
      () async {
    final transaction = _transaction(2);
    var sendCount = 0;
    final client = _FakeStoreKitReconciliationClient(
      snapshot: StoreKitReconciliationSnapshot.success(
        unfinished: const <StoreKitReconciliationTransaction>[],
        currentEntitlements: <StoreKitReconciliationTransaction>[transaction],
      ),
    );
    final firstCoordinator = _coordinator((_) async => sendCount++);
    final first = await _service(
      coordinator: firstCoordinator,
      client: client,
    );

    await first.reconcileStoreKitForTesting();

    final restartedCoordinator = _coordinator((_) async => sendCount++);
    final restarted = await _service(
      coordinator: restartedCoordinator,
      client: client,
    );
    await restarted.reconcileStoreKitForTesting();

    expect(first.isPremium, isTrue);
    expect(restarted.isPremium, isTrue);
    expect(sendCount, 1);
    expect(client.finishCount, 0);
  });

  test('falha Analytics mantém pending, ainda finaliza e permite retry',
      () async {
    final transaction = _transaction(3);
    final order = <String>[];
    final failingCoordinator = _coordinator((_) async {
      order.add('analytics');
      throw StateError('simulated');
    });
    final unfinishedClient = _FakeStoreKitReconciliationClient(
      snapshot: StoreKitReconciliationSnapshot.success(
        unfinished: <StoreKitReconciliationTransaction>[transaction],
        currentEntitlements: <StoreKitReconciliationTransaction>[transaction],
      ),
      onFinish: (_) async {
        order.add('finish');
        return StoreKitFinishStatus.finished;
      },
    );
    final service = await _service(
      coordinator: failingCoordinator,
      client: unfinishedClient,
    );

    await service.reconcileStoreKitForTesting();

    expect(service.isPremium, isTrue);
    expect(order, <String>['analytics', 'finish']);
    expect(
      await failingCoordinator.readState(transaction.transactionId),
      AppleTransactionAnalyticsState.pending,
    );

    var retryCount = 0;
    final retryCoordinator = _coordinator((_) async => retryCount++);
    await retryCoordinator.retryPending();

    expect(retryCount, 1);
    expect(
      await retryCoordinator.readState(transaction.transactionId),
      AppleTransactionAnalyticsState.sent,
    );
  });

  test('snapshot vazio ou expirado desativa Premium conclusivamente', () async {
    final emptyService = await _service(
      coordinator: _coordinator((_) async {}),
      client: _FakeStoreKitReconciliationClient(
        snapshot: const StoreKitReconciliationSnapshot.success(
          unfinished: <StoreKitReconciliationTransaction>[],
          currentEntitlements: <StoreKitReconciliationTransaction>[],
        ),
      ),
      isPremium: true,
    );
    await emptyService.reconcileStoreKitForTesting();

    final expiredService = await _service(
      coordinator: _coordinator((_) async {}),
      client: _FakeStoreKitReconciliationClient(
        snapshot: StoreKitReconciliationSnapshot.success(
          unfinished: const <StoreKitReconciliationTransaction>[],
          currentEntitlements: <StoreKitReconciliationTransaction>[
            _transaction(4, active: false, expired: true),
          ],
        ),
      ),
      isPremium: true,
    );
    await expiredService.reconcileStoreKitForTesting();

    expect(emptyService.isPremium, isFalse);
    expect(expiredService.isPremium, isFalse);
  });

  test('falha ou indisponibilidade Apple não revoga Premium', () async {
    for (final snapshot in <StoreKitReconciliationSnapshot>[
      const StoreKitReconciliationSnapshot.failed(),
      const StoreKitReconciliationSnapshot.unavailable(),
    ]) {
      final service = await _service(
        coordinator: _coordinator((_) async {}),
        client: _FakeStoreKitReconciliationClient(snapshot: snapshot),
        isPremium: true,
      );

      await service.reconcileStoreKitForTesting();

      expect(service.isPremium, isTrue);
    }
  });

  test('produto desconhecido, não verificado e ID malformado são ignorados',
      () async {
    var sendCount = 0;
    final invalidTransactions = <StoreKitReconciliationTransaction>[
      _transaction(5, productId: 'unknown.product'),
      _transaction(6, verified: false),
      _transaction(7, transactionId: 'invalid'),
    ];
    final client = _FakeStoreKitReconciliationClient(
      snapshot: StoreKitReconciliationSnapshot.success(
        unfinished: invalidTransactions,
        currentEntitlements: invalidTransactions,
      ),
    );
    final service = await _service(
      coordinator: _coordinator((_) async => sendCount++),
      client: client,
    );

    await service.reconcileStoreKitForTesting();

    expect(service.isPremium, isFalse);
    expect(sendCount, 0);
    expect(client.finishCount, 0);
  });

  test('Android não consulta a ponte nem altera o comportamento anterior',
      () async {
    final client = _FakeStoreKitReconciliationClient(
      snapshot: StoreKitReconciliationSnapshot.success(
        unfinished: <StoreKitReconciliationTransaction>[_transaction(8)],
        currentEntitlements: <StoreKitReconciliationTransaction>[
          _transaction(8),
        ],
      ),
    );
    final service = await _service(
      coordinator: _coordinator((_) async {}),
      client: client,
      isIos: false,
      isPremium: true,
    );

    await service.reconcileStoreKitForTesting();

    expect(client.loadCount, 0);
    expect(client.finishCount, 0);
    expect(service.isPremium, isTrue);
  });
}

AppleTransactionAnalyticsCoordinator _coordinator(
  Future<void> Function(String transactionId) sendTransaction,
) {
  return AppleTransactionAnalyticsCoordinator(
    preferencesProvider: SharedPreferences.getInstance,
    isAnalyticsConfigured: () => true,
    sendTransaction: sendTransaction,
  );
}

Future<PurchaseService> _service({
  required AppleTransactionAnalyticsCoordinator coordinator,
  required StoreKitReconciliationClient client,
  PurchaseFunnelAnalytics? funnelAnalytics,
  bool isIos = true,
  bool isPremium = false,
}) async {
  return PurchaseService.forTesting(
    preferences: await SharedPreferences.getInstance(),
    appleTransactionAnalyticsCoordinator: coordinator,
    storeKitReconciliationClient: client,
    purchaseFunnelAnalytics:
        funnelAnalytics ?? _TrackingPurchaseFunnelAnalytics(),
    isIosPlatform: isIos,
    isPremium: isPremium,
  );
}

StoreKitReconciliationTransaction _transaction(
  int suffix, {
  String? transactionId,
  String productId = PurchaseService.yearlyProductId,
  bool verified = true,
  bool active = true,
  bool revoked = false,
  bool expired = false,
}) {
  return StoreKitReconciliationTransaction(
    transactionId: transactionId ?? (9100000000000000 + suffix).toString(),
    productId: productId,
    verified: verified,
    active: active,
    revoked: revoked,
    expired: expired,
  );
}

class _FakeStoreKitReconciliationClient
    implements StoreKitReconciliationClient {
  _FakeStoreKitReconciliationClient({
    required this.snapshot,
    this.onFinish,
  });

  final StoreKitReconciliationSnapshot snapshot;
  final Future<StoreKitFinishStatus> Function(
    StoreKitReconciliationTransaction transaction,
  )? onFinish;
  int loadCount = 0;
  int finishCount = 0;

  @override
  Future<StoreKitReconciliationSnapshot> loadSnapshot() async {
    loadCount++;
    return snapshot;
  }

  @override
  Future<StoreKitFinishStatus> finish(
    StoreKitReconciliationTransaction transaction,
  ) async {
    finishCount++;
    final callback = onFinish;
    if (callback == null) return StoreKitFinishStatus.finished;
    return callback(transaction);
  }
}

class _TrackingPurchaseFunnelAnalytics implements PurchaseFunnelAnalytics {
  int purchaseEventCount = 0;

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
  Future<void> logPurchaseStarted(PurchaseAttemptContext context) async =>
      purchaseEventCount++;

  @override
  Future<void> logPurchaseCanceled(PurchaseAttemptContext context) async =>
      purchaseEventCount++;

  @override
  Future<void> logPurchaseFailed({
    required PurchaseAttemptContext context,
    required PurchaseFailureStage failureStage,
    required PurchaseFailureCode failureCode,
  }) async =>
      purchaseEventCount++;
}
