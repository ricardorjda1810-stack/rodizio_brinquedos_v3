import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/weekly_planning/weekly_planning_overview.dart';
import 'package:rodizio_brinquedos_v3/ui/weekly_planning_overview_page.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settingsRepository;
  late ToyRepository toyRepository;
  late WeeklyPlanningRepository weeklyPlanningRepository;
  late RoundRepository roundRepository;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settingsRepository = SettingsRepository(db);
    toyRepository = _OverviewTestToyRepository(db);
    weeklyPlanningRepository = WeeklyPlanningRepository(
      db: db,
      settingsRepository: settingsRepository,
    );
    roundRepository = _OverviewTestRoundRepository(db);

    await toyRepository.ensureSeedData();
    await toyRepository.restoreRoundCategoryDefaults();
    await _configureFiveToyWeek(toyRepository);
    await _insertFiveScheduledToys(db, toyRepository);
  });

  tearDown(() async {
    settingsRepository.dispose();
    await db.close();
  });

  testWidgets('tocar em miniatura abre o brinquedo correto', (tester) async {
    await _setIphoneViewport(tester);
    await _pumpOverview(
      tester,
      settingsRepository: settingsRepository,
      weeklyPlanningRepository: weeklyPlanningRepository,
      roundRepository: roundRepository,
      toyRepository: toyRepository,
    );

    final thumbnail = find.byKey(
      const ValueKey('weekly-toy-thumbnail-toy_tambor'),
    );
    await tester.ensureVisible(thumbnail.first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(thumbnail.first);
    await _pumpUntilFound(tester, find.text('Tambor Musical'));

    expect(find.text('Tambor Musical'), findsWidgets);
    expect(find.text('Blocos Vermelhos'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('badge, seta e item da lista abrem brinquedos do dia',
      (tester) async {
    await _setIphoneViewport(tester);
    await _pumpOverview(
      tester,
      settingsRepository: settingsRepository,
      weeklyPlanningRepository: weeklyPlanningRepository,
      roundRepository: roundRepository,
      toyRepository: toyRepository,
    );

    final mondayTitle = _currentMondayTitle();
    final mondayBadge = find.byKey(const ValueKey('weekly-day-total-1'));
    final mondayChevron = find.byKey(const ValueKey('weekly-day-chevron-1'));

    await tester.ensureVisible(mondayBadge.first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(mondayBadge.first);
    await _pumpUntilFound(tester, find.text(mondayTitle));
    await _pumpUntilFound(tester, find.text('Blocos Vermelhos'));

    expect(find.text(mondayTitle), findsOneWidget);
    expect(find.text('5 brinquedos programados'), findsOneWidget);
    expect(find.text('Blocos Vermelhos'), findsOneWidget);
    expect(find.text('Tambor Musical'), findsOneWidget);
    expect(find.text('Carrinho Verde'), findsOneWidget);
    expect(find.text('Livro de Animais'), findsOneWidget);
    expect(find.text('Quebra-cabeca Formas'), findsOneWidget);
    expect(find.text('Sentidos e Exploração'), findsWidgets);
    expect(find.textContaining('Caixa 1'), findsWidgets);
    expect(find.textContaining('Prateleira'), findsWidgets);

    await tester.tap(find.byIcon(Icons.close));
    await _pumpUntilGone(tester, find.text(mondayTitle));

    await tester.tap(mondayChevron.first);
    await _pumpUntilFound(tester, find.text(mondayTitle));
    await _pumpUntilFound(tester, find.text('Blocos Vermelhos'));

    expect(find.text(mondayTitle), findsOneWidget);
    expect(find.text('5 brinquedos programados'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('weekly-day-list-toy-toy_carrinho')),
    );
    await _pumpUntilGone(tester, find.text(mondayTitle));
    await _pumpUntilFound(tester, find.text('Carrinho Verde'));

    expect(find.text('Carrinho Verde'), findsWidgets);
    expect(find.text('Tambor Musical'), findsNothing);

    await _disposeWidgetTree(tester);
  });

  testWidgets('acervo vazio nao mostra planejamento fantasma de 5 brinquedos',
      (tester) async {
    await db.delete(db.roundToys).go();
    await db.delete(db.rounds).go();
    await db.delete(db.toys).go();

    await _setIphoneViewport(tester);
    await _pumpOverview(
      tester,
      settingsRepository: settingsRepository,
      weeklyPlanningRepository: weeklyPlanningRepository,
      roundRepository: roundRepository,
      toyRepository: toyRepository,
    );

    expect(find.text('5 brinq.'), findsNothing);
    expect(find.text('Nenhum brinquedo planejado'), findsWidgets);

    await _disposeWidgetTree(tester);
  });
}

Future<void> _pumpOverview(
  WidgetTester tester, {
  required SettingsRepository settingsRepository,
  required WeeklyPlanningRepository weeklyPlanningRepository,
  required RoundRepository roundRepository,
  required ToyRepository toyRepository,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WeeklyPlanningOverviewPage(
        settingsRepository: settingsRepository,
        weeklyPlanningRepository: weeklyPlanningRepository,
        roundRepository: roundRepository,
        toyRepository: toyRepository,
      ),
    ),
  );
  await _pumpUntilFound(tester, find.text('Programação da semana'));
}

Future<void> _setIphoneViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump();
}

Future<void> _configureFiveToyWeek(ToyRepository toyRepository) async {
  const categories = [
    'corpo',
    'exploracao',
    'maos',
    'imaginacao',
    'comunicacao',
  ];

  for (final categoryId in categories) {
    await toyRepository.setCategoryQuotaInRound(
      categoryId: categoryId,
      quota: categoryId == 'exploracao' ? 5 : 0,
    );
  }
}

Future<void> _insertFiveScheduledToys(
  AppDatabase db,
  ToyRepository toyRepository,
) async {
  final box = await toyRepository.createBox(number: 1, local: 'Sala');
  const toys = [
    ('toy_blocos', 'Blocos Vermelhos', 'exploracao'),
    ('toy_tambor', 'Tambor Musical', 'exploracao'),
    ('toy_carrinho', 'Carrinho Verde', 'exploracao'),
    ('toy_livro', 'Livro de Animais', 'exploracao'),
    ('toy_quebra_cabeca', 'Quebra-cabeca Formas', 'exploracao'),
  ];

  for (var index = 0; index < toys.length; index++) {
    final toy = toys[index];
    await db.into(db.toys).insert(
          ToysCompanion.insert(
            id: toy.$1,
            categoryId: Value(toy.$3),
            name: toy.$2,
            boxId: Value(index.isEven ? box.id : null),
            locationText: Value(index.isOdd ? 'Prateleira' : null),
            createdAt: 1000 + index,
            photoPath: const Value(null),
          ),
        );
  }
}

String _currentMondayTitle() {
  final monday = startOfPlanningWeek(DateTime.now());
  return '${DateFormat.EEEE('pt_BR').format(monday)}, ${DateFormat.yMd('pt_BR').format(monday)}';
}

class _OverviewTestRoundRepository extends RoundRepository {
  _OverviewTestRoundRepository(super.db);

  @override
  Stream<List<RoundToyWithBox>> watchActiveRoundToysWithBox() {
    return Stream.value(const <RoundToyWithBox>[]);
  }
}

class _OverviewTestToyRepository extends ToyRepository {
  _OverviewTestToyRepository(super.db);

  @override
  Stream<List<CategoryDefinition>> watchCategories({bool activeOnly = false}) {
    return Stream.fromFuture(_loadCategories(activeOnly: activeOnly));
  }

  @override
  Stream<ToyWithBox?> watchToyWithBox({required String toyId}) {
    return Stream.fromFuture(_loadToyWithBox(toyId));
  }

  @override
  Stream<List<ToyCatalogItem>> watchCatalog() {
    return Stream.fromFuture(_loadCatalog());
  }

  Future<List<CategoryDefinition>> _loadCategories({
    required bool activeOnly,
  }) async {
    final d = db;
    if (d == null) return const <CategoryDefinition>[];
    final rows = await d.select(d.categoryDefinitions).get();
    return rows
        .where((category) => !activeOnly || category.isActive)
        .toList(growable: false);
  }

  Future<ToyWithBox?> _loadToyWithBox(String toyId) async {
    final d = db;
    if (d == null) return null;
    final toy = await (d.select(d.toys)..where((t) => t.id.equals(toyId)))
        .getSingleOrNull();
    if (toy == null) return null;
    final boxId = toy.boxId;
    final box = boxId == null
        ? null
        : await (d.select(d.boxes)..where((b) => b.id.equals(boxId)))
            .getSingleOrNull();
    return ToyWithBox(toy: toy, box: box);
  }

  Future<List<ToyCatalogItem>> _loadCatalog() async {
    final d = db;
    if (d == null) return const <ToyCatalogItem>[];
    final toys = await d.select(d.toys).get();
    final boxes = {
      for (final box in await d.select(d.boxes).get()) box.id: box,
    };
    final categories = {
      for (final category in await d.select(d.categoryDefinitions).get())
        category.id: category,
    };

    return toys
        .map(
          (toy) => ToyCatalogItem(
            toy: toy,
            box: toy.boxId == null ? null : boxes[toy.boxId],
            category: categories[toy.categoryId],
          ),
        )
        .toList(growable: false);
  }
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 40,
}) async {
  for (var frame = 0; frame < maxFrames; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets);
}

Future<void> _pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 20,
}) async {
  for (var frame = 0; frame < maxFrames; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isEmpty) return;
  }
  expect(finder, findsNothing);
}
