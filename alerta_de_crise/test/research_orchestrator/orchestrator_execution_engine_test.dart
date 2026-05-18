import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/realtime_streaming/realtime_stream_models.dart';
import 'package:signalflow/research_orchestrator/orchestrator_execution_engine.dart';
import 'package:signalflow/research_orchestrator/orchestrator_snapshot_service.dart';
import 'package:signalflow/research_orchestrator/orchestrator_workflow_models.dart';
import 'package:signalflow/research_orchestrator/research_orchestrator_models.dart';

void main() {
  group('OrchestratorExecutionEngine', () {
    late OrchestratorExecutionEngine engine;

    setUp(() {
      engine = OrchestratorExecutionEngine(
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    test('executes pipeline with duration and success', () {
      final run = engine.executePipeline(
        pipelineType: ExperimentalPipelineType.realtimeAnalysis,
        processedSamples: 20,
        generatedForecasts: 1,
        generatedInsights: 1,
        generatedMarkers: 1,
      );

      expect(run.pipelineType, ExperimentalPipelineType.realtimeAnalysis);
      expect(run.completedAt, isNotNull);
      expect(run.executionDuration, greaterThan(Duration.zero));
      expect(run.success, isTrue);
      expect(run.safetyCopy, contains('pipeline experimental'));
    });

    test('executes workflow with enabled pipelines', () {
      final runs = engine.executeWorkflow(
        workflow: _workflow(),
        processedSamples: 12,
      );

      expect(runs, hasLength(3));
      expect(
        runs.map((run) => run.pipelineType),
        contains(ExperimentalPipelineType.multimodalFusion),
      );
      expect(runs.every((run) => run.success), isTrue);
    });

    test('executes realtime and replay cycles', () {
      final realtime = engine.executeRealtimeCycle(
        realtimeSnapshots: [_realtimeSnapshot(bufferSize: 8)],
      );
      final replay = engine.executeReplayCycle(replayedSamples: 30);

      expect(realtime.processedSamples, 8);
      expect(realtime.pipelineType, ExperimentalPipelineType.realtimeAnalysis);
      expect(replay.processedSamples, 30);
      expect(replay.pipelineType, ExperimentalPipelineType.replayValidation);
    });

    test('supports controlled failure', () {
      final run = engine.executePipeline(
        pipelineType: ExperimentalPipelineType.syntheticReplay,
        shouldFail: true,
      );

      expect(run.success, isFalse);
      expect(run.completedAt, isNotNull);
    });

    test('generates orchestrator snapshot', () {
      final run = engine.executePipeline(
        pipelineType: ExperimentalPipelineType.forecastSimulation,
        processedSamples: 10,
        generatedForecasts: 2,
      );
      final snapshot = OrchestratorSnapshotService(
        now: () => DateTime.utc(2026, 5, 18, 12, 5),
      ).generateSnapshot(runs: [run]);

      expect(snapshot.completedRuns, 1);
      expect(snapshot.totalForecasts, 2);
      expect(snapshot.healthScore, inInclusiveRange(0, 100));
      expect(snapshot.summaryFactors, contains('orquestração experimental'));
    });
  });
}

OrchestratorWorkflow _workflow() {
  return const OrchestratorWorkflow(
    workflowId: 'workflow-test',
    title: 'Pipeline experimental',
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

RealtimePipelineSnapshot _realtimeSnapshot({required int bufferSize}) {
  return RealtimePipelineSnapshot(
    id: 'snapshot-test',
    generatedAt: DateTime.utc(2026, 5, 18, 11),
    bufferSize: bufferSize,
    rollingHeartRate: 82,
    rollingHrv: 36,
    rollingConfidence: 80,
    rollingEscalationDensity: 20,
    latestEscalationProbability: 30,
    streamingState: RealtimeStreamingState.running,
  );
}
