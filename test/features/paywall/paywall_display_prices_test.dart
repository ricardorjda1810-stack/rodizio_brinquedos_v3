import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/features/paywall/paywall_display_prices.dart';

void main() {
  test('precos visuais do paywall usam real brasileiro', () {
    expect(paywallYearlyDisplayPrice, 'R\$ 99,90/ano');
    expect(paywallYearlyMonthlyEquivalent, 'equivalente a R\$ 8,32/m\u00EAs');
    expect(paywallMonthlyDisplayPrice, 'R\$ 14,90/m\u00EAs');
  });

  test('precos visuais do paywall nao usam dolar', () {
    expect(paywallYearlyDisplayPrice, isNot(contains(r'$14.99')));
    expect(paywallMonthlyDisplayPrice, isNot(contains(r'$1.99')));
  });
}
