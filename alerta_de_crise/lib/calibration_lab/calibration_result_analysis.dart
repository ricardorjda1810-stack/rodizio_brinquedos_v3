import 'calibration_models.dart';
import 'calibration_profile.dart';

class CalibrationResultAnalysis {
  const CalibrationResultAnalysis();

  List<CalibrationBenchmarkResult> rankResults(
    List<CalibrationBenchmarkResult> results,
  ) {
    final ranked = [...results]
      ..sort((a, b) => b.benchmarkScore.compareTo(a.benchmarkScore));
    return List.unmodifiable(ranked);
  }

  CalibrationProfile? detectMostStableProfile(
    List<CalibrationBenchmarkResult> results,
  ) {
    if (results.isEmpty) return null;
    final ranked = [...results]
      ..sort((a, b) => a.falseEscalationRate.compareTo(b.falseEscalationRate));
    return ranked.first.profile;
  }

  CalibrationProfile? detectMostSensitiveProfile(
    List<CalibrationBenchmarkResult> results,
  ) {
    if (results.isEmpty) return null;
    final ranked = [...results]
      ..sort(
        (a, b) => a.profile.escalationThreshold.compareTo(
          b.profile.escalationThreshold,
        ),
      );
    return ranked.first.profile;
  }

  double calculateFinalScore(CalibrationBenchmarkResult result) {
    final weighted =
        (result.benchmarkScore * 0.5) +
        (result.forecastConsistency * 0.18) +
        (result.recoveryConsistency * 0.16) +
        ((100 - result.falseEscalationRate) * 0.16);
    return weighted.clamp(0, 100).toDouble();
  }

  List<String> generateExperimentalSummary(
    List<CalibrationBenchmarkResult> results,
  ) {
    if (results.isEmpty) {
      return const [
        'calibração experimental sem comparação de configuração disponível.',
      ];
    }
    final ranked = rankResults(results);
    final best = ranked.first;
    final stable = detectMostStableProfile(results);
    return [
      'validação offline com ${results.length} perfis de ajuste de parâmetros.',
      'melhor perfil por benchmark de thresholds: ${best.profile.name}.',
      'perfil mais estável observado: ${stable?.name ?? best.profile.name}.',
    ];
  }
}
