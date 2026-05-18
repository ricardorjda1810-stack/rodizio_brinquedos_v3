import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/experimental_insights/experimental_insight_models.dart';
import 'package:signalflow/experimental_insights/longitudinal_summary_service.dart';
import 'package:signalflow/experimental_insights/physiological_insight_service.dart';
import 'package:signalflow/longitudinal_analysis/longitudinal_analysis_models.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/predictive_forecasting/physiological_forecast_window.dart';
import 'package:signalflow/predictive_forecasting/predictive_forecast_models.dart';

void main() {
  group('PhysiologicalInsightService', () {
    late SignalFlowDatabase database;
    late PhysiologicalInsightService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = PhysiologicalInsightService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('generates insight with contributing factors', () {
      final insights = service.generateInsights(
        trends: _trends(),
        recoveryProfiles: _recovery(),
        forecasts: [_forecast()],
      );

      expect(insights, isNotEmpty);
      expect(
        insights.any(
          (insight) => insight.insightType == InsightType.escalationPattern,
        ),
        isTrue,
      );
      expect(insights.first.contributingFactors, isNotEmpty);
      expect(insights.first.safetyCopy, contains('não representa diagnóstico'));
    });

    test('confidence is consistent', () {
      final insights = service.generateRealtimeInsights(
        trends: _trends(),
        recoveryProfiles: _recovery(),
        forecasts: [_forecast()],
      );

      expect(insights.first.confidence, inInclusiveRange(0, 100));
      expect(insights.first.confidence, greaterThan(45));
    });

    test('detects recurring pattern and longitudinal summary', () {
      final insights = service.generateInsights(
        trends: _trends(),
        recoveryProfiles: _recovery(),
        forecasts: [_forecast()],
        cohortAnalyses: [_cohort()],
      );
      final summary =
          LongitudinalSummaryService(
            now: () => DateTime.utc(2026, 5, 18, 12, 30),
          ).generateLongitudinalSummary(
            insights: insights,
            cohortAnalyses: [_cohort()],
          );

      expect(
        insights.any(
          (insight) => insight.insightType == InsightType.escalationPattern,
        ),
        isTrue,
      );
      expect(summary.summary, contains('Não representa diagnóstico'));
      expect(summary.confidence, inInclusiveRange(0, 100));
    });

    test('persists Drift insight', () async {
      final insights = service.generateInsights(
        trends: _trends(),
        recoveryProfiles: _recovery(),
        forecasts: [_forecast()],
      );

      await service.persistInsights(insights);
      final loaded = await service.loadInsights();
      final rows = await database
          .select(database.experimentalInsightsTable)
          .get();

      expect(loaded, isNotEmpty);
      expect(rows.first.safetyCopy, contains('padrões observados'));
      expect(rows.first.contributingFactors, isNotEmpty);
    });

    test('migration 12 to 13 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 18);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 12 &&
              migration.toVersion == 13 &&
              migration.description.contains('Experimental insight'),
        ),
        isTrue,
      );
    });
  });
}

List<PhysiologicalTrend> _trends() {
  return [
    PhysiologicalTrend(
      averageHeartRate: 88,
      averageHrv: 31,
      hrvSlope: -4,
      heartRateSlope: 6,
      activationDensity: 64,
      escalationScore: 68,
      generatedAt: DateTime.utc(2026, 5, 18, 11),
      window: TrendWindow.shortTerm,
    ),
    PhysiologicalTrend(
      averageHeartRate: 91,
      averageHrv: 28,
      hrvSlope: -3,
      heartRateSlope: 5,
      activationDensity: 61,
      escalationScore: 66,
      generatedAt: DateTime.utc(2026, 5, 18, 11, 30),
      window: TrendWindow.mediumTerm,
    ),
  ];
}

List<AutonomicRecoveryProfile> _recovery() {
  return [
    AutonomicRecoveryProfile(
      recoveryRate: 40,
      hrvRecoverySlope: 1,
      heartRateNormalization: 42,
      baselineReturnTime: const Duration(minutes: 40),
      resilienceScore: 46,
      fatigueScore: 68,
      stressCarryover: 60,
      generatedAt: DateTime.utc(2026, 5, 18, 11),
      resilienceLevel: AutonomicResilienceLevel.fatigued,
    ),
  ];
}

EscalationForecast _forecast() {
  return EscalationForecast(
    id: 'forecast-test',
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    forecastWindow: PhysiologicalForecastWindow.nearFuture,
    escalationProbability: 72,
    forecastConfidence: const ForecastConfidenceResult(
      score: 70,
      level: ForecastConfidenceLevel.highConfidence,
      factors: ['dados longitudinais'],
    ),
    escalationRiskLevel: ForecastRiskLevel.elevated,
    contributingFactors: const ['tendência fisiológica'],
    recoveryProtection: 24,
    autonomicLoad: 75,
  );
}

CohortAnalysisResult _cohort() {
  return CohortAnalysisResult(
    id: 'cohort-test',
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    comparedSessions: 5,
    averageRecoveryEfficiency: 55,
    averageEscalationProbability: 62,
    averageResilience: 51,
    stabilityScore: 48,
    variabilityScore: 64,
    contextualConsistency: 58,
    longitudinalConfidence: 66,
  );
}
