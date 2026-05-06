import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_seed.dart';

void main() {
  test('demo seed tem 30 brinquedos com fotos e rodada ativa de 7', () {
    expect(DemoSeed.toys, hasLength(30));
    expect(DemoSeed.activeRoundToyIds, hasLength(7));

    final toyIds = DemoSeed.toys.map((toy) => toy.id).toSet();
    final photoAssetPaths =
        DemoSeed.toys.map((toy) => toy.photoAssetPath).toSet();

    expect(toyIds, hasLength(30));
    expect(photoAssetPaths, hasLength(30));
    for (final toy in DemoSeed.toys) {
      expect(toy.name.trim(), isNotEmpty);
      expect(toy.categoryId.trim(), isNotEmpty);
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
