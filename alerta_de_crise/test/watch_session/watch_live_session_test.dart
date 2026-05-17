import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/watch_session/watch_live_session.dart';
import 'package:signalflow/watch_session/watch_session_models.dart';
import 'package:signalflow/watch_session/watch_session_state.dart';

void main() {
  group('WatchLiveSession', () {
    test('start changes state to running', () {
      final startedAt = DateTime(2026, 5, 16, 10);
      final session = WatchLiveSession.idle().start(at: startedAt);

      expect(session.state, WatchSessionState.running);
      expect(session.startedAt, startedAt);
    });

    test('pause and resume update state', () {
      final session = WatchLiveSession.idle()
          .start(at: DateTime(2026, 5, 16, 10))
          .pause()
          .resume();

      expect(session.state, WatchSessionState.running);
    });

    test('complete sets endedAt and completed state', () {
      final endedAt = DateTime(2026, 5, 16, 10, 2);
      final session = WatchLiveSession.idle()
          .start(at: DateTime(2026, 5, 16, 10))
          .complete(at: endedAt);

      expect(session.state, WatchSessionState.completed);
      expect(session.endedAt, endedAt);
    });

    test('fail sets failed state', () {
      final session = WatchLiveSession.idle()
          .start(at: DateTime(2026, 5, 16, 10))
          .fail(at: DateTime(2026, 5, 16, 10, 1));

      expect(session.state, WatchSessionState.failed);
    });

    test('recordSample increments count and updates latest values', () {
      final session = WatchLiveSession.idle()
          .start(at: DateTime(2026, 5, 16, 10))
          .recordSample(
            WatchSessionSample(
              timestamp: DateTime(2026, 5, 16, 10, 1),
              heartRateBpm: 88,
              hrvRmssdMs: 36,
            ),
          );

      expect(session.sampleCount, 1);
      expect(session.lastHeartRate, 88);
      expect(session.lastHrv, 36);
    });

    test('duration is consistent while running and completed', () {
      final startedAt = DateTime(2026, 5, 16, 10);
      final running = WatchLiveSession.idle().start(at: startedAt);

      expect(running.duration(at: DateTime(2026, 5, 16, 10, 2)).inSeconds, 120);

      final completed = running.complete(at: DateTime(2026, 5, 16, 10, 3));

      expect(completed.duration().inSeconds, 180);
    });
  });
}
