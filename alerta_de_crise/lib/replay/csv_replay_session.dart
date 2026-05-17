import 'csv_replay_statistics.dart';

class CsvReplaySession {
  final String id;
  final DateTime createdAt;
  final int totalSamples;
  final int processedSamples;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double averageScore;
  final int highestScore;
  final int highInterventionCount;
  final CsvReplayStatistics statistics;

  const CsvReplaySession({
    required this.id,
    required this.createdAt,
    required this.totalSamples,
    required this.processedSamples,
    required this.startedAt,
    required this.completedAt,
    required this.averageScore,
    required this.highestScore,
    required this.highInterventionCount,
    required this.statistics,
  });
}
