import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/cognitive_feedback/cognitive_feedback_models.dart';
import 'package:signalflow/cognitive_feedback/feedback_correlation_service.dart';
import 'package:signalflow/cognitive_feedback/perceived_state_models.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/predictive_forecasting/physiological_forecast_window.dart';
import 'package:signalflow/predictive_forecasting/predictive_forecast_models.dart';

void main() {
  group('FeedbackCorrelationService', () {
    const service = FeedbackCorrelationService();

    test('calculates subjective correlation and confidence', () {
      final result = service.correlateFeedback(
        perceivedState: _state(stress: 7, fatigue: 7, recovery: 3),
        trends: [_trend(score: 68, activation: 66)],
        recoveryProfiles: [_recovery(resilience: 48, fatigue: 66)],
        forecasts: [_forecast(load: 72)],
      );

      expect(result.subjectiveCorrelation, inInclusiveRange(0, 100));
      expect(result.confidence, inInclusiveRange(0, 100));
      expect(result.safetyCopy, contains('não representa avaliação clínica'));
    });

    test('detects subjective physiology mismatch', () {
      final result = service.correlateFeedback(
        perceivedState: _state(
          stress: 1,
          fatigue: 1,
          recovery: 9,
          emotionalIntensity: 1,
        ),
        trends: [_trend(score: 86, activation: 82)],
        forecasts: [_forecast(load: 88)],
      );

      expect(result.hasMismatch, isTrue);
      expect(result.patterns, contains('inconsistência percepção/fisiologia'));
    });

    test('calculates consistent perception for aligned load', () {
      final consistency = service.calculatePerceptionConsistency(
        perceivedState: _state(stress: 8, fatigue: 8, emotionalIntensity: 8),
        physiologicalLoad: 80,
      );

      expect(consistency, greaterThanOrEqualTo(95));
    });

    test('detects recurring subjective fatigue pattern', () {
      final history = [_entry('a', fatigue: 8), _entry('b', fatigue: 7)];

      final patterns = service.detectSubjectivePatterns(
        perceivedState: _state(fatigue: 8),
        history: history,
      );

      expect(patterns, contains('fadiga subjetiva recorrente'));
    });

    test('perceived recovery blends subjective and physiological recovery', () {
      final result = service.correlateFeedback(
        perceivedState: _state(stress: 2, fatigue: 2, control: 8, recovery: 8),
        recoveryProfiles: [_recovery(resilience: 80, fatigue: 15)],
      );

      expect(result.perceivedRecovery, greaterThan(70));
      expect(
        result.patterns,
        contains('recuperação percebida por autoavaliação'),
      );
    });

    test('creates experimental insight with contributing factors', () {
      final result = service.correlateFeedback(
        perceivedState: _state(stress: 1, fatigue: 1, emotionalIntensity: 1),
        trends: [_trend(score: 82, activation: 82)],
      );
      final insight = service.toExperimentalInsight(
        result: result,
        generatedAt: DateTime.utc(2026, 5, 18, 12),
      );

      expect(insight.title, contains('Inconsistência'));
      expect(insight.contributingFactors, contains('percepção subjetiva'));
      expect(insight.summary, contains('Não representa avaliação clínica'));
    });
  });
}

PerceivedState _state({
  int stress = 6,
  int fatigue = 5,
  int control = 5,
  int recovery = 5,
  int emotionalIntensity = 6,
}) {
  return PerceivedState(
    timestamp: DateTime.utc(2026, 5, 18, 11),
    perceivedStress: stress,
    perceivedFatigue: fatigue,
    perceivedControl: control,
    perceivedRecovery: recovery,
    emotionalIntensity: emotionalIntensity,
    notes: 'feedback experimental',
  );
}

SubjectiveFeedbackEntry _entry(String id, {required int fatigue}) {
  return SubjectiveFeedbackEntry(
    id: id,
    generatedAt: DateTime.utc(2026, 5, 18, 10),
    perceivedState: _state(fatigue: fatigue),
    contextualFactors: const ['autoavaliação'],
    physiologicalCorrelation: 60,
    confidence: 55,
  );
}

PhysiologicalTrend _trend({required int score, required double activation}) {
  return PhysiologicalTrend(
    averageHeartRate: 92,
    averageHrv: 28,
    hrvSlope: -4,
    heartRateSlope: 6,
    activationDensity: activation,
    escalationScore: score,
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    window: TrendWindow.shortTerm,
  );
}

AutonomicRecoveryProfile _recovery({
  required int resilience,
  required int fatigue,
}) {
  return AutonomicRecoveryProfile(
    recoveryRate: 45,
    hrvRecoverySlope: 1,
    heartRateNormalization: 45,
    baselineReturnTime: const Duration(minutes: 30),
    resilienceScore: resilience,
    fatigueScore: fatigue,
    stressCarryover: 55,
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    resilienceLevel: AutonomicResilienceLevel.fatigued,
  );
}

EscalationForecast _forecast({required double load}) {
  return EscalationForecast(
    id: 'correlation-forecast',
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    forecastWindow: PhysiologicalForecastWindow.nearFuture,
    escalationProbability: load,
    forecastConfidence: const ForecastConfidenceResult(
      score: 70,
      level: ForecastConfidenceLevel.mediumConfidence,
      factors: ['feedback experimental'],
    ),
    escalationRiskLevel: ForecastRiskLevel.elevated,
    contributingFactors: const ['sinais fisiológicos'],
    recoveryProtection: 28,
    autonomicLoad: load,
  );
}
