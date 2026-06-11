import 'package:rodizio_brinquedos_v3/domain/child_age/child_age_range.dart';

class OfficialAgeCategory {
  final String id;
  final String name;
  final String examples;
  final int sortOrder;

  const OfficialAgeCategory({
    required this.id,
    required this.name,
    required this.examples,
    required this.sortOrder,
  });
}

class AgePreset {
  final ChildAgeRange ageRange;
  final Map<String, int> quotasByCategoryId;

  const AgePreset({
    required this.ageRange,
    required this.quotasByCategoryId,
  });

  String get label => ageRange.label;

  int get total {
    var value = 0;
    for (final quota in quotasByCategoryId.values) {
      value += quota < 0 ? 0 : quota;
    }
    return value;
  }
}

class AgePresetCatalog {
  static const officialCategories = <OfficialAgeCategory>[
    OfficialAgeCategory(
      id: 'corpo',
      name: 'Corpo',
      examples: 'bola • túnel • cavalinho • empurrar',
      sortOrder: 1,
    ),
    OfficialAgeCategory(
      id: 'maos',
      name: 'Mãos',
      examples: 'blocos • encaixes • quebra-cabeça • argolas',
      sortOrder: 2,
    ),
    OfficialAgeCategory(
      id: 'imaginacao',
      name: 'Imaginação',
      examples: 'bonecos • cozinha • carrinhos • ferramentas',
      sortOrder: 3,
    ),
    OfficialAgeCategory(
      id: 'comunicacao',
      name: 'Comunicação',
      examples: 'livros • fantoches • animais • jogos simples',
      sortOrder: 4,
    ),
    OfficialAgeCategory(
      id: 'exploracao',
      name: 'Exploração',
      examples: 'massinha • chocalho • água • areia • tecidos',
      sortOrder: 5,
    ),
  ];

  static const presets = <ChildAgeRange, AgePreset>{
    ChildAgeRange.months0To6: AgePreset(
      ageRange: ChildAgeRange.months0To6,
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
}
