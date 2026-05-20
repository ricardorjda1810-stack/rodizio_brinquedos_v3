import '../session_timeline/physiological_event_marker.dart';
import 'perceived_state_models.dart';

class SubjectiveFeedbackEntry {
  final String id;
  final DateTime generatedAt;
  final PerceivedState perceivedState;
  final List<String> contextualFactors;
  final double physiologicalCorrelation;
  final double confidence;
  final List<PhysiologicalEventMarker> relatedMarkers;

  const SubjectiveFeedbackEntry({
    required this.id,
    required this.generatedAt,
    required this.perceivedState,
    required this.contextualFactors,
    required this.physiologicalCorrelation,
    required this.confidence,
    this.relatedMarkers = const [],
  });

  String get safetyCopy =>
      'feedback subjetivo experimental: autoavaliação e sensação percebida; não representa avaliação clínica.';
}

class SubjectiveFeedbackSummary {
  final DateTime generatedAt;
  final int entryCount;
  final double averagePerceivedStress;
  final double averagePerceivedFatigue;
  final double averagePerceivedRecovery;
  final double averagePhysiologicalCorrelation;
  final List<String> patterns;

  const SubjectiveFeedbackSummary({
    required this.generatedAt,
    required this.entryCount,
    required this.averagePerceivedStress,
    required this.averagePerceivedFatigue,
    required this.averagePerceivedRecovery,
    required this.averagePhysiologicalCorrelation,
    required this.patterns,
  });

  String get safetyCopy =>
      'feedback experimental de percepção subjetiva; não representa avaliação clínica.';
}

class FeedbackCorrelationResult {
  final double subjectiveCorrelation;
  final double perceptionConsistency;
  final double perceivedRecovery;
  final double confidence;
  final bool hasMismatch;
  final List<String> patterns;

  const FeedbackCorrelationResult({
    required this.subjectiveCorrelation,
    required this.perceptionConsistency,
    required this.perceivedRecovery,
    required this.confidence,
    required this.hasMismatch,
    required this.patterns,
  });

  String get safetyCopy =>
      'correlação de feedback subjetivo experimental; não representa avaliação clínica.';
}
