import 'package:drift/drift.dart' show OrderingTerm, Value;
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

  test('cria 2 brinquedos sem nome na Caixa 1: Brinquedo 1.1 e Brinquedo 1.2',
      () async {
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

    final toy = await (db.select(db.toys)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .getSingle();

    expect(toy.name, 'Brinquedo 0.1');
    expect(toy.boxId, isNull);
  });

  test('mover brinquedo para outra caixa nao renomeia automaticamente',
      () async {
    final box1 = await repository.addBoxWithAutoNumber(local: 'Quarto');
    final box2 = await repository.addBoxWithAutoNumber(local: 'Sala');

    await repository.addToy(name: '', boxId: box1.id);
    final created = await (db.select(db.toys)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .getSingle();
    expect(created.name, 'Brinquedo 5.1');

    await repository.setToyBox(toyId: created.id, boxId: box2.id);
    final moved = await (db.select(db.toys)
          ..where((t) => t.id.equals(created.id)))
        .getSingle();

    expect(moved.name, 'Brinquedo 5.1');
    expect(moved.boxId, box2.id);
  });

  test('renomear caixa preserva foto, local e brinquedos associados', () async {
    final box = await repository.addBoxWithAutoNumber(local: 'Sala');
    await (db.update(db.boxes)..where((b) => b.id.equals(box.id))).write(
      const BoxesCompanion(photoPath: Value('/foto/caixa.png')),
    );
    await repository.addToy(name: 'Carrinho', boxId: box.id);

    await repository.renameBox(boxId: box.id, name: 'Caixa dos favoritos');

    final renamed = await (db.select(db.boxes)
          ..where((b) => b.id.equals(box.id)))
        .getSingle();
    final toy = await (db.select(db.toys)..where((t) => t.boxId.equals(box.id)))
        .getSingle();

    expect(renamed.name, 'Caixa dos favoritos');
    expect(renamed.local, 'Sala');
    expect(renamed.photoPath, '/foto/caixa.png');
    expect(toy.name, 'Carrinho');
    expect(toy.boxId, box.id);
  });

  test('renomear caixa rejeita nome vazio', () async {
    final box = await repository.addBoxWithAutoNumber(local: 'Sala');

    expect(
      () => repository.renameBox(boxId: box.id, name: '   '),
      throwsA(isA<StateError>()),
    );

    final unchanged = await (db.select(db.boxes)
          ..where((b) => b.id.equals(box.id)))
        .getSingle();
    expect(unchanged.name, 'Caixa ${box.number} - Sala');
  });

  test('editar local preserva nome customizado da caixa', () async {
    final box = await repository.addBoxWithAutoNumber(local: 'Sala');

    await repository.renameBox(boxId: box.id, name: 'Caixa sensorial');
    await repository.updateBoxLocal(boxId: box.id, local: 'Quarto');

    final updated = await (db.select(db.boxes)
          ..where((b) => b.id.equals(box.id)))
        .getSingle();
    expect(updated.name, 'Caixa sensorial');
    expect(updated.local, 'Quarto');
  });

  test('restaurar padrao deixa total do rodizio em 7 brinquedos', () async {
    await repository.restoreRoundCategoryDefaults();

    final settings = await db.select(db.roundCategorySettings).get();
    final total = settings
        .where((setting) => setting.isIncluded)
        .fold<int>(0, (sum, setting) => sum + setting.quota);

    expect(total, 7);
  });

  test('seed padrao cria somente as 5 categorias oficiais', () async {
    final categories = await (db.select(db.categoryDefinitions)
          ..orderBy([(category) => OrderingTerm.asc(category.sortOrder)]))
        .get();

    expect(categories.map((category) => category.id).toSet(), {
      'corpo',
      'exploracao',
      'maos',
      'imaginacao',
      'comunicacao',
    });
    expect(categories.map((category) => category.name), [
      'Corpo e Respiração',
      'Sentidos e Exploração',
      'Mãos e Construção',
      'Imaginação e Criatividade',
      'Comunicação e Histórias',
    ]);
  });
}
