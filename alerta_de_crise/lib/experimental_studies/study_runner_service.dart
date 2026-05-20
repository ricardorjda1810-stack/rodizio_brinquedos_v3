import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/signalflow_database.dart';
import 'experimental_study_models.dart';
import 'study_metrics_service.dart';
import 'study_session_manager.dart';
import 'study_summary_generator.dart';

class StudyRunnerService {
  final SignalFlowDatabase _database;
  final StudySessionManager _sessionManager;
  final StudyMetricsService _metricsService;
  final StudySummaryGenerator _summaryGenerator;
  final DateTime Function() _now;

  StudyRunnerService({
    SignalFlowDatabase? database,
    StudySessionManager? sessionManager,
    StudyMetricsService metricsService = const StudyMetricsService(),
    StudySummaryGenerator summaryGenerator = const StudySummaryGenerator(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _sessionManager = sessionManager ?? StudySessionManager(now: now),
       _metricsService = metricsService,
       _summaryGenerator = summaryGenerator,
       _now = now ?? DateTime.now;

  Future<ExperimentalStudy> startStudy({
    required String title,
    required String description,
    required String protocolId,
    int totalSessions = 0,
    int totalParticipants = 1,
    Duration targetDuration = const Duration(days: 7),
    List<String> studyTags = const ['benchmark longitudinal'],
    List<String> enabledSensors = const ['Polar H10', 'Apple Health'],
    bool persist = false,
  }) async {
    final createdAt = _now();
    final study = ExperimentalStudy(
      id: 'study-${createdAt.microsecondsSinceEpoch}',
      title: title,
      description: description,
      createdAt: createdAt,
      protocolId: protocolId,
      totalSessions: totalSessions,
      totalParticipants: totalParticipants,
      targetDuration: targetDuration,
      studyTags: List.unmodifiable(studyTags),
      enabledSensors: List.unmodifiable(enabledSensors),
      active: true,
    );
    if (persist) {
      await persistStudy(study);
    }
    return study;
  }

  Future<ExperimentalStudySession> startStudySession({
    required ExperimentalStudy study,
    required String sessionId,
    bool persist = false,
  }) async {
    final session = _sessionManager.createActiveSession(
      studyId: study.id,
      sessionId: sessionId,
    );
    if (persist) {
      await persistSession(session);
    }
    return session;
  }

  Future<ExperimentalStudySession> completeStudySession({
    required String sessionRecordId,
    bool replayGenerated = true,
    bool benchmarkGenerated = true,
    bool subjectiveFeedbackIncluded = true,
    double multimodalConsensusScore = 80,
    bool persist = false,
  }) async {
    final session = _sessionManager.completeActiveSession(
      sessionRecordId: sessionRecordId,
      replayGenerated: replayGenerated,
      benchmarkGenerated: benchmarkGenerated,
      subjectiveFeedbackIncluded: subjectiveFeedbackIncluded,
      multimodalConsensusScore: multimodalConsensusScore,
    );
    if (persist) {
      await persistSession(session);
    }
    return session;
  }

  Future<StudySnapshot> finalizeStudy({
    required ExperimentalStudy study,
    required List<ExperimentalStudySession> sessions,
    List<double> recoveryScores = const [],
    List<double> falseEscalationRates = const [],
    List<double> sensorReliabilityScores = const [],
  }) async {
    final finalizedStudy = study.copyWith(
      active: false,
      totalSessions: sessions.length,
    );
    final metrics = _metricsService.calculateStudyMetrics(
      sessions: sessions,
      recoveryScores: recoveryScores,
      falseEscalationRates: falseEscalationRates,
      sensorReliabilityScores: sensorReliabilityScores,
    );
    final summary = [
      ..._summaryGenerator.generateLongitudinalSummary(finalizedStudy, metrics),
      ..._summaryGenerator.generateBenchmarkSummary(metrics),
    ];
    await persistStudy(finalizedStudy);
    return StudySnapshot(
      study: finalizedStudy,
      sessions: List.unmodifiable(sessions),
      metrics: metrics,
      summary: List.unmodifiable(summary),
    );
  }

  Future<StudySnapshot> generateStudySnapshot({
    required ExperimentalStudy study,
    required List<ExperimentalStudySession> sessions,
  }) async {
    final metrics = _metricsService.calculateStudyMetrics(sessions: sessions);
    return StudySnapshot(
      study: study,
      sessions: List.unmodifiable(sessions),
      metrics: metrics,
      summary: _summaryGenerator.generateLongitudinalSummary(study, metrics),
    );
  }

  Future<void> persistStudy(ExperimentalStudy study) async {
    await _database
        .into(_database.experimentalStudiesTable)
        .insertOnConflictUpdate(
          ExperimentalStudiesTableCompanion.insert(
            id: study.id,
            title: study.title,
            description: study.description,
            createdAt: study.createdAt,
            protocolId: study.protocolId,
            totalSessions: study.totalSessions,
            totalParticipants: study.totalParticipants,
            targetDurationSeconds: study.targetDuration.inSeconds,
            studyTagsJson: jsonEncode(study.studyTags),
            enabledSensorsJson: jsonEncode(study.enabledSensors),
            active: study.active,
            safetyCopy: study.safetyCopy,
          ),
        );
  }

  Future<void> persistSession(ExperimentalStudySession session) async {
    await _database
        .into(_database.experimentalStudySessionsTable)
        .insertOnConflictUpdate(
          ExperimentalStudySessionsTableCompanion.insert(
            id: session.id,
            studyId: session.studyId,
            sessionId: session.sessionId,
            startedAt: session.startedAt,
            completedAt: Value(session.completedAt),
            success: session.success,
            replayGenerated: session.replayGenerated,
            benchmarkGenerated: session.benchmarkGenerated,
            subjectiveFeedbackIncluded: session.subjectiveFeedbackIncluded,
            multimodalConsensusScore: session.multimodalConsensusScore,
            safetyCopy: session.safetyCopy,
          ),
        );
  }

  Future<List<ExperimentalStudy>> loadStudies() async {
    final rows = await _database
        .select(_database.experimentalStudiesTable)
        .get();
    return rows.map(_studyFromRow).toList(growable: false);
  }

  ExperimentalStudy _studyFromRow(ExperimentalStudiesTableData row) {
    return ExperimentalStudy(
      id: row.id,
      title: row.title,
      description: row.description,
      createdAt: row.createdAt,
      protocolId: row.protocolId,
      totalSessions: row.totalSessions,
      totalParticipants: row.totalParticipants,
      targetDuration: Duration(seconds: row.targetDurationSeconds),
      studyTags: (jsonDecode(row.studyTagsJson) as List).cast<String>(),
      enabledSensors: (jsonDecode(row.enabledSensorsJson) as List)
          .cast<String>(),
      active: row.active,
    );
  }
}
