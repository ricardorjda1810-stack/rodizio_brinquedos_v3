import 'baseline_profile.dart';
import 'cognitive_check_response.dart';
import 'crisis_risk_result.dart';
import 'physiological_sample.dart';

class CrisisRiskEngine {
  const CrisisRiskEngine();

  CrisisRiskResult evaluate({
    required PhysiologicalSample sample,
    required BaselineProfile baseline,
    CognitiveCheckResponse cognitiveResponse = CognitiveCheckResponse.notAsked,
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

    final normalizedScore = score.clamp(0, 100).toInt();
    final level = _levelFromScore(normalizedScore);
    final action = _recommendedAction(level, reasons);

    return CrisisRiskResult(
      score: normalizedScore,
      level: level,
      reasonCodes: reasons,
      recommendedAction: action,
    );
  }

  CrisisRiskLevel _levelFromScore(int score) {
    if (score >= 70) return CrisisRiskLevel.highIntervention;
    if (score >= 50) return CrisisRiskLevel.moderateAlert;
    if (score >= 30) return CrisisRiskLevel.mildAttention;
    return CrisisRiskLevel.normal;
  }

  String _recommendedAction(CrisisRiskLevel level, List<String> reasons) {
    if (reasons.contains('low_spo2_requires_caution')) {
      return 'Sinais fisiológicos exigem cautela. Não tratar automaticamente como crise emocional.';
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
