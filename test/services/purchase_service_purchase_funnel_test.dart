import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/paywall_analytics_context.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('purchase_started ocorre antes do launcher terminar', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    final launcherResult = Completer<bool>();
    var launchCount = 0;
    var startPurchaseCompleted = false;
    final service = await _service(
      analytics: analytics,
      purchaseLauncher: (_) {
        launchCount++;
        return launcherResult.future;
      },
    );

    final startPurchase = service
        .startPurchase(
          productId: PurchaseService.yearlyProductId,
          paywallContext: _paywall,
        )
        .whenComplete(() => startPurchaseCompleted = true);
    await Future<void>.delayed(Duration.zero);

    expect(launchCount, 1);
    expect(startPurchaseCompleted, isFalse);
    expect(
      analytics.events.map((event) => event.name),
      <String>['started'],
    );

    launcherResult.complete(true);
    await startPurchase;
  });

  test('tentativa aceita gera purchase_started uma vez e IDs novos', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    final idGenerator =
        _SequenceIdGenerator(<String>['attempt-1', 'attempt-2']);
    final service = await _service(
      analytics: analytics,
      idGenerator: idGenerator.call,
      purchaseLauncher: (_) async => true,
    );

    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );

    expect(analytics.events.where((event) => event.name == 'started'),
        hasLength(1));
    expect(analytics.events.single.context!.attemptId, 'attempt-1');

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(PurchaseStatus.canceled),
    ]);
    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );

    final starts =
        analytics.events.where((event) => event.name == 'started').toList();
    expect(starts, hasLength(2));
    expect(
      starts.map((event) => event.context!.attemptId),
      <String>['attempt-1', 'attempt-2'],
    );
  });

  test('produto ausente não inicia tentativa StoreKit', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    var launchCount = 0;
    final service = await _service(
      analytics: analytics,
      products: const <String, ProductDetails>{},
      purchaseLauncher: (_) async {
        launchCount++;
        return true;
      },
    );

    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );

    expect(launchCount, 0);
    expect(analytics.events.where((event) => event.name == 'started'), isEmpty);
    expect(analytics.events.where((event) => event.name == 'failed'),
        hasLength(1));
    expect(
      analytics.events.single.failureStage,
      PurchaseFailureStage.productResolution,
    );
    expect(
      analytics.events.single.failureCode,
      PurchaseFailureCode.productNotFound,
    );
  });

  test('reserva tentativa antes de resolver produtos no mesmo frame', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    final productsResult = Completer<Map<String, ProductDetails>>();
    var loadCount = 0;
    var launchCount = 0;
    final service = await _service(
      analytics: analytics,
      products: const <String, ProductDetails>{},
      productDetailsLoader: () {
        loadCount++;
        return productsResult.future;
      },
      purchaseLauncher: (_) async {
        launchCount++;
        return true;
      },
    );

    final first = service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    final second = service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    await Future<void>.delayed(Duration.zero);

    expect(loadCount, 1);
    expect(launchCount, 0);
    expect(analytics.events, isEmpty);

    productsResult.complete(<String, ProductDetails>{
      PurchaseService.yearlyProductId:
          _product(PurchaseService.yearlyProductId),
      PurchaseService.monthlyProductId:
          _product(PurchaseService.monthlyProductId),
    });
    await Future.wait(<Future<void>>[first, second]);

    expect(launchCount, 1);
    expect(
      analytics.events.where((event) => event.name == 'started'),
      hasLength(1),
    );
  });

  test('produto ausente depois do refresh libera retry sem started', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    var loadCount = 0;
    var launchCount = 0;
    final service = await _service(
      analytics: analytics,
      products: const <String, ProductDetails>{},
      productDetailsLoader: () async {
        loadCount++;
        return const <String, ProductDetails>{};
      },
      purchaseLauncher: (_) async {
        launchCount++;
        return true;
      },
    );

    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );

    expect(loadCount, 2);
    expect(launchCount, 0);
    expect(analytics.events.where((event) => event.name == 'started'), isEmpty);
    expect(
      analytics.events.where((event) => event.name == 'failed'),
      hasLength(2),
    );
  });

  test('pending preserva contexto e canceled gera somente cancelamento',
      () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    var completeCount = 0;
    final service = await _service(
      analytics: analytics,
      purchaseLauncher: (_) async => true,
      completePurchase: (_) async {
        completeCount++;
      },
    );

    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    final attemptId = analytics.events.single.context!.attemptId;

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(PurchaseStatus.pending),
    ]);
    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    expect(analytics.events, hasLength(1));

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(PurchaseStatus.canceled),
      _purchase(PurchaseStatus.canceled),
    ]);

    expect(
      analytics.events.map((event) => event.name),
      <String>['started', 'canceled'],
    );
    expect(analytics.events.where((event) => event.name == 'failed'), isEmpty);
    expect(
      analytics.events.last.context!.attemptId,
      attemptId,
    );
    expect(service.isPremium, isFalse);
    expect(completeCount, 0);
  });

  test('error gera somente falha controlada sem mensagem ou stack', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    final service = await _service(
      analytics: analytics,
      purchaseLauncher: (_) async => true,
    );

    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(
        PurchaseStatus.error,
        errorMessage: 'mensagem localizada secreta com recibo',
      ),
    ]);

    expect(analytics.events.where((event) => event.name == 'failed'),
        hasLength(1));
    expect(
        analytics.events.where((event) => event.name == 'canceled'), isEmpty);
    final failure = analytics.events.last;
    expect(failure.failureStage, PurchaseFailureStage.purchaseStream);
    expect(failure.failureCode, PurchaseFailureCode.storeError);
    expect(failure.toString(), isNot(contains('mensagem localizada secreta')));
    expect(failure.toString(), isNot(contains('recibo')));
  });

  test('purchased encerra contexto sem evento customizado de conclusão',
      () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    var completeCount = 0;
    final service = await _service(
      analytics: analytics,
      purchaseLauncher: (_) async => true,
      completePurchase: (_) async {
        completeCount++;
      },
    );

    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(
        PurchaseStatus.purchased,
        pendingCompletePurchase: true,
      ),
    ]);
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(PurchaseStatus.error),
    ]);

    expect(
      analytics.events.map((event) => event.name).toList(growable: false),
      <String>['started'],
    );
    expect(service.isPremium, isTrue);
    expect(completeCount, 1);
  });

  test('restauração não reutiliza contexto da tentativa', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    final service = await _service(
      analytics: analytics,
      purchaseLauncher: (_) async => true,
    );

    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(PurchaseStatus.restored),
    ]);
    expect(
      analytics.events.map((event) => event.name),
      <String>['started'],
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(PurchaseStatus.canceled),
    ]);

    expect(
      analytics.events.map((event) => event.name).toList(growable: false),
      <String>['started', 'canceled'],
    );
    expect(
      analytics.events.last.context,
      same(analytics.events.first.context),
    );
  });

  test('replay sem contexto não inventa identificadores', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    final service = await _service(
      analytics: analytics,
      purchaseLauncher: (_) async => true,
    );

    await service.handlePurchaseUpdatesForTesting(<PurchaseDetails>[
      _purchase(PurchaseStatus.pending),
      _purchase(PurchaseStatus.canceled),
      _purchase(PurchaseStatus.error),
      _purchase(PurchaseStatus.purchased),
    ]);

    expect(analytics.events, isEmpty);
  });

  test('falha geral do purchaseStream consome a tentativa uma vez', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    final service = await _service(
      analytics: analytics,
      purchaseLauncher: (_) async => true,
    );

    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    await service.handlePurchaseStreamFailureForTesting();
    await service.handlePurchaseStreamFailureForTesting();

    expect(analytics.events.where((event) => event.name == 'failed'),
        hasLength(1));
    expect(
      analytics.events.last.failureStage,
      PurchaseFailureStage.purchaseStream,
    );
  });

  test('lançamento rejeitado gera started e falha uma vez', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    final service = await _service(
      analytics: analytics,
      purchaseLauncher: (_) async => false,
    );
    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    await service.handlePurchaseStreamFailureForTesting();

    expect(
      analytics.events.map((event) => event.name),
      <String>['started', 'failed'],
    );
    expect(
      analytics.events.last.failureCode,
      PurchaseFailureCode.launchRejected,
    );
    expect(analytics.events.last.context, same(analytics.events.first.context));
    expect(
        analytics.events.where((event) => event.name == 'canceled'), isEmpty);
    expect(service.isPremium, isFalse);
  });

  test('exceção no lançamento gera started e falha sanitizada uma vez',
      () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    final service = await _service(
      analytics: analytics,
      purchaseLauncher: (_) async {
        throw StateError('texto livre que não pode ir ao Analytics');
      },
    );
    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    await service.handlePurchaseStreamFailureForTesting();

    expect(analytics.events.map((event) => event.name),
        <String>['started', 'failed']);
    expect(
      analytics.events.last.failureCode,
      PurchaseFailureCode.storeError,
    );
    expect(
      analytics.events.last.toString(),
      isNot(contains('texto livre')),
    );
    expect(analytics.events.last.context, same(analytics.events.first.context));
    expect(
        analytics.events.where((event) => event.name == 'canceled'), isEmpty);
    expect(service.isPremium, isFalse);
  });

  test('toques concorrentes não duplicam purchase_started', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    final launcherResult = Completer<bool>();
    var launchCount = 0;
    final service = await _service(
      analytics: analytics,
      purchaseLauncher: (_) {
        launchCount++;
        return launcherResult.future;
      },
    );

    final first = service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    final second = service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );
    await Future<void>.delayed(Duration.zero);

    expect(launchCount, 1);
    expect(
      analytics.events.where((event) => event.name == 'started'),
      hasLength(1),
    );

    launcherResult.complete(true);
    await Future.wait(<Future<void>>[first, second]);
  });

  test('plataforma sem paywall preserva comportamento anterior', () async {
    final analytics = _FakePurchaseFunnelAnalytics();
    var launchCount = 0;
    final service = await _service(
      analytics: analytics,
      paywallEnabled: false,
      purchaseLauncher: (_) async {
        launchCount++;
        return true;
      },
    );

    await service.startPurchase(
      productId: PurchaseService.yearlyProductId,
      paywallContext: _paywall,
    );

    expect(launchCount, 0);
    expect(analytics.events, isEmpty);
    expect(service.hasPremiumAccess, isTrue);
  });
}

final PaywallAnalyticsContext _paywall = PaywallAnalyticsContext.create(
  source: PaywallSource.settings,
  idGenerator: () => 'paywall-fixed',
);

Future<PurchaseService> _service({
  required _FakePurchaseFunnelAnalytics analytics,
  Map<String, ProductDetails>? products,
  Future<bool> Function(ProductDetails productDetails)? purchaseLauncher,
  Future<void> Function(PurchaseDetails purchaseDetails)? completePurchase,
  AnalyticsOpaqueIdGenerator? idGenerator,
  bool paywallEnabled = true,
  Future<Map<String, ProductDetails>> Function()? productDetailsLoader,
}) async {
  final preferences = await SharedPreferences.getInstance();
  return PurchaseService.forTesting(
    preferences: preferences,
    productDetailsById: products ??
        <String, ProductDetails>{
          PurchaseService.yearlyProductId:
              _product(PurchaseService.yearlyProductId),
          PurchaseService.monthlyProductId:
              _product(PurchaseService.monthlyProductId),
        },
    purchaseFunnelAnalytics: analytics,
    analyticsIdGenerator: idGenerator ?? () => 'attempt-fixed',
    purchaseLauncher: purchaseLauncher,
    completePurchase: completePurchase,
    paywallEnabled: paywallEnabled,
    productDetailsLoader: productDetailsLoader,
  );
}

ProductDetails _product(String id) {
  return ProductDetails(
    id: id,
    title: id,
    description: id,
    price: r'$19.99',
    rawPrice: 19.99,
    currencyCode: 'USD',
    currencySymbol: r'$',
  );
}

PurchaseDetails _purchase(
  PurchaseStatus status, {
  String errorMessage = 'erro simulado',
  bool pendingCompletePurchase = false,
}) {
  final purchase = PurchaseDetails(
    purchaseID: 'transaction-id-not-sent-to-funnel',
    productID: PurchaseService.yearlyProductId,
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
      message: errorMessage,
    );
  }
  return purchase;
}

class _SequenceIdGenerator {
  _SequenceIdGenerator(this._values);

  final List<String> _values;
  int _index = 0;

  String call() => _values[_index++];
}

class _FakePurchaseFunnelAnalytics implements PurchaseFunnelAnalytics {
  final List<_FunnelEvent> events = <_FunnelEvent>[];

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
  Future<void> logPurchaseStarted(PurchaseAttemptContext context) async {
    events.add(_FunnelEvent(name: 'started', context: context));
  }

  @override
  Future<void> logPurchaseCanceled(PurchaseAttemptContext context) async {
    events.add(_FunnelEvent(name: 'canceled', context: context));
  }

  @override
  Future<void> logPurchaseFailed({
    required PurchaseAttemptContext context,
    required PurchaseFailureStage failureStage,
    required PurchaseFailureCode failureCode,
  }) async {
    events.add(
      _FunnelEvent(
        name: 'failed',
        context: context,
        failureStage: failureStage,
        failureCode: failureCode,
      ),
    );
  }
}

class _FunnelEvent {
  const _FunnelEvent({
    required this.name,
    this.context,
    this.failureStage,
    this.failureCode,
  });

  final String name;
  final PurchaseAttemptContext? context;
  final PurchaseFailureStage? failureStage;
  final PurchaseFailureCode? failureCode;

  @override
  String toString() {
    return '$name:${context?.attemptId}:'
        '${failureStage?.analyticsValue}:${failureCode?.analyticsValue}';
  }
}
