import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';
import 'package:signalflow/sensor_quality/physiological_signal_quality.dart';
import 'package:signalflow/sensor_quality/sensor_quality_service.dart';

void main() {
  group('SensorQualityService', () {
    test('generates consistent high score for clean signal', () {
      final evaluation = const SensorQualityService().evaluateSampleQuality(
        sample: _sample(heartRateBpm: 74, movementIntensity: 0.1),
        rrIntervalsMs: const [800, 810, 790],
        contactDetected: true,
      );

      expect(evaluation.confidenceScore.overallScore, greaterThanOrEqualTo(90));
      expect(evaluation.signalQuality, PhysiologicalSignalQuality.excellent);
      expect(evaluation.warnings, isEmpty);
    });

    test('invalid RR lowers score and generates warning', () {
      final evaluation = const SensorQualityService().evaluateSampleQuality(
        sample: _sample(heartRateBpm: 74, movementIntensity: 0.1),
        rrIntervalsMs: const [800, 120, 810],
        contactDetected: true,
      );

      expect(evaluation.confidenceScore.hasArtifacts, isTrue);
      expect(evaluation.confidenceScore.rrQuality, lessThan(100));
      expect(evaluation.warnings, contains('rr_interval_out_of_range'));
    });

    test('invalid heart rate lowers HR quality', () {
      final evaluation = const SensorQualityService().evaluateSampleQuality(
        sample: _sample(heartRateBpm: 245, movementIntensity: 0.1),
        rrIntervalsMs: const [800, 810, 790],
        contactDetected: true,
      );

      expect(evaluation.confidenceScore.hrQuality, 10);
      expect(evaluation.warnings, contains('heart_rate_out_of_range'));
    });

    test('jitter changes signal quality away from excellent', () {
      final evaluation = const SensorQualityService().evaluateSampleQuality(
        sample: _sample(heartRateBpm: 74, movementIntensity: 0.1),
        rrIntervalsMs: const [800, 420, 1300, 760],
        contactDetected: true,
      );

      expect(
        evaluation.signalQuality,
        isNot(PhysiologicalSignalQuality.excellent),
      );
      expect(evaluation.warnings, contains('extreme_rr_jitter'));
    });

    test('movement reduces confidence', () {
      final lowMovement = const SensorQualityService().evaluateSampleQuality(
        sample: _sample(heartRateBpm: 100, movementIntensity: 0.1),
        rrIntervalsMs: const [600, 610, 590],
        contactDetected: true,
      );
      final highMovement = const SensorQualityService().evaluateSampleQuality(
        sample: _sample(heartRateBpm: 100, movementIntensity: 0.9),
        rrIntervalsMs: const [600, 610, 590],
        contactDetected: true,
      );

      expect(
        highMovement.confidenceScore.overallScore,
        lessThan(lowMovement.confidenceScore.overallScore),
      );
      expect(
        highMovement.warnings,
        contains('high_movement_reduces_confidence'),
      );
    });

    test('lost contact generates degraded confidence warning', () {
      final evaluation = const SensorQualityService().evaluateSampleQuality(
        sample: _sample(heartRateBpm: 74, movementIntensity: 0.1),
        rrIntervalsMs: const [800, 810, 790],
        contactDetected: false,
      );

      expect(evaluation.confidenceScore.contactConfidence, 20);
      expect(evaluation.warnings, contains('sensor_contact_not_detected'));
    });
  });
}

PhysiologicalSample _sample({
  required double heartRateBpm,
  required double movementIntensity,
}) {
  return PhysiologicalSample(
    timestamp: DateTime(2026, 5, 17, 10),
    heartRateBpm: heartRateBpm,
    movementIntensity: movementIntensity,
  );
}
