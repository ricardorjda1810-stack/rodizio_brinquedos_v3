import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/cognitive_feedback/cognitive_feedback_models.dart';
import 'package:signalflow/cognitive_feedback/perceived_state_models.dart';
import 'package:signalflow/contextual_triggers/contextual_event.dart';
import 'package:signalflow/contextual_triggers/contextual_trigger_models.dart';
import 'package:signalflow/cross_modal_fusion/cross_modal_models.dart';
import 'package:signalflow/cross_modal_fusion/integrated_consensus_engine.dart';
import 'package:signalflow/cross_modal_fusion/multimodal_confidence_service.dart';
import 'package:signalflow/cross_modal_fusion/signal_weighting_service.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/predictive_forecasting/physiological_forecast_window.dart';
import 'package:signalflow/predictive_forecasting/predictive_forecast_models.dart';
import 'package:signalflow/sensor_quality/sensor_confidence_score.dart';

void main() {
  group('IntegratedConsensusEngine', () {
    late IntegratedConsensusEngine engine;

    setUp(() {
      engine = IntegratedConsensusEngine(
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    test('builds integrated consensus with contributing signals', () {
      final consensus = engine.buildConsensus(
        sensorConfidence: _sensorConfidence(),
        trends: [_trend()],
        recoveryProfiles: [_recovery()],
        contextualCorrelations: [_contextual()],
        subjectiveFeedback: [_feedback()],
        forecasts: [_forecast()],
      );

      expect(consensus.integratedStressLoad, inInclusiveRange(0, 100));
      expect(consensus.integratedRecoveryState, inInclusiveRange(0, 100));
      expect(consensus.integratedResilience, inInclusiveRange(0, 100));
      expect(consensus.contributingSignals, contains('fusão experimental'));
      expect(consensus.contributingSignals, contains('sinais combinados'));
      expect(
        consensus.safetyCopy,
        contains('não representa avaliação clínica'),
      );
    });

    test('calculates dynamic signal weighting', () {
      const service = SignalWeightingService();
      final weights = service.calculateSignalWeights(
        sensorConfidence: _sensorConfidence(),
        trends: [_trend()],
        recoveryProfiles: [_recovery()],
        contextualCorrelations: [_contextual()],
        subjectiveFeedback: [_feedback()],
        forecasts: [_forecast()],
      );
      final total = weights.toMap().values.fold<double>(
        0,
        (sum, value) => sum + value,
      );

      expect(total, closeTo(1, 0.0001));
      expect(weights.trends, greaterThan(0));
      expect(weights.subjectiveFeedback, greaterThan(0));
    });

    test('detects signal conflict and subjective divergence', () {
      const service = SignalWeightingService();
      final conflicts = service.detectSignalConflict(
        trends: [_trend(score: 85, activation: 85)],
        recoveryProfiles: [_recovery(resilience: 82, fatigue: 12)],
        subjectiveFeedback: [_feedback(stress: 1, fatigue: 1, recovery: 9)],
        forecasts: [_forecast(probability: 78, load: 82)],
      );

      expect(conflicts, contains('divergência fisiologia/percepção subjetiva'));
      expect(conflicts, contains('recovery alto com forecast elevado'));
    });

    test('classifies multimodal confidence', () {
      const service = MultimodalConfidenceService();
      final result = service.calculateMultimodalConfidence(
        sensorConfidence: _sensorConfidence(),
        trends: [_trend()],
        recoveryProfiles: [_recovery()],
        contextualCorrelations: [_contextual()],
        subjectiveFeedback: [_feedback()],
        forecasts: [_forecast()],
      );

      expect(result.score, inInclusiveRange(0, 100));
      expect(result.level, MultimodalConfidenceLevel.high);
      expect(result.factors, contains('confiança experimental'));
    });

    test('calculates integrated stress and recovery', () {
      const weights = SignalWeights(
        rrQuality: 0.15,
        hrv: 0.15,
        recovery: 0.2,
        trends: 0.2,
        context: 0.1,
        subjectiveFeedback: 0.1,
        confidenceScore: 0.1,
      );

      final stress = engine.calculateIntegratedStress(
        sensorConfidence: _sensorConfidence(),
        trends: [_trend()],
        recoveryProfiles: [_recovery()],
        contextualCorrelations: [_contextual()],
        subjectiveFeedback: [_feedback()],
        forecasts: [_forecast()],
        weights: weights,
      );
      final recovery = engine.calculateIntegratedRecovery(
        recoveryProfiles: [_recovery()],
        subjectiveFeedback: [_feedback(recovery: 7)],
        forecasts: [_forecast(protection: 45)],
        weights: weights,
      );

      expect(stress, greaterThan(40));
      expect(recovery, inInclusiveRange(0, 100));
    });
  });
}

SensorConfidenceScore _sensorConfidence() {
  return const SensorConfidenceScore(
    overallScore: 86,
    rrQuality: 88,
    hrQuality: 84,
    movementConfidence: 82,
    contactConfidence: 86,
    hasArtifacts: false,
    warnings: [],
  );
}

PhysiologicalTrend _trend({int score = 70, double activation = 66}) {
  return PhysiologicalTrend(
    averageHeartRate: 92,
    averageHrv: 28,
    hrvSlope: -4,
    heartRateSlope: 7,
    activationDensity: activation,
    escalationScore: score,
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    window: TrendWindow.shortTerm,
  );
}

AutonomicRecoveryProfile _recovery({int resilience = 48, int fatigue = 66}) {
  return AutonomicRecoveryProfile(
    recoveryRate: 42,
    hrvRecoverySlope: 1,
    heartRateNormalization: 44,
    baselineReturnTime: const Duration(minutes: 30),
    resilienceScore: resilience,
    fatigueScore: fatigue,
    stressCarryover: 60,
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    resilienceLevel: AutonomicResilienceLevel.fatigued,
  );
}

ContextualTriggerCorrelation _contextual() {
  return ContextualTriggerCorrelation(
    category: ContextualCategory.work,
    occurrenceCount: 3,
    escalationCorrelation: 62,
    recoveryImpact: 38,
    confidence: 64,
    lastOccurrence: DateTime.utc(2026, 5, 18, 10),
    associatedMarkers: const [],
  );
}

SubjectiveFeedbackEntry _feedback({
  int stress = 7,
  int fatigue = 7,
  int recovery = 3,
}) {
  return SubjectiveFeedbackEntry(
    id: 'feedback-test',
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    perceivedState: PerceivedState(
      timestamp: DateTime.utc(2026, 5, 18, 11),
      perceivedStress: stress,
      perceivedFatigue: fatigue,
      perceivedControl: 4,
      perceivedRecovery: recovery,
      emotionalIntensity: stress,
      notes: 'autoavaliação',
    ),
    contextualFactors: const ['contexto'],
    physiologicalCorrelation: 68,
    confidence: 66,
  );
}

EscalationForecast _forecast({
  double probability = 68,
  double load = 70,
  double protection = 34,
}) {
  return EscalationForecast(
    id: 'forecast-test',
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    forecastWindow: PhysiologicalForecastWindow.nearFuture,
    escalationProbability: probability,
    forecastConfidence: const ForecastConfidenceResult(
      score: 68,
      level: ForecastConfidenceLevel.mediumConfidence,
      factors: ['integração multimodal'],
    ),
    escalationRiskLevel: ForecastRiskLevel.elevated,
    contributingFactors: const ['sinais combinados'],
    recoveryProtection: protection,
    autonomicLoad: load,
  );
}
