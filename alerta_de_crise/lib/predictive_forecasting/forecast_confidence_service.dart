import '../adaptive_baseline/adaptive_baseline_models.dart';
import '../sensor_quality/sensor_confidence_score.dart';
import '../session_timeline/session_timeline_models.dart';
import 'predictive_forecast_models.dart';

class ForecastConfidenceService {
  const ForecastConfidenceService();

  ForecastConfidenceResult calculateConfidence({
    List<SensorConfidenceScore> confidenceScores = const [],
    List<SessionTimeline> timelines = const [],
    AdaptiveBaselineProfile? adaptiveBaseline,
    double baselineStability = 100,
  }) {
    final factors = <String>[];
    final sensorScore = _average(
      confidenceScores.map((score) => score.overallScore.toDouble()).toList(),
    );
    final artifactPenalty =
        confidenceScores
            .where((score) => score.hasArtifacts || score.warnings.isNotEmpty)
            .length *
        10;
    final sampleCount = timelines.fold<int>(
      0,
      (sum, timeline) => sum + timeline.totalSamples,
    );
    final dataScore = sampleCount >= 60
        ? 100
        : sampleCount >= 20
        ? 75
        : sampleCount >= 8
        ? 55
        : 30;
    final gapPenalty = _gapPenalty(timelines);
    final baselineScore = adaptiveBaseline == null
        ? 45
        : ((baselineStability * 0.7) +
                  (adaptiveBaseline.totalSamples >= 60
                      ? 30
                      : adaptiveBaseline.totalSamples >= 20
                      ? 20
                      : 10))
              .clamp(0, 100);

    if (sensorScore < 60 || artifactPenalty > 0) {
      factors.add('confiança do sensor reduzida ou artefatos detectados');
    }
    if (sampleCount < 20) {
      factors.add('quantidade de dados ainda limitada');
    }
    if (gapPenalty > 0) {
      factors.add('lacunas temporais reduzem a confiança da previsão');
    }
    if (baselineScore < 65) {
      factors.add('baseline adaptativo ainda pouco estável');
    }

    final score =
        (sensorScore * 0.36) +
        (dataScore * 0.28) +
        (baselineScore * 0.26) +
        10 -
        artifactPenalty -
        gapPenalty;
    final normalized = score.clamp(0, 100).round();

    return ForecastConfidenceResult(
      score: normalized,
      level: _level(normalized),
      factors: List.unmodifiable(factors),
    );
  }

  ForecastConfidenceLevel _level(int score) {
    if (score >= 75) {
      return ForecastConfidenceLevel.highConfidence;
    }
    if (score >= 45) {
      return ForecastConfidenceLevel.mediumConfidence;
    }
    return ForecastConfidenceLevel.lowConfidence;
  }

  double _gapPenalty(List<SessionTimeline> timelines) {
    final endedTimelines =
        timelines.where((timeline) => timeline.endedAt != null).toList()
          ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    if (endedTimelines.length < 2) {
      return 0;
    }
    var penalty = 0.0;
    for (var index = 1; index < endedTimelines.length; index++) {
      final previous = endedTimelines[index - 1].endedAt!;
      final current = endedTimelines[index].startedAt;
      if (current.difference(previous) > const Duration(minutes: 45)) {
        penalty += 8;
      }
    }
    return penalty.clamp(0, 24).toDouble();
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 50;
    }
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }
}
