import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/age_preset.dart';

List<CategoryDefinition> officialToyFormCategories(
  List<CategoryDefinition> categories,
) {
  final result = <CategoryDefinition>[];

  for (final official in AgePresetCatalog.officialCategories) {
    final match = _bestMatchForOfficial(categories, official);
    if (match != null) {
      result.add(match);
    }
  }

  return result;
}

bool isOfficialToyFormCategory(CategoryDefinition category) {
  return officialToyFormCategory(category) != null;
}

String toyFormCategoryName(CategoryDefinition category) {
  return officialToyFormCategory(category)?.name ?? category.name;
}

String? toyFormCategoryExamples(CategoryDefinition category) {
  return officialToyFormCategory(category)?.examples ?? category.examples;
}

String? toyFormCategoryDevelopmentAspect(CategoryDefinition category) {
  return officialToyFormCategory(category)?.developmentAspect ??
      category.developmentAspect;
}

OfficialAgeCategory? officialToyFormCategory(CategoryDefinition category) {
  final normalizedId = _normalizeCategoryKey(category.id);

  for (final official in AgePresetCatalog.officialCategories) {
    if (normalizedId == official.id) {
      return official;
    }
  }

  return null;
}

CategoryDefinition? _bestMatchForOfficial(
  List<CategoryDefinition> categories,
  OfficialAgeCategory official,
) {
  for (final category in categories) {
    if (_normalizeCategoryKey(category.id) == official.id) {
      return category;
    }
  }

  return null;
}

String _normalizeCategoryKey(String value) {
  var normalized = value.trim().toLowerCase();
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
