import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';

class PremiumGate {
  static Future<bool> ensureWeeklyPlanningPremium({
    required BuildContext context,
    required PurchaseService? purchaseService,
  }) async {
    if (purchaseService == null || purchaseService.hasPremiumAccess) {
      return true;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallPage(
          purchaseService: purchaseService,
          source: 'weekly_planning_gate',
        ),
      ),
    );

    return purchaseService.hasPremiumAccess;
  }
}
