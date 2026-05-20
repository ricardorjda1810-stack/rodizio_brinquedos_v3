class InterventionLearningProfile {
  final String interventionType;
  final double successRate;
  final Duration averageRecoveryTime;
  final double averageRecoveryImprovement;
  final Map<String, double> contextualPerformance;
  final Map<int, double> circadianPerformance;
  final double confidence;
  final int usageCount;
  final DateTime updatedAt;

  const InterventionLearningProfile({
    required this.interventionType,
    required this.successRate,
    required this.averageRecoveryTime,
    required this.averageRecoveryImprovement,
    required this.contextualPerformance,
    required this.circadianPerformance,
    required this.confidence,
    required this.usageCount,
    required this.updatedAt,
  });

  String get safetyCopy =>
      'adaptação experimental: sugestão experimental baseada em padrões observados; não garante eficácia.';
}

class ContextualInterventionRecommendation {
  final String interventionType;
  final double recommendationScore;
  final double expectedRecoveryBenefit;
  final double confidence;
  final List<String> contextualFactors;
  final List<String> physiologicalFactors;
  final List<String> recoveryFactors;

  const ContextualInterventionRecommendation({
    required this.interventionType,
    required this.recommendationScore,
    required this.expectedRecoveryBenefit,
    required this.confidence,
    required this.contextualFactors,
    required this.physiologicalFactors,
    required this.recoveryFactors,
  });

  String get safetyCopy =>
      'sugestão experimental: não garante eficácia; baseada em intervenções observadas e padrões de recuperação.';
}

class InterventionEffectivenessResult {
  final String interventionType;
  final double effectivenessScore;
  final double successRate;
  final double recoveryBenefit;
  final double escalationReduction;
  final double recoverySpeed;
  final double contextualPerformance;
  final double confidence;

  const InterventionEffectivenessResult({
    required this.interventionType,
    required this.effectivenessScore,
    required this.successRate,
    required this.recoveryBenefit,
    required this.escalationReduction,
    required this.recoverySpeed,
    required this.contextualPerformance,
    required this.confidence,
  });
}
