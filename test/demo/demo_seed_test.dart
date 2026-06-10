import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_seed.dart';

void main() {
  const officialCategoryIds = <String>{
    'faz_de_conta',
    'movimento',
    'coordenacao',
    'construcao',
    'livros',
    'arte_musica',
  };

  test('demo seed tem 12 brinquedos com fotos e rodada ativa de 5', () {
    expect(DemoSeed.toys, hasLength(12));
    expect(DemoSeed.activeRoundToyIds, hasLength(5));
    expect(DemoSeed.categories, hasLength(6));
    expect(DemoSeed.boxes, hasLength(3));
    expect(DemoSeed.locations, hasLength(5));
    expect(
      DemoSeed.categories.map((category) => category.id).toSet(),
      officialCategoryIds,
    );
    expect(
      DemoSeed.toys.map((toy) => toy.name),
      <String>[
        'Dinossauro verde',
        'Bola sensorial',
        'Triciclo',
        'Livro de historias',
        'Blocos coloridos',
        'Ursinho Caramelo',
        'Instrumento musical',
        'Caminhao de martelar',
        'Kit de arte',
        'Carrinho vermelho',
        'Quebra-cabeca',
        'Bike de equilibrio',
      ],
    );

    final toyIds = DemoSeed.toys.map((toy) => toy.id).toSet();
    final photoAssetPaths =
        DemoSeed.toys.map((toy) => toy.photoAssetPath).toSet();

    expect(toyIds, hasLength(12));
    expect(photoAssetPaths, hasLength(12));
    for (final toy in DemoSeed.toys) {
      expect(toy.name.trim(), isNotEmpty);
      expect(officialCategoryIds, contains(toy.categoryId));
      expect(toy.photoAssetPath, startsWith('assets/demo/toys/'));
      expect(toy.photoAssetPath, endsWith('.png'));
      expect(toy.boxId != null || toy.locationText != null, isTrue);
    }
    for (final toyId in DemoSeed.activeRoundToyIds) {
      expect(toyIds, contains(toyId));
    }
  });

  test('demo seed alterna categorias e armazenamento no catalogo', () {
    for (var index = 1; index < DemoSeed.toys.length; index++) {
      expect(
        DemoSeed.toys[index].categoryId,
        isNot(DemoSeed.toys[index - 1].categoryId),
      );
    }

    expect(
      DemoSeed.toys.map((toy) => toy.categoryId).toSet(),
      officialCategoryIds,
    );

    final usedBoxIds =
        DemoSeed.toys.map((toy) => toy.boxId).whereType<String>().toSet();
    expect(
      usedBoxIds,
      <String>{
        'demo_box_sala',
        'demo_box_quarto',
        'demo_box_area_brincar',
      },
    );

    final looseLocations = DemoSeed.toys
        .where((toy) => toy.boxId == null)
        .map((toy) => toy.locationText)
        .whereType<String>()
        .toSet();
    expect(looseLocations, containsAll(<String>['Estante - Sala', 'Tapete']));
  });

  test('demo seed usa cota padrao de 5 brinquedos', () {
    final total = DemoSeed.categories.fold<int>(
      0,
      (sum, category) => sum + category.quota,
    );

    expect(total, 5);
  });

  test('demo seed cria planejamento semanal com 5 brinquedos por dia', () {
    expect(DemoSeed.weeklyPlans, hasLength(7));

    for (final plan in DemoSeed.weeklyPlans) {
      final total = plan.quotas.values.fold<int>(0, (sum, quota) {
        return sum + quota;
      });

      expect(plan.weekday, inInclusiveRange(DateTime.monday, DateTime.sunday));
      expect(total, 5);
      expect(plan.quotas.keys.toSet().difference(officialCategoryIds), isEmpty);
    }
  });
}
