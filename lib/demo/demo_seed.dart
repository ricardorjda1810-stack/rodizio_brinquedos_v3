class DemoCategorySeed {
  final String id;
  final String name;
  final String examples;
  final String developmentAspect;
  final int sortOrder;
  final int quota;

  const DemoCategorySeed({
    required this.id,
    required this.name,
    required this.examples,
    required this.developmentAspect,
    required this.sortOrder,
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

class DemoDayPlanSeed {
  final int weekday;
  final Map<String, int> quotas;

  const DemoDayPlanSeed({
    required this.weekday,
    required this.quotas,
  });
}

class DemoSeed {
  static const categories = <DemoCategorySeed>[
    DemoCategorySeed(
      id: 'faz_de_conta',
      name: 'Faz de Conta',
      examples: 'bonecos, carrinhos, animais e cenas do dia a dia',
      developmentAspect: 'Imaginacao, imitacao e vida pratica',
      sortOrder: 1,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'movimento',
      name: 'Movimento',
      examples: 'triciclo, bike, bola e brinquedos de empurrar',
      developmentAspect: 'Coordenacao ampla, equilibrio e autonomia motora',
      sortOrder: 2,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'coordenacao',
      name: 'Sensorial e Coordenacao',
      examples: 'martelar, encaixar, tocar, abrir e fechar',
      developmentAspect: 'Coordenacao fina, tato, ritmo e exploracao sensorial',
      sortOrder: 3,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'construcao',
      name: 'Montar e Raciocinar',
      examples: 'blocos, quebra-cabecas, pecas e desafios simples',
      developmentAspect: 'Raciocinio, concentracao e resolucao de problemas',
      sortOrder: 4,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'livros',
      name: 'Historias e Linguagem',
      examples: 'livros, figuras, animais, narrativas e conversas',
      developmentAspect: 'Linguagem, escuta, vocabulario e narrativa',
      sortOrder: 5,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'arte_musica',
      name: 'Arte e Musica',
      examples: 'instrumentos, sons, ritmos, cores e criacao',
      developmentAspect: 'Expressao criativa, ritmo e percepcao auditiva',
      sortOrder: 6,
      quota: 0,
    ),
  ];

  static const locations = <String>[
    'Sala',
    'Quarto',
    'Area de brincar',
    'Estante - Sala',
    'Tapete',
  ];

  static const boxes = <DemoBoxSeed>[
    DemoBoxSeed(
      id: 'demo_box_sala',
      number: 1,
      local: 'Sala',
    ),
    DemoBoxSeed(
      id: 'demo_box_quarto',
      number: 2,
      local: 'Quarto',
    ),
    DemoBoxSeed(
      id: 'demo_box_area_brincar',
      number: 3,
      local: 'Area de brincar',
    ),
  ];

  static const toys = <DemoToySeed>[
    DemoToySeed(
      id: 'demo_toy_dinossauro_verde',
      name: 'Dinossauro verde',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/animais_de_madeira.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_bola_sensorial',
      name: 'Bola sensorial',
      categoryId: 'coordenacao',
      photoAssetPath: 'assets/demo/toys/bola_sensorial.png',
      boxId: null,
      locationText: 'Tapete',
    ),
    DemoToySeed(
      id: 'demo_toy_triciclo',
      name: 'Triciclo',
      categoryId: 'movimento',
      photoAssetPath: 'assets/demo/toys/rampa_de_carrinhos.png',
      boxId: 'demo_box_area_brincar',
    ),
    DemoToySeed(
      id: 'demo_toy_livro_de_historias',
      name: 'Livro de historias',
      categoryId: 'livros',
      photoAssetPath: 'assets/demo/toys/livro_de_cores.png',
      boxId: null,
      locationText: 'Estante - Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_blocos_coloridos',
      name: 'Blocos coloridos',
      categoryId: 'construcao',
      photoAssetPath: 'assets/demo/toys/blocos_de_madeira.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_ursinho_caramelo',
      name: 'Ursinho Caramelo',
      categoryId: 'faz_de_conta',
      photoAssetPath: 'assets/demo/toys/boneco_de_pano.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_instrumento_musical',
      name: 'Instrumento musical',
      categoryId: 'arte_musica',
      photoAssetPath: 'assets/demo/toys/tambor_infantil.png',
      boxId: 'demo_box_area_brincar',
    ),
    DemoToySeed(
      id: 'demo_toy_caminhao_de_martelar',
      name: 'Caminhao de martelar',
      categoryId: 'coordenacao',
      photoAssetPath: 'assets/demo/toys/caminhao_de_encaixe.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_kit_de_arte',
      name: 'Kit de arte',
      categoryId: 'arte_musica',
      photoAssetPath: 'assets/demo/toys/pecas_magneticas_grandes.png',
      boxId: null,
      locationText: 'Estante - Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_carrinho_vermelho',
      name: 'Carrinho vermelho',
      categoryId: 'movimento',
      photoAssetPath: 'assets/demo/toys/carrinho_de_madeira.png',
      boxId: 'demo_box_area_brincar',
    ),
    DemoToySeed(
      id: 'demo_toy_quebra_cabeca_fazenda',
      name: 'Quebra-cabeca',
      categoryId: 'construcao',
      photoAssetPath: 'assets/demo/toys/quebra_cabeca.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_bike_de_equilibrio',
      name: 'Bike de equilibrio',
      categoryId: 'movimento',
      photoAssetPath: 'assets/demo/toys/tapete_sensorial.png',
      boxId: null,
      locationText: 'Tapete',
    ),
  ];

  static const weeklyPlans = <DemoDayPlanSeed>[
    DemoDayPlanSeed(
      weekday: DateTime.monday,
      quotas: <String, int>{
        'faz_de_conta': 1,
        'movimento': 1,
        'coordenacao': 1,
        'construcao': 1,
        'livros': 1,
      },
    ),
    DemoDayPlanSeed(
      weekday: DateTime.tuesday,
      quotas: <String, int>{
        'faz_de_conta': 1,
        'movimento': 1,
        'coordenacao': 1,
        'construcao': 1,
        'arte_musica': 1,
      },
    ),
    DemoDayPlanSeed(
      weekday: DateTime.wednesday,
      quotas: <String, int>{
        'faz_de_conta': 1,
        'coordenacao': 1,
        'construcao': 1,
        'livros': 1,
        'arte_musica': 1,
      },
    ),
    DemoDayPlanSeed(
      weekday: DateTime.thursday,
      quotas: <String, int>{
        'faz_de_conta': 1,
        'movimento': 1,
        'construcao': 1,
        'livros': 1,
        'arte_musica': 1,
      },
    ),
    DemoDayPlanSeed(
      weekday: DateTime.friday,
      quotas: <String, int>{
        'faz_de_conta': 1,
        'movimento': 1,
        'coordenacao': 1,
        'livros': 1,
        'arte_musica': 1,
      },
    ),
    DemoDayPlanSeed(
      weekday: DateTime.saturday,
      quotas: <String, int>{
        'movimento': 1,
        'coordenacao': 1,
        'construcao': 1,
        'livros': 1,
        'arte_musica': 1,
      },
    ),
    DemoDayPlanSeed(
      weekday: DateTime.sunday,
      quotas: <String, int>{
        'faz_de_conta': 1,
        'movimento': 1,
        'coordenacao': 1,
        'livros': 1,
        'arte_musica': 1,
      },
    ),
  ];

  static const activeRoundToyIds = <String>[
    'demo_toy_dinossauro_verde',
    'demo_toy_bola_sensorial',
    'demo_toy_livro_de_historias',
    'demo_toy_blocos_coloridos',
    'demo_toy_instrumento_musical',
  ];
}
