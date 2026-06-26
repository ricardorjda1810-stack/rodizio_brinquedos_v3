import 'package:rodizio_brinquedos_v3/domain/child_age/child_age_range.dart';

class OfficialAgeCategory {
  final String id;
  final String name;
  final String examples;
  final String developmentAspect;
  final int sortOrder;
  final List<String> legacyNames;

  const OfficialAgeCategory({
    required this.id,
    required this.name,
    required this.examples,
    required this.developmentAspect,
    required this.sortOrder,
    this.legacyNames = const <String>[],
  });
}

class AgePreset {
  final ChildAgeRange ageRange;
  final Map<String, int> quotasByCategoryId;
  final String saturdayExtraCategoryId;
  final String sundayExtraCategoryId;

  const AgePreset({
    required this.ageRange,
    required this.quotasByCategoryId,
    required this.saturdayExtraCategoryId,
    required this.sundayExtraCategoryId,
  });

  String get label => ageRange.label;

  int get total => _totalFor(quotasByCategoryId);

  Map<String, int> quotasForWeekday(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return _withExtra(saturdayExtraCategoryId);
      case DateTime.sunday:
        return _withExtra(sundayExtraCategoryId);
      default:
        return Map<String, int>.unmodifiable(quotasByCategoryId);
    }
  }

  int totalForWeekday(int weekday) => _totalFor(quotasForWeekday(weekday));

  Map<String, int> _withExtra(String categoryId) {
    final quotas = Map<String, int>.of(quotasByCategoryId);
    quotas[categoryId] = (quotas[categoryId] ?? 0) + 1;
    return Map<String, int>.unmodifiable(quotas);
  }

  int _totalFor(Map<String, int> quotas) {
    var value = 0;
    for (final quota in quotas.values) {
      value += quota < 0 ? 0 : quota;
    }
    return value;
  }
}

class AgePresetCatalog {
  static const officialCategoryIds = <String>[
    'corpo',
    'exploracao',
    'maos',
    'imaginacao',
    'comunicacao',
  ];

  static const legacyCategoryTargetsByKey = <String, String>{
    'corpo': 'corpo',
    'movimento': 'corpo',
    'respiracao': 'corpo',
    'exploracao': 'exploracao',
    'sensorio': 'exploracao',
    'sensorial': 'exploracao',
    'sentidos': 'exploracao',
    'texturas': 'exploracao',
    'maos': 'maos',
    'construcao': 'maos',
    'coordenacao': 'maos',
    'imaginacao': 'imaginacao',
    'faz de conta': 'imaginacao',
    'faz_de_conta': 'imaginacao',
    'criatividade': 'imaginacao',
    'comunicacao': 'comunicacao',
    'livros': 'comunicacao',
    'livro': 'comunicacao',
    'historias': 'comunicacao',
    'historia': 'comunicacao',
  };

  static const officialCategories = <OfficialAgeCategory>[
    OfficialAgeCategory(
      id: 'corpo',
      name: 'Corpo e Respiração',
      examples: 'movimento • equilíbrio • sopro • pausa corporal',
      developmentAspect: 'Movimento, equilíbrio, sopro e pausa corporal',
      sortOrder: 1,
      legacyNames: <String>[
        'Corpo',
        'Movimento',
      ],
    ),
    OfficialAgeCategory(
      id: 'exploracao',
      name: 'Sentidos e Exploração',
      examples: 'texturas • sons • cores • água • areia • descoberta',
      developmentAspect: 'Texturas, sons, cores, água, areia e descoberta',
      sortOrder: 2,
      legacyNames: <String>[
        'Exploração',
        'Sensorial',
        'Sentidos',
        'Texturas',
      ],
    ),
    OfficialAgeCategory(
      id: 'maos',
      name: 'Mãos e Construção',
      examples: 'encaixar • empilhar • montar • resolver problemas',
      developmentAspect: 'Encaixar, empilhar, montar e resolver problemas',
      sortOrder: 3,
      legacyNames: <String>[
        'Mãos',
        'Montar e Raciocinar',
        'Construção',
        'Coordenação',
      ],
    ),
    OfficialAgeCategory(
      id: 'imaginacao',
      name: 'Imaginação e Criatividade',
      examples: 'faz de conta • arte • criação • expressão',
      developmentAspect: 'Faz de conta, arte, criação e expressão',
      sortOrder: 4,
      legacyNames: <String>[
        'Imaginação',
        'Faz de Conta',
      ],
    ),
    OfficialAgeCategory(
      id: 'comunicacao',
      name: 'Comunicação e Histórias',
      examples: 'livros • fala • escuta • narrativa • conversa',
      developmentAspect: 'Livros, fala, escuta, narrativa e conversa',
      sortOrder: 5,
      legacyNames: <String>[
        'Comunicação',
        'Histórias e Linguagem',
        'Livros',
      ],
    ),
  ];

  static const presets = <ChildAgeRange, AgePreset>{
    ChildAgeRange.months0To6: AgePreset(
      ageRange: ChildAgeRange.months0To6,
      saturdayExtraCategoryId: 'exploracao',
      sundayExtraCategoryId: 'comunicacao',
      quotasByCategoryId: {
        'corpo': 0,
        'maos': 1,
        'imaginacao': 0,
        'comunicacao': 1,
        'exploracao': 2,
      },
    ),
    ChildAgeRange.months6To12: AgePreset(
      ageRange: ChildAgeRange.months6To12,
      saturdayExtraCategoryId: 'corpo',
      sundayExtraCategoryId: 'exploracao',
      quotasByCategoryId: {
        'corpo': 1,
        'maos': 1,
        'imaginacao': 0,
        'comunicacao': 1,
        'exploracao': 2,
      },
    ),
    ChildAgeRange.years1To2: AgePreset(
      ageRange: ChildAgeRange.years1To2,
      saturdayExtraCategoryId: 'corpo',
      sundayExtraCategoryId: 'imaginacao',
      quotasByCategoryId: {
        'corpo': 1,
        'maos': 2,
        'imaginacao': 1,
        'comunicacao': 1,
        'exploracao': 1,
      },
    ),
    ChildAgeRange.years2To3: AgePreset(
      ageRange: ChildAgeRange.years2To3,
      saturdayExtraCategoryId: 'corpo',
      sundayExtraCategoryId: 'imaginacao',
      quotasByCategoryId: {
        'corpo': 2,
        'maos': 2,
        'imaginacao': 2,
        'comunicacao': 1,
        'exploracao': 1,
      },
    ),
    ChildAgeRange.years3To5: AgePreset(
      ageRange: ChildAgeRange.years3To5,
      saturdayExtraCategoryId: 'corpo',
      sundayExtraCategoryId: 'comunicacao',
      quotasByCategoryId: {
        'corpo': 1,
        'maos': 2,
        'imaginacao': 2,
        'comunicacao': 2,
        'exploracao': 2,
      },
    ),
    ChildAgeRange.years5To7: AgePreset(
      ageRange: ChildAgeRange.years5To7,
      saturdayExtraCategoryId: 'imaginacao',
      sundayExtraCategoryId: 'comunicacao',
      quotasByCategoryId: {
        'corpo': 1,
        'maos': 2,
        'imaginacao': 3,
        'comunicacao': 2,
        'exploracao': 2,
      },
    ),
  };

  static AgePreset presetFor(ChildAgeRange ageRange) {
    return presets[ageRange]!;
  }

  static OfficialAgeCategory categoryById(String id) {
    return officialCategories.firstWhere((category) => category.id == id);
  }

  static List<String> categoryNameCandidates(OfficialAgeCategory category) {
    return <String>[
      category.name,
      ...category.legacyNames,
    ];
  }

  static bool isOfficialCategoryId(String? id) {
    final normalized = normalizeCategoryKey(id);
    return officialCategoryIds.contains(normalized);
  }

  static String? officialCategoryIdForLegacyKey(String? value) {
    final normalized = normalizeCategoryKey(value);
    if (normalized.isEmpty) return null;
    if (officialCategoryIds.contains(normalized)) return normalized;
    return legacyCategoryTargetsByKey[normalized];
  }

  static String normalizeCategoryKey(String? value) {
    var normalized = value?.trim().toLowerCase() ?? '';
    const replacements = <String, String>{
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'ê': 'e',
      'è': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    for (final entry in replacements.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }

    return normalized.replaceAll(RegExp(r'\s+'), ' ');
  }
}
