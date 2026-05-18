import 'session_recorder_models.dart';
import 'session_snapshot_models.dart';

class SessionExportBuilder {
  const SessionExportBuilder();

  Map<String, Object?> buildSessionExport({
    required RecordedExperimentalSession session,
    required List<SessionSnapshot> snapshots,
    required List<String> markers,
  }) {
    return {
      'metadata': buildReplayMetadata(session),
      'summary': generateSessionSummary(session),
      'markers': markers,
      'snapshots': snapshots.map((snapshot) => snapshot.toJson()).toList(),
      'safetyCopy':
          'registro experimental; dataset fisiológico; não representa monitoramento clínico.',
    };
  }

  Map<String, Object?> buildReplayMetadata(
    RecordedExperimentalSession session,
  ) {
    return {
      'sessionId': session.id,
      'protocolId': session.protocolId,
      'benchmarkId': 'benchmark-${session.id}',
      'replayType': 'replay experimental',
      'startedAt': session.startedAt.toIso8601String(),
      'completedAt': session.completedAt?.toIso8601String(),
      'totalSamples': session.totalSamples,
    };
  }

  Map<String, Object> generateSessionSummary(
    RecordedExperimentalSession session,
  ) {
    return {
      'durationSeconds': session.duration.inSeconds,
      'totalSamples': session.totalSamples,
      'averageHeartRate': session.averageHeartRate,
      'averageHrv': session.averageHrv,
      'averageConfidence': session.averageConfidence,
      'escalationEvents': session.escalationEvents,
      'recoveryEvents': session.recoveryEvents,
      'description':
          'sessão experimental de coleta fisiológica para dataset reproduzível',
    };
  }
}
