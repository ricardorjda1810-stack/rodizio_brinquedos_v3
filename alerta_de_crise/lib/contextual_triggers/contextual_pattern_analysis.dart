import '../session_timeline/physiological_event_marker.dart';
import 'contextual_event.dart';
import 'contextual_trigger_models.dart';

class ContextualPatternAnalysis {
  const ContextualPatternAnalysis();

  List<ContextualPattern> detectPatterns({
    required List<ContextualEvent> events,
    required List<PhysiologicalEventMarker> markers,
    Duration associationWindow = const Duration(minutes: 45),
  }) {
    final patterns = <ContextualPattern>[];

    for (final category in ContextualCategory.values) {
      final categoryEvents = events
          .where((event) => event.category == category)
          .toList(growable: false);
      if (categoryEvents.isEmpty) {
        continue;
      }

      final associatedMarkers = markers
          .where(
            (marker) => categoryEvents.any(
              (event) => _isAssociated(
                event.timestamp,
                marker.timestamp,
                associationWindow,
              ),
            ),
          )
          .toList(growable: false);
      final commonHour = _mostCommonHour(categoryEvents);
      final combinedWith = _combinedCategories(
        category: category,
        events: events,
        categoryEvents: categoryEvents,
      );

      patterns.add(
        ContextualPattern(
          category: category,
          occurrenceCount: categoryEvents.length,
          associatedMarkerCount: associatedMarkers.length,
          commonHour: commonHour,
          associationDensity: associatedMarkers.isEmpty
              ? 0
              : (associatedMarkers.length / categoryEvents.length)
                    .clamp(0, 1)
                    .toDouble(),
          combinedWith: combinedWith,
        ),
      );
    }

    patterns.sort(
      (a, b) => b.associationDensity.compareTo(a.associationDensity),
    );
    return List.unmodifiable(patterns);
  }

  bool _isAssociated(DateTime eventTime, DateTime markerTime, Duration window) {
    final delta = markerTime.difference(eventTime);
    return !delta.isNegative && delta <= window;
  }

  int _mostCommonHour(List<ContextualEvent> events) {
    final counts = <int, int>{};
    for (final event in events) {
      counts[event.timestamp.hour] = (counts[event.timestamp.hour] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  List<ContextualCategory> _combinedCategories({
    required ContextualCategory category,
    required List<ContextualEvent> events,
    required List<ContextualEvent> categoryEvents,
  }) {
    final counts = <ContextualCategory, int>{};
    for (final event in categoryEvents) {
      for (final other in events) {
        if (other.category == category || other.id == event.id) {
          continue;
        }
        final minutes = other.timestamp
            .difference(event.timestamp)
            .inMinutes
            .abs();
        if (minutes <= 30) {
          counts[other.category] = (counts[other.category] ?? 0) + 1;
        }
      }
    }

    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(3).map((entry) => entry.key).toList(growable: false);
  }
}
