import 'package:flutter/material.dart';

import '../../autonomic_recovery/autonomic_recovery_models.dart';
import '../../contextual_triggers/contextual_event.dart';
import '../../contextual_triggers/contextual_trigger_models.dart';
import '../../experimental_insights/contextual_insight_service.dart';
import '../../experimental_insights/experimental_insight_models.dart';
import '../../experimental_insights/longitudinal_summary_service.dart';
import '../../experimental_insights/physiological_insight_service.dart';
import '../../longitudinal_analysis/longitudinal_analysis_models.dart';
import '../../physiological_trends/physiological_trend_models.dart';
import '../../physiological_trends/trend_window.dart';
import '../../predictive_forecasting/physiological_forecast_window.dart';
import '../../predictive_forecasting/predictive_forecast_models.dart';

class ExperimentalInsightsDebugPage extends StatefulWidget {
  const ExperimentalInsightsDebugPage({super.key});

  @override
  State<ExperimentalInsightsDebugPage> createState() =>
      _ExperimentalInsightsDebugPageState();
}

class _ExperimentalInsightsDebugPageState
    extends State<ExperimentalInsightsDebugPage> {
  final PhysiologicalInsightService _physiologicalService =
      PhysiologicalInsightService();
  final ContextualInsightService _contextualService =
      ContextualInsightService();
  final LongitudinalSummaryService _summaryService =
      const LongitudinalSummaryService();
  List<ExperimentalPhysiologicalInsight> _insights = const [];
  ExperimentalInsightSummary? _summary;

  @override
  void initState() {
    super.initState();
    _recalculateInsights();
  }

  Future<void> _recalculateInsights() async {
    final trends = _mockTrends();
    final recovery = _mockRecovery();
    final forecasts = _mockForecasts();
    final cohort = _mockCohort();
    final contextual = _contextualService.generateContextualInsights(
      correlations: _mockCorrelations(),
      forecasts: forecasts,
      recoveryProfiles: recovery,
    );
    final physiological = _physiologicalService.generateInsights(
      trends: trends,
      recoveryProfiles: recovery,
      forecasts: forecasts,
      cohortAnalyses: cohort,
    );
    final insights = [...physiological, ...contextual];
    await _physiologicalService.persistInsights(insights);
    setState(() {
      _insights = insights;
      _summary = _summaryService.generateWeeklySummary(insights: insights);
    });
  }

  void _generateSummary() {
    setState(() {
      _summary = _summaryService.generateLongitudinalSummary(
        insights: _insights,
        cohortAnalyses: _mockCohort(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Experimental Insights')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'insight experimental; não representa diagnóstico; baseado em padrões observados.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _recalculateInsights,
                child: const Text('Recalculate insights'),
              ),
              FilledButton.tonal(
                onPressed: _generateSummary,
                child: const Text('Generate summary'),
              ),
              OutlinedButton(
                onPressed: _recalculateInsights,
                child: const Text('Simulate context'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_summary != null)
            Card(
              child: ListTile(
                title: Text(_summary!.title),
                subtitle: Text(_summary!.summary),
                trailing: Text(_summary!.confidence.toStringAsFixed(0)),
              ),
            ),
          const SizedBox(height: 8),
          for (final insight in _insights)
            Card(
              child: ListTile(
                title: Text(insight.title),
                subtitle: Text(
                  '${insight.summary}\n${insight.contributingFactors.join(', ')}',
                ),
                trailing: Text(insight.confidence.toStringAsFixed(0)),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }
}

List<PhysiologicalTrend> _mockTrends() {
  return [
    PhysiologicalTrend(
      averageHeartRate: 88,
      averageHrv: 31,
      hrvSlope: -4,
      heartRateSlope: 7,
      activationDensity: 64,
      escalationScore: 68,
      generatedAt: DateTime.now(),
      window: TrendWindow.shortTerm,
    ),
    PhysiologicalTrend(
      averageHeartRate: 92,
      averageHrv: 28,
      hrvSlope: -3,
      heartRateSlope: 5,
      activationDensity: 61,
      escalationScore: 66,
      generatedAt: DateTime.now(),
      window: TrendWindow.mediumTerm,
    ),
  ];
}

List<AutonomicRecoveryProfile> _mockRecovery() {
  return [
    AutonomicRecoveryProfile(
      recoveryRate: 42,
      hrvRecoverySlope: 1,
      heartRateNormalization: 45,
      baselineReturnTime: const Duration(minutes: 35),
      resilienceScore: 48,
      fatigueScore: 66,
      stressCarryover: 62,
      generatedAt: DateTime.now(),
      resilienceLevel: AutonomicResilienceLevel.fatigued,
    ),
  ];
}

List<EscalationForecast> _mockForecasts() {
  return [
    EscalationForecast(
      id: 'debug-forecast',
      generatedAt: DateTime.now(),
      forecastWindow: PhysiologicalForecastWindow.nearFuture,
      escalationProbability: 72,
      forecastConfidence: const ForecastConfidenceResult(
        score: 68,
        level: ForecastConfidenceLevel.mediumConfidence,
        factors: ['debug'],
      ),
      escalationRiskLevel: ForecastRiskLevel.elevated,
      contributingFactors: const ['tendência fisiológica'],
      recoveryProtection: 28,
      autonomicLoad: 74,
    ),
  ];
}

List<ContextualTriggerCorrelation> _mockCorrelations() {
  return [
    ContextualTriggerCorrelation(
      category: ContextualCategory.work,
      occurrenceCount: 3,
      escalationCorrelation: 68,
      recoveryImpact: -12,
      confidence: 62,
      lastOccurrence: DateTime.now(),
      associatedMarkers: const [],
    ),
  ];
}

List<CohortAnalysisResult> _mockCohort() {
  return [
    CohortAnalysisResult(
      id: 'debug-cohort',
      generatedAt: DateTime.now(),
      comparedSessions: 4,
      averageRecoveryEfficiency: 55,
      averageEscalationProbability: 58,
      averageResilience: 52,
      stabilityScore: 48,
      variabilityScore: 62,
      contextualConsistency: 57,
      longitudinalConfidence: 66,
    ),
  ];
}
