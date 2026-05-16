import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/baseline_profile.dart';
import 'package:signalflow/core/crisis_detection/baseline_session_service.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';

void main() {
  const service = BaselineSessionService();

  group('BaselineSessionService', () {
    test('generates a valid BaselineSessionResult', () {
      final result = service.createInitialBaseline(samples: _validSamples());

      expect(result.baseline, isA<BaselineProfile>());
      expect(result.sampleCount, 5);
      expect(result.usedFallbackDefaults, isFalse);
    });

    test('uses fallback when samples are insufficient', () {
      final result = service.createInitialBaseline(
        samples: [_sample(heartRateBpm: 70), _sample(heartRateBpm: 72)],
      );

      expect(result.usedFallbackDefaults, isTrue);
      expect(result.baseline.restingHeartRateBpm, 72);
    });

    test('preserves sampleCount', () {
      final result = service.createInitialBaseline(
        samples: [
          _sample(heartRateBpm: 70),
          _sample(heartRateBpm: 71),
          _sample(heartRateBpm: 72),
        ],
      );

      expect(result.sampleCount, 3);
    });

    test('createdAt is recent', () {
      final before = DateTime.now();
      final result = service.createInitialBaseline(samples: _validSamples());
      final after = DateTime.now();

      expect(result.createdAt.isBefore(before), isFalse);
      expect(result.createdAt.isAfter(after), isFalse);
    });

    test('baseline is not null', () {
      final result = service.createInitialBaseline(samples: _validSamples());

      expect(result.baseline, isNotNull);
    });
  });
}

List<PhysiologicalSample> _validSamples() {
  return [
    _sample(heartRateBpm: 68, hrvRmssdMs: 40),
    _sample(heartRateBpm: 70, hrvRmssdMs: 42),
    _sample(heartRateBpm: 72, hrvRmssdMs: 44),
    _sample(heartRateBpm: 74, hrvRmssdMs: 46),
    _sample(heartRateBpm: 76, hrvRmssdMs: 48),
  ];
}

PhysiologicalSample _sample({
  required double heartRateBpm,
  double hrvRmssdMs = 45,
}) {
  return PhysiologicalSample(
    timestamp: DateTime(2026, 5, 16, 10),
    heartRateBpm: heartRateBpm,
    movementIntensity: 0.1,
    hrvRmssdMs: hrvRmssdMs,
    spo2Percent: 98,
    respiratoryRate: 16,
  );
}
