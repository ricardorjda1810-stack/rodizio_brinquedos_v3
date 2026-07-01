import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_data_loader.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  late AppDatabase db;
  late Directory tempDir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    tempDir =
        Directory.systemTemp.createTempSync('rodizio_settings_demo_test_');

    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });
  });

  tearDown(() async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(pathProviderChannel, null);
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets(
    'Configurações remove exemplos e preserva brinquedo real',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final preferences = await SharedPreferences.getInstance();
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      final PurchaseService purchaseService;
      try {
        purchaseService = PurchaseService.forTesting(
          preferences: preferences,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
      addTearDown(purchaseService.dispose);

      final settingsRepository = SettingsRepository(db);
      addTearDown(settingsRepository.dispose);
      await tester.runAsync(() async {
        await DemoDataLoader.restoreExamples(
          db,
          includePlanning: true,
          includeActiveRound: true,
          includeRoundSettings: true,
        );
        await _insertRealToyMixedWithDemoRound(db);
        await settingsRepository.load();
      });
      final toyRepository = _SettingsToyRepository(db);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPage(
            settingsRepository: settingsRepository,
            toyRepository: toyRepository,
            purchaseService: purchaseService,
          ),
        ),
      );
      await _pumpFrames(tester);

      expect(find.text('Dados de demonstração'), findsOneWidget);
      expect(
        find.text(
          'Apaga apenas os brinquedos de demonstração. Seus brinquedos cadastrados não serão apagados.',
        ),
        findsOneWidget,
      );

      final removeButton = find.text('Remover brinquedos de exemplo');
      await tester.scrollUntilVisible(
        removeButton,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(removeButton);
      await _pumpFrames(tester);

      expect(find.text('Remover exemplos?'), findsOneWidget);
      expect(
        find.text(
          'Isso vai apagar apenas os brinquedos de exemplo usados para demonstração. Seus brinquedos cadastrados manualmente serão preservados.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Remover exemplos'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await _pumpFrames(tester, frames: 6);

      expect(find.text('Brinquedos de exemplo removidos.'), findsOneWidget);
      expect(find.text('Configurações'), findsWidgets);

      final toys = await db.select(db.toys).get();
      expect(toys.map((toy) => toy.id), <String>['real_toy_1']);
      expect(toys.single.name, 'Brinquedo real');

      final roundToys = await db.select(db.roundToys).get();
      expect(roundToys, hasLength(1));
      expect(roundToys.single.roundId, 'real_round');
      expect(roundToys.single.toyId, 'real_toy_1');

      final rounds = await db.select(db.rounds).get();
      expect(rounds.map((round) => round.id), <String>['real_round']);

      final checklistRows = await db.select(db.roundToyChecklistItems).get();
      expect(checklistRows, hasLength(1));
      expect(checklistRows.single.toyId, 'real_toy_1');

      final weeklyRows = await db.select(db.weeklyPlanningSettings).get();
      expect(weeklyRows, hasLength(7));
      expect(await DemoDataLoader.countExampleToys(db), 0);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}

Future<void> _pumpFrames(
  WidgetTester tester, {
  int frames = 3,
}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _SettingsToyRepository extends ToyRepository {
  _SettingsToyRepository(super.db);

  @override
  Stream<Map<String, int>> watchAvailableToyCountByCategory() {
    return Stream<Map<String, int>>.value(const <String, int>{'corpo': 1});
  }

  @override
  Stream<List<RoundCategorySettingRow>> watchRoundCategorySettings() {
    return Stream<List<RoundCategorySettingRow>>.value(
      const <RoundCategorySettingRow>[
        RoundCategorySettingRow(
          category: CategoryDefinition(
            id: 'corpo',
            name: 'Corpo e Respiração',
            sortOrder: 1,
            isDefault: true,
            isActive: true,
          ),
          isIncluded: true,
          quota: 1,
        ),
      ],
    );
  }
}

Future<void> _insertRealToyMixedWithDemoRound(AppDatabase db) async {
  await db.into(db.toys).insert(
        ToysCompanion.insert(
          id: 'real_toy_1',
          categoryId: const Value('corpo'),
          name: 'Brinquedo real',
          createdAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
        ),
      );
  await db.into(db.rounds).insert(
        RoundsCompanion.insert(
          id: 'real_round',
          startAt: DateTime(2026, 1, 2).millisecondsSinceEpoch,
        ),
      );
  await db.into(db.roundToys).insert(
        RoundToysCompanion.insert(
          roundId: 'real_round',
          toyId: 'real_toy_1',
          position: 0,
        ),
      );
  await db.into(db.roundToys).insert(
        RoundToysCompanion.insert(
          roundId: 'real_round',
          toyId: 'demo_toy_corpo_bola_macia',
          position: 1,
        ),
      );
  await db.into(db.roundToyChecklistItems).insert(
        RoundToyChecklistItemsCompanion.insert(
          dateKey: '2026-01-02',
          toyId: 'demo_toy_corpo_bola_macia',
          collected: const Value(true),
          updatedAt: DateTime(2026, 1, 2).millisecondsSinceEpoch,
        ),
      );
  await db.into(db.roundToyChecklistItems).insert(
        RoundToyChecklistItemsCompanion.insert(
          dateKey: '2026-01-02',
          toyId: 'real_toy_1',
          collected: const Value(true),
          updatedAt: DateTime(2026, 1, 2).millisecondsSinceEpoch,
        ),
      );
}
