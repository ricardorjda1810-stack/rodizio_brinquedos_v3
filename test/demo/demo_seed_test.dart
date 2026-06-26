import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/demo/demo_seed.dart';

void main() {
  const officialCategoryIds = <String>{
    'corpo',
    'maos',
    'imaginacao',
    'comunicacao',
    'exploracao',
  };

  test('demo seed tem 50 brinquedos oficiais com fotos unicas', () {
    expect(DemoSeed.toys, hasLength(50));
    expect(DemoSeed.activeRoundToyIds, hasLength(5));
    expect(DemoSeed.categories, hasLength(5));
    expect(DemoSeed.boxes, hasLength(5));
    expect(DemoSeed.locations, hasLength(5));
    expect(
      DemoSeed.categories.map((category) => category.id).toSet(),
      officialCategoryIds,
    );
    expect(
      DemoSeed.categories.map((category) => category.name),
      <String>[
        'Corpo e Respira\u00E7\u00E3o',
        'Sentidos e Explora\u00E7\u00E3o',
        'M\u00E3os e Constru\u00E7\u00E3o',
        'Imagina\u00E7\u00E3o e Criatividade',
        'Comunica\u00E7\u00E3o e Hist\u00F3rias',
      ],
    );

    final toyIds = DemoSeed.toys.map((toy) => toy.id).toSet();
    final toyNames = DemoSeed.toys.map((toy) => toy.name).toSet();
    final photoAssetPaths =
        DemoSeed.toys.map((toy) => toy.photoAssetPath).toSet();

    expect(toyIds, hasLength(50));
    expect(toyNames, hasLength(50));
    expect(photoAssetPaths, hasLength(50));
    for (final toy in DemoSeed.toys) {
      expect(toy.name.trim(), isNotEmpty);
      expect(officialCategoryIds, contains(toy.categoryId));
      expect(toy.photoAssetPath, startsWith('assets/demo_toys_v2/'));
      expect(toy.photoAssetPath, endsWith('.png'));
      expect(File(toy.photoAssetPath).existsSync(), isTrue);
      expect(toy.boxId != null || toy.locationText != null, isTrue);
    }
    for (final toyId in DemoSeed.activeRoundToyIds) {
      expect(toyIds, contains(toyId));
    }
  });

  test('demo seed tem exatamente 10 brinquedos por categoria oficial', () {
    final counts = <String, int>{};
    for (final toy in DemoSeed.toys) {
      counts[toy.categoryId] = (counts[toy.categoryId] ?? 0) + 1;
    }

    expect(counts.keys.toSet(), officialCategoryIds);
    for (final categoryId in officialCategoryIds) {
      expect(counts[categoryId], 10, reason: categoryId);
    }
  });

  test('demo seed usa nomes solicitados e sem marcas comerciais', () {
    expect(
      DemoSeed.toys.map((toy) => toy.name).toSet(),
      <String>{
        'Torre de empilhar',
        'Encaixe de formas',
        'Quebra-cabe\u00E7a de madeira',
        'Blocos grandes',
        'Cubos de montar sem marca',
        'Brinquedo de martelar',
        'Parafusos e porcas grandes',
        'Alinhavo com pe\u00E7as grandes',
        'Painel de fechos',
        'Copos medidores de empilhar',
        'Bola macia',
        'T\u00FAnel infantil dobr\u00E1vel',
        'Bambol\u00EA infantil',
        'Tapete de movimento',
        'Cones coloridos',
        'Prancha de equil\u00EDbrio baixa',
        'Almofadas de percurso',
        'Argolas de arremesso',
        'Cavalinho de balan\u00E7o simples',
        'Mini cesta com bola',
        'Cozinha de brinquedo',
        'Comidinhas de madeira',
        'Animais de fazenda',
        'Bonecos fam\u00EDlia simples',
        'Carrinhos de madeira',
        'Trem de madeira',
        'Casinha de bonecos',
        'Kit m\u00E9dico infantil',
        'Fantasias simples',
        'Fantoches de animais',
        'Livro cartonado',
        'Cart\u00F5es de figuras',
        'Telefone de brinquedo simples',
        'Fantoches para hist\u00F3ria',
        'Jogo da mem\u00F3ria com imagens',
        'Letras grandes de madeira ou espuma',
        'Dados de hist\u00F3rias',
        'Cart\u00F5es de emo\u00E7\u00F5es',
        'Mini quadro branco',
        'Sequ\u00EAncia de hist\u00F3rias ilustradas',
        'Lupa infantil',
        'Instrumentos musicais simples',
        'Mesa de areia e \u00E1gua',
        'Kit jardinagem infantil',
        'Animais e insetos de explora\u00E7\u00E3o',
        'Garrafas sensoriais seguras',
        'Tubos de observa\u00E7\u00E3o transparentes',
        'Pedras e formas sensoriais grandes',
        'Circuito de bolinhas grandes',
        'Brinquedo causa-e-efeito',
      },
    );
  });

  test('demo seed distribui armazenamento e rodada ativa por categoria', () {
    final usedBoxIds =
        DemoSeed.toys.map((toy) => toy.boxId).whereType<String>().toSet();
    expect(
      usedBoxIds,
      <String>{
        'demo_box_sala',
        'demo_box_quarto',
        'demo_box_estante_montessori',
        'demo_box_caixa_tecido',
        'demo_box_prateleira_baixa',
      },
    );

    final looseLocations = DemoSeed.toys
        .where((toy) => toy.boxId == null)
        .map((toy) => toy.locationText)
        .whereType<String>()
        .toSet();
    expect(
      looseLocations,
      containsAll(<String>[
        'Sala',
        'Quarto',
        'Estante Montessori',
        'Prateleira baixa',
      ]),
    );

    final toysById = {for (final toy in DemoSeed.toys) toy.id: toy};
    final activeCategories = DemoSeed.activeRoundToyIds
        .map((toyId) => toysById[toyId]!.categoryId)
        .toSet();
    expect(activeCategories, officialCategoryIds);
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
      expect(plan.quotas.keys.toSet(), officialCategoryIds);
    }
  });
}
