enum LongitudinalEvolutionTrend { improving, worsening, stable, mixed }

class CohortAnalysisResult {
  final String id;
  final DateTime generatedAt;
  final int comparedSessions;
  final double averageRecoveryEfficiency;
  final double averageEscalationProbability;
  final double averageResilience;
  final double stabilityScore;
  final double variabilityScore;
  final double contextualConsistency;
  final double longitudinalConfidence;

  const CohortAnalysisResult({
    required this.id,
    required this.generatedAt,
    required this.comparedSessions,
    required this.averageRecoveryEfficiency,
    required this.averageEscalationProbability,
    required this.averageResilience,
    required this.stabilityScore,
    required this.variabilityScore,
    required this.contextualConsistency,
    required this.longitudinalConfidence,
  });

  String get safetyCopy =>
      'análise experimental: mudanças observadas e padrões ao longo do tempo não representam diagnóstico.';
}

class SessionComparisonResult {
  final int comparedSessions;
  final LongitudinalEvolutionTrend recoveryTrend;
  final LongitudinalEvolutionTrend resilienceTrend;
  final LongitudinalEvolutionTrend escalationTrend;
  final bool hasRecurringIncompleteRecovery;
  final double confidence;

  const SessionComparisonResult({
    required this.comparedSessions,
    required this.recoveryTrend,
    required this.resilienceTrend,
    required this.escalationTrend,
    required this.hasRecurringIncompleteRecovery,
    required this.confidence,
  });
}
