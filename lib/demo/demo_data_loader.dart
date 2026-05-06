import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_seed.dart';

class DemoDataLoader {
  static const _isDemo = bool.fromEnvironment('DEMO_MODE');
  static const _demoToyPhotosDirName = 'demo_toy_photos';

  static Future<void> load(AppDatabase db) async {
    if (!_isDemo) return;

    // ignore: avoid_print
    print('[DEMO] DemoDataLoader.load started');
    final toysCount =
        await db.select(db.toys).get().then((toys) => toys.length);
    // ignore: avoid_print
    print('[DEMO] toys count before seed = $toysCount');

    await _insertData(db);
    // ignore: avoid_print
    print('[DEMO] seed completed');
  }

  static Future<void> _insertData(AppDatabase db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      await _clearDemoState(db);
      await _insertCategories(db);
      await _insertLocations(db);
      await _insertBoxes(db, now);
      await _insertToys(db, now);
      await _insertWeeklyPlanning(db);
      await _insertActiveRound(db, now);
    });
  }

  static Future<void> _clearDemoState(AppDatabase db) async {
    if (!_isDemo) return;

    await db.delete(db.roundToys).go();
    await db.delete(db.rounds).go();
    await db.delete(db.toys).go();
    await db.delete(db.boxes).go();
    await _clearDemoToyPhotos();
  }

  static Future<void> _insertCategories(AppDatabase db) async {
    for (final category in DemoSeed.categories) {
      await db.into(db.categoryDefinitions).insertOnConflictUpdate(
            CategoryDefinitionsCompanion.insert(
              id: category.id,
              name: category.name,
              examples: Value(category.examples),
              isActive: const Value(true),
            ),
          );

      await db.into(db.categoryCounters).insert(
            CategoryCountersCompanion.insert(
              categoryId: category.id,
              nextNumber: const Value(1),
            ),
            mode: InsertMode.insertOrIgnore,
          );

      await db.into(db.roundCategorySettings).insertOnConflictUpdate(
            RoundCategorySettingsCompanion.insert(
              categoryId: category.id,
              isIncluded: Value(category.quota > 0),
              quota: Value(category.quota),
            ),
          );
    }
  }

  static Future<void> _insertLocations(AppDatabase db) async {
    const locations = <String>[
      'Sala',
      'Quarto',
      'Brinquedoteca',
      'Varanda',
      'Banheiro',
    ];

    for (final name in locations) {
      await db.into(db.locationDefinitions).insert(
            LocationDefinitionsCompanion.insert(
              id: _slug(name),
              name: name,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  static Future<void> _insertBoxes(AppDatabase db, int now) async {
    for (final box in DemoSeed.boxes) {
      final name = 'Caixa ${box.number} - ${box.local}';
      await db.into(db.boxes).insertOnConflictUpdate(
            BoxesCompanion.insert(
              id: box.id,
              number: Value(box.number),
              local: Value(box.local),
              name: Value(name),
              createdAt: now + box.number,
            ),
          );
    }
  }

  static Future<void> _insertToys(AppDatabase db, int now) async {
    for (var index = 0; index < DemoSeed.toys.length; index++) {
      final toy = DemoSeed.toys[index];
      final photoPath = await _copyDemoToyPhoto(toy);

      await db.into(db.toys).insertOnConflictUpdate(
            ToysCompanion.insert(
              id: toy.id,
              categoryId: Value(toy.categoryId),
              name: toy.name,
              boxId: Value(toy.boxId),
              locationText: Value(toy.locationText),
              createdAt: now + index,
              photoPath: Value(photoPath),
            ),
          );
    }
  }

  static Future<void> _clearDemoToyPhotos() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_demoToyPhotosDirName');
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  static Future<String> _copyDemoToyPhoto(DemoToySeed toy) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_demoToyPhotosDirName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final data = await rootBundle.load(toy.photoAssetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final assetFileName = toy.photoAssetPath.split('/').last;
    final file = File('${dir.path}/${toy.id}_$assetFileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static Future<void> _insertWeeklyPlanning(AppDatabase db) async {
    await _ensureWeeklyPlanningColumn(db);

    await db.into(db.roundUiSettings).insert(
          RoundUiSettingsCompanion.insert(
            id: const Value(1),
            perCategoryLimit: const Value(7),
            hapticEnabled: const Value(true),
            soundEnabled: const Value(false),
            darkModeEnabled: const Value(false),
          ),
          mode: InsertMode.insertOrIgnore,
        );

    await db.customUpdate(
      '''
      UPDATE round_ui_settings
      SET weekly_planning_enabled = 1
      WHERE id = 1
      ''',
      updates: {db.roundUiSettings},
    );

    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      await db.into(db.weeklyPlanningSettings).insertOnConflictUpdate(
            WeeklyPlanningSettingsCompanion.insert(
              weekday: Value(weekday),
              useDefault: const Value(true),
              customSize: const Value(null),
            ),
          );

      for (final category in DemoSeed.categories) {
        await db.into(db.weeklyPlanningCategorySettings).insertOnConflictUpdate(
              WeeklyPlanningCategorySettingsCompanion.insert(
                weekday: weekday,
                categoryId: category.id,
                isIncluded: Value(category.quota > 0),
                quota: Value(category.quota),
              ),
            );
      }
    }
  }

  static Future<void> _ensureWeeklyPlanningColumn(AppDatabase db) async {
    final columns = await db.customSelect(
      'PRAGMA table_info(round_ui_settings)',
      readsFrom: {db.roundUiSettings},
    ).get();
    final exists = columns
        .any((row) => row.read<String>('name') == 'weekly_planning_enabled');
    if (exists) return;

    await db.customStatement(
      '''
      ALTER TABLE round_ui_settings
      ADD COLUMN weekly_planning_enabled INTEGER NOT NULL DEFAULT 0
      ''',
    );
  }

  static Future<void> _insertActiveRound(AppDatabase db, int now) async {
    const roundId = 'demo_active_round';

    await db.into(db.rounds).insertOnConflictUpdate(
          RoundsCompanion.insert(
            id: roundId,
            startAt: now,
            endAt: const Value(null),
          ),
        );

    for (var index = 0; index < DemoSeed.activeRoundToyIds.length; index++) {
      await db.into(db.roundToys).insert(
            RoundToysCompanion.insert(
              roundId: roundId,
              toyId: DemoSeed.activeRoundToyIds[index],
              position: index,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  static String _slug(String value) {
    return value.trim().toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
  }
}
