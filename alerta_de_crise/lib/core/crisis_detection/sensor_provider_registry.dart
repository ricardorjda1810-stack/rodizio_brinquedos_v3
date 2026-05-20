import 'apple_health_sensor_provider.dart';
import 'physiological_sensor_provider.dart';
import 'polar_h10_sensor_provider.dart';
import 'sensor_provider_type.dart';
import 'simulated_sensor_provider.dart';

class SensorProviderRegistry {
  final Map<SensorProviderType, PhysiologicalSensorProvider> _providers = {};
  SensorProviderType _currentType = SensorProviderType.simulator;

  SensorProviderRegistry({PhysiologicalSensorProvider? defaultProvider}) {
    register(defaultProvider ?? SimulatedSensorProvider());
    register(AppleHealthSensorProvider.defaultService());
    register(PolarH10SensorProvider.defaultService());
    _currentType = SensorProviderType.simulator;
  }

  void register(PhysiologicalSensorProvider provider) {
    _providers[provider.type] = provider;
  }

  PhysiologicalSensorProvider getCurrent() {
    return _providers[_currentType] ??
        _providers[SensorProviderType.simulator]!;
  }

  void switchProvider(SensorProviderType type) {
    if (!_providers.containsKey(type)) {
      throw StateError('Provider não registrado: $type');
    }

    _currentType = type;
  }
}
