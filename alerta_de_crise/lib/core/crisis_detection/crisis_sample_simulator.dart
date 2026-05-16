import 'baseline_profile.dart';
import 'cognitive_check_response.dart';
import 'physiological_sample.dart';

enum CrisisSimulationScenario {
  normal,
  elevatedHeartRate,
  hrvDrop,
  movementExplainsHeartRate,
  lowSpo2Caution,
  highRiskWithUserHelp,
}

class CrisisSimulationCase {
  final CrisisSimulationScenario scenario;
  final String title;
  final String description;
  final PhysiologicalSample sample;
  final BaselineProfile baseline;
  final CognitiveCheckResponse cognitiveResponse;

  const CrisisSimulationCase({
    required this.scenario,
    required this.title,
    required this.description,
    required this.sample,
    required this.baseline,
    required this.cognitiveResponse,
  });
}

class CrisisSampleSimulator {
  static final DateTime _timestamp = DateTime(2026, 5, 16, 10);

  const CrisisSampleSimulator();

  List<CrisisSimulationCase> get scenarios {
    return CrisisSimulationScenario.values.map(scenarioFor).toList();
  }

  CrisisSimulationCase scenarioFor(CrisisSimulationScenario scenario) {
    final baseline = BaselineProfile.safeDefault();

    return switch (scenario) {
      CrisisSimulationScenario.normal => CrisisSimulationCase(
        scenario: scenario,
        title: 'Normal',
        description: 'Sinais próximos do padrão de repouso.',
        sample: _sample(
          heartRateBpm: 72,
          hrvRmssdMs: 45,
          spo2Percent: 98,
          movementIntensity: 0.15,
          respiratoryRate: 16,
        ),
        baseline: baseline,
        cognitiveResponse: CognitiveCheckResponse.notAsked,
      ),
      CrisisSimulationScenario.elevatedHeartRate => CrisisSimulationCase(
        scenario: scenario,
        title: 'FC elevada',
        description: 'Frequência cardíaca acima do padrão com pouco movimento.',
        sample: _sample(
          heartRateBpm: 94,
          hrvRmssdMs: 44,
          spo2Percent: 98,
          movementIntensity: 0.1,
          respiratoryRate: 17,
        ),
        baseline: baseline,
        cognitiveResponse: CognitiveCheckResponse.notAsked,
      ),
      CrisisSimulationScenario.hrvDrop => CrisisSimulationCase(
        scenario: scenario,
        title: 'Queda de HRV',
        description: 'HRV abaixo do padrão individual simulado.',
        sample: _sample(
          heartRateBpm: 76,
          hrvRmssdMs: 24,
          spo2Percent: 98,
          movementIntensity: 0.15,
          respiratoryRate: 16,
        ),
        baseline: baseline,
        cognitiveResponse: CognitiveCheckResponse.notAsked,
      ),
      CrisisSimulationScenario.movementExplainsHeartRate =>
        CrisisSimulationCase(
          scenario: scenario,
          title: 'Movimento explica FC',
          description: 'FC elevada com movimento intenso no mesmo momento.',
          sample: _sample(
            heartRateBpm: 104,
            hrvRmssdMs: 42,
            spo2Percent: 98,
            movementIntensity: 0.8,
            respiratoryRate: 18,
          ),
          baseline: baseline,
          cognitiveResponse: CognitiveCheckResponse.notAsked,
        ),
      CrisisSimulationScenario.lowSpo2Caution => CrisisSimulationCase(
        scenario: scenario,
        title: 'SpO2 baixa',
        description: 'Sinal de cautela sem classificar como crise emocional.',
        sample: _sample(
          heartRateBpm: 104,
          hrvRmssdMs: 24,
          spo2Percent: 92,
          movementIntensity: 0.1,
          respiratoryRate: 18,
        ),
        baseline: baseline,
        cognitiveResponse: CognitiveCheckResponse.notAsked,
      ),
      CrisisSimulationScenario.highRiskWithUserHelp => CrisisSimulationCase(
        scenario: scenario,
        title: 'Ajuda solicitada',
        description: 'Sinais acima do padrão combinados com pedido de ajuda.',
        sample: _sample(
          heartRateBpm: 106,
          hrvRmssdMs: 20,
          spo2Percent: 98,
          movementIntensity: 0.1,
          respiratoryRate: 22,
        ),
        baseline: baseline,
        cognitiveResponse: CognitiveCheckResponse.needsHelp,
      ),
    };
  }

  static PhysiologicalSample _sample({
    required double heartRateBpm,
    required double movementIntensity,
    required double? hrvRmssdMs,
    required double? spo2Percent,
    required double? respiratoryRate,
  }) {
    return PhysiologicalSample(
      timestamp: _timestamp,
      heartRateBpm: heartRateBpm,
      movementIntensity: movementIntensity,
      hrvRmssdMs: hrvRmssdMs,
      spo2Percent: spo2Percent,
      respiratoryRate: respiratoryRate,
    );
  }
}
