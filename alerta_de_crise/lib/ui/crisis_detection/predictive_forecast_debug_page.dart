import 'package:flutter/material.dart';

import '../../autonomic_recovery/autonomic_recovery_models.dart';
import '../../physiological_trends/physiological_trend_models.dart';
import '../../physiological_trends/trend_window.dart';
import '../../predictive_forecasting/escalation_forecast_service.dart';
import '../../predictive_forecasting/predictive_forecast_models.dart';
import '../../sensor_quality/sensor_confidence_score.dart';
import '../../session_timeline/session_timeline_models.dart';

class PredictiveForecastDebugPage extends StatefulWidget {
  const PredictiveForecastDebugPage({super.key});

  @override
  State<PredictiveForecastDebugPage> createState() =>
      _PredictiveForecastDebugPageState();
}

class _PredictiveForecastDebugPageState
    extends State<PredictiveForecastDebugPage> {
  final _service = EscalationForecastService();
  EscalationForecast? _forecast;

  @override
  void initState() {
    super.initState();
    _simulateLowProbability();
  }

  Future<void> _simulateLowProbability() async {
    final now = DateTime.now();
    final forecast = await _service.generateForecast(
      trends: [
        _trend(now.subtract(const Duration(minutes: 20)), 18, 0.08, 0.1, -0.05),
        _trend(now, 22, 0.12, 0.08, -0.04),
      ],
      recoveryProfiles: [_recovery(now, 0.86, 82, 12, 0.08)],
      confidenceScores: [_confidence(88, hasArtifacts: false)],
      timelines: [_timeline(now, samples: 64)],
    );
    if (mounted) {
      setState(() => _forecast = forecast);
    }
  }

  Future<void> _simulateElevatedProbability() async {
    final now = DateTime.now();
    final forecast = await _service.generateForecast(
      trends: [
        _trend(now.subtract(const Duration(minutes: 30)), 48, 0.35, 0.44, -0.3),
        _trend(now.subtract(const Duration(minutes: 15)), 68, 0.58, 0.62, -0.4),
        _trend(now, 82, 0.74, 0.78, -0.5),
      ],
      recoveryProfiles: [_recovery(now, 0.24, 36, 76, 0.72)],
      confidenceScores: [_confidence(72, hasArtifacts: false)],
      timelines: [_timeline(now, samples: 42)],
    );
    if (mounted) {
      setState(() => _forecast = forecast);
    }
  }

  Future<void> _simulateLowConfidence() async {
    final now = DateTime.now();
    final forecast = await _service.generateForecast(
      trends: [_trend(now, 52, 0.36, 0.3, -0.22)],
      recoveryProfiles: [_recovery(now, 0.48, 52, 46, 0.4)],
      confidenceScores: [_confidence(32, hasArtifacts: true)],
      timelines: [_timeline(now, samples: 4)],
      baselineStability: 38,
    );
    if (mounted) {
      setState(() => _forecast = forecast);
    }
  }

  @override
  Widget build(BuildContext context) {
    final forecast = _forecast;

    return Scaffold(
      appBar: AppBar(title: const Text('Predictive Forecast')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Previsão experimental de tendência autonômica: não é diagnóstico '
            'e não representa garantia de crise.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _simulateLowProbability,
                child: const Text('Baixa probabilidade'),
              ),
              OutlinedButton(
                onPressed: _simulateElevatedProbability,
                child: const Text('Escalada fisiológica'),
              ),
              OutlinedButton(
                onPressed: _simulateLowConfidence,
                child: const Text('Baixa confiança'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (forecast == null)
            const Center(child: CircularProgressIndicator())
          else ...[
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.9,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MetricTile(
                  label: 'Probabilidade',
                  value:
                      '${forecast.escalationProbability.toStringAsFixed(1)}%',
                ),
                _MetricTile(
                  label: 'Confiança',
                  value:
                      '${forecast.forecastConfidence.score}% ${forecast.forecastConfidence.level.name}',
                ),
                _MetricTile(
                  label: 'Risco',
                  value: forecast.escalationRiskLevel.name,
                ),
                _MetricTile(
                  label: 'Janela',
                  value: forecast.forecastWindow.label,
                ),
                _MetricTile(
                  label: 'Proteção recuperação',
                  value: forecast.recoveryProtection.toStringAsFixed(1),
                ),
                _MetricTile(
                  label: 'Carga autonômica',
                  value: forecast.autonomicLoad.toStringAsFixed(1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contributing factors',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final factor in forecast.contributingFactors)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('- $factor'),
                      ),
                    if (forecast.forecastConfidence.factors.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Confidence notes',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      for (final factor in forecast.forecastConfidence.factors)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('- $factor'),
                        ),
                    ],
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
    int escalationScore,
    double activationDensity,
    double heartRateSlope,
    double hrvSlope,
  ) {
    return PhysiologicalTrend(
      averageHeartRate: 72 + escalationScore * 0.25,
      averageHrv: 46 - escalationScore * 0.18,
      hrvSlope: hrvSlope,
      heartRateSlope: heartRateSlope,
      activationDensity: activationDensity,
      escalationScore: escalationScore,
      generatedAt: generatedAt,
      window: TrendWindow.shortTerm,
    );
  }

  AutonomicRecoveryProfile _recovery(
    DateTime generatedAt,
    double recoveryRate,
    int resilience,
    int fatigue,
    double carryover,
  ) {
    return AutonomicRecoveryProfile(
      recoveryRate: recoveryRate,
      hrvRecoverySlope: recoveryRate,
      heartRateNormalization: recoveryRate,
      baselineReturnTime: const Duration(minutes: 12),
      resilienceScore: resilience,
      fatigueScore: fatigue,
      stressCarryover: carryover,
      generatedAt: generatedAt,
      resilienceLevel: resilience >= 70
          ? AutonomicResilienceLevel.resilient
          : AutonomicResilienceLevel.fatigued,
    );
  }

  SensorConfidenceScore _confidence(int score, {required bool hasArtifacts}) {
    return SensorConfidenceScore(
      overallScore: score,
      rrQuality: score,
      hrQuality: score,
      movementConfidence: score,
      contactConfidence: score,
      hasArtifacts: hasArtifacts,
      warnings: hasArtifacts ? const ['artifact'] : const [],
    );
  }

  SessionTimeline _timeline(DateTime now, {required int samples}) {
    return SessionTimeline(
      id: 'debug-forecast',
      startedAt: now.subtract(const Duration(minutes: 20)),
      endedAt: now,
      totalSamples: samples,
      totalEvents: 0,
      averageHeartRate: 78,
      averageHrv: 38,
      maxHeartRate: 92,
      minHrv: 28,
    );
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
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
