import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/contextual_triggers/contextual_event.dart';
import 'package:signalflow/contextual_triggers/contextual_trigger_models.dart';
import 'package:signalflow/experimental_insights/contextual_insight_service.dart';
import 'package:signalflow/experimental_insights/experimental_insight_models.dart';
import 'package:signalflow/experimental_insights/longitudinal_summary_service.dart';
import 'package:signalflow/predictive_forecasting/physiological_forecast_window.dart';
import 'package:signalflow/predictive_forecasting/predictive_forecast_models.dart';

void main() {
  group('ContextualInsightService', () {
    late ContextualInsightService service;

    setUp(() {
      service = ContextualInsightService(
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    test('generates contextual insight', () {
      final insights = service.generateContextualInsights(
        correlations: [_correlation()],
        forecasts: [_forecast()],
        recoveryProfiles: [_recovery()],
      );

      expect(insights, hasLength(1));
      expect(insights.single.insightType, InsightType.contextualPattern);
      expect(insights.single.summary, contains('padrões observados'));
      expect(insights.single.summary, contains('Não representa diagnóstico'));
      expect(insights.single.contributingFactors, isNotEmpty);
    });

    test('explains correlation experimentally', () {
      final explanation = service.explainCorrelation(_correlation());

      expect(explanation, contains('Interpretação experimental'));
      expect(explanation, contains('não representa diagnóstico'));
    });

    test('generates behavioral and recovery summaries', () {
      final insights = service.generateContextualInsights(
        correlations: [_correlation()],
        forecasts: [_forecast()],
        recoveryProfiles: [_recovery()],
      );
      final summary =
          LongitudinalSummaryService(
            now: () => DateTime.utc(2026, 5, 18, 13),
          ).summarizeRecoveryPatterns(
            recoveryProfiles: [_recovery()],
            insights: insights,
          );

      expect(
        service.generateBehavioralSummary(
          correlations: [_correlation()],
          forecasts: [_forecast()],
          recoveryProfiles: [_recovery()],
        ),
        contains('mudança contextual'),
      );
      expect(summary.safetyCopy, contains('não representa diagnóstico'));
      expect(summary.confidence, inInclusiveRange(0, 100));
    });
  });
}

ContextualTriggerCorrelation _correlation() {
  return ContextualTriggerCorrelation(
    category: ContextualCategory.work,
    occurrenceCount: 3,
    escalationCorrelation: 70,
    recoveryImpact: -10,
    confidence: 64,
    lastOccurrence: DateTime.utc(2026, 5, 18, 11),
    associatedMarkers: const [],
  );
}

EscalationForecast _forecast() {
  return EscalationForecast(
    id: 'context-forecast-test',
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    forecastWindow: PhysiologicalForecastWindow.nearFuture,
    escalationProbability: 68,
    forecastConfidence: const ForecastConfidenceResult(
      score: 66,
      level: ForecastConfidenceLevel.mediumConfidence,
      factors: ['contexto'],
    ),
    escalationRiskLevel: ForecastRiskLevel.elevated,
    contributingFactors: const ['mudanças contextuais'],
    recoveryProtection: 30,
    autonomicLoad: 70,
  );
}

AutonomicRecoveryProfile _recovery() {
  return AutonomicRecoveryProfile(
    recoveryRate: 44,
    hrvRecoverySlope: 1,
    heartRateNormalization: 45,
    baselineReturnTime: const Duration(minutes: 30),
    resilienceScore: 50,
    fatigueScore: 62,
    stressCarryover: 56,
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    resilienceLevel: AutonomicResilienceLevel.fatigued,
  );
}
