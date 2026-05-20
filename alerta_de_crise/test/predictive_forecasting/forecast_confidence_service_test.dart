import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/predictive_forecasting/forecast_confidence_service.dart';
import 'package:signalflow/predictive_forecasting/predictive_forecast_models.dart';
import 'package:signalflow/sensor_quality/sensor_confidence_score.dart';
import 'package:signalflow/session_timeline/session_timeline_models.dart';

void main() {
  group('ForecastConfidenceService', () {
    const service = ForecastConfidenceService();

    test('detects low confidence from poor signal and sparse data', () {
      final result = service.calculateConfidence(
        confidenceScores: [_confidence(28, hasArtifacts: true)],
        timelines: [_timeline(samples: 3)],
        baselineStability: 35,
      );

      expect(result.level, ForecastConfidenceLevel.lowConfidence);
      expect(result.factors.join(' '), contains('sensor'));
      expect(result.factors.join(' '), contains('quantidade de dados'));
    });

    test('detects medium confidence for partial data', () {
      final result = service.calculateConfidence(
        confidenceScores: [_confidence(66)],
        timelines: [_timeline(samples: 18)],
        baselineStability: 70,
      );

      expect(result.level, ForecastConfidenceLevel.mediumConfidence);
    });

    test('detects high confidence for stable signal and enough data', () {
      final result = service.calculateConfidence(
        confidenceScores: [_confidence(92), _confidence(88)],
        timelines: [_timeline(samples: 80)],
        baselineStability: 95,
      );

      expect(result.level, ForecastConfidenceLevel.highConfidence);
      expect(result.score, greaterThanOrEqualTo(75));
    });
  });
}

SensorConfidenceScore _confidence(int score, {bool hasArtifacts = false}) {
  return SensorConfidenceScore(
    overallScore: score,
    rrQuality: score,
    hrQuality: score,
    movementConfidence: score,
    contactConfidence: score,
    hasArtifacts: hasArtifacts,
    warnings: hasArtifacts ? const ['artifact'] : const [],
  );
}

SessionTimeline _timeline({required int samples}) {
  return SessionTimeline(
    id: 'timeline-confidence',
    startedAt: DateTime.utc(2026, 5, 18, 11),
    endedAt: DateTime.utc(2026, 5, 18, 12),
    totalSamples: samples,
    totalEvents: 0,
    averageHeartRate: 72,
    averageHrv: 44,
    maxHeartRate: 82,
    minHrv: 36,
  );
}
