import '../data/crisis_detection/crisis_risk_event.dart';
import '../data/crisis_detection/intervention_history_entry.dart';
import '../replay/csv_replay_session.dart';

class ResearchCsvExporter {
  const ResearchCsvExporter();

  String exportCrisisEvents(List<CrisisRiskEvent> events) {
    return _rowsToCsv([
      [
        'id',
        'timestamp',
        'score',
        'level',
        'reasonCodes',
        'recommendedAction',
        'cognitiveResponse',
        'source',
      ],
      for (final event in events)
        [
          event.id,
          event.timestamp.toIso8601String(),
          event.score,
          event.level.name,
          event.reasonCodes.join('|'),
          event.recommendedAction,
          event.cognitiveResponse.name,
          event.source,
        ],
    ]);
  }

  String exportInterventionHistory(List<InterventionHistoryEntry> entries) {
    return _rowsToCsv([
      [
        'id',
        'protocolId',
        'startedAt',
        'completedAt',
        'durationSeconds',
        'completed',
        'userReportedImprovement',
        'finalResponse',
        'preInterventionScore',
        'postInterventionScore',
        'scoreDelta',
      ],
      for (final entry in entries)
        [
          entry.id,
          entry.protocolId,
          entry.startedAt.toIso8601String(),
          entry.completedAt.toIso8601String(),
          entry.durationSeconds,
          entry.completed,
          entry.userReportedImprovement,
          entry.finalResponse.name,
          entry.preInterventionScore,
          entry.postInterventionScore,
          entry.scoreDelta,
        ],
    ]);
  }

  String exportReplaySessions(List<CsvReplaySession> sessions) {
    return _rowsToCsv([
      [
        'id',
        'createdAt',
        'totalSamples',
        'processedSamples',
        'startedAt',
        'completedAt',
        'averageScore',
        'highestScore',
        'highInterventionCount',
        'mildAttentionCount',
        'moderateAlertCount',
        'averageHeartRate',
        'averageHrv',
      ],
      for (final session in sessions)
        [
          session.id,
          session.createdAt.toIso8601String(),
          session.totalSamples,
          session.processedSamples,
          session.startedAt?.toIso8601String(),
          session.completedAt?.toIso8601String(),
          session.averageScore,
          session.highestScore,
          session.highInterventionCount,
          session.statistics.mildAttentionCount,
          session.statistics.moderateAlertCount,
          session.statistics.averageHeartRate,
          session.statistics.averageHrv,
        ],
    ]);
  }

  String exportFullBundle({
    required List<CrisisRiskEvent> crisisEvents,
    required List<InterventionHistoryEntry> interventions,
    required List<CsvReplaySession> replaySessions,
  }) {
    return [
      '# crisisEvents',
      exportCrisisEvents(crisisEvents),
      '# interventionHistory',
      exportInterventionHistory(interventions),
      '# replaySessions',
      exportReplaySessions(replaySessions),
    ].join('\n\n');
  }

  String _rowsToCsv(List<List<Object?>> rows) {
    return rows.map((row) => row.map(_escape).join(',')).join('\n');
  }

  String _escape(Object? value) {
    final raw = value?.toString() ?? '';
    final mustQuote =
        raw.contains(',') || raw.contains('"') || raw.contains('\n');
    final escaped = raw.replaceAll('"', '""');

    return mustQuote ? '"$escaped"' : escaped;
  }
}
