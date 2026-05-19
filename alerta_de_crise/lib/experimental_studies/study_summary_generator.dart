import 'experimental_study_models.dart';

class StudySummaryGenerator {
  const StudySummaryGenerator();

  List<String> generateLongitudinalSummary(
    ExperimentalStudy study,
    StudyMetrics metrics,
  ) {
    return [
      'estudo experimental ${study.title} com benchmark longitudinal estruturado.',
      'coorte experimental com ${study.totalParticipants} participantes previstos e ${study.totalSessions} sessões.',
      'coleta experimental com recovery ${metrics.recoveryEfficiency.toStringAsFixed(0)} e multimodal ${metrics.multimodalAgreement.toStringAsFixed(0)}.',
      'não representa estudo clínico.',
    ];
  }

  List<String> generateRecoverySummary(StudyMetrics metrics) {
    return [
      'resumo de sessão experimental com eficiência de recuperação ${metrics.recoveryEfficiency.toStringAsFixed(0)}.',
      'tendência de resiliência experimental ${metrics.resilienceTrend.toStringAsFixed(0)}.',
    ];
  }

  List<String> generateForecastSummary(StudyMetrics metrics) {
    return [
      'forecast summary experimental com falsa escalada ${metrics.falseEscalationRate.toStringAsFixed(0)}.',
    ];
  }

  List<String> generateContextualSummary(ExperimentalStudy study) {
    return ['contextos do estudo experimental: ${study.studyTags.join(', ')}.'];
  }

  List<String> generateBenchmarkSummary(StudyMetrics metrics) {
    return [
      'benchmark longitudinal com consistência ${metrics.benchmarkConsistency.toStringAsFixed(0)}.',
      'não representa estudo clínico.',
    ];
  }
}
