import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/session_recorder/realtime_session_recorder.dart';
import 'package:signalflow/session_recorder/session_recorder_models.dart';
import 'package:signalflow/session_recorder/session_snapshot_models.dart';

void main() {
  group('RealtimeSessionRecorder', () {
    late RealtimeSessionRecorder recorder;

    setUp(() {
      recorder = RealtimeSessionRecorder(
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    test('starts recording', () {
      final state = recorder.startRecording(protocolId: 'protocol-1');

      expect(state.state, RecordingState.recording);
      expect(state.session.protocolId, 'protocol-1');
      expect(state.markers, contains('recording_started'));
    });

    test('pause and resume recording', () {
      recorder.startRecording();

      final paused = recorder.pauseRecording();
      final resumed = recorder.resumeRecording();

      expect(paused.state, RecordingState.paused);
      expect(paused.markers, contains('recording_paused'));
      expect(resumed.state, RecordingState.recording);
      expect(resumed.markers, contains('recording_resumed'));
    });

    test('records snapshot and updates averages', () {
      recorder.startRecording();

      final state = recorder.recordSnapshot(_snapshot(heartRate: 80, hrv: 40));
      final updated = recorder.recordSnapshot(
        _snapshot(heartRate: 90, hrv: 30),
      );

      expect(state.snapshots, hasLength(1));
      expect(updated.snapshots, hasLength(2));
      expect(updated.session.averageHeartRate, 85);
      expect(updated.session.averageHrv, 35);
      expect(updated.session.averageConfidence, 80);
    });

    test('finalizes recording', () {
      recorder.startRecording();
      recorder.recordSnapshot(_snapshot());

      final completed = recorder.stopRecording();

      expect(completed.state, RecordingState.completed);
      expect(completed.session.completedAt, isNotNull);
      expect(completed.markers, contains('recording_completed'));
    });
  });
}

SessionSnapshot _snapshot({double heartRate = 80, double hrv = 40}) {
  return SessionSnapshot(
    timestamp: DateTime.utc(2026, 5, 18, 12),
    heartRate: heartRate,
    hrv: hrv,
    confidence: 80,
    escalationLevel: 'low',
    forecastProbability: 20,
    recoveryState: 'recovering',
    resilience: 70,
    contextualState: 'contexto experimental',
    multimodalConsensus: 'consenso fisiológico',
  );
}
