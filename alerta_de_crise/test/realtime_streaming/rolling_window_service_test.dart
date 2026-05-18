import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/baseline_profile.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';
import 'package:signalflow/realtime_streaming/physiological_stream_buffer.dart';
import 'package:signalflow/realtime_streaming/realtime_stream_models.dart';
import 'package:signalflow/realtime_streaming/rolling_window_service.dart';

void main() {
  group('RollingWindowService', () {
    const service = RollingWindowService();

    test('calculates rolling averages', () {
      final now = DateTime.utc(2026, 5, 18, 12);
      final window = service.generateRollingWindow(
        samples: [
          _sample(now.subtract(const Duration(seconds: 20)), hr: 70, hrv: 42),
          _sample(now.subtract(const Duration(seconds: 10)), hr: 80, hrv: 38),
        ],
        duration: RollingWindow.ultraShortDuration,
        now: now,
      );
      final metrics = service.calculateRollingMetrics(window: window);

      expect(metrics.averageHeartRate, 75);
      expect(metrics.averageHrv, 40);
      expect(metrics.confidence, greaterThan(80));
    });

    test('trims rolling window samples', () {
      final now = DateTime.utc(2026, 5, 18, 12);
      final samples = [
        _sample(now.subtract(const Duration(minutes: 10)), hr: 70),
        _sample(now.subtract(const Duration(minutes: 2)), hr: 72),
      ];

      final trimmed = service.trimOldSamples(
        samples: samples,
        maxAge: const Duration(minutes: 5),
        now: now,
      );

      expect(trimmed, hasLength(1));
      expect(trimmed.single.heartRateBpm, 72);
    });

    test('buffer respects max size', () {
      final now = DateTime.utc(2026, 5, 18, 12);
      final buffer = PhysiologicalStreamBuffer(maxSize: 2);

      buffer
        ..addSample(_sample(now, hr: 70))
        ..addSample(_sample(now.add(const Duration(seconds: 1)), hr: 71))
        ..addSample(_sample(now.add(const Duration(seconds: 2)), hr: 72));

      expect(buffer.samples, hasLength(2));
      expect(buffer.samples.first.heartRateBpm, 71);
      expect(buffer.latestSample()?.heartRateBpm, 72);
    });

    test('calculates escalation density with baseline', () {
      final now = DateTime.utc(2026, 5, 18, 12);
      final window = service.generateRollingWindow(
        samples: [
          _sample(now.subtract(const Duration(seconds: 20)), hr: 70, hrv: 42),
          _sample(now.subtract(const Duration(seconds: 10)), hr: 92, hrv: 24),
        ],
        duration: RollingWindow.ultraShortDuration,
        now: now,
      );

      final metrics = service.calculateRollingMetrics(
        window: window,
        baseline: const BaselineProfile(
          restingHeartRateBpm: 68,
          hrvRmssdMs: 42,
          respiratoryRate: 15,
          movementIntensity: 0.1,
        ),
      );

      expect(metrics.escalationDensity, greaterThan(0));
    });
  });
}

PhysiologicalSample _sample(
  DateTime timestamp, {
  required double hr,
  double? hrv = 40,
}) {
  return PhysiologicalSample(
    timestamp: timestamp,
    heartRateBpm: hr,
    hrvRmssdMs: hrv,
    movementIntensity: 0.1,
  );
}
