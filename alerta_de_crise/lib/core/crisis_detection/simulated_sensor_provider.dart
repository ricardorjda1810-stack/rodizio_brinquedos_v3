import 'crisis_sample_simulator.dart';
import 'physiological_sample.dart';
import 'physiological_sensor_provider.dart';
import 'sensor_provider_type.dart';

class SimulatedSensorProvider implements PhysiologicalSensorProvider {
  final CrisisSampleSimulator _simulator;
  final List<PhysiologicalSample> _samples = [];
  CrisisSimulationScenario _scenario;

  SimulatedSensorProvider({
    CrisisSampleSimulator simulator = const CrisisSampleSimulator(),
    CrisisSimulationScenario initialScenario = CrisisSimulationScenario.normal,
  }) : _simulator = simulator,
       _scenario = initialScenario;

  @override
  SensorProviderType get type => SensorProviderType.simulator;

  CrisisSimulationScenario get currentScenario => _scenario;

  void setScenario(CrisisSimulationScenario scenario) {
    _scenario = scenario;
  }

  @override
  Future<PhysiologicalSample?> getLatestSample() async {
    final sample = _simulator.scenarioFor(_scenario).sample;
    _samples.add(sample);
    return sample;
  }

  @override
  Future<List<PhysiologicalSample>> getRecentSamples({int limit = 30}) async {
    if (limit <= 0) {
      return const [];
    }

    if (_samples.isEmpty) {
      await getLatestSample();
    }

    return List.unmodifiable(_samples.reversed.take(limit));
  }
}
