import '../../domain/models/sensor_sample.dart';

enum SensorProviderType {
  mock,
  healthkit;

  String get label {
    return switch (this) {
      SensorProviderType.mock => 'Simulação',
      SensorProviderType.healthkit => 'HealthKit (experimental)',
    };
  }

  String get key {
    return switch (this) {
      SensorProviderType.mock => 'mock',
      SensorProviderType.healthkit => 'healthkit',
    };
  }
}

abstract interface class SensorProvider {
  SensorProviderType get type;

  Future<SensorSample?> getLatestSample();

  Stream<SensorSample> watchSamples() {
    return const Stream<SensorSample>.empty();
  }
}
