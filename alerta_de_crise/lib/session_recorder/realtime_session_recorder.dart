import 'session_recorder_models.dart';
import 'session_snapshot_models.dart';

class RealtimeSessionRecorder {
  final DateTime Function() _now;
  RecordingSessionState? _state;

  RealtimeSessionRecorder({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  RecordingSessionState? get currentState => _state;

  RecordingSessionState startRecording({String? protocolId}) {
    final startedAt = _now();
    final session = RecordedExperimentalSession(
      id: 'recording-${startedAt.microsecondsSinceEpoch}',
      startedAt: startedAt,
      completedAt: null,
      protocolId: protocolId,
      totalSamples: 0,
      totalMarkers: 1,
      totalForecasts: 0,
      totalInsights: 0,
      totalContextEvents: 0,
      totalSubjectiveEntries: 0,
      averageHeartRate: 0,
      averageHrv: 0,
      averageConfidence: 0,
      escalationEvents: 0,
      recoveryEvents: 0,
    );
    _state = RecordingSessionState(
      session: session,
      snapshots: const [],
      state: RecordingState.recording,
      markers: const ['recording_started'],
    );
    return _state!;
  }

  RecordingSessionState recordSnapshot(
    SessionSnapshot snapshot, {
    int forecasts = 0,
    int insights = 0,
    int contextEvents = 0,
    int subjectiveEntries = 0,
  }) {
    final state = _requireState();
    if (state.state != RecordingState.recording) {
      return state;
    }
    final snapshots = [...state.snapshots, snapshot];
    final session = state.session.copyWith(
      totalSamples: snapshots.length,
      totalMarkers: state.markers.length,
      totalForecasts: state.session.totalForecasts + forecasts,
      totalInsights: state.session.totalInsights + insights,
      totalContextEvents: state.session.totalContextEvents + contextEvents,
      totalSubjectiveEntries:
          state.session.totalSubjectiveEntries + subjectiveEntries,
      averageHeartRate: _average(snapshots.map((item) => item.heartRate)),
      averageHrv: _average(snapshots.map((item) => item.hrv)),
      averageConfidence: _average(snapshots.map((item) => item.confidence)),
      escalationEvents: snapshots
          .where((item) => item.escalationLevel != 'low')
          .length,
      recoveryEvents: snapshots
          .where((item) => item.recoveryState == 'recovering')
          .length,
    );
    _state = RecordingSessionState(
      session: session,
      snapshots: List.unmodifiable(snapshots),
      state: RecordingState.recording,
      markers: state.markers,
    );
    return _state!;
  }

  RecordingSessionState pauseRecording() {
    final state = _requireState();
    final markers = [...state.markers, 'recording_paused'];
    _state = RecordingSessionState(
      session: state.session.copyWith(totalMarkers: markers.length),
      snapshots: state.snapshots,
      state: RecordingState.paused,
      markers: List.unmodifiable(markers),
    );
    return _state!;
  }

  RecordingSessionState resumeRecording() {
    final state = _requireState();
    final markers = [...state.markers, 'recording_resumed'];
    _state = RecordingSessionState(
      session: state.session.copyWith(totalMarkers: markers.length),
      snapshots: state.snapshots,
      state: RecordingState.recording,
      markers: List.unmodifiable(markers),
    );
    return _state!;
  }

  RecordingSessionState stopRecording() {
    final state = _requireState();
    final markers = [...state.markers, 'recording_completed'];
    _state = RecordingSessionState(
      session: state.session.copyWith(
        completedAt: _now(),
        totalMarkers: markers.length,
      ),
      snapshots: state.snapshots,
      state: RecordingState.completed,
      markers: List.unmodifiable(markers),
    );
    return _state!;
  }

  RecordingSessionState _requireState() {
    final state = _state;
    if (state == null) {
      throw StateError('Nenhuma sessão experimental em gravação.');
    }
    return state;
  }

  double _average(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    final total = list.fold<double>(0, (sum, value) => sum + value);
    return total / list.length;
  }
}
