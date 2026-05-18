enum EventType {
  elevatedHeartRate,
  hrvDrop,
  interventionStarted,
  interventionCompleted,
  movementArtifact,
  lowConfidenceSignal,
  manualMarker,
  circadianTransition,
  escalatingPhysiology,
  sustainedHeartRateElevation,
  prolongedHrvSuppression,
  incompleteRecovery,
  prolongedActivation,
  autonomicFatigue,
  resilienceDegradation,
  forecastElevatedRisk,
  prolongedAutonomicLoad,
  recoveryProtectiveEffect,
  repeatedContextTrigger,
  contextualEscalationPattern,
  recoveryContextAssociation,
  interventionEffective,
  interventionLowEffect,
  contextualRecommendationGenerated,
  persistentImprovement,
  persistentDeterioration,
  autonomicInstabilityPattern,
  longitudinalRecoveryPattern,
  recurringEscalationPattern,
  recoveryImprovementPattern,
  contextualBehavioralPattern,
  resilienceShift,
}

enum Severity { low, medium, high }

class PhysiologicalEventMarker {
  final String id;
  final DateTime timestamp;
  final EventType type;
  final String title;
  final String description;
  final Severity severity;
  final String source;

  const PhysiologicalEventMarker({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.source,
  });
}
