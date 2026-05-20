import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/crisis_sample_simulator.dart';
import 'package:signalflow/core/crisis_detection/simulated_sensor_provider.dart';

void main() {
  group('SimulatedSensorProvider', () {
    test('returns valid sample', () async {
      final provider = SimulatedSensorProvider();

      final sample = await provider.getLatestSample();

      expect(sample, isNotNull);
      expect(sample!.heartRateBpm, greaterThan(0));
      expect(sample.movementIntensity, inInclusiveRange(0, 1));
    });

    test('scenario switch changes latest sample', () async {
      final provider = SimulatedSensorProvider();
      provider.setScenario(CrisisSimulationScenario.elevatedHeartRate);

      final sample = await provider.getLatestSample();

      expect(
        provider.currentScenario,
        CrisisSimulationScenario.elevatedHeartRate,
      );
      expect(sample!.heartRateBpm, 94);
    });

    test('getRecentSamples respects limit', () async {
      final provider = SimulatedSensorProvider();

      await provider.getLatestSample();
      await provider.getLatestSample();
      await provider.getLatestSample();

      final samples = await provider.getRecentSamples(limit: 2);

      expect(samples, hasLength(2));
    });
  });
}
