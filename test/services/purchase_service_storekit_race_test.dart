import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/apple_transaction_analytics_coordinator.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/services/storekit_reconciliation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('callback aguarda startup e fila drena em FIFO sem efeito antecipado',
      () async {
    final snapshot = Completer<StoreKitReconciliationSnapshot>();
    final analyticsOrder = <String>[];
    final finishOrder = <String>[];
    final logs = <String>[];
    final client = _Client(snapshotLoader: () => snapshot.future);
    final service = await _service(
      logs: logs,
      client: client,
      initialReconciliationComplete: false,
      coordinator: _coordinator(
        onSend: (transactionId) async => analyticsOrder.add(transactionId),
      ),
      completePurchase: (purchase) async {
        finishOrder.add(purchase.purchaseID!);
      },
    );

    final startup = service.runInitialStoreKitReconciliationForTesting();
    await Future<void>.delayed(Duration.zero);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(_id(1)),
    ]);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(_id(2)),
    ]);

    expect(analyticsOrder, isEmpty);
    expect(finishOrder, isEmpty);
    expect(service.isPremium, isFalse);
    expect(_count(logs, '[PurchaseFlow] callback '), 0);

    snapshot.complete(_snapshot());
    await startup;

    expect(analyticsOrder, <String>[_id(1), _id(2)]);
    expect(finishOrder, <String>[_id(1), _id(2)]);
    expect(service.isPremium, isTrue);
    expect(_count(logs, '[PurchaseFlow] callback '), 2);
    expect(
      logs.indexWhere((line) => line.contains('callback transaction=1')),
      lessThan(
        logs.indexWhere((line) => line.contains('callback transaction=2')),
      ),
    );
  });

  test('fila drena no finally quando snapshot falha', () async {
    var analyticsCount = 0;
    var completeCount = 0;
    final service = await _service(
      logs: <String>[],
      client: _Client(
        snapshot: const StoreKitReconciliationSnapshot.failed(),
      ),
      initialReconciliationComplete: false,
      coordinator: _coordinator(onSend: (_) async => analyticsCount++),
      completePurchase: (_) async => completeCount++,
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(_id(3)),
    ]);
    await service.runInitialStoreKitReconciliationForTesting();

    expect(analyticsCount, 1);
    expect(completeCount, 1);
    expect(service.isPremium, isTrue);
  });

  test('snapshot unfinished assume Analytics e finish antes do callback igual',
      () async {
    final transaction = _transaction(4);
    var analyticsCount = 0;
    var completePurchaseCount = 0;
    final logs = <String>[];
    final client = _Client(
      snapshot: _snapshot(
        unfinished: <StoreKitReconciliationTransaction>[transaction],
        entitlements: <StoreKitReconciliationTransaction>[transaction],
      ),
    );
    final service = await _service(
      logs: logs,
      client: client,
      initialReconciliationComplete: false,
      coordinator: _coordinator(onSend: (_) async => analyticsCount++),
      completePurchase: (_) async => completePurchaseCount++,
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(transaction.transactionId),
    ]);
    await service.runInitialStoreKitReconciliationForTesting();

    expect(analyticsCount, 1);
    expect(client.finishCount, 1);
    expect(completePurchaseCount, 0);
    expect(service.isPremium, isTrue);
    expect(
      logs,
      contains(
        '[StoreKitReconciliation] finish_result transaction=1 result=success',
      ),
    );
    expect(
      logs,
      contains(
        '[PurchaseFlow] analytics_result transaction=1 result=coalesced',
      ),
    );
    expect(
      logs,
      contains(
        '[PurchaseFlow] complete_purchase_result transaction=1 '
        'result=coalesced',
      ),
    );
  });

  test('unfinished com ledger sent ainda finaliza uma única vez', () async {
    final transaction = _transaction(5);
    var analyticsCount = 0;
    final coordinator = _coordinator(onSend: (_) async => analyticsCount++);
    await coordinator.recordNewPurchase(transaction.transactionId);
    final client = _Client(
      snapshot: _snapshot(
        unfinished: <StoreKitReconciliationTransaction>[transaction],
      ),
    );
    final logs = <String>[];
    final service = await _service(
      logs: logs,
      client: client,
      coordinator: coordinator,
    );

    await service.reconcileStoreKitForTesting();
    await service.reconcileStoreKitForTesting();

    expect(analyticsCount, 1);
    expect(client.finishCount, 1);
    expect(
      logs,
      contains(
        '[StoreKitReconciliation] analytics_result transaction=1 '
        'result=skipped_already_sent',
      ),
    );
    expect(
      logs,
      contains(
        '[StoreKitReconciliation] finish_result transaction=1 '
        'result=coalesced',
      ),
    );
  });

  test('unfinished expirado finaliza sem ativar Premium', () async {
    final transaction = _transaction(6, active: false, expired: true);
    final coordinator = _coordinator();
    await coordinator.recordNewPurchase(transaction.transactionId);
    final client = _Client(
      snapshot: _snapshot(
        unfinished: <StoreKitReconciliationTransaction>[transaction],
      ),
    );
    final service = await _service(
      logs: <String>[],
      client: client,
      coordinator: coordinator,
      isPremium: true,
    );

    await service.reconcileStoreKitForTesting();

    expect(client.finishCount, 1);
    expect(service.isPremium, isFalse);
  });

  test('entitlement atual isolado ativa Premium sem finish', () async {
    final transaction = _transaction(7);
    final logs = <String>[];
    final client = _Client(
      snapshot: _snapshot(
        entitlements: <StoreKitReconciliationTransaction>[transaction],
      ),
    );
    final service = await _service(logs: logs, client: client);

    await service.reconcileStoreKitForTesting();

    expect(service.isPremium, isTrue);
    expect(client.finishCount, 0);
    expect(
      logs,
      contains(
        '[StoreKitReconciliation] finish_result transaction=1 '
        'result=not_required_current_entitlement',
      ),
    );
  });

  test('três IDs duplicados geram seis callbacks e três operações', () async {
    var analyticsCount = 0;
    var completeCount = 0;
    final logs = <String>[];
    final service = await _service(
      logs: logs,
      client: _Client(snapshot: _snapshot()),
      initialReconciliationComplete: false,
      coordinator: _coordinator(onSend: (_) async => analyticsCount++),
      completePurchase: (_) async => completeCount++,
    );
    final callbacks = <PurchaseDetails>[
      for (var suffix = 8; suffix <= 10; suffix++) ...<PurchaseDetails>[
        _purchased(_id(suffix)),
        _purchased(_id(suffix)),
      ],
    ];

    await service.handlePurchaseUpdatesForTesting(callbacks);
    await service.runInitialStoreKitReconciliationForTesting();

    expect(_count(logs, '[PurchaseFlow] callback '), 6);
    expect(_count(logs, 'callback_coalesced'), 3);
    expect(_count(logs, 'terminal_result transaction='), 3);
    expect(analyticsCount, 3);
    expect(completeCount, 3);
    expect(_callbackOrdinals(logs), <String>{'1', '2', '3'});
  });

  test('callbacks simultâneo e tardio reutilizam finish concluído', () async {
    final completion = Completer<void>();
    var analyticsCount = 0;
    var completeCount = 0;
    final logs = <String>[];
    final service = await _service(
      logs: logs,
      client: _Client(snapshot: _snapshot()),
      coordinator: _coordinator(onSend: (_) async => analyticsCount++),
      completePurchase: (_) {
        completeCount++;
        return completion.future;
      },
    );
    final purchase = _purchased(_id(11));

    final first = service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      purchase,
    ]);
    final simultaneous = service.handlePurchaseUpdatesForTesting(
      <PurchaseDetails>[_purchased(_id(11))],
    );
    await Future<void>.delayed(Duration.zero);
    completion.complete();
    await Future.wait(<Future<void>>[first, simultaneous]);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(_id(11)),
    ]);

    expect(analyticsCount, 1);
    expect(completeCount, 1);
    expect(_count(logs, '[PurchaseFlow] callback '), 3);
    expect(_count(logs, 'callback_coalesced'), 2);
    expect(_callbackOrdinals(logs), <String>{'1'});
  });

  test('alreadyFinished e failure têm diagnóstico distinto e não repetem',
      () async {
    for (final testCase in <({
      StoreKitFinishStatus status,
      String diagnostic,
    })>[
      (
        status: StoreKitFinishStatus.alreadyFinished,
        diagnostic: 'already_finished',
      ),
      (status: StoreKitFinishStatus.failed, diagnostic: 'failure'),
    ]) {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final transaction = _transaction(12);
      final logs = <String>[];
      var completeCount = 0;
      final client = _Client(
        snapshot: _snapshot(
          unfinished: <StoreKitReconciliationTransaction>[transaction],
        ),
        finishStatus: testCase.status,
      );
      final service = await _service(
        logs: logs,
        client: client,
        initialReconciliationComplete: false,
        completePurchase: (_) async => completeCount++,
      );

      await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
        _purchased(transaction.transactionId),
      ]);
      await service.runInitialStoreKitReconciliationForTesting();

      expect(client.finishCount, 1);
      expect(completeCount, 0);
      expect(
        logs,
        contains(
          '[StoreKitReconciliation] finish_result transaction=1 '
          'result=${testCase.diagnostic}',
        ),
      );
    }
  });

  test('falha de completePurchase ao vivo não repete finish na sessão',
      () async {
    var completeCount = 0;
    final service = await _service(
      logs: <String>[],
      client: _Client(snapshot: _snapshot()),
      completePurchase: (_) async {
        completeCount++;
        throw StateError('controlled');
      },
    );

    await expectLater(
      service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
        _purchased(_id(14)),
      ]),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
        _purchased(_id(14)),
      ]),
      throwsA(isA<StateError>()),
    );

    expect(completeCount, 1);
  });

  test('dispose descarta fila sem processamento tardio', () async {
    final snapshot = Completer<StoreKitReconciliationSnapshot>();
    var analyticsCount = 0;
    var completeCount = 0;
    final service = await _service(
      logs: <String>[],
      client: _Client(snapshotLoader: () => snapshot.future),
      initialReconciliationComplete: false,
      coordinator: _coordinator(onSend: (_) async => analyticsCount++),
      completePurchase: (_) async => completeCount++,
    );
    final startup = service.runInitialStoreKitReconciliationForTesting();
    await Future<void>.delayed(Duration.zero);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchased(_id(13)),
    ]);

    service.dispose();
    snapshot.complete(_snapshot());
    await startup;

    expect(analyticsCount, 0);
    expect(completeCount, 0);
  });
}

Future<PurchaseService> _service({
  required List<String> logs,
  required _Client client,
  AppleTransactionAnalyticsCoordinator? coordinator,
  Future<void> Function(PurchaseDetails purchaseDetails)? completePurchase,
  bool initialReconciliationComplete = true,
  bool isPremium = false,
}) async {
  return PurchaseService.forTesting(
    preferences: await SharedPreferences.getInstance(),
    appleTransactionAnalyticsCoordinator: coordinator ?? _coordinator(),
    isIosPlatform: true,
    completePurchase: completePurchase,
    storeKitReconciliationClient: client,
    storeKitDiagnosticsEnabled: true,
    storeKitDiagnosticsLogger: logs.add,
    initialStoreKitReconciliationComplete: initialReconciliationComplete,
    isPremium: isPremium,
  );
}

AppleTransactionAnalyticsCoordinator _coordinator({
  Future<void> Function(String transactionId)? onSend,
}) {
  return AppleTransactionAnalyticsCoordinator(
    preferencesProvider: SharedPreferences.getInstance,
    isAnalyticsConfigured: () => true,
    sendTransaction: onSend ?? (_) async {},
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

StoreKitReconciliationTransaction _transaction(
  int suffix, {
  bool active = true,
  bool expired = false,
}) {
  return StoreKitReconciliationTransaction(
    transactionId: _id(suffix),
    productId: PurchaseService.yearlyProductId,
    verified: true,
    active: active,
    revoked: false,
    expired: expired,
  );
}

PurchaseDetails _purchased(String transactionId) {
  final purchase = PurchaseDetails(
    purchaseID: transactionId,
    productID: PurchaseService.yearlyProductId,
    verificationData: PurchaseVerificationData(
      localVerificationData: '',
      serverVerificationData: '',
      source: 'test',
    ),
    transactionDate: null,
    status: PurchaseStatus.purchased,
  );
  purchase.pendingCompletePurchase = true;
  return purchase;
}

String _id(int suffix) => (9300000000000000 + suffix).toString();

int _count(List<String> logs, String fragment) {
  return logs.where((line) => line.contains(fragment)).length;
}

Set<String> _callbackOrdinals(List<String> logs) {
  final pattern = RegExp(r'callback transaction=(\d+)');
  return logs
      .map(pattern.firstMatch)
      .whereType<RegExpMatch>()
      .map((match) => match.group(1)!)
      .toSet();
}

class _Client implements StoreKitReconciliationClient {
  _Client({
    this.snapshot,
    this.snapshotLoader,
    this.finishStatus = StoreKitFinishStatus.finished,
  }) : assert(snapshot != null || snapshotLoader != null);

  final StoreKitReconciliationSnapshot? snapshot;
  final Future<StoreKitReconciliationSnapshot> Function()? snapshotLoader;
  final StoreKitFinishStatus finishStatus;
  int finishCount = 0;

  @override
  Future<StoreKitReconciliationSnapshot> loadSnapshot() async {
    final loader = snapshotLoader;
    if (loader != null) return loader();
    return snapshot!;
  }

  @override
  Future<StoreKitFinishStatus> finish(
    StoreKitReconciliationTransaction transaction,
  ) async {
    finishCount++;
    return finishStatus;
  }
}
