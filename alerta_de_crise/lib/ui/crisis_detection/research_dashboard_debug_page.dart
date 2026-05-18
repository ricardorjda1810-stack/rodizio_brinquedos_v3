import 'package:flutter/material.dart';

import '../../autonomic_recovery/autonomic_recovery_models.dart';
import '../../physiological_trends/physiological_trend_models.dart';
import '../../physiological_trends/trend_window.dart';
import '../../research_dashboard/research_dashboard_models.dart';
import '../../research_dashboard/research_dashboard_service.dart';
import '../../sensor_quality/sensor_confidence_score.dart';

class ResearchDashboardDebugPage extends StatefulWidget {
  const ResearchDashboardDebugPage({super.key});

  @override
  State<ResearchDashboardDebugPage> createState() =>
      _ResearchDashboardDebugPageState();
}

class _ResearchDashboardDebugPageState
    extends State<ResearchDashboardDebugPage> {
  final _service = ResearchDashboardService();
  ResearchDashboardSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _generateStableDashboard();
  }

  Future<void> _generateStableDashboard() async {
    final now = DateTime.now();
    final snapshot = await _service.generateDashboard(
      trends: [
        _trend(now.subtract(const Duration(minutes: 30)), 72, 44, 0.1, 18),
        _trend(now.subtract(const Duration(minutes: 15)), 76, 42, 0.18, 32),
        _trend(now, 74, 43, 0.14, 24),
      ],
      recoveryProfiles: [
        _recovery(now.subtract(const Duration(minutes: 20)), 0.72, 78, 18),
        _recovery(now, 0.82, 84, 14),
      ],
      confidenceScores: [_confidence(88), _confidence(82)],
    );

    if (mounted) {
      setState(() => _snapshot = snapshot);
    }
  }

  Future<void> _generateHighLoadDashboard() async {
    final now = DateTime.now();
    final snapshot = await _service.generateDashboard(
      trends: [
        _trend(now.subtract(const Duration(minutes: 30)), 82, 35, 0.35, 52),
        _trend(now.subtract(const Duration(minutes: 15)), 88, 31, 0.55, 68),
        _trend(now, 94, 28, 0.72, 82),
      ],
      recoveryProfiles: [
        _recovery(now.subtract(const Duration(minutes: 20)), 0.28, 44, 62),
        _recovery(now, 0.22, 38, 74),
      ],
      confidenceScores: [_confidence(66), _confidence(58)],
    );

    if (mounted) {
      setState(() => _snapshot = snapshot);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;

    return Scaffold(
      appBar: AppBar(title: const Text('Research Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Dashboard experimental para pesquisa/autoconhecimento. '
            'Não substitui avaliação médica.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _generateStableDashboard,
                child: const Text('Simular estável'),
              ),
              OutlinedButton(
                onPressed: _generateHighLoadDashboard,
                child: const Text('Simular carga alta'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (snapshot == null)
            const Center(child: CircularProgressIndicator())
          else ...[
            _MetricGrid(snapshot: snapshot),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Indicators',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Resumo: ${snapshot.insights.summaryLabel}'),
                    Text('Improving: ${snapshot.insights.improvingTrend}'),
                    Text('Worsening: ${snapshot.insights.worseningTrend}'),
                    Text('Recovery: ${snapshot.insights.recoveryTrend}'),
                    Text('Stable: ${!snapshot.insights.worseningTrend}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  PhysiologicalTrend _trend(
    DateTime generatedAt,
    double heartRate,
    double hrv,
    double activationDensity,
    int escalationScore,
  ) {
    return PhysiologicalTrend(
      averageHeartRate: heartRate,
      averageHrv: hrv,
      hrvSlope: -0.2,
      heartRateSlope: 0.4,
      activationDensity: activationDensity,
      escalationScore: escalationScore,
      generatedAt: generatedAt,
      window: TrendWindow.mediumTerm,
    );
  }

  AutonomicRecoveryProfile _recovery(
    DateTime generatedAt,
    double recoveryRate,
    int resilienceScore,
    int fatigueScore,
  ) {
    return AutonomicRecoveryProfile(
      recoveryRate: recoveryRate,
      hrvRecoverySlope: 0.6,
      heartRateNormalization: recoveryRate,
      baselineReturnTime: const Duration(minutes: 12),
      resilienceScore: resilienceScore,
      fatigueScore: fatigueScore,
      stressCarryover: fatigueScore / 100,
      generatedAt: generatedAt,
      resilienceLevel: resilienceScore >= 75
          ? AutonomicResilienceLevel.resilient
          : AutonomicResilienceLevel.fatigued,
    );
  }

  SensorConfidenceScore _confidence(int score) {
    return SensorConfidenceScore(
      overallScore: score,
      rrQuality: score,
      hrQuality: score,
      movementConfidence: score,
      contactConfidence: score,
      hasArtifacts: false,
      warnings: const [],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final ResearchDashboardSnapshot snapshot;

  const _MetricGrid({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final metrics = snapshot.metrics;
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _MetricTile(
          label: 'Average HR',
          value: _format(metrics.averageHeartRate),
        ),
        _MetricTile(label: 'Average HRV', value: _format(metrics.averageHrv)),
        _MetricTile(label: 'Escalations', value: '${metrics.escalationCount}'),
        _MetricTile(
          label: 'Recovery efficiency',
          value: metrics.recoveryEfficiency.toStringAsFixed(1),
        ),
        _MetricTile(label: 'Resilience', value: '${metrics.resilienceScore}'),
        _MetricTile(label: 'Fatigue', value: '${metrics.fatigueScore}'),
        _MetricTile(
          label: 'Activation density',
          value: metrics.activationDensity.toStringAsFixed(2),
        ),
        _MetricTile(
          label: 'Confidence média',
          value: metrics.averageConfidence.toStringAsFixed(1),
        ),
        _MetricTile(
          label: 'Autonomic load',
          value: snapshot.insights.autonomicLoad.toStringAsFixed(1),
        ),
      ],
    );
  }

  String _format(double? value) {
    return value == null ? '-' : value.toStringAsFixed(1);
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
