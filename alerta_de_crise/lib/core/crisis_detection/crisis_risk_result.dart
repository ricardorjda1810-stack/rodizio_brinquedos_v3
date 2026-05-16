enum CrisisRiskLevel { normal, mildAttention, moderateAlert, highIntervention }

class CrisisRiskResult {
  final int score;
  final CrisisRiskLevel level;
  final List<String> reasonCodes;
  final String recommendedAction;

  const CrisisRiskResult({
    required this.score,
    required this.level,
    required this.reasonCodes,
    required this.recommendedAction,
  });

  bool get shouldAskCognitiveCheck {
    return level == CrisisRiskLevel.moderateAlert ||
        level == CrisisRiskLevel.highIntervention;
  }
}
