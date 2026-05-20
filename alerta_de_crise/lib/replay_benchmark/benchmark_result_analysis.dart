import 'replay_benchmark_models.dart';

class BenchmarkResultAnalysis {
  const BenchmarkResultAnalysis();

  List<ReplayBenchmarkResult> rankResults(List<ReplayBenchmarkResult> results) {
    final ranked = [...results]
      ..sort((a, b) => b.benchmarkScore.compareTo(a.benchmarkScore));
    return List.unmodifiable(ranked);
  }

  double calculateInferenceStability(List<ReplayBenchmarkResult> results) {
    if (results.isEmpty) return 0;
    final average = _average(results.map((result) => result.benchmarkScore));
    final averageDelta = _average(
      results.map((result) => (result.benchmarkScore - average).abs()),
    );
    return (100 - averageDelta.clamp(0, 100)).toDouble();
  }

  List<String> generateBenchmarkSummary(List<ReplayBenchmarkResult> results) {
    if (results.isEmpty) {
      return const ['benchmark experimental sem resultados comparáveis.'];
    }
    final ranked = rankResults(results);
    final best = ranked.first;
    return [
      'benchmark experimental com ${results.length} comparação de replay.',
      'melhor cenário: ${best.replayScenario} (${best.benchmarkScore.toStringAsFixed(0)}).',
      'validação experimental baseada em comparação de inferência.',
    ];
  }

  List<String> generateReplayQualityInsights(ReplayBenchmarkResult result) {
    final insights = <String>[];
    if (result.forecastConsistency >= 80) {
      insights.add('forecast com alta consistência na análise comparativa.');
    }
    if (result.falseEscalationRate > 25) {
      insights.add('taxa de falsa escalada merece revisão experimental.');
    }
    if (result.multimodalAgreement >= 80) {
      insights.add('acordo multimodal consistente no replay experimental.');
    }
    return insights.isEmpty
        ? const ['resultado de benchmark experimental estável.']
        : insights;
  }

  double _average(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    final total = list.fold<double>(0, (sum, value) => sum + value);
    return total / list.length;
  }
}
