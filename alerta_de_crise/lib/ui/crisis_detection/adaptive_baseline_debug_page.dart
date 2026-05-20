import 'package:flutter/material.dart';

import '../../adaptive_baseline/adaptive_baseline_models.dart';
import '../../adaptive_baseline/adaptive_baseline_service.dart';
import '../../adaptive_baseline/adaptive_baseline_statistics.dart';
import '../../adaptive_baseline/circadian_profile.dart';
import '../../core/crisis_detection/physiological_sample.dart';

class AdaptiveBaselineDebugPage extends StatefulWidget {
  const AdaptiveBaselineDebugPage({super.key});

  @override
  State<AdaptiveBaselineDebugPage> createState() =>
      _AdaptiveBaselineDebugPageState();
}

class _AdaptiveBaselineDebugPageState extends State<AdaptiveBaselineDebugPage> {
  final AdaptiveBaselineService _service = AdaptiveBaselineService();
  AdaptiveBaselineProfile? _baseline;
  AdaptiveBaselineStatistics? _statistics;

  @override
  Widget build(BuildContext context) {
    final baseline = _baseline;
    final statistics = _statistics;

    return Scaffold(
      appBar: AppBar(title: const Text('Adaptive Baseline debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Baseline fisiológico adaptativo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ferramenta interna para testar perfis circadianos e atualização gradual do padrão fisiológico. Não realiza diagnóstico.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _recalculateBaseline,
                child: const Text('Recalcular baseline'),
              ),
              FilledButton.tonal(
                onPressed: baseline == null ? null : _simulateNewEveningSample,
                child: const Text('Simular novo horário'),
              ),
            ],
          ),
          if (baseline != null) ...[
            const SizedBox(height: 16),
            _SummaryCard(baseline: baseline, statistics: statistics),
            const SizedBox(height: 16),
            for (final profile in baseline.circadianProfiles)
              _ProfileCard(profile: profile),
          ],
        ],
      ),
    );
  }

  void _recalculateBaseline() {
    final samples = _simulatedHistory();
    setState(() {
      _baseline = _service.buildAdaptiveBaseline(samples: samples);
      _statistics = AdaptiveBaselineStatistics.fromSamples(samples);
    });
  }

  void _simulateNewEveningSample() {
    final current = _baseline;
    if (current == null) {
      return;
    }

    final updated = _service.updateWithNewSample(
      current: current,
      sample: PhysiologicalSample(
        timestamp: DateTime(2026, 5, 17, 19),
        heartRateBpm: 86,
        hrvRmssdMs: 34,
        respiratoryRate: 18,
        movementIntensity: 0.2,
      ),
    );

    setState(() => _baseline = updated);
  }

  List<PhysiologicalSample> _simulatedHistory() {
    return [
      _sample(hour: 6, heartRate: 66, hrv: 48),
      _sample(hour: 7, heartRate: 68, hrv: 46),
      _sample(hour: 9, heartRate: 72, hrv: 42),
      _sample(hour: 10, heartRate: 74, hrv: 41),
      _sample(hour: 14, heartRate: 78, hrv: 38),
      _sample(hour: 15, heartRate: 80, hrv: 37),
      _sample(hour: 19, heartRate: 82, hrv: 36),
      _sample(hour: 20, heartRate: 84, hrv: 35),
      _sample(hour: 23, heartRate: 70, hrv: 44),
      _sample(hour: 2, heartRate: 62, hrv: 52),
    ];
  }

  PhysiologicalSample _sample({
    required int hour,
    required double heartRate,
    required double hrv,
  }) {
    return PhysiologicalSample(
      timestamp: DateTime(2026, 5, 17, hour),
      heartRateBpm: heartRate,
      hrvRmssdMs: hrv,
      respiratoryRate: 16,
      movementIntensity: 0.15,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.baseline, required this.statistics});

  final AdaptiveBaselineProfile baseline;
  final AdaptiveBaselineStatistics? statistics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _Line(
              label: 'FC global',
              value: baseline.globalBaseline.restingHeartRateBpm
                  .toStringAsFixed(1),
            ),
            _Line(
              label: 'HRV global',
              value: baseline.globalBaseline.hrvRmssdMs.toStringAsFixed(1),
            ),
            _Line(label: 'Samples', value: '${baseline.totalSamples}'),
            _Line(
              label: 'Estabilidade',
              value: statistics?.stabilityScore.toStringAsFixed(1) ?? 'n/a',
            ),
            _Line(
              label: 'Tendência FC',
              value: statistics?.heartRateTrend.toStringAsFixed(1) ?? 'n/a',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final CircadianProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.window.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _Line(
              label: 'FC média',
              value: profile.averageHeartRate.toStringAsFixed(1),
            ),
            _Line(
              label: 'HRV média',
              value: profile.averageHrv?.toStringAsFixed(1) ?? 'n/a',
            ),
            _Line(
              label: 'Respiração média',
              value:
                  profile.averageRespiratoryRate?.toStringAsFixed(1) ?? 'n/a',
            ),
            _Line(label: 'Samples', value: '${profile.sampleCount}'),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Text(value),
        ],
      ),
    );
  }
}
