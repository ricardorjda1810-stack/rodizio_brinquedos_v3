import 'package:drift/drift.dart' show Value;
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

  test('nao agora salva faixa etaria sem alterar quotas', () async {
    final toyRepository = ToyRepository(db);
    await toyRepository.ensureSeedData();
    final before = await _roundQuotasByCategoryId(db);

    await service.saveAgeRangeOnly(ChildAgeRange.years2To3);
    final after = await _roundQuotasByCategoryId(db);
    await settingsRepository.load();

    expect(settingsRepository.childAgeRange, ChildAgeRange.years2To3);
    expect(after, before);
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
