import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_category_form_options.dart';

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

  test('seletor principal mostra somente as 5 categorias oficiais', () async {
    await repository.addCategory(
      name: 'Categoria personalizada',
      examples: 'exemplo interno',
    );
    await db.into(db.toys).insert(
          ToysCompanion.insert(
            id: 'toy_antigo',
            categoryId: const Value('movimento'),
            name: 'Brinquedo antigo',
            createdAt: 1,
            boxId: const Value(null),
            locationText: const Value(null),
            photoPath: const Value(null),
          ),
        );

    await repository.ensureOfficialToyFormCategories();

    final categories = await db.select(db.categoryDefinitions).get();
    expect(categories.map((category) => category.name), contains('Movimento'));
    expect(
      categories.map((category) => category.name),
      contains('Categoria personalizada'),
    );

    final pickerCategories = officialToyFormCategories(categories);
    expect(pickerCategories.map(toyFormCategoryName), [
      'Corpo',
      'Mãos',
      'Imaginação',
      'Comunicação',
      'Exploração',
    ]);
    expect(
      pickerCategories.map(toyFormCategoryExamples),
      containsAll([
        'bola • túnel • cavalinho • empurrar',
        'blocos • encaixes • quebra-cabeça • argolas',
        'bonecos • cozinha • carrinhos • ferramentas',
        'livros • fantoches • animais • jogos simples',
        'massinha • chocalho • água • areia • tecidos',
      ]),
    );
    expect(
      pickerCategories.map((category) => category.name),
      isNot(contains('Movimento')),
    );
    expect(
      pickerCategories.map((category) => category.name),
      isNot(contains('Categoria personalizada')),
    );

    final oldToy = await (db.select(db.toys)
          ..where((toy) => toy.id.equals('toy_antigo')))
        .getSingle();
    expect(oldToy.categoryId, 'movimento');
  });
}
