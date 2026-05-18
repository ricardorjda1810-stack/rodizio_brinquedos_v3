import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/research_orchestrator/experimental_pipeline_service.dart';
import 'package:signalflow/research_orchestrator/orchestrator_workflow_models.dart';
import 'package:signalflow/research_orchestrator/research_orchestrator_models.dart';

void main() {
  group('ExperimentalPipelineService', () {
    late SignalFlowDatabase database;
    late ExperimentalPipelineService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = ExperimentalPipelineService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('starts pipeline and records execution duration', () async {
      final run = await service.startPipeline(
        pipelineType: ExperimentalPipelineType.realtimeAnalysis,
        processedSamples: 18,
        persist: false,
      );

      expect(run.success, isTrue);
      expect(run.executionDuration, greaterThan(Duration.zero));
      expect(run.generatedForecasts, 1);
      expect(service.runs, contains(run));
      expect(service.activePipelines, isEmpty);
    });

    test('executes workflow and calculates health score', () async {
      final runs = await service.executeWorkflow(
        workflow: _workflow(),
        processedSamples: 20,
        persist: false,
      );
      final health = service.calculatePipelineHealth(runs);

      expect(runs, hasLength(3));
      expect(health, inInclusiveRange(0, 100));
      expect(health, greaterThan(50));
    });

    test('generates pipeline snapshot', () async {
      await service.startPipeline(
        pipelineType: ExperimentalPipelineType.forecastSimulation,
        processedSamples: 12,
        persist: false,
      );
      final snapshot = service.generatePipelineSnapshot();

      expect(snapshot.completedRuns, 1);
      expect(snapshot.totalForecasts, 2);
      expect(snapshot.healthScore, inInclusiveRange(0, 100));
      expect(snapshot.safetyCopy, contains('execução controlada'));
    });

    test('persists Drift pipeline run and workflow', () async {
      final runs = await service.executeWorkflow(
        workflow: _workflow(),
        processedSamples: 16,
      );
      final loadedRuns = await service.loadPipelineRuns();
      final loadedWorkflows = await service.loadWorkflows();
      final runRows = await database
          .select(database.experimentalPipelineRunsTable)
          .get();
      final workflowRows = await database
          .select(database.orchestratorWorkflowsTable)
          .get();

      expect(runs, hasLength(3));
      expect(loadedRuns, hasLength(3));
      expect(loadedWorkflows, hasLength(1));
      expect(runRows.first.safetyCopy, contains('não monitoramento clínico'));
      expect(
        workflowRows.first.safetyCopy,
        contains('orquestração experimental'),
      );
    });

    test('migration 15 to 16 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 17);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 15 &&
              migration.toVersion == 16 &&
              migration.description.contains('Research orchestrator'),
        ),
        isTrue,
      );
    });

    test('records controlled pipeline failure', () async {
      final run = await service.startPipeline(
        pipelineType: ExperimentalPipelineType.syntheticReplay,
        shouldFail: true,
        persist: false,
      );
      final health = service.calculatePipelineHealth([run]);

      expect(run.success, isFalse);
      expect(health, lessThan(50));
    });
  });
}

OrchestratorWorkflow _workflow() {
  return const OrchestratorWorkflow(
    workflowId: 'workflow-service-test',
    title: 'Synthetic orchestrator workflow',
    enabledPipelines: [
      ExperimentalPipelineType.realtimeAnalysis,
      ExperimentalPipelineType.forecastSimulation,
      ExperimentalPipelineType.multimodalFusion,
    ],
    executionFrequency: Duration(minutes: 15),
    lastExecution: null,
    totalExecutions: 0,
    averageExecutionTime: Duration.zero,
  );
}
