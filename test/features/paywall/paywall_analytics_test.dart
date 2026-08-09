import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/paywall_analytics_context.dart';
import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'visualização e seleção anual padrão ocorrem uma vez por instância',
    (tester) async {
      await _setIphoneViewport(tester);
      final analytics = _FakePurchaseFunnelAnalytics();
      final service = await _serviceWithProducts();

      await _pumpPaywall(
        tester,
        purchaseService: service,
        analytics: analytics,
        idGenerator: () => 'paywall-instance-1',
      );

      expect(analytics.events.where((event) => event.name == 'viewed'),
          hasLength(1));
      final defaultSelections = analytics.events.where(
        (event) =>
            event.name == 'selected' &&
            event.selectionMethod == PlanSelectionMethod.defaultSelection,
      );
      expect(defaultSelections, hasLength(1));
      expect(defaultSelections.single.plan, PremiumPlan.yearly);
      expect(
        defaultSelections.single.productId,
        PurchaseService.yearlyProductId,
      );
      expect(defaultSelections.single.context!.source, PaywallSource.settings);
      expect(
          defaultSelections.single.context!.instanceId, 'paywall-instance-1');

      service.notifyListeners();
      await tester.pump();
      await tester.pump();

      expect(analytics.events.where((event) => event.name == 'viewed'),
          hasLength(1));
      expect(
        analytics.events.where(
          (event) =>
              event.name == 'selected' &&
              event.selectionMethod == PlanSelectionMethod.defaultSelection,
        ),
        hasLength(1),
      );
    },
  );

  testWidgets(
    'seleção manual só registra mudança real de Product ID',
    (tester) async {
      await _setIphoneViewport(tester);
      final analytics = _FakePurchaseFunnelAnalytics();
      final service = await _serviceWithProducts();

      await _pumpPaywall(
        tester,
        purchaseService: service,
        analytics: analytics,
        idGenerator: () => 'paywall-instance-2',
      );

      await tester.scrollUntilVisible(
        find.text('Plano mensal'),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Plano mensal'));
      await tester.pump();
      await tester.tap(find.text('Plano mensal'));
      await tester.pump();

      final manualSelections = analytics.events.where(
        (event) =>
            event.name == 'selected' &&
            event.selectionMethod == PlanSelectionMethod.manual,
      );
      expect(manualSelections, hasLength(1));
      expect(manualSelections.single.plan, PremiumPlan.monthly);
      expect(
        manualSelections.single.productId,
        PurchaseService.monthlyProductId,
      );
      expect(
        manualSelections.single.context!.instanceId,
        'paywall-instance-2',
      );
    },
  );

  testWidgets('cada nova tela recebe novo paywall_instance_id', (tester) async {
    await _setIphoneViewport(tester);
    final analytics = _FakePurchaseFunnelAnalytics();
    final service = await _serviceWithProducts();
    final ids = <String>['paywall-a', 'paywall-b'].iterator;
    String nextId() {
      expect(ids.moveNext(), isTrue);
      return ids.current;
    }

    await _pumpPaywall(
      tester,
      key: const ValueKey<String>('first-paywall'),
      purchaseService: service,
      analytics: analytics,
      idGenerator: nextId,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpPaywall(
      tester,
      key: const ValueKey<String>('second-paywall'),
      purchaseService: service,
      analytics: analytics,
      idGenerator: nextId,
    );

    final idsSeen = analytics.events
        .where((event) => event.name == 'viewed')
        .map((event) => event.context!.instanceId)
        .toList(growable: false);
    expect(idsSeen, <String>['paywall-a', 'paywall-b']);
  });
}

Future<PurchaseService> _serviceWithProducts() async {
  final preferences = await SharedPreferences.getInstance();
  return PurchaseService.forTesting(
    preferences: preferences,
    productDetailsById: <String, ProductDetails>{
      PurchaseService.yearlyProductId: _product(
        PurchaseService.yearlyProductId,
      ),
      PurchaseService.monthlyProductId: _product(
        PurchaseService.monthlyProductId,
      ),
    },
  );
}

ProductDetails _product(String id) {
  return ProductDetails(
    id: id,
    title: id,
    description: id,
    price: r'$1.99',
    rawPrice: 1.99,
    currencyCode: 'USD',
    currencySymbol: r'$',
  );
}

Future<void> _pumpPaywall(
  WidgetTester tester, {
  Key? key,
  required PurchaseService purchaseService,
  required PurchaseFunnelAnalytics analytics,
  required AnalyticsOpaqueIdGenerator idGenerator,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: PaywallPage(
        key: key,
        purchaseService: purchaseService,
        source: PaywallSource.settings,
        purchaseFunnelAnalytics: analytics,
        analyticsIdGenerator: idGenerator,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _setIphoneViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _FakePurchaseFunnelAnalytics implements PurchaseFunnelAnalytics {
  final List<_FunnelEvent> events = <_FunnelEvent>[];

  @override
  Future<void> logPaywallViewed(PaywallAnalyticsContext context) async {
    events.add(_FunnelEvent(name: 'viewed', context: context));
  }

  @override
  Future<void> logPremiumPlanSelected({
    required PaywallAnalyticsContext context,
    required PremiumPlan plan,
    required String productId,
    required PlanSelectionMethod selectionMethod,
  }) async {
    events.add(
      _FunnelEvent(
        name: 'selected',
        context: context,
        plan: plan,
        productId: productId,
        selectionMethod: selectionMethod,
      ),
    );
  }

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

class _FunnelEvent {
  const _FunnelEvent({
    required this.name,
    this.context,
    this.plan,
    this.productId,
    this.selectionMethod,
  });

  final String name;
  final PaywallAnalyticsContext? context;
  final PremiumPlan? plan;
  final String? productId;
  final PlanSelectionMethod? selectionMethod;
}
