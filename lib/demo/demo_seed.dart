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
      id: 'montessori',
      name: 'Montessori',
      examples: 'torres, permanencia, pinos, classificacao',
      quota: 2,
    ),
    DemoCategorySeed(
      id: 'movimento',
      name: 'Movimento',
      examples: 'bolas, rampas, carrinhos, tapetes',
      quota: 2,
    ),
    DemoCategorySeed(
      id: 'faz_de_conta',
      name: 'Faz de conta',
      examples: 'panelinhas, medico, bonecos, frutas',
      quota: 2,
    ),
    DemoCategorySeed(
      id: 'musica',
      name: 'Musica',
      examples: 'tambor, chocalho, xilofone, instrumentos',
      quota: 2,
    ),
    DemoCategorySeed(
      id: 'encaixe',
      name: 'Encaixe',
      examples: 'blocos, formas, caminhoes, pecas magneticas',
      quota: 2,
    ),
    DemoCategorySeed(
      id: 'livros',
      name: 'Livros',
      examples: 'animais, cores, tecido, primeiros livros',
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'sensorial',
      name: 'Sensorial',
      examples: 'texturas, bolas, tapetes, arcos',
      quota: 2,
    ),
    DemoCategorySeed(
      id: 'coordenacao_motora',
      name: 'Coordenacao motora',
      examples: 'quebra-cabeca, memoria, pinos, trilhos',
      quota: 2,
    ),
  ];

  static const boxes = <DemoBoxSeed>[
    DemoBoxSeed(
        id: 'demo_box_montessori', number: 1, local: 'Caixa Montessori'),
    DemoBoxSeed(id: 'demo_box_semana', number: 2, local: 'Caixa da Semana'),
    DemoBoxSeed(
      id: 'demo_box_armario_quarto',
      number: 3,
      local: 'Armario do quarto',
    ),
    DemoBoxSeed(
      id: 'demo_box_brinquedos_grandes',
      number: 4,
      local: 'Brinquedos grandes',
    ),
    DemoBoxSeed(id: 'demo_box_cesto_sala', number: 5, local: 'Cesto da sala'),
  ];

  static const toys = <DemoToySeed>[
    DemoToySeed(
      id: 'demo_toy_torre_de_argolas',
      name: 'Torre de argolas',
      categoryId: 'montessori',
      photoAssetPath: 'assets/demo/toys/torre_de_argolas.png',
      boxId: 'demo_box_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_blocos_de_madeira',
      name: 'Blocos de madeira',
      categoryId: 'encaixe',
      photoAssetPath: 'assets/demo/toys/blocos_de_madeira.png',
      boxId: 'demo_box_semana',
    ),
    DemoToySeed(
      id: 'demo_toy_carrinho_de_madeira',
      name: 'Carrinho de madeira',
      categoryId: 'movimento',
      photoAssetPath: 'assets/demo/toys/carrinho_de_madeira.png',
      boxId: 'demo_box_semana',
    ),
    DemoToySeed(
      id: 'demo_toy_tambor_infantil',
      name: 'Tambor infantil',
      categoryId: 'musica',
      photoAssetPath: 'assets/demo/toys/tambor_infantil.png',
      boxId: 'demo_box_armario_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_livro_dos_animais',
      name: 'Livro dos animais',
      categoryId: 'livros',
      photoAssetPath: 'assets/demo/toys/livro_dos_animais.png',
      boxId: 'demo_box_armario_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_cubo_de_formas',
      name: 'Cubo de formas',
      categoryId: 'encaixe',
      photoAssetPath: 'assets/demo/toys/cubo_de_formas.png',
      boxId: 'demo_box_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_panelinhas',
      name: 'Panelinhas',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/panelinhas.png',
      boxId: 'demo_box_cesto_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_bola_sensorial',
      name: 'Bola sensorial',
      categoryId: 'sensorial',
      photoAssetPath: 'assets/demo/toys/bola_sensorial.png',
      boxId: 'demo_box_cesto_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_arco_iris_de_madeira',
      name: 'Arco-iris de madeira',
      categoryId: 'sensorial',
      photoAssetPath: 'assets/demo/toys/arco_iris_de_madeira.png',
      boxId: 'demo_box_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_quebra_cabeca',
      name: 'Quebra-cabeca',
      categoryId: 'coordenacao_motora',
      photoAssetPath: 'assets/demo/toys/quebra_cabeca.png',
      boxId: 'demo_box_armario_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_chocalho',
      name: 'Chocalho',
      categoryId: 'musica',
      photoAssetPath: 'assets/demo/toys/chocalho.png',
      boxId: 'demo_box_semana',
    ),
    DemoToySeed(
      id: 'demo_toy_cestinha_de_brinquedos',
      name: 'Cestinha de brinquedos',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/cestinha_de_brinquedos.png',
      boxId: 'demo_box_cesto_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_trem_de_madeira',
      name: 'Trem de madeira',
      categoryId: 'movimento',
      photoAssetPath: 'assets/demo/toys/trem_de_madeira.png',
      boxId: 'demo_box_semana',
    ),
    DemoToySeed(
      id: 'demo_toy_xilofone_infantil',
      name: 'Xilofone infantil',
      categoryId: 'musica',
      photoAssetPath: 'assets/demo/toys/xilofone_infantil.png',
      boxId: 'demo_box_armario_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_frutas_de_brinquedo',
      name: 'Frutas de brinquedo',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/frutas_de_brinquedo.png',
      boxId: 'demo_box_cesto_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_animais_de_madeira',
      name: 'Animais de madeira',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/animais_de_madeira.png',
      boxId: 'demo_box_cesto_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_caminhao_de_encaixe',
      name: 'Caminhao de encaixe',
      categoryId: 'encaixe',
      photoAssetPath: 'assets/demo/toys/caminhao_de_encaixe.png',
      boxId: 'demo_box_brinquedos_grandes',
    ),
    DemoToySeed(
      id: 'demo_toy_boneco_de_pano',
      name: 'Boneco de pano',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/boneco_de_pano.png',
      boxId: 'demo_box_armario_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_livro_de_cores',
      name: 'Livro de cores',
      categoryId: 'livros',
      photoAssetPath: 'assets/demo/toys/livro_de_cores.png',
      boxId: 'demo_box_armario_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_torre_de_copos',
      name: 'Torre de copos',
      categoryId: 'montessori',
      photoAssetPath: 'assets/demo/toys/torre_de_copos.png',
      boxId: 'demo_box_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_caixa_de_permanencia',
      name: 'Caixa de permanencia',
      categoryId: 'montessori',
      photoAssetPath: 'assets/demo/toys/caixa_de_permanencia.png',
      boxId: 'demo_box_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_prancha_de_pinos',
      name: 'Prancha de pinos',
      categoryId: 'coordenacao_motora',
      photoAssetPath: 'assets/demo/toys/prancha_de_pinos.png',
      boxId: 'demo_box_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_barquinho_de_madeira',
      name: 'Barquinho de madeira',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/barquinho_de_madeira.png',
      boxId: null,
      locationText: 'Prateleira da sala',
    ),
    DemoToySeed(
      id: 'demo_toy_jogo_de_memoria_infantil',
      name: 'Jogo de memoria infantil',
      categoryId: 'coordenacao_motora',
      photoAssetPath: 'assets/demo/toys/jogo_de_memoria_infantil.png',
      boxId: 'demo_box_armario_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_fantoches_de_animais',
      name: 'Fantoches de animais',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/fantoches_de_animais.png',
      boxId: 'demo_box_cesto_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_cesta_de_instrumentos',
      name: 'Cesta de instrumentos',
      categoryId: 'musica',
      photoAssetPath: 'assets/demo/toys/cesta_de_instrumentos.png',
      boxId: 'demo_box_cesto_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_rampa_de_carrinhos',
      name: 'Rampa de carrinhos',
      categoryId: 'movimento',
      photoAssetPath: 'assets/demo/toys/rampa_de_carrinhos.png',
      boxId: 'demo_box_brinquedos_grandes',
    ),
    DemoToySeed(
      id: 'demo_toy_tapete_sensorial',
      name: 'Tapete sensorial',
      categoryId: 'sensorial',
      photoAssetPath: 'assets/demo/toys/tapete_sensorial.png',
      boxId: null,
      locationText: 'Tapete da sala',
    ),
    DemoToySeed(
      id: 'demo_toy_pecas_magneticas_grandes',
      name: 'Pecas magneticas grandes',
      categoryId: 'encaixe',
      photoAssetPath: 'assets/demo/toys/pecas_magneticas_grandes.png',
      boxId: 'demo_box_brinquedos_grandes',
    ),
    DemoToySeed(
      id: 'demo_toy_maleta_de_medico_infantil',
      name: 'Maleta de medico infantil',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/maleta_de_medico_infantil.png',
      boxId: 'demo_box_cesto_sala',
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
