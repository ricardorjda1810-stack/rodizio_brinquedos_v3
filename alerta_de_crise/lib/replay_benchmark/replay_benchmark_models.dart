class ReplayBenchmarkResult {
  final String id;
  final DateTime createdAt;
  final String sessionId;
  final String replayScenario;
  final double forecastConsistency;
  final double recoveryConsistency;
  final double escalationDetectionRate;
  final double falseEscalationRate;
  final double multimodalAgreement;
  final double confidenceConsistency;
  final double benchmarkScore;

  const ReplayBenchmarkResult({
    required this.id,
    required this.createdAt,
    required this.sessionId,
    required this.replayScenario,
    required this.forecastConsistency,
    required this.recoveryConsistency,
    required this.escalationDetectionRate,
    required this.falseEscalationRate,
    required this.multimodalAgreement,
    required this.confidenceConsistency,
    required this.benchmarkScore,
  });

  String get safetyCopy =>
      'benchmark experimental e comparação experimental; não representa validação clínica.';
}

class BenchmarkStrategyComparison {
  final String label;
  final double baselineScore;
  final double candidateScore;
  final double delta;
  final List<String> factors;

  const BenchmarkStrategyComparison({
    required this.label,
    required this.baselineScore,
    required this.candidateScore,
    required this.delta,
    required this.factors,
  });
}
