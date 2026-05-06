import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_seed.dart';

void main() {
  const officialCategoryIds = <String>{
    'livros',
    'construcao',
    'faz_de_conta',
    'movimento',
    'coordenacao',
  };

  test('demo seed tem 30 brinquedos com fotos e rodada ativa de 7', () {
    expect(DemoSeed.toys, hasLength(30));
    expect(DemoSeed.activeRoundToyIds, hasLength(7));
    expect(DemoSeed.categories, hasLength(5));
    expect(
      DemoSeed.categories.map((category) => category.id).toSet(),
      officialCategoryIds,
    );

    final toyIds = DemoSeed.toys.map((toy) => toy.id).toSet();
    final photoAssetPaths =
        DemoSeed.toys.map((toy) => toy.photoAssetPath).toSet();

    expect(toyIds, hasLength(30));
    expect(photoAssetPaths, hasLength(30));
    for (final toy in DemoSeed.toys) {
      expect(toy.name.trim(), isNotEmpty);
      expect(officialCategoryIds, contains(toy.categoryId));
      expect(toy.photoAssetPath, startsWith('assets/demo/toys/'));
      expect(toy.photoAssetPath, endsWith('.png'));
    }
    for (final toyId in DemoSeed.activeRoundToyIds) {
      expect(toyIds, contains(toyId));
    }
  });

  test('demo seed usa cota padrao de 7 brinquedos', () {
    final total = DemoSeed.categories.fold<int>(
      0,
      (sum, category) => sum + category.quota,
    );

    expect(total, 7);
  });
}
