import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';

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

  test('startRound respeita cotas por categoria ativa e completa com geral', () async {
    await _setCategoryState(toyRepository, 'bonecos', included: true, quota: 2);
    await _setCategoryState(toyRepository, 'livros', included: true, quota: 1);
    await _setAllOthersExcluded(toyRepository, const {'bonecos', 'livros'});

    await _insertToy(db, id: 'b1', categoryId: 'bonecos', createdAt: 100);
    await _insertToy(db, id: 'b2', categoryId: 'bonecos', createdAt: 200);
    await _insertToy(db, id: 'l1', categoryId: 'livros', createdAt: 150);
    await _insertToy(db, id: 'j1', categoryId: 'jogos', createdAt: 50);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['b1', 'b2', 'l1', 'j1']);
  });

  test('startRound tolera falta e completa com brinquedos de outras categorias', () async {
    await _setCategoryState(toyRepository, 'bonecos', included: true, quota: 3);
    await _setCategoryState(toyRepository, 'livros', included: true, quota: 2);
    await _setAllOthersExcluded(toyRepository, const {'bonecos', 'livros'});

    await _insertToy(db, id: 'b1', categoryId: 'bonecos', createdAt: 100);
    await _insertToy(db, id: 'j1', categoryId: 'jogos', createdAt: 50);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['b1', 'j1']);
  });

  test('categoria com switch off tem cota efetiva zero, mas ainda entra no complemento geral', () async {
    await _setCategoryState(toyRepository, 'bonecos', included: false, quota: 3);
    await _setCategoryState(toyRepository, 'livros', included: true, quota: 1);
    await _setAllOthersExcluded(toyRepository, const {'bonecos', 'livros'});

    await _insertToy(db, id: 'b1', categoryId: 'bonecos', createdAt: 100);
    await _insertToy(db, id: 'l1', categoryId: 'livros', createdAt: 100);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['l1', 'b1']);
  });

  test('startRound inclui os brinquedos restantes apos priorizar cotas', () async {
    await _setCategoryState(toyRepository, 'bonecos', included: true, quota: 1);
    await _setCategoryState(toyRepository, 'livros', included: true, quota: 1);
    await _setAllOthersExcluded(toyRepository, const {'bonecos', 'livros'});

    await _insertToy(db, id: 'b1', categoryId: 'bonecos', createdAt: 100);
    await _insertToy(db, id: 'b2', categoryId: 'bonecos', createdAt: 200);
    await _insertToy(db, id: 'l1', categoryId: 'livros', createdAt: 150);
    await _insertToy(db, id: 'l2', categoryId: 'livros', createdAt: 250);
    await _insertToy(db, id: 'l3', categoryId: 'livros', createdAt: 350);

    final result = await roundRepository.startRound();

    expect(result.created, isTrue);
    expect(result.selectedCount, 5);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['b1', 'l1', 'b2', 'l2', 'l3']);
  });

  test('startRound nao cria rodada quando nao ha brinquedos cadastrados', () async {
    await _setCategoryState(toyRepository, 'bonecos', included: true, quota: 2);
    await _setAllOthersExcluded(toyRepository, const {'bonecos'});

    final result = await roundRepository.startRound(size: 99);

    expect(result.created, isFalse);
    expect(result.selectedCount, 0);

    final activeRound =
        await (db.select(db.rounds)..where((r) => r.endAt.isNull())).getSingleOrNull();
    expect(activeRound, isNull);
  });

  test('startRound cria rodada com 1 brinquedo fora das categorias priorizadas', () async {
    await _setCategoryState(toyRepository, 'bonecos', included: true, quota: 2);
    await _setAllOthersExcluded(toyRepository, const {'bonecos'});

    await _insertToy(db, id: 'l1', categoryId: 'livros', createdAt: 100);

    final result = await roundRepository.startRound();

    expect(result.created, isTrue);
    expect(result.selectedCount, 1);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['l1']);
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

Future<List<String>> _selectedToyIdsByPosition(AppDatabase db) async {
  final activeRound =
      await (db.select(db.rounds)..where((r) => r.endAt.isNull())).getSingle();

  final rows = await (db.select(db.roundToys)
        ..where((rt) => rt.roundId.equals(activeRound.id))
        ..orderBy([(rt) => OrderingTerm.asc(rt.position)]))
      .get();

  return rows.map((e) => e.toyId).toList();
}
