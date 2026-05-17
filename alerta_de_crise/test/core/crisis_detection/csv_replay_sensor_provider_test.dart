import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/csv_replay_sensor_provider.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';
import 'package:signalflow/core/crisis_detection/sensor_provider_type.dart';

void main() {
  group('CsvReplaySensorProvider', () {
    test('reproduces samples in sequence', () async {
      final provider = CsvReplaySensorProvider(samples: _samples());

      final first = await provider.nextSample();
      final second = await provider.nextSample();

      expect(provider.type, SensorProviderType.csvReplay);
      expect(first?.heartRateBpm, 72);
      expect(second?.heartRateBpm, 88);
      expect(provider.cursor, 2);
    });

    test('reset works', () async {
      final provider = CsvReplaySensorProvider(samples: _samples());
      await provider.nextSample();
      await provider.nextSample();

      provider.reset();
      final sample = await provider.nextSample();

      expect(provider.cursor, 1);
      expect(sample?.heartRateBpm, 72);
    });

    test(
      'getLatestSample returns current sample without advancing again',
      () async {
        final provider = CsvReplaySensorProvider(samples: _samples());

        final first = await provider.getLatestSample();
        final latest = await provider.getLatestSample();

        expect(first, latest);
        expect(provider.cursor, 1);
      },
    );

    test('getRecentSamples respects limit', () async {
      final provider = CsvReplaySensorProvider(samples: _samples());

      final samples = await provider.getRecentSamples(limit: 1);

      expect(samples, hasLength(1));
      expect(samples.single.heartRateBpm, 72);
    });
  });
}

List<PhysiologicalSample> _samples() {
  return [_sample(0, 72), _sample(5, 88)];
}

PhysiologicalSample _sample(int seconds, double heartRate) {
  return PhysiologicalSample(
    timestamp: DateTime(2026, 5, 16, 10, 0, seconds),
    heartRateBpm: heartRate,
    hrvRmssdMs: 40,
    movementIntensity: 0.1,
  );
}
