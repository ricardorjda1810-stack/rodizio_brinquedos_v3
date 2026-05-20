import '../core/crisis_detection/physiological_sample.dart';
import 'physiological_event_marker.dart';

class SessionTimelineStatistics {
  final int durationSeconds;
  final double? averageSecondsBetweenEvents;
  final double? maxHeartRate;
  final double? minHrv;
  final int totalInterventions;
  final int totalLowConfidence;
  final int totalArtifacts;
  final double activationDensity;

  const SessionTimelineStatistics({
    required this.durationSeconds,
    required this.averageSecondsBetweenEvents,
    required this.maxHeartRate,
    required this.minHrv,
    required this.totalInterventions,
    required this.totalLowConfidence,
    required this.totalArtifacts,
    required this.activationDensity,
  });

  factory SessionTimelineStatistics.calculate({
    required DateTime startedAt,
    required DateTime? endedAt,
    required List<PhysiologicalSample> samples,
    required List<PhysiologicalEventMarker> markers,
  }) {
    final effectiveEnd =
        endedAt ?? _latestTimestamp(startedAt, samples, markers);
    final durationSeconds = effectiveEnd.difference(startedAt).inSeconds;
    final activationEvents = markers
        .where(
          (marker) =>
              marker.type == EventType.elevatedHeartRate ||
              marker.type == EventType.hrvDrop,
        )
        .length;

    return SessionTimelineStatistics(
      durationSeconds: durationSeconds < 0 ? 0 : durationSeconds,
      averageSecondsBetweenEvents: _averageSecondsBetweenEvents(markers),
      maxHeartRate: _maxHeartRate(samples),
      minHrv: _minHrv(samples),
      totalInterventions: markers
          .where(
            (marker) =>
                marker.type == EventType.interventionStarted ||
                marker.type == EventType.interventionCompleted,
          )
          .length,
      totalLowConfidence: markers
          .where((marker) => marker.type == EventType.lowConfidenceSignal)
          .length,
      totalArtifacts: markers
          .where((marker) => marker.type == EventType.movementArtifact)
          .length,
      activationDensity: markers.isEmpty
          ? 0
          : activationEvents / markers.length,
    );
  }

  static DateTime _latestTimestamp(
    DateTime startedAt,
    List<PhysiologicalSample> samples,
    List<PhysiologicalEventMarker> markers,
  ) {
    var latest = startedAt;
    for (final sample in samples) {
      if (sample.timestamp.isAfter(latest)) {
        latest = sample.timestamp;
      }
    }
    for (final marker in markers) {
      if (marker.timestamp.isAfter(latest)) {
        latest = marker.timestamp;
      }
    }
    return latest;
  }

  static double? _averageSecondsBetweenEvents(
    List<PhysiologicalEventMarker> markers,
  ) {
    if (markers.length < 2) {
      return null;
    }
    final ordered = [...markers]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final intervals = <int>[];
    for (var i = 1; i < ordered.length; i += 1) {
      intervals.add(
        ordered[i].timestamp.difference(ordered[i - 1].timestamp).inSeconds,
      );
    }
    return intervals.reduce((a, b) => a + b) / intervals.length;
  }

  static double? _maxHeartRate(List<PhysiologicalSample> samples) {
    if (samples.isEmpty) {
      return null;
    }
    return samples
        .map((sample) => sample.heartRateBpm)
        .reduce((a, b) => a > b ? a : b);
  }

  static double? _minHrv(List<PhysiologicalSample> samples) {
    final hrvValues = samples
        .map((sample) => sample.hrvRmssdMs)
        .whereType<double>()
        .toList();
    if (hrvValues.isEmpty) {
      return null;
    }
    return hrvValues.reduce((a, b) => a < b ? a : b);
  }
}
