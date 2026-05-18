import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../contextual_triggers/contextual_trigger_models.dart';
import '../experimental_insights/experimental_insight_models.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import 'cognitive_feedback_models.dart';
import 'cognitive_pattern_analysis.dart';
import 'perceived_state_models.dart';

class FeedbackCorrelationService {
  final CognitivePatternAnalysis _analysis;

  const FeedbackCorrelationService({
    CognitivePatternAnalysis analysis = const CognitivePatternAnalysis(),
  }) : _analysis = analysis;

  FeedbackCorrelationResult correlateFeedback({
    required PerceivedState perceivedState,
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<ContextualTriggerCorrelation> contextualCorrelations = const [],
    List<EscalationForecast> forecasts = const [],
    List<SubjectiveFeedbackEntry> history = const [],
  }) {
    final normalized = perceivedState.normalized();
    final physiologicalLoad = _analysis.physiologicalLoadScore(
      trends: trends,
      forecasts: forecasts,
    );
    final subjectiveLoad = normalized.perceivedLoad * 10.0;
    final subjectiveCorrelation =
        (100 - (physiologicalLoad - subjectiveLoad).abs()).clamp(0, 100);
    final consistency = calculatePerceptionConsistency(
      perceivedState: normalized,
      physiologicalLoad: physiologicalLoad,
    );
    final perceivedRecovery = _calculateRecovery(normalized, recoveryProfiles);
    final patterns = detectSubjectivePatterns(
      perceivedState: normalized,
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      forecasts: forecasts,
      history: history,
    );
    final contextualBoost =
        contextualCorrelations
            .where((correlation) => correlation.confidence >= 50)
            .length *
        4;
    final confidence = (45 + (history.length.clamp(0, 5) * 6) + contextualBoost)
        .clamp(0, 100);
    return FeedbackCorrelationResult(
      subjectiveCorrelation: subjectiveCorrelation.toDouble(),
      perceptionConsistency: consistency,
      perceivedRecovery: perceivedRecovery,
      confidence: confidence.toDouble(),
      hasMismatch: patterns.any(
        (pattern) => pattern.contains('inconsistência'),
      ),
      patterns: patterns,
    );
  }

  List<String> detectSubjectivePatterns({
    required PerceivedState perceivedState,
    List<SubjectiveFeedbackEntry> history = const [],
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
  }) {
    return _analysis.detectPatterns(
      perceivedState: perceivedState,
      history: history,
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      forecasts: forecasts,
    );
  }

  double calculatePerceptionConsistency({
    required PerceivedState perceivedState,
    required double physiologicalLoad,
  }) {
    final subjectiveLoad = perceivedState.normalized().perceivedLoad * 10.0;
    return (100 - (subjectiveLoad - physiologicalLoad).abs())
        .clamp(0, 100)
        .toDouble();
  }

  ExperimentalPhysiologicalInsight toExperimentalInsight({
    required FeedbackCorrelationResult result,
    required DateTime generatedAt,
  }) {
    return ExperimentalPhysiologicalInsight(
      id: 'insight-subjective-${generatedAt.microsecondsSinceEpoch}',
      generatedAt: generatedAt,
      title: result.hasMismatch
          ? 'Inconsistência percepção/fisiologia observada'
          : 'Percepção subjetiva consistente observada',
      summary:
          'Feedback experimental correlaciona percepção subjetiva e fisiologia longitudinal por autoavaliação. Não representa avaliação clínica.',
      confidence: result.confidence,
      insightType: InsightType.contextualPattern,
      contributingFactors: [
        'percepção subjetiva',
        'feedback experimental',
        'sensação percebida',
        ...result.patterns,
      ],
    );
  }

  double _calculateRecovery(
    PerceivedState perceivedState,
    List<AutonomicRecoveryProfile> recoveryProfiles,
  ) {
    final perceived = perceivedState.perceivedRecovery * 10.0;
    if (recoveryProfiles.isEmpty) return perceived.clamp(0, 100).toDouble();
    final latest = recoveryProfiles.last;
    final physiological = (latest.resilienceScore + latest.recoveryRate) / 2;
    return ((perceived * 0.65) + (physiological * 0.35))
        .clamp(0, 100)
        .toDouble();
  }
}
