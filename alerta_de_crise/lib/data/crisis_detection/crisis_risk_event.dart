import '../../core/crisis_detection/cognitive_check_response.dart';
import '../../core/crisis_detection/crisis_risk_result.dart';

class CrisisRiskEvent {
  final String id;
  final DateTime timestamp;
  final int score;
  final CrisisRiskLevel level;
  final List<String> reasonCodes;
  final String recommendedAction;
  final CognitiveCheckResponse cognitiveResponse;
  final String source;

  const CrisisRiskEvent({
    required this.id,
    required this.timestamp,
    required this.score,
    required this.level,
    required this.reasonCodes,
    required this.recommendedAction,
    required this.cognitiveResponse,
    required this.source,
  });
}
