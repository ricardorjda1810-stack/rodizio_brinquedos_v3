import 'replay_benchmark_models.dart';
import 'replay_validation_metrics.dart';

class BenchmarkComparisonService {
  final ReplayValidationMetrics _metrics;

  const BenchmarkComparisonService({
    ReplayValidationMetrics metrics = const ReplayValidationMetrics(),
  }) : _metrics = metrics;

  BenchmarkStrategyComparison compareForecasts({
    required List<double> baselineForecasts,
    required List<double> candidateForecasts,
  }) {
    return _compare(
      label: 'forecast comparison',
      baselineScore: _metrics.forecastAgreement(
        baselineForecasts,
        baselineForecasts,
      ),
      candidateScore: _metrics.forecastAgreement(
        baselineForecasts,
        candidateForecasts,
      ),
      factors: const ['comparação de inferência', 'forecast sensitivity'],
    );
  }

  BenchmarkStrategyComparison compareRecovery({
    required List<double> baselineRecovery,
    required List<double> candidateRecovery,
  }) {
    return _compare(
      label: 'recovery comparison',
      baselineScore: _metrics.recoveryAgreement(
        baselineRecovery,
        baselineRecovery,
      ),
      candidateScore: _metrics.recoveryAgreement(
        baselineRecovery,
        candidateRecovery,
      ),
      factors: const ['análise comparativa', 'recovery sensitivity'],
    );
  }

  BenchmarkStrategyComparison compareConfidence({
    required List<double> strictConfidence,
    required List<double> relaxedConfidence,
  }) {
    return _compare(
      label: 'confidence comparison',
      baselineScore: _metrics.confidenceStability(strictConfidence),
      candidateScore: _metrics.confidenceStability(relaxedConfidence),
      factors: const ['confidence strict vs relaxed'],
    );
  }

  BenchmarkStrategyComparison compareFusionStrategies({
    required List<double> baselineAgreement,
    required List<double> candidateAgreement,
  }) {
    return _compare(
      label: 'multimodal weighting comparison',
      baselineScore: _metrics.multimodalConsistency(baselineAgreement),
      candidateScore: _metrics.multimodalConsistency(candidateAgreement),
      factors: const ['multimodal weighting', 'comparação de replay'],
    );
  }

  BenchmarkStrategyComparison _compare({
    required String label,
    required double baselineScore,
    required double candidateScore,
    required List<String> factors,
  }) {
    return BenchmarkStrategyComparison(
      label: label,
      baselineScore: baselineScore,
      candidateScore: candidateScore,
      delta: candidateScore - baselineScore,
      factors: factors,
    );
  }
}
