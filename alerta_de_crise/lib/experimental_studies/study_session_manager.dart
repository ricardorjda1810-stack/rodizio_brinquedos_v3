import 'experimental_study_models.dart';

class StudySessionManager {
  final Map<String, ExperimentalStudySession> _activeSessions = {};
  final DateTime Function() _now;

  StudySessionManager({DateTime Function()? now}) : _now = now ?? DateTime.now;

  List<ExperimentalStudySession> get activeSessions =>
      List.unmodifiable(_activeSessions.values);

  ExperimentalStudySession createActiveSession({
    required String studyId,
    required String sessionId,
  }) {
    final startedAt = _now();
    final session = ExperimentalStudySession(
      id: 'study-session-$sessionId-${startedAt.microsecondsSinceEpoch}',
      studyId: studyId,
      sessionId: sessionId,
      startedAt: startedAt,
      success: false,
      replayGenerated: false,
      benchmarkGenerated: false,
      subjectiveFeedbackIncluded: false,
      multimodalConsensusScore: 0,
    );
    _activeSessions[session.id] = session;
    return session;
  }

  ExperimentalStudySession completeActiveSession({
    required String sessionRecordId,
    bool replayGenerated = true,
    bool benchmarkGenerated = true,
    bool subjectiveFeedbackIncluded = true,
    double multimodalConsensusScore = 80,
  }) {
    final session = _activeSessions.remove(sessionRecordId);
    if (session == null) {
      throw StateError('Sessão experimental ativa não encontrada.');
    }
    return session.copyWith(
      completedAt: _now(),
      success: true,
      replayGenerated: replayGenerated,
      benchmarkGenerated: benchmarkGenerated,
      subjectiveFeedbackIncluded: subjectiveFeedbackIncluded,
      multimodalConsensusScore: multimodalConsensusScore
          .clamp(0, 100)
          .toDouble(),
    );
  }

  Map<String, bool> pipelineState(ExperimentalStudySession session) {
    return {
      'recording': true,
      'replay': session.replayGenerated,
      'benchmark': session.benchmarkGenerated,
      'forecast': true,
      'contextualEvents': session.subjectiveFeedbackIncluded,
    };
  }
}
