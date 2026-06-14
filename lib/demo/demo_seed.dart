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
      id: 'corpo',
      name: 'Corpo',
      examples: 'bolas, tunel, cones, argolas e percursos',
      developmentAspect: 'Movimento e coordenacao ampla',
      sortOrder: 1,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'maos',
      name: 'M\u00E3os',
      examples: 'blocos, encaixes, pinos e pecas de rosquear',
      developmentAspect: 'Montar, encaixar e manipular',
      sortOrder: 2,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'imaginacao',
      name: 'Imagina\u00E7\u00E3o',
      examples: 'panelinhas, bonecos, carrinhos e cenas do dia a dia',
      developmentAspect: 'Historias e faz de conta',
      sortOrder: 3,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'comunicacao',
      name: 'Comunica\u00E7\u00E3o',
      examples: 'livros, cartoes, fantoches e narrativas',
      developmentAspect: 'Linguagem, escuta e interacao',
      sortOrder: 4,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'exploracao',
      name: 'Explora\u00E7\u00E3o',
      examples: 'lupa, texturas, sons, luz e descobertas',
      developmentAspect: 'Texturas, sons e investigacao',
      sortOrder: 5,
      quota: 1,
    ),
  ];

  static const locations = <String>[
    'Sala',
    'Quarto',
    'Estante Montessori',
    'Caixa de tecido',
    'Prateleira baixa',
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
      id: 'demo_box_estante_montessori',
      number: 3,
      local: 'Estante Montessori',
    ),
    DemoBoxSeed(
      id: 'demo_box_caixa_tecido',
      number: 4,
      local: 'Caixa de tecido',
    ),
    DemoBoxSeed(
      id: 'demo_box_prateleira_baixa',
      number: 5,
      local: 'Prateleira baixa',
    ),
  ];

  static const toys = <DemoToySeed>[
    DemoToySeed(
      id: 'demo_toy_corpo_bola_macia_colorida',
      name: 'Bola macia colorida',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo/toys/demo_corpo_bola_macia_colorida.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_blocos_de_encaixe',
      name: 'Blocos de encaixe',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo/toys/demo_maos_blocos_de_encaixe.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_panelinha_de_faz_de_conta',
      name: 'Panelinha de faz de conta',
      categoryId: 'imaginacao',
      photoAssetPath:
          'assets/demo/toys/demo_imaginacao_panelinha_de_faz_de_conta.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_livro_de_figuras',
      name: 'Livro de figuras',
      categoryId: 'comunicacao',
      photoAssetPath: 'assets/demo/toys/demo_comunicacao_livro_de_figuras.png',
      boxId: null,
      locationText: 'Prateleira baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_lupa_infantil',
      name: 'Lupa infantil',
      categoryId: 'exploracao',
      photoAssetPath: 'assets/demo/toys/demo_exploracao_lupa_infantil.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_pinos_de_boliche_infantil',
      name: 'Pinos de boliche infantil',
      categoryId: 'corpo',
      photoAssetPath:
          'assets/demo/toys/demo_corpo_pinos_de_boliche_infantil.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_torre_de_empilhar',
      name: 'Torre de empilhar',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo/toys/demo_maos_torre_de_empilhar.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_boneco_bebe_de_pano',
      name: 'Boneco beb\u00EA de pano',
      categoryId: 'imaginacao',
      photoAssetPath:
          'assets/demo/toys/demo_imaginacao_boneco_bebe_de_pano.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_cartoes_de_emocoes',
      name: 'Cart\u00F5es de emo\u00E7\u00F5es',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo/toys/demo_comunicacao_cartoes_de_emocoes.png',
      boxId: null,
      locationText: 'Prateleira baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_garrafas_sensoriais',
      name: 'Garrafas sensoriais',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo/toys/demo_exploracao_garrafas_sensoriais.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_mini_cones_de_movimento',
      name: 'Mini cones de movimento',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo/toys/demo_corpo_mini_cones_de_movimento.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_quebra_cabeca_de_formas',
      name: 'Quebra-cabe\u00E7a de formas',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo/toys/demo_maos_quebra_cabeca_de_formas.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_carrinhos_coloridos',
      name: 'Carrinhos coloridos',
      categoryId: 'imaginacao',
      photoAssetPath:
          'assets/demo/toys/demo_imaginacao_carrinhos_coloridos.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_telefone_de_brinquedo',
      name: 'Telefone de brinquedo',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo/toys/demo_comunicacao_telefone_de_brinquedo.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_instrumentos_musicais',
      name: 'Instrumentos musicais',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo/toys/demo_exploracao_instrumentos_musicais.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_tapete_de_equilibrio',
      name: 'Tapete de equil\u00EDbrio',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo/toys/demo_corpo_tapete_de_equilibrio.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_cubos_sensoriais',
      name: 'Cubos sensoriais',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo/toys/demo_maos_cubos_sensoriais.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_fazendinha_de_madeira',
      name: 'Fazendinha de madeira',
      categoryId: 'imaginacao',
      photoAssetPath:
          'assets/demo/toys/demo_imaginacao_fazendinha_de_madeira.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_fantoches_de_historias',
      name: 'Fantoches de hist\u00F3rias',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo/toys/demo_comunicacao_fantoches_de_historias.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_blocos_transparentes',
      name: 'Blocos transparentes',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo/toys/demo_exploracao_blocos_transparentes.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_argolas_de_atividade',
      name: 'Argolas de atividade',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo/toys/demo_corpo_argolas_de_atividade.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_potes_de_encaixar',
      name: 'Potes de encaixar',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo/toys/demo_maos_potes_de_encaixar.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_animais_de_brinquedo',
      name: 'Animais de brinquedo',
      categoryId: 'imaginacao',
      photoAssetPath:
          'assets/demo/toys/demo_imaginacao_animais_de_brinquedo.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_alfabeto_ilustrado',
      name: 'Alfabeto ilustrado',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo/toys/demo_comunicacao_alfabeto_ilustrado.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_potes_de_descoberta',
      name: 'Potes de descoberta',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo/toys/demo_exploracao_potes_de_descoberta.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_bambole_infantil',
      name: 'Bambol\u00EA infantil',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo/toys/demo_corpo_bambole_infantil.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_martelo_de_pinos',
      name: 'Martelo de pinos',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo/toys/demo_maos_martelo_de_pinos.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_casinha_de_bonecos',
      name: 'Casinha de bonecos',
      categoryId: 'imaginacao',
      photoAssetPath: 'assets/demo/toys/demo_imaginacao_casinha_de_bonecos.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_cartoes_de_animais',
      name: 'Cart\u00F5es de animais',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo/toys/demo_comunicacao_cartoes_de_animais.png',
      boxId: null,
      locationText: 'Prateleira baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_mesa_de_atividades',
      name: 'Mesa de atividades',
      categoryId: 'exploracao',
      photoAssetPath: 'assets/demo/toys/demo_exploracao_mesa_de_atividades.png',
      boxId: null,
      locationText: 'Estante Montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_tunel_dobravel',
      name: 'T\u00FAnel dobr\u00E1vel',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo/toys/demo_corpo_tunel_dobravel.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_contas_grandes_de_montar',
      name: 'Contas grandes de montar',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo/toys/demo_maos_contas_grandes_de_montar.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_kit_medico_infantil',
      name: 'Kit m\u00E9dico infantil',
      categoryId: 'imaginacao',
      photoAssetPath:
          'assets/demo/toys/demo_imaginacao_kit_medico_infantil.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_sequencia_de_imagens',
      name: 'Sequ\u00EAncia de imagens',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo/toys/demo_comunicacao_sequencia_de_imagens.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_chocalhos_variados',
      name: 'Chocalhos variados',
      categoryId: 'exploracao',
      photoAssetPath: 'assets/demo/toys/demo_exploracao_chocalhos_variados.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_carrinho_de_empurrar',
      name: 'Carrinho de empurrar',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo/toys/demo_corpo_carrinho_de_empurrar.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_formas_geometricas',
      name: 'Formas geom\u00E9tricas',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo/toys/demo_maos_formas_geometricas.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_mercadinho_de_brincar',
      name: 'Mercadinho de brincar',
      categoryId: 'imaginacao',
      photoAssetPath:
          'assets/demo/toys/demo_imaginacao_mercadinho_de_brincar.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_microfone_de_brinquedo',
      name: 'Microfone de brinquedo',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo/toys/demo_comunicacao_microfone_de_brinquedo.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_caixa_de_texturas',
      name: 'Caixa de texturas',
      categoryId: 'exploracao',
      photoAssetPath: 'assets/demo/toys/demo_exploracao_caixa_de_texturas.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_almofadas_de_percurso',
      name: 'Almofadas de percurso',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo/toys/demo_corpo_almofadas_de_percurso.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_painel_de_abrir_e_fechar',
      name: 'Painel de abrir e fechar',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo/toys/demo_maos_painel_de_abrir_e_fechar.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_fantoches_de_animais',
      name: 'Fantoches de animais',
      categoryId: 'imaginacao',
      photoAssetPath:
          'assets/demo/toys/demo_imaginacao_fantoches_de_animais.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_livrinho_de_sons',
      name: 'Livrinho de sons',
      categoryId: 'comunicacao',
      photoAssetPath: 'assets/demo/toys/demo_comunicacao_livrinho_de_sons.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_lanterna_infantil',
      name: 'Lanterna infantil',
      categoryId: 'exploracao',
      photoAssetPath: 'assets/demo/toys/demo_exploracao_lanterna_infantil.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_bola_sensorial_com_textura',
      name: 'Bola sensorial com textura',
      categoryId: 'corpo',
      photoAssetPath:
          'assets/demo/toys/demo_corpo_bola_sensorial_com_textura.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_pecas_de_rosquear_grandes',
      name: 'Pe\u00E7as de rosquear grandes',
      categoryId: 'maos',
      photoAssetPath:
          'assets/demo/toys/demo_maos_pecas_de_rosquear_grandes.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_fantasia_de_explorador',
      name: 'Fantasia de explorador',
      categoryId: 'imaginacao',
      photoAssetPath:
          'assets/demo/toys/demo_imaginacao_fantasia_de_explorador.png',
      boxId: null,
      locationText: 'Quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_jogo_de_contar_historias',
      name: 'Jogo de contar hist\u00F3rias',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo/toys/demo_comunicacao_jogo_de_contar_historias.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_blocos_magneticos_grandes',
      name: 'Blocos magn\u00E9ticos grandes',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo/toys/demo_exploracao_blocos_magneticos_grandes.png',
      boxId: 'demo_box_estante_montessori',
    ),
  ];

  static const _balancedDailyQuotas = <String, int>{
    'corpo': 1,
    'maos': 1,
    'imaginacao': 1,
    'comunicacao': 1,
    'exploracao': 1,
  };

  static const weeklyPlans = <DemoDayPlanSeed>[
    DemoDayPlanSeed(
      weekday: DateTime.monday,
      quotas: _balancedDailyQuotas,
    ),
    DemoDayPlanSeed(
      weekday: DateTime.tuesday,
      quotas: _balancedDailyQuotas,
    ),
    DemoDayPlanSeed(
      weekday: DateTime.wednesday,
      quotas: _balancedDailyQuotas,
    ),
    DemoDayPlanSeed(
      weekday: DateTime.thursday,
      quotas: _balancedDailyQuotas,
    ),
    DemoDayPlanSeed(
      weekday: DateTime.friday,
      quotas: _balancedDailyQuotas,
    ),
    DemoDayPlanSeed(
      weekday: DateTime.saturday,
      quotas: _balancedDailyQuotas,
    ),
    DemoDayPlanSeed(
      weekday: DateTime.sunday,
      quotas: _balancedDailyQuotas,
    ),
  ];

  static const activeRoundToyIds = <String>[
    'demo_toy_corpo_bola_macia_colorida',
    'demo_toy_maos_blocos_de_encaixe',
    'demo_toy_imaginacao_panelinha_de_faz_de_conta',
    'demo_toy_comunicacao_livro_de_figuras',
    'demo_toy_exploracao_lupa_infantil',
  ];
}
