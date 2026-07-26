import 'package:drift/drift.dart' show InsertMode, OrderingTerm, Value;
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
    await _setCategoryState(toyRepository, 'imaginacao',
        included: true, quota: 2);
    await _setCategoryState(toyRepository, 'comunicacao',
        included: true, quota: 1);
    await _setAllOthersExcluded(
        toyRepository, const {'imaginacao', 'comunicacao'});

    await _insertToy(db, id: 'b1', categoryId: 'imaginacao', createdAt: 100);
    await _insertToy(db, id: 'b2', categoryId: 'imaginacao', createdAt: 200);
    await _insertToy(db, id: 'l1', categoryId: 'comunicacao', createdAt: 150);
    await _insertToy(db, id: 'j1', categoryId: 'maos', createdAt: 50);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['b1', 'l1', 'b2']);
  });

  test('startRound tolera falta sem buscar brinquedos fora das categorias',
      () async {
    await _setCategoryState(toyRepository, 'imaginacao',
        included: true, quota: 3);
    await _setCategoryState(toyRepository, 'comunicacao',
        included: true, quota: 2);
    await _setAllOthersExcluded(
        toyRepository, const {'imaginacao', 'comunicacao'});

    await _insertToy(db, id: 'b1', categoryId: 'imaginacao', createdAt: 100);
    await _insertToy(db, id: 'j1', categoryId: 'maos', createdAt: 50);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['b1']);
  });

  test('categoria com switch off fica fora da rodada', () async {
    await _setCategoryState(toyRepository, 'imaginacao',
        included: false, quota: 3);
    await _setCategoryState(toyRepository, 'comunicacao',
        included: true, quota: 1);
    await _setAllOthersExcluded(
        toyRepository, const {'imaginacao', 'comunicacao'});

    await _insertToy(db, id: 'b1', categoryId: 'imaginacao', createdAt: 100);
    await _insertToy(db, id: 'l1', categoryId: 'comunicacao', createdAt: 100);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['l1']);
  });

  test('startRound limita o total pela soma das cotas incluidas', () async {
    await _setCategoryState(toyRepository, 'imaginacao',
        included: true, quota: 1);
    await _setCategoryState(toyRepository, 'comunicacao',
        included: true, quota: 1);
    await _setAllOthersExcluded(
        toyRepository, const {'imaginacao', 'comunicacao'});

    await _insertToy(db, id: 'b1', categoryId: 'imaginacao', createdAt: 100);
    await _insertToy(db, id: 'b2', categoryId: 'imaginacao', createdAt: 200);
    await _insertToy(db, id: 'l1', categoryId: 'comunicacao', createdAt: 150);
    await _insertToy(db, id: 'l2', categoryId: 'comunicacao', createdAt: 250);
    await _insertToy(db, id: 'l3', categoryId: 'comunicacao', createdAt: 350);

    final result = await roundRepository.startRound();

    expect(result.created, isTrue);
    expect(result.selectedCount, 2);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['b1', 'l1']);
  });

  test('startRound evita a rodada anterior quando existem alternativas',
      () async {
    await _setCategoryState(toyRepository, 'corpo', included: true, quota: 1);
    await _setAllOthersExcluded(toyRepository, const {'corpo'});
    await _insertToy(db, id: 'anterior', categoryId: 'corpo', createdAt: 100);
    await _insertToy(db,
        id: 'alternativa', categoryId: 'corpo', createdAt: 200);
    await _insertHistoricalRound(
      db,
      id: 'round_previous',
      startAt: DateTime(2026, 1, 5, 12),
      toyIds: const ['anterior'],
    );

    final result = await roundRepository.startRound(
      date: DateTime(2026, 1, 6, 12),
    );

    expect(result.created, isTrue);
    expect(await _selectedToyIdsByPosition(db), ['alternativa']);
  });

  test('sugestao e criacao direta usam a mesma selecao', () async {
    await _setCategoryState(toyRepository, 'corpo', included: true, quota: 2);
    await _setAllOthersExcluded(toyRepository, const {'corpo'});
    await _insertToy(db, id: 'a', categoryId: 'corpo', createdAt: 100);
    await _insertToy(db, id: 'b', categoryId: 'corpo', createdAt: 200);
    await _insertToy(db, id: 'c', categoryId: 'corpo', createdAt: 300);
    await _insertHistoricalRound(
      db,
      id: 'round_previous',
      startAt: DateTime(2026, 1, 5, 12),
      toyIds: const ['a', 'b'],
    );
    final date = DateTime(2026, 1, 6, 12);

    final suggestion = await roundRepository.suggestRoundForDate(date);
    await roundRepository.startRound(date: date);

    expect(
      await _selectedToyIdsByPosition(db),
      suggestion.map((toy) => toy.id).toList(growable: false),
    );
  });

  test('historico prioriza nunca usado, recencia e menor total de usos',
      () async {
    await _setCategoryState(toyRepository, 'corpo', included: true, quota: 4);
    await _setAllOthersExcluded(toyRepository, const {'corpo'});
    await _insertToy(db,
        id: 'muito_usado', categoryId: 'corpo', createdAt: 100);
    await _insertToy(db,
        id: 'menos_usado', categoryId: 'corpo', createdAt: 200);
    await _insertToy(db, id: 'recente', categoryId: 'corpo', createdAt: 300);
    await _insertToy(db,
        id: 'nunca_usado', categoryId: 'corpo', createdAt: 400);

    await _insertHistoricalRound(
      db,
      id: 'round_old_1',
      startAt: DateTime(2025, 12, 1, 12),
      toyIds: const ['muito_usado'],
    );
    await _insertHistoricalRound(
      db,
      id: 'round_old_2',
      startAt: DateTime(2025, 12, 15, 12),
      toyIds: const ['muito_usado', 'menos_usado'],
    );
    await _insertHistoricalRound(
      db,
      id: 'round_recent',
      startAt: DateTime(2026, 1, 1, 12),
      toyIds: const ['recente'],
    );

    final suggestion = await roundRepository.suggestRoundForDate(
      DateTime(2026, 1, 10, 12),
    );

    expect(
      suggestion.map((toy) => toy.id),
      ['nunca_usado', 'menos_usado', 'muito_usado', 'recente'],
    );
  });

  test('planejamento semanal redistribui falta igual a sugestao diaria',
      () async {
    await _overwriteRoundCategoryQuotas(db, const {
      'corpo': 2,
      'exploracao': 2,
      'maos': 0,
      'imaginacao': 0,
      'comunicacao': 0,
    });
    for (var index = 0; index < 8; index++) {
      await _insertToy(
        db,
        id: 'corpo_$index',
        categoryId: 'corpo',
        createdAt: 100 + index,
      );
    }
    final monday = DateTime(2026, 1, 5, 12);

    final daily = await roundRepository.suggestRoundForDate(monday);
    final weekly = await roundRepository.suggestWeeklyPlanningForWeek(monday);

    expect(daily, hasLength(4));
    expect(weekly[DateTime.monday], hasLength(4));
  });

  test('categoria personalizada permanece fora da resolucao efetiva', () async {
    await toyRepository.addCategory(name: 'Personalizada');
    final categories = await db.select(db.categoryDefinitions).get();
    final custom = categories.singleWhere((category) {
      return category.name == 'Personalizada';
    });
    await toyRepository.setCategoryIncludedInRound(
      categoryId: custom.id,
      isIncluded: true,
    );
    await toyRepository.setCategoryQuotaInRound(
      categoryId: custom.id,
      quota: 2,
    );
    await _insertToy(
      db,
      id: 'custom_1',
      categoryId: custom.id,
      createdAt: 100,
    );

    final suggestion = await roundRepository.suggestRoundForDate(
      DateTime(2026, 1, 5, 12),
    );

    expect(suggestion.map((toy) => toy.id), isNot(contains('custom_1')));
  });

  test('confirmacao atualiza uma unica rodada efetiva no mesmo dia', () async {
    await _setCategoryState(toyRepository, 'corpo', included: true, quota: 2);
    await _setAllOthersExcluded(toyRepository, const {'corpo'});
    await _insertToy(db, id: 'a', categoryId: 'corpo', createdAt: 100);
    await _insertToy(db, id: 'b', categoryId: 'corpo', createdAt: 200);
    final date = DateTime(2026, 1, 5, 12);

    await roundRepository.setActiveRoundFromToyIds(['a'], date: date);
    await roundRepository.setActiveRoundFromToyIds(['b', 'b'], date: date);

    expect(await db.select(db.rounds).get(), hasLength(1));
    expect(await _selectedToyIdsByPosition(db), ['b']);
  });

  test('confirmacao em nova data cria nova entrada historica', () async {
    await _setCategoryState(toyRepository, 'corpo', included: true, quota: 1);
    await _setAllOthersExcluded(toyRepository, const {'corpo'});
    await _insertToy(db, id: 'a', categoryId: 'corpo', createdAt: 100);
    await _insertToy(db, id: 'b', categoryId: 'corpo', createdAt: 200);

    await roundRepository.setActiveRoundFromToyIds(
      ['a'],
      date: DateTime(2026, 1, 5, 12),
    );
    await roundRepository.setActiveRoundFromToyIds(
      ['b'],
      date: DateTime(2026, 1, 6, 12),
    );

    final rounds = await (db.select(db.rounds)
          ..orderBy([(round) => OrderingTerm.asc(round.startAt)]))
        .get();
    expect(rounds, hasLength(2));
    expect(rounds.first.endAt, isNotNull);
    expect(rounds.last.endAt, isNull);
  });

  test('confirmacao rejeita ID inexistente', () async {
    await expectLater(
      roundRepository.setActiveRoundFromToyIds(
        ['nao_existe'],
        date: DateTime(2026, 1, 5, 12),
      ),
      throwsStateError,
    );
    expect(await db.select(db.rounds).get(), isEmpty);
  });

  test('confirmacao rejeita brinquedo de categoria inativa', () async {
    await _insertToy(db, id: 'inativo', categoryId: 'corpo', createdAt: 100);
    await (db.update(db.categoryDefinitions)
          ..where((category) => category.id.equals('corpo')))
        .write(
      const CategoryDefinitionsCompanion(isActive: Value(false)),
    );

    await expectLater(
      roundRepository.setActiveRoundFromToyIds(
        ['inativo'],
        date: DateTime(2026, 1, 5, 12),
      ),
      throwsStateError,
    );
  });

  test('confirmacao rejeita categoria fora da configuracao da data', () async {
    await _setAllOthersExcluded(toyRepository, const <String>{});
    await _insertToy(db, id: 'fora', categoryId: 'corpo', createdAt: 100);

    await expectLater(
      roundRepository.setActiveRoundFromToyIds(
        ['fora'],
        date: DateTime(2026, 1, 5, 12),
      ),
      throwsStateError,
    );
  });

  test('createdAt e ID produzem desempate deterministico', () async {
    await _setCategoryState(toyRepository, 'corpo', included: true, quota: 3);
    await _setAllOthersExcluded(toyRepository, const {'corpo'});
    await _insertToy(db, id: 'z', categoryId: 'corpo', createdAt: 50);
    await _insertToy(db, id: 'b', categoryId: 'corpo', createdAt: 100);
    await _insertToy(db, id: 'a', categoryId: 'corpo', createdAt: 100);
    final date = DateTime(2026, 1, 5, 12);

    final first = await roundRepository.suggestRoundForDate(date);
    final second = await roundRepository.suggestRoundForDate(date);

    expect(first.map((toy) => toy.id), ['z', 'a', 'b']);
    expect(second.map((toy) => toy.id), ['z', 'a', 'b']);
  });

  test('catalogo menor que total retorna todos sem duplicar', () async {
    await _setCategoryState(toyRepository, 'corpo', included: true, quota: 5);
    await _setAllOthersExcluded(toyRepository, const {'corpo'});
    await _insertToy(db, id: 'unico', categoryId: 'corpo', createdAt: 100);

    final suggestion = await roundRepository.suggestRoundForDate(
      DateTime(2026, 1, 5, 12),
    );

    expect(suggestion.map((toy) => toy.id), ['unico']);
  });

  test('redistribuicao escolhe menor proporcao selecionados por cota',
      () async {
    await _overwriteRoundCategoryQuotas(db, const {
      'corpo': 3,
      'exploracao': 3,
      'maos': 2,
      'imaginacao': 0,
      'comunicacao': 0,
    });
    await _insertOfficialToysForCategories(
      db,
      const ['corpo', 'maos'],
      countPerCategory: 10,
    );
    await _insertToy(
      db,
      id: 'exploracao_unico',
      categoryId: 'exploracao',
      createdAt: 50000,
    );

    final suggestion = await roundRepository.suggestRoundForDate(
      DateTime(2026, 1, 5, 12),
    );

    expect(_categoryCountsForToys(suggestion), {
      'corpo': 4,
      'exploracao': 1,
      'maos': 3,
    });
  });

  test('planejamento semanal repete quando nao existe alternativa', () async {
    await _overwriteRoundCategoryQuotas(db, const {
      'corpo': 1,
      'exploracao': 0,
      'maos': 0,
      'imaginacao': 0,
      'comunicacao': 0,
    });
    await _insertToy(db, id: 'unico', categoryId: 'corpo', createdAt: 100);

    final week = await roundRepository.suggestWeeklyPlanningForWeek(
      DateTime(2026, 1, 5, 12),
    );

    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      expect(week[weekday]!.map((toy) => toy.id), ['unico']);
    }
  });

  test('todas as faixas preservam totais base e adicionais do fim de semana',
      () async {
    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    await _insertOfficialToys(db);
    final service = AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    );
    final monday = DateTime(2026, 1, 5, 12);

    for (final ageRange in ChildAgeRange.values) {
      await service.applyAgePreset(ageRange);
      final preset = AgePresetCatalog.presetFor(ageRange);

      expect(
        await roundRepository.suggestRoundForDate(monday),
        hasLength(preset.total),
        reason: ageRange.storageValue,
      );
      expect(
        await roundRepository.suggestRoundForDate(
          monday.add(const Duration(days: 5)),
        ),
        hasLength(preset.total + 1),
        reason: '${ageRange.storageValue} saturday',
      );
      expect(
        await roundRepository.suggestRoundForDate(
          monday.add(const Duration(days: 6)),
        ),
        hasLength(preset.total + 1),
        reason: '${ageRange.storageValue} sunday',
      );
    }

    settingsRepository.dispose();
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

  test('suggestRoundForDate ignora planejamento demo travado em 5 para 3 a 5',
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
    ).applyAgePreset(ChildAgeRange.years3To5);
    await _insertOfficialToys(db);
    await _writeLegacyDemoFixedFiveWeeklyPlanning(db);

    final suggestion =
        await roundRepository.suggestRoundForDate(DateTime(2026, 6, 26));
    final counts = _categoryCountsForToys(suggestion);

    expect(suggestion, hasLength(9));
    expect(counts['corpo'], 1);
    expect(counts['exploracao'], 2);
    expect(counts['maos'], 2);
    expect(counts['imaginacao'], 2);
    expect(counts['comunicacao'], 2);

    await roundRepository.setActiveRoundFromToyIds(
      suggestion.map((toy) => toy.id).toList(growable: false),
    );
    expect(await _selectedToyIdsByPosition(db), hasLength(9));

    settingsRepository.dispose();
  });

  test('suggestRoundForDate ignora planejamento demo travado em 5 para 5 a 7',
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
    ).applyAgePreset(ChildAgeRange.years5To7);
    await _insertOfficialToys(db);
    await _writeLegacyDemoFixedFiveWeeklyPlanning(db);

    final suggestion =
        await roundRepository.suggestRoundForDate(DateTime(2026, 6, 26));
    final counts = _categoryCountsForToys(suggestion);

    expect(suggestion, hasLength(10));
    expect(counts['corpo'], 1);
    expect(counts['exploracao'], 2);
    expect(counts['maos'], 2);
    expect(counts['imaginacao'], 3);
    expect(counts['comunicacao'], 2);

    await roundRepository.setActiveRoundFromToyIds(
      suggestion.map((toy) => toy.id).toList(growable: false),
    );
    expect(await _selectedToyIdsByPosition(db), hasLength(10));

    settingsRepository.dispose();
  });

  test('suggestRoundForDate completa total da idade com categoria vazia',
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
    ).applyAgePreset(ChildAgeRange.years5To7);
    await _insertOfficialToysForCategories(
      db,
      const ['corpo', 'exploracao', 'maos', 'imaginacao'],
    );
    await _writeLegacyDemoFixedFiveWeeklyPlanning(db);

    final suggestion =
        await roundRepository.suggestRoundForDate(DateTime(2026, 6, 26));
    final counts = _categoryCountsForToys(suggestion);

    expect(suggestion, hasLength(10));
    expect(counts.containsKey('comunicacao'), isFalse);
    expect(
        counts.keys,
        containsAll(<String>[
          'corpo',
          'exploracao',
          'maos',
          'imaginacao',
        ]));

    settingsRepository.dispose();
  });

  test('suggestWeeklyPlanningForWeek distribui brinquedos antes de repetir',
      () async {
    await _overwriteRoundCategoryQuotas(db, const {
      'corpo': 2,
      'exploracao': 2,
      'maos': 2,
      'imaginacao': 2,
      'comunicacao': 2,
    });
    await _insertWeeklyPlanningToys(db, countPerCategory: 10);

    final week = await roundRepository.suggestWeeklyPlanningForWeek(
      DateTime(2026, 1, 5),
    );

    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      expect(week[weekday], hasLength(10), reason: 'weekday $weekday');
    }

    final mondayIds = week[DateTime.monday]!.map((toy) => toy.id).toSet();
    final tuesdayIds = week[DateTime.tuesday]!.map((toy) => toy.id).toSet();
    expect(mondayIds.intersection(tuesdayIds), isEmpty);

    final firstFiveDaysIds = <String>{};
    for (var weekday = DateTime.monday; weekday <= DateTime.friday; weekday++) {
      firstFiveDaysIds.addAll(week[weekday]!.map((toy) => toy.id));
    }
    expect(firstFiveDaysIds, hasLength(50));

    for (var weekday = DateTime.tuesday;
        weekday <= DateTime.sunday;
        weekday++) {
      final previousIds = week[weekday - 1]!.map((toy) => toy.id).toSet();
      final currentIds = week[weekday]!.map((toy) => toy.id).toSet();
      expect(
        previousIds.intersection(currentIds),
        isEmpty,
        reason: 'weekday $weekday should avoid consecutive repeats',
      );
    }
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

  test('suggestRoundForDate inclui uma categoria oficial antes de extras',
      () async {
    await _overwriteRoundCategoryQuotas(db, const {
      'corpo': 3,
      'exploracao': 1,
      'maos': 1,
      'imaginacao': 1,
      'comunicacao': 1,
    });

    await _insertToy(db, id: 'c1', categoryId: 'corpo', createdAt: 100);
    await _insertToy(db, id: 'c2', categoryId: 'corpo', createdAt: 200);
    await _insertToy(db, id: 'c3', categoryId: 'corpo', createdAt: 300);
    await _insertToy(db, id: 'e1', categoryId: 'exploracao', createdAt: 400);
    await _insertToy(db, id: 'm1', categoryId: 'maos', createdAt: 500);
    await _insertToy(db, id: 'i1', categoryId: 'imaginacao', createdAt: 600);
    await _insertToy(db, id: 'h1', categoryId: 'comunicacao', createdAt: 700);

    final suggestion =
        await roundRepository.suggestRoundForDate(DateTime(2026, 1, 5));
    final counts = _categoryCountsForToys(suggestion);

    expect(suggestion, hasLength(7));
    expect(counts['corpo'], 3);
    expect(counts['exploracao'], 1);
    expect(counts['maos'], 1);
    expect(counts['imaginacao'], 1);
    expect(counts['comunicacao'], 1);
  });

  test('suggestRoundForDate completa total quando categoria oficial esta vazia',
      () async {
    await _overwriteRoundCategoryQuotas(db, const {
      'corpo': 2,
      'exploracao': 1,
      'maos': 1,
      'imaginacao': 1,
      'comunicacao': 1,
    });

    await _insertToy(db, id: 'c1', categoryId: 'corpo', createdAt: 100);
    await _insertToy(db, id: 'c2', categoryId: 'corpo', createdAt: 200);
    await _insertToy(db, id: 'c3', categoryId: 'corpo', createdAt: 300);
    await _insertToy(db, id: 'e1', categoryId: 'exploracao', createdAt: 400);
    await _insertToy(db, id: 'm1', categoryId: 'maos', createdAt: 500);
    await _insertToy(db, id: 'i1', categoryId: 'imaginacao', createdAt: 600);

    final suggestion =
        await roundRepository.suggestRoundForDate(DateTime(2026, 1, 5));
    final counts = _categoryCountsForToys(suggestion);

    expect(suggestion, hasLength(6));
    expect(counts['corpo'], 3);
    expect(counts['exploracao'], 1);
    expect(counts['maos'], 1);
    expect(counts['imaginacao'], 1);
    expect(counts.containsKey('comunicacao'), isFalse);
  });

  test('startRound nao cria rodada quando nao ha brinquedos cadastrados',
      () async {
    await _setCategoryState(toyRepository, 'imaginacao',
        included: true, quota: 2);
    await _setAllOthersExcluded(toyRepository, const {'imaginacao'});

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
    await _setCategoryState(toyRepository, 'imaginacao',
        included: true, quota: 2);
    await _setAllOthersExcluded(toyRepository, const {'imaginacao'});

    await _insertToy(db, id: 'l1', categoryId: 'comunicacao', createdAt: 100);

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

Future<void> _insertHistoricalRound(
  AppDatabase db, {
  required String id,
  required DateTime startAt,
  required List<String> toyIds,
}) async {
  await db.into(db.rounds).insert(
        RoundsCompanion.insert(
          id: id,
          startAt: startAt.millisecondsSinceEpoch,
          endAt: Value(
              startAt.add(const Duration(hours: 1)).millisecondsSinceEpoch),
        ),
      );
  for (var index = 0; index < toyIds.length; index++) {
    await db.into(db.roundToys).insert(
          RoundToysCompanion.insert(
            roundId: id,
            toyId: toyIds[index],
            position: index,
          ),
        );
  }
}

Future<void> _insertOfficialToys(
  AppDatabase db, {
  int countPerCategory = 20,
}) async {
  return _insertOfficialToysForCategories(
    db,
    const ['corpo', 'exploracao', 'maos', 'imaginacao', 'comunicacao'],
    countPerCategory: countPerCategory,
  );
}

Future<void> _insertOfficialToysForCategories(
  AppDatabase db,
  List<String> categoryIds, {
  int countPerCategory = 20,
}) async {
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

Future<void> _insertWeeklyPlanningToys(
  AppDatabase db, {
  required int countPerCategory,
}) async {
  const categoryIds = <String>[
    'corpo',
    'exploracao',
    'maos',
    'imaginacao',
    'comunicacao',
  ];
  var createdAt = 20000;
  for (final categoryId in categoryIds) {
    for (var index = 0; index < countPerCategory; index++) {
      await _insertToy(
        db,
        id: 'planning_${categoryId}_$index',
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
