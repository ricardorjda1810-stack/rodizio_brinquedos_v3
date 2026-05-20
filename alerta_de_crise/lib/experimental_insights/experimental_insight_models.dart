import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/physiological_event_marker.dart';

enum InsightType {
  escalationPattern,
  recoveryPattern,
  contextualPattern,
  circadianPattern,
  resiliencePattern,
  interventionPattern,
  longitudinalPattern,
  forecastPattern,
}

class ExperimentalPhysiologicalInsight {
  final String id;
  final DateTime generatedAt;
  final String title;
  final String summary;
  final double confidence;
  final InsightType insightType;
  final List<String> contributingFactors;
  final List<PhysiologicalEventMarker> relatedMarkers;
  final List<EscalationForecast> relatedForecasts;

  const ExperimentalPhysiologicalInsight({
    required this.id,
    required this.generatedAt,
    required this.title,
    required this.summary,
    required this.confidence,
    required this.insightType,
    required this.contributingFactors,
    this.relatedMarkers = const [],
    this.relatedForecasts = const [],
  });

  String get safetyCopy =>
      'insight experimental: não representa diagnóstico; baseado em padrões observados.';
}

class ExperimentalInsightSummary {
  final String title;
  final String summary;
  final DateTime generatedAt;
  final double confidence;
  final List<ExperimentalPhysiologicalInsight> insights;

  const ExperimentalInsightSummary({
    required this.title,
    required this.summary,
    required this.generatedAt,
    required this.confidence,
    required this.insights,
  });

  String get safetyCopy =>
      'interpretação experimental de padrões observados; não representa diagnóstico.';
}
