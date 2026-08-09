import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/services/app_version_info.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'cartão Sobre mostra a versão pt-BR e consulta o loader uma vez',
    (tester) async {
      final harness = await _SettingsHarness.create();
      addTearDown(harness.dispose);
      _useTabletViewport(tester);

      var loaderCalls = 0;
      Future<AppVersionInfo> loader() async {
        loaderCalls++;
        return AppVersionInfo(version: '1.0.11', buildNumber: '121');
      }

      await tester.pumpWidget(
        _buildSettingsApp(
          locale: const Locale('pt', 'BR'),
          harness: harness,
          loader: loader,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sobre'), findsOneWidget);
      expect(find.text('Versão 1.0.11 (121)'), findsOneWidget);
      expect(find.text('Política de privacidade'), findsOneWidget);
      expect(find.text('Termos de uso'), findsOneWidget);
      expect(loaderCalls, 1);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _buildSettingsApp(
          locale: const Locale('pt', 'BR'),
          harness: harness,
          loader: loader,
        ),
      );
      await tester.pumpAndSettle();

      expect(loaderCalls, 1);
      expect(find.text('Versão 1.0.11 (121)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cartão Sobre mostra en-US e aceita build futuro',
      (tester) async {
    final harness = await _SettingsHarness.create();
    addTearDown(harness.dispose);
    _useTabletViewport(tester);

    await tester.pumpWidget(
      _buildSettingsApp(
        locale: const Locale('en', 'US'),
        harness: harness,
        loader: () async =>
            AppVersionInfo(version: '1.0.11', buildNumber: '122'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Version 1.0.11 (122)'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Use'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('fonte funcional não contém a versão antiga', () {
    final source = File('lib/ui/settings_page.dart').readAsStringSync();

    expect(source, isNot(contains('1.0.5+93')));
  });
}

Widget _buildSettingsApp({
  required Locale locale,
  required _SettingsHarness harness,
  required AppVersionInfoLoader loader,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: SettingsPage(
      settingsRepository: harness.settingsRepository,
      toyRepository: harness.toyRepository,
      purchaseService: harness.purchaseService,
      appVersionInfoLoader: loader,
    ),
  );
}

void _useTabletViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1024, 1366);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _SettingsHarness {
  const _SettingsHarness({
    required this.settingsRepository,
    required this.toyRepository,
    required this.purchaseService,
  });

  final SettingsRepository settingsRepository;
  final ToyRepository toyRepository;
  final PurchaseService purchaseService;

  static Future<_SettingsHarness> create() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    return _SettingsHarness(
      settingsRepository: SettingsRepository(),
      toyRepository: ToyRepository(null),
      purchaseService: PurchaseService.forTesting(
        preferences: preferences,
        paywallEnabled: false,
      ),
    );
  }

  void dispose() {
    settingsRepository.dispose();
    purchaseService.dispose();
  }
}
