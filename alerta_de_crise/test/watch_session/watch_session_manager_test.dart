import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/watch_session/watch_session_manager.dart';
import 'package:signalflow/watch_session/watch_session_models.dart';
import 'package:signalflow/watch_session/watch_session_state.dart';

void main() {
  group('WatchSessionManager', () {
    late DateTime now;
    late WatchSessionManager manager;

    setUp(() {
      now = DateTime(2026, 5, 16, 10);
      manager = WatchSessionManager(clock: () => now);
    });

    test('startSession changes state', () {
      final session = manager.startSession();

      expect(session.state, WatchSessionState.running);
      expect(session.startedAt, now);
    });

    test('pauseSession works', () {
      manager.startSession();

      final session = manager.pauseSession();

      expect(session.state, WatchSessionState.paused);
    });

    test('resumeSession works', () {
      manager.startSession();
      manager.pauseSession();

      final session = manager.resumeSession();

      expect(session.state, WatchSessionState.running);
    });

    test('completeSession works', () {
      manager.startSession();
      now = DateTime(2026, 5, 16, 10, 2);

      final session = manager.completeSession();

      expect(session.state, WatchSessionState.completed);
      expect(session.endedAt, now);
    });

    test('failSession works', () {
      manager.startSession();
      now = DateTime(2026, 5, 16, 10, 1);

      final session = manager.failSession();

      expect(session.state, WatchSessionState.failed);
      expect(session.endedAt, now);
    });

    test('ingestWatchSample increments sampleCount', () {
      manager.startSession();

      final session = manager.ingestWatchSample(
        WatchSessionSample(
          timestamp: DateTime(2026, 5, 16, 10, 1),
          heartRateBpm: 86,
          hrvRmssdMs: 35,
        ),
      );

      expect(session.sampleCount, 1);
    });

    test('latest HR and HRV update', () {
      manager.startSession();

      final session = manager.ingestWatchSample(
        WatchSessionSample(
          timestamp: DateTime(2026, 5, 16, 10, 1),
          heartRateBpm: 90,
          hrvRmssdMs: 32,
        ),
      );

      expect(session.lastHeartRate, 90);
      expect(session.lastHrv, 32);
    });

    test('duration remains consistent', () {
      manager.startSession();
      now = DateTime(2026, 5, 16, 10, 3);

      expect(manager.currentSession.duration(at: now).inSeconds, 180);

      final completed = manager.completeSession();

      expect(completed.duration().inSeconds, 180);
    });
  });
}
