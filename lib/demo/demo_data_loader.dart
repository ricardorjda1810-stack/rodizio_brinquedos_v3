import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_seed.dart';

class DemoDataLoader {
  static const _isDemo = bool.fromEnvironment('DEMO_MODE');
  static const _isMarketingDemo = bool.fromEnvironment('MARKETING_DEMO');
  static const _demoToyPhotosDirName = 'demo_toy_photos';
  static const _demoBoxPhotosDirName = 'demo_box_photos';
  static const _initialSeedAppliedKey = 'demo_initial_seed_applied_v1';
  static const examplesRemovedPreferenceKey = 'demoExamplesRemoved';
  static const demoToyIdPrefix = 'demo_toy_';
  static const demoBoxIdPrefix = 'demo_box_';
  static const _demoActiveRoundId = 'demo_active_round';
  static const _starterLocationIds = <String>{
    'sala',
    'quarto_da_crianca',
    'quarto',
    'cozinha',
    'banheiro',
    'varanda',
    'area_de_servico',
    'corredor',
  };

  static bool get controlsEnabled => _isDemo || _isMarketingDemo;

  static bool isDemoToyId(String toyId) => toyId.startsWith(demoToyIdPrefix);

  static bool isDemoBoxId(String boxId) => boxId.startsWith(demoBoxIdPrefix);

  static Future<bool> examplesRemoved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(examplesRemovedPreferenceKey) ?? false;
  }

  static Future<void> load(AppDatabase db) async {
    if (!_isDemo) {
      await _populateInitialIfNeeded(db);
      return;
    }

    // ignore: avoid_print
    print('[DEMO] DemoDataLoader.load started');
    final toysCount =
        await db.select(db.toys).get().then((toys) => toys.length);
    // ignore: avoid_print
    print('[DEMO] toys count before seed = $toysCount');

    await populate(db);
    // ignore: avoid_print
    print('[DEMO] seed completed');
  }

  static Future<void> _populateInitialIfNeeded(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    final examplesRemoved = await DemoDataLoader.examplesRemoved();
    if (examplesRemoved) {
      await _clearEmptyExampleScaffolding(db);
      await prefs.setBool(_initialSeedAppliedKey, true);
      return;
    }

    final alreadyHandled = prefs.getBool(_initialSeedAppliedKey) ?? false;
    if (alreadyHandled) {
      await _repairExistingDemoToyPhotos(db);
      await _repairExistingDemoBoxPhotos(db);
      return;
    }

    final toys = await db.select(db.toys).get();
    final hasRealToys = toys.any((toy) => !isDemoToyId(toy.id));
    if (hasRealToys) {
      await _repairExistingDemoToyPhotos(db);
      await _repairExistingDemoBoxPhotos(db);
      await prefs.setBool(_initialSeedAppliedKey, true);
      return;
    }

    await restoreExamples(
      db,
      includePlanning: true,
      includeActiveRound: true,
      includeRoundSettings: true,
    );
  }

  static Future<void> populate(AppDatabase db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      await _clearDemoState(db);
      await _insertCategories(db, includeRoundSettings: true);
      await _insertLocations(db);
      await _insertBoxes(db, now);
      await _insertToys(db, now);
      await _insertWeeklyPlanning(db);
      await _insertActiveRound(db, now);
    });
  }

  static Future<void> restoreExamples(
    AppDatabase db, {
    bool includePlanning = false,
    bool includeActiveRound = false,
    bool includeRoundSettings = false,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      await _insertCategories(db, includeRoundSettings: includeRoundSettings);
      await _insertLocations(db);
      await _insertBoxes(db, now);
      await _insertToys(db, now);
      if (includePlanning) {
        await _insertWeeklyPlanning(db);
      }
      if (includeActiveRound) {
        await _insertActiveRound(db, now);
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(examplesRemovedPreferenceKey, false);
    await prefs.setBool(_initialSeedAppliedKey, true);
  }

  static Future<void> removeExamples(AppDatabase db) async {
    await db.transaction(() async {
      final demoToys = await (db.select(db.toys)
            ..where((toy) => toy.id.like('$demoToyIdPrefix%')))
          .get();
      final demoToyIds = demoToys.map((toy) => toy.id).toList();
      final demoToyIdSet = demoToyIds.toSet();

      final roundIdsToDelete = <String>{_demoActiveRoundId};
      if (demoToyIdSet.isNotEmpty) {
        final rounds = await db.select(db.rounds).get();
        final roundToyRows = await db.select(db.roundToys).get();

        for (final round in rounds) {
          final toysInRound = roundToyRows.where(
            (row) => row.roundId == round.id,
          );
          if (toysInRound.isEmpty) continue;
          final onlyDemoToys = toysInRound.every(
            (row) => demoToyIdSet.contains(row.toyId),
          );
          if (onlyDemoToys) {
            roundIdsToDelete.add(round.id);
          }
        }

        await (db.delete(db.roundToyChecklistItems)
              ..where((row) => row.toyId.isIn(demoToyIds)))
            .go();
        await (db.delete(db.roundToys)
              ..where((row) => row.toyId.isIn(demoToyIds)))
            .go();
        await (db.delete(db.toys)..where((row) => row.id.isIn(demoToyIds)))
            .go();
      }

      await (db.delete(db.rounds)
            ..where((row) => row.id.isIn(roundIdsToDelete.toList())))
          .go();
      await _deleteEmptyDemoBoxes(db);
      await _clearEmptyExampleScaffolding(db);
    });

    await _clearDemoToyPhotos();
    await _clearDemoBoxPhotosIfNoDemoBoxes(db);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(examplesRemovedPreferenceKey, true);
    await prefs.setBool(_initialSeedAppliedKey, true);
  }

  static Future<int> countExampleToys(AppDatabase db) async {
    final toys = await (db.select(db.toys)
          ..where((toy) => toy.id.like('$demoToyIdPrefix%')))
        .get();
    return toys.length;
  }

  static Future<void> clear(AppDatabase db) async {
    await db.transaction(() async {
      await _clearDemoState(db);
    });
  }

  static Future<void> _clearDemoState(AppDatabase db) async {
    await db.delete(db.roundToys).go();
    await db.delete(db.rounds).go();
    await db.delete(db.toys).go();
    await db.delete(db.boxes).go();
    await db.delete(db.weeklyPlanningCategorySettings).go();
    await db.delete(db.weeklyPlanningSettings).go();
    await db.delete(db.roundCategorySettings).go();
    await db.delete(db.roundUiSettings).go();
    await db.delete(db.toyAutoNameCounters).go();
    await db.delete(db.categoryCounters).go();
    await db.delete(db.locationDefinitions).go();
    await db.delete(db.categoryDefinitions).go();
    await db.delete(db.historyEvents).go();
    await _clearDemoToyPhotos();
    await _clearDemoBoxPhotos();
  }

  static Future<void> _insertCategories(
    AppDatabase db, {
    required bool includeRoundSettings,
  }) async {
    for (final category in DemoSeed.categories) {
      await db.into(db.categoryDefinitions).insertOnConflictUpdate(
            CategoryDefinitionsCompanion.insert(
              id: category.id,
              name: category.name,
              description: const Value(null),
              examples: Value(category.examples),
              developmentAspect: Value(category.developmentAspect),
              sortOrder: Value(category.sortOrder),
              isDefault: const Value(true),
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

      if (includeRoundSettings) {
        await db.into(db.roundCategorySettings).insertOnConflictUpdate(
              RoundCategorySettingsCompanion.insert(
                categoryId: category.id,
                isIncluded: Value(category.quota > 0),
                quota: Value(category.quota),
              ),
            );
      }
    }
  }

  static Future<void> _insertLocations(AppDatabase db) async {
    for (final name in DemoSeed.locations) {
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
      final photoPath = await _copyDemoBoxPhoto(box);
      await db.into(db.boxes).insertOnConflictUpdate(
            BoxesCompanion.insert(
              id: box.id,
              number: Value(box.number),
              local: Value(box.local),
              name: Value(name),
              photoPath: Value(photoPath),
              createdAt: now + box.number,
            ),
          );
    }
  }

  static Future<void> _deleteEmptyDemoBoxes(AppDatabase db) async {
    for (final box in DemoSeed.boxes) {
      final linkedToy = await (db.select(db.toys)
            ..where((toy) => toy.boxId.equals(box.id))
            ..limit(1))
          .getSingleOrNull();
      if (linkedToy != null) continue;

      await (db.delete(db.boxes)..where((row) => row.id.equals(box.id))).go();
    }
  }

  static Future<void> _clearEmptyExampleScaffolding(AppDatabase db) async {
    final realToy = await (db.select(db.toys)
          ..where((toy) => toy.id.like('$demoToyIdPrefix%').not())
          ..limit(1))
        .getSingleOrNull();
    final hasRealToys = realToy != null;

    await _deleteEmptyDemoBoxes(db);
    await _deleteUnusedSeedLocations(db);

    if (hasRealToys) return;

    await db.delete(db.roundToyChecklistItems).go();
    await db.delete(db.roundToys).go();
    await db.delete(db.rounds).go();
    await db.delete(db.weeklyPlanningCategorySettings).go();
    await db.delete(db.weeklyPlanningSettings).go();
    await _deleteEmptyStarterBoxes(db);
    await _disableWeeklyPlanning(db);
  }

  static Future<void> _deleteEmptyStarterBoxes(AppDatabase db) async {
    final boxes = await db.select(db.boxes).get();
    for (final box in boxes) {
      if (!_isStarterBox(box)) continue;

      final linkedToy = await (db.select(db.toys)
            ..where((toy) => toy.boxId.equals(box.id))
            ..limit(1))
          .getSingleOrNull();
      if (linkedToy != null) continue;

      await (db.delete(db.boxes)..where((row) => row.id.equals(box.id))).go();
    }
  }

  static bool _isStarterBox(Boxe box) {
    final expectedName = 'Caixa ${box.number}';
    return box.number >= 1 &&
        box.number <= 4 &&
        box.local.trim().isEmpty &&
        box.name.trim() == expectedName &&
        (box.notes?.trim().isEmpty ?? true) &&
        (box.photoPath?.trim().isEmpty ?? true);
  }

  static Future<void> _deleteUnusedSeedLocations(AppDatabase db) async {
    final seedLocationIds = <String>{
      ..._starterLocationIds,
      for (final name in DemoSeed.locations) _slug(name),
    };
    final realToys = await (db.select(db.toys)
          ..where((toy) => toy.id.like('$demoToyIdPrefix%').not()))
        .get();
    final realLocationNames = realToys
        .map((toy) => toy.locationText?.trim().toLowerCase())
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toSet();

    final locations = await (db.select(db.locationDefinitions)
          ..where((location) => location.id.isIn(seedLocationIds.toList())))
        .get();
    for (final location in locations) {
      final name = location.name.trim().toLowerCase();
      if (realLocationNames.contains(name)) continue;

      await (db.delete(db.locationDefinitions)
            ..where((row) => row.id.equals(location.id)))
          .go();
    }
  }

  static Future<void> _disableWeeklyPlanning(AppDatabase db) async {
    await _ensureWeeklyPlanningColumn(db);
    await db.customUpdate(
      '''
      UPDATE round_ui_settings
      SET weekly_planning_enabled = 0
      WHERE id = 1
      ''',
      updates: {db.roundUiSettings},
    );
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

  static Future<void> _repairExistingDemoToyPhotos(AppDatabase db) async {
    final seedById = {for (final toy in DemoSeed.toys) toy.id: toy};
    final seedToyIds = seedById.keys.toList(growable: false);
    if (seedToyIds.isEmpty) return;

    final demoToys = await (db.select(db.toys)
          ..where((toy) => toy.id.isIn(seedToyIds)))
        .get();

    for (final demoToy in demoToys) {
      final seed = seedById[demoToy.id];
      if (seed == null) continue;

      final photoPath = demoToy.photoPath?.trim();
      final pointsToBundledAsset =
          photoPath != null && photoPath.startsWith('assets/');
      if (photoPath != null &&
          photoPath.isNotEmpty &&
          !pointsToBundledAsset &&
          await File(photoPath).exists()) {
        continue;
      }

      final repairedPath = await _copyDemoToyPhoto(seed);
      await (db.update(db.toys)..where((toy) => toy.id.equals(demoToy.id)))
          .write(ToysCompanion(photoPath: Value(repairedPath)));
    }
  }

  static Future<void> _repairExistingDemoBoxPhotos(AppDatabase db) async {
    final seedById = {for (final box in DemoSeed.boxes) box.id: box};
    final seedBoxIds = seedById.keys.toList(growable: false);
    if (seedBoxIds.isEmpty) return;

    final demoBoxes = await (db.select(db.boxes)
          ..where((box) => box.id.isIn(seedBoxIds)))
        .get();

    for (final demoBox in demoBoxes) {
      final seed = seedById[demoBox.id];
      if (seed == null) continue;

      final photoPath = demoBox.photoPath?.trim();
      final pointsToBundledAsset =
          photoPath != null && photoPath.startsWith('assets/');
      if (photoPath != null &&
          photoPath.isNotEmpty &&
          !pointsToBundledAsset &&
          await File(photoPath).exists()) {
        continue;
      }

      final repairedPath = await _copyDemoBoxPhoto(seed);
      await (db.update(db.boxes)..where((box) => box.id.equals(demoBox.id)))
          .write(BoxesCompanion(photoPath: Value(repairedPath)));
    }
  }

  static Future<void> _clearDemoToyPhotos() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_demoToyPhotosDirName');
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  static Future<void> _clearDemoBoxPhotos() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_demoBoxPhotosDirName');
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  static Future<void> _clearDemoBoxPhotosIfNoDemoBoxes(AppDatabase db) async {
    final remainingDemoBox = await (db.select(db.boxes)
          ..where((box) => box.id.like('$demoBoxIdPrefix%'))
          ..limit(1))
        .getSingleOrNull();
    if (remainingDemoBox == null) {
      await _clearDemoBoxPhotos();
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

  static Future<String> _copyDemoBoxPhoto(DemoBoxSeed box) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_demoBoxPhotosDirName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final data = await rootBundle.load(box.photoAssetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final assetFileName = box.photoAssetPath.split('/').last;
    final file = File('${dir.path}/${box.id}_$assetFileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static Future<void> _insertWeeklyPlanning(AppDatabase db) async {
    await _ensureWeeklyPlanningColumn(db);

    await db.into(db.roundUiSettings).insert(
          RoundUiSettingsCompanion.insert(
            id: const Value(1),
            perCategoryLimit: const Value(5),
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
    await db.into(db.rounds).insertOnConflictUpdate(
          RoundsCompanion.insert(
            id: _demoActiveRoundId,
            startAt: now,
            endAt: const Value(null),
          ),
        );

    for (var index = 0; index < DemoSeed.activeRoundToyIds.length; index++) {
      await db.into(db.roundToys).insert(
            RoundToysCompanion.insert(
              roundId: _demoActiveRoundId,
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
