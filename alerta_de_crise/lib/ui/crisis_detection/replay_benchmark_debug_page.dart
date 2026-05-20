import 'package:flutter/material.dart';

import '../../replay_benchmark/benchmark_result_analysis.dart';
import '../../replay_benchmark/replay_benchmark_models.dart';
import '../../replay_benchmark/replay_benchmark_runner.dart';

class ReplayBenchmarkDebugPage extends StatefulWidget {
  const ReplayBenchmarkDebugPage({super.key});

  @override
  State<ReplayBenchmarkDebugPage> createState() =>
      _ReplayBenchmarkDebugPageState();
}

class _ReplayBenchmarkDebugPageState extends State<ReplayBenchmarkDebugPage> {
  final ReplayBenchmarkRunner _runner = ReplayBenchmarkRunner();
  final BenchmarkResultAnalysis _analysis = const BenchmarkResultAnalysis();
  ReplayBenchmarkResult? _result;
  String _selectedReplay = 'recorded-session-debug';
  bool _sideBySide = false;

  Future<void> _runBenchmark() async {
    final result = await _runner.runBenchmark(
      sessionId: _selectedReplay,
      replayScenario: _sideBySide ? 'side-by-side' : 'standard-replay',
      expectedForecasts: const [20, 35, 45, 40],
      replayForecasts: _sideBySide
          ? const [22, 34, 44, 41]
          : const [24, 39, 52, 43],
      expectedRecovery: const [82, 78, 74],
      replayRecovery: const [80, 77, 73],
      confidenceScores: const [84, 85, 83, 86],
      multimodalAgreementScores: const [80, 82, 84],
      falseEscalations: _sideBySide ? 0 : 1,
      totalReplays: 4,
    );
    setState(() => _result = result);
  }

  void _toggleSideBySide(bool value) {
    setState(() => _sideBySide = value);
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final insights = result == null
        ? const <String>['benchmark experimental aguardando execução.']
        : _analysis.generateReplayQualityInsights(result);

    return Scaffold(
      appBar: AppBar(title: const Text('Replay Benchmark')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'benchmark experimental; comparação experimental; não representa validação clínica.',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedReplay,
            decoration: const InputDecoration(labelText: 'Replay'),
            items: const [
              DropdownMenuItem(
                value: 'recorded-session-debug',
                child: Text('Recorded session debug'),
              ),
              DropdownMenuItem(
                value: 'synthetic-replay-debug',
                child: Text('Synthetic replay debug'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedReplay = value);
            },
          ),
          SwitchListTile(
            value: _sideBySide,
            onChanged: _toggleSideBySide,
            title: const Text('Replay side-by-side'),
            subtitle: const Text('comparação de replay'),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _runBenchmark,
                child: const Text('Run benchmark'),
              ),
              OutlinedButton(
                onPressed: _runBenchmark,
                child: const Text('Recalculate'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricTile(
            title: 'Forecast consistency',
            value: result?.forecastConsistency.toStringAsFixed(0) ?? '-',
            subtitle: 'comparação de inferência',
          ),
          _MetricTile(
            title: 'Recovery consistency',
            value: result?.recoveryConsistency.toStringAsFixed(0) ?? '-',
            subtitle: 'validação experimental',
          ),
          _MetricTile(
            title: 'Escalation detection',
            value: result?.escalationDetectionRate.toStringAsFixed(0) ?? '-',
            subtitle: 'análise comparativa',
          ),
          _MetricTile(
            title: 'False escalation rate',
            value: result?.falseEscalationRate.toStringAsFixed(0) ?? '-',
            subtitle: 'benchmark experimental',
          ),
          _MetricTile(
            title: 'Benchmark score',
            value: result?.benchmarkScore.toStringAsFixed(0) ?? '-',
            subtitle: result?.safetyCopy ?? 'comparação experimental',
          ),
          for (final insight in insights)
            Card(
              child: ListTile(
                title: const Text('Replay quality insight'),
                subtitle: Text(insight),
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
