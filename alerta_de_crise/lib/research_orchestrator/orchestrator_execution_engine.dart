import '../cross_modal_fusion/cross_modal_models.dart';
import '../experimental_insights/experimental_insight_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../realtime_streaming/realtime_stream_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import 'orchestrator_workflow_models.dart';
import 'research_orchestrator_models.dart';

class OrchestratorExecutionEngine {
  final DateTime Function() _now;

  const OrchestratorExecutionEngine({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  ExperimentalPipelineRun executePipeline({
    required ExperimentalPipelineType pipelineType,
    int processedSamples = 0,
    int generatedForecasts = 0,
    int generatedInsights = 0,
    int generatedMarkers = 0,
    bool shouldFail = false,
  }) {
    final startedAt = _now();
    final duration = _durationFor(
      pipelineType: pipelineType,
      processedSamples: processedSamples,
      generatedForecasts: generatedForecasts,
      generatedInsights: generatedInsights,
      generatedMarkers: generatedMarkers,
    );
    final completedAt = startedAt.add(duration);
    return ExperimentalPipelineRun(
      id: 'pipeline-${pipelineType.name}-${startedAt.microsecondsSinceEpoch}',
      startedAt: startedAt,
      completedAt: completedAt,
      pipelineType: pipelineType,
      processedSamples: processedSamples,
      generatedForecasts: generatedForecasts,
      generatedInsights: generatedInsights,
      generatedMarkers: generatedMarkers,
      executionDuration: duration,
      success: !shouldFail,
    );
  }

  List<ExperimentalPipelineRun> executeWorkflow({
    required OrchestratorWorkflow workflow,
    int processedSamples = 0,
    bool shouldFail = false,
  }) {
    return workflow.enabledPipelines
        .map(
          (type) => executePipeline(
            pipelineType: type,
            processedSamples: processedSamples,
            generatedForecasts: _forecastCount(type),
            generatedInsights: _insightCount(type),
            generatedMarkers: _markerCount(type),
            shouldFail: shouldFail && type == workflow.enabledPipelines.last,
          ),
        )
        .toList(growable: false);
  }

  ExperimentalPipelineRun executeRealtimeCycle({
    List<RealtimePipelineSnapshot> realtimeSnapshots = const [],
    List<EscalationForecast> forecasts = const [],
    List<ExperimentalPhysiologicalInsight> insights = const [],
    List<PhysiologicalEventMarker> markers = const [],
  }) {
    return executePipeline(
      pipelineType: ExperimentalPipelineType.realtimeAnalysis,
      processedSamples: realtimeSnapshots.fold<int>(
        0,
        (total, snapshot) => total + snapshot.bufferSize,
      ),
      generatedForecasts: forecasts.length,
      generatedInsights: insights.length,
      generatedMarkers: markers.length,
    );
  }

  ExperimentalPipelineRun executeReplayCycle({
    int replayedSamples = 0,
    List<EscalationForecast> forecasts = const [],
    List<IntegratedPhysiologicalConsensus> consensusSnapshots = const [],
  }) {
    return executePipeline(
      pipelineType: ExperimentalPipelineType.replayValidation,
      processedSamples: replayedSamples,
      generatedForecasts: forecasts.length,
      generatedInsights: consensusSnapshots.length,
      generatedMarkers: consensusSnapshots
          .where((snapshot) => snapshot.signalAgreement < 60)
          .length,
    );
  }

  Duration _durationFor({
    required ExperimentalPipelineType pipelineType,
    required int processedSamples,
    required int generatedForecasts,
    required int generatedInsights,
    required int generatedMarkers,
  }) {
    final baseMillis = switch (pipelineType) {
      ExperimentalPipelineType.realtimeAnalysis => 120,
      ExperimentalPipelineType.replayValidation => 180,
      ExperimentalPipelineType.longitudinalAnalysis => 240,
      ExperimentalPipelineType.forecastSimulation => 150,
      ExperimentalPipelineType.recoverySimulation => 150,
      ExperimentalPipelineType.multimodalFusion => 170,
      ExperimentalPipelineType.syntheticReplay => 210,
    };
    return Duration(
      milliseconds:
          baseMillis +
          processedSamples * 2 +
          generatedForecasts * 15 +
          generatedInsights * 20 +
          generatedMarkers * 8,
    );
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
