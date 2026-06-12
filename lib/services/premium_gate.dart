import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';

class PremiumGate {
  static const String weeklyPlanningTitle = 'Planejamento Semanal é Premium';
  static const String weeklyPlanningMessage =
      'Organize a semana inteira automaticamente, personalize cada dia e economize tempo na rotina dos brinquedos.';
  static const String weeklyPlanningCta = 'Desbloquear Premium';

  static Future<bool> ensureWeeklyPlanningPremium({
    required BuildContext context,
    required PurchaseService? purchaseService,
  }) async {
    if (purchaseService == null || purchaseService.isPremium) {
      return true;
    }

    final shouldOpenPaywall = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(weeklyPlanningTitle),
          content: const Text(weeklyPlanningMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Agora não'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(weeklyPlanningCta),
            ),
          ],
        );
      },
    );

    if (shouldOpenPaywall != true || !context.mounted) {
      return false;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallPage(
          purchaseService: purchaseService,
          source: 'weekly_planning_gate',
        ),
      ),
    );

    return false;
  }
}
