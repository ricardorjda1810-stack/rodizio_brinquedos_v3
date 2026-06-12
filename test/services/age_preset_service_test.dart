import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/age_preset.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/child_age_range.dart';
import 'package:rodizio_brinquedos_v3/domain/weekly_planning/week_day_summary.dart';
import 'package:rodizio_brinquedos_v3/services/age_preset_service.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settingsRepository;
  late AgePresetService service;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settingsRepository = SettingsRepository(db);
    service = AgePresetService(
      db: db,
      settingsRepository: settingsRepository,
    );
    await settingsRepository.load();
  });

  tearDown(() async {
    settingsRepository.dispose();
    await db.close();
  });

  test('applyAgePreset cria categorias oficiais ausentes', () async {
    await service.applyAgePreset(ChildAgeRange.months0To6);

    final categories = await db.select(db.categoryDefinitions).get();
    final names = categories.map((category) => category.name).toSet();

    expect(
      names,
      containsAll(<String>[
        'Corpo',
        'Mãos',
        'Imaginação',
        'Comunicação',
        'Exploração',
      ]),
    );
  });

  test('applyAgePreset nao duplica categorias oficiais existentes', () async {
    await _insertCategory(db, id: 'categoria_corpo_existente', name: 'Corpo');

    await service.applyAgePreset(ChildAgeRange.months6To12);

    final categories = await db.select(db.categoryDefinitions).get();
    final corpoCategories = categories
        .where((category) => _normalize(category.name) == 'corpo')
        .toList();
    final setting = await _roundSetting(db, 'categoria_corpo_existente');

    expect(corpoCategories, hasLength(1));
    expect(corpoCategories.single.id, 'categoria_corpo_existente');
    expect(setting?.quota, 1);
    expect(setting?.isIncluded, isTrue);
  });

  test('applyAgePreset nao apaga categorias personalizadas', () async {
    await _insertCategory(
      db,
      id: 'cat_personalizada',
      name: 'Brinquedos do quintal',
    );

    await service.applyAgePreset(ChildAgeRange.years1To2);

    final custom = await (db.select(db.categoryDefinitions)
          ..where((category) => category.id.equals('cat_personalizada')))
        .getSingleOrNull();

    expect(custom, isNotNull);
    expect(custom!.name, 'Brinquedos do quintal');
  });

  test('applyAgePreset aplica quantidades corretas', () async {
    await service.applyAgePreset(ChildAgeRange.years5To7);

    final quotasByName = await _roundQuotasByCategoryName(db);

    expect(quotasByName['corpo'], 1);
    expect(quotasByName['maos'], 2);
    expect(quotasByName['imaginacao'], 3);
    expect(quotasByName['comunicacao'], 2);
    expect(quotasByName['exploracao'], 2);
    expect(
      quotasByName.values.fold<int>(0, (sum, quota) => sum + quota),
      10,
    );
  });

  test('applyAgePreset cria fim de semana com brinquedo extra', () async {
    final weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );

    await service.applyAgePreset(ChildAgeRange.years2To3);

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
      final day = await weeklyPlanningRepository.getByWeekday(entry.key);
      expect(day, isNotNull);
      expect(day!.total, entry.value);
      expect(day.useDefault, entry.key < DateTime.saturday);
    }

    final saturday =
        await weeklyPlanningRepository.getByWeekday(DateTime.saturday);
    final sunday = await weeklyPlanningRepository.getByWeekday(DateTime.sunday);
    final saturdayQuotas = _quotasByCategoryName(saturday!.categories);
    final sundayQuotas = _quotasByCategoryName(sunday!.categories);
    final summary = await weeklyPlanningRepository.watchWeekSummary().first;

    expect(settingsRepository.weeklyPlanningEnabled, isTrue);
    expect(saturday.useDefault, isFalse);
    expect(saturday.total, 9);
    expect(saturdayQuotas['corpo'], 3);
    expect(saturdayQuotas['imaginacao'], 2);
    expect(sunday.useDefault, isFalse);
    expect(sunday.total, 9);
    expect(sundayQuotas['corpo'], 2);
    expect(sundayQuotas['imaginacao'], 3);
    for (final entry in expectedTotals.entries) {
      expect(_summaryTotal(summary, entry.key), entry.value);
    }
  });

  test('applyAgePreset atualiza fim de semana automatico anterior', () async {
    final weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );

    await service.applyAgePreset(ChildAgeRange.months0To6);
    var saturday =
        await weeklyPlanningRepository.getByWeekday(DateTime.saturday);
    var sunday = await weeklyPlanningRepository.getByWeekday(DateTime.sunday);
    expect(saturday!.total, 5);
    expect(sunday!.total, 5);

    await service.applyAgePreset(ChildAgeRange.years5To7);

    saturday = await weeklyPlanningRepository.getByWeekday(DateTime.saturday);
    sunday = await weeklyPlanningRepository.getByWeekday(DateTime.sunday);
    final saturdayQuotas = _quotasByCategoryName(saturday!.categories);
    final sundayQuotas = _quotasByCategoryName(sunday!.categories);

    expect(saturday.useDefault, isFalse);
    expect(saturday.total, 11);
    expect(saturdayQuotas['imaginacao'], 4);
    expect(sunday.useDefault, isFalse);
    expect(sunday.total, 11);
    expect(sundayQuotas['comunicacao'], 3);
  });

  test('nao agora salva faixa etaria sem alterar quotas nem planejamento',
      () async {
    final toyRepository = ToyRepository(db);
    await toyRepository.ensureSeedData();
    final weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    await settingsRepository.setWeeklyPlanningEnabled(true);
    await weeklyPlanningRepository.setUseDefault(
      weekday: DateTime.saturday,
      useDefault: false,
    );
    await weeklyPlanningRepository.updateCategoryConfig(
      weekday: DateTime.saturday,
      categoryId: 'livros',
      isIncluded: true,
      quota: 4,
    );
    final before = await _roundQuotasByCategoryId(db);
    final saturdayBefore =
        await weeklyPlanningRepository.getByWeekday(DateTime.saturday);

    await service.saveAgeRangeOnly(ChildAgeRange.years2To3);
    final after = await _roundQuotasByCategoryId(db);
    final saturdayAfter =
        await weeklyPlanningRepository.getByWeekday(DateTime.saturday);
    await settingsRepository.load();

    expect(settingsRepository.childAgeRange, ChildAgeRange.years2To3);
    expect(after, before);
    expect(saturdayAfter!.useDefault, saturdayBefore!.useDefault);
    expect(saturdayAfter.total, saturdayBefore.total);
    expect(
      _quotasByCategoryName(saturdayAfter.categories),
      _quotasByCategoryName(saturdayBefore.categories),
    );
  });

  test('applyAgePreset preserva sabado personalizado pelo usuario', () async {
    final toyRepository = ToyRepository(db);
    await toyRepository.ensureSeedData();
    final weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );

    await settingsRepository.setWeeklyPlanningEnabled(true);
    await weeklyPlanningRepository.setUseDefault(
      weekday: DateTime.saturday,
      useDefault: false,
    );
    final saturdayCategories =
        await weeklyPlanningRepository.getCategoriesForWeekday(
      DateTime.saturday,
    );
    for (final category in saturdayCategories) {
      await weeklyPlanningRepository.updateCategoryConfig(
        weekday: DateTime.saturday,
        categoryId: category.categoryId,
        isIncluded: false,
        quota: 0,
      );
    }
    await weeklyPlanningRepository.updateCategoryConfig(
      weekday: DateTime.saturday,
      categoryId: 'livros',
      isIncluded: true,
      quota: 2,
    );
    await settingsRepository.setWeeklyPlanningEnabled(true);
    await weeklyPlanningRepository.setUseDefault(
      weekday: DateTime.sunday,
      useDefault: false,
    );
    final sundayCategories =
        await weeklyPlanningRepository.getCategoriesForWeekday(DateTime.sunday);
    for (final category in sundayCategories) {
      await weeklyPlanningRepository.updateCategoryConfig(
        weekday: DateTime.sunday,
        categoryId: category.categoryId,
        isIncluded: false,
        quota: 0,
      );
    }
    await weeklyPlanningRepository.updateCategoryConfig(
      weekday: DateTime.sunday,
      categoryId: 'livros',
      isIncluded: true,
      quota: 4,
    );

    final before =
        await weeklyPlanningRepository.getByWeekday(DateTime.saturday);
    final sundayBefore =
        await weeklyPlanningRepository.getByWeekday(DateTime.sunday);
    await service.applyAgePreset(ChildAgeRange.years3To5);
    final after =
        await weeklyPlanningRepository.getByWeekday(DateTime.saturday);
    final sundayAfter =
        await weeklyPlanningRepository.getByWeekday(DateTime.sunday);

    expect(before!.total, 2);
    expect(after!.useDefault, isFalse);
    expect(after.total, 2);
    final livro = after.categories
        .where((category) => category.categoryId == 'livros')
        .single;
    expect(livro.isIncluded, isTrue);
    expect(livro.safeQuota, 2);
    expect(sundayBefore!.total, 4);
    expect(sundayAfter!.useDefault, isFalse);
    expect(sundayAfter.total, 4);
    final sundayLivro = sundayAfter.categories
        .where((category) => category.categoryId == 'livros')
        .single;
    expect(sundayLivro.isIncluded, isTrue);
    expect(sundayLivro.safeQuota, 4);
  });

  test('applyAgePreset nao sobrescreve dias personalizados', () async {
    final toyRepository = ToyRepository(db);
    await toyRepository.ensureSeedData();
    final weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );

    await settingsRepository.setWeeklyPlanningEnabled(true);
    await weeklyPlanningRepository.setUseDefault(
      weekday: DateTime.monday,
      useDefault: false,
    );
    final mondayCategories =
        await weeklyPlanningRepository.getCategoriesForWeekday(
      DateTime.monday,
    );
    for (final category in mondayCategories) {
      await weeklyPlanningRepository.updateCategoryConfig(
        weekday: DateTime.monday,
        categoryId: category.categoryId,
        isIncluded: false,
        quota: 0,
      );
    }
    await weeklyPlanningRepository.updateCategoryConfig(
      weekday: DateTime.monday,
      categoryId: 'livros',
      isIncluded: true,
      quota: 3,
    );

    final before = await weeklyPlanningRepository.getByWeekday(DateTime.monday);
    await service.applyAgePreset(ChildAgeRange.years3To5);
    final after = await weeklyPlanningRepository.getByWeekday(DateTime.monday);

    expect(before!.total, 3);
    expect(after!.useDefault, isFalse);
    expect(after.total, 3);
    final livro = after.categories
        .where((category) => category.categoryId == 'livros')
        .single;
    expect(livro.isIncluded, isTrue);
    expect(livro.safeQuota, 3);

    final officialNames = AgePresetCatalog.officialCategories
        .map((category) => _normalize(category.name))
        .toSet();
    final includedOfficialCategories = after.categories.where((category) {
      return officialNames.contains(_normalize(category.categoryName)) &&
          category.isIncluded;
    });
    expect(includedOfficialCategories, isEmpty);
  });
}

Future<void> _insertCategory(
  AppDatabase db, {
  required String id,
  required String name,
}) async {
  await db.into(db.categoryDefinitions).insert(
        CategoryDefinitionsCompanion.insert(
          id: id,
          name: name,
          description: const Value(null),
          examples: const Value(null),
          developmentAspect: const Value(null),
          sortOrder: const Value(999),
          isDefault: const Value(false),
          isActive: const Value(true),
        ),
      );
}

Future<RoundCategorySetting?> _roundSetting(
  AppDatabase db,
  String categoryId,
) {
  return (db.select(db.roundCategorySettings)
        ..where((setting) => setting.categoryId.equals(categoryId)))
      .getSingleOrNull();
}

Future<Map<String, int>> _roundQuotasByCategoryId(AppDatabase db) async {
  final rows = await db.select(db.roundCategorySettings).get();
  return {
    for (final row in rows) row.categoryId: row.quota,
  };
}

Future<Map<String, int>> _roundQuotasByCategoryName(AppDatabase db) async {
  final categories = await db.select(db.categoryDefinitions).get();
  final result = <String, int>{};
  for (final category in categories) {
    final setting = await _roundSetting(db, category.id);
    if (setting == null || !setting.isIncluded) continue;
    result[_normalize(category.name)] = setting.quota;
  }
  return result;
}

Map<String, int> _quotasByCategoryName(
  List<WeeklyPlanningCategoryConfig> categories,
) {
  return {
    for (final category in categories)
      _normalize(category.categoryName): category.safeQuota,
  };
}

int _summaryTotal(List<WeekDaySummary> summary, int weekday) {
  return summary.where((day) => day.weekday == weekday).single.totalToys;
}

String _normalize(String value) {
  var normalized = value.trim().toLowerCase();
  const replacements = <String, String>{
    'ã': 'a',
    'á': 'a',
    'â': 'a',
    'à': 'a',
    'é': 'e',
    'ê': 'e',
    'í': 'i',
    'ó': 'o',
    'õ': 'o',
    'ô': 'o',
    'ú': 'u',
    'ç': 'c',
  };
  for (final entry in replacements.entries) {
    normalized = normalized.replaceAll(entry.key, entry.value);
  }
  return normalized.replaceAll(RegExp(r'\s+'), ' ');
}
