import 'watch_live_session.dart';
import 'watch_session_models.dart';
import 'watch_session_state.dart';

typedef WatchSessionClock = DateTime Function();

class WatchSessionManager {
  final WatchSessionClock _clock;
  WatchLiveSession _currentSession;

  WatchSessionManager({
    WatchSessionClock? clock,
    WatchLiveSession? initialSession,
  }) : _clock = clock ?? DateTime.now,
       _currentSession = initialSession ?? WatchLiveSession.idle();

  WatchLiveSession get currentSession => _currentSession;

  WatchLiveSession startSession({String source = 'appleWatch'}) {
    final now = _clock();
    _currentSession = WatchLiveSession(
      id: 'watch-session-${now.microsecondsSinceEpoch}',
      startedAt: now,
      endedAt: null,
      state: WatchSessionState.running,
      sampleCount: 0,
      source: source,
    );
    return _currentSession;
  }

  WatchLiveSession pauseSession() {
    _currentSession = _currentSession.pause();
    return _currentSession;
  }

  WatchLiveSession resumeSession() {
    _currentSession = _currentSession.resume();
    return _currentSession;
  }

  WatchLiveSession completeSession() {
    _currentSession = _currentSession.complete(at: _clock());
    return _currentSession;
  }

  WatchLiveSession failSession() {
    _currentSession = _currentSession.fail(at: _clock());
    return _currentSession;
  }

  WatchLiveSession ingestWatchSample(WatchSessionSample sample) {
    _currentSession = _currentSession.recordSample(sample);
    return _currentSession;
  }
}
