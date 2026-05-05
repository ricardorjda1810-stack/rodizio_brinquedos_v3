class DemoCategorySeed {
  final String id;
  final String name;
  final String examples;
  final int quota;

  const DemoCategorySeed({
    required this.id,
    required this.name,
    required this.examples,
    required this.quota,
  });
}

class DemoBoxSeed {
  final String id;
  final int number;
  final String local;

  const DemoBoxSeed({
    required this.id,
    required this.number,
    required this.local,
  });
}

class DemoToySeed {
  final String id;
  final String name;
  final String categoryId;
  final String? boxId;
  final String? locationText;
  final String photoAssetPath;

  const DemoToySeed({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.photoAssetPath,
    this.boxId,
    this.locationText,
  });
}

class DemoSeed {
  static const categories = <DemoCategorySeed>[
    DemoCategorySeed(
      id: 'veiculos',
      name: 'Veiculos',
      examples: 'carrinhos, trens, caminhoes',
      quota: 2,
    ),
    DemoCategorySeed(
      id: 'faz_de_conta',
      name: 'Faz de conta',
      examples: 'panelinhas, fantasias, bonecos',
      quota: 2,
    ),
    DemoCategorySeed(
      id: 'montagem',
      name: 'Montagem',
      examples: 'blocos, encaixes, pecas',
      quota: 2,
    ),
    DemoCategorySeed(
      id: 'livros',
      name: 'Livros',
      examples: 'historias, animais, cores',
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'musica',
      name: 'Musica',
      examples: 'tambor, chocalho, teclado',
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'artes',
      name: 'Artes',
      examples: 'pintura, giz, massinha',
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'banho',
      name: 'Banho',
      examples: 'barquinhos, patinhos, copos',
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'sensorial',
      name: 'Sensorial',
      examples: 'bolas, texturas, encaixes macios',
      quota: 1,
    ),
  ];

  static const boxes = <DemoBoxSeed>[
    DemoBoxSeed(id: 'demo_box_sala', number: 1, local: 'Sala'),
    DemoBoxSeed(id: 'demo_box_quarto', number: 2, local: 'Quarto'),
    DemoBoxSeed(
        id: 'demo_box_brinquedoteca', number: 3, local: 'Brinquedoteca'),
    DemoBoxSeed(id: 'demo_box_varanda', number: 4, local: 'Varanda'),
  ];

  static const toys = <DemoToySeed>[
    DemoToySeed(
      id: 'demo_toy_torre_de_argolas',
      name: 'Torre de argolas',
      categoryId: 'sensorial',
      photoAssetPath: 'assets/demo/toys/torre_de_argolas.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_blocos_de_madeira',
      name: 'Blocos de madeira',
      categoryId: 'montagem',
      photoAssetPath: 'assets/demo/toys/blocos_de_madeira.png',
      boxId: 'demo_box_brinquedoteca',
    ),
    DemoToySeed(
      id: 'demo_toy_carrinho_de_madeira',
      name: 'Carrinho de madeira',
      categoryId: 'veiculos',
      photoAssetPath: 'assets/demo/toys/carrinho_de_madeira.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_tambor_infantil',
      name: 'Tambor infantil',
      categoryId: 'musica',
      photoAssetPath: 'assets/demo/toys/tambor_infantil.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_livro_dos_animais',
      name: 'Livro dos animais',
      categoryId: 'livros',
      photoAssetPath: 'assets/demo/toys/livro_dos_animais.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_cubo_de_formas',
      name: 'Cubo de formas',
      categoryId: 'montagem',
      photoAssetPath: 'assets/demo/toys/cubo_de_formas.png',
      boxId: 'demo_box_brinquedoteca',
    ),
    DemoToySeed(
      id: 'demo_toy_panelinhas',
      name: 'Panelinhas',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/panelinhas.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_bola_sensorial',
      name: 'Bola sensorial',
      categoryId: 'sensorial',
      photoAssetPath: 'assets/demo/toys/bola_sensorial.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_arco_iris_de_madeira',
      name: 'Arco-iris de madeira',
      categoryId: 'sensorial',
      photoAssetPath: 'assets/demo/toys/arco_iris_de_madeira.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_quebra_cabeca',
      name: 'Quebra-cabeca',
      categoryId: 'montagem',
      photoAssetPath: 'assets/demo/toys/quebra_cabeca.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_chocalho',
      name: 'Chocalho',
      categoryId: 'musica',
      photoAssetPath: 'assets/demo/toys/chocalho.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_cestinha_de_brinquedos',
      name: 'Cestinha de brinquedos',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/cestinha_de_brinquedos.png',
      boxId: 'demo_box_brinquedoteca',
    ),
  ];

  static const activeRoundToyIds = <String>[
    'demo_toy_torre_de_argolas',
    'demo_toy_blocos_de_madeira',
    'demo_toy_carrinho_de_madeira',
    'demo_toy_tambor_infantil',
    'demo_toy_livro_dos_animais',
    'demo_toy_cubo_de_formas',
    'demo_toy_bola_sensorial',
    'demo_toy_arco_iris_de_madeira',
    'demo_toy_cestinha_de_brinquedos',
  ];
}
