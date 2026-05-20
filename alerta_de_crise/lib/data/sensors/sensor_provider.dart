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

  String get permissionStatusMessage {
    return 'Permissões não disponíveis para esta fonte de dados.';
  }

  Future<SensorSample?> getLatestSample();

  Future<bool> requestPermissions() async {
    return false;
  }

  Future<bool> hasPermissions() async {
    return false;
  }

  Stream<SensorSample> watchSamples() {
    return const Stream<SensorSample>.empty();
  }
}

abstract interface class ResettableSensorDeduplication {
  void resetDeduplication();
}
