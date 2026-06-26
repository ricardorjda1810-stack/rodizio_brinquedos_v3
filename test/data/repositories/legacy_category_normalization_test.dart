import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/features/brinquedos/brinquedos_catalog_controller.dart';

void main() {
  late AppDatabase db;
  late ToyRepository toyRepository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    toyRepository = ToyRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('normaliza base antiga preservando brinquedos e desativando legadas',
      () async {
    await _insertLegacyCategory(db, id: 'livros', name: 'Livros');
    await _insertLegacyCategory(db, id: 'construcao', name: 'Construção');
    await _insertLegacyCategory(db, id: 'faz_de_conta', name: 'Faz de conta');
    await _insertLegacyCategory(db, id: 'movimento', name: 'Movimento');
    await _insertLegacyCategory(db, id: 'coordenacao', name: 'Coordenação');
    await _insertLegacyCategory(db, id: 'sensorial', name: 'Sensorial');

    await _insertToy(db, id: 'toy_livro', categoryId: 'livros');
    await _insertToy(db, id: 'toy_bloco', categoryId: 'construcao');
    await _insertToy(db, id: 'toy_cena', categoryId: 'faz_de_conta');
    await _insertToy(db, id: 'toy_bola', categoryId: 'movimento');
    await _insertToy(db, id: 'toy_pinos', categoryId: 'coordenacao');
    await _insertToy(db, id: 'toy_textura', categoryId: 'sensorial');

    await toyRepository.ensureSeedData();

    final toysById = {
      for (final toy in await db.select(db.toys).get()) toy.id: toy,
    };
    expect(toysById['toy_livro']!.categoryId, 'comunicacao');
    expect(toysById['toy_bloco']!.categoryId, 'maos');
    expect(toysById['toy_cena']!.categoryId, 'imaginacao');
    expect(toysById['toy_bola']!.categoryId, 'corpo');
    expect(toysById['toy_pinos']!.categoryId, 'maos');
    expect(toysById['toy_textura']!.categoryId, 'exploracao');

    final categories = await db.select(db.categoryDefinitions).get();
    final activeIds = categories
        .where((category) => category.isActive)
        .map((category) => category.id)
        .toList()
      ..sort();
    expect(activeIds, <String>[
      'comunicacao',
      'corpo',
      'exploracao',
      'imaginacao',
      'maos',
    ]);

    for (final legacyId in <String>[
      'livros',
      'construcao',
      'faz_de_conta',
      'movimento',
      'coordenacao',
      'sensorial',
    ]) {
      final legacy = categories.where((category) => category.id == legacyId);
      expect(legacy.single.isActive, isFalse, reason: legacyId);
    }

    final suggestion =
        await RoundRepository(db).suggestRoundForDate(DateTime(2026, 1, 5));
    expect(
      suggestion.map((toy) => toy.categoryId).toSet(),
      containsAll(<String>[
        'corpo',
        'exploracao',
        'maos',
        'imaginacao',
        'comunicacao',
      ]),
    );
  });

  test('catalogo nao cria filtros principais para categorias nao oficiais',
      () async {
    await toyRepository.ensureSeedData();
    await _insertLegacyCategory(db, id: 'livros', name: 'Livros');
    await _insertLegacyCategory(db, id: 'custom', name: 'Categoria custom');
    await _insertToy(db, id: 'toy_livro', categoryId: 'livros');
    await _insertToy(db, id: 'toy_custom', categoryId: 'custom');

    final controller = BrinquedosCatalogController(toyRepository: toyRepository)
      ..init();
    addTearDown(controller.dispose);

    final state = await controller.stream.firstWhere(
      (state) => state.totalItemsCount >= 2,
    );

    expect(state.filteredItems, hasLength(2));
    expect(state.categories.map((category) => category.id), <String>[
      'corpo',
      'exploracao',
      'maos',
      'imaginacao',
      'comunicacao',
    ]);
  });

  test('planejamento semanal usa somente categorias oficiais finais', () async {
    await toyRepository.ensureSeedData();
    await _insertLegacyCategory(db, id: 'livros', name: 'Livros');
    await toyRepository.setCategoryIncludedInRound(
      categoryId: 'livros',
      isIncluded: true,
    );
    await toyRepository.setCategoryQuotaInRound(
      categoryId: 'livros',
      quota: 5,
    );

    final settingsRepository = SettingsRepository(db);
    await settingsRepository.load();
    addTearDown(settingsRepository.dispose);

    final weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    final defaults = await weeklyPlanningRepository.getDefaultCategoryConfig();
    final monday = await weeklyPlanningRepository.getCategoriesForWeekday(
      DateTime.monday,
    );

    expect(defaults.map((category) => category.categoryId), <String>[
      'corpo',
      'exploracao',
      'maos',
      'imaginacao',
      'comunicacao',
    ]);
    expect(monday.map((category) => category.categoryId), <String>[
      'corpo',
      'exploracao',
      'maos',
      'imaginacao',
      'comunicacao',
    ]);
  });
}

Future<void> _insertLegacyCategory(
  AppDatabase db, {
  required String id,
  required String name,
}) {
  return db.into(db.categoryDefinitions).insert(
        CategoryDefinitionsCompanion.insert(
          id: id,
          name: name,
          description: const Value(null),
          examples: const Value(null),
          developmentAspect: const Value(null),
          sortOrder: const Value(100),
          isDefault: const Value(false),
          isActive: const Value(true),
        ),
      );
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
          boxId: const Value(null),
          locationText: const Value(null),
          photoPath: const Value(null),
        ),
      );
}
