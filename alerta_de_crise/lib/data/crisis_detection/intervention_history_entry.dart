import '../../core/crisis_detection/cognitive_check_response.dart';

class InterventionHistoryEntry {
  final String id;
  final String protocolId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationSeconds;
  final bool completed;
  final bool userReportedImprovement;
  final CognitiveCheckResponse finalResponse;
  final int? preInterventionScore;
  final int? postInterventionScore;
  final int? scoreDelta;

  const InterventionHistoryEntry({
    required this.id,
    required this.protocolId,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.completed,
    required this.userReportedImprovement,
    required this.finalResponse,
    this.preInterventionScore,
    this.postInterventionScore,
    this.scoreDelta,
  });
}
