import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_engine.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_result.dart';
import 'package:signalflow/core/crisis_detection/crisis_sample_simulator.dart';

void main() {
  const simulator = CrisisSampleSimulator();
  const engine = CrisisRiskEngine();

  group('CrisisSampleSimulator', () {
    test('exposes all scenarios', () {
      final scenarios = simulator.scenarios.map((item) => item.scenario);

      expect(scenarios, containsAll(CrisisSimulationScenario.values));
      expect(
        simulator.scenarios,
        hasLength(CrisisSimulationScenario.values.length),
      );
    });

    test('each scenario generates a valid physiological sample', () {
      for (final scenario in simulator.scenarios) {
        final sample = scenario.sample;

        expect(sample.timestamp, isA<DateTime>());
        expect(sample.heartRateBpm, greaterThan(0));
        expect(sample.movementIntensity, greaterThanOrEqualTo(0));
        expect(sample.movementIntensity, lessThanOrEqualTo(1));
      }
    });

    test('normal scenario returns normal score', () {
      final scenario = simulator.scenarioFor(CrisisSimulationScenario.normal);
      final result = engine.evaluate(
        sample: scenario.sample,
        baseline: scenario.baseline,
        cognitiveResponse: scenario.cognitiveResponse,
      );

      expect(result.score, 0);
      expect(result.level, CrisisRiskLevel.normal);
    });

    test('lowSpo2Caution includes low SpO2 caution reason code', () {
      final scenario = simulator.scenarioFor(
        CrisisSimulationScenario.lowSpo2Caution,
      );
      final result = engine.evaluate(
        sample: scenario.sample,
        baseline: scenario.baseline,
        cognitiveResponse: scenario.cognitiveResponse,
      );

      expect(result.reasonCodes, contains('low_spo2_requires_caution'));
    });

    test('highRiskWithUserHelp returns highIntervention', () {
      final scenario = simulator.scenarioFor(
        CrisisSimulationScenario.highRiskWithUserHelp,
      );
      final result = engine.evaluate(
        sample: scenario.sample,
        baseline: scenario.baseline,
        cognitiveResponse: scenario.cognitiveResponse,
      );

      expect(result.level, CrisisRiskLevel.highIntervention);
    });
  });
}
