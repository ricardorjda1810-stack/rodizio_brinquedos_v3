import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/baseline_builder.dart';
import 'package:signalflow/core/crisis_detection/baseline_profile.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';

void main() {
  const builder = BaselineBuilder();

  group('BaselineBuilder', () {
    test('empty list returns safeDefault', () {
      final baseline = builder.build(const []);

      expectBaselineEqualsSafeDefault(baseline);
    });

    test('less than 5 valid samples returns safeDefault', () {
      final baseline = builder.build([
        _sample(heartRateBpm: 70),
        _sample(heartRateBpm: 71),
        _sample(heartRateBpm: 72),
        _sample(heartRateBpm: 73),
      ]);

      expectBaselineEqualsSafeDefault(baseline);
    });

    test('calculates resting heart rate median', () {
      final baseline = builder.build([
        _sample(heartRateBpm: 70, movementIntensity: 0.1),
        _sample(heartRateBpm: 72, movementIntensity: 0.2),
        _sample(heartRateBpm: 74, movementIntensity: 0.15),
        _sample(heartRateBpm: 76, movementIntensity: 0.3),
        _sample(heartRateBpm: 78, movementIntensity: 0.35),
        _sample(heartRateBpm: 120, movementIntensity: 0.8),
      ]);

      expect(baseline.restingHeartRateBpm, 74);
    });

    test('ignores samples with invalid heart rate', () {
      final baseline = builder.build([
        _sample(heartRateBpm: 20, movementIntensity: 0.1),
        _sample(heartRateBpm: 70, movementIntensity: 0.1),
        _sample(heartRateBpm: 72, movementIntensity: 0.1),
        _sample(heartRateBpm: 74, movementIntensity: 0.1),
        _sample(heartRateBpm: 76, movementIntensity: 0.1),
        _sample(heartRateBpm: 78, movementIntensity: 0.1),
        _sample(heartRateBpm: 260, movementIntensity: 0.1),
      ]);

      expect(baseline.restingHeartRateBpm, 74);
    });

    test('ignores invalid HRV', () {
      final baseline = builder.build([
        _sample(hrvRmssdMs: -1),
        _sample(hrvRmssdMs: 0),
        _sample(hrvRmssdMs: 30),
        _sample(hrvRmssdMs: 40),
        _sample(hrvRmssdMs: 50),
        _sample(hrvRmssdMs: 300),
        _sample(hrvRmssdMs: 60),
        _sample(hrvRmssdMs: 70),
      ]);

      expect(baseline.hrvRmssdMs, 50);
    });

    test('uses HRV fallback when no valid HRV exists', () {
      final fallback = BaselineProfile.safeDefault();
      final baseline = builder.build([
        _sample(hrvRmssdMs: null),
        _sample(hrvRmssdMs: null),
        _sample(hrvRmssdMs: null),
        _sample(hrvRmssdMs: null),
        _sample(hrvRmssdMs: null),
      ]);

      expect(baseline.hrvRmssdMs, fallback.hrvRmssdMs);
    });

    test('uses respiratory rate fallback when no valid value exists', () {
      final fallback = BaselineProfile.safeDefault();
      final baseline = builder.build([
        _sample(respiratoryRate: null),
        _sample(respiratoryRate: null),
        _sample(respiratoryRate: null),
        _sample(respiratoryRate: null),
        _sample(respiratoryRate: null),
      ]);

      expect(baseline.respiratoryRate, fallback.respiratoryRate);
    });

    test('calculates movementIntensity median', () {
      final baseline = builder.build([
        _sample(movementIntensity: 0.1),
        _sample(movementIntensity: 0.2),
        _sample(movementIntensity: 0.3),
        _sample(movementIntensity: 0.4),
        _sample(movementIntensity: 0.5),
      ]);

      expect(baseline.movementIntensity, 0.3);
    });

    test(
      'uses all valid heart rates when fewer than 5 resting samples exist',
      () {
        final baseline = builder.build([
          _sample(heartRateBpm: 70, movementIntensity: 0.1),
          _sample(heartRateBpm: 72, movementIntensity: 0.2),
          _sample(heartRateBpm: 90, movementIntensity: 0.6),
          _sample(heartRateBpm: 92, movementIntensity: 0.7),
          _sample(heartRateBpm: 94, movementIntensity: 0.8),
        ]);

        expect(baseline.restingHeartRateBpm, 90);
      },
    );
  });
}

void expectBaselineEqualsSafeDefault(BaselineProfile baseline) {
  final fallback = BaselineProfile.safeDefault();

  expect(baseline.restingHeartRateBpm, fallback.restingHeartRateBpm);
  expect(baseline.hrvRmssdMs, fallback.hrvRmssdMs);
  expect(baseline.respiratoryRate, fallback.respiratoryRate);
  expect(baseline.movementIntensity, fallback.movementIntensity);
}

PhysiologicalSample _sample({
  double heartRateBpm = 72,
  double movementIntensity = 0.1,
  double? hrvRmssdMs = 45,
  double? respiratoryRate = 16,
}) {
  return PhysiologicalSample(
    timestamp: DateTime(2026, 5, 16, 10),
    heartRateBpm: heartRateBpm,
    movementIntensity: movementIntensity,
    hrvRmssdMs: hrvRmssdMs,
    respiratoryRate: respiratoryRate,
    spo2Percent: 98,
  );
}
