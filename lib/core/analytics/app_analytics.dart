import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AppAnalytics {
  const AppAnalytics._();

  static Future<void> logAppOpen() => _logEvent('app_open');

  static Future<void> logToyCreated({
    required String category,
    required bool hasPhoto,
    required bool hasBox,
  }) {
    return _logEvent(
      'toy_created',
      parameters: <String, Object>{
        'category': _safeValue(category),
        'has_photo': _boolValue(hasPhoto),
        'has_box': _boolValue(hasBox),
      },
    );
  }

  static Future<void> logFirstRoundCreated({
    required int toyCount,
  }) {
    return _logEvent(
      'first_round_created',
      parameters: <String, Object>{
        'toy_count': _safeCount(toyCount),
      },
    );
  }

  static Future<void> logRoundCreated({
    required int toyCount,
    required String source,
  }) {
    return _logEvent(
      'round_created',
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
      'suggestion_opened',
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
      'suggestion_used',
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
      'weekly_planning_opened',
      parameters: <String, Object>{
        'source': _safeValue(source),
      },
    );
  }

  static Future<void> logPaywallViewed({
    required String source,
  }) {
    return _logEvent(
      'paywall_viewed',
      parameters: <String, Object>{
        'source': _safeValue(source),
      },
    );
  }

  static Future<void> logPremiumPlanSelected({
    required String plan,
    required String source,
  }) {
    return _logEvent(
      'premium_plan_selected',
      parameters: <String, Object>{
        'plan': _safeValue(plan),
        'source': _safeValue(source),
      },
    );
  }

  static Future<void> logPurchaseStarted({
    required String plan,
    required String source,
  }) {
    return _logEvent(
      'purchase_started',
      parameters: <String, Object>{
        'plan': _safeValue(plan),
        'source': _safeValue(source),
      },
    );
  }

  static Future<void> logPurchaseCompleted({
    required String plan,
    required String source,
  }) {
    return _logEvent(
      'purchase_completed',
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
      'purchase_restored',
      parameters: <String, Object>{
        'source': _safeValue(source),
      },
    );
  }

  static Future<void> logPurchaseFailed({
    required String plan,
    required String source,
    required String reason,
  }) {
    return _logEvent(
      'purchase_failed',
      parameters: <String, Object>{
        'plan': _safeValue(plan),
        'source': _safeValue(source),
        'reason': _safeValue(reason),
      },
    );
  }

  static Future<void> _logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (error) {
      debugPrint('Analytics event "$name" skipped: $error');
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
