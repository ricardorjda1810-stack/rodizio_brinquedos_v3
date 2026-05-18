import '../cross_modal_fusion/cross_modal_models.dart';
import '../experimental_insights/experimental_insight_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../realtime_streaming/realtime_stream_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import 'research_orchestrator_models.dart';

class OrchestratorSnapshotService {
  final DateTime Function() _now;

  const OrchestratorSnapshotService({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  OrchestratorSnapshot generateSnapshot({
    List<ExperimentalPipelineRun> runs = const [],
    List<RealtimePipelineSnapshot> realtimeSnapshots = const [],
    List<EscalationForecast> forecasts = const [],
    List<ExperimentalPhysiologicalInsight> insights = const [],
    List<PhysiologicalEventMarker> markers = const [],
    List<IntegratedPhysiologicalConsensus> consensusSnapshots = const [],
    int activePipelines = 0,
  }) {
    final completedRuns = runs.where((run) => run.completedAt != null).toList();
    final successfulRuns = completedRuns.where((run) => run.success).length;
    final successRate = completedRuns.isEmpty
        ? 100.0
        : (successfulRuns / completedRuns.length) * 100;
    final averageExecution = _averageDuration(
      completedRuns.map((run) => run.executionDuration),
    );
    final confidence = consensusSnapshots.isEmpty
        ? 70.0
        : _average(
            consensusSnapshots.map(
              (snapshot) => snapshot.multimodalConfidence.score,
            ),
          );
    final healthScore = ((successRate * 0.55) + (confidence * 0.45))
        .clamp(0, 100)
        .toDouble();

    return OrchestratorSnapshot(
      generatedAt: _now(),
      activePipelines: activePipelines,
      completedRuns: completedRuns.length,
      healthScore: healthScore,
      totalForecasts:
          forecasts.length +
          runs.fold<int>(0, (total, run) => total + run.generatedForecasts),
      totalInsights:
          insights.length +
          runs.fold<int>(0, (total, run) => total + run.generatedInsights),
      totalMarkers:
          markers.length +
          runs.fold<int>(0, (total, run) => total + run.generatedMarkers),
      averageExecutionTime: averageExecution,
      summaryFactors: [
        'orquestração experimental',
        'coordenação de análise',
        'processamento longitudinal',
        if (realtimeSnapshots.isNotEmpty) 'realtime snapshots',
        if (consensusSnapshots.isNotEmpty) 'consenso multimodal',
      ],
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

  double _average(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    return list.fold<double>(0, (sum, value) => sum + value) / list.length;
  }
}
