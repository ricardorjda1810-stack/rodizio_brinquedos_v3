import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_data_loader.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_seed.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const officialCategoryIds = <String>{
    'corpo',
    'maos',
    'imaginacao',
    'comunicacao',
    'exploracao',
  };
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  late AppDatabase db;
  late Directory tempDir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    tempDir = Directory.systemTemp.createTempSync('rodizio_demo_loader_test_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('populate insere 50 brinquedos e rodar de novo nao duplica', () async {
    await DemoDataLoader.populate(db);
    await DemoDataLoader.populate(db);

    final toys = await db.select(db.toys).get();
    final categories = await db.select(db.categoryDefinitions).get();
    final boxes = await db.select(db.boxes).get();
    final weeklyRows = await db.select(db.weeklyPlanningCategorySettings).get();
    final weeklyDays = await db.select(db.weeklyPlanningSettings).get();
    final roundRows = await db.select(db.roundToys).get();

    expect(toys, hasLength(50));
    expect(
        categories.map((category) => category.id).toSet(), officialCategoryIds);
    expect(boxes, hasLength(5));
    expect(weeklyRows, isEmpty);
    expect(weeklyDays, hasLength(7));
    expect(weeklyDays.every((day) => day.useDefault), isTrue);
    expect(roundRows, hasLength(5));

    final counts = <String, int>{};
    for (final toy in toys) {
      counts[toy.categoryId] = (counts[toy.categoryId] ?? 0) + 1;
      expect(toy.photoPath, isNotNull);
      expect(File(toy.photoPath!).existsSync(), isTrue);
    }
    for (final categoryId in officialCategoryIds) {
      expect(counts[categoryId], 10, reason: categoryId);
    }
    for (final box in boxes) {
      expect(box.photoPath, isNotNull);
      expect(File(box.photoPath!).existsSync(), isTrue);
    }
  });

  test('load aplica seed inicial uma vez e respeita exemplos apagados',
      () async {
    await DemoDataLoader.load(db);
    expect(await db.select(db.toys).get(), hasLength(50));

    await db.transaction(() async {
      await db.delete(db.roundToys).go();
      await db.delete(db.rounds).go();
      await db.delete(db.toys).go();
    });

    await DemoDataLoader.load(db);
    expect(await db.select(db.toys).get(), isEmpty);
  });

  test('load repara fotos locais ausentes de exemplos ja aplicados', () async {
    await DemoDataLoader.load(db);

    final stalePath = '${tempDir.path}/container_antigo/foto_ausente.png';
    final staleBoxPath =
        '${tempDir.path}/container_antigo/foto_caixa_ausente.png';
    await (db.update(db.toys)
          ..where(
            (toy) => toy.id.like('${DemoDataLoader.demoToyIdPrefix}%'),
          ))
        .write(ToysCompanion(photoPath: Value(stalePath)));
    await (db.update(db.toys)
          ..where((toy) => toy.id.equals('demo_toy_corpo_bola_macia')))
        .write(
      const ToysCompanion(
        photoPath: Value('assets/demo_toys_v2/corpo_bola_macia.png'),
      ),
    );
    await (db.update(db.boxes)
          ..where(
            (box) => box.id.like('${DemoDataLoader.demoBoxIdPrefix}%'),
          ))
        .write(BoxesCompanion(photoPath: Value(staleBoxPath)));
    await (db.update(db.boxes)..where((box) => box.id.equals('demo_box_sala')))
        .write(
      const BoxesCompanion(
        photoPath: Value('assets/demo_boxes/demo_box_sala.png'),
      ),
    );

    await db.into(db.toys).insert(
          ToysCompanion.insert(
            id: 'real_toy_1',
            categoryId: const Value('corpo'),
            name: 'Brinquedo real',
            createdAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
            photoPath: const Value('/foto/real/do/usuario.png'),
          ),
        );
    await db.into(db.boxes).insert(
          BoxesCompanion.insert(
            id: 'real_box_1',
            number: const Value(42),
            local: const Value('Quarto real'),
            name: const Value('Caixa real'),
            photoPath: const Value('/foto/real/da/caixa.png'),
            createdAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
          ),
        );

    await DemoDataLoader.load(db);

    final toys = await db.select(db.toys).get();
    final boxes = await db.select(db.boxes).get();
    final demoToys =
        toys.where((toy) => DemoDataLoader.isDemoToyId(toy.id)).toList();
    expect(demoToys, hasLength(50));
    for (final toy in demoToys) {
      expect(toy.photoPath, isNotNull);
      expect(toy.photoPath, isNot(stalePath));
      expect(toy.photoPath!, isNot(startsWith('assets/')));
      expect(toy.photoPath!, startsWith(tempDir.path));
      expect(File(toy.photoPath!).existsSync(), isTrue);
    }

    final realToy = toys.singleWhere((toy) => toy.id == 'real_toy_1');
    expect(realToy.photoPath, '/foto/real/do/usuario.png');

    final demoBoxes =
        boxes.where((box) => DemoDataLoader.isDemoBoxId(box.id)).toList();
    expect(demoBoxes, hasLength(DemoSeed.boxes.length));
    for (final box in demoBoxes) {
      expect(box.photoPath, isNotNull);
      expect(box.photoPath, isNot(staleBoxPath));
      expect(box.photoPath!, isNot(startsWith('assets/')));
      expect(box.photoPath!, startsWith(tempDir.path));
      expect(File(box.photoPath!).existsSync(), isTrue);
    }

    final realBox = boxes.singleWhere((box) => box.id == 'real_box_1');
    expect(realBox.photoPath, '/foto/real/da/caixa.png');
  });

  test('removeExamples apaga apenas exemplos e preserva dados reais', () async {
    await DemoDataLoader.restoreExamples(
      db,
      includePlanning: true,
      includeActiveRound: true,
      includeRoundSettings: true,
    );

    await db.into(db.boxes).insert(
          BoxesCompanion.insert(
            id: 'real_box_1',
            number: const Value(42),
            local: const Value('Quarto real'),
            name: const Value('Caixa real'),
            photoPath: const Value('/foto/real/da/caixa.png'),
            createdAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
          ),
        );
    await db.into(db.locationDefinitions).insert(
          LocationDefinitionsCompanion.insert(
            id: 'real_location_1',
            name: 'Quarto real',
          ),
        );
    await db.into(db.toys).insert(
          ToysCompanion.insert(
            id: 'real_toy_1',
            categoryId: const Value('corpo'),
            name: 'Brinquedo real',
            boxId: const Value('real_box_1'),
            locationText: const Value('Quarto real'),
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

    await DemoDataLoader.removeExamples(db);

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

    final boxes = await db.select(db.boxes).get();
    expect(boxes.map((box) => box.id), <String>['real_box_1']);
    expect(boxes.single.photoPath, '/foto/real/da/caixa.png');

    final locations = await db.select(db.locationDefinitions).get();
    expect(
        locations.map((location) => location.id), contains('real_location_1'));
    expect(locations.map((location) => location.name), contains('Quarto real'));

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getBool(DemoDataLoader.examplesRemovedPreferenceKey),
      isTrue,
    );
  });

  test('removeExamples preserva caixa demo usada por brinquedo real', () async {
    await DemoDataLoader.restoreExamples(
      db,
      includePlanning: true,
      includeActiveRound: true,
      includeRoundSettings: true,
    );

    final demoBoxBefore = await (db.select(db.boxes)
          ..where((box) => box.id.equals('demo_box_sala')))
        .getSingle();
    final demoBoxPhotoPath = demoBoxBefore.photoPath;
    expect(demoBoxPhotoPath, isNotNull);
    expect(File(demoBoxPhotoPath!).existsSync(), isTrue);

    await db.into(db.toys).insert(
          ToysCompanion.insert(
            id: 'real_toy_in_demo_box',
            categoryId: const Value('corpo'),
            name: 'Brinquedo real na caixa demo',
            boxId: const Value('demo_box_sala'),
            createdAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
          ),
        );

    await DemoDataLoader.removeExamples(db);

    final toys = await db.select(db.toys).get();
    expect(toys.map((toy) => toy.id), <String>['real_toy_in_demo_box']);

    final boxes = await db.select(db.boxes).get();
    expect(boxes.map((box) => box.id), <String>['demo_box_sala']);
    expect(boxes.single.photoPath, demoBoxPhotoPath);
    expect(File(boxes.single.photoPath!).existsSync(), isTrue);
  });

  test('removeExamples limpa scaffolding demo quando nao ha dados reais',
      () async {
    final toyRepository = ToyRepository(db);
    await toyRepository.ensureSeedData();
    await DemoDataLoader.restoreExamples(
      db,
      includePlanning: true,
      includeActiveRound: true,
      includeRoundSettings: true,
    );

    expect(await db.select(db.toys).get(), hasLength(50));
    expect(await db.select(db.boxes).get(), hasLength(9));
    expect(await db.select(db.locationDefinitions).get(), hasLength(11));
    expect(await db.select(db.roundToys).get(), hasLength(5));
    expect(await db.select(db.weeklyPlanningCategorySettings).get(), isEmpty);

    await DemoDataLoader.removeExamples(db);

    expect(await db.select(db.toys).get(), isEmpty);
    expect(await db.select(db.roundToyChecklistItems).get(), isEmpty);
    expect(await db.select(db.roundToys).get(), isEmpty);
    expect(await db.select(db.rounds).get(), isEmpty);
    expect(await db.select(db.weeklyPlanningCategorySettings).get(), isEmpty);
    expect(await db.select(db.weeklyPlanningSettings).get(), isEmpty);
    expect(await db.select(db.boxes).get(), isEmpty);
    expect(await db.select(db.locationDefinitions).get(), isEmpty);

    await toyRepository.ensureSeedData(includeStarterStorage: false);
    await DemoDataLoader.load(db);

    expect(await db.select(db.toys).get(), isEmpty);
    expect(await db.select(db.boxes).get(), isEmpty);
    expect(await db.select(db.locationDefinitions).get(), isEmpty);

    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    expect(settingsRepository.weeklyPlanningEnabled, isFalse);
    settingsRepository.dispose();
  });

  test('load nao recria exemplos depois de removeExamples', () async {
    await DemoDataLoader.load(db);
    expect(await db.select(db.toys).get(), hasLength(50));

    await DemoDataLoader.removeExamples(db);
    expect(await db.select(db.toys).get(), isEmpty);

    await DemoDataLoader.load(db);
    expect(await db.select(db.toys).get(), isEmpty);
  });

  test('restoreExamples recria 50 brinquedos sem duplicar', () async {
    await DemoDataLoader.restoreExamples(db);
    await DemoDataLoader.restoreExamples(db);

    final toys = await db.select(db.toys).get();
    expect(toys, hasLength(50));
    expect(await DemoDataLoader.countExampleToys(db), 50);

    final counts = <String, int>{};
    for (final toy in toys) {
      counts[toy.categoryId] = (counts[toy.categoryId] ?? 0) + 1;
      expect(DemoDataLoader.isDemoToyId(toy.id), isTrue);
      expect(toy.photoPath, isNotNull);
      expect(File(toy.photoPath!).existsSync(), isTrue);
    }
    for (final categoryId in officialCategoryIds) {
      expect(counts[categoryId], 10, reason: categoryId);
    }
    for (final box in await db.select(db.boxes).get()) {
      expect(DemoDataLoader.isDemoBoxId(box.id), isTrue);
      expect(box.photoPath, isNotNull);
      expect(File(box.photoPath!).existsSync(), isTrue);
    }

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getBool(DemoDataLoader.examplesRemovedPreferenceKey),
      isFalse,
    );
  });

  test('load nao sobrescreve brinquedos reais existentes', () async {
    await db.into(db.toys).insert(
          ToysCompanion.insert(
            id: 'real_toy_1',
            categoryId: const Value('corpo'),
            name: 'Brinquedo real',
            createdAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
          ),
        );

    await DemoDataLoader.load(db);
    await DemoDataLoader.load(db);

    final toys = await db.select(db.toys).get();
    expect(toys, hasLength(1));
    expect(toys.single.id, 'real_toy_1');
    expect(toys.single.name, 'Brinquedo real');
  });
}
