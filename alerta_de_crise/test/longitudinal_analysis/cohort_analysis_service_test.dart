import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/contextual_triggers/contextual_event.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/longitudinal_analysis/cohort_analysis_service.dart';
import 'package:signalflow/longitudinal_analysis/longitudinal_analysis_models.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/predictive_forecasting/physiological_forecast_window.dart';
import 'package:signalflow/predictive_forecasting/predictive_forecast_models.dart';
import 'package:signalflow/session_timeline/session_timeline_models.dart';

void main() {
  group('CohortAnalysisService', () {
    late SignalFlowDatabase database;
    late CohortAnalysisService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = CohortAnalysisService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('generates cohort analysis with contextual consistency', () async {
      final result = await service.generateCohortAnalysis(
        sessions: [_session('s1'), _session('s2'), _session('s3')],
        trends: [_trend(42), _trend(38), _trend(34)],
        recoveryProfiles: [_recovery(0.5, 55), _recovery(0.62, 68)],
        forecasts: [_forecast(36, 44)],
        contextEvents: [
          _context(ContextualCategory.work),
          _context(ContextualCategory.work),
          _context(ContextualCategory.noise),
        ],
      );

      expect(result.comparedSessions, 3);
      expect(result.contextualConsistency, closeTo(66.6, 0.2));
      expect(result.safetyCopy, contains('não representam diagnóstico'));
    });

    test('generates evolution trend', () {
      final profile = service.generateEvolutionProfile(
        sessions: [_session('s1', hr: 82), _session('s2', hr: 74)],
        trends: [_trend(70), _trend(42)],
        recoveryProfiles: [_recovery(0.42, 45), _recovery(0.66, 72)],
        forecasts: [_forecast(40, 48)],
      );

      expect(profile.recoveryTrend, LongitudinalEvolutionTrend.improving);
      expect(profile.escalationTrend, LongitudinalEvolutionTrend.improving);
      expect(profile.safetyCopy, contains('não representa diagnóstico'));
    });

    test('longitudinal confidence is consistent with data volume', () {
      final low = service.calculateLongitudinalConfidence(
        sessions: [_session('s1')],
      );
      final higher = service.calculateLongitudinalConfidence(
        sessions: [_session('s1'), _session('s2')],
        trends: [_trend(40), _trend(35)],
        recoveryProfiles: [_recovery(0.5, 50)],
        forecasts: [_forecast(35, 42)],
        contextEvents: [_context(ContextualCategory.work)],
      );

      expect(higher, greaterThan(low));
      expect(higher, inInclusiveRange(0, 100));
    });

    test('persists Drift cohort and evolution profile', () async {
      final result = await service.generateCohortAnalysis(
        sessions: [_session('s1'), _session('s2')],
        recoveryProfiles: [_recovery(0.55, 60)],
        persist: true,
      );
      final profile = service.generateEvolutionProfile(
        sessions: [_session('s1'), _session('s2')],
        recoveryProfiles: [_recovery(0.44, 44), _recovery(0.62, 68)],
      );
      await service.persistEvolutionProfile(profile);

      final cohorts = await service.loadCohortAnalyses();
      final profiles = await service.loadEvolutionProfiles();

      expect(cohorts.single.id, result.id);
      expect(
        profiles.single.recoveryTrend,
        LongitudinalEvolutionTrend.improving,
      );
    });

    test('migration 9 to 10 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 19);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 9 &&
              migration.toVersion == 10 &&
              migration.description.contains('Longitudinal cohort analysis'),
        ),
        isTrue,
      );
    });
  });
}

SessionTimeline _session(String id, {double hr = 72, double hrv = 42}) {
  return SessionTimeline(
    id: id,
    startedAt: DateTime.utc(2026, 5, 18, 9),
    endedAt: DateTime.utc(2026, 5, 18, 9, 30),
    totalSamples: 60,
    totalEvents: 2,
    averageHeartRate: hr,
    averageHrv: hrv,
    maxHeartRate: hr + 12,
    minHrv: hrv - 6,
  );
}

PhysiologicalTrend _trend(int score) {
  return PhysiologicalTrend(
    averageHeartRate: 72 + score * 0.1,
    averageHrv: 44 - score * 0.1,
    hrvSlope: -0.2,
    heartRateSlope: 0.3,
    activationDensity: score / 100,
    escalationScore: score,
    generatedAt: DateTime.utc(2026, 5, 18),
    window: TrendWindow.longTerm,
  );
}

AutonomicRecoveryProfile _recovery(double rate, int resilience) {
  return AutonomicRecoveryProfile(
    recoveryRate: rate,
    hrvRecoverySlope: 0.2,
    heartRateNormalization: rate,
    baselineReturnTime: const Duration(minutes: 20),
    resilienceScore: resilience,
    fatigueScore: 100 - resilience,
    stressCarryover: (100 - resilience) / 100,
    generatedAt: DateTime.utc(2026, 5, 18),
    resilienceLevel: AutonomicResilienceLevel.stable,
  );
}

EscalationForecast _forecast(double probability, double load) {
  return EscalationForecast(
    id: 'forecast-$probability',
    generatedAt: DateTime.utc(2026, 5, 18),
    forecastWindow: PhysiologicalForecastWindow.nearFuture,
    escalationProbability: probability,
    forecastConfidence: const ForecastConfidenceResult(
      score: 70,
      level: ForecastConfidenceLevel.mediumConfidence,
      factors: ['test'],
    ),
    escalationRiskLevel: ForecastRiskLevel.moderate,
    contributingFactors: const ['tendência longitudinal'],
    recoveryProtection: 50,
    autonomicLoad: load,
  );
}

ContextualEvent _context(ContextualCategory category) {
  return ContextualEvent(
    id: 'context-${category.name}',
    timestamp: DateTime.utc(2026, 5, 18),
    category: category,
    label: category.name,
    description: 'contexto',
    intensity: ContextualIntensity.medium,
    source: 'test',
  );
}
