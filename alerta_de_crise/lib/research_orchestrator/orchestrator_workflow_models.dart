import 'research_orchestrator_models.dart';

class OrchestratorWorkflow {
  final String workflowId;
  final String title;
  final List<ExperimentalPipelineType> enabledPipelines;
  final Duration executionFrequency;
  final DateTime? lastExecution;
  final int totalExecutions;
  final Duration averageExecutionTime;

  const OrchestratorWorkflow({
    required this.workflowId,
    required this.title,
    required this.enabledPipelines,
    required this.executionFrequency,
    required this.lastExecution,
    required this.totalExecutions,
    required this.averageExecutionTime,
  });

  OrchestratorWorkflow recordExecution({
    required DateTime executedAt,
    required Duration executionTime,
  }) {
    final totalMillis =
        averageExecutionTime.inMilliseconds * totalExecutions +
        executionTime.inMilliseconds;
    final nextTotal = totalExecutions + 1;
    return OrchestratorWorkflow(
      workflowId: workflowId,
      title: title,
      enabledPipelines: enabledPipelines,
      executionFrequency: executionFrequency,
      lastExecution: executedAt,
      totalExecutions: nextTotal,
      averageExecutionTime: Duration(milliseconds: totalMillis ~/ nextTotal),
    );
  }

  String get safetyCopy =>
      'workflow de orquestração experimental com execução controlada.';
}
