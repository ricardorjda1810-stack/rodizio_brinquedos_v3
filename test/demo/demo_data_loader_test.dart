import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_data_loader.dart';
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
    final roundRows = await db.select(db.roundToys).get();

    expect(toys, hasLength(50));
    expect(
        categories.map((category) => category.id).toSet(), officialCategoryIds);
    expect(boxes, hasLength(5));
    expect(weeklyRows, hasLength(35));
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
}
