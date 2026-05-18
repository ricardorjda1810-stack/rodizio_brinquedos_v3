import '../contextual_triggers/contextual_event.dart';
import '../core/crisis_detection/physiological_sample.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import 'replay_engine_models.dart';

class ReplayTimelineEngine {
  final List<PhysiologicalSample> samples;
  final List<PhysiologicalEventMarker> markers;
  final List<ContextualEvent> contextualEvents;
  final List<EscalationForecast> forecasts;
  int _index;

  ReplayTimelineEngine({
    required this.samples,
    this.markers = const [],
    this.contextualEvents = const [],
    this.forecasts = const [],
    int initialIndex = 0,
  }) : _index = samples.isEmpty ? 0 : initialIndex.clamp(0, samples.length - 1);

  ReplayTimelineState stepForward() {
    if (samples.isNotEmpty && _index < samples.length - 1) {
      _index += 1;
    }
    return currentState();
  }

  ReplayTimelineState stepBackward() {
    if (_index > 0) {
      _index -= 1;
    }
    return currentState();
  }

  ReplayTimelineState seekTimeline(Duration offset) {
    if (samples.isEmpty) {
      return currentState();
    }
    final start = samples.first.timestamp;
    final target = start.add(offset);
    _index = _nearestIndex(target);
    return currentState();
  }

  ReplayTimelineState currentState() {
    final sample = samples.isEmpty ? null : samples[_index];
    final timestamp = currentTimestamp();
    return ReplayTimelineState(
      timestamp: timestamp,
      sample: sample,
      markers: _markersNear(timestamp),
      contextualEvents: _eventsNear(timestamp),
      forecast: forecasts.isEmpty ? null : forecasts.last,
      progress: samples.length <= 1 ? 0 : _index / (samples.length - 1),
      index: _index,
    );
  }

  DateTime currentTimestamp() {
    if (samples.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    return samples[_index].timestamp;
  }

  int _nearestIndex(DateTime target) {
    var bestIndex = 0;
    var bestDistance = target.difference(samples.first.timestamp).abs();
    for (var i = 1; i < samples.length; i += 1) {
      final distance = target.difference(samples[i].timestamp).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  List<PhysiologicalEventMarker> _markersNear(DateTime timestamp) {
    return markers
        .where(
          (marker) =>
              marker.timestamp.difference(timestamp).abs().inSeconds <= 60,
        )
        .toList(growable: false);
  }

  List<ContextualEvent> _eventsNear(DateTime timestamp) {
    return contextualEvents
        .where(
          (event) =>
              event.timestamp.difference(timestamp).abs().inMinutes <= 10,
        )
        .toList(growable: false);
  }
}
