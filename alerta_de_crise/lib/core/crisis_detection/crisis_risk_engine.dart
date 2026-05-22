import 'baseline_profile.dart';
import 'cognitive_check_response.dart';
import 'crisis_risk_result.dart';
import 'environmental_audio_context.dart';
import 'physiological_sample.dart';

class CrisisRiskEngine {
  const CrisisRiskEngine();

  static const int _maxConfidence = 5;
  static const int _moderateRiskScore = 50;

  CrisisRiskResult evaluate({
    required PhysiologicalSample sample,
    required BaselineProfile baseline,
    CognitiveCheckResponse cognitiveResponse = CognitiveCheckResponse.notAsked,
    EnvironmentalAudioContext environmentalAudioContext =
        const EnvironmentalAudioContext.none(),
  }) {
    var score = 0;
    final reasons = <String>[];

    final heartRateDelta = sample.heartRateBpm - baseline.restingHeartRateBpm;

    if (heartRateDelta >= 15 && sample.movementIntensity <= 0.35) {
      score += 20;
      reasons.add('heart_rate_above_baseline_without_movement');
    }

    if (heartRateDelta >= 30 && sample.movementIntensity <= 0.35) {
      score += 15;
      reasons.add('marked_heart_rate_increase');
    }

    final hrv = sample.hrvRmssdMs;
    if (hrv != null && hrv < baseline.hrvRmssdMs * 0.75) {
      score += 25;
      reasons.add('hrv_drop');
    }

    if (hrv != null && hrv < baseline.hrvRmssdMs * 0.55) {
      score += 15;
      reasons.add('marked_hrv_drop');
    }

    final sdnn = sample.hrvSdnnMs;
    if (sdnn != null && sdnn < baseline.hrvRmssdMs * 0.70) {
      score += 10;
      reasons.add('sdnn_drop');
    }

    final spo2 = sample.spo2Percent;
    if (spo2 != null && spo2 < 94) {
      score -= 20;
      reasons.add('low_spo2_requires_caution');
    }

    final respiratoryRate = sample.respiratoryRate;
    if (respiratoryRate != null &&
        respiratoryRate >= baseline.respiratoryRate + 5) {
      score += 15;
      reasons.add('respiratory_rate_above_baseline');
    }

    if (sample.movementIntensity >= 0.65) {
      score -= 10;
      reasons.add('movement_may_explain_activation');
    }

    switch (cognitiveResponse) {
      case CognitiveCheckResponse.notAsked:
        break;
      case CognitiveCheckResponse.feelingOk:
        score -= 10;
        reasons.add('user_reports_ok');
        break;
      case CognitiveCheckResponse.feelingActivated:
        score += 20;
        reasons.add('user_reports_activation');
        break;
      case CognitiveCheckResponse.needsHelp:
        score += 35;
        reasons.add('user_requests_help');
        break;
    }

    final rawPhysiologicalScore = score.clamp(0, 100).toInt();
    final blockedResult = _blockedResult(
      sample: sample,
      rawPhysiologicalScore: rawPhysiologicalScore,
      reasons: reasons,
    );
    if (blockedResult != null) {
      return blockedResult;
    }

    final adjustedRiskScore = _adjustedScoreForNoise(
      rawPhysiologicalScore,
      environmentalAudioContext,
    );
    final state = _stateFromScoreAndNoise(
      rawPhysiologicalScore: rawPhysiologicalScore,
      adjustedRiskScore: adjustedRiskScore,
      environmentalAudioContext: environmentalAudioContext,
    );
    final hasContextualStress =
        environmentalAudioContext.hasNoise &&
        rawPhysiologicalScore >= _moderateRiskScore;
    if (hasContextualStress) {
      reasons.add('environmental_noise_contextual_stress');
    }

    final level = _levelFromScore(adjustedRiskScore);
    final action = _recommendedAction(level, reasons, state);

    return CrisisRiskResult(
      score: adjustedRiskScore,
      rawPhysiologicalScore: rawPhysiologicalScore,
      adjustedRiskScore: adjustedRiskScore,
      confidence: _maxConfidence,
      level: level,
      state: state,
      noiseContext: environmentalAudioContext.context,
      reasonCodes: reasons,
      recommendedAction: action,
      reason: action,
    );
  }

  CrisisRiskResult? _blockedResult({
    required PhysiologicalSample sample,
    required int rawPhysiologicalScore,
    required List<String> reasons,
  }) {
    if (sample.signalQuality < 0.40) {
      reasons.add('bad_signal_blocks_activation');
      return _resultForBlockedState(
        rawPhysiologicalScore: rawPhysiologicalScore,
        state: PhysiologicalRiskState.badSignal,
        reasons: reasons,
        action:
            'Sinal fisiológico com baixa qualidade. Recoletar antes de interpretar risco.',
      );
    }

    if (sample.movementIntensity >= 0.85) {
      if (!reasons.contains('movement_may_explain_activation')) {
        reasons.add('movement_may_explain_activation');
      }
      reasons.add('blocked_by_h10_motion');
      return _resultForBlockedState(
        rawPhysiologicalScore: rawPhysiologicalScore,
        state: PhysiologicalRiskState.blockedByMotion,
        reasons: reasons,
        action:
            'Movimento corporal elevado no H10 pode explicar a ativação. Evitar falso positivo.',
      );
    }

    if (sample.probableSleep) {
      reasons.add('blocked_by_probable_sleep');
      return _resultForBlockedState(
        rawPhysiologicalScore: rawPhysiologicalScore,
        state: PhysiologicalRiskState.blockedBySleep,
        reasons: reasons,
        action:
            'Padrão compatível com sono provável. Evitar interpretar como crise.',
      );
    }

    return null;
  }

  CrisisRiskResult _resultForBlockedState({
    required int rawPhysiologicalScore,
    required PhysiologicalRiskState state,
    required List<String> reasons,
    required String action,
  }) {
    return CrisisRiskResult(
      score: 0,
      rawPhysiologicalScore: rawPhysiologicalScore,
      adjustedRiskScore: 0,
      confidence: 0,
      level: CrisisRiskLevel.normal,
      state: state,
      noiseContext: EnvironmentalContext.none,
      reasonCodes: reasons,
      recommendedAction: action,
      reason: action,
    );
  }

  int _adjustedScoreForNoise(
    int rawPhysiologicalScore,
    EnvironmentalAudioContext environmentalAudioContext,
  ) {
    if (rawPhysiologicalScore < _moderateRiskScore) {
      return rawPhysiologicalScore;
    }

    return (rawPhysiologicalScore + environmentalAudioContext.stressWeight)
        .clamp(0, 100)
        .toInt();
  }

  PhysiologicalRiskState _stateFromScoreAndNoise({
    required int rawPhysiologicalScore,
    required int adjustedRiskScore,
    required EnvironmentalAudioContext environmentalAudioContext,
  }) {
    if (rawPhysiologicalScore <= 0) {
      return PhysiologicalRiskState.normal;
    }

    if (environmentalAudioContext.hasNoise &&
        rawPhysiologicalScore >= _moderateRiskScore) {
      return PhysiologicalRiskState.possibleEnvironmentalStress;
    }

    if (adjustedRiskScore >= 70) {
      return PhysiologicalRiskState.likelyActivation;
    }
    if (adjustedRiskScore >= 50) {
      return PhysiologicalRiskState.cognitiveCheckNeeded;
    }
    if (adjustedRiskScore >= 30) {
      return PhysiologicalRiskState.possibleActivation;
    }
    return PhysiologicalRiskState.normal;
  }

  CrisisRiskLevel _levelFromScore(int score) {
    if (score >= 70) return CrisisRiskLevel.highIntervention;
    if (score >= 50) return CrisisRiskLevel.moderateAlert;
    if (score >= 30) return CrisisRiskLevel.mildAttention;
    return CrisisRiskLevel.normal;
  }

  String _recommendedAction(
    CrisisRiskLevel level,
    List<String> reasons,
    PhysiologicalRiskState state,
  ) {
    if (reasons.contains('low_spo2_requires_caution')) {
      return 'Sinais fisiológicos exigem cautela. Não tratar automaticamente como crise emocional.';
    }

    if (state == PhysiologicalRiskState.possibleEnvironmentalStress ||
        reasons.contains('environmental_noise_contextual_stress')) {
      return 'Ativação fisiológica detectada pelo H10, com ruído ambiental elevado como possível fator contextual de estresse.';
    }

    switch (level) {
      case CrisisRiskLevel.normal:
        return 'Nenhuma ação necessária.';
      case CrisisRiskLevel.mildAttention:
        return 'Observar por mais alguns instantes.';
      case CrisisRiskLevel.moderateAlert:
        return 'Sugerir pausa curta e pergunta cognitiva.';
      case CrisisRiskLevel.highIntervention:
        return 'Iniciar protocolo de respiração guiada e oferecer ajuda.';
    }
  }
}
