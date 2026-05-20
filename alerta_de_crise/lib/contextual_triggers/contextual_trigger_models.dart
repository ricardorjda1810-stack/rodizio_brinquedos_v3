import '../session_timeline/physiological_event_marker.dart';
import 'contextual_event.dart';

class ContextualTriggerCorrelation {
  final ContextualCategory category;
  final int occurrenceCount;
  final double escalationCorrelation;
  final double recoveryImpact;
  final double confidence;
  final DateTime? lastOccurrence;
  final List<PhysiologicalEventMarker> associatedMarkers;

  const ContextualTriggerCorrelation({
    required this.category,
    required this.occurrenceCount,
    required this.escalationCorrelation,
    required this.recoveryImpact,
    required this.confidence,
    required this.lastOccurrence,
    required this.associatedMarkers,
  });

  String get safetyCopy =>
      'análise experimental: correlação não implica causalidade; gatilhos potenciais representam padrões observados.';
}

class ContextualInsight {
  final String title;
  final String description;
  final double confidence;

  const ContextualInsight({
    required this.title,
    required this.description,
    required this.confidence,
  });
}

class ContextualPattern {
  final ContextualCategory category;
  final int occurrenceCount;
  final int associatedMarkerCount;
  final int commonHour;
  final double associationDensity;
  final List<ContextualCategory> combinedWith;

  const ContextualPattern({
    required this.category,
    required this.occurrenceCount,
    required this.associatedMarkerCount,
    required this.commonHour,
    required this.associationDensity,
    required this.combinedWith,
  });
}
