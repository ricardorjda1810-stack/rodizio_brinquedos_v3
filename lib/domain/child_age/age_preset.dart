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
}
