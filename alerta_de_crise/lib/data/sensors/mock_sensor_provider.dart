import '../../domain/models/sensor_sample.dart';
import 'sensor_provider.dart';

final class MockSensorProvider implements SensorProvider {
  MockSensorProvider();

  int _sampleIndex = 0;

  @override
  SensorProviderType get type => SensorProviderType.mock;

  @override
  Future<SensorSample?> getLatestSample() async {
    return nextSample();
  }

  @override
  Stream<SensorSample> watchSamples() {
    return Stream<SensorSample>.periodic(
      const Duration(seconds: 3),
      (_) => nextSample(),
    );
  }

  SensorSample nextSample() {
    final samples = _simulatedSamples();
    final sample = samples[_sampleIndex % samples.length];
    _sampleIndex++;
    return sample;
  }

  List<SensorSample> _simulatedSamples() {
    final now = DateTime.now();

    return [
      SensorSample(
        id: 'sim-normal-${now.microsecondsSinceEpoch}',
        timestamp: now,
        heartRate: 72,
        hrv: 42,
        motionState: 'parado',
      ),
      SensorSample(
        id: 'sim-leve-${now.microsecondsSinceEpoch}',
        timestamp: now,
        heartRate: 84,
        hrv: 34,
        motionState: 'parado',
      ),
      SensorSample(
        id: 'sim-atencao-${now.microsecondsSinceEpoch}',
        timestamp: now,
        heartRate: 94,
        hrv: 27,
        motionState: 'parado',
      ),
      SensorSample(
        id: 'sim-alerta-${now.microsecondsSinceEpoch}',
        timestamp: now,
        heartRate: 112,
        hrv: 18,
        motionState: 'parado',
      ),
      SensorSample(
        id: 'sim-recuperacao-${now.microsecondsSinceEpoch}',
        timestamp: now,
        heartRate: 80,
        hrv: 36,
        motionState: 'caminhando',
      ),
    ];
  }
}
