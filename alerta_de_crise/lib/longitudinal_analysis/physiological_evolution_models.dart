import 'longitudinal_analysis_models.dart';

class PhysiologicalEvolutionProfile {
  final LongitudinalEvolutionTrend baselineTrend;
  final LongitudinalEvolutionTrend recoveryTrend;
  final LongitudinalEvolutionTrend resilienceTrend;
  final LongitudinalEvolutionTrend escalationTrend;
  final LongitudinalEvolutionTrend autonomicLoadTrend;
  final LongitudinalEvolutionTrend circadianStabilityTrend;
  final DateTime generatedAt;

  const PhysiologicalEvolutionProfile({
    required this.baselineTrend,
    required this.recoveryTrend,
    required this.resilienceTrend,
    required this.escalationTrend,
    required this.autonomicLoadTrend,
    required this.circadianStabilityTrend,
    required this.generatedAt,
  });

  String get safetyCopy =>
      'tendência longitudinal experimental: mudança observada não representa diagnóstico.';
}
