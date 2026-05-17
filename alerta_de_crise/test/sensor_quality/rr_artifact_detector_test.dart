import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/sensor_quality/rr_artifact_detector.dart';

void main() {
  group('RrArtifactDetector', () {
    test('detects invalid RR intervals', () {
      final report = const RrArtifactDetector().detect(
        rrIntervalsMs: const [800, 120, 2600],
        heartRateBpm: 75,
      );

      expect(report.hasArtifacts, isTrue);
      expect(report.invalidIntervalCount, 2);
      expect(report.warnings, contains('rr_interval_out_of_range'));
    });

    test('accepts valid RR intervals', () {
      final report = const RrArtifactDetector().detect(
        rrIntervalsMs: const [800, 810, 790],
        heartRateBpm: 75,
      );

      expect(report.hasArtifacts, isFalse);
      expect(report.warnings, isEmpty);
    });

    test('detects invalid heart rate', () {
      final report = const RrArtifactDetector().detect(
        rrIntervalsMs: const [800, 810, 790],
        heartRateBpm: 245,
      );

      expect(report.hasInvalidHeartRate, isTrue);
      expect(report.warnings, contains('heart_rate_out_of_range'));
    });

    test('detects extreme jitter and abrupt RR changes', () {
      final report = const RrArtifactDetector().detect(
        rrIntervalsMs: const [800, 420, 1300, 760],
        heartRateBpm: 75,
      );

      expect(report.abruptChangeCount, greaterThan(0));
      expect(report.hasExtremeJitter, isTrue);
      expect(report.warnings, contains('abrupt_rr_change'));
      expect(report.warnings, contains('extreme_rr_jitter'));
    });
  });
}
