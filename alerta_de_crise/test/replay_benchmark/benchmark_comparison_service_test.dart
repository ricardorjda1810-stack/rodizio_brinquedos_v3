import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/replay_benchmark/benchmark_comparison_service.dart';

void main() {
  group('BenchmarkComparisonService', () {
    const service = BenchmarkComparisonService();

    test('compares forecasts', () {
      final comparison = service.compareForecasts(
        baselineForecasts: const [20, 40, 60],
        candidateForecasts: const [22, 38, 61],
      );

      expect(comparison.label, 'forecast comparison');
      expect(comparison.candidateScore, greaterThan(95));
      expect(comparison.factors, contains('comparação de inferência'));
    });

    test('compares recovery', () {
      final comparison = service.compareRecovery(
        baselineRecovery: const [90, 80, 70],
        candidateRecovery: const [88, 78, 72],
      );

      expect(comparison.label, 'recovery comparison');
      expect(comparison.candidateScore, greaterThan(95));
      expect(comparison.factors, contains('análise comparativa'));
    });

    test('compares confidence and fusion strategies', () {
      final confidence = service.compareConfidence(
        strictConfidence: const [80, 82, 81],
        relaxedConfidence: const [78, 86, 82],
      );
      final fusion = service.compareFusionStrategies(
        baselineAgreement: const [80, 82, 84],
        candidateAgreement: const [86, 88, 90],
      );

      expect(confidence.candidateScore, greaterThan(90));
      expect(fusion.candidateScore, greaterThan(fusion.baselineScore));
      expect(fusion.factors, contains('comparação de replay'));
    });
  });
}
