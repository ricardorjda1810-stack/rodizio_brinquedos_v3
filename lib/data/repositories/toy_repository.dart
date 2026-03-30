import 'dart:io';

import 'package:drift/drift.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/services/photo_cropper_service.dart';

class ToyWithBox {
  final Toy toy;
  final Boxe? box;

  const ToyWithBox({required this.toy, required this.box});
}

class ToyCatalogItem {
  final Toy toy;
  final Boxe? box;
  final CategoryDefinition? category;

  const ToyCatalogItem({
    required this.toy,
    required this.box,
    required this.category,
  });
}

class RoundCategorySettingRow {
  final CategoryDefinition category;
  final bool isIncluded;
  final int quota;

  const RoundCategorySettingRow({
    required this.category,
    required this.isIncluded,
    required this.quota,
  });
}

class CategorySeed {
  final String id;
  final String name;

  const CategorySeed(this.id, this.name);
}

class LocationSeed {
  final String id;
  final String name;

  const LocationSeed(this.id, this.name);
}

class ToyRepository {
  final AppDatabase? db;
  final ImagePicker _picker = ImagePicker();

  ToyRepository(this.db);

  static const List<CategorySeed> defaultCategories = [
    CategorySeed('veiculos', 'Veículos'),
    CategorySeed('bonecos', 'Bonecos'),
    CategorySeed('montagem', 'Montagem'),
    CategorySeed('livros', 'Livros'),
    CategorySeed('jogos', 'Jogos'),
    CategorySeed('faz_de_conta', 'Faz de conta'),
    CategorySeed('artes', 'Artes'),
    CategorySeed('musica', 'Música'),
    CategorySeed('banho', 'Banho'),
    CategorySeed('outros', 'Outros'),
  ];

  static const List<LocationSeed> defaultLocations = [
    LocationSeed('sala', 'Sala'),
    LocationSeed('quarto_da_crianca', 'Quarto da criança'),
    LocationSeed('quarto', 'Quarto'),
    LocationSeed('cozinha', 'Cozinha'),
    LocationSeed('banheiro', 'Banheiro'),
    LocationSeed('varanda', 'Varanda'),
    LocationSeed('area_de_servico', 'Área de serviço'),
    LocationSeed('corredor', 'Corredor'),
  ];

  Future<void> ensureSeedData() async {
    final d = db;
    if (d == null) return;

    await d.transaction(() async {
      for (final c in defaultCategories) {
        await d
            .into(d.categoryDefinitions)
            .insertOnConflictUpdate(
              CategoryDefinitionsCompanion.insert(
                id: c.id,
                name: c.name,
                isActive: const Value(true),
              ),
            );

        await d
            .into(d.categoryCounters)
            .insert(
              CategoryCountersCompanion.insert(
                categoryId: c.id,
                nextNumber: const Value(1),
              ),
              mode: InsertMode.insertOrIgnore,
            );

        await d
            .into(d.roundCategorySettings)
            .insert(
              RoundCategorySettingsCompanion.insert(
                categoryId: c.id,
                isIncluded: const Value(true),
                quota: const Value(1),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

      for (final loc in defaultLocations) {
        await d
            .into(d.locationDefinitions)
            .insert(
              LocationDefinitionsCompanion.insert(id: loc.id, name: loc.name),
              mode: InsertMode.insertOrIgnore,
            );
      }

      final categories = await d.select(d.categoryDefinitions).get();
      for (final c in categories) {
        await d
            .into(d.categoryCounters)
            .insert(
              CategoryCountersCompanion.insert(
                categoryId: c.id,
                nextNumber: const Value(1),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        await d
            .into(d.roundCategorySettings)
            .insert(
              RoundCategorySettingsCompanion.insert(
                categoryId: c.id,
                isIncluded: const Value(true),
                quota: const Value(1),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

      final existingBoxes = await d.select(d.boxes).get();
      if (existingBoxes.length < 4) {
        final existingByNumber = <int>{
          for (final box in existingBoxes) box.number,
        };
        var createdAt = DateTime.now().millisecondsSinceEpoch;

        for (var i = 1; i <= 4; i++) {
          if (existingByNumber.contains(i)) continue;

          await d
              .into(d.boxes)
              .insert(
                BoxesCompanion.insert(
                  id: const Uuid().v4(),
                  number: Value(i),
                  local: const Value(''),
                  name: Value('Caixa $i'),
                  createdAt: createdAt++,
                ),
              );
        }
      }
    });
  }

  Stream<List<Toy>> watchAll() {
    final d = db;
    if (d == null) return const Stream<List<Toy>>.empty();

    final q = d.select(d.toys)..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return q.watch();
  }

  Stream<Map<String, int>> watchAvailableToyCountByCategory() {
    return watchAll().map((toys) {
      final counts = <String, int>{};
      for (final toy in toys) {
        final id = toy.categoryId.trim();
        if (id.isEmpty) continue;
        counts[id] = (counts[id] ?? 0) + 1;
      }
      return counts;
    });
  }

  Future<List<Toy>> getAllToysOnce() async {
    final d = db;
    if (d == null) return const <Toy>[];
    return (d.select(
      d.toys,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
  }

  Stream<List<ToyCatalogItem>> watchCatalog() {
    final d = db;
    if (d == null) return const Stream<List<ToyCatalogItem>>.empty();

    final t = d.toys;
    final b = d.boxes;
    final c = d.categoryDefinitions;

    final query = d.select(t).join([
      leftOuterJoin(b, b.id.equalsExp(t.boxId)),
      leftOuterJoin(c, c.id.equalsExp(t.categoryId)),
    ])..orderBy([OrderingTerm.asc(t.createdAt)]);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => ToyCatalogItem(
              toy: row.readTable(t),
              box: row.readTableOrNull(b),
              category: row.readTableOrNull(c),
            ),
          )
          .toList();
    });
  }

  Stream<List<ToyWithBox>> watchAllWithBox() {
    final d = db;
    if (d == null) return const Stream<List<ToyWithBox>>.empty();

    final t = d.toys;
    final b = d.boxes;

    final query = d.select(t).join(
      [leftOuterJoin(b, b.id.equalsExp(t.boxId))],
    )..orderBy([OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ToyWithBox(toy: row.readTable(t), box: row.readTableOrNull(b));
      }).toList();
    });
  }

  Stream<ToyWithBox?> watchToyWithBox({required String toyId}) {
    final d = db;
    if (d == null) return const Stream<ToyWithBox?>.empty();

    final t = d.toys;
    final b = d.boxes;

    final query = (d.select(t)..where((x) => x.id.equals(toyId))).join([
      leftOuterJoin(b, b.id.equalsExp(t.boxId)),
    ]);

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final row = rows.first;
      return ToyWithBox(toy: row.readTable(t), box: row.readTableOrNull(b));
    });
  }

  Stream<List<Boxe>> watchBoxes() {
    final d = db;
    if (d == null) return const Stream<List<Boxe>>.empty();

    final q = d.select(d.boxes)
      ..orderBy([
        (b) => OrderingTerm(expression: b.number, mode: OrderingMode.asc),
      ]);

    return q.watch();
  }

  Future<int> peekNextBoxNumber() async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final maxExpr = d.boxes.number.max();
    final row = await (d.selectOnly(
      d.boxes,
    )..addColumns([maxExpr])).getSingle();
    final currentMax = row.read(maxExpr);
    if (currentMax == null) return 1;
    return currentMax + 1;
  }

  Stream<List<CategoryDefinition>> watchCategories({bool activeOnly = false}) {
    final d = db;
    if (d == null) return const Stream<List<CategoryDefinition>>.empty();

    final q = d.select(d.categoryDefinitions)
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    if (activeOnly) {
      q.where((c) => c.isActive.equals(true));
    }
    return q.watch();
  }

  Stream<List<CategoryDefinition>> watchRoundIncludedCategories() {
    final d = db;
    if (d == null) return const Stream<List<CategoryDefinition>>.empty();

    final c = d.categoryDefinitions;
    final s = d.roundCategorySettings;

    final query =
        d.select(c).join([
            innerJoin(
              s,
              s.categoryId.equalsExp(c.id) & s.isIncluded.equals(true),
            ),
          ])
          ..where(c.isActive.equals(true))
          ..orderBy([OrderingTerm.asc(c.name)]);

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(c)).toList();
    });
  }

  Stream<List<CategoryDefinition>> watchIncludedRoundCategories() {
    return watchRoundIncludedCategories();
  }

  Stream<List<RoundCategorySettingRow>> watchRoundCategorySettings() {
    final d = db;
    if (d == null) return const Stream<List<RoundCategorySettingRow>>.empty();

    final c = d.categoryDefinitions;
    final s = d.roundCategorySettings;

    final query = d.select(c).join([
      leftOuterJoin(s, s.categoryId.equalsExp(c.id)),
    ])..orderBy([OrderingTerm.asc(c.name)]);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => RoundCategorySettingRow(
              category: row.readTable(c),
              isIncluded: row.readTableOrNull(s)?.isIncluded ?? true,
              quota: row.readTableOrNull(s)?.quota ?? 1,
            ),
          )
          .toList();
    });
  }

  Stream<List<LocationDefinition>> watchLocations() {
    final d = db;
    if (d == null) return const Stream<List<LocationDefinition>>.empty();

    final q = d.select(d.locationDefinitions)
      ..orderBy([(l) => OrderingTerm.asc(l.name)]);
    return q.watch();
  }

  Future<void> addToy({required String name, String? boxId}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final normalizedBoxId = _normalizeNullable(boxId);
    final normalizedName = _normalizeNullable(name);

    await d.transaction(() async {
      final resolvedName =
          normalizedName ?? await _nextAutoToyNameForBox(normalizedBoxId);
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = const Uuid().v4();

      await d
          .into(d.toys)
          .insert(
            ToysCompanion.insert(
              id: id,
              categoryId: const Value('outros'),
              name: resolvedName,
              createdAt: now,
              boxId: Value(normalizedBoxId),
              locationText: const Value(null),
              photoPath: const Value(null),
            ),
          );
    });
  }

  Future<Toy> createToy({
    required String name,
    String? boxId,
    String? locationText,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw StateError('Nome do brinquedo é obrigatório.');
    }

    final normalizedBoxId = _normalizeNullable(boxId);
    final normalizedLocation = _normalizeNullable(locationText);
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = const Uuid().v4();

    await d
        .into(d.toys)
        .insert(
          ToysCompanion.insert(
            id: id,
            categoryId: const Value('outros'),
            name: trimmedName,
            createdAt: now,
            boxId: Value(normalizedBoxId),
            locationText: Value(normalizedLocation),
            photoPath: const Value(null),
          ),
        );

    return (d.select(d.toys)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> addToyWithGeneratedName({
    required String categoryId,
    String? name,
    String? boxId,
    String? locationText,
    String? photoSourcePath,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final normalizedBoxId = _normalizeNullable(boxId);
    final normalizedName = _normalizeNullable(name);
    final normalizedLocation = _normalizeNullable(locationText);
    final now = DateTime.now().millisecondsSinceEpoch;
    final toyId = const Uuid().v4();

    await d.transaction(() async {
      final category = await (d.select(
        d.categoryDefinitions,
      )..where((c) => c.id.equals(categoryId))).getSingleOrNull();
      if (category == null) {
        throw StateError('Categoria inválida.');
      }

      final resolvedName =
          normalizedName ?? await _nextAutoToyNameForBox(normalizedBoxId);

      await d
          .into(d.toys)
          .insert(
            ToysCompanion.insert(
              id: toyId,
              categoryId: Value(categoryId),
              name: resolvedName,
              createdAt: now,
              boxId: Value(normalizedBoxId),
              locationText: Value(normalizedLocation),
              photoPath: const Value(null),
            ),
          );
    });

    final source = _normalizeNullable(photoSourcePath);
    if (source != null) {
      final copiedPath = await _copyPhotoToToyStorage(
        toyId: toyId,
        sourcePath: source,
      );
      await (d.update(d.toys)..where((t) => t.id.equals(toyId))).write(
        ToysCompanion(photoPath: Value(copiedPath)),
      );
    }
  }

  Future<void> setToyBox({required String toyId, String? boxId}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final normalizedBoxId = _normalizeNullable(boxId);

    await (d.update(d.toys)..where((t) => t.id.equals(toyId))).write(
      ToysCompanion(boxId: Value(normalizedBoxId)),
    );
  }

  Future<void> updateToyLocationText({
    required String toyId,
    String? locationText,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    await (d.update(d.toys)..where((t) => t.id.equals(toyId))).write(
      ToysCompanion(locationText: Value(_normalizeNullable(locationText))),
    );
  }

  Future<void> updateToyName({
    required String toyId,
    required String name,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw StateError('Nome do brinquedo e obrigatorio.');
    }

    await (d.update(d.toys)..where((t) => t.id.equals(toyId))).write(
      ToysCompanion(name: Value(trimmed)),
    );
  }

  Future<void> updateToyCategory({
    required String toyId,
    required String categoryId,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final normalizedCategoryId = categoryId.trim();
    if (normalizedCategoryId.isEmpty) {
      throw StateError('Categoria invalida.');
    }

    final category = await (d.select(
      d.categoryDefinitions,
    )..where((c) => c.id.equals(normalizedCategoryId))).getSingleOrNull();
    if (category == null) {
      throw StateError('Categoria invalida.');
    }

    await (d.update(d.toys)..where((t) => t.id.equals(toyId))).write(
      ToysCompanion(categoryId: Value(normalizedCategoryId)),
    );
  }

  Future<void> addBox({String? name, String? local}) async {
    final resolvedLocal = _normalizeNullable(local) ?? _normalizeNullable(name);
    if (resolvedLocal == null) return;
    await addBoxWithAutoNumber(local: resolvedLocal);
  }

  Future<Boxe> addBoxWithAutoNumber({
    required String local,
    String? notes,
    String? photoSourcePath,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final normalizedLocal = local.trim();
    final normalizedNotes = _normalizeNullable(notes);

    final id = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final nextNumber = await d.transaction<int>(() async {
      final maxExpr = d.boxes.number.max();
      final row = await (d.selectOnly(
        d.boxes,
      )..addColumns([maxExpr])).getSingle();
      final currentMax = row.read(maxExpr) ?? 0;
      return currentMax + 1;
    });

    final box = Boxe(
      id: id,
      number: nextNumber,
      local: normalizedLocal,
      name: normalizedLocal.isEmpty
          ? 'Caixa $nextNumber'
          : 'Caixa $nextNumber - $normalizedLocal',
      notes: normalizedNotes,
      photoPath: null,
      createdAt: now,
    );

    await d
        .into(d.boxes)
        .insert(
          BoxesCompanion.insert(
            id: box.id,
            number: Value(box.number),
            local: Value(box.local),
            name: Value(box.name),
            notes: Value(box.notes),
            photoPath: const Value(null),
            createdAt: box.createdAt,
          ),
        );

    final source = _normalizeNullable(photoSourcePath);
    if (source != null) {
      final copiedPath = await _copyPhotoToBoxStorage(
        boxId: box.id,
        sourcePath: source,
      );
      await (d.update(d.boxes)..where((b) => b.id.equals(box.id))).write(
        BoxesCompanion(photoPath: Value(copiedPath)),
      );
      return box.copyWith(photoPath: Value(copiedPath));
    }

    return box;
  }

  Future<Boxe> createBox({required int number, required String local}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    if (number <= 0) {
      throw StateError('Número da caixa deve ser maior que zero.');
    }

    final normalizedLocal = local.trim();
    if (normalizedLocal.isEmpty) {
      throw StateError('Local da caixa é obrigatório.');
    }

    final existing = await (d.select(
      d.boxes,
    )..where((b) => b.number.equals(number))).getSingleOrNull();
    if (existing != null) return existing;

    final id = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final name = 'Caixa $number';

    await d
        .into(d.boxes)
        .insert(
          BoxesCompanion.insert(
            id: id,
            number: Value(number),
            local: Value(normalizedLocal),
            name: Value(name),
            createdAt: now,
          ),
        );

    return (d.select(d.boxes)..where((b) => b.id.equals(id))).getSingle();
  }

  Future<void> deleteBox({required String boxId}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    await d.transaction(() async {
      await (d.update(d.toys)..where((t) => t.boxId.equals(boxId))).write(
        const ToysCompanion(boxId: Value(null)),
      );

      await (d.delete(d.boxes)..where((b) => b.id.equals(boxId))).go();
    });
  }

  Future<void> updateBoxLocal({
    required String boxId,
    required String local,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final box = await (d.select(
      d.boxes,
    )..where((b) => b.id.equals(boxId))).getSingleOrNull();
    if (box == null) return;

    final normalizedLocal = local.trim();
    final normalizedName = normalizedLocal.isEmpty
        ? 'Caixa ${box.number}'
        : 'Caixa ${box.number} - $normalizedLocal';

    await (d.update(d.boxes)..where((b) => b.id.equals(boxId))).write(
      BoxesCompanion(
        local: Value(normalizedLocal),
        name: Value(normalizedName),
      ),
    );
  }

  Future<void> updateBoxNotes({required String boxId, String? notes}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    await (d.update(d.boxes)..where((b) => b.id.equals(boxId))).write(
      BoxesCompanion(notes: Value(_normalizeNullable(notes))),
    );
  }

  Future<void> addCategory({required String name}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final existing = await d.select(d.categoryDefinitions).get();
    final ids = existing.map((e) => e.id).toSet();
    final id = _generateUniqueId(_slugify(trimmed), ids, prefix: 'cat');

    await d.transaction(() async {
      await d
          .into(d.categoryDefinitions)
          .insert(
            CategoryDefinitionsCompanion.insert(
              id: id,
              name: trimmed,
              isActive: const Value(true),
            ),
          );
      await d
          .into(d.categoryCounters)
          .insert(
            CategoryCountersCompanion.insert(
              categoryId: id,
              nextNumber: const Value(1),
            ),
          );
      await d
          .into(d.roundCategorySettings)
          .insert(
            RoundCategorySettingsCompanion.insert(
              categoryId: id,
              isIncluded: const Value(true),
              quota: const Value(1),
            ),
          );
    });
  }

  Future<void> renameCategory({
    required String categoryId,
    required String newName,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    await (d.update(d.categoryDefinitions)
          ..where((c) => c.id.equals(categoryId)))
        .write(CategoryDefinitionsCompanion(name: Value(trimmed)));
  }

  Future<void> removeCategory({required String categoryId}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final inUse = await (d.select(
      d.toys,
    )..where((t) => t.categoryId.equals(categoryId))).getSingleOrNull();
    if (inUse != null) {
      await (d.update(d.categoryDefinitions)
            ..where((c) => c.id.equals(categoryId)))
          .write(const CategoryDefinitionsCompanion(isActive: Value(false)));
      return;
    }

    await d.transaction(() async {
      await (d.delete(
        d.categoryCounters,
      )..where((c) => c.categoryId.equals(categoryId))).go();
      await (d.delete(
        d.roundCategorySettings,
      )..where((s) => s.categoryId.equals(categoryId))).go();
      await (d.delete(
        d.categoryDefinitions,
      )..where((c) => c.id.equals(categoryId))).go();
    });
  }

  Future<void> reactivateCategory({required String categoryId}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    await (d.update(d.categoryDefinitions)
          ..where((c) => c.id.equals(categoryId)))
        .write(const CategoryDefinitionsCompanion(isActive: Value(true)));
  }

  Future<void> setCategoryIncludedInRound({
    required String categoryId,
    required bool isIncluded,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final current = await (d.select(
      d.roundCategorySettings,
    )..where((s) => s.categoryId.equals(categoryId))).getSingleOrNull();
    final currentQuota = current?.quota ?? 1;
    final nextQuota = isIncluded && currentQuota <= 0 ? 1 : currentQuota;

    await d
        .into(d.roundCategorySettings)
        .insertOnConflictUpdate(
          RoundCategorySettingsCompanion.insert(
            categoryId: categoryId,
            isIncluded: Value(isIncluded),
            quota: Value(nextQuota),
          ),
        );
  }

  Future<void> setCategoryQuotaInRound({
    required String categoryId,
    required int quota,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final q = quota < 0 ? 0 : quota;
    final current = await (d.select(
      d.roundCategorySettings,
    )..where((s) => s.categoryId.equals(categoryId))).getSingleOrNull();
    final included = current?.isIncluded ?? true;
    await d
        .into(d.roundCategorySettings)
        .insertOnConflictUpdate(
          RoundCategorySettingsCompanion.insert(
            categoryId: categoryId,
            isIncluded: Value(included),
            quota: Value(q),
          ),
        );
  }

  Future<void> restoreRoundCategoryDefaults() async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    const defaultQuotas = <String, int>{
      'veiculos': 2,
      'bonecos': 2,
      'montagem': 2,
      'livros': 1,
      'jogos': 1,
      'faz_de_conta': 1,
      'artes': 1,
      'musica': 0,
      'banho': 0,
      'outros': 0,
    };

    final categories = await d.select(d.categoryDefinitions).get();
    for (final c in categories) {
      final q = defaultQuotas[c.id] ?? 0;
      await d
          .into(d.roundCategorySettings)
          .insertOnConflictUpdate(
            RoundCategorySettingsCompanion.insert(
              categoryId: c.id,
              isIncluded: Value(q > 0),
              quota: Value(q),
            ),
          );
    }
  }

  Future<void> addLocationDefinition({required String name}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final existing = await d.select(d.locationDefinitions).get();
    final ids = existing.map((e) => e.id).toSet();
    final id = _generateUniqueId(_slugify(trimmed), ids, prefix: 'loc');

    await d
        .into(d.locationDefinitions)
        .insert(LocationDefinitionsCompanion.insert(id: id, name: trimmed));
  }

  Future<void> renameLocation({
    required String locationId,
    required String newName,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    await (d.update(d.locationDefinitions)
          ..where((l) => l.id.equals(locationId)))
        .write(LocationDefinitionsCompanion(name: Value(trimmed)));
  }

  Future<void> removeLocation({required String locationId}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    await (d.delete(
      d.locationDefinitions,
    )..where((l) => l.id.equals(locationId))).go();
  }

  Future<void> pickAndSaveToyPhoto({
    required String toyId,
    required ImageSource source,
  }) async {
    final xfile = await _picker.pickImage(source: source, imageQuality: 85);
    if (xfile == null) return;
    final croppedPath = await PhotoCropperService.cropToSquare(
      sourcePath: xfile.path,
    );
    if (croppedPath == null) return;

    await saveToyPhoto(toyId: toyId, croppedPhotoPath: croppedPath);
  }

  Future<void> pickAndSaveBoxPhoto({
    required String boxId,
    required ImageSource source,
  }) async {
    final xfile = await _picker.pickImage(source: source, imageQuality: 85);
    if (xfile == null) return;
    final croppedPath = await PhotoCropperService.cropToSquare(
      sourcePath: xfile.path,
    );
    if (croppedPath == null) return;

    await saveBoxPhoto(boxId: boxId, croppedPhotoPath: croppedPath);
  }

  Future<void> saveToyPhoto({
    required String toyId,
    required String croppedPhotoPath,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final sourcePath = croppedPhotoPath.trim();
    if (sourcePath.isEmpty) {
      throw StateError('Caminho da foto invalido.');
    }

    final targetPath = await _copyPhotoToToyStorage(
      toyId: toyId,
      sourcePath: sourcePath,
    );

    final old = await (d.select(
      d.toys,
    )..where((t) => t.id.equals(toyId))).getSingleOrNull();
    final oldPath = old?.photoPath;
    if (oldPath != null && oldPath.isNotEmpty) {
      _tryDeleteFile(oldPath);
    }

    await (d.update(d.toys)..where((t) => t.id.equals(toyId))).write(
      ToysCompanion(photoPath: Value(targetPath)),
    );
  }

  Future<void> saveBoxPhoto({
    required String boxId,
    required String croppedPhotoPath,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final sourcePath = croppedPhotoPath.trim();
    if (sourcePath.isEmpty) {
      throw StateError('Caminho da foto invalido.');
    }

    final targetPath = await _copyPhotoToBoxStorage(
      boxId: boxId,
      sourcePath: sourcePath,
    );

    final old = await (d.select(
      d.boxes,
    )..where((b) => b.id.equals(boxId))).getSingleOrNull();
    final oldPath = old?.photoPath;
    if (oldPath != null && oldPath.isNotEmpty) {
      _tryDeleteFile(oldPath);
    }

    await (d.update(d.boxes)..where((b) => b.id.equals(boxId))).write(
      BoxesCompanion(photoPath: Value(targetPath)),
    );
  }

  Future<void> removeToyPhoto({required String toyId}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final toy = await (d.select(
      d.toys,
    )..where((t) => t.id.equals(toyId))).getSingleOrNull();
    final path = toy?.photoPath;

    await (d.update(d.toys)..where((t) => t.id.equals(toyId))).write(
      const ToysCompanion(photoPath: Value(null)),
    );

    if (path != null && path.isNotEmpty) {
      _tryDeleteFile(path);
    }
  }

  Future<void> deleteToy({required String toyId}) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final toy = await (d.select(
      d.toys,
    )..where((t) => t.id.equals(toyId))).getSingleOrNull();
    final path = toy?.photoPath;

    await d.transaction(() async {
      await (d.delete(d.roundToys)..where((rt) => rt.toyId.equals(toyId))).go();
      await (d.delete(d.toys)..where((t) => t.id.equals(toyId))).go();
    });

    if (path != null && path.isNotEmpty) {
      _tryDeleteFile(path);
    }
  }

  Future<void> deleteAll() async {
    await hardResetAllData();
  }

  Future<void> hardResetAllData() async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    await d.transaction(() async {
      await d.delete(d.roundToys).go();
      await d.delete(d.rounds).go();
      await d.delete(d.historyEvents).go();
      await d.delete(d.toys).go();
      await d.delete(d.toyAutoNameCounters).go();
      await d.delete(d.boxes).go();
      await d.delete(d.categoryCounters).go();
      await d.delete(d.roundCategorySettings).go();
      await d.delete(d.categoryDefinitions).go();
      await d.delete(d.locationDefinitions).go();
    });

    await ensureSeedData();

    try {
      await _deletePhotosDir(_ensureToyPhotosDir);
      await _deletePhotosDir(_ensureBoxPhotosDir);
    } catch (_) {}
  }

  Future<void> _deletePhotosDir(Future<Directory> Function() dirFactory) async {
    try {
      final dir = await dirFactory();
      if (!dir.existsSync()) return;
      dir.deleteSync(recursive: true);
    } catch (_) {}
  }

  Future<Directory> _ensureToyPhotosDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/toy_photos');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Future<String> _copyPhotoToToyStorage({
    required String toyId,
    required String sourcePath,
  }) async {
    final photosDir = await _ensureToyPhotosDir();
    final ext = _safeExt(sourcePath);
    final filename =
        'toy_${toyId}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final targetPath = '${photosDir.path}/$filename';
    final srcFile = File(sourcePath);
    await srcFile.copy(targetPath);
    return targetPath;
  }

  Future<Directory> _ensureBoxPhotosDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/box_photos');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Future<String> _copyPhotoToBoxStorage({
    required String boxId,
    required String sourcePath,
  }) async {
    final photosDir = await _ensureBoxPhotosDir();
    final ext = _safeExt(sourcePath);
    final filename =
        'box_${boxId}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final targetPath = '${photosDir.path}/$filename';
    final srcFile = File(sourcePath);
    await srcFile.copy(targetPath);
    return targetPath;
  }

  String _safeExt(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.webp')) return '.webp';
    if (lower.endsWith('.jpeg')) return '.jpeg';
    if (lower.endsWith('.jpg')) return '.jpg';
    return '.jpg';
  }

  void _tryDeleteFile(String path) {
    try {
      final f = File(path);
      if (f.existsSync()) {
        f.deleteSync();
      }
    } catch (_) {}
  }

  String? _normalizeNullable(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  String _slugify(String value) {
    final lower = value.toLowerCase().trim();
    final withoutAccents = lower
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');

    final cleaned = withoutAccents.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final normalized = cleaned
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return normalized.isEmpty ? 'item' : normalized;
  }

  String _generateUniqueId(
    String base,
    Set<String> existingIds, {
    required String prefix,
  }) {
    final seed = base.isEmpty ? prefix : base;
    if (!existingIds.contains(seed)) return seed;
    var i = 2;
    while (existingIds.contains('${seed}_$i')) {
      i++;
    }
    return '${seed}_$i';
  }

  Future<String> _nextAutoToyNameForBox(String? boxId) async {
    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final boxIndex = await _resolveBoxIndex(boxId);
    final prefix = 'Brinquedo $boxIndex.';
    final toys = await d.select(d.toys).get();
    var maxSeq = 0;
    for (final toy in toys) {
      final name = toy.name.trim();
      if (!name.startsWith(prefix)) continue;
      final suffix = name.substring(prefix.length);
      final seq = int.tryParse(suffix);
      if (seq != null && seq > maxSeq) {
        maxSeq = seq;
      }
    }
    final nextNumber = maxSeq + 1;

    // Mantém o contador em sincronia para compatibilidade com dados legados.
    await d
        .into(d.toyAutoNameCounters)
        .insertOnConflictUpdate(
          ToyAutoNameCountersCompanion.insert(
            boxIndex: Value(boxIndex),
            nextNumber: Value(nextNumber + 1),
          ),
        );

    return 'Brinquedo $boxIndex.$nextNumber';
  }

  Future<int> _resolveBoxIndex(String? boxId) async {
    if (boxId == null) return 0;

    final d = db;
    if (d == null) {
      throw StateError('ToyRepository.db is null. Use um Fake no teste.');
    }

    final box = await (d.select(
      d.boxes,
    )..where((b) => b.id.equals(boxId))).getSingleOrNull();
    if (box == null) {
      throw StateError('Caixa inválida.');
    }
    return box.number;
  }
}
