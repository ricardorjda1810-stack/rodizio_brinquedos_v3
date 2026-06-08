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
    expect(DemoSeed.locations, hasLength(4));
    expect(
      DemoSeed.categories.map((category) => category.id).toSet(),
      officialCategoryIds,
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
