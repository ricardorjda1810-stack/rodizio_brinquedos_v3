import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class PremiumGate {
  static const String weeklyPlanningTitle = 'Planejamento Semanal é Premium';
  static const String weeklyPlanningMessage =
      'Organize a semana inteira automaticamente, personalize cada dia e economize tempo na rotina dos brinquedos.';
  static const String weeklyPlanningCta = 'Desbloquear Premium';

  static Future<bool> ensureWeeklyPlanningPremium({
    required BuildContext context,
    required PurchaseService? purchaseService,
  }) async {
    if (purchaseService == null || purchaseService.hasPremiumAccess) {
      return true;
    }

    final shouldOpenPaywall = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isTablet = MediaQuery.sizeOf(dialogContext).shortestSide >= 600;
        if (isTablet) {
          return const _PremiumGateIpadDialog();
        }

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

class _PremiumGateIpadDialog extends StatelessWidget {
  const _PremiumGateIpadDialog();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: UiTokens.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFF0DEC8)),
            boxShadow: UiTokens.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFFF97316),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RODÍZIO PREMIUM',
                          style: UiTokens.textMicro.copyWith(
                            color: const Color(0xFFC2410C),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          PremiumGate.weeklyPlanningTitle,
                          style: textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF25180A),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                PremiumGate.weeklyPlanningMessage,
                style: UiTokens.textBody.copyWith(
                  color: const Color(0xFF6B4F30),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF6D7BA)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_outlined,
                      color: Color(0xFFF97316),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'O Premium libera a visão semanal para preparar os brinquedos com antecedência.',
                        style: UiTokens.textCaption.copyWith(
                          color: const Color(0xFF6B4F30),
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        foregroundColor: const Color(0xFF6B4F30),
                        side: const BorderSide(color: Color(0xFFF0DEC8)),
                      ),
                      child: const Text('Agora não'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(PremiumGate.weeklyPlanningCta),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
