import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AppAnalytics {
  const AppAnalytics._();

  static Future<void> logAppOpen() => _logEvent('app_open');

  static Future<void> logFirstRoundCreated() =>
      _logEvent('first_round_created');

  static Future<void> logPaywallViewed() => _logEvent('paywall_viewed');

  static Future<void> logPurchaseStarted() => _logEvent('purchase_started');

  static Future<void> logPurchaseCompleted() => _logEvent('purchase_completed');

  static Future<void> _logEvent(String name) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: name);
    } catch (error) {
      debugPrint('Analytics event "$name" skipped: $error');
    }
  }
}
