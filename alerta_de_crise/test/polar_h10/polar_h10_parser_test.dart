import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/polar_h10/polar_h10_parser.dart';

void main() {
  group('PolarH10Parser', () {
    test('parses uint8 heart rate with RR intervals', () {
      final parser = const PolarH10Parser();
      final timestamp = DateTime(2026, 5, 17, 10);

      final measurement = parser.parseHeartRateMeasurement([
        0x16,
        72,
        0x20,
        0x03,
      ], timestamp: timestamp);

      expect(measurement, isNotNull);
      expect(measurement?.heartRate, 72);
      expect(measurement?.contactDetected, isTrue);
      expect(measurement?.rrSamples, hasLength(1));
      expect(measurement?.rrSamples.first.rrIntervalMs, closeTo(781.25, 0.01));
      expect(measurement?.rrSamples.first.timestamp, timestamp);
    });

    test('parses uint16 heart rate safely', () {
      final parser = const PolarH10Parser();

      final measurement = parser.parseHeartRateMeasurement([
        0x11,
        0x2c,
        0x01,
        0x00,
        0x04,
      ]);

      expect(measurement?.heartRate, 300);
      expect(measurement?.rrSamples.first.rrIntervalMs, 1000);
    });

    test('returns null for malformed payload', () {
      final parser = const PolarH10Parser();

      expect(parser.parseHeartRateMeasurement(const []), isNull);
      expect(parser.parseHeartRateMeasurement(const [0x01]), isNull);
    });
  });
}
