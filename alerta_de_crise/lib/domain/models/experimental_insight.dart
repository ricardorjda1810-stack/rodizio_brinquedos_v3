enum InsightCategory {
  activation('activation'),
  recovery('recovery'),
  collection('collection'),
  protocol('protocol');

  const InsightCategory(this.key);

  final String key;

  String get label {
    return switch (this) {
      InsightCategory.activation => 'Ativação',
      InsightCategory.recovery => 'Recuperação',
      InsightCategory.collection => 'Coleta',
      InsightCategory.protocol => 'Protocolo',
    };
  }
}

final class ExperimentalInsight {
  const ExperimentalInsight({
    required this.title,
    required this.description,
    required this.category,
    required this.confidenceLabel,
    required this.valueSummary,
  });

  final String title;
  final String description;
  final InsightCategory category;
  final String confidenceLabel;
  final String valueSummary;
}
