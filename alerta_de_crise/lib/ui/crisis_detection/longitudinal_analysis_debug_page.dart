import 'package:flutter/material.dart';

import '../../autonomic_recovery/autonomic_recovery_models.dart';
import '../../contextual_triggers/contextual_event.dart';
import '../../longitudinal_analysis/cohort_analysis_service.dart';
import '../../longitudinal_analysis/longitudinal_analysis_models.dart';
import '../../longitudinal_analysis/physiological_evolution_models.dart';
import '../../physiological_trends/physiological_trend_models.dart';
import '../../physiological_trends/trend_window.dart';
import '../../predictive_forecasting/physiological_forecast_window.dart';
import '../../predictive_forecasting/predictive_forecast_models.dart';
import '../../session_timeline/session_timeline_models.dart';

class LongitudinalAnalysisDebugPage extends StatefulWidget {
  const LongitudinalAnalysisDebugPage({super.key});

  @override
  State<LongitudinalAnalysisDebugPage> createState() =>
      _LongitudinalAnalysisDebugPageState();
}

class _LongitudinalAnalysisDebugPageState
    extends State<LongitudinalAnalysisDebugPage> {
  final _service = CohortAnalysisService();

  List<SessionTimeline> _sessions = const [];
  List<PhysiologicalTrend> _trends = const [];
  List<AutonomicRecoveryProfile> _recovery = const [];
  List<EscalationForecast> _forecasts = const [];
  List<ContextualEvent> _contexts = const [];
  CohortAnalysisResult? _cohort;
  PhysiologicalEvolutionProfile? _profile;
  List<String> _insights = const [];

  @override
  void initState() {
    super.initState();
    _simulateStableEvolution();
  }

  Future<void> _simulateStableEvolution() async {
    final now = DateTime.now();
    _sessions = [
      _session('s1', now.subtract(const Duration(days: 14)), 72, 40),
      _session('s2', now.subtract(const Duration(days: 7)), 71, 41),
      _session('s3', now.subtract(const Duration(days: 1)), 70, 42),
    ];
    _trends = [
      _trend(now.subtract(const Duration(days: 14)), 40),
      _trend(now.subtract(const Duration(days: 7)), 36),
      _trend(now.subtract(const Duration(days: 1)), 32),
    ];
    _recovery = [
      _recoveryProfile(now.subtract(const Duration(days: 14)), 0.48, 54),
      _recoveryProfile(now.subtract(const Duration(days: 7)), 0.56, 62),
      _recoveryProfile(now.subtract(const Duration(days: 1)), 0.64, 70),
    ];
    _forecasts = [_forecast(now.subtract(const Duration(days: 1)), 34, 42)];
    _contexts = [
      _context(now.subtract(const Duration(days: 14)), ContextualCategory.work),
      _context(now.subtract(const Duration(days: 7)), ContextualCategory.work),
      _context(now.subtract(const Duration(days: 1)), ContextualCategory.work),
    ];
    await _recalculate();
  }

  Future<void> _simulateVariableEvolution() async {
    final now = DateTime.now();
    _sessions = [
      _session('s1', now.subtract(const Duration(days: 14)), 68, 46),
      _session('s2', now.subtract(const Duration(days: 7)), 78, 34),
      _session('s3', now.subtract(const Duration(days: 1)), 86, 28),
    ];
    _trends = [
      _trend(now.subtract(const Duration(days: 14)), 38),
      _trend(now.subtract(const Duration(days: 7)), 58),
      _trend(now.subtract(const Duration(days: 1)), 76),
    ];
    _recovery = [
      _recoveryProfile(now.subtract(const Duration(days: 14)), 0.62, 70),
      _recoveryProfile(now.subtract(const Duration(days: 7)), 0.44, 48),
      _recoveryProfile(now.subtract(const Duration(days: 1)), 0.32, 34),
    ];
    _forecasts = [_forecast(now.subtract(const Duration(days: 1)), 72, 78)];
    _contexts = [
      _context(now.subtract(const Duration(days: 14)), ContextualCategory.work),
      _context(now.subtract(const Duration(days: 7)), ContextualCategory.noise),
      _context(
        now.subtract(const Duration(days: 1)),
        ContextualCategory.conflict,
      ),
    ];
    await _recalculate();
  }

  Future<void> _recalculate() async {
    final cohort = await _service.generateCohortAnalysis(
      sessions: _sessions,
      trends: _trends,
      recoveryProfiles: _recovery,
      forecasts: _forecasts,
      contextEvents: _contexts,
    );
    final profile = _service.generateEvolutionProfile(
      sessions: _sessions,
      trends: _trends,
      recoveryProfiles: _recovery,
      forecasts: _forecasts,
    );
    setState(() {
      _cohort = cohort;
      _profile = profile;
      _insights = _service.generateEvolutionInsights(
        cohort: cohort,
        profile: profile,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cohort = _cohort;
    final profile = _profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Longitudinal Analysis')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Análise experimental de tendência longitudinal: mudanças '
            'observadas, estabilidade fisiológica, variação contextual e '
            'padrões ao longo do tempo não representam diagnóstico.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _simulateStableEvolution,
                child: const Text('Simular estabilidade'),
              ),
              OutlinedButton(
                onPressed: _simulateVariableEvolution,
                child: const Text('Simular variação'),
              ),
              FilledButton(
                onPressed: _recalculate,
                child: const Text('Recalcular'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (cohort != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cohort',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('Compared sessions: ${cohort.comparedSessions}'),
                    Text(
                      'Stability score: ${cohort.stabilityScore.toStringAsFixed(1)}',
                    ),
                    Text(
                      'Variability: ${cohort.variabilityScore.toStringAsFixed(1)}',
                    ),
                    Text(
                      'Circadian consistency: ${cohort.contextualConsistency.toStringAsFixed(1)}',
                    ),
                    Text(
                      'Confidence: ${cohort.longitudinalConfidence.toStringAsFixed(1)}',
                    ),
                  ],
                ),
              ),
            ),
          if (profile != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evolution',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('Resilience trend: ${profile.resilienceTrend.name}'),
                    Text('Recovery trend: ${profile.recoveryTrend.name}'),
                    Text('Escalation trend: ${profile.escalationTrend.name}'),
                    Text(
                      'Autonomic load trend: ${profile.autonomicLoadTrend.name}',
                    ),
                    Text(
                      'Circadian stability: ${profile.circadianStabilityTrend.name}',
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Insights', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final insight in _insights)
            Card(child: ListTile(title: Text(insight))),
        ],
      ),
    );
  }

  SessionTimeline _session(
    String id,
    DateTime startedAt,
    double hr,
    double hrv,
  ) {
    return SessionTimeline(
      id: id,
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(minutes: 30)),
      totalSamples: 120,
      totalEvents: 4,
      averageHeartRate: hr,
      averageHrv: hrv,
      maxHeartRate: hr + 18,
      minHrv: hrv - 8,
    );
  }

  PhysiologicalTrend _trend(DateTime generatedAt, int score) {
    return PhysiologicalTrend(
      averageHeartRate: 70 + score * 0.1,
      averageHrv: 44 - score * 0.12,
      hrvSlope: -0.2,
      heartRateSlope: 0.3,
      activationDensity: score / 100,
      escalationScore: score,
      generatedAt: generatedAt,
      window: TrendWindow.longTerm,
    );
  }

  AutonomicRecoveryProfile _recoveryProfile(
    DateTime generatedAt,
    double recoveryRate,
    int resilience,
  ) {
    return AutonomicRecoveryProfile(
      recoveryRate: recoveryRate,
      hrvRecoverySlope: 0.2,
      heartRateNormalization: recoveryRate,
      baselineReturnTime: const Duration(minutes: 18),
      resilienceScore: resilience,
      fatigueScore: 100 - resilience,
      stressCarryover: (100 - resilience) / 100,
      generatedAt: generatedAt,
      resilienceLevel: AutonomicResilienceLevel.stable,
    );
  }

  EscalationForecast _forecast(
    DateTime generatedAt,
    double probability,
    double load,
  ) {
    return EscalationForecast(
      id: 'forecast-${generatedAt.microsecondsSinceEpoch}',
      generatedAt: generatedAt,
      forecastWindow: PhysiologicalForecastWindow.nearFuture,
      escalationProbability: probability,
      forecastConfidence: const ForecastConfidenceResult(
        score: 70,
        level: ForecastConfidenceLevel.mediumConfidence,
        factors: ['debug'],
      ),
      escalationRiskLevel: ForecastRiskLevel.moderate,
      contributingFactors: const ['tendência longitudinal'],
      recoveryProtection: 50,
      autonomicLoad: load,
    );
  }

  ContextualEvent _context(DateTime timestamp, ContextualCategory category) {
    return ContextualEvent(
      id: 'context-${timestamp.microsecondsSinceEpoch}',
      timestamp: timestamp,
      category: category,
      label: category.name,
      description: 'Contexto simulado para variação contextual.',
      intensity: ContextualIntensity.medium,
      source: 'debug',
    );
  }
}
