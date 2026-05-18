import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/cognitive_feedback/cognitive_feedback_models.dart';
import 'package:signalflow/cognitive_feedback/perceived_state_models.dart';
import 'package:signalflow/contextual_triggers/contextual_event.dart';
import 'package:signalflow/contextual_triggers/contextual_trigger_models.dart';
import 'package:signalflow/cross_modal_fusion/cross_modal_models.dart';
import 'package:signalflow/cross_modal_fusion/physiological_fusion_service.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/predictive_forecasting/physiological_forecast_window.dart';
import 'package:signalflow/predictive_forecasting/predictive_forecast_models.dart';
import 'package:signalflow/sensor_quality/sensor_confidence_score.dart';

void main() {
  group('PhysiologicalFusionService', () {
    late SignalFlowDatabase database;
    late PhysiologicalFusionService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = PhysiologicalFusionService(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('generates integrated consensus and recommendations', () async {
      final result = await service.generateFusion(
        sensorConfidence: _sensorConfidence(),
        trends: [_trend()],
        recoveryProfiles: [_recovery()],
        contextualCorrelations: [_contextual()],
        subjectiveFeedback: [_feedback()],
        forecasts: [_forecast()],
        persist: false,
      );

      expect(result.consensus.integratedStressLoad, inInclusiveRange(0, 100));
      expect(
        result.consensus.multimodalConfidence.level,
        isNot(MultimodalConfidenceLevel.low),
      );
      expect(result.consensus.contributingSignals, isNotEmpty);
      expect(result.weights.toMap().values, everyElement(greaterThan(0)));
    });

    test('detects signal conflicts in fusion result', () async {
      final result = await service.generateFusion(
        sensorConfidence: _sensorConfidence(),
        trends: [_trend(score: 86, activation: 84)],
        recoveryProfiles: [_recovery(resilience: 84, fatigue: 12)],
        subjectiveFeedback: [_feedback(stress: 1, fatigue: 1, recovery: 9)],
        forecasts: [_forecast(probability: 78, load: 82)],
        persist: false,
      );

      expect(result.signalConflicts, isNotEmpty);
      expect(result.consensus.signalAgreement, lessThan(80));
      expect(result.consensus.disagreementFactors, result.signalConflicts);
    });

    test('persists Drift consensus snapshot', () async {
      final result = await service.generateFusion(
        sensorConfidence: _sensorConfidence(),
        trends: [_trend()],
        recoveryProfiles: [_recovery()],
        contextualCorrelations: [_contextual()],
        subjectiveFeedback: [_feedback()],
        forecasts: [_forecast()],
      );

      final rows = await database
          .select(database.integratedConsensusSnapshotsTable)
          .get();
      final loaded = await service.loadConsensus();

      expect(rows, hasLength(1));
      expect(loaded, hasLength(1));
      expect(rows.first.id, result.consensus.id);
      expect(rows.first.safetyCopy, contains('fusão multimodal'));
      expect(rows.first.contributingSignalsJson, contains('sinais combinados'));
    });

    test('migration 14 to 15 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 18);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 14 &&
              migration.toVersion == 15 &&
              migration.description.contains('Cross-modal fusion'),
        ),
        isTrue,
      );
    });
  });
}

SensorConfidenceScore _sensorConfidence() {
  return const SensorConfidenceScore(
    overallScore: 84,
    rrQuality: 86,
    hrQuality: 82,
    movementConfidence: 80,
    contactConfidence: 86,
    hasArtifacts: false,
    warnings: [],
  );
}

PhysiologicalTrend _trend({int score = 68, double activation = 64}) {
  return PhysiologicalTrend(
    averageHeartRate: 90,
    averageHrv: 30,
    hrvSlope: -3,
    heartRateSlope: 5,
    activationDensity: activation,
    escalationScore: score,
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    window: TrendWindow.shortTerm,
  );
}

AutonomicRecoveryProfile _recovery({int resilience = 50, int fatigue = 62}) {
  return AutonomicRecoveryProfile(
    recoveryRate: 44,
    hrvRecoverySlope: 1,
    heartRateNormalization: 46,
    baselineReturnTime: const Duration(minutes: 35),
    resilienceScore: resilience,
    fatigueScore: fatigue,
    stressCarryover: 58,
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
    id: 'feedback-fusion-test',
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    perceivedState: PerceivedState(
      timestamp: DateTime.utc(2026, 5, 18, 11),
      perceivedStress: stress,
      perceivedFatigue: fatigue,
      perceivedControl: 4,
      perceivedRecovery: recovery,
      emotionalIntensity: stress,
      notes: 'percepção subjetiva',
    ),
    contextualFactors: const ['contexto'],
    physiologicalCorrelation: 68,
    confidence: 66,
  );
}

EscalationForecast _forecast({double probability = 68, double load = 70}) {
  return EscalationForecast(
    id: 'forecast-fusion-test',
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    forecastWindow: PhysiologicalForecastWindow.nearFuture,
    escalationProbability: probability,
    forecastConfidence: const ForecastConfidenceResult(
      score: 68,
      level: ForecastConfidenceLevel.mediumConfidence,
      factors: ['confiança experimental'],
    ),
    escalationRiskLevel: ForecastRiskLevel.elevated,
    contributingFactors: const ['integração multimodal'],
    recoveryProtection: 34,
    autonomicLoad: load,
  );
}
