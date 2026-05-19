import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/cognitive_feedback/perceived_state_models.dart';
import 'package:signalflow/cognitive_feedback/subjective_feedback_service.dart';
import 'package:signalflow/contextual_triggers/contextual_event.dart';
import 'package:signalflow/contextual_triggers/contextual_trigger_models.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/predictive_forecasting/physiological_forecast_window.dart';
import 'package:signalflow/predictive_forecasting/predictive_forecast_models.dart';
import 'package:signalflow/session_timeline/physiological_event_marker.dart';

void main() {
  group('SubjectiveFeedbackService', () {
    late SignalFlowDatabase database;
    late SubjectiveFeedbackService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = SubjectiveFeedbackService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('registers subjective feedback entry', () async {
      final entry = await service.submitFeedback(
        perceivedState: _state(stress: 11, fatigue: 8, recovery: -2),
        contextualFactors: const ['contexto emocional percebido'],
        trends: [_trend()],
        recoveryProfiles: [_recovery()],
        contextualCorrelations: [_contextualCorrelation()],
        forecasts: [_forecast()],
        relatedMarkers: [_marker()],
        persist: false,
      );

      expect(entry.id, startsWith('subjective-'));
      expect(entry.perceivedState.perceivedStress, 10);
      expect(entry.perceivedState.perceivedRecovery, 0);
      expect(entry.contextualFactors, contains('contexto emocional percebido'));
      expect(entry.relatedMarkers.single.type, EventType.perceivedHighStress);
      expect(entry.safetyCopy, contains('feedback subjetivo experimental'));
      expect(entry.confidence, inInclusiveRange(0, 100));
    });

    test('summarizes perceived recovery and patterns', () async {
      final recovered = await service.submitFeedback(
        perceivedState: _state(stress: 3, fatigue: 2, control: 8, recovery: 8),
        persist: false,
      );
      final fatigued = await service.submitFeedback(
        perceivedState: _state(stress: 7, fatigue: 8, recovery: 3),
        persist: false,
      );
      final history = [recovered, fatigued];

      final summary = service.generateFeedbackSummary(history);

      expect(service.calculatePerceivedRecovery(history), 55);
      expect(summary.entryCount, 2);
      expect(
        summary.patterns,
        contains('recovery percebida por autoavaliação'),
      );
      expect(summary.safetyCopy, contains('não representa avaliação clínica'));
    });

    test('persists subjective feedback with Drift', () async {
      await service.submitFeedback(
        perceivedState: _state(stress: 8, fatigue: 7, recovery: 3),
        contextualFactors: const ['autoavaliação'],
        trends: [_trend()],
        forecasts: [_forecast()],
      );

      final rows = await database
          .select(database.subjectiveFeedbackEntriesTable)
          .get();
      final loaded = await service.loadFeedback();

      expect(rows, hasLength(1));
      expect(loaded, hasLength(1));
      expect(
        rows.first.safetyCopy,
        contains('não representa avaliação clínica'),
      );
      expect(rows.first.perceivedStress, 8);
    });

    test('migration 13 to 14 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 22);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 13 &&
              migration.toVersion == 14 &&
              migration.description.contains('Subjective feedback'),
        ),
        isTrue,
      );
    });
  });
}

PerceivedState _state({
  int stress = 7,
  int fatigue = 6,
  int control = 4,
  int recovery = 4,
  int emotionalIntensity = 7,
}) {
  return PerceivedState(
    timestamp: DateTime.utc(2026, 5, 18, 11),
    perceivedStress: stress,
    perceivedFatigue: fatigue,
    perceivedControl: control,
    perceivedRecovery: recovery,
    emotionalIntensity: emotionalIntensity,
    notes: 'sensação percebida registrada em teste',
  );
}

PhysiologicalTrend _trend() {
  return PhysiologicalTrend(
    averageHeartRate: 90,
    averageHrv: 30,
    hrvSlope: -3,
    heartRateSlope: 5,
    activationDensity: 65,
    escalationScore: 70,
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    window: TrendWindow.shortTerm,
  );
}

AutonomicRecoveryProfile _recovery() {
  return AutonomicRecoveryProfile(
    recoveryRate: 42,
    hrvRecoverySlope: 1,
    heartRateNormalization: 45,
    baselineReturnTime: const Duration(minutes: 35),
    resilienceScore: 48,
    fatigueScore: 66,
    stressCarryover: 60,
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    resilienceLevel: AutonomicResilienceLevel.fatigued,
  );
}

EscalationForecast _forecast() {
  return EscalationForecast(
    id: 'subjective-forecast-test',
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    forecastWindow: PhysiologicalForecastWindow.nearFuture,
    escalationProbability: 70,
    forecastConfidence: const ForecastConfidenceResult(
      score: 68,
      level: ForecastConfidenceLevel.mediumConfidence,
      factors: ['sinais fisiológicos'],
    ),
    escalationRiskLevel: ForecastRiskLevel.elevated,
    contributingFactors: const ['feedback experimental'],
    recoveryProtection: 30,
    autonomicLoad: 72,
  );
}

ContextualTriggerCorrelation _contextualCorrelation() {
  return ContextualTriggerCorrelation(
    category: ContextualCategory.work,
    occurrenceCount: 3,
    escalationCorrelation: 62,
    recoveryImpact: 35,
    confidence: 66,
    lastOccurrence: DateTime.utc(2026, 5, 18, 10),
    associatedMarkers: [_marker()],
  );
}

PhysiologicalEventMarker _marker() {
  return PhysiologicalEventMarker(
    id: 'marker-perceived-high-stress',
    timestamp: DateTime.utc(2026, 5, 18, 11),
    type: EventType.perceivedHighStress,
    title: 'Perceived high stress',
    description: 'feedback subjetivo experimental',
    severity: Severity.medium,
    source: 'test',
  );
}
