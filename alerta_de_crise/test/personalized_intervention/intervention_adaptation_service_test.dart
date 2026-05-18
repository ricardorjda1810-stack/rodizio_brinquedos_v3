import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/contextual_triggers/contextual_event.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/data/crisis_detection/intervention_history_entry.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/personalized_intervention/intervention_adaptation_service.dart';
import 'package:signalflow/session_timeline/physiological_event_marker.dart';

void main() {
  group('InterventionAdaptationService', () {
    late SignalFlowDatabase database;
    late InterventionAdaptationService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = InterventionAdaptationService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('ranks recommendations by observed effectiveness', () async {
      final recommendations = await service.generateRecommendations(
        interventions: [
          _intervention('paced-breathing', id: 'breath-1', delta: -34),
          _intervention('paced-breathing', id: 'breath-2', delta: -24),
          _intervention('grounding', id: 'ground-1', delta: 2, improved: false),
        ],
        recoveryProfiles: [_recovery()],
        contextEvents: [_context()],
      );

      expect(recommendations.first.interventionType, 'paced-breathing');
      expect(
        recommendations.first.recommendationScore,
        greaterThan(recommendations.last.recommendationScore),
      );
    });

    test('updates learning profile from observed interventions', () {
      final profile = service.updateLearningProfile(
        interventionType: 'guided-pause',
        interventions: [
          _intervention('guided-pause', id: 'pause-1', delta: -20),
          _intervention('guided-pause', id: 'pause-2', delta: -12),
        ],
        contextEvents: [_context()],
      );

      expect(profile.usageCount, 2);
      expect(profile.successRate, 100);
      expect(profile.averageRecoveryImprovement, greaterThan(0));
      expect(profile.safetyCopy, contains('não garante eficácia'));
    });

    test('persists Drift profiles and recommendations', () async {
      final recommendations = await service.generateRecommendations(
        interventions: [
          _intervention('paced-breathing', id: 'breath-1', delta: -30),
        ],
        recoveryProfiles: [_recovery()],
        contextEvents: [_context()],
        persist: true,
      );

      final profiles = await service.loadProfiles();
      final loadedRecommendations = await service.loadRecommendations();
      final profileRows = await database
          .select(database.interventionLearningProfilesTable)
          .get();

      expect(recommendations, isNotEmpty);
      expect(profiles.single.interventionType, 'paced-breathing');
      expect(loadedRecommendations.single.safetyCopy, contains('não garante'));
      expect(profileRows.single.safetyCopy, contains('padrões observados'));
    });

    test('migration 8 to 9 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 10);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 8 &&
              migration.toVersion == 9 &&
              migration.description.contains('Personalized intervention'),
        ),
        isTrue,
      );
    });

    test(
      'recommendation confidence is consistent and markers are generated',
      () async {
        final recommendations = await service.generateRecommendations(
          interventions: [
            _intervention('paced-breathing', id: 'breath-1', delta: -30),
            _intervention('paced-breathing', id: 'breath-2', delta: -24),
          ],
          recoveryProfiles: [_recovery(), _recovery()],
          contextEvents: [_context()],
        );
        final markers = service.buildOptionalMarkers(
          recommendations: recommendations,
          timelineId: 'timeline-intervention',
        );

        expect(recommendations.first.confidence, inInclusiveRange(0, 100));
        expect(
          markers.map((marker) => marker.type),
          contains(EventType.contextualRecommendationGenerated),
        );
      },
    );
  });
}

InterventionHistoryEntry _intervention(
  String type, {
  required String id,
  int delta = -20,
  bool improved = true,
}) {
  final end = DateTime.utc(2026, 5, 18, 12);
  return InterventionHistoryEntry(
    id: id,
    protocolId: type,
    startedAt: end.subtract(const Duration(minutes: 5)),
    completedAt: end,
    durationSeconds: 300,
    completed: true,
    userReportedImprovement: improved,
    finalResponse: CognitiveCheckResponse.feelingOk,
    preInterventionScore: 70,
    postInterventionScore: 70 + delta,
    scoreDelta: delta,
  );
}

AutonomicRecoveryProfile _recovery() {
  return AutonomicRecoveryProfile(
    recoveryRate: 0.62,
    hrvRecoverySlope: 0.24,
    heartRateNormalization: 0.6,
    baselineReturnTime: const Duration(minutes: 16),
    resilienceScore: 68,
    fatigueScore: 36,
    stressCarryover: 0.22,
    generatedAt: DateTime.utc(2026, 5, 18, 12, 10),
    resilienceLevel: AutonomicResilienceLevel.stable,
  );
}

ContextualEvent _context() {
  return ContextualEvent(
    id: 'context-work',
    timestamp: DateTime.utc(2026, 5, 18, 11, 30),
    category: ContextualCategory.work,
    label: 'Work',
    description: 'contexto de teste',
    intensity: ContextualIntensity.medium,
    source: 'test',
  );
}
