import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/replay_engine/advanced_replay_service.dart';
import 'package:signalflow/replay_engine/replay_engine_models.dart';
import 'package:signalflow/replay_engine/replay_timeline_engine.dart';
import 'package:signalflow/replay_engine/replay_validation_service.dart';
import 'package:signalflow/replay_engine/synthetic_scenario_generator.dart';

void main() {
  group('AdvancedReplayService', () {
    late SignalFlowDatabase database;
    late SyntheticScenarioGenerator generator;
    late AdvancedReplayService replayService;
    late ReplayValidationService validationService;

    setUp(() {
      database = SignalFlowDatabase.memory();
      generator = SyntheticScenarioGenerator(
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
      replayService = AdvancedReplayService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12, 5),
      );
      validationService = ReplayValidationService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12, 10),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('starts pauses and resumes replay', () async {
      final dataset = generator.generateEscalationScenario(sampleCount: 6);

      final started = await replayService.startReplay(dataset: dataset);
      final paused = replayService.pauseReplay();
      final resumed = replayService.resumeReplay();

      expect(started.state, ReplayPlaybackState.running);
      expect(paused.state, ReplayPlaybackState.paused);
      expect(resumed.state, ReplayPlaybackState.running);
    });

    test('timeline stepping moves through samples', () {
      final dataset = generator.generateSyntheticScenario(sampleCount: 5);
      final engine = ReplayTimelineEngine(
        samples: dataset.samples,
        markers: dataset.markers,
        contextualEvents: dataset.contextualEvents,
        forecasts: dataset.forecasts,
      );

      final first = engine.currentState();
      final second = engine.stepForward();
      final firstAgain = engine.stepBackward();

      expect(second.index, first.index + 1);
      expect(firstAgain.index, first.index);
      expect(engine.currentTimestamp(), first.timestamp);
    });

    test('validates replay consistency', () {
      final dataset = generator.generateEscalationScenario(sampleCount: 8);

      final result = validationService.validateReplay(dataset);

      expect(result.replayConsistency, greaterThanOrEqualTo(80));
      expect(result.timelineConsistency, greaterThanOrEqualTo(80));
      expect(result.findings, isNotEmpty);
      expect(result.safetyCopy, contains('validação offline'));
    });

    test('persists Drift scenario and validation result', () async {
      final dataset = generator.generateSyntheticScenario(sampleCount: 8);
      await replayService.startReplay(dataset: dataset, persistScenario: true);
      final validation = validationService.validateReplay(dataset);
      await validationService.persistValidationResult(validation);

      final scenarios = await replayService.loadScenarios();
      final validations = await validationService.loadValidationResults();
      final scenarioRows = await database
          .select(database.replayScenariosTable)
          .get();
      final validationRows = await database
          .select(database.replayValidationResultsTable)
          .get();

      expect(scenarios.single.id, dataset.scenario.id);
      expect(validations.single.scenarioId, dataset.scenario.id);
      expect(scenarioRows.single.safetyCopy, contains('cenário sintético'));
      expect(validationRows.single.safetyCopy, contains('validação offline'));
    });

    test('migration 11 to 12 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 17);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 11 &&
              migration.toVersion == 12 &&
              migration.description.contains('Advanced replay engine'),
        ),
        isTrue,
      );
    });
  });
}
