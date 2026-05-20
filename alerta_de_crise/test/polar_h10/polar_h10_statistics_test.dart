import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/polar_h10/polar_h10_rr_sample.dart';
import 'package:signalflow/polar_h10/polar_h10_statistics.dart';

void main() {
  group('PolarH10Statistics', () {
    test('calculates RMSSD consistently', () {
      final statistics = PolarH10Statistics.fromSamples([
        _sample(rrIntervalMs: 800, heartRate: 75),
        _sample(rrIntervalMs: 820, heartRate: 73),
        _sample(rrIntervalMs: 790, heartRate: 76),
      ]);

      expect(statistics.rmssdMs, closeTo(25.49, 0.01));
      expect(statistics.sampleCount, 3);
    });

    test('calculates SDNN and min max heart rate consistently', () {
      final statistics = PolarH10Statistics.fromSamples([
        _sample(rrIntervalMs: 800, heartRate: 75),
        _sample(rrIntervalMs: 820, heartRate: 73),
        _sample(rrIntervalMs: 790, heartRate: 76),
      ]);

      expect(statistics.sdnnMs, closeTo(12.47, 0.01));
      expect(statistics.minHeartRate, 73);
      expect(statistics.maxHeartRate, 76);
    });

    test('empty sample list returns null statistics', () {
      final statistics = PolarH10Statistics.fromSamples(const []);

      expect(statistics.sampleCount, 0);
      expect(statistics.rmssdMs, isNull);
      expect(statistics.sdnnMs, isNull);
    });
  });
}

PolarH10RrSample _sample({
  required double rrIntervalMs,
  required double heartRate,
}) {
  return PolarH10RrSample(
    timestamp: DateTime(2026, 5, 17, 10),
    rrIntervalMs: rrIntervalMs,
    heartRate: heartRate,
    contactDetected: true,
  );
}
