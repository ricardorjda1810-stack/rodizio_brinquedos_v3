import 'dart:math';

typedef AnalyticsOpaqueIdGenerator = String Function();

String generateAnalyticsOpaqueId() {
  final random = Random.secure();
  return List<String>.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    growable: false,
  ).join();
}

enum PaywallSource {
  appTrialExpired('app_trial_expired'),
  weeklyPlanningGate('weekly_planning_gate'),
  settings('settings');

  const PaywallSource(this.analyticsValue);

  final String analyticsValue;
}

enum PremiumPlan {
  monthly('monthly'),
  yearly('yearly');

  const PremiumPlan(this.analyticsValue);

  final String analyticsValue;
}

enum PlanSelectionMethod {
  defaultSelection('default'),
  manual('manual');

  const PlanSelectionMethod(this.analyticsValue);

  final String analyticsValue;
}

enum PurchaseFailureStage {
  productResolution('product_resolution'),
  purchaseLaunch('purchase_launch'),
  purchaseStream('purchase_stream');

  const PurchaseFailureStage(this.analyticsValue);

  final String analyticsValue;
}

enum PurchaseFailureCode {
  storeUnavailable('store_unavailable'),
  productNotFound('product_not_found'),
  launchRejected('launch_rejected'),
  storeError('store_error'),
  unknown('unknown');

  const PurchaseFailureCode(this.analyticsValue);

  final String analyticsValue;
}

class PaywallAnalyticsContext {
  const PaywallAnalyticsContext._({
    required this.source,
    required this.instanceId,
  });

  factory PaywallAnalyticsContext.create({
    required PaywallSource source,
    AnalyticsOpaqueIdGenerator? idGenerator,
  }) {
    return PaywallAnalyticsContext._(
      source: source,
      instanceId: _validatedOpaqueId(
        (idGenerator ?? generateAnalyticsOpaqueId)(),
        fieldName: 'paywall_instance_id',
      ),
    );
  }

  final PaywallSource source;
  final String instanceId;
}

class PurchaseAttemptContext {
  const PurchaseAttemptContext._({
    required this.plan,
    required this.productId,
    required this.paywall,
    required this.attemptId,
  });

  factory PurchaseAttemptContext.create({
    required PremiumPlan plan,
    required String productId,
    required PaywallAnalyticsContext paywall,
    AnalyticsOpaqueIdGenerator? idGenerator,
  }) {
    return PurchaseAttemptContext._(
      plan: plan,
      productId: productId,
      paywall: paywall,
      attemptId: _validatedOpaqueId(
        (idGenerator ?? generateAnalyticsOpaqueId)(),
        fieldName: 'purchase_attempt_id',
      ),
    );
  }

  final PremiumPlan plan;
  final String productId;
  final PaywallAnalyticsContext paywall;
  final String attemptId;
}

abstract interface class PurchaseFunnelAnalytics {
  Future<void> logPaywallViewed(PaywallAnalyticsContext context);

  Future<void> logPremiumPlanSelected({
    required PaywallAnalyticsContext context,
    required PremiumPlan plan,
    required String productId,
    required PlanSelectionMethod selectionMethod,
  });

  Future<void> logPurchaseStarted(PurchaseAttemptContext context);

  Future<void> logPurchaseCanceled(PurchaseAttemptContext context);

  Future<void> logPurchaseFailed({
    required PurchaseAttemptContext context,
    required PurchaseFailureStage failureStage,
    required PurchaseFailureCode failureCode,
  });
}

String _validatedOpaqueId(
  String value, {
  required String fieldName,
}) {
  if (value.isEmpty ||
      value.length > 36 ||
      !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value)) {
    throw ArgumentError.value(value, fieldName, 'Invalid opaque identifier.');
  }
  return value;
}
