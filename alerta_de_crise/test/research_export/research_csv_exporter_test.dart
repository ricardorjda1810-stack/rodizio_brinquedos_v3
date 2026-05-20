import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_result.dart';
import 'package:signalflow/data/crisis_detection/crisis_risk_event.dart';
import 'package:signalflow/data/crisis_detection/intervention_history_entry.dart';
import 'package:signalflow/replay/csv_replay_session.dart';
import 'package:signalflow/replay/csv_replay_statistics.dart';
import 'package:signalflow/research_export/research_csv_exporter.dart';

void main() {
  group('ResearchCsvExporter', () {
    test('exports valid crisis event CSV with correct headers', () {
      const exporter = ResearchCsvExporter();

      final csv = exporter.exportCrisisEvents(_events());

      expect(
        csv.split('\n').first,
        'id,timestamp,score,level,reasonCodes,recommendedAction,cognitiveResponse,source',
      );
      expect(csv, contains('risk-1'));
      expect(csv, contains('mildAttention'));
    });

    test('escapes commas and quotes', () {
      const exporter = ResearchCsvExporter();
      final event = CrisisRiskEvent(
        id: 'risk-quote',
        timestamp: DateTime(2026, 5, 16, 10),
        score: 10,
        level: CrisisRiskLevel.normal,
        reasonCodes: const ['ok'],
        recommendedAction: 'Observar, sem "alarme".',
        cognitiveResponse: CognitiveCheckResponse.notAsked,
        source: 'debug',
      );

      final csv = exporter.exportCrisisEvents([event]);

      expect(csv, contains('"Observar, sem ""alarme""."'));
    });

    test('exports intervention and replay session CSV', () {
      const exporter = ResearchCsvExporter();

      final interventionCsv = exporter.exportInterventionHistory(
        _interventions(),
      );
      final replayCsv = exporter.exportReplaySessions(_replaySessions());

      expect(interventionCsv.split('\n').first, contains('scoreDelta'));
      expect(interventionCsv, contains('-20'));
      expect(replayCsv.split('\n').first, contains('averageHeartRate'));
      expect(replayCsv, contains('replay-1'));
    });
  });
}

List<CrisisRiskEvent> _events() {
  return [
    CrisisRiskEvent(
      id: 'risk-1',
      timestamp: DateTime(2026, 5, 16, 10),
      score: 40,
      level: CrisisRiskLevel.mildAttention,
      reasonCodes: const ['heart_rate_above_baseline_without_movement'],
      recommendedAction: 'Observar por mais alguns instantes.',
      cognitiveResponse: CognitiveCheckResponse.notAsked,
      source: 'debug',
    ),
  ];
}

List<InterventionHistoryEntry> _interventions() {
  return [
    InterventionHistoryEntry(
      id: 'intervention-1',
      protocolId: 'standard',
      startedAt: DateTime(2026, 5, 16, 10),
      completedAt: DateTime(2026, 5, 16, 10, 5),
      durationSeconds: 300,
      completed: true,
      userReportedImprovement: true,
      finalResponse: CognitiveCheckResponse.feelingOk,
      preInterventionScore: 60,
      postInterventionScore: 40,
      scoreDelta: -20,
    ),
  ];
}

List<CsvReplaySession> _replaySessions() {
  return [
    CsvReplaySession(
      id: 'replay-1',
      createdAt: DateTime(2026, 5, 16, 11),
      totalSamples: 2,
      processedSamples: 2,
      startedAt: DateTime(2026, 5, 16, 10),
      completedAt: DateTime(2026, 5, 16, 10, 1),
      averageScore: 30,
      highestScore: 50,
      highInterventionCount: 0,
      statistics: const CsvReplayStatistics(
        averageScore: 30,
        highestScore: 50,
        mildAttentionCount: 1,
        moderateAlertCount: 1,
        highInterventionCount: 0,
        averageHeartRate: 85,
        averageHrv: 36,
      ),
    ),
  ];
}
