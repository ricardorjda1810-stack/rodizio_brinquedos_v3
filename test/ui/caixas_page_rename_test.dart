import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/ui/caixas_page.dart';

void main() {
  late AppDatabase db;
  late ToyRepository toyRepository;
  late SettingsRepository settingsRepository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    toyRepository = ToyRepository(db);
    settingsRepository = SettingsRepository(db);
    await toyRepository.ensureSeedData();
    await settingsRepository.load();
  });

  tearDown(() async {
    settingsRepository.dispose();
    await db.close();
  });

  testWidgets('cancelar renomeacao fecha dialogo sem alterar caixa',
      (tester) async {
    await _setIphoneViewport(tester);
    await _pumpCaixasPage(
      tester,
      toyRepository: toyRepository,
      settingsRepository: settingsRepository,
    );

    await _openRenameDialog(tester);
    expect(find.text('Renomear caixa'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Renomear caixa'), findsNothing);

    final box = await _firstBox(db);
    expect(box.name, 'Caixa 1');

    await _disposeWidgetTree(tester);
  });

  testWidgets('salvar renomeacao altera nome e preserva dados da caixa',
      (tester) async {
    final boxBefore = await _firstBox(db);
    await (db.update(db.boxes)..where((box) => box.id.equals(boxBefore.id)))
        .write(
      const BoxesCompanion(
        local: Value('Sala'),
        notes: Value('Notas da caixa'),
        photoPath: Value('/foto/caixa.png'),
      ),
    );
    await toyRepository.addToy(name: 'Carrinho', boxId: boxBefore.id);

    await _setIphoneViewport(tester);
    await _pumpCaixasPage(
      tester,
      toyRepository: toyRepository,
      settingsRepository: settingsRepository,
    );

    await _openRenameDialog(tester);
    await tester.enterText(find.byType(TextField), 'Caixa sensorial');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final renamed = await _firstBox(db);
    final linkedToy = await (db.select(db.toys)
          ..where((toy) => toy.boxId.equals(renamed.id)))
        .getSingle();

    expect(renamed.name, 'Caixa sensorial');
    expect(renamed.local, 'Sala');
    expect(renamed.notes, 'Notas da caixa');
    expect(renamed.photoPath, '/foto/caixa.png');
    expect(linkedToy.name, 'Carrinho');

    await _disposeWidgetTree(tester);
  });

  testWidgets('nome vazio mostra erro e mantem dialogo aberto', (tester) async {
    await _setIphoneViewport(tester);
    await _pumpCaixasPage(
      tester,
      toyRepository: toyRepository,
      settingsRepository: settingsRepository,
    );

    await _openRenameDialog(tester);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Renomear caixa'), findsOneWidget);
    expect(find.text('Informe o nome da caixa.'), findsOneWidget);

    final box = await _firstBox(db);
    expect(box.name, 'Caixa 1');

    await _disposeWidgetTree(tester);
  });
}

Future<void> _setIphoneViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpCaixasPage(
  WidgetTester tester, {
  required ToyRepository toyRepository,
  required SettingsRepository settingsRepository,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: CaixasPage(
        toyRepository: toyRepository,
        settingsRepository: settingsRepository,
        onOpenBrinquedosForBox: (_) {},
        onOpenHomeTab: () {},
        onOpenRoundTab: () {},
        onOpenWeeklyPlanning: () {},
        onOpenToysTab: () {},
        onOpenBoxesTab: () {},
        onOpenSettings: () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openRenameDialog(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Ações da caixa').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Renomear caixa').last);
  await tester.pumpAndSettle();
}

Future<Boxe> _firstBox(AppDatabase db) async {
  final boxes = await (db.select(db.boxes)
        ..orderBy([(box) => OrderingTerm.asc(box.number)]))
      .get();
  return boxes.first;
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}
