import 'session_snapshot_models.dart';

enum RecordingState { idle, recording, paused, completed }

class RecordedExperimentalSession {
  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? protocolId;
  final int totalSamples;
  final int totalMarkers;
  final int totalForecasts;
  final int totalInsights;
  final int totalContextEvents;
  final int totalSubjectiveEntries;
  final double averageHeartRate;
  final double averageHrv;
  final double averageConfidence;
  final int escalationEvents;
  final int recoveryEvents;

  const RecordedExperimentalSession({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.protocolId,
    required this.totalSamples,
    required this.totalMarkers,
    required this.totalForecasts,
    required this.totalInsights,
    required this.totalContextEvents,
    required this.totalSubjectiveEntries,
    required this.averageHeartRate,
    required this.averageHrv,
    required this.averageConfidence,
    required this.escalationEvents,
    required this.recoveryEvents,
  });

  Duration get duration => (completedAt ?? startedAt).difference(startedAt);

  String get safetyCopy =>
      'registro experimental de dataset fisiológico; não representa monitoramento clínico.';

  RecordedExperimentalSession copyWith({
    DateTime? completedAt,
    int? totalSamples,
    int? totalMarkers,
    int? totalForecasts,
    int? totalInsights,
    int? totalContextEvents,
    int? totalSubjectiveEntries,
    double? averageHeartRate,
    double? averageHrv,
    double? averageConfidence,
    int? escalationEvents,
    int? recoveryEvents,
  }) {
    return RecordedExperimentalSession(
      id: id,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      protocolId: protocolId,
      totalSamples: totalSamples ?? this.totalSamples,
      totalMarkers: totalMarkers ?? this.totalMarkers,
      totalForecasts: totalForecasts ?? this.totalForecasts,
      totalInsights: totalInsights ?? this.totalInsights,
      totalContextEvents: totalContextEvents ?? this.totalContextEvents,
      totalSubjectiveEntries:
          totalSubjectiveEntries ?? this.totalSubjectiveEntries,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      averageHrv: averageHrv ?? this.averageHrv,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      escalationEvents: escalationEvents ?? this.escalationEvents,
      recoveryEvents: recoveryEvents ?? this.recoveryEvents,
    );
  }
}

class RecordingSessionState {
  final RecordedExperimentalSession session;
  final List<SessionSnapshot> snapshots;
  final RecordingState state;
  final List<String> markers;

  const RecordingSessionState({
    required this.session,
    required this.snapshots,
    required this.state,
    required this.markers,
  });

  bool get isActive =>
      state == RecordingState.recording || state == RecordingState.paused;
}
