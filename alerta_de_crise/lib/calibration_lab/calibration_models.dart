import 'calibration_profile.dart';

class CalibrationBenchmarkResult {
  final String id;
  final DateTime createdAt;
  final CalibrationProfile profile;
  final String sessionId;
  final double forecastConsistency;
  final double recoveryConsistency;
  final double falseEscalationRate;
  final double multimodalAgreement;
  final double confidenceConsistency;
  final double benchmarkScore;
  final int rankingPosition;

  const CalibrationBenchmarkResult({
    required this.id,
    required this.createdAt,
    required this.profile,
    required this.sessionId,
    required this.forecastConsistency,
    required this.recoveryConsistency,
    required this.falseEscalationRate,
    required this.multimodalAgreement,
    required this.confidenceConsistency,
    required this.benchmarkScore,
    required this.rankingPosition,
  });

  String get safetyCopy =>
      'calibração experimental; comparação de configuração; não representa validação clínica.';
}

class CalibrationProfileComparison {
  final CalibrationProfile profile;
  final double score;
  final double falseEscalationRate;
  final double recoveryConsistency;
  final double forecastConsistency;
  final List<String> factors;

  const CalibrationProfileComparison({
    required this.profile,
    required this.score,
    required this.falseEscalationRate,
    required this.recoveryConsistency,
    required this.forecastConsistency,
    required this.factors,
  });
}

class CalibrationThresholdComparison {
  final String label;
  final double baselineValue;
  final double candidateValue;
  final double delta;
  final String interpretation;

  const CalibrationThresholdComparison({
    required this.label,
    required this.baselineValue,
    required this.candidateValue,
    required this.delta,
    required this.interpretation,
  });
}
