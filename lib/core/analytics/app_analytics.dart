import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/apple_transaction_analytics_coordinator.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/first_round_analytics_coordinator.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/paywall_analytics_context.dart';

class AppAnalytics {
  const AppAnalytics._();

  static const String appOpenEventName = 'app_open';
  static const String toyCreatedEventName = 'toy_created';
  static const String firstRoundCreatedEventName = 'first_round_created';
  static const String roundCreatedEventName = 'round_created';
  static const String suggestionOpenedEventName = 'suggestion_opened';
  static const String suggestionUsedEventName = 'suggestion_used';
  static const String weeklyPlanningOpenedEventName = 'weekly_planning_opened';
  static const String paywallViewedEventName = 'paywall_viewed';
  static const String premiumPlanSelectedEventName = 'premium_plan_selected';
  static const String purchaseStartedEventName = 'purchase_started';
  static const String purchaseCompletedEventName = 'purchase_completed';
  static const String purchaseRestoredEventName = 'purchase_restored';
  static const String purchaseFailedEventName = 'purchase_failed';
  static const String purchaseCanceledEventName = 'purchase_canceled';

  @visibleForTesting
  static const Set<String> knownEventNames = <String>{
    appOpenEventName,
    toyCreatedEventName,
    firstRoundCreatedEventName,
    roundCreatedEventName,
    suggestionOpenedEventName,
    suggestionUsedEventName,
    weeklyPlanningOpenedEventName,
    paywallViewedEventName,
    premiumPlanSelectedEventName,
    purchaseStartedEventName,
    purchaseCompletedEventName,
    purchaseRestoredEventName,
    purchaseFailedEventName,
    purchaseCanceledEventName,
  };

  static bool _environmentConfigured = false;

  static final FirstRoundAnalyticsCoordinator firstRoundCreatedCoordinator =
      FirstRoundAnalyticsCoordinator.withSharedPreferences(
    isAnalyticsConfigured: () => isEnvironmentConfigured,
    sendEvent: ({
      required int toyCount,
      required RoundCreationSource source,
    }) {
      return logFirstRoundCreated(
        toyCount: toyCount,
        source: source,
      );
    },
  );

  static final AppleTransactionAnalyticsCoordinator
      appleTransactionAnalyticsCoordinator =
      AppleTransactionAnalyticsCoordinator.withSharedPreferences(
    isAnalyticsConfigured: () =>
        isEnvironmentConfigured &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.iOS,
    sendTransaction: FirebaseAnalytics.instance.logTransaction,
  );

  static bool get isEnvironmentConfigured => _environmentConfigured;

  static Future<void> configureEnvironment({
    required String environment,
  }) async {
    _environmentConfigured = false;
    if (environment != 'staging' && environment != 'production') {
      debugPrint('Analytics environment configuration skipped.');
      return;
    }

    try {
      await FirebaseAnalytics.instance.setDefaultEventParameters(
        <String, Object>{
          'app_environment': environment,
        },
      );
      _environmentConfigured = true;
      try {
        await firstRoundCreatedCoordinator.retryPending();
      } catch (error) {
        debugPrint('Pending first round Analytics retry skipped: $error');
      }
      try {
        await appleTransactionAnalyticsCoordinator.retryPending();
      } catch (_) {
        debugPrint('Pending Apple transaction Analytics retry skipped.');
      }
    } catch (_) {
      debugPrint('Analytics environment configuration skipped.');
    }
  }

  static Future<void> logAppOpen() => _logEvent(appOpenEventName);

  static Future<void> logToyCreated({
    required String category,
    required bool hasPhoto,
    required bool hasBox,
  }) {
    return _logEvent(
      toyCreatedEventName,
      parameters: <String, Object>{
        'category': _safeValue(category),
        'has_photo': _boolValue(hasPhoto),
        'has_box': _boolValue(hasBox),
      },
    );
  }

  static Future<bool> logFirstRoundCreated({
    required int toyCount,
    required RoundCreationSource source,
  }) {
    return _tryLogEvent(
      firstRoundCreatedEventName,
      parameters: <String, Object>{
        'toy_count': _safeCount(toyCount),
        'round_source': source.analyticsValue,
      },
    );
  }

  static Future<void> logRoundCreated({
    required int toyCount,
    required String source,
  }) {
    return _logEvent(
      roundCreatedEventName,
      parameters: <String, Object>{
        'toy_count': _safeCount(toyCount),
        'source': _safeValue(source),
      },
    );
  }

  static Future<void> logSuggestionOpened({
    required String source,
  }) {
    return _logEvent(
      suggestionOpenedEventName,
      parameters: <String, Object>{
        'source': _safeValue(source),
      },
    );
  }

  static Future<void> logSuggestionUsed({
    required int toyCount,
    required String source,
  }) {
    return _logEvent(
      suggestionUsedEventName,
      parameters: <String, Object>{
        'toy_count': _safeCount(toyCount),
        'source': _safeValue(source),
      },
    );
  }

  static Future<void> logWeeklyPlanningOpened({
    required String source,
  }) {
    return _logEvent(
      weeklyPlanningOpenedEventName,
      parameters: <String, Object>{
        'source': _safeValue(source),
      },
    );
  }

  static Future<void> logPaywallViewed({
    required PaywallAnalyticsContext context,
  }) {
    return _logEvent(
      paywallViewedEventName,
      parameters: <String, Object>{
        'paywall_source': context.source.analyticsValue,
        'paywall_instance_id': context.instanceId,
      },
    );
  }

  static Future<void> logPremiumPlanSelected({
    required PaywallAnalyticsContext context,
    required PremiumPlan plan,
    required String productId,
    required PlanSelectionMethod selectionMethod,
  }) {
    return _logEvent(
      premiumPlanSelectedEventName,
      parameters: <String, Object>{
        'plan': plan.analyticsValue,
        'product_id': productId,
        'selection_method': selectionMethod.analyticsValue,
        'paywall_source': context.source.analyticsValue,
        'paywall_instance_id': context.instanceId,
      },
    );
  }

  static Future<void> logPurchaseStarted({
    required PurchaseAttemptContext context,
  }) {
    return _logEvent(
      purchaseStartedEventName,
      parameters: _purchaseAttemptParameters(context),
    );
  }

  static Future<void> logPurchaseCompleted({
    required String plan,
    required String source,
  }) {
    // Retired for new data; historical events remain quarantined.
    return _logEvent(
      purchaseCompletedEventName,
      parameters: <String, Object>{
        'plan': _safeValue(plan),
        'source': _safeValue(source),
      },
    );
  }

  static Future<void> logPurchaseRestored({
    required String source,
  }) {
    return _logEvent(
      purchaseRestoredEventName,
      parameters: <String, Object>{
        'source': _safeValue(source),
      },
    );
  }

  static Future<void> logPurchaseFailed({
    required PurchaseAttemptContext context,
    required PurchaseFailureStage failureStage,
    required PurchaseFailureCode failureCode,
  }) {
    return _logEvent(
      purchaseFailedEventName,
      parameters: <String, Object>{
        ..._purchaseAttemptParameters(context),
        'failure_stage': failureStage.analyticsValue,
        'failure_code': failureCode.analyticsValue,
      },
    );
  }

  static Future<void> logPurchaseCanceled({
    required PurchaseAttemptContext context,
  }) {
    return _logEvent(
      purchaseCanceledEventName,
      parameters: _purchaseAttemptParameters(context),
    );
  }

  static Map<String, Object> _purchaseAttemptParameters(
    PurchaseAttemptContext context,
  ) {
    return <String, Object>{
      'plan': context.plan.analyticsValue,
      'product_id': context.productId,
      'paywall_source': context.paywall.source.analyticsValue,
      'paywall_instance_id': context.paywall.instanceId,
      'purchase_attempt_id': context.attemptId,
    };
  }

  static Future<void> _logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await _tryLogEvent(name, parameters: parameters);
  }

  static Future<bool> _tryLogEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    if (!_environmentConfigured) {
      debugPrint(
          'Analytics event "$name" skipped: environment not configured.');
      return false;
    }

    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
      return true;
    } catch (error) {
      debugPrint('Analytics event "$name" skipped: $error');
      return false;
    }
  }

  static int _boolValue(bool value) => value ? 1 : 0;

  static int _safeCount(int value) => value < 0 ? 0 : value;

  static String _safeValue(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (normalized.isEmpty) return 'unknown';
    return normalized.length > 40 ? normalized.substring(0, 40) : normalized;
  }
}

class FirebasePurchaseFunnelAnalytics implements PurchaseFunnelAnalytics {
  const FirebasePurchaseFunnelAnalytics();

  @override
  Future<void> logPaywallViewed(PaywallAnalyticsContext context) {
    return AppAnalytics.logPaywallViewed(context: context);
  }

  @override
  Future<void> logPremiumPlanSelected({
    required PaywallAnalyticsContext context,
    required PremiumPlan plan,
    required String productId,
    required PlanSelectionMethod selectionMethod,
  }) {
    return AppAnalytics.logPremiumPlanSelected(
      context: context,
      plan: plan,
      productId: productId,
      selectionMethod: selectionMethod,
    );
  }

  @override
  Future<void> logPurchaseStarted(PurchaseAttemptContext context) {
    return AppAnalytics.logPurchaseStarted(context: context);
  }

  @override
  Future<void> logPurchaseCanceled(PurchaseAttemptContext context) {
    return AppAnalytics.logPurchaseCanceled(context: context);
  }

  @override
  Future<void> logPurchaseFailed({
    required PurchaseAttemptContext context,
    required PurchaseFailureStage failureStage,
    required PurchaseFailureCode failureCode,
  }) {
    return AppAnalytics.logPurchaseFailed(
      context: context,
      failureStage: failureStage,
      failureCode: failureCode,
    );
  }
}
