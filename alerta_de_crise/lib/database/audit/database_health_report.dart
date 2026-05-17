class DatabaseHealthReport {
  final DateTime generatedAt;
  final int schemaVersion;
  final List<String> tablesChecked;
  final int totalRecords;
  final bool hasIntegrityIssues;
  final List<String> issues;
  final List<String> warnings;
  final int healthScore;

  const DatabaseHealthReport({
    required this.generatedAt,
    required this.schemaVersion,
    required this.tablesChecked,
    required this.totalRecords,
    required this.hasIntegrityIssues,
    required this.issues,
    required this.warnings,
    required this.healthScore,
  });

  bool get isHealthy => !hasIntegrityIssues;
}
