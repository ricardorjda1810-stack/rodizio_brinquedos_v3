import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/ui/categories_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/locations_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/app_theme.dart';

void main() {
  late AppDatabase db;
  late ToyRepository toyRepository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    toyRepository = ToyRepository(db);
    await toyRepository.ensureSeedData();
  });

  tearDown(() async {
    await db.close();
  });

  for (final testCase in const [
    (
      locale: Locale('pt', 'BR'),
      title: 'Gerenciar categorias',
      section: 'Categorias do catálogo',
      action: 'Nova categoria',
      dataLabel: 'Corpo e Respiração',
      forbidden: 'Manage categories',
    ),
    (
      locale: Locale('en', 'US'),
      title: 'Manage categories',
      section: 'Catalog categories',
      action: 'New category',
      dataLabel: 'Body and Breathing',
      forbidden: 'Gerenciar categorias',
    ),
  ]) {
    testWidgets('categorias usa ${testCase.locale.toLanguageTag()}', (
      tester,
    ) async {
      await _pumpManagePage(
        tester,
        locale: testCase.locale,
        child: CategoriesManagePage(toyRepository: toyRepository),
      );

      expect(find.text(testCase.title), findsOneWidget);
      expect(find.text(testCase.section), findsOneWidget);
      expect(find.text(testCase.action), findsWidgets);
      expect(find.text(testCase.dataLabel), findsOneWidget);
      expect(find.text(testCase.forbidden), findsNothing);
      expect(tester.takeException(), isNull);
      await _disposeWidgetTree(tester);
    });
  }

  for (final testCase in const [
    (
      locale: Locale('pt', 'BR'),
      title: 'Gerenciar locais',
      section: 'Locais da casa',
      action: 'Novo local',
      dataLabel: 'Sala',
      forbidden: 'Manage locations',
    ),
    (
      locale: Locale('en', 'US'),
      title: 'Manage locations',
      section: 'Home locations',
      action: 'New location',
      dataLabel: 'Living room',
      forbidden: 'Gerenciar locais',
    ),
  ]) {
    testWidgets('locais usa ${testCase.locale.toLanguageTag()}', (
      tester,
    ) async {
      await _pumpManagePage(
        tester,
        locale: testCase.locale,
        child: LocationsManagePage(toyRepository: toyRepository),
      );

      expect(find.text(testCase.title), findsOneWidget);
      expect(find.text(testCase.section), findsOneWidget);
      expect(find.text(testCase.action), findsWidgets);
      expect(find.text(testCase.dataLabel), findsOneWidget);
      expect(find.text(testCase.forbidden), findsNothing);
      expect(tester.takeException(), isNull);
      await _disposeWidgetTree(tester);
    });
  }
}

Future<void> _pumpManagePage(
  WidgetTester tester, {
  required Locale locale,
  required Widget child,
}) async {
  await tester.binding.setSurfaceSize(const Size(1024, 1366));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(isTablet: true),
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}
