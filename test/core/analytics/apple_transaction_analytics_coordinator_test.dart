import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/apple_transaction_analytics_coordinator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late bool analyticsConfigured;
  late int sendCount;
  late AppleTransactionAnalyticsCoordinator coordinator;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    analyticsConfigured = false;
    sendCount = 0;
    coordinator = AppleTransactionAnalyticsCoordinator(
      preferencesProvider: SharedPreferences.getInstance,
      isAnalyticsConfigured: () => analyticsConfigured,
      sendTransaction: (_) async {
        sendCount++;
      },
    );
  });

  test('compra nova registra pending antes de o Analytics estar disponível',
      () async {
    final transactionId = _opaqueTransactionId(1);

    await coordinator.recordNewPurchase(transactionId);

    expect(
      await coordinator.readState(transactionId),
      AppleTransactionAnalyticsState.pending,
    );
    expect(sendCount, 0);
  });

  test('retorno sem exceção marca sent e replay não envia novamente', () async {
    analyticsConfigured = true;
    final transactionId = _opaqueTransactionId(2);

    await coordinator.recordNewPurchase(transactionId);
    await coordinator.recordNewPurchase(transactionId);

    expect(sendCount, 1);
    expect(
      await coordinator.readState(transactionId),
      AppleTransactionAnalyticsState.sent,
    );
  });

  test('duas chamadas concorrentes não duplicam a tentativa', () async {
    analyticsConfigured = true;
    final transactionId = _opaqueTransactionId(3);
    final senderStarted = Completer<void>();
    final releaseSender = Completer<void>();
    coordinator = AppleTransactionAnalyticsCoordinator(
      preferencesProvider: SharedPreferences.getInstance,
      isAnalyticsConfigured: () => analyticsConfigured,
      sendTransaction: (_) async {
        sendCount++;
        senderStarted.complete();
        await releaseSender.future;
      },
    );

    final first = coordinator.recordNewPurchase(transactionId);
    final second = coordinator.recordNewPurchase(transactionId);
    await senderStarted.future;
    expect(sendCount, 1);

    releaseSender.complete();
    await Future.wait(<Future<void>>[first, second]);

    expect(sendCount, 1);
    expect(
      await coordinator.readState(transactionId),
      AppleTransactionAnalyticsState.sent,
    );
  });

  test('falha do Analytics conserva pending', () async {
    analyticsConfigured = true;
    final transactionId = _opaqueTransactionId(4);
    coordinator = AppleTransactionAnalyticsCoordinator(
      preferencesProvider: SharedPreferences.getInstance,
      isAnalyticsConfigured: () => analyticsConfigured,
      sendTransaction: (_) async {
        sendCount++;
        throw StateError('falha simulada');
      },
    );

    await coordinator.recordNewPurchase(transactionId);

    expect(sendCount, 1);
    expect(
      await coordinator.readState(transactionId),
      AppleTransactionAnalyticsState.pending,
    );
  });

  test('reprocessamento posterior envia a pendência', () async {
    final transactionId = _opaqueTransactionId(5);
    await coordinator.recordNewPurchase(transactionId);
    analyticsConfigured = true;

    await coordinator.retryPending();

    expect(sendCount, 1);
    expect(
      await coordinator.readState(transactionId),
      AppleTransactionAnalyticsState.sent,
    );
  });

  test('sent persiste após reinicialização e impede reenvio', () async {
    analyticsConfigured = true;
    final transactionId = _opaqueTransactionId(6);
    await coordinator.recordNewPurchase(transactionId);

    final restarted = AppleTransactionAnalyticsCoordinator(
      preferencesProvider: SharedPreferences.getInstance,
      isAnalyticsConfigured: () => analyticsConfigured,
      sendTransaction: (_) async {
        sendCount++;
      },
    );
    await restarted.recordNewPurchase(transactionId);
    await restarted.retryPending();

    expect(sendCount, 1);
    expect(
      await restarted.readState(transactionId),
      AppleTransactionAnalyticsState.sent,
    );
  });

  test('identificador é encaminhado sem transformação', () async {
    analyticsConfigured = true;
    final transactionId = ' ${_opaqueTransactionId(7)} ';
    var receivedOriginalValue = false;
    coordinator = AppleTransactionAnalyticsCoordinator(
      preferencesProvider: SharedPreferences.getInstance,
      isAnalyticsConfigured: () => analyticsConfigured,
      sendTransaction: (received) async {
        receivedOriginalValue = received == transactionId;
      },
    );

    await coordinator.recordNewPurchase(transactionId);

    expect(receivedOriginalValue, isTrue);
  });

  test('armazenamento permanece limitado', () async {
    for (var index = 0;
        index < AppleTransactionAnalyticsCoordinator.maxStoredTransactions + 5;
        index++) {
      await coordinator.recordNewPurchase(_opaqueTransactionId(100 + index));
    }

    expect(
      await coordinator.readStoredCount(),
      AppleTransactionAnalyticsCoordinator.maxStoredTransactions,
    );
  });
}

String _opaqueTransactionId(int suffix) {
  return (9000000000000000 + suffix).toString();
}
