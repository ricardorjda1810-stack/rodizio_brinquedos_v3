import 'physiological_forecast_window.dart';

enum ForecastRiskLevel { low, moderate, elevated, high }

enum ForecastConfidenceLevel { lowConfidence, mediumConfidence, highConfidence }

class ForecastConfidenceResult {
  final int score;
  final ForecastConfidenceLevel level;
  final List<String> factors;

  const ForecastConfidenceResult({
    required this.score,
    required this.level,
    required this.factors,
  });
}

class EscalationForecast {
  final String id;
  final DateTime generatedAt;
  final PhysiologicalForecastWindow forecastWindow;
  final double escalationProbability;
  final ForecastConfidenceResult forecastConfidence;
  final ForecastRiskLevel escalationRiskLevel;
  final List<String> contributingFactors;
  final double recoveryProtection;
  final double autonomicLoad;

  const EscalationForecast({
    required this.id,
    required this.generatedAt,
    required this.forecastWindow,
    required this.escalationProbability,
    required this.forecastConfidence,
    required this.escalationRiskLevel,
    required this.contributingFactors,
    required this.recoveryProtection,
    required this.autonomicLoad,
  });

  String get safetyCopy =>
      'previsão experimental: não é diagnóstico e não representa garantia de crise.';
}
