import 'package:flutter/material.dart';

import '../../calibration_lab/calibration_benchmark_service.dart';
import '../../calibration_lab/calibration_models.dart';
import '../../calibration_lab/calibration_profile.dart';
import '../../calibration_lab/calibration_result_analysis.dart';

class CalibrationLabDebugPage extends StatefulWidget {
  const CalibrationLabDebugPage({super.key});

  @override
  State<CalibrationLabDebugPage> createState() =>
      _CalibrationLabDebugPageState();
}

class _CalibrationLabDebugPageState extends State<CalibrationLabDebugPage> {
  final CalibrationBenchmarkService _benchmarkService =
      CalibrationBenchmarkService();
  final CalibrationResultAnalysis _analysis = const CalibrationResultAnalysis();
  final List<CalibrationProfile> _profiles = CalibrationProfiles.presets();
  List<CalibrationBenchmarkResult> _results = const [];
  CalibrationProfile? _selectedProfile = CalibrationProfiles.balanced;
  bool _running = false;

  Future<void> _runBenchmark() async {
    final profile = _selectedProfile;
    if (profile == null || _running) return;
    setState(() => _running = true);
    final result = await _benchmarkService.runCalibrationBenchmark(
      profile: profile,
      sessionId: 'calibration-debug-session',
    );
    setState(() {
      _results = [result, ..._results];
      _running = false;
    });
  }

  Future<void> _compareProfiles() async {
    if (_running) return;
    setState(() => _running = true);
    final results = await _benchmarkService.compareProfiles(
      profiles: _profiles,
      sessionId: 'calibration-debug-session',
    );
    setState(() {
      _results = results;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ranked = _analysis.rankResults(_results);
    final best = ranked.isEmpty ? null : ranked.first;
    final summary = _analysis.generateExperimentalSummary(_results);

    return Scaffold(
      appBar: AppBar(title: const Text('Calibration Lab')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'calibração experimental; não representa validação clínica; parâmetros usados apenas para pesquisa/autoconhecimento.',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedProfile?.id,
            decoration: const InputDecoration(labelText: 'Profile'),
            items: [
              for (final profile in _profiles)
                DropdownMenuItem(value: profile.id, child: Text(profile.name)),
            ],
            onChanged: (value) {
              setState(
                () => _selectedProfile = _profiles.firstWhere(
                  (profile) => profile.id == value,
                  orElse: () => CalibrationProfiles.balanced,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          if (_selectedProfile != null)
            _ProfileTile(profile: _selectedProfile!),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _running ? null : _runBenchmark,
                child: const Text('Run benchmark'),
              ),
              OutlinedButton(
                onPressed: _running ? null : _compareProfiles,
                child: const Text('Compare profiles'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricTile(
            title: 'Best profile',
            value: best?.profile.name ?? '-',
            subtitle: 'comparação de configuração',
          ),
          _MetricTile(
            title: 'Score',
            value: best?.benchmarkScore.toStringAsFixed(0) ?? '-',
            subtitle: 'benchmark de thresholds',
          ),
          _MetricTile(
            title: 'False escalation rate',
            value: best?.falseEscalationRate.toStringAsFixed(0) ?? '-',
            subtitle: 'validação offline',
          ),
          _MetricTile(
            title: 'Recovery consistency',
            value: best?.recoveryConsistency.toStringAsFixed(0) ?? '-',
            subtitle: 'ajuste de parâmetros',
          ),
          _MetricTile(
            title: 'Forecast consistency',
            value: best?.forecastConsistency.toStringAsFixed(0) ?? '-',
            subtitle: 'calibração experimental',
          ),
          for (final line in summary)
            Card(
              child: ListTile(
                title: const Text('Experimental summary'),
                subtitle: Text(line),
              ),
            ),
          for (final result in ranked)
            Card(
              child: ListTile(
                title: Text(result.profile.name),
                subtitle: Text(result.safetyCopy),
                trailing: Text(result.benchmarkScore.toStringAsFixed(0)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final CalibrationProfile profile;

  const _ProfileTile({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(profile.name),
        subtitle: Text(profile.description),
        trailing: Text(profile.escalationThreshold.toStringAsFixed(0)),
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
