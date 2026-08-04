import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/apple_transaction_analytics_coordinator.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('compra nova iOS tenta Analytics antes de completePurchase', () async {
    final transactionId = _opaqueTransactionId(1);
    final order = <String>[];
    var senderMatchedOriginalValue = false;
    late PurchaseService service;
    final coordinator = _coordinator(
      configured: () => true,
      sendTransaction: (received) async {
        senderMatchedOriginalValue = received == transactionId;
        expect(service.isPremium, isTrue);
        order.add('analytics');
      },
    );
    service = await _service(
      coordinator: coordinator,
      isIos: true,
      completePurchase: (_) async {
        expect(service.isPremium, isTrue);
        order.add('complete');
      },
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(
        status: PurchaseStatus.purchased,
        purchaseId: transactionId,
        pendingCompletePurchase: true,
      ),
    ]);

    expect(senderMatchedOriginalValue, isTrue);
    expect(order, <String>['analytics', 'complete']);
    expect(
      await coordinator.readState(transactionId),
      AppleTransactionAnalyticsState.sent,
    );
  });

  test('falha do Analytics não impede Premium nem completePurchase', () async {
    final transactionId = _opaqueTransactionId(2);
    var completeCount = 0;
    final coordinator = _coordinator(
      configured: () => true,
      sendTransaction: (_) async {
        throw StateError('falha simulada');
      },
    );
    final service = await _service(
      coordinator: coordinator,
      isIos: true,
      completePurchase: (_) async {
        completeCount++;
      },
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(
        status: PurchaseStatus.purchased,
        purchaseId: transactionId,
        pendingCompletePurchase: true,
      ),
    ]);

    expect(service.isPremium, isTrue);
    expect(service.errorMessage, isNull);
    expect(completeCount, 1);
    expect(
      await coordinator.readState(transactionId),
      AppleTransactionAnalyticsState.pending,
    );
  });

  test('identificador ausente ou vazio não chama Analytics', () async {
    var sendCount = 0;
    var completeCount = 0;
    final coordinator = _coordinator(
      configured: () => true,
      sendTransaction: (_) async {
        sendCount++;
      },
    );
    final service = await _service(
      coordinator: coordinator,
      isIos: true,
      completePurchase: (_) async {
        completeCount++;
      },
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(
        status: PurchaseStatus.purchased,
        purchaseId: null,
        pendingCompletePurchase: true,
      ),
      _purchase(
        status: PurchaseStatus.purchased,
        purchaseId: ' ',
        pendingCompletePurchase: true,
      ),
    ]);

    expect(sendCount, 0);
    expect(completeCount, 2);
    expect(service.isPremium, isTrue);
  });

  test('restored, pending, error e canceled não chamam logTransaction',
      () async {
    var sendCount = 0;
    final coordinator = _coordinator(
      configured: () => true,
      sendTransaction: (_) async {
        sendCount++;
      },
    );
    final service = await _service(
      coordinator: coordinator,
      isIos: true,
    );

    for (final status in <PurchaseStatus>[
      PurchaseStatus.restored,
      PurchaseStatus.pending,
      PurchaseStatus.error,
      PurchaseStatus.canceled,
    ]) {
      await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
        _purchase(
          status: status,
          purchaseId: _opaqueTransactionId(status.index + 10),
        ),
      ]);
    }

    expect(sendCount, 0);
    expect(service.isPremium, isTrue);
  });

  test('Android não chama logTransaction e preserva entitlement', () async {
    var sendCount = 0;
    var completeCount = 0;
    final coordinator = _coordinator(
      configured: () => true,
      sendTransaction: (_) async {
        sendCount++;
      },
    );
    final service = await _service(
      coordinator: coordinator,
      isIos: false,
      completePurchase: (_) async {
        completeCount++;
      },
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(
        status: PurchaseStatus.purchased,
        purchaseId: _opaqueTransactionId(20),
        pendingCompletePurchase: true,
      ),
    ]);

    expect(sendCount, 0);
    expect(completeCount, 1);
    expect(service.isPremium, isTrue);
  });

  test('produto desconhecido não chama logTransaction', () async {
    var sendCount = 0;
    final coordinator = _coordinator(
      configured: () => true,
      sendTransaction: (_) async {
        sendCount++;
      },
    );
    final service = await _service(
      coordinator: coordinator,
      isIos: true,
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(
        status: PurchaseStatus.purchased,
        purchaseId: _opaqueTransactionId(21),
        productId: 'unknown.product',
      ),
    ]);

    expect(sendCount, 0);
    expect(service.isPremium, isFalse);
  });

  test('contrato analítico e Product IDs permanecem estáveis', () async {
    expect(AppAnalytics.knownEventNames, hasLength(14));
    expect(
      AppAnalytics.knownEventNames,
      contains(AppAnalytics.purchaseCompletedEventName),
    );
    expect(
      AppAnalytics.knownEventNames,
      contains(AppAnalytics.purchaseCanceledEventName),
    );
    expect(
      PurchaseService.monthlyProductId,
      'com.rodiziobrinquedos.premium.monthly',
    );
    expect(
      PurchaseService.yearlyProductId,
      'com.rodiziobrinquedos.premium.yearly',
    );

    final purchaseServiceSource =
        await File('lib/services/purchase_service.dart').readAsString();
    final analyticsSource =
        await File('lib/core/analytics/app_analytics.dart').readAsString();
    expect(purchaseServiceSource, isNot(contains('logPurchaseCompleted')));
    expect(purchaseServiceSource, contains('logPurchaseRestored'));
    expect(analyticsSource, contains('logTransaction'));
    expect(analyticsSource, isNot(contains('logInAppPurchase')));
    expect(
      analyticsSource,
      isNot(contains("logEvent(name: 'in_app_purchase'")),
    );
  });
}

AppleTransactionAnalyticsCoordinator _coordinator({
  required bool Function() configured,
  required Future<void> Function(String transactionId) sendTransaction,
}) {
  return AppleTransactionAnalyticsCoordinator(
    preferencesProvider: SharedPreferences.getInstance,
    isAnalyticsConfigured: configured,
    sendTransaction: sendTransaction,
  );
}

Future<PurchaseService> _service({
  required AppleTransactionAnalyticsCoordinator coordinator,
  required bool isIos,
  Future<void> Function(PurchaseDetails purchaseDetails)? completePurchase,
}) async {
  final preferences = await SharedPreferences.getInstance();
  return PurchaseService.forTesting(
    preferences: preferences,
    appleTransactionAnalyticsCoordinator: coordinator,
    isIosPlatform: isIos,
    completePurchase: completePurchase,
  );
}

PurchaseDetails _purchase({
  required PurchaseStatus status,
  required String? purchaseId,
  String productId = PurchaseService.monthlyProductId,
  bool pendingCompletePurchase = false,
}) {
  final purchase = PurchaseDetails(
    purchaseID: purchaseId,
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: '',
      serverVerificationData: '',
      source: 'test',
    ),
    transactionDate: null,
    status: status,
  );
  purchase.pendingCompletePurchase = pendingCompletePurchase;
  if (status == PurchaseStatus.error) {
    purchase.error = IAPError(
      source: 'test',
      code: 'simulated',
      message: 'falha simulada',
    );
  }
  return purchase;
}

String _opaqueTransactionId(int suffix) {
  return (9000000000000000 + suffix).toString();
}
