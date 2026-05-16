import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';
import 'package:signalflow/core/crisis_detection/physiological_sensor_provider.dart';
import 'package:signalflow/core/crisis_detection/sensor_provider_registry.dart';
import 'package:signalflow/core/crisis_detection/sensor_provider_type.dart';

void main() {
  group('SensorProviderRegistry', () {
    test('default provider is simulator', () {
      final registry = SensorProviderRegistry();

      expect(registry.getCurrent().type, SensorProviderType.simulator);
    });

    test('getCurrent returns current provider', () {
      final registry = SensorProviderRegistry();

      expect(registry.getCurrent(), isA<PhysiologicalSensorProvider>());
    });

    test('switchProvider switches provider', () {
      final registry = SensorProviderRegistry();
      final customProvider = _FakeProvider(SensorProviderType.csvReplay);

      registry.register(customProvider);
      registry.switchProvider(SensorProviderType.csvReplay);

      expect(registry.getCurrent(), customProvider);
    });
  });
}

class _FakeProvider implements PhysiologicalSensorProvider {
  _FakeProvider(this.type);

  @override
  final SensorProviderType type;

  @override
  Future<PhysiologicalSample?> getLatestSample() async {
    return null;
  }

  @override
  Future<List<PhysiologicalSample>> getRecentSamples({int limit = 30}) async {
    return const [];
  }
}
