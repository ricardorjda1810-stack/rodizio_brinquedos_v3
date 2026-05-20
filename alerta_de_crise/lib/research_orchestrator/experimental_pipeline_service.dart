import 'package:drift/drift.dart';

import '../database/signalflow_database.dart';
import 'orchestrator_execution_engine.dart';
import 'orchestrator_snapshot_service.dart';
import 'orchestrator_workflow_models.dart';
import 'research_orchestrator_models.dart';

class ExperimentalPipelineService {
  final SignalFlowDatabase _database;
  final OrchestratorExecutionEngine _executionEngine;
  final OrchestratorSnapshotService _snapshotService;
  final DateTime Function() _now;
  final List<ExperimentalPipelineType> _activePipelines = [];
  final List<ExperimentalPipelineRun> _runs = [];

  ExperimentalPipelineService({
    SignalFlowDatabase? database,
    OrchestratorExecutionEngine executionEngine =
        const OrchestratorExecutionEngine(),
    OrchestratorSnapshotService snapshotService =
        const OrchestratorSnapshotService(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _executionEngine = executionEngine,
       _snapshotService = snapshotService,
       _now = now ?? DateTime.now;

  List<ExperimentalPipelineType> get activePipelines =>
      List.unmodifiable(_activePipelines);

  List<ExperimentalPipelineRun> get runs => List.unmodifiable(_runs);

  Future<ExperimentalPipelineRun> startPipeline({
    required ExperimentalPipelineType pipelineType,
    int processedSamples = 0,
    bool persist = true,
    bool shouldFail = false,
  }) async {
    if (!_activePipelines.contains(pipelineType)) {
      _activePipelines.add(pipelineType);
    }
    final run = _executionEngine.executePipeline(
      pipelineType: pipelineType,
      processedSamples: processedSamples,
      generatedForecasts: _forecastCount(pipelineType),
      generatedInsights: _insightCount(pipelineType),
      generatedMarkers: _markerCount(pipelineType),
      shouldFail: shouldFail,
    );
    _runs.add(run);
    _activePipelines.remove(pipelineType);
    if (persist) {
      await persistPipelineRun(run);
    }
    return run;
  }

  Future<ExperimentalPipelineRun> stopPipeline({
    required ExperimentalPipelineType pipelineType,
    bool persist = true,
  }) async {
    _activePipelines.remove(pipelineType);
    final startedAt = _now();
    final run = ExperimentalPipelineRun(
      id: 'pipeline-stop-${pipelineType.name}-${startedAt.microsecondsSinceEpoch}',
      startedAt: startedAt,
      completedAt: startedAt,
      pipelineType: pipelineType,
      processedSamples: 0,
      generatedForecasts: 0,
      generatedInsights: 0,
      generatedMarkers: 0,
      executionDuration: Duration.zero,
      success: true,
    );
    _runs.add(run);
    if (persist) {
      await persistPipelineRun(run);
    }
    return run;
  }

  Future<List<ExperimentalPipelineRun>> executeWorkflow({
    required OrchestratorWorkflow workflow,
    int processedSamples = 0,
    bool persist = true,
    bool shouldFail = false,
  }) async {
    final runs = _executionEngine.executeWorkflow(
      workflow: workflow,
      processedSamples: processedSamples,
      shouldFail: shouldFail,
    );
    _runs.addAll(runs);
    if (persist) {
      for (final run in runs) {
        await persistPipelineRun(run);
      }
      await persistWorkflow(
        workflow.recordExecution(
          executedAt: _now(),
          executionTime: _averageDuration(
            runs.map((run) => run.executionDuration),
          ),
        ),
      );
    }
    return runs;
  }

  OrchestratorSnapshot generatePipelineSnapshot() {
    return _snapshotService.generateSnapshot(
      runs: _runs,
      activePipelines: _activePipelines.length,
    );
  }

  double calculatePipelineHealth(List<ExperimentalPipelineRun> runs) {
    if (runs.isEmpty) return 100;
    final successful = runs.where((run) => run.success).length;
    final successRate = successful / runs.length;
    final averageDuration = _averageDuration(
      runs.map((run) => run.executionDuration),
    );
    final durationPenalty = (averageDuration.inMilliseconds / 40).clamp(0, 25);
    return ((successRate * 100) - durationPenalty).clamp(0, 100).toDouble();
  }

  Future<void> persistPipelineRun(ExperimentalPipelineRun run) async {
    await _database
        .into(_database.experimentalPipelineRunsTable)
        .insertOnConflictUpdate(_runCompanion(run));
  }

  Future<void> persistWorkflow(OrchestratorWorkflow workflow) async {
    await _database
        .into(_database.orchestratorWorkflowsTable)
        .insertOnConflictUpdate(_workflowCompanion(workflow));
  }

  Future<List<ExperimentalPipelineRun>> loadPipelineRuns({
    int limit = 20,
  }) async {
    final query = _database.select(_database.experimentalPipelineRunsTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.startedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_runFromRow).toList(growable: false);
  }

  Future<List<OrchestratorWorkflow>> loadWorkflows({int limit = 20}) async {
    final query = _database.select(_database.orchestratorWorkflowsTable)
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_workflowFromRow).toList(growable: false);
  }

  ExperimentalPipelineRunsTableCompanion _runCompanion(
    ExperimentalPipelineRun run,
  ) {
    return ExperimentalPipelineRunsTableCompanion.insert(
      id: run.id,
      startedAt: run.startedAt,
      completedAt: Value(run.completedAt),
      pipelineType: run.pipelineType.name,
      processedSamples: run.processedSamples,
      generatedForecasts: run.generatedForecasts,
      generatedInsights: run.generatedInsights,
      generatedMarkers: run.generatedMarkers,
      executionDurationMs: run.executionDuration.inMilliseconds,
      success: run.success,
      safetyCopy: run.safetyCopy,
    );
  }

  OrchestratorWorkflowsTableCompanion _workflowCompanion(
    OrchestratorWorkflow workflow,
  ) {
    return OrchestratorWorkflowsTableCompanion.insert(
      workflowId: workflow.workflowId,
      title: workflow.title,
      enabledPipelines: workflow.enabledPipelines
          .map((pipeline) => pipeline.name)
          .join('|'),
      executionFrequencySeconds: workflow.executionFrequency.inSeconds,
      lastExecution: Value(workflow.lastExecution),
      totalExecutions: workflow.totalExecutions,
      averageExecutionTimeMs: workflow.averageExecutionTime.inMilliseconds,
      safetyCopy: workflow.safetyCopy,
    );
  }

  ExperimentalPipelineRun _runFromRow(ExperimentalPipelineRunsTableData row) {
    return ExperimentalPipelineRun(
      id: row.id,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      pipelineType: ExperimentalPipelineType.values.byName(row.pipelineType),
      processedSamples: row.processedSamples,
      generatedForecasts: row.generatedForecasts,
      generatedInsights: row.generatedInsights,
      generatedMarkers: row.generatedMarkers,
      executionDuration: Duration(milliseconds: row.executionDurationMs),
      success: row.success,
    );
  }

  OrchestratorWorkflow _workflowFromRow(OrchestratorWorkflowsTableData row) {
    return OrchestratorWorkflow(
      workflowId: row.workflowId,
      title: row.title,
      enabledPipelines: row.enabledPipelines.isEmpty
          ? const []
          : row.enabledPipelines
                .split('|')
                .map(ExperimentalPipelineType.values.byName)
                .toList(growable: false),
      executionFrequency: Duration(seconds: row.executionFrequencySeconds),
      lastExecution: row.lastExecution,
      totalExecutions: row.totalExecutions,
      averageExecutionTime: Duration(milliseconds: row.averageExecutionTimeMs),
    );
  }

  Duration _averageDuration(Iterable<Duration> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return Duration.zero;
    final total = list.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    return Duration(milliseconds: total ~/ list.length);
  }

  int _forecastCount(ExperimentalPipelineType type) {
    return switch (type) {
      ExperimentalPipelineType.realtimeAnalysis => 1,
      ExperimentalPipelineType.forecastSimulation => 2,
      ExperimentalPipelineType.replayValidation => 1,
      _ => 0,
    };
  }

  int _insightCount(ExperimentalPipelineType type) {
    return switch (type) {
      ExperimentalPipelineType.longitudinalAnalysis => 2,
      ExperimentalPipelineType.multimodalFusion => 1,
      ExperimentalPipelineType.syntheticReplay => 1,
      _ => 0,
    };
  }

  int _markerCount(ExperimentalPipelineType type) {
    return switch (type) {
      ExperimentalPipelineType.realtimeAnalysis => 1,
      ExperimentalPipelineType.replayValidation => 1,
      ExperimentalPipelineType.multimodalFusion => 1,
      _ => 0,
    };
  }
}
