import 'research_export_statistics.dart';

enum ResearchExportType {
  crisisEvents,
  interventionHistory,
  replaySessions,
  fullBundle,
}

class ResearchExportBundle {
  final DateTime generatedAt;
  final int totalEvents;
  final int totalInterventions;
  final int totalReplaySessions;
  final ResearchExportStatistics statistics;
  final Map<ResearchExportType, String> csvContents;

  const ResearchExportBundle({
    required this.generatedAt,
    required this.totalEvents,
    required this.totalInterventions,
    required this.totalReplaySessions,
    required this.statistics,
    required this.csvContents,
  });

  String get fullCsv => csvContents[ResearchExportType.fullBundle] ?? '';
}
