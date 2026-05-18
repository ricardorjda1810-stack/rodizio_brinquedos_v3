enum ExperimentalPipelineType {
  realtimeAnalysis,
  replayValidation,
  longitudinalAnalysis,
  forecastSimulation,
  recoverySimulation,
  multimodalFusion,
  syntheticReplay,
}

class ExperimentalPipelineRun {
  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final ExperimentalPipelineType pipelineType;
  final int processedSamples;
  final int generatedForecasts;
  final int generatedInsights;
  final int generatedMarkers;
  final Duration executionDuration;
  final bool success;

  const ExperimentalPipelineRun({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.pipelineType,
    required this.processedSamples,
    required this.generatedForecasts,
    required this.generatedInsights,
    required this.generatedMarkers,
    required this.executionDuration,
    required this.success,
  });

  String get safetyCopy =>
      'orquestração experimental de pipeline experimental; não monitoramento clínico.';
}

class OrchestratorSnapshot {
  final DateTime generatedAt;
  final int activePipelines;
  final int completedRuns;
  final double healthScore;
  final int totalForecasts;
  final int totalInsights;
  final int totalMarkers;
  final Duration averageExecutionTime;
  final List<String> summaryFactors;

  const OrchestratorSnapshot({
    required this.generatedAt,
    required this.activePipelines,
    required this.completedRuns,
    required this.healthScore,
    required this.totalForecasts,
    required this.totalInsights,
    required this.totalMarkers,
    required this.averageExecutionTime,
    required this.summaryFactors,
  });

  String get safetyCopy =>
      'coordenação de análise em execução controlada; não monitoramento clínico.';
}
