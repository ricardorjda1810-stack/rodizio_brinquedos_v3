import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';

void main() {
  late AppDatabase db;
  late ToyRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = ToyRepository(db);
    await repository.ensureSeedData();
  });

  tearDown(() async {
    await db.close();
  });

  test('cria 2 brinquedos sem nome na Caixa 1: Brinquedo 1.1 e Brinquedo 1.2', () async {
    final box = await repository.addBoxWithAutoNumber(local: 'Sala');

    await repository.addToy(name: '', boxId: box.id);
    await repository.addToy(name: '   ', boxId: box.id);

    final toys = await (db.select(db.toys)
          ..where((t) => t.boxId.equals(box.id))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    expect(toys.length, 2);
    expect(toys[0].name, 'Brinquedo 5.1');
    expect(toys[1].name, 'Brinquedo 5.2');
  });

  test('cria brinquedo sem nome e sem caixa: Brinquedo 0.1', () async {
    await repository.addToy(name: '   ', boxId: null);

    final toy = await (db.select(db.toys)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).getSingle();

    expect(toy.name, 'Brinquedo 0.1');
    expect(toy.boxId, isNull);
  });

  test('mover brinquedo para outra caixa nao renomeia automaticamente', () async {
    final box1 = await repository.addBoxWithAutoNumber(local: 'Quarto');
    final box2 = await repository.addBoxWithAutoNumber(local: 'Sala');

    await repository.addToy(name: '', boxId: box1.id);
    final created = await (db.select(db.toys)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).getSingle();
    expect(created.name, 'Brinquedo 5.1');

    await repository.setToyBox(toyId: created.id, boxId: box2.id);
    final moved = await (db.select(db.toys)..where((t) => t.id.equals(created.id))).getSingle();

    expect(moved.name, 'Brinquedo 5.1');
    expect(moved.boxId, box2.id);
  });
}

