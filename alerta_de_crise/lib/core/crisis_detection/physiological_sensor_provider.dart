import 'physiological_sample.dart';
import 'sensor_provider_type.dart';

abstract class PhysiologicalSensorProvider {
  SensorProviderType get type;

  Future<PhysiologicalSample?> getLatestSample();

  Future<List<PhysiologicalSample>> getRecentSamples({int limit = 30});
}
