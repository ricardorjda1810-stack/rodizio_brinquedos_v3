import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../longitudinal_analysis/longitudinal_analysis_models.dart';
import 'experimental_insight_models.dart';

class LongitudinalSummaryService {
  final DateTime Function() _now;

  const LongitudinalSummaryService({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  ExperimentalInsightSummary generateWeeklySummary({
    required List<ExperimentalPhysiologicalInsight> insights,
  }) {
    return ExperimentalInsightSummary(
      title: 'Resumo semanal experimental',
      summary:
          'Resumo baseado em padrões observados na semana, com interpretação experimental e sem valor diagnóstico.',
      generatedAt: _now(),
      confidence: _averageConfidence(insights),
      insights: insights,
    );
  }

  ExperimentalInsightSummary generateLongitudinalSummary({
    required List<ExperimentalPhysiologicalInsight> insights,
    List<CohortAnalysisResult> cohortAnalyses = const [],
  }) {
    final comparedSessions = cohortAnalyses.fold<int>(
      0,
      (total, cohort) => total + cohort.comparedSessions,
    );
    return ExperimentalInsightSummary(
      title: 'Resumo longitudinal experimental',
      summary:
          'Tendência fisiológica e mudanças contextuais foram resumidas em $comparedSessions sessões comparadas. Não representa diagnóstico.',
      generatedAt: _now(),
      confidence: _averageConfidence(insights),
      insights: insights,
    );
  }

  ExperimentalInsightSummary summarizeRecoveryPatterns({
    required List<AutonomicRecoveryProfile> recoveryProfiles,
    required List<ExperimentalPhysiologicalInsight> insights,
  }) {
    final averageFatigue = recoveryProfiles.isEmpty
        ? 0
        : recoveryProfiles
                  .map((profile) => profile.fatigueScore)
                  .reduce((a, b) => a + b) /
              recoveryProfiles.length;
    return ExperimentalInsightSummary(
      title: 'Resumo experimental de recuperação',
      summary:
          'Padrões de recuperação mostram fadiga média ${averageFatigue.toStringAsFixed(0)} nos dados informados; interpretação experimental baseada em padrões observados.',
      generatedAt: _now(),
      confidence: _averageConfidence(insights),
      insights: insights,
    );
  }

  double _averageConfidence(List<ExperimentalPhysiologicalInsight> insights) {
    if (insights.isEmpty) return 0;
    return insights
            .map((insight) => insight.confidence)
            .reduce((a, b) => a + b) /
        insights.length;
  }
}
