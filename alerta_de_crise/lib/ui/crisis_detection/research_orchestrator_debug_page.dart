import 'package:flutter/material.dart';

import '../../research_orchestrator/experimental_pipeline_service.dart';
import '../../research_orchestrator/orchestrator_execution_engine.dart';
import '../../research_orchestrator/orchestrator_workflow_models.dart';
import '../../research_orchestrator/research_orchestrator_models.dart';

class ResearchOrchestratorDebugPage extends StatefulWidget {
  const ResearchOrchestratorDebugPage({super.key});

  @override
  State<ResearchOrchestratorDebugPage> createState() =>
      _ResearchOrchestratorDebugPageState();
}

class _ResearchOrchestratorDebugPageState
    extends State<ResearchOrchestratorDebugPage> {
  final ExperimentalPipelineService _service = ExperimentalPipelineService();
  final OrchestratorExecutionEngine _engine =
      const OrchestratorExecutionEngine();
  ExperimentalPipelineType _selectedType =
      ExperimentalPipelineType.realtimeAnalysis;
  List<ExperimentalPipelineRun> _runs = const [];
  OrchestratorSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _refreshSnapshot();
  }

  Future<void> _startPipeline() async {
    final run = await _service.startPipeline(
      pipelineType: _selectedType,
      processedSamples: 24,
      persist: false,
    );
    setState(() => _runs = [run, ..._runs]);
    _refreshSnapshot();
  }

  Future<void> _stopPipeline() async {
    final run = await _service.stopPipeline(
      pipelineType: _selectedType,
      persist: false,
    );
    setState(() => _runs = [run, ..._runs]);
    _refreshSnapshot();
  }

  Future<void> _executeWorkflow() async {
    final runs = await _service.executeWorkflow(
      workflow: _workflow(),
      processedSamples: 32,
      persist: false,
    );
    setState(() => _runs = [...runs.reversed, ..._runs]);
    _refreshSnapshot();
  }

  void _executeRealtimeCycle() {
    final run = _engine.executeRealtimeCycle();
    setState(() => _runs = [run, ..._runs]);
    _refreshSnapshot();
  }

  void _executeReplayCycle() {
    final run = _engine.executeReplayCycle(replayedSamples: 48);
    setState(() => _runs = [run, ..._runs]);
    _refreshSnapshot();
  }

  void _refreshSnapshot() {
    setState(() => _snapshot = _service.generatePipelineSnapshot());
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final latest = _runs.isEmpty ? null : _runs.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Research Orchestrator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'orquestração experimental; pipeline experimental; não monitoramento clínico.',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ExperimentalPipelineType>(
            initialValue: _selectedType,
            decoration: const InputDecoration(labelText: 'Pipeline'),
            items: ExperimentalPipelineType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.name)),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedType = value);
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _startPipeline,
                child: const Text('Start pipeline'),
              ),
              OutlinedButton(
                onPressed: _stopPipeline,
                child: const Text('Stop pipeline'),
              ),
              FilledButton.tonal(
                onPressed: _executeWorkflow,
                child: const Text('Run workflow'),
              ),
              OutlinedButton(
                onPressed: _executeRealtimeCycle,
                child: const Text('Realtime cycle'),
              ),
              OutlinedButton(
                onPressed: _executeReplayCycle,
                child: const Text('Replay cycle'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricTile(
            title: 'Active pipelines',
            value: '${snapshot?.activePipelines ?? 0}',
            subtitle: 'execução controlada',
          ),
          _MetricTile(
            title: 'Duration',
            value: latest == null
                ? '-'
                : '${latest.executionDuration.inMilliseconds}ms',
            subtitle: 'coordenação de análise',
          ),
          _MetricTile(
            title: 'Forecasts generated',
            value: '${snapshot?.totalForecasts ?? 0}',
            subtitle: 'pipeline experimental',
          ),
          _MetricTile(
            title: 'Insights generated',
            value: '${snapshot?.totalInsights ?? 0}',
            subtitle: 'processamento longitudinal',
          ),
          _MetricTile(
            title: 'Markers generated',
            value: '${snapshot?.totalMarkers ?? 0}',
            subtitle: snapshot?.summaryFactors.join(', ') ?? 'sem snapshot',
          ),
          _MetricTile(
            title: 'Health score',
            value: snapshot?.healthScore.toStringAsFixed(0) ?? '-',
            subtitle: snapshot?.safetyCopy ?? 'execução controlada',
          ),
          const SizedBox(height: 8),
          for (final run in _runs.take(8))
            Card(
              child: ListTile(
                title: Text(run.pipelineType.name),
                subtitle: Text(
                  '${run.processedSamples} samples, ${run.generatedForecasts} forecasts, ${run.generatedInsights} insights',
                ),
                trailing: Icon(
                  run.success ? Icons.check_circle : Icons.error_outline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(value),
      ),
    );
  }
}

OrchestratorWorkflow _workflow() {
  return const OrchestratorWorkflow(
    workflowId: 'debug-synthetic-workflow',
    title: 'Synthetic workflow',
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
