import 'package:drift/drift.dart' show InsertMode, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/age_preset.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/child_age_range.dart';
import 'package:rodizio_brinquedos_v3/services/age_preset_service.dart';

void main() {
  late AppDatabase db;
  late ToyRepository toyRepository;
  late WeeklyPlanningRepository weeklyPlanningRepository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    toyRepository = ToyRepository(db);
    weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: SettingsRepository(db),
    );
    await toyRepository.ensureSeedData();
    await toyRepository.restoreRoundCategoryDefaults();
  });

  tearDown(() async {
    await db.close();
  });

  test('restaurar planejamento deixa todos os dias com 7 brinquedos', () async {
    await toyRepository.setCategoryQuotaInRound(
      categoryId: 'exploracao',
      quota: 5,
    );
    await toyRepository.setCategoryQuotaInRound(
      categoryId: 'maos',
      quota: 5,
    );
    await toyRepository.setCategoryQuotaInRound(
      categoryId: 'imaginacao',
      quota: 5,
    );
    await weeklyPlanningRepository.setUseDefault(
      weekday: DateTime.monday,
      useDefault: false,
    );
    await weeklyPlanningRepository.updateCategoryConfig(
      weekday: DateTime.monday,
      categoryId: 'exploracao',
      isIncluded: true,
      quota: 3,
    );
    await weeklyPlanningRepository.updateCategoryConfig(
      weekday: DateTime.monday,
      categoryId: 'maos',
      isIncluded: true,
      quota: 3,
    );
    await db.into(db.weeklyPlanningSettings).insertOnConflictUpdate(
          WeeklyPlanningSettingsCompanion.insert(
            weekday: const Value(DateTime.tuesday),
            useDefault: const Value(false),
            customSize: const Value(null),
          ),
        );

    await weeklyPlanningRepository.restoreDefaultWeek();

    final weeklyCategoryRows =
        await db.select(db.weeklyPlanningCategorySettings).get();
    final days = await weeklyPlanningRepository.getAll();
    final summary = await weeklyPlanningRepository.watchWeekSummary().first;

    expect(weeklyCategoryRows, isEmpty);
    expect(days, hasLength(7));
    for (final day in days) {
      expect(day.useDefault, isTrue);
      expect(day.total, 7);
    }
    for (final day in summary) {
      expect(day.totalToys, 7);
    }
  });

  test('sugere ajuste para categoria menos presente com brinquedos', () async {
    final now = DateTime(2026, 5, 4);
    await _insertToy(db, id: 'comunicacao_1', categoryId: 'comunicacao');
    await _insertToy(db, id: 'corpo_1', categoryId: 'corpo');
    await _insertRoundWithToy(
      db,
      roundId: 'round_1',
      toyId: 'comunicacao_1',
      startAt: now.subtract(const Duration(days: 1)),
    );

    final suggestion = await weeklyPlanningRepository
        .suggestCategoryBalanceAdjustment(now: now);

    expect(suggestion, isNotNull);
    expect(suggestion!.categoryId, 'corpo');
    expect(suggestion.deltaQuota, 1);
    expect(suggestion.targetWeekday, DateTime.tuesday);
    expect(
      suggestion.message,
      contains('Deseja incluir mais 1 brinquedo'),
    );
  });

  test('aplica sugestao sem aumentar o total acima de 7', () async {
    const suggestion = CategoryBalanceAdjustmentSuggestion(
      categoryId: 'corpo',
      categoryName: 'Corpo e Respiração',
      message: 'Corpo e Respiração apareceu pouco esta semana.',
      targetWeekday: DateTime.tuesday,
    );

    await weeklyPlanningRepository.applyCategoryBalanceAdjustment(suggestion);

    final day = await weeklyPlanningRepository.getByWeekday(DateTime.tuesday);
    final body = day!.categories
        .where((category) => category.categoryId == 'corpo')
        .single;

    expect(day.useDefault, isFalse);
    expect(day.total, 7);
    expect(body.isIncluded, isTrue);
    expect(body.safeQuota, 2);
  });

  test('dia que vira proprio copia o preset base atual', () async {
    await weeklyPlanningRepository.ensureSeeded();

    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    final repository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    final agePresetService = AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    );

    await agePresetService.applyAgePreset(ChildAgeRange.years2To3);
    await repository.setUseDefault(
      weekday: DateTime.monday,
      useDefault: false,
    );

    final monday = await repository.getByWeekday(DateTime.monday);
    final quotas = _quotasByCategoryId(monday!.categories);
    final included = _includedByCategoryId(monday.categories);

    expect(monday.useDefault, isFalse);
    expect(monday.total, 8);
    expect(quotas['corpo'], 2);
    expect(quotas['maos'], 2);
    expect(quotas['imaginacao'], 2);
    expect(quotas['comunicacao'], 1);
    expect(quotas['exploracao'], 1);
    expect(included['comunicacao'], isTrue);
    expect(quotas['comunicacao'], 1);
    expect(quotas.containsKey('livros'), isFalse);

    settingsRepository.dispose();
  });

  test('sugestao em dia default parte do preset base efetivo', () async {
    await weeklyPlanningRepository.ensureSeeded();

    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    final repository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    final agePresetService = AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    );

    await agePresetService.applyAgePreset(ChildAgeRange.years2To3);
    await repository.applyCategoryBalanceAdjustment(
      const CategoryBalanceAdjustmentSuggestion(
        categoryId: 'corpo',
        categoryName: 'Corpo e Respiração',
        message: 'Corpo apareceu pouco.',
        targetWeekday: DateTime.monday,
      ),
    );

    final monday = await repository.getByWeekday(DateTime.monday);
    final quotas = _quotasByCategoryId(monday!.categories);
    final included = _includedByCategoryId(monday.categories);

    expect(monday.useDefault, isFalse);
    expect(monday.total, 8);
    expect(quotas['corpo'], 3);
    expect(included['comunicacao'], isTrue);
    expect(quotas['comunicacao'], 1);
    expect(quotas.containsKey('livros'), isFalse);

    settingsRepository.dispose();
  });

  test('resumo semanal usa faixa etaria em vez de cota bruta antiga', () async {
    await weeklyPlanningRepository.ensureSeeded();

    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    final repository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    await AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    ).applyAgePreset(ChildAgeRange.months6To12);
    await _overwriteRoundCategoryQuotas(db, const {
      'corpo': 2,
      'maos': 3,
      'imaginacao': 3,
      'comunicacao': 2,
      'exploracao': 2,
    });

    final rawDefault = await repository.getDefaultCategoryConfig();
    final mondayConfig = await repository.resolveCategoryConfigForDate(
      DateTime(2026, 1, 5),
    );
    final summary = await repository.watchWeekSummary().first;
    final preset = AgePresetCatalog.presetFor(ChildAgeRange.months6To12);

    expect(_totalFor(rawDefault), 12);
    expect(_totalFor(mondayConfig), preset.totalForWeekday(DateTime.monday));
    for (final day in summary) {
      expect(
        day.totalToys,
        preset.totalForWeekday(day.weekday),
        reason: 'weekday ${day.weekday}',
      );
    }

    settingsRepository.dispose();
  });

  test('resumo semanal ignora copia antiga que soma categorias duplicadas',
      () async {
    await weeklyPlanningRepository.ensureSeeded();

    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    final repository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
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
    await _writeStaleWeeklyCustomQuotas(db);

    final rawMonday = await repository.getByWeekday(DateTime.monday);
    final rawDefault = await repository.getDefaultCategoryConfig();
    final mondayConfig = await repository.resolveCategoryConfigForDate(
      DateTime(2026, 1, 5),
    );
    final summary = await repository.watchWeekSummary().first;

    expect(rawMonday!.useDefault, isFalse);
    expect(rawMonday.total, 5);
    expect(_totalFor(rawDefault), 5);
    expect(_totalFor(mondayConfig), _totalFor(rawDefault));
    for (final day in summary) {
      expect(
        day.totalToys,
        _totalFor(rawDefault),
        reason: 'weekday ${day.weekday}',
      );
    }

    settingsRepository.dispose();
  });

  test('resumo semanal aplica faixa etaria sobre copia antiga duplicada',
      () async {
    await weeklyPlanningRepository.ensureSeeded();

    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    final repository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    await AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    ).applyAgePreset(ChildAgeRange.months0To6);
    await _writeStaleWeeklyCustomQuotas(db);

    final rawMonday = await repository.getByWeekday(DateTime.monday);
    final mondayConfig = await repository.resolveCategoryConfigForDate(
      DateTime(2026, 1, 5),
    );
    final summary = await repository.watchWeekSummary().first;
    final preset = AgePresetCatalog.presetFor(ChildAgeRange.months0To6);

    expect(rawMonday!.useDefault, isFalse);
    expect(rawMonday.total, 5);
    expect(_totalFor(mondayConfig), preset.totalForWeekday(DateTime.monday));
    for (final day in summary) {
      expect(
        day.totalToys,
        preset.totalForWeekday(day.weekday),
        reason: 'weekday ${day.weekday}',
      );
    }

    settingsRepository.dispose();
  });

  test('resumo semanal ignora planejamento demo travado em 5 por idade',
      () async {
    await weeklyPlanningRepository.ensureSeeded();

    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    final repository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    await AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    ).applyAgePreset(ChildAgeRange.years3To5);
    await _writeLegacyDemoFixedFiveWeeklyPlanning(db);

    final rawFriday = await repository.getByWeekday(DateTime.friday);
    final fridayConfig = await repository.resolveCategoryConfigForDate(
      DateTime(2026, 6, 26),
    );
    final summary = await repository.watchWeekSummary().first;
    final preset = AgePresetCatalog.presetFor(ChildAgeRange.years3To5);

    expect(rawFriday!.useDefault, isFalse);
    expect(rawFriday.total, 5);
    expect(_totalFor(fridayConfig), 9);
    for (final day in summary) {
      expect(
        day.totalToys,
        preset.totalForWeekday(day.weekday),
        reason: 'weekday ${day.weekday}',
      );
    }

    settingsRepository.dispose();
  });

  test('resumo semanal preserva customizacao real com total diferente',
      () async {
    await weeklyPlanningRepository.ensureSeeded();

    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    final repository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    await AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    ).applyAgePreset(ChildAgeRange.years3To5);
    await _writeFridayCustomQuotas(db, const {
      'corpo': 0,
      'exploracao': 0,
      'maos': 3,
      'imaginacao': 3,
      'comunicacao': 0,
    });

    final fridayConfig = await repository.resolveCategoryConfigForDate(
      DateTime(2026, 6, 26),
    );
    final quotas = _quotasByCategoryId(fridayConfig);

    expect(_totalFor(fridayConfig), 6);
    expect(quotas['maos'], 3);
    expect(quotas['imaginacao'], 3);

    settingsRepository.dispose();
  });
}

Future<void> _insertToy(
  AppDatabase db, {
  required String id,
  required String categoryId,
}) {
  return db.into(db.toys).insert(
        ToysCompanion.insert(
          id: id,
          categoryId: Value(categoryId),
          name: id,
          createdAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
        ),
      );
}

Future<void> _insertRoundWithToy(
  AppDatabase db, {
  required String roundId,
  required String toyId,
  required DateTime startAt,
}) async {
  await db.into(db.rounds).insert(
        RoundsCompanion.insert(
          id: roundId,
          startAt: startAt.millisecondsSinceEpoch,
        ),
      );
  await db.into(db.roundToys).insert(
        RoundToysCompanion.insert(
          roundId: roundId,
          toyId: toyId,
          position: 0,
        ),
      );
}

Map<String, int> _quotasByCategoryId(
  List<WeeklyPlanningCategoryConfig> categories,
) {
  return {
    for (final category in categories) category.categoryId: category.safeQuota,
  };
}

Map<String, bool> _includedByCategoryId(
  List<WeeklyPlanningCategoryConfig> categories,
) {
  return {
    for (final category in categories) category.categoryId: category.isIncluded,
  };
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
  await _insertLegacyCategories(db);

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

Future<void> _writeLegacyDemoFixedFiveWeeklyPlanning(AppDatabase db) async {
  const categoryIds = <String>[
    'corpo',
    'exploracao',
    'maos',
    'imaginacao',
    'comunicacao',
  ];

  for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
    await db.into(db.weeklyPlanningSettings).insertOnConflictUpdate(
          WeeklyPlanningSettingsCompanion.insert(
            weekday: Value(weekday),
            useDefault: const Value(false),
            customSize: const Value(null),
          ),
        );

    for (final categoryId in categoryIds) {
      await db.into(db.weeklyPlanningCategorySettings).insertOnConflictUpdate(
            WeeklyPlanningCategorySettingsCompanion.insert(
              weekday: weekday,
              categoryId: categoryId,
              isIncluded: const Value(true),
              quota: const Value(1),
            ),
          );
    }
  }
}

Future<void> _writeFridayCustomQuotas(
  AppDatabase db,
  Map<String, int> quotasByCategoryId,
) async {
  await db.into(db.weeklyPlanningSettings).insertOnConflictUpdate(
        WeeklyPlanningSettingsCompanion.insert(
          weekday: const Value(DateTime.friday),
          useDefault: const Value(false),
          customSize: const Value(null),
        ),
      );

  for (final entry in quotasByCategoryId.entries) {
    await db.into(db.weeklyPlanningCategorySettings).insertOnConflictUpdate(
          WeeklyPlanningCategorySettingsCompanion.insert(
            weekday: DateTime.friday,
            categoryId: entry.key,
            isIncluded: Value(entry.value > 0),
            quota: Value(entry.value),
          ),
        );
  }
}

Future<void> _insertLegacyCategories(AppDatabase db) async {
  const categories = <({String id, String name, int sortOrder})>[
    (id: 'livros', name: 'Livros', sortOrder: 101),
    (id: 'construcao', name: 'Construção', sortOrder: 102),
    (id: 'faz_de_conta', name: 'Faz de conta', sortOrder: 103),
    (id: 'movimento', name: 'Movimento', sortOrder: 104),
    (id: 'coordenacao', name: 'Coordenação', sortOrder: 105),
  ];

  for (final category in categories) {
    await db.into(db.categoryDefinitions).insert(
          CategoryDefinitionsCompanion.insert(
            id: category.id,
            name: category.name,
            description: const Value(null),
            examples: const Value(null),
            developmentAspect: const Value(null),
            sortOrder: Value(category.sortOrder),
            isDefault: const Value(false),
            isActive: const Value(true),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await db.into(db.roundCategorySettings).insert(
          RoundCategorySettingsCompanion.insert(
            categoryId: category.id,
            isIncluded: const Value(false),
            quota: const Value(0),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }
}

int _totalFor(List<WeeklyPlanningCategoryConfig> categories) {
  var total = 0;
  for (final category in categories) {
    if (!category.isIncluded) continue;
    total += category.safeQuota;
  }
  return total;
}
