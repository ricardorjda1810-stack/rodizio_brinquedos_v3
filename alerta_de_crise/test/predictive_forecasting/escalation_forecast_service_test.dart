import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/predictive_forecasting/escalation_forecast_service.dart';
import 'package:signalflow/predictive_forecasting/predictive_forecast_models.dart';
import 'package:signalflow/sensor_quality/sensor_confidence_score.dart';
import 'package:signalflow/session_timeline/session_timeline_models.dart';

void main() {
  group('EscalationForecastService', () {
    late SignalFlowDatabase database;
    late EscalationForecastService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = EscalationForecastService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('generates low probability for stable signals', () async {
      final forecast = await service.generateForecast(
        trends: [_trend(score: 18, activation: 0.08, hrSlope: 0.05)],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.9, resilience: 86, fatigue: 8),
        ],
        confidenceScores: [_confidence(90)],
        timelines: [_timeline(samples: 80)],
      );

      expect(forecast.escalationProbability, lessThan(30));
      expect(forecast.escalationRiskLevel, ForecastRiskLevel.low);
      expect(forecast.safetyCopy, contains('previsão experimental'));
      expect(forecast.safetyCopy, contains('não é diagnóstico'));
    });

    test('generates elevated probability for escalation trend', () async {
      final forecast = await service.generateForecast(
        trends: [
          _trend(score: 46, activation: 0.4, hrSlope: 0.5, hrvSlope: -0.3),
          _trend(score: 72, activation: 0.7, hrSlope: 0.8, hrvSlope: -0.5),
        ],
        recoveryProfiles: [
          _recovery(
            recoveryRate: 0.2,
            resilience: 34,
            fatigue: 78,
            carryover: 0.74,
          ),
        ],
        confidenceScores: [_confidence(76)],
        timelines: [_timeline(samples: 45)],
      );

      expect(forecast.escalationProbability, greaterThanOrEqualTo(55));
      expect(
        forecast.escalationRiskLevel,
        anyOf(ForecastRiskLevel.elevated, ForecastRiskLevel.high),
      );
    });

    test('recovery reduces forecast probability', () {
      final highRecovery = service.calculateEscalationProbability(
        trends: [_trend(score: 55, activation: 0.45, hrSlope: 0.45)],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.9, resilience: 86, fatigue: 10),
        ],
        confidenceScores: [_confidence(85)],
      );
      final lowRecovery = service.calculateEscalationProbability(
        trends: [_trend(score: 55, activation: 0.45, hrSlope: 0.45)],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.2, resilience: 30, fatigue: 70),
        ],
        confidenceScores: [_confidence(85)],
      );

      expect(highRecovery, lessThan(lowRecovery));
    });

    test('fatigue increases forecast probability', () {
      final lowFatigue = service.calculateEscalationProbability(
        trends: [_trend(score: 40, activation: 0.35, hrSlope: 0.35)],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.6, resilience: 72, fatigue: 12),
        ],
        confidenceScores: [_confidence(85)],
      );
      final highFatigue = service.calculateEscalationProbability(
        trends: [_trend(score: 40, activation: 0.35, hrSlope: 0.35)],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.6, resilience: 42, fatigue: 82),
        ],
        confidenceScores: [_confidence(85)],
      );

      expect(highFatigue, greaterThan(lowFatigue));
    });

    test('fills contributing factors', () async {
      final forecast = await service.generateForecast(
        trends: [_trend(score: 62, activation: 0.5, hrSlope: 0.7)],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.3, resilience: 36, fatigue: 66),
        ],
        confidenceScores: [_confidence(58)],
        timelines: [_timeline(samples: 12)],
      );

      expect(forecast.contributingFactors, isNotEmpty);
      expect(
        forecast.contributingFactors.join(' '),
        contains('escalada fisiológica'),
      );
    });

    test('persists forecast with Drift', () async {
      final forecast = await service.generateForecast(
        trends: [_trend(score: 64, activation: 0.54, hrSlope: 0.55)],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.36, resilience: 44, fatigue: 58),
        ],
        confidenceScores: [_confidence(70)],
        timelines: [_timeline(samples: 40)],
        persist: true,
      );

      final rows = await database
          .select(database.escalationForecastsTable)
          .get();
      final loaded = await service.loadForecasts();

      expect(rows.single.id, forecast.id);
      expect(rows.single.safetyCopy, contains('não é diagnóstico'));
      expect(
        loaded.single.escalationProbability,
        forecast.escalationProbability,
      );
    });

    test('migration 6 to 7 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 18);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 6 &&
              migration.toVersion == 7 &&
              migration.description.contains('Predictive forecasting'),
        ),
        isTrue,
      );
    });
  });
}

PhysiologicalTrend _trend({
  required int score,
  required double activation,
  required double hrSlope,
  double hrvSlope = -0.1,
}) {
  return PhysiologicalTrend(
    averageHeartRate: 72 + score * 0.2,
    averageHrv: 44 - score * 0.12,
    hrvSlope: hrvSlope,
    heartRateSlope: hrSlope,
    activationDensity: activation,
    escalationScore: score,
    generatedAt: DateTime.utc(2026, 5, 18),
    window: TrendWindow.shortTerm,
  );
}

AutonomicRecoveryProfile _recovery({
  required double recoveryRate,
  required int resilience,
  required int fatigue,
  double carryover = 0.2,
}) {
  return AutonomicRecoveryProfile(
    recoveryRate: recoveryRate,
    hrvRecoverySlope: recoveryRate,
    heartRateNormalization: recoveryRate,
    baselineReturnTime: const Duration(minutes: 12),
    resilienceScore: resilience,
    fatigueScore: fatigue,
    stressCarryover: carryover,
    generatedAt: DateTime.utc(2026, 5, 18),
    resilienceLevel: resilience >= 70
        ? AutonomicResilienceLevel.resilient
        : AutonomicResilienceLevel.fatigued,
  );
}

SensorConfidenceScore _confidence(int score, {bool hasArtifacts = false}) {
  return SensorConfidenceScore(
    overallScore: score,
    rrQuality: score,
    hrQuality: score,
    movementConfidence: score,
    contactConfidence: score,
    hasArtifacts: hasArtifacts,
    warnings: hasArtifacts ? const ['artifact'] : const [],
  );
}

SessionTimeline _timeline({required int samples}) {
  return SessionTimeline(
    id: 'timeline-test',
    startedAt: DateTime.utc(2026, 5, 18, 11),
    endedAt: DateTime.utc(2026, 5, 18, 12),
    totalSamples: samples,
    totalEvents: 0,
    averageHeartRate: 74,
    averageHrv: 42,
    maxHeartRate: 90,
    minHrv: 34,
  );
}
