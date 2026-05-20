import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_result.dart';
import 'package:signalflow/data/crisis_detection/crisis_risk_event.dart';
import 'package:signalflow/data/crisis_detection/intervention_history_entry.dart';
import 'package:signalflow/replay/csv_replay_session.dart';
import 'package:signalflow/replay/csv_replay_statistics.dart';
import 'package:signalflow/research_export/research_export_models.dart';
import 'package:signalflow/research_export/research_export_service.dart';

void main() {
  group('ResearchExportService', () {
    test('generates valid bundle with full contents', () {
      final generatedAt = DateTime(2026, 5, 16, 12);
      final service = ResearchExportService(clock: () => generatedAt);

      final bundle = service.generateResearchBundle(
        crisisEvents: _events(),
        interventions: _interventions(),
        replaySessions: _replaySessions(),
      );

      expect(bundle.generatedAt, generatedAt);
      expect(bundle.totalEvents, 3);
      expect(bundle.totalInterventions, 2);
      expect(bundle.totalReplaySessions, 1);
      expect(bundle.csvContents[ResearchExportType.fullBundle], isNotEmpty);
      expect(bundle.fullCsv, contains('# crisisEvents'));
      expect(bundle.fullCsv, contains('# replaySessions'));
    });

    test('statistics are consistent', () {
      const service = ResearchExportService();

      final bundle = service.generateResearchBundle(
        crisisEvents: _events(),
        interventions: _interventions(),
        replaySessions: _replaySessions(),
      );

      expect(bundle.statistics.totalCrises, 3);
      expect(bundle.statistics.totalInterventions, 2);
      expect(bundle.statistics.totalHighIntervention, 1);
      expect(bundle.statistics.averageScore, 50);
      expect(bundle.statistics.averageImprovement, -15);
      expect(bundle.statistics.perceivedImprovementRate, 0.5);
      expect(bundle.statistics.averageInterventionDurationSeconds, 210);
    });
  });
}

List<CrisisRiskEvent> _events() {
  return [
    _event('risk-1', 20, CrisisRiskLevel.normal),
    _event('risk-2', 50, CrisisRiskLevel.moderateAlert),
    _event('risk-3', 80, CrisisRiskLevel.highIntervention),
  ];
}

CrisisRiskEvent _event(String id, int score, CrisisRiskLevel level) {
  return CrisisRiskEvent(
    id: id,
    timestamp: DateTime(2026, 5, 16, 10),
    score: score,
    level: level,
    reasonCodes: const ['debug'],
    recommendedAction: 'Observar por mais alguns instantes.',
    cognitiveResponse: CognitiveCheckResponse.notAsked,
    source: 'debug',
  );
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
      preInterventionScore: 80,
      postInterventionScore: 50,
      scoreDelta: -30,
    ),
    InterventionHistoryEntry(
      id: 'intervention-2',
      protocolId: 'standard',
      startedAt: DateTime(2026, 5, 16, 11),
      completedAt: DateTime(2026, 5, 16, 11, 2),
      durationSeconds: 120,
      completed: true,
      userReportedImprovement: false,
      finalResponse: CognitiveCheckResponse.feelingActivated,
      preInterventionScore: 50,
      postInterventionScore: 50,
      scoreDelta: 0,
    ),
  ];
}

List<CsvReplaySession> _replaySessions() {
  return [
    CsvReplaySession(
      id: 'replay-1',
      createdAt: DateTime(2026, 5, 16, 12),
      totalSamples: 3,
      processedSamples: 3,
      startedAt: DateTime(2026, 5, 16, 10),
      completedAt: DateTime(2026, 5, 16, 10, 1),
      averageScore: 40,
      highestScore: 70,
      highInterventionCount: 1,
      statistics: const CsvReplayStatistics(
        averageScore: 40,
        highestScore: 70,
        mildAttentionCount: 1,
        moderateAlertCount: 1,
        highInterventionCount: 1,
        averageHeartRate: 90,
        averageHrv: 32,
      ),
    ),
  ];
}
