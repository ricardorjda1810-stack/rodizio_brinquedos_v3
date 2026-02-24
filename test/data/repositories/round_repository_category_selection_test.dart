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

  test('startRound respeita cotas por categoria ativa', () async {
    await _setCategoryState(toyRepository, 'bonecos', included: true, quota: 2);
    await _setCategoryState(toyRepository, 'livros', included: true, quota: 1);
    await _setAllOthersExcluded(toyRepository, const {'bonecos', 'livros'});

    await _insertToy(db, id: 'b1', categoryId: 'bonecos', createdAt: 100);
    await _insertToy(db, id: 'b2', categoryId: 'bonecos', createdAt: 200);
    await _insertToy(db, id: 'l1', categoryId: 'livros', createdAt: 150);
    await _insertToy(db, id: 'j1', categoryId: 'jogos', createdAt: 50);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['b1', 'b2', 'l1']);
  });

  test('startRound tolera falta e nao completa com geral', () async {
    await _setCategoryState(toyRepository, 'bonecos', included: true, quota: 3);
    await _setCategoryState(toyRepository, 'livros', included: true, quota: 2);
    await _setAllOthersExcluded(toyRepository, const {'bonecos', 'livros'});

    await _insertToy(db, id: 'b1', categoryId: 'bonecos', createdAt: 100);
    await _insertToy(db, id: 'j1', categoryId: 'jogos', createdAt: 50);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['b1']);
  });

  test('categoria com switch off tem cota efetiva zero', () async {
    await _setCategoryState(toyRepository, 'bonecos', included: false, quota: 3);
    await _setCategoryState(toyRepository, 'livros', included: true, quota: 1);
    await _setAllOthersExcluded(toyRepository, const {'bonecos', 'livros'});

    await _insertToy(db, id: 'b1', categoryId: 'bonecos', createdAt: 100);
    await _insertToy(db, id: 'l1', categoryId: 'livros', createdAt: 100);

    await roundRepository.startRound(size: 99);

    final selectedIds = await _selectedToyIdsByPosition(db);
    expect(selectedIds, ['l1']);
  });
}

Future<void> _setAllOthersExcluded(ToyRepository repository, Set<String> keepIncluded) async {
  final d = repository.db;
  if (d == null) throw StateError('db nulo');
  final all = await d.select(d.categoryDefinitions).get();
  for (final c in all) {
    if (keepIncluded.contains(c.id)) continue;
    await repository.setCategoryIncludedInRound(categoryId: c.id, isIncluded: false);
    await repository.setCategoryQuotaInRound(categoryId: c.id, quota: 0);
  }
}

Future<void> _setCategoryState(
  ToyRepository repository,
  String categoryId, {
  required bool included,
  required int quota,
}) async {
  await repository.setCategoryIncludedInRound(categoryId: categoryId, isIncluded: included);
  await repository.setCategoryQuotaInRound(categoryId: categoryId, quota: quota);
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
  final activeRound = await (db.select(db.rounds)..where((r) => r.endAt.isNull())).getSingle();
  final rows = await (db.select(db.roundToys)
        ..where((rt) => rt.roundId.equals(activeRound.id))
        ..orderBy([(rt) => OrderingTerm.asc(rt.position)]))
      .get();
  return rows.map((e) => e.toyId).toList();
}
