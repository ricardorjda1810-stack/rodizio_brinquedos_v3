import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/experimental_studies/experimental_study_models.dart';
import 'package:signalflow/experimental_studies/study_metrics_service.dart';
import 'package:signalflow/experimental_studies/study_summary_generator.dart';

void main() {
  group('StudyMetricsService', () {
    const service = StudyMetricsService();

    test('calculates study metrics and benchmark consistency', () {
      final startedAt = DateTime(2026, 1, 1, 9);
      final sessions = [
        ExperimentalStudySession(
          id: 'record-1',
          studyId: 'study-1',
          sessionId: 'session-1',
          startedAt: startedAt,
          completedAt: startedAt.add(const Duration(minutes: 15)),
          success: true,
          replayGenerated: true,
          benchmarkGenerated: true,
          subjectiveFeedbackIncluded: true,
          multimodalConsensusScore: 82,
        ),
        ExperimentalStudySession(
          id: 'record-2',
          studyId: 'study-1',
          sessionId: 'session-2',
          startedAt: startedAt.add(const Duration(days: 1)),
          completedAt: startedAt.add(const Duration(days: 1, minutes: 12)),
          success: false,
          replayGenerated: true,
          benchmarkGenerated: false,
          subjectiveFeedbackIncluded: false,
          multimodalConsensusScore: 70,
        ),
      ];

      final metrics = service.calculateStudyMetrics(
        sessions: sessions,
        recoveryScores: [70, 80],
        falseEscalationRates: [8, 4],
        sensorReliabilityScores: [90, 86],
      );

      expect(metrics.recoveryEfficiency, 75);
      expect(metrics.falseEscalationRate, 6);
      expect(metrics.multimodalAgreement, 76);
      expect(metrics.resilienceTrend, 60);
      expect(metrics.protocolCompletionRate, 50);
      expect(metrics.sensorReliability, 88);
      expect(metrics.benchmarkConsistency, 75);
    });

    test('calculates longitudinal metrics with bounded trend', () {
      expect(service.calculateLongitudinalMetrics([60, 75]), 65);
      expect(service.calculateLongitudinalMetrics([80, 20]), 0);
      expect(service.calculateLongitudinalMetrics([]), 0);
    });

    test('generates experimental study summaries', () {
      final study = ExperimentalStudy(
        id: 'study-1',
        title: 'Coorte Experimental',
        description: 'coleta experimental longitudinal',
        createdAt: DateTime(2026, 1, 1),
        protocolId: 'protocol-basic',
        totalSessions: 2,
        totalParticipants: 1,
        targetDuration: const Duration(days: 7),
        studyTags: const ['coorte experimental'],
        enabledSensors: const ['Polar H10'],
        active: false,
      );
      final metrics = const StudyMetrics(
        recoveryEfficiency: 75,
        falseEscalationRate: 6,
        multimodalAgreement: 76,
        resilienceTrend: 60,
        protocolCompletionRate: 50,
        sensorReliability: 88,
        benchmarkConsistency: 75,
      );

      final summaries = const StudySummaryGenerator()
          .generateLongitudinalSummary(study, metrics);

      expect(summaries.join(' '), contains('estudo experimental'));
      expect(summaries.join(' '), contains('benchmark longitudinal'));
      expect(summaries.join(' '), contains('coleta experimental'));
      expect(summaries.join(' '), contains('não representa estudo clínico'));
    });
  });
}
