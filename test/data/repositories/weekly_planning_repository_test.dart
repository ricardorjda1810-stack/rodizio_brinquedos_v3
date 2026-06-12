import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
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
      categoryId: 'coordenacao',
      quota: 5,
    );
    await toyRepository.setCategoryQuotaInRound(
      categoryId: 'construcao',
      quota: 5,
    );
    await toyRepository.setCategoryQuotaInRound(
      categoryId: 'faz_de_conta',
      quota: 5,
    );
    await weeklyPlanningRepository.setUseDefault(
      weekday: DateTime.monday,
      useDefault: false,
    );
    await weeklyPlanningRepository.updateCategoryConfig(
      weekday: DateTime.monday,
      categoryId: 'coordenacao',
      isIncluded: true,
      quota: 3,
    );
    await weeklyPlanningRepository.updateCategoryConfig(
      weekday: DateTime.monday,
      categoryId: 'construcao',
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
    await _insertToy(db, id: 'livro_1', categoryId: 'livros');
    await _insertToy(db, id: 'movimento_1', categoryId: 'movimento');
    await _insertRoundWithToy(
      db,
      roundId: 'round_1',
      toyId: 'livro_1',
      startAt: now.subtract(const Duration(days: 1)),
    );

    final suggestion = await weeklyPlanningRepository
        .suggestCategoryBalanceAdjustment(now: now);

    expect(suggestion, isNotNull);
    expect(suggestion!.categoryId, 'movimento');
    expect(suggestion.deltaQuota, 1);
    expect(suggestion.targetWeekday, DateTime.tuesday);
    expect(
      suggestion.message,
      contains('Deseja incluir mais 1 brinquedo'),
    );
  });

  test('aplica sugestao sem aumentar o total acima de 7', () async {
    const suggestion = CategoryBalanceAdjustmentSuggestion(
      categoryId: 'movimento',
      categoryName: 'Movimento',
      message: 'Movimento apareceu pouco esta semana.',
      targetWeekday: DateTime.tuesday,
    );

    await weeklyPlanningRepository.applyCategoryBalanceAdjustment(suggestion);

    final day = await weeklyPlanningRepository.getByWeekday(DateTime.tuesday);
    final movement = day!.categories
        .where((category) => category.categoryId == 'movimento')
        .single;

    expect(day.useDefault, isFalse);
    expect(day.total, 7);
    expect(movement.isIncluded, isTrue);
    expect(movement.safeQuota, 2);
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
    expect(included['livros'], isFalse);
    expect(quotas['livros'], 0);

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
        categoryName: 'Corpo',
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
    expect(included['livros'], isFalse);
    expect(quotas['livros'], 0);

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
