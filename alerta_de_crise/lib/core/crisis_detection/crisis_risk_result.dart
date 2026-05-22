import 'environmental_audio_context.dart';

enum CrisisRiskLevel { normal, mildAttention, moderateAlert, highIntervention }

enum PhysiologicalRiskState {
  normal,
  possibleActivation,
  cognitiveCheckNeeded,
  likelyActivation,
  badSignal,
  blockedByMotion,
  blockedBySleep,
  possibleEnvironmentalStress,
}

class CrisisRiskResult {
  final int score;
  final int rawPhysiologicalScore;
  final int adjustedRiskScore;
  final int confidence;
  final CrisisRiskLevel level;
  final PhysiologicalRiskState state;
  final EnvironmentalContext noiseContext;
  final List<String> reasonCodes;
  final String recommendedAction;
  final String reason;

  const CrisisRiskResult({
    required this.score,
    required this.level,
    required this.reasonCodes,
    required this.recommendedAction,
    int? rawPhysiologicalScore,
    int? adjustedRiskScore,
    this.confidence = 5,
    this.state = PhysiologicalRiskState.normal,
    this.noiseContext = EnvironmentalContext.none,
    String? reason,
  }) : rawPhysiologicalScore = rawPhysiologicalScore ?? score,
       adjustedRiskScore = adjustedRiskScore ?? score,
       reason = reason ?? recommendedAction;

  bool get shouldAskCognitiveCheck {
    return state == PhysiologicalRiskState.cognitiveCheckNeeded ||
        level == CrisisRiskLevel.moderateAlert ||
        level == CrisisRiskLevel.highIntervention;
  }
}
