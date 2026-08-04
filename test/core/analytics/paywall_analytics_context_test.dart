import 'package:flutter_test/flutter_test.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/paywall_analytics_context.dart';

void main() {
  test('gerador cria identificadores opacos, curtos e distintos', () {
    final ids = List<String>.generate(
      100,
      (_) => generateAnalyticsOpaqueId(),
      growable: false,
    );

    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(id, hasLength(32));
      expect(id, matches(RegExp(r'^[a-f0-9]+$')));
    }
  });

  test('contextos reutilizam a instância e recebem tentativa independente', () {
    final ids = <String>['paywall-id', 'attempt-id'].iterator;
    String nextId() {
      expect(ids.moveNext(), isTrue);
      return ids.current;
    }

    final paywall = PaywallAnalyticsContext.create(
      source: PaywallSource.settings,
      idGenerator: nextId,
    );
    final attempt = PurchaseAttemptContext.create(
      plan: PremiumPlan.yearly,
      productId: 'product.yearly',
      paywall: paywall,
      idGenerator: nextId,
    );

    expect(paywall.instanceId, 'paywall-id');
    expect(attempt.paywall, same(paywall));
    expect(attempt.attemptId, 'attempt-id');
  });

  test('origens e planos possuem somente valores canônicos do funil', () {
    expect(
      PaywallSource.values
          .map((source) => source.analyticsValue)
          .toList(growable: false),
      <String>[
        'app_trial_expired',
        'weekly_planning_gate',
        'settings',
      ],
    );
    expect(
      PremiumPlan.values
          .map((plan) => plan.analyticsValue)
          .toList(growable: false),
      <String>['monthly', 'yearly'],
    );
  });

  test('identificador inválido ou acima de 36 caracteres é rejeitado', () {
    expect(
      () => PaywallAnalyticsContext.create(
        source: PaywallSource.settings,
        idGenerator: () => 'x' * 37,
      ),
      throwsArgumentError,
    );
    expect(
      () => PaywallAnalyticsContext.create(
        source: PaywallSource.settings,
        idGenerator: () => 'identificador com espaço',
      ),
      throwsArgumentError,
    );
  });
}
