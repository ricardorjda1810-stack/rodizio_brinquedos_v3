import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/age_preset.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/child_age_range.dart';
import 'package:rodizio_brinquedos_v3/services/age_preset_service.dart';

void main() {
  late AppDatabase db;
  late ToyRepository toyRepository;
  late RoundRepository roundRepository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    toyRepository = ToyRepository(db);
    roundRepository = RoundRepository(db);
    await toyRepository.ensureSeedData();
  });

  tearDown(() async {
    await db.close();
  });

  test('startRound respeita cotas por categoria ativa sem complemento geral',
      () async {
    await _setCategoryState(toyRepository, 'faz_de_conta',
        included: true, quota: 2);
    await _setCategoryState(toyRepository, 'livros', included: true, quota: 1);
    await _setAllOthersExcluded(
        toyRepository, const {'faz_de_conta', 'livros'});

    await _insertToy(db, id: 'b1', categoryId: 'faz_de_conta', createdAt: 100);
    await _insertToy(db, id: 'b2', categoryId: 'faz_de_conta', createdAt: 200);
    await _insertToy(db, id: 'l1', categoryId: 'livros', createdAt: 150);
    await _insertToy(db, id: 'j1', categoryId: 'construcao', createdAt: 50);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['l1', 'b1', 'b2']);
  });

  test('startRound tolera falta sem buscar brinquedos fora das categorias',
      () async {
    await _setCategoryState(toyRepository, 'faz_de_conta',
        included: true, quota: 3);
    await _setCategoryState(toyRepository, 'livros', included: true, quota: 2);
    await _setAllOthersExcluded(
        toyRepository, const {'faz_de_conta', 'livros'});

    await _insertToy(db, id: 'b1', categoryId: 'faz_de_conta', createdAt: 100);
    await _insertToy(db, id: 'j1', categoryId: 'construcao', createdAt: 50);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['b1']);
  });

  test('categoria com switch off fica fora da rodada', () async {
    await _setCategoryState(toyRepository, 'faz_de_conta',
        included: false, quota: 3);
    await _setCategoryState(toyRepository, 'livros', included: true, quota: 1);
    await _setAllOthersExcluded(
        toyRepository, const {'faz_de_conta', 'livros'});

    await _insertToy(db, id: 'b1', categoryId: 'faz_de_conta', createdAt: 100);
    await _insertToy(db, id: 'l1', categoryId: 'livros', createdAt: 100);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['l1']);
  });

  test('startRound limita o total pela soma das cotas incluidas', () async {
    await _setCategoryState(toyRepository, 'faz_de_conta',
        included: true, quota: 1);
    await _setCategoryState(toyRepository, 'livros', included: true, quota: 1);
    await _setAllOthersExcluded(
        toyRepository, const {'faz_de_conta', 'livros'});

    await _insertToy(db, id: 'b1', categoryId: 'faz_de_conta', createdAt: 100);
    await _insertToy(db, id: 'b2', categoryId: 'faz_de_conta', createdAt: 200);
    await _insertToy(db, id: 'l1', categoryId: 'livros', createdAt: 150);
    await _insertToy(db, id: 'l2', categoryId: 'livros', createdAt: 250);
    await _insertToy(db, id: 'l3', categoryId: 'livros', createdAt: 350);

    final result = await roundRepository.startRound();

    expect(result.created, isTrue);
    expect(result.selectedCount, 2);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['l1', 'b1']);
  });

  test('suggestRoundForDate usa cotas efetivas de cada dia por idade',
      () async {
    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    await AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    ).applyAgePreset(ChildAgeRange.years2To3);
    await _insertOfficialToys(db);

    final weekStart = DateTime(2026, 1, 5);
    final expectedTotals = <int, int>{
      DateTime.monday: 8,
      DateTime.tuesday: 8,
      DateTime.wednesday: 8,
      DateTime.thursday: 8,
      DateTime.friday: 8,
      DateTime.saturday: 9,
      DateTime.sunday: 9,
    };

    for (final entry in expectedTotals.entries) {
      final date = weekStart.add(Duration(days: entry.key - 1));
      final suggestion = await roundRepository.suggestRoundForDate(date);

      expect(
        suggestion,
        hasLength(entry.value),
        reason: 'weekday ${entry.key}',
      );

      await roundRepository.setActiveRoundFromToyIds(
        suggestion.map((toy) => toy.id).toList(growable: false),
      );
      expect(
        await _selectedToyIdsByPosition(db),
        hasLength(entry.value),
        reason: 'active round weekday ${entry.key}',
      );
    }

    final mondaySuggestion =
        await roundRepository.suggestRoundForDate(weekStart);
    final mondayCounts = _categoryCountsForToys(mondaySuggestion);
    expect(mondayCounts['corpo'], 2);
    expect(mondayCounts['maos'], 2);
    expect(mondayCounts['imaginacao'], 2);
    expect(mondayCounts['comunicacao'], 1);
    expect(mondayCounts['exploracao'], 1);

    final saturdaySuggestion = await roundRepository.suggestRoundForDate(
      weekStart.add(const Duration(days: 5)),
    );
    final saturdayCounts = _categoryCountsForToys(saturdaySuggestion);
    expect(saturdayCounts['corpo'], 3);
    expect(saturdayCounts['imaginacao'], 2);

    final sundaySuggestion = await roundRepository.suggestRoundForDate(
      weekStart.add(const Duration(days: 6)),
    );
    final sundayCounts = _categoryCountsForToys(sundaySuggestion);
    expect(sundayCounts['corpo'], 2);
    expect(sundayCounts['imaginacao'], 3);

    settingsRepository.dispose();
  });

  test('suggestRoundForDate aplica faixa etaria apesar de cota bruta antiga',
      () async {
    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    final weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    final roundRepository = RoundRepository(db, weeklyPlanningRepository);
    await AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    ).applyAgePreset(ChildAgeRange.months6To12);
    await _insertOfficialToys(db);
    await _overwriteRoundCategoryQuotas(db, const {
      'corpo': 2,
      'maos': 3,
      'imaginacao': 3,
      'comunicacao': 2,
      'exploracao': 2,
    });

    final weekStart = DateTime(2026, 1, 5);
    final preset = AgePresetCatalog.presetFor(ChildAgeRange.months6To12);
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final date = weekStart.add(Duration(days: weekday - DateTime.monday));
      final suggestion = await roundRepository.suggestRoundForDate(date);

      expect(
        suggestion,
        hasLength(preset.totalForWeekday(weekday)),
        reason: 'weekday $weekday',
      );
    }

    settingsRepository.dispose();
  });

  test(
      'suggestRoundForDate ignora copia semanal antiga com categorias duplicadas',
      () async {
    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    final weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    final roundRepository = RoundRepository(db, weeklyPlanningRepository);
    await AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    ).applyAgePreset(ChildAgeRange.months6To12);
    await settingsRepository.setChildAgeRange(null);
    await _overwriteRoundCategoryQuotas(db, const {
      'corpo': 1,
      'maos': 1,
      'imaginacao': 1,
      'comunicacao': 1,
      'exploracao': 1,
    });
    await _insertOfficialToys(db);
    await _writeStaleWeeklyCustomQuotas(db);

    final weekStart = DateTime(2026, 1, 5);
    const expectedTotal = 5;
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final date = weekStart.add(Duration(days: weekday - DateTime.monday));
      final suggestion = await roundRepository.suggestRoundForDate(date);

      expect(suggestion, hasLength(expectedTotal), reason: 'weekday $weekday');
    }

    settingsRepository.dispose();
  });

  test('suggestRoundForDate aplica faixa etaria sobre copia semanal duplicada',
      () async {
    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    final weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    final roundRepository = RoundRepository(db, weeklyPlanningRepository);
    await AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    ).applyAgePreset(ChildAgeRange.months0To6);
    await _insertOfficialToys(db);
    await _writeStaleWeeklyCustomQuotas(db);

    final weekStart = DateTime(2026, 1, 5);
    final preset = AgePresetCatalog.presetFor(ChildAgeRange.months0To6);
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final date = weekStart.add(Duration(days: weekday - DateTime.monday));
      final suggestion = await roundRepository.suggestRoundForDate(date);

      expect(
        suggestion,
        hasLength(preset.totalForWeekday(weekday)),
        reason: 'weekday $weekday',
      );
    }

    settingsRepository.dispose();
  });

  test('startRound usa cotas efetivas de cada data por idade', () async {
    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    await AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    ).applyAgePreset(ChildAgeRange.years2To3);
    await _insertOfficialToys(db);

    final weekStart = DateTime(2026, 1, 5);
    final expectedTotals = <int, int>{
      DateTime.monday: 8,
      DateTime.tuesday: 8,
      DateTime.wednesday: 8,
      DateTime.thursday: 8,
      DateTime.friday: 8,
      DateTime.saturday: 9,
      DateTime.sunday: 9,
    };

    for (final entry in expectedTotals.entries) {
      final date = weekStart.add(Duration(days: entry.key - 1));
      final result = await roundRepository.startRound(date: date);
      final selectedIds = await _selectedToyIdsByPosition(db);

      expect(result.created, isTrue, reason: 'weekday ${entry.key}');
      expect(result.selectedCount, entry.value, reason: 'weekday ${entry.key}');
      expect(selectedIds, hasLength(entry.value),
          reason: 'weekday ${entry.key}');

      if (entry.key == DateTime.monday) {
        final counts = await _selectedCategoryCounts(db);
        expect(counts['corpo'], 2);
        expect(counts['maos'], 2);
        expect(counts['imaginacao'], 2);
        expect(counts['comunicacao'], 1);
        expect(counts['exploracao'], 1);
      }
    }

    settingsRepository.dispose();
  });

  test('startRound nao cria rodada quando nao ha brinquedos cadastrados',
      () async {
    await _setCategoryState(toyRepository, 'faz_de_conta',
        included: true, quota: 2);
    await _setAllOthersExcluded(toyRepository, const {'faz_de_conta'});

    final result = await roundRepository.startRound(size: 99);

    expect(result.created, isFalse);
    expect(result.selectedCount, 0);

    final activeRound = await (db.select(db.rounds)
          ..where((r) => r.endAt.isNull()))
        .getSingleOrNull();
    expect(activeRound, isNull);
  });

  test('startRound nao cria rodada apenas com brinquedo fora das categorias',
      () async {
    await _setCategoryState(toyRepository, 'faz_de_conta',
        included: true, quota: 2);
    await _setAllOthersExcluded(toyRepository, const {'faz_de_conta'});

    await _insertToy(db, id: 'l1', categoryId: 'livros', createdAt: 100);

    final result = await roundRepository.startRound();

    expect(result.created, isFalse);
    expect(result.selectedCount, 0);

    final activeRound = await (db.select(db.rounds)
          ..where((r) => r.endAt.isNull()))
        .getSingleOrNull();
    expect(activeRound, isNull);
  });
}

Future<void> _setAllOthersExcluded(
  ToyRepository repository,
  Set<String> keepIncluded,
) async {
  final d = repository.db;
  if (d == null) throw StateError('db nulo');
  final all = await d.select(d.categoryDefinitions).get();
  for (final c in all) {
    if (keepIncluded.contains(c.id)) continue;
    await repository.setCategoryIncludedInRound(
      categoryId: c.id,
      isIncluded: false,
    );
    await repository.setCategoryQuotaInRound(
      categoryId: c.id,
      quota: 0,
    );
  }
}

Future<void> _setCategoryState(
  ToyRepository repository,
  String categoryId, {
  required bool included,
  required int quota,
}) async {
  await repository.setCategoryIncludedInRound(
    categoryId: categoryId,
    isIncluded: included,
  );
  await repository.setCategoryQuotaInRound(
    categoryId: categoryId,
    quota: quota,
  );
}

Future<void> _insertToy(
  AppDatabase db, {
  required String id,
  required String categoryId,
  required int createdAt,
}) async {
  await db.into(db.toys).insert(
        ToysCompanion.insert(
          id: id,
          categoryId: Value(categoryId),
          name: 'Toy $id',
          createdAt: createdAt,
          boxId: const Value(null),
          locationText: const Value(null),
          photoPath: const Value(null),
        ),
      );
}

Future<void> _insertOfficialToys(
  AppDatabase db, {
  int countPerCategory = 20,
}) async {
  const categoryIds = <String>[
    'corpo',
    'maos',
    'imaginacao',
    'comunicacao',
    'exploracao',
  ];
  var createdAt = 10000;
  for (final categoryId in categoryIds) {
    for (var index = 0; index < countPerCategory; index++) {
      await _insertToy(
        db,
        id: 'official_${categoryId}_$index',
        categoryId: categoryId,
        createdAt: createdAt,
      );
      createdAt++;
    }
  }
}

Future<void> _overwriteRoundCategoryQuotas(
  AppDatabase db,
  Map<String, int> quotasByCategoryId,
) async {
  for (final entry in quotasByCategoryId.entries) {
    await db.into(db.roundCategorySettings).insertOnConflictUpdate(
          RoundCategorySettingsCompanion.insert(
            categoryId: entry.key,
            isIncluded: Value(entry.value > 0),
            quota: Value(entry.value),
          ),
        );
  }
}

Future<void> _writeStaleWeeklyCustomQuotas(AppDatabase db) async {
  const quotasByCategoryId = <String, int>{
    'livros': 1,
    'construcao': 2,
    'faz_de_conta': 1,
    'movimento': 1,
    'coordenacao': 2,
    'corpo': 1,
    'maos': 1,
    'imaginacao': 1,
    'comunicacao': 1,
    'exploracao': 1,
  };

  for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
    await db.into(db.weeklyPlanningSettings).insertOnConflictUpdate(
          WeeklyPlanningSettingsCompanion.insert(
            weekday: Value(weekday),
            useDefault: const Value(false),
            customSize: const Value(null),
          ),
        );

    for (final entry in quotasByCategoryId.entries) {
      await db.into(db.weeklyPlanningCategorySettings).insertOnConflictUpdate(
            WeeklyPlanningCategorySettingsCompanion.insert(
              weekday: weekday,
              categoryId: entry.key,
              isIncluded: Value(entry.value > 0),
              quota: Value(entry.value),
            ),
          );
    }
  }
}

Map<String, int> _categoryCountsForToys(List<Toy> toys) {
  final result = <String, int>{};
  for (final toy in toys) {
    final categoryId = toy.categoryId.trim();
    if (categoryId.isEmpty) continue;
    result[categoryId] = (result[categoryId] ?? 0) + 1;
  }
  return result;
}

Future<Map<String, int>> _selectedCategoryCounts(AppDatabase db) async {
  final selectedIds = await _selectedToyIdsByPosition(db);
  if (selectedIds.isEmpty) return const <String, int>{};

  final toys = await (db.select(db.toys)
        ..where((toy) => toy.id.isIn(selectedIds)))
      .get();
  return _categoryCountsForToys(toys);
}

Future<List<String>> _selectedToyIdsByPosition(AppDatabase db) async {
  final activeRound =
      await (db.select(db.rounds)..where((r) => r.endAt.isNull())).getSingle();

  final rows = await (db.select(db.roundToys)
        ..where((rt) => rt.roundId.equals(activeRound.id))
        ..orderBy([(rt) => OrderingTerm.asc(rt.position)]))
      .get();

  return rows.map((e) => e.toyId).toList();
}
