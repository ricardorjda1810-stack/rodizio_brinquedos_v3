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
  final String photoAssetPath;

  const DemoBoxSeed({
    required this.id,
    required this.number,
    required this.local,
    required this.photoAssetPath,
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
      name: 'Corpo e Respira\u00E7\u00E3o',
      examples: 'movimento, equilibrio, sopro e pausa corporal',
      developmentAspect: 'Movimento, equilibrio, sopro e pausa corporal',
      sortOrder: 1,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'exploracao',
      name: 'Sentidos e Explora\u00E7\u00E3o',
      examples: 'texturas, sons, cores, agua, areia e descoberta',
      developmentAspect: 'Texturas, sons, cores, agua, areia e descoberta',
      sortOrder: 2,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'maos',
      name: 'M\u00E3os e Constru\u00E7\u00E3o',
      examples: 'encaixar, empilhar, montar e resolver problemas',
      developmentAspect: 'Encaixar, empilhar, montar e resolver problemas',
      sortOrder: 3,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'imaginacao',
      name: 'Imagina\u00E7\u00E3o e Criatividade',
      examples: 'faz de conta, arte, criacao e expressao',
      developmentAspect: 'Faz de conta, arte, criacao e expressao',
      sortOrder: 4,
      quota: 1,
    ),
    DemoCategorySeed(
      id: 'comunicacao',
      name: 'Comunica\u00E7\u00E3o e Hist\u00F3rias',
      examples: 'livros, fala, escuta, narrativa e conversa',
      developmentAspect: 'Livros, fala, escuta, narrativa e conversa',
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
      photoAssetPath: 'assets/demo_boxes/demo_box_sala.png',
    ),
    DemoBoxSeed(
      id: 'demo_box_quarto',
      number: 2,
      local: 'Quarto',
      photoAssetPath: 'assets/demo_boxes/demo_box_quarto.png',
    ),
    DemoBoxSeed(
      id: 'demo_box_estante_montessori',
      number: 3,
      local: 'Estante Montessori',
      photoAssetPath: 'assets/demo_boxes/demo_box_estante_montessori.png',
    ),
    DemoBoxSeed(
      id: 'demo_box_caixa_tecido',
      number: 4,
      local: 'Caixa de tecido',
      photoAssetPath: 'assets/demo_boxes/demo_box_caixa_tecido.png',
    ),
    DemoBoxSeed(
      id: 'demo_box_prateleira_baixa',
      number: 5,
      local: 'Prateleira baixa',
      photoAssetPath: 'assets/demo_boxes/demo_box_prateleira_baixa.png',
    ),
  ];

  static const toys = <DemoToySeed>[
    DemoToySeed(
      id: 'demo_toy_corpo_bola_macia',
      name: 'Bola macia',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo_toys_v2/corpo_bola_macia.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_torre_empilhar',
      name: 'Torre de empilhar',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo_toys_v2/maos_torre_empilhar.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_cozinha_brinquedo',
      name: 'Cozinha de brinquedo',
      categoryId: 'imaginacao',
      photoAssetPath: 'assets/demo_toys_v2/imaginacao_cozinha_brinquedo.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_livro_cartonado',
      name: 'Livro cartonado',
      categoryId: 'comunicacao',
      photoAssetPath: 'assets/demo_toys_v2/comunicacao_livro_cartonado.png',
      boxId: null,
      locationText: 'Prateleira baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_lupa_infantil',
      name: 'Lupa infantil',
      categoryId: 'exploracao',
      photoAssetPath: 'assets/demo_toys_v2/exploracao_lupa_infantil.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_tunel_infantil_dobravel',
      name: 'T\u00FAnel infantil dobr\u00E1vel',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo_toys_v2/corpo_tunel_infantil_dobravel.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_encaixe_formas',
      name: 'Encaixe de formas',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo_toys_v2/maos_encaixe_formas.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_comidinhas_madeira',
      name: 'Comidinhas de madeira',
      categoryId: 'imaginacao',
      photoAssetPath: 'assets/demo_toys_v2/imaginacao_comidinhas_madeira.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_cartoes_figuras',
      name: 'Cart\u00F5es de figuras',
      categoryId: 'comunicacao',
      photoAssetPath: 'assets/demo_toys_v2/comunicacao_cartoes_figuras.png',
      boxId: null,
      locationText: 'Prateleira baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_instrumentos_musicais_simples',
      name: 'Instrumentos musicais simples',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo_toys_v2/exploracao_instrumentos_musicais_simples.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_bambole_infantil',
      name: 'Bambol\u00EA infantil',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo_toys_v2/corpo_bambole_infantil.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_quebra_cabeca_madeira',
      name: 'Quebra-cabe\u00E7a de madeira',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo_toys_v2/maos_quebra_cabeca_madeira.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_animais_fazenda',
      name: 'Animais de fazenda',
      categoryId: 'imaginacao',
      photoAssetPath: 'assets/demo_toys_v2/imaginacao_animais_fazenda.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_telefone_brinquedo_simples',
      name: 'Telefone de brinquedo simples',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo_toys_v2/comunicacao_telefone_brinquedo_simples.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_mesa_areia_agua',
      name: 'Mesa de areia e \u00E1gua',
      categoryId: 'exploracao',
      photoAssetPath: 'assets/demo_toys_v2/exploracao_mesa_areia_agua.png',
      boxId: null,
      locationText: 'Estante Montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_tapete_movimento',
      name: 'Tapete de movimento',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo_toys_v2/corpo_tapete_movimento.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_blocos_grandes',
      name: 'Blocos grandes',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo_toys_v2/maos_blocos_grandes.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_bonecos_familia_simples',
      name: 'Bonecos fam\u00EDlia simples',
      categoryId: 'imaginacao',
      photoAssetPath:
          'assets/demo_toys_v2/imaginacao_bonecos_familia_simples.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_fantoches_historia',
      name: 'Fantoches para hist\u00F3ria',
      categoryId: 'comunicacao',
      photoAssetPath: 'assets/demo_toys_v2/comunicacao_fantoches_historia.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_kit_jardinagem_infantil',
      name: 'Kit jardinagem infantil',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo_toys_v2/exploracao_kit_jardinagem_infantil.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_cones_coloridos',
      name: 'Cones coloridos',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo_toys_v2/corpo_cones_coloridos.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_cubos_montar_sem_marca',
      name: 'Cubos de montar sem marca',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo_toys_v2/maos_cubos_montar_sem_marca.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_carrinhos_madeira',
      name: 'Carrinhos de madeira',
      categoryId: 'imaginacao',
      photoAssetPath: 'assets/demo_toys_v2/imaginacao_carrinhos_madeira.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_jogo_memoria_imagens',
      name: 'Jogo da mem\u00F3ria com imagens',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo_toys_v2/comunicacao_jogo_memoria_imagens.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_animais_insetos_exploracao',
      name: 'Animais e insetos de explora\u00E7\u00E3o',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo_toys_v2/exploracao_animais_insetos_exploracao.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_prancha_equilibrio_baixa',
      name: 'Prancha de equil\u00EDbrio baixa',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo_toys_v2/corpo_prancha_equilibrio_baixa.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_brinquedo_martelar',
      name: 'Brinquedo de martelar',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo_toys_v2/maos_brinquedo_martelar.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_trem_madeira',
      name: 'Trem de madeira',
      categoryId: 'imaginacao',
      photoAssetPath: 'assets/demo_toys_v2/imaginacao_trem_madeira.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_letras_grandes_madeira_espuma',
      name: 'Letras grandes de madeira ou espuma',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo_toys_v2/comunicacao_letras_grandes_madeira_espuma.png',
      boxId: null,
      locationText: 'Prateleira baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_garrafas_sensoriais_seguras',
      name: 'Garrafas sensoriais seguras',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo_toys_v2/exploracao_garrafas_sensoriais_seguras.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_almofadas_percurso',
      name: 'Almofadas de percurso',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo_toys_v2/corpo_almofadas_percurso.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_parafusos_porcas_grandes',
      name: 'Parafusos e porcas grandes',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo_toys_v2/maos_parafusos_porcas_grandes.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_casinha_bonecos',
      name: 'Casinha de bonecos',
      categoryId: 'imaginacao',
      photoAssetPath: 'assets/demo_toys_v2/imaginacao_casinha_bonecos.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_dados_historias',
      name: 'Dados de hist\u00F3rias',
      categoryId: 'comunicacao',
      photoAssetPath: 'assets/demo_toys_v2/comunicacao_dados_historias.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_tubos_observacao_transparentes',
      name: 'Tubos de observa\u00E7\u00E3o transparentes',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo_toys_v2/exploracao_tubos_observacao_transparentes.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_argolas_arremesso',
      name: 'Argolas de arremesso',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo_toys_v2/corpo_argolas_arremesso.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_alinhavo_pecas_grandes',
      name: 'Alinhavo com pe\u00E7as grandes',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo_toys_v2/maos_alinhavo_pecas_grandes.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_kit_medico_infantil',
      name: 'Kit m\u00E9dico infantil',
      categoryId: 'imaginacao',
      photoAssetPath: 'assets/demo_toys_v2/imaginacao_kit_medico_infantil.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_cartoes_emocoes',
      name: 'Cart\u00F5es de emo\u00E7\u00F5es',
      categoryId: 'comunicacao',
      photoAssetPath: 'assets/demo_toys_v2/comunicacao_cartoes_emocoes.png',
      boxId: null,
      locationText: 'Prateleira baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_pedras_formas_sensoriais_grandes',
      name: 'Pedras e formas sensoriais grandes',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo_toys_v2/exploracao_pedras_formas_sensoriais_grandes.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_cavalinho_balanco_simples',
      name: 'Cavalinho de balan\u00E7o simples',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo_toys_v2/corpo_cavalinho_balanco_simples.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_painel_fechos_busy_board',
      name: 'Painel de fechos',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo_toys_v2/maos_painel_fechos_busy_board.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_fantasias_simples',
      name: 'Fantasias simples',
      categoryId: 'imaginacao',
      photoAssetPath: 'assets/demo_toys_v2/imaginacao_fantasias_simples.png',
      boxId: null,
      locationText: 'Quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_mini_quadro_branco',
      name: 'Mini quadro branco',
      categoryId: 'comunicacao',
      photoAssetPath: 'assets/demo_toys_v2/comunicacao_mini_quadro_branco.png',
      boxId: null,
      locationText: 'Sala',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_circuito_bolinhas_grandes',
      name: 'Circuito de bolinhas grandes',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo_toys_v2/exploracao_circuito_bolinhas_grandes.png',
      boxId: 'demo_box_estante_montessori',
    ),
    DemoToySeed(
      id: 'demo_toy_corpo_mini_cesta_bola',
      name: 'Mini cesta com bola',
      categoryId: 'corpo',
      photoAssetPath: 'assets/demo_toys_v2/corpo_mini_cesta_bola.png',
      boxId: 'demo_box_sala',
    ),
    DemoToySeed(
      id: 'demo_toy_maos_copos_medidores_empilhar',
      name: 'Copos medidores de empilhar',
      categoryId: 'maos',
      photoAssetPath: 'assets/demo_toys_v2/maos_copos_medidores_empilhar.png',
      boxId: 'demo_box_caixa_tecido',
    ),
    DemoToySeed(
      id: 'demo_toy_imaginacao_fantoches_animais',
      name: 'Fantoches de animais',
      categoryId: 'imaginacao',
      photoAssetPath: 'assets/demo_toys_v2/imaginacao_fantoches_animais.png',
      boxId: 'demo_box_quarto',
    ),
    DemoToySeed(
      id: 'demo_toy_comunicacao_sequencia_historias_ilustradas',
      name: 'Sequ\u00EAncia de hist\u00F3rias ilustradas',
      categoryId: 'comunicacao',
      photoAssetPath:
          'assets/demo_toys_v2/comunicacao_sequencia_historias_ilustradas.png',
      boxId: 'demo_box_prateleira_baixa',
    ),
    DemoToySeed(
      id: 'demo_toy_exploracao_brinquedo_causa_efeito',
      name: 'Brinquedo causa-e-efeito',
      categoryId: 'exploracao',
      photoAssetPath:
          'assets/demo_toys_v2/exploracao_brinquedo_causa_efeito.png',
      boxId: 'demo_box_caixa_tecido',
    ),
  ];

  static const _balancedDailyQuotas = <String, int>{
    'corpo': 1,
    'exploracao': 1,
    'maos': 1,
    'imaginacao': 1,
    'comunicacao': 1,
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
    'demo_toy_corpo_bola_macia',
    'demo_toy_maos_torre_empilhar',
    'demo_toy_imaginacao_cozinha_brinquedo',
    'demo_toy_comunicacao_livro_cartonado',
    'demo_toy_exploracao_lupa_infantil',
  ];
}
