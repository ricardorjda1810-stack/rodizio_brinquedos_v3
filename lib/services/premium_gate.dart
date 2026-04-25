import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';

class PremiumGate {
  static const String blockedActionMessage =
      'Para continuar organizando os brinquedos, ative o Premium.';

  static Future<bool> ensurePremium({
    required BuildContext context,
    required PurchaseService? purchaseService,
  }) async {
    if (purchaseService == null || purchaseService.isPremium) {
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(blockedActionMessage)),
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallPage(purchaseService: purchaseService),
      ),
    );

    return false;
  }
}
