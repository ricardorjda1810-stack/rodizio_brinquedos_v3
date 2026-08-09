import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/apple_transaction_analytics_coordinator.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/services/storekit_reconciliation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('snapshot vazio registra contagens e desativa Premium conclusivamente',
      () async {
    final logs = <String>[];
    final service = await _service(
      logs: logs,
      coordinator: _coordinator((_) async {}),
      client: _FakeStoreKitReconciliationClient(
        snapshot: const StoreKitReconciliationSnapshot.success(
          unfinished: <StoreKitReconciliationTransaction>[],
          currentEntitlements: <StoreKitReconciliationTransaction>[],
        ),
      ),
      isPremium: true,
    );

    await service.reconcileStoreKitForTesting();

    expect(service.isPremium, isFalse);
    expect(logs, contains(_log('startup_begin')));
    expect(
      logs,
      contains(
        _log(
          'snapshot_success unfinished_count=0 current_entitlement_count=0',
        ),
      ),
    );
    expect(
      logs,
      contains(
        _log(
          'premium_decision result=inactive '
          'reason=conclusive_empty_snapshot',
        ),
      ),
    );
    expect(
      logs,
      contains(
        _log(
          'startup_end processed=0 deduplicated=0 finished=0 '
          'finish_failed=0',
        ),
      ),
    );
  });

  test('unfinished registra Analytics antes de finish e sucesso real',
      () async {
    final logs = <String>[];
    final order = <String>[];
    final transaction = _transaction(1);
    final client = _FakeStoreKitReconciliationClient(
      snapshot: StoreKitReconciliationSnapshot.success(
        unfinished: <StoreKitReconciliationTransaction>[transaction],
        currentEntitlements: const <StoreKitReconciliationTransaction>[],
      ),
      onFinish: (_) async {
        order.add('finish');
        return StoreKitFinishStatus.finished;
      },
    );
    final service = await _service(
      logs: logs,
      coordinator: _coordinator((_) async => order.add('analytics')),
      client: client,
    );

    await service.reconcileStoreKitForTesting();

    expect(order, <String>['analytics', 'finish']);
    expect(client.finishCount, 1);
    expect(
      logs,
      contains(
        _log(
          'transaction=1 source=unfinished plan=yearly verified=true '
          'active=true revoked=false expired=false ledger_before=absent '
          'deduplicated=false',
        ),
      ),
    );
    expect(logs, contains(_log('analytics_result transaction=1 result=sent')));
    expect(logs, contains(_log('finish_result transaction=1 result=success')));
    expect(
      logs.indexOf(_log('analytics_result transaction=1 result=sent')),
      lessThan(
          logs.indexOf(_log('finish_result transaction=1 result=success'))),
    );
  });

  test('entitlement atual ativa Premium sem chamar finish', () async {
    final logs = <String>[];
    final transaction =
        _transaction(2, productId: PurchaseService.monthlyProductId);
    final client = _FakeStoreKitReconciliationClient(
      snapshot: StoreKitReconciliationSnapshot.success(
        unfinished: const <StoreKitReconciliationTransaction>[],
        currentEntitlements: <StoreKitReconciliationTransaction>[transaction],
      ),
    );
    final service = await _service(
      logs: logs,
      coordinator: _coordinator((_) async {}),
      client: client,
    );

    await service.reconcileStoreKitForTesting();

    expect(service.isPremium, isTrue);
    expect(client.finishCount, 0);
    expect(
      logs,
      contains(
        _log(
          'transaction=1 source=current_entitlement plan=monthly '
          'verified=true active=true revoked=false expired=false '
          'ledger_before=absent deduplicated=false',
        ),
      ),
    );
    expect(
      logs,
      contains(
        _log(
          'finish_result transaction=1 '
          'result=not_required_current_entitlement',
        ),
      ),
    );
    expect(
      logs,
      contains(
        _log('premium_decision result=active reason=active_entitlement'),
      ),
    );
  });

  test('mesmo ID nas duas fontes é processado e finalizado uma vez', () async {
    final logs = <String>[];
    var analyticsCount = 0;
    final transaction = _transaction(3);
    final client = _FakeStoreKitReconciliationClient(
      snapshot: StoreKitReconciliationSnapshot.success(
        unfinished: <StoreKitReconciliationTransaction>[transaction],
        currentEntitlements: <StoreKitReconciliationTransaction>[transaction],
      ),
    );
    final service = await _service(
      logs: logs,
      coordinator: _coordinator((_) async => analyticsCount++),
      client: client,
    );

    await service.reconcileStoreKitForTesting();

    expect(analyticsCount, 1);
    expect(client.finishCount, 1);
    expect(
      logs.singleWhere((line) => line.contains('transaction=1 source=')),
      contains('source=unfinished,current_entitlement'),
    );
    expect(
      logs.singleWhere((line) => line.contains('transaction=1 source=')),
      contains('deduplicated=true'),
    );
    expect(
      logs,
      contains(
        _log(
          'startup_end processed=1 deduplicated=1 finished=1 '
          'finish_failed=0',
        ),
      ),
    );
  });

  test('ledger sent impede reenvio e registra skipped_already_sent', () async {
    final logs = <String>[];
    var analyticsCount = 0;
    final transaction = _transaction(4);
    final coordinator = _coordinator((_) async => analyticsCount++);
    await coordinator.recordNewPurchase(transaction.transactionId);
    final service = await _service(
      logs: logs,
      coordinator: coordinator,
      client: _FakeStoreKitReconciliationClient(
        snapshot: StoreKitReconciliationSnapshot.success(
          unfinished: const <StoreKitReconciliationTransaction>[],
          currentEntitlements: <StoreKitReconciliationTransaction>[
            transaction,
          ],
        ),
      ),
    );

    await service.reconcileStoreKitForTesting();

    expect(analyticsCount, 1);
    expect(
      logs.singleWhere((line) => line.contains('transaction=1 source=')),
      contains('ledger_before=sent'),
    );
    expect(
      logs,
      contains(
        _log(
          'analytics_result transaction=1 result=skipped_already_sent',
        ),
      ),
    );
  });

  test('falha Analytics mantém pending e não impede finish', () async {
    final logs = <String>[];
    final transaction = _transaction(5);
    final coordinator = _coordinator((_) async {
      throw StateError('private receipt JWS user@example.com');
    });
    final client = _FakeStoreKitReconciliationClient(
      snapshot: StoreKitReconciliationSnapshot.success(
        unfinished: <StoreKitReconciliationTransaction>[transaction],
        currentEntitlements: const <StoreKitReconciliationTransaction>[],
      ),
    );
    final service = await _service(
      logs: logs,
      coordinator: coordinator,
      client: client,
    );

    await service.reconcileStoreKitForTesting();

    expect(
      await coordinator.readState(transaction.transactionId),
      AppleTransactionAnalyticsState.pending,
    );
    expect(client.finishCount, 1);
    expect(
      logs,
      contains(_log('analytics_result transaction=1 result=pending')),
    );
    expect(logs, contains(_log('finish_result transaction=1 result=success')));
  });

  test('falha de finish incrementa contador sem falsa linha de sucesso',
      () async {
    final logs = <String>[];
    final transaction = _transaction(6);
    final service = await _service(
      logs: logs,
      coordinator: _coordinator((_) async {}),
      client: _FakeStoreKitReconciliationClient(
        snapshot: StoreKitReconciliationSnapshot.success(
          unfinished: <StoreKitReconciliationTransaction>[transaction],
          currentEntitlements: const <StoreKitReconciliationTransaction>[],
        ),
        onFinish: (_) async => StoreKitFinishStatus.failed,
      ),
    );

    await service.reconcileStoreKitForTesting();

    expect(logs, contains(_log('finish_result transaction=1 result=failure')));
    expect(
      logs,
      isNot(contains(_log('finish_result transaction=1 result=success'))),
    );
    expect(
      logs,
      contains(
        _log(
          'startup_end processed=1 deduplicated=0 finished=0 '
          'finish_failed=1',
        ),
      ),
    );
  });

  test('falha e snapshot malformado preservam Premium com código controlado',
      () async {
    for (final testCase in <({
      StoreKitReconciliationSnapshot snapshot,
      String failureCode,
      String reason,
    })>[
      (
        snapshot: const StoreKitReconciliationSnapshot.failed(),
        failureCode: 'platform_error',
        reason: 'snapshot_failure',
      ),
      (
        snapshot: const StoreKitReconciliationSnapshot.malformed(),
        failureCode: 'malformed_snapshot',
        reason: 'malformed_snapshot',
      ),
    ]) {
      final logs = <String>[];
      final service = await _service(
        logs: logs,
        coordinator: _coordinator((_) async {}),
        client: _FakeStoreKitReconciliationClient(
          snapshot: testCase.snapshot,
        ),
        isPremium: true,
      );

      await service.reconcileStoreKitForTesting();

      expect(service.isPremium, isTrue);
      expect(
        logs,
        contains(_log('snapshot_failure code=${testCase.failureCode}')),
      );
      expect(
        logs,
        contains(
          _log(
            'premium_decision result=preserved reason=${testCase.reason}',
          ),
        ),
      );
    }
  });

  test('produção não emite diagnósticos', () async {
    final logs = <String>[];
    final service = await _service(
      logs: logs,
      diagnosticsEnabled: false,
      coordinator: _coordinator((_) async {}),
      client: _FakeStoreKitReconciliationClient(
        snapshot: const StoreKitReconciliationSnapshot.success(
          unfinished: <StoreKitReconciliationTransaction>[],
          currentEntitlements: <StoreKitReconciliationTransaction>[],
        ),
      ),
    );

    await service.reconcileStoreKitForTesting();

    expect(logs, isEmpty);
  });

  test('Android não consulta ponte nem emite diagnósticos', () async {
    final logs = <String>[];
    final client = _FakeStoreKitReconciliationClient(
      snapshot: StoreKitReconciliationSnapshot.success(
        unfinished: <StoreKitReconciliationTransaction>[_transaction(7)],
        currentEntitlements: <StoreKitReconciliationTransaction>[
          _transaction(7),
        ],
      ),
    );
    final service = await _service(
      logs: logs,
      coordinator: _coordinator((_) async {}),
      client: client,
      isIos: false,
    );

    await service.reconcileStoreKitForTesting();

    expect(client.loadCount, 0);
    expect(client.finishCount, 0);
    expect(logs, isEmpty);
  });

  test('diagnósticos não expõem IDs, JWS, recibo, e-mail ou erro integral',
      () async {
    final logs = <String>[];
    final transaction = _transaction(8);
    const privateError = 'receipt JWS private-user@example.com';
    final service = await _service(
      logs: logs,
      coordinator: _coordinator((_) async => throw StateError(privateError)),
      client: _FakeStoreKitReconciliationClient(
        snapshot: StoreKitReconciliationSnapshot.success(
          unfinished: <StoreKitReconciliationTransaction>[transaction],
          currentEntitlements: <StoreKitReconciliationTransaction>[
            transaction,
          ],
        ),
      ),
    );

    await service.reconcileStoreKitForTesting();

    final output = logs.join('\n');
    expect(output, isNot(contains(transaction.transactionId)));
    expect(output, isNot(contains('transactionId')));
    expect(output, isNot(contains('JWS')));
    expect(output, isNot(contains('receipt')));
    expect(output, isNot(contains('private-user@example.com')));
    expect(output, isNot(contains(privateError)));
    expect(output, isNot(contains('com.rodiziobrinquedos.premium')));
  });
}

String _log(String message) => '[StoreKitReconciliation] $message';

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
  required List<String> logs,
  required AppleTransactionAnalyticsCoordinator coordinator,
  required StoreKitReconciliationClient client,
  bool diagnosticsEnabled = true,
  bool isIos = true,
  bool isPremium = false,
}) async {
  return PurchaseService.forTesting(
    preferences: await SharedPreferences.getInstance(),
    appleTransactionAnalyticsCoordinator: coordinator,
    storeKitReconciliationClient: client,
    storeKitDiagnosticsEnabled: diagnosticsEnabled,
    storeKitDiagnosticsLogger: logs.add,
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
    transactionId: transactionId ?? (9200000000000000 + suffix).toString(),
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
