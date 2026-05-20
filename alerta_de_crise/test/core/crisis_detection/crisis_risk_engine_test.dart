import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/baseline_profile.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_engine.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_result.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';

void main() {
  const engine = CrisisRiskEngine();
  final baseline = BaselineProfile.safeDefault();
  final timestamp = DateTime(2026, 5, 16, 10);

  PhysiologicalSample sample({
    double heartRateBpm = 72,
    double movementIntensity = 0.15,
    double? hrvRmssdMs = 45,
    double? spo2Percent = 98,
    double? respiratoryRate = 16,
  }) {
    return PhysiologicalSample(
      timestamp: timestamp,
      heartRateBpm: heartRateBpm,
      movementIntensity: movementIntensity,
      hrvRmssdMs: hrvRmssdMs,
      spo2Percent: spo2Percent,
      respiratoryRate: respiratoryRate,
    );
  }

  group('CrisisRiskEngine', () {
    test('returns normal score when data is close to baseline', () {
      final result = engine.evaluate(sample: sample(), baseline: baseline);

      expect(result.score, 0);
      expect(result.level, CrisisRiskLevel.normal);
      expect(result.reasonCodes, isEmpty);
      expect(result.shouldAskCognitiveCheck, isFalse);
    });

    test('heart rate increase without movement creates attention', () {
      final result = engine.evaluate(
        sample: sample(heartRateBpm: 92, movementIntensity: 0.1),
        baseline: baseline,
      );

      expect(result.score, 20);
      expect(result.level, CrisisRiskLevel.normal);
      expect(
        result.reasonCodes,
        contains('heart_rate_above_baseline_without_movement'),
      );
    });

    test('HRV drop increases score', () {
      final result = engine.evaluate(
        sample: sample(hrvRmssdMs: 25),
        baseline: baseline,
      );

      expect(result.score, 25);
      expect(result.reasonCodes, contains('hrv_drop'));
    });

    test('high movement reduces suspicion of emotional crisis', () {
      final stillResult = engine.evaluate(
        sample: sample(heartRateBpm: 105, movementIntensity: 0.1),
        baseline: baseline,
      );
      final movingResult = engine.evaluate(
        sample: sample(heartRateBpm: 105, movementIntensity: 0.8),
        baseline: baseline,
      );

      expect(movingResult.score, lessThan(stillResult.score));
      expect(
        movingResult.reasonCodes,
        contains('movement_may_explain_activation'),
      );
    });

    test(
      'low SpO2 adds caution and avoids automatic emotional crisis action',
      () {
        final result = engine.evaluate(
          sample: sample(heartRateBpm: 105, hrvRmssdMs: 20, spo2Percent: 92),
          baseline: baseline,
        );

        expect(result.reasonCodes, contains('low_spo2_requires_caution'));
        expect(
          result.recommendedAction,
          'Sinais fisiológicos exigem cautela. Não tratar automaticamente como crise emocional.',
        );
      },
    );

    test(
      'needsHelp response reaches highIntervention with physiological signs',
      () {
        final result = engine.evaluate(
          sample: sample(heartRateBpm: 105, hrvRmssdMs: 20),
          baseline: baseline,
          cognitiveResponse: CognitiveCheckResponse.needsHelp,
        );

        expect(result.score, 100);
        expect(result.level, CrisisRiskLevel.highIntervention);
        expect(result.reasonCodes, contains('user_requests_help'));
      },
    );

    test('shouldAskCognitiveCheck is true for moderate and high levels', () {
      const moderateResult = CrisisRiskResult(
        score: 50,
        level: CrisisRiskLevel.moderateAlert,
        reasonCodes: [],
        recommendedAction: 'Sugerir pausa curta e pergunta cognitiva.',
      );
      const highResult = CrisisRiskResult(
        score: 70,
        level: CrisisRiskLevel.highIntervention,
        reasonCodes: [],
        recommendedAction:
            'Iniciar protocolo de respiração guiada e oferecer ajuda.',
      );
      const mildResult = CrisisRiskResult(
        score: 30,
        level: CrisisRiskLevel.mildAttention,
        reasonCodes: [],
        recommendedAction: 'Observar por mais alguns instantes.',
      );

      expect(moderateResult.shouldAskCognitiveCheck, isTrue);
      expect(highResult.shouldAskCognitiveCheck, isTrue);
      expect(mildResult.shouldAskCognitiveCheck, isFalse);
    });
  });
}
