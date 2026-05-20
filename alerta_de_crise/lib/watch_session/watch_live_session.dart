import 'watch_session_models.dart';
import 'watch_session_state.dart';

class WatchLiveSession {
  static const Object _unset = Object();

  final String id;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final WatchSessionState state;
  final int sampleCount;
  final String source;
  final double? lastHeartRate;
  final double? lastHrv;

  const WatchLiveSession({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.state,
    required this.sampleCount,
    required this.source,
    this.lastHeartRate,
    this.lastHrv,
  });

  factory WatchLiveSession.idle({
    String id = 'watch-session-idle',
    String source = 'appleWatch',
  }) {
    return WatchLiveSession(
      id: id,
      startedAt: null,
      endedAt: null,
      state: WatchSessionState.idle,
      sampleCount: 0,
      source: source,
    );
  }

  WatchLiveSession start({DateTime? at}) {
    final started = at ?? DateTime.now();
    return copyWith(
      startedAt: startedAt ?? started,
      clearEndedAt: true,
      state: WatchSessionState.running,
    );
  }

  WatchLiveSession pause() {
    if (state != WatchSessionState.running) {
      return this;
    }

    return copyWith(state: WatchSessionState.paused);
  }

  WatchLiveSession resume() {
    if (state != WatchSessionState.paused) {
      return this;
    }

    return copyWith(state: WatchSessionState.running);
  }

  WatchLiveSession complete({DateTime? at}) {
    return copyWith(
      endedAt: at ?? DateTime.now(),
      state: WatchSessionState.completed,
    );
  }

  WatchLiveSession fail({DateTime? at}) {
    return copyWith(
      endedAt: at ?? DateTime.now(),
      state: WatchSessionState.failed,
    );
  }

  WatchLiveSession recordSample(WatchSessionSample sample) {
    if (state != WatchSessionState.running) {
      return this;
    }

    return copyWith(
      sampleCount: sampleCount + 1,
      lastHeartRate: sample.heartRateBpm,
      lastHrv: sample.hrvRmssdMs,
      source: sample.source,
    );
  }

  Duration duration({DateTime? at}) {
    final started = startedAt;
    if (started == null) {
      return Duration.zero;
    }

    final end = endedAt ?? at ?? DateTime.now();
    if (end.isBefore(started)) {
      return Duration.zero;
    }

    return end.difference(started);
  }

  WatchLiveSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    bool clearEndedAt = false,
    WatchSessionState? state,
    int? sampleCount,
    String? source,
    Object? lastHeartRate = _unset,
    Object? lastHrv = _unset,
  }) {
    return WatchLiveSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
      state: state ?? this.state,
      sampleCount: sampleCount ?? this.sampleCount,
      source: source ?? this.source,
      lastHeartRate: identical(lastHeartRate, _unset)
          ? this.lastHeartRate
          : lastHeartRate as double?,
      lastHrv: identical(lastHrv, _unset) ? this.lastHrv : lastHrv as double?,
    );
  }
}
