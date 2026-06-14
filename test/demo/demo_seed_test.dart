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
        'Corpo',
        'M\u00E3os',
        'Imagina\u00E7\u00E3o',
        'Comunica\u00E7\u00E3o',
        'Explora\u00E7\u00E3o',
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
      expect(toy.photoAssetPath, startsWith('assets/demo/toys/demo_'));
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
        'Bola macia colorida',
        'Pinos de boliche infantil',
        'Mini cones de movimento',
        'Tapete de equil\u00EDbrio',
        'Argolas de atividade',
        'Bambol\u00EA infantil',
        'T\u00FAnel dobr\u00E1vel',
        'Carrinho de empurrar',
        'Almofadas de percurso',
        'Bola sensorial com textura',
        'Blocos de encaixe',
        'Torre de empilhar',
        'Quebra-cabe\u00E7a de formas',
        'Cubos sensoriais',
        'Potes de encaixar',
        'Martelo de pinos',
        'Contas grandes de montar',
        'Formas geom\u00E9tricas',
        'Painel de abrir e fechar',
        'Pe\u00E7as de rosquear grandes',
        'Panelinha de faz de conta',
        'Boneco beb\u00EA de pano',
        'Carrinhos coloridos',
        'Fazendinha de madeira',
        'Animais de brinquedo',
        'Casinha de bonecos',
        'Kit m\u00E9dico infantil',
        'Mercadinho de brincar',
        'Fantoches de animais',
        'Fantasia de explorador',
        'Livro de figuras',
        'Cart\u00F5es de emo\u00E7\u00F5es',
        'Telefone de brinquedo',
        'Fantoches de hist\u00F3rias',
        'Alfabeto ilustrado',
        'Cart\u00F5es de animais',
        'Sequ\u00EAncia de imagens',
        'Microfone de brinquedo',
        'Livrinho de sons',
        'Jogo de contar hist\u00F3rias',
        'Lupa infantil',
        'Garrafas sensoriais',
        'Instrumentos musicais',
        'Blocos transparentes',
        'Potes de descoberta',
        'Mesa de atividades',
        'Chocalhos variados',
        'Caixa de texturas',
        'Lanterna infantil',
        'Blocos magn\u00E9ticos grandes',
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
