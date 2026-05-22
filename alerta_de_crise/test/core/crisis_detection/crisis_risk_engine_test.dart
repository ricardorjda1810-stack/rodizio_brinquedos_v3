import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/baseline_profile.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_engine.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_result.dart';
import 'package:signalflow/core/crisis_detection/environmental_audio_context.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';

void main() {
  const engine = CrisisRiskEngine();
  final baseline = BaselineProfile.safeDefault();
  final timestamp = DateTime(2026, 5, 16, 10);

  PhysiologicalSample sample({
    double heartRateBpm = 72,
    double movementIntensity = 0.15,
    double? hrvRmssdMs = 45,
    double? hrvSdnnMs,
    double? spo2Percent = 98,
    double? respiratoryRate = 16,
    double signalQuality = 1,
    bool probableSleep = false,
  }) {
    return PhysiologicalSample(
      timestamp: timestamp,
      heartRateBpm: heartRateBpm,
      movementIntensity: movementIntensity,
      hrvRmssdMs: hrvRmssdMs,
      hrvSdnnMs: hrvSdnnMs,
      spo2Percent: spo2Percent,
      respiratoryRate: respiratoryRate,
      signalQuality: signalQuality,
      probableSleep: probableSleep,
    );
  }

  PhysiologicalSample strongH10Activation({
    double movementIntensity = 0.1,
    bool probableSleep = false,
    double signalQuality = 1,
  }) {
    return sample(
      heartRateBpm: 105,
      hrvRmssdMs: 20,
      movementIntensity: movementIntensity,
      probableSleep: probableSleep,
      signalQuality: signalQuality,
    );
  }

  PhysiologicalSample moderateH10Activation() {
    return sample(heartRateBpm: 105, hrvRmssdMs: 32, movementIntensity: 0.1);
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

    test('strong H10 activation without noise keeps likely activation', () {
      final result = engine.evaluate(
        sample: strongH10Activation(),
        baseline: baseline,
      );

      expect(result.rawPhysiologicalScore, 75);
      expect(result.adjustedRiskScore, 75);
      expect(result.score, result.adjustedRiskScore);
      expect(result.confidence, 5);
      expect(result.state, PhysiologicalRiskState.likelyActivation);
      expect(result.noiseContext, EnvironmentalContext.none);
    });

    test('noise without physiological change does not increase risk', () {
      final result = engine.evaluate(
        sample: sample(),
        baseline: baseline,
        environmentalAudioContext: const EnvironmentalAudioContext(
          context: EnvironmentalContext.veryHighNoise,
          peakDecibels: 92,
        ),
      );

      expect(result.rawPhysiologicalScore, 0);
      expect(result.adjustedRiskScore, 0);
      expect(result.confidence, 5);
      expect(result.state, PhysiologicalRiskState.normal);
      expect(result.level, CrisisRiskLevel.normal);
      expect(result.shouldAskCognitiveCheck, isFalse);
      expect(result.noiseContext, EnvironmentalContext.veryHighNoise);
      expect(
        result.reasonCodes,
        isNot(contains('environmental_noise_contextual_stress')),
      );
    });

    test('noise below moderate physiological risk does not change state', () {
      final result = engine.evaluate(
        sample: sample(heartRateBpm: 92, movementIntensity: 0.1),
        baseline: baseline,
        environmentalAudioContext: const EnvironmentalAudioContext(
          context: EnvironmentalContext.highNoise,
          peakDecibels: 87,
        ),
      );

      expect(result.rawPhysiologicalScore, 20);
      expect(result.adjustedRiskScore, 20);
      expect(result.confidence, 5);
      expect(result.state, PhysiologicalRiskState.normal);
      expect(result.level, CrisisRiskLevel.normal);
      expect(result.shouldAskCognitiveCheck, isFalse);
      expect(result.noiseContext, EnvironmentalContext.highNoise);
      expect(
        result.reasonCodes,
        isNot(contains('environmental_noise_contextual_stress')),
      );
    });

    test('moderate H10 activation with elevated noise adds small weight', () {
      final result = engine.evaluate(
        sample: moderateH10Activation(),
        baseline: baseline,
        environmentalAudioContext: const EnvironmentalAudioContext(
          context: EnvironmentalContext.elevatedNoise,
          peakDecibels: 82,
        ),
      );

      expect(result.rawPhysiologicalScore, 60);
      expect(result.adjustedRiskScore, 61);
      expect(result.confidence, 5);
      expect(result.state, PhysiologicalRiskState.possibleEnvironmentalStress);
      expect(result.shouldAskCognitiveCheck, isTrue);
      expect(result.noiseContext, EnvironmentalContext.elevatedNoise);
      expect(
        result.reason,
        'Ativação fisiológica detectada pelo H10, com ruído ambiental elevado como possível fator contextual de estresse.',
      );
      expect(
        result.reasonCodes,
        contains('environmental_noise_contextual_stress'),
      );
    });

    test(
      'moderate H10 activation with high noise adds the same small weight',
      () {
        final result = engine.evaluate(
          sample: moderateH10Activation(),
          baseline: baseline,
          environmentalAudioContext: const EnvironmentalAudioContext(
            context: EnvironmentalContext.highNoise,
            peakDecibels: 87,
          ),
        );

        expect(result.rawPhysiologicalScore, 60);
        expect(result.adjustedRiskScore, 61);
        expect(result.confidence, 5);
        expect(
          result.state,
          PhysiologicalRiskState.possibleEnvironmentalStress,
        );
        expect(result.noiseContext, EnvironmentalContext.highNoise);
        expect(
          result.reasonCodes,
          contains('environmental_noise_contextual_stress'),
        );
      },
    );

    test(
      'strong H10 activation with very high noise adds at most two points',
      () {
        final result = engine.evaluate(
          sample: strongH10Activation(),
          baseline: baseline,
          environmentalAudioContext: const EnvironmentalAudioContext(
            context: EnvironmentalContext.veryHighNoise,
            peakDecibels: 92,
          ),
        );

        expect(result.rawPhysiologicalScore, 75);
        expect(result.adjustedRiskScore, 77);
        expect(result.confidence, 5);
        expect(
          result.state,
          PhysiologicalRiskState.possibleEnvironmentalStress,
        );
        expect(result.level, CrisisRiskLevel.highIntervention);
        expect(result.noiseContext, EnvironmentalContext.veryHighNoise);
      },
    );

    test('absence of environmental data behaves as no noise', () {
      final result = engine.evaluate(
        sample: strongH10Activation(),
        baseline: baseline,
        environmentalAudioContext: EnvironmentalAudioContext.fromSamples(
          eventTimestamp: timestamp,
          samples: const [],
        ),
      );

      expect(result.rawPhysiologicalScore, result.adjustedRiskScore);
      expect(result.confidence, 5);
      expect(result.state, PhysiologicalRiskState.likelyActivation);
      expect(result.noiseContext, EnvironmentalContext.none);
    });

    test('high H10 motion blocks false positive before noise analysis', () {
      final result = engine.evaluate(
        sample: strongH10Activation(movementIntensity: 0.9),
        baseline: baseline,
        environmentalAudioContext: const EnvironmentalAudioContext(
          context: EnvironmentalContext.veryHighNoise,
          peakDecibels: 94,
        ),
      );

      expect(result.state, PhysiologicalRiskState.blockedByMotion);
      expect(result.adjustedRiskScore, 0);
      expect(result.noiseContext, EnvironmentalContext.none);
      expect(result.reasonCodes, contains('blocked_by_h10_motion'));
      expect(
        result.reasonCodes,
        isNot(contains('environmental_noise_contextual_stress')),
      );
    });

    test('probable sleep blocks false positive before noise analysis', () {
      final result = engine.evaluate(
        sample: strongH10Activation(probableSleep: true),
        baseline: baseline,
        environmentalAudioContext: const EnvironmentalAudioContext(
          context: EnvironmentalContext.highNoise,
          peakDecibels: 87,
        ),
      );

      expect(result.state, PhysiologicalRiskState.blockedBySleep);
      expect(result.adjustedRiskScore, 0);
      expect(result.noiseContext, EnvironmentalContext.none);
      expect(result.reasonCodes, contains('blocked_by_probable_sleep'));
      expect(
        result.reasonCodes,
        isNot(contains('environmental_noise_contextual_stress')),
      );
    });

    test('bad signal blocks false positive before noise analysis', () {
      final result = engine.evaluate(
        sample: strongH10Activation(signalQuality: 0.2),
        baseline: baseline,
        environmentalAudioContext: const EnvironmentalAudioContext(
          context: EnvironmentalContext.veryHighNoise,
          peakDecibels: 95,
        ),
      );

      expect(result.state, PhysiologicalRiskState.badSignal);
      expect(result.adjustedRiskScore, 0);
      expect(result.noiseContext, EnvironmentalContext.none);
      expect(result.reasonCodes, contains('bad_signal_blocks_activation'));
      expect(
        result.reasonCodes,
        isNot(contains('environmental_noise_contextual_stress')),
      );
    });
  });
}
