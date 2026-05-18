import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/replay_engine/replay_engine_models.dart';
import 'package:signalflow/replay_engine/synthetic_scenario_generator.dart';

void main() {
  group('SyntheticScenarioGenerator', () {
    late SyntheticScenarioGenerator generator;

    setUp(() {
      generator = SyntheticScenarioGenerator(
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    test('generates valid synthetic scenario', () {
      final dataset = generator.generateSyntheticScenario(sampleCount: 12);

      expect(dataset.scenario.sampleCount, 12);
      expect(dataset.samples, hasLength(12));
      expect(dataset.scenario.safetyCopy, contains('simulação experimental'));
      expect(
        dataset.scenario.safetyCopy,
        contains('não representa evento real'),
      );
    });

    test('generates escalating scenario', () {
      final dataset = generator.generateEscalationScenario(sampleCount: 8);

      expect(dataset.scenario.scenarioType, ReplayScenarioType.escalating);
      expect(
        dataset.samples.last.heartRateBpm,
        greaterThan(dataset.samples.first.heartRateBpm),
      );
      expect(
        dataset.samples.last.hrvRmssdMs!,
        lessThan(dataset.samples.first.hrvRmssdMs!),
      );
      expect(dataset.forecasts.single.escalationProbability, greaterThan(60));
    });

    test('generates recovery scenario', () {
      final dataset = generator.generateRecoveryScenario(sampleCount: 8);

      expect(dataset.scenario.scenarioType, ReplayScenarioType.recovery);
      expect(
        dataset.samples.last.heartRateBpm,
        lessThan(dataset.samples.first.heartRateBpm),
      );
      expect(
        dataset.samples.last.hrvRmssdMs!,
        greaterThan(dataset.samples.first.hrvRmssdMs!),
      );
    });
  });
}
