import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/polar_h10_sensor_provider.dart';
import 'package:signalflow/core/crisis_detection/sensor_provider_type.dart';
import 'package:signalflow/polar_h10/polar_h10_rr_sample.dart';
import 'package:signalflow/polar_h10/polar_h10_service.dart';

void main() {
  group('PolarH10SensorProvider', () {
    test('provider generates PhysiologicalSample from RR interval', () async {
      final service = _FakePolarH10Service([
        _sample(rrIntervalMs: 810, heartRate: 74),
        _sample(rrIntervalMs: 790, heartRate: 76),
      ]);
      final provider = PolarH10SensorProvider(service: service);

      final sample = await provider.getLatestSample();

      expect(provider.type, SensorProviderType.polarH10);
      expect(sample, isNotNull);
      expect(sample?.heartRateBpm, 76);
      expect(sample?.hrvRmssdMs, closeTo(20, 0.01));
      expect(sample?.movementIntensity, 0);
    });

    test('recent samples respect limit', () async {
      final service = _FakePolarH10Service([
        _sample(rrIntervalMs: 810, heartRate: 74),
        _sample(rrIntervalMs: 790, heartRate: 76),
        _sample(rrIntervalMs: 800, heartRate: 75),
      ]);
      final provider = PolarH10SensorProvider(service: service);

      final samples = await provider.getRecentSamples(limit: 2);

      expect(samples, hasLength(2));
      expect(samples.first.heartRateBpm, 76);
      expect(samples.last.heartRateBpm, 75);
    });

    test('returns null when no valid RR interval exists', () async {
      final service = _FakePolarH10Service(const []);
      final provider = PolarH10SensorProvider(service: service);

      final sample = await provider.getLatestSample();

      expect(sample, isNull);
    });
  });
}

class _FakePolarH10Service extends PolarH10Service {
  _FakePolarH10Service(this.samples);

  final List<PolarH10RrSample> samples;

  @override
  Future<PolarH10RrSample?> getLatestRrSample() async {
    if (samples.isEmpty) {
      return null;
    }

    return samples.last;
  }

  @override
  Future<List<PolarH10RrSample>> getRecentRrSamples({int limit = 30}) async {
    if (limit <= 0) {
      return const [];
    }

    return List.unmodifiable(
      samples.skip(samples.length - limit.clamp(0, samples.length)),
    );
  }
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
