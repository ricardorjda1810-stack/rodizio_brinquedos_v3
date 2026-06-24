import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/features/paywall/paywall_page.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('paywall bloqueante mantém Restaurar compra acessível',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final purchaseService = PurchaseService.forTesting(
      preferences: preferences,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PaywallPage(
          purchaseService: purchaseService,
          source: 'app_trial_expired',
          blocking: true,
        ),
      ),
    );

    expect(find.text('Seu teste grátis terminou'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Restaurar compra'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Restaurar compra'), findsOneWidget);
  });
}
