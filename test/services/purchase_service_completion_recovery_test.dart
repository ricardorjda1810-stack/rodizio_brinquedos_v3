import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

  test('1 completePurchase conclui antes do timeout sem snapshot', () async {
    final logs = <String>[];
    final client = _SnapshotClient(snapshot: _confirmedSnapshot());
    var completeCount = 0;
    final service = await _service(
      logs: logs,
      client: client,
      completePurchase: (_) async => completeCount++,
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    expect(completeCount, 1);
    expect(client.loadCount, 0);
    expect(
      logs,
      contains(
        _flow('complete_purchase_result transaction=1 result=success'),
      ),
    );
    expect(_count(logs, 'terminal_result transaction=1 status=purchased'), 1);
    expect(service.isLoading, isFalse);
  });

  test('2 erro de completePurchase preserva falha sem snapshot', () async {
    const sensitiveError = 'receipt JWS user@example.com full error';
    final logs = <String>[];
    final client = _SnapshotClient(snapshot: _confirmedSnapshot());
    var completeCount = 0;
    final service = await _service(
      logs: logs,
      client: client,
      completePurchase: (_) {
        completeCount++;
        return Future<void>.error(StateError(sensitiveError));
      },
    );

    await expectLater(
      service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
        _purchased(),
      ]),
      throwsA(isA<StateError>()),
    );

    expect(completeCount, 1);
    expect(client.loadCount, 0);
    expect(
      logs,
      contains(
        _flow('complete_purchase_result transaction=1 result=failure'),
      ),
    );
    expect(logs.join('\n'), isNot(contains(sensitiveError)));
    expect(_count(logs, 'terminal_result'), 0);
  });

  test('3 timeout confirma entitlement ativo e finalizado', () async {
    final logs = <String>[];
    final order = <String>[];
    final completion = Completer<void>();
    final client = _SnapshotClient(
      snapshotLoader: () async {
        order.add('snapshot');
        return _confirmedSnapshot();
      },
    );
    var completeCount = 0;
    final coordinator = await _coordinator(
      onSend: (_) async => order.add('analytics'),
    );
    final service = await _service(
      logs: logs,
      client: client,
      coordinator: coordinator,
      completePurchase: (_) {
        completeCount++;
        order.add('complete');
        return completion.future;
      },
    );
    await _startYearly(service);

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    expect(order, <String>['analytics', 'complete', 'snapshot']);
    expect(completeCount, 1);
    expect(client.loadCount, 1);
    expect(client.finishCount, 0);
    expect(
      logs,
      contains(
        _flow('complete_purchase_result transaction=1 result=timeout'),
      ),
    );
    expect(
      logs,
      contains(
        _flow(
          'complete_purchase_result transaction=1 '
          'result=confirmed_by_snapshot',
        ),
      ),
    );
    expect(
      logs,
      contains(
        _flow(
          'terminal_result transaction=1 status=purchased premium=active '
          'context_consumed=true',
        ),
      ),
    );
    expect(service.isPremium, isTrue);
    expect(service.isLoading, isFalse);
  });

  test('4 timeout com a mesma transação unfinished fica incerto', () async {
    final logs = <String>[];
    final client = _SnapshotClient(
      snapshot: _snapshot(
        unfinished: <StoreKitReconciliationTransaction>[_transaction()],
        entitlements: <StoreKitReconciliationTransaction>[_transaction()],
      ),
    );
    final service = await _service(
      logs: logs,
      client: client,
      completePurchase: (_) => Completer<void>().future,
    );
    await _startYearly(service);

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    expect(client.loadCount, 1);
    expect(
      logs,
      contains(
        _flow(
          'complete_purchase_result transaction=1 '
          'result=timeout_unfinished',
        ),
      ),
    );
    expect(_count(logs, 'terminal_result transaction=1 status=purchased'), 0);
    expect(service.isPremium, isTrue);
    expect(service.isLoading, isFalse);
  });

  test('5 falha ao carregar snapshot produz timeout_inconclusive', () async {
    final client = _SnapshotClient(
      snapshotLoader: () => Future<StoreKitReconciliationSnapshot>.error(
        StateError('private bridge error'),
      ),
    );
    await _expectInconclusive(client);
    expect(client.loadCount, 1);
  });

  test('6 snapshot malformado produz timeout_inconclusive', () async {
    final client = _SnapshotClient(
      snapshot: const StoreKitReconciliationSnapshot.malformed(),
    );
    await _expectInconclusive(client);
    expect(client.loadCount, 1);
  });

  test('7 entitlement de outro Transaction ID é inconclusivo', () async {
    final client = _SnapshotClient(
      snapshot: _snapshot(
        entitlements: <StoreKitReconciliationTransaction>[
          _transaction(transactionId: _otherTransactionId),
        ],
      ),
    );
    await _expectInconclusive(client);
  });

  test('8 entitlement expirado é inconclusivo', () async {
    final client = _SnapshotClient(
      snapshot: _snapshot(
        entitlements: <StoreKitReconciliationTransaction>[
          _transaction(expired: true, active: false),
        ],
      ),
    );
    await _expectInconclusive(client);
  });

  test('9 entitlement revogado é inconclusivo', () async {
    final client = _SnapshotClient(
      snapshot: _snapshot(
        entitlements: <StoreKitReconciliationTransaction>[
          _transaction(revoked: true, active: false),
        ],
      ),
    );
    await _expectInconclusive(client);
  });

  test('10 produto desconhecido é inconclusivo', () async {
    final client = _SnapshotClient(
      snapshot: _snapshot(
        entitlements: <StoreKitReconciliationTransaction>[
          _transaction(productId: 'unknown.private.product'),
        ],
      ),
    );
    await _expectInconclusive(client);
  });

  test('11 completePurchase é chamado exatamente uma vez no timeout', () async {
    var completeCount = 0;
    final client = _SnapshotClient(snapshot: _confirmedSnapshot());
    final service = await _service(
      logs: <String>[],
      client: client,
      completePurchase: (_) {
        completeCount++;
        return Completer<void>().future;
      },
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    expect(completeCount, 1);
    expect(client.loadCount, 1);
    expect(client.finishCount, 0);
  });

  test('12 logTransaction ocorre uma vez antes de completePurchase', () async {
    final order = <String>[];
    final coordinator = await _coordinator(
      onSend: (_) async => order.add('analytics'),
    );
    final client = _SnapshotClient(snapshot: _confirmedSnapshot());
    final service = await _service(
      logs: <String>[],
      client: client,
      coordinator: coordinator,
      completePurchase: (_) {
        order.add('complete');
        return Completer<void>().future;
      },
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    expect(order, <String>['analytics', 'complete']);
  });

  test('13 ledger não cresce depois da confirmação por snapshot', () async {
    var sendCount = 0;
    final coordinator = await _coordinator(
      onSend: (_) async => sendCount++,
    );
    final service = await _service(
      logs: <String>[],
      client: _SnapshotClient(snapshot: _confirmedSnapshot()),
      coordinator: coordinator,
      completePurchase: (_) => Completer<void>().future,
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    expect(sendCount, 1);
    expect(await coordinator.readStoredCount(), 1);
    expect(
      await coordinator.readState(_transactionId),
      AppleTransactionAnalyticsState.sent,
    );
  });

  test('14 contexto é consumido só após confirmação conclusiva', () async {
    final confirmedLogs = <String>[];
    final confirmed = await _service(
      logs: confirmedLogs,
      client: _SnapshotClient(snapshot: _confirmedSnapshot()),
      completePurchase: (_) => Completer<void>().future,
    );
    await _startYearly(confirmed);
    await confirmed.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);
    expect(
      confirmedLogs,
      contains(
        _flow(
          'terminal_result transaction=1 status=purchased premium=active '
          'context_consumed=true',
        ),
      ),
    );

    final uncertainLogs = <String>[];
    final uncertain = await _service(
      logs: uncertainLogs,
      client: _SnapshotClient(
        snapshot: const StoreKitReconciliationSnapshot.failed(),
      ),
      completePurchase: (_) => Completer<void>().future,
    );
    await _startYearly(uncertain);
    await uncertain.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);
    await uncertain.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    expect(
      uncertainLogs.where((line) => line.contains('context_present=true')),
      hasLength(greaterThanOrEqualTo(2)),
    );
    expect(
      _count(uncertainLogs, 'terminal_result transaction=1 status=purchased'),
      0,
    );
  });

  test('15 loading é liberado depois de timeout inconclusivo', () async {
    final service = await _uncertainService();
    await _startYearly(service);
    expect(service.isLoading, isTrue);

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    expect(service.isLoading, isFalse);
  });

  test('16 nova compra do mesmo produto é bloqueada na sessão', () async {
    var launchCount = 0;
    final service = await _uncertainService(
      purchaseLauncher: (_) async {
        launchCount++;
        return true;
      },
    );
    await _startYearly(service);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    await _startYearly(service);

    expect(launchCount, 1);
  });

  test('17 restauração é bloqueada enquanto conclusão está incerta', () async {
    final service = await _uncertainService();
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);
    expect(service.errorMessage, isNull);

    await service.restorePurchases(source: 'settings');

    expect(service.errorMessage, isNull);
    expect(service.isLoading, isFalse);
  });

  test('18 novo processo permite reconciliação normal', () async {
    final preferences = await SharedPreferences.getInstance();
    final first = await _uncertainService(preferences: preferences);
    await first.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    var launchCount = 0;
    final startupClient = _SnapshotClient(snapshot: _confirmedSnapshot());
    final restarted = await _service(
      logs: <String>[],
      preferences: preferences,
      client: startupClient,
      completePurchase: (_) async {},
      purchaseLauncher: (_) async {
        launchCount++;
        return true;
      },
    );
    await restarted.reconcileStoreKitForTesting();
    await _startYearly(restarted);

    expect(startupClient.loadCount, 1);
    expect(restarted.isPremium, isTrue);
    expect(launchCount, 1);
  });

  test('19 conclusão tardia não duplica resultado terminal', () async {
    final logs = <String>[];
    final completion = Completer<void>();
    final service = await _service(
      logs: logs,
      client: _SnapshotClient(snapshot: _confirmedSnapshot()),
      completePurchase: (_) => completion.future,
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);
    completion.complete();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(
      _count(logs, 'complete_purchase_result transaction=1 result=timeout'),
      1,
    );
    expect(_count(logs, 'result=confirmed_by_snapshot'), 1);
    expect(
      _count(logs, 'complete_purchase_result transaction=1 result=success'),
      0,
    );
    expect(_count(logs, 'terminal_result transaction=1 status=purchased'), 1);
  });

  test('20 callback repetido do mesmo Transaction ID não trava', () async {
    var completeCount = 0;
    final client = _SnapshotClient(
      snapshot: const StoreKitReconciliationSnapshot.failed(),
    );
    final service = await _service(
      logs: <String>[],
      client: client,
      completePurchase: (_) {
        completeCount++;
        return Completer<void>().future;
      },
    );
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased()
    ]).timeout(const Duration(milliseconds: 100));

    expect(completeCount, 1);
    expect(client.loadCount, 1);
  });

  test('21 produção recupera sem emitir logs PurchaseFlow', () async {
    final logs = <String>[];
    final client = _SnapshotClient(snapshot: _confirmedSnapshot());
    final service = await _service(
      logs: logs,
      client: client,
      diagnosticsEnabled: false,
      completePurchase: (_) => Completer<void>().future,
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]);

    expect(client.loadCount, 1);
    expect(service.isPremium, isTrue);
    expect(service.isLoading, isFalse);
    expect(logs, isEmpty);
  });

  test('22 Android não usa timeout nem ponte iOS', () async {
    final completion = Completer<void>();
    final client = _SnapshotClient(snapshot: _confirmedSnapshot());
    var handlerFinished = false;
    final service = await _service(
      logs: <String>[],
      client: client,
      isIos: false,
      completePurchase: (_) => completion.future,
    );

    final handler = service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(),
    ]).whenComplete(() => handlerFinished = true);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(handlerFinished, isFalse);
    expect(client.loadCount, 0);
    completion.complete();
    await handler;
    expect(handlerFinished, isTrue);
  });

  test('23 diagnósticos de recuperação não contêm dados sensíveis', () async {
    const secretVerification =
        'receipt JWS user@example.com payment full-message';
    final logs = <String>[];
    final service = await _service(
      logs: logs,
      client: _SnapshotClient(snapshot: _confirmedSnapshot()),
      completePurchase: (_) => Completer<void>().future,
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(verificationData: secretVerification),
    ]);

    final joined = logs.join('\n');
    for (final forbidden in <String>[
      _transactionId,
      PurchaseService.yearlyProductId,
      'receipt',
      'JWS',
      'user@example.com',
      'payment',
      'full-message',
    ]) {
      expect(joined, isNot(contains(forbidden)));
    }
  });
}

const String _transactionId = '9000000000000420';
const String _otherTransactionId = '9000000000000421';
const Duration _testTimeout = Duration(milliseconds: 2);

final PaywallAnalyticsContext _paywall = PaywallAnalyticsContext.create(
  source: PaywallSource.settings,
  idGenerator: () => 'paywall-completion-recovery',
);

Future<void> _expectInconclusive(_SnapshotClient client) async {
  final logs = <String>[];
  final service = await _service(
    logs: logs,
    client: client,
    completePurchase: (_) => Completer<void>().future,
  );

  await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
    _purchased(),
  ]);

  expect(
    logs,
    contains(
      _flow(
        'complete_purchase_result transaction=1 '
        'result=timeout_inconclusive',
      ),
    ),
  );
  expect(_count(logs, 'terminal_result transaction=1 status=purchased'), 0);
  expect(service.isLoading, isFalse);
}

Future<PurchaseService> _uncertainService({
  SharedPreferences? preferences,
  Future<bool> Function(ProductDetails productDetails)? purchaseLauncher,
}) {
  return _service(
    logs: <String>[],
    preferences: preferences,
    client: _SnapshotClient(
      snapshot: const StoreKitReconciliationSnapshot.failed(),
    ),
    completePurchase: (_) => Completer<void>().future,
    purchaseLauncher: purchaseLauncher,
  );
}

Future<PurchaseService> _service({
  required List<String> logs,
  required _SnapshotClient client,
  SharedPreferences? preferences,
  AppleTransactionAnalyticsCoordinator? coordinator,
  Future<void> Function(PurchaseDetails purchaseDetails)? completePurchase,
  Future<bool> Function(ProductDetails productDetails)? purchaseLauncher,
  bool diagnosticsEnabled = true,
  bool isIos = true,
}) async {
  final resolvedPreferences =
      preferences ?? await SharedPreferences.getInstance();
  return PurchaseService.forTesting(
    preferences: resolvedPreferences,
    productDetailsById: <String, ProductDetails>{
      PurchaseService.yearlyProductId:
          _product(PurchaseService.yearlyProductId),
    },
    appleTransactionAnalyticsCoordinator:
        coordinator ?? await _coordinator(preferences: resolvedPreferences),
    isIosPlatform: isIos,
    completePurchase: completePurchase,
    completePurchaseTimeout: _testTimeout,
    purchaseLauncher: purchaseLauncher ?? (_) async => true,
    purchaseFunnelAnalytics: const _NoopPurchaseFunnelAnalytics(),
    analyticsIdGenerator: () => 'attempt-completion-recovery',
    storeKitReconciliationClient: client,
    storeKitDiagnosticsEnabled: diagnosticsEnabled,
    storeKitDiagnosticsLogger: logs.add,
  );
}

Future<AppleTransactionAnalyticsCoordinator> _coordinator({
  SharedPreferences? preferences,
  Future<void> Function(String transactionId)? onSend,
}) async {
  final resolvedPreferences =
      preferences ?? await SharedPreferences.getInstance();
  return AppleTransactionAnalyticsCoordinator(
    preferencesProvider: () async => resolvedPreferences,
    isAnalyticsConfigured: () => true,
    sendTransaction: onSend ?? (_) async {},
  );
}

Future<void> _startYearly(PurchaseService service) {
  return service.startPurchase(
    productId: PurchaseService.yearlyProductId,
    paywallContext: _paywall,
  );
}

StoreKitReconciliationSnapshot _confirmedSnapshot() {
  return _snapshot(
    entitlements: <StoreKitReconciliationTransaction>[_transaction()],
  );
}

StoreKitReconciliationSnapshot _snapshot({
  List<StoreKitReconciliationTransaction> unfinished =
      const <StoreKitReconciliationTransaction>[],
  List<StoreKitReconciliationTransaction> entitlements =
      const <StoreKitReconciliationTransaction>[],
}) {
  return StoreKitReconciliationSnapshot.success(
    unfinished: unfinished,
    currentEntitlements: entitlements,
  );
}

StoreKitReconciliationTransaction _transaction({
  String transactionId = _transactionId,
  String productId = PurchaseService.yearlyProductId,
  bool verified = true,
  bool active = true,
  bool revoked = false,
  bool expired = false,
}) {
  return StoreKitReconciliationTransaction(
    transactionId: transactionId,
    productId: productId,
    verified: verified,
    active: active,
    revoked: revoked,
    expired: expired,
  );
}

PurchaseDetails _purchased({String verificationData = ''}) {
  final purchase = PurchaseDetails(
    purchaseID: _transactionId,
    productID: PurchaseService.yearlyProductId,
    verificationData: PurchaseVerificationData(
      localVerificationData: verificationData,
      serverVerificationData: verificationData,
      source: 'test',
    ),
    transactionDate: null,
    status: PurchaseStatus.purchased,
  );
  purchase.pendingCompletePurchase = true;
  return purchase;
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

String _flow(String message) => '[PurchaseFlow] $message';

int _count(List<String> logs, String fragment) {
  return logs.where((line) => line.contains(fragment)).length;
}

class _SnapshotClient implements StoreKitReconciliationClient {
  _SnapshotClient({
    StoreKitReconciliationSnapshot? snapshot,
    Future<StoreKitReconciliationSnapshot> Function()? snapshotLoader,
  })  : assert(snapshot != null || snapshotLoader != null),
        _snapshot = snapshot,
        _snapshotLoader = snapshotLoader;

  final StoreKitReconciliationSnapshot? _snapshot;
  final Future<StoreKitReconciliationSnapshot> Function()? _snapshotLoader;
  int loadCount = 0;
  int finishCount = 0;

  @override
  Future<StoreKitReconciliationSnapshot> loadSnapshot() async {
    loadCount++;
    final loader = _snapshotLoader;
    if (loader != null) return loader();
    return _snapshot!;
  }

  @override
  Future<StoreKitFinishStatus> finish(
    StoreKitReconciliationTransaction transaction,
  ) async {
    finishCount++;
    return StoreKitFinishStatus.finished;
  }
}

class _NoopPurchaseFunnelAnalytics implements PurchaseFunnelAnalytics {
  const _NoopPurchaseFunnelAnalytics();

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
  }) async {}
}
