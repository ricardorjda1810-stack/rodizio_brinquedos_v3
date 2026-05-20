import 'cognitive_check_response.dart';

class InterventionSessionResult {
  final String protocolId;
  final DateTime startedAt;
  final DateTime completedAt;
  final bool completed;
  final bool userReportedImprovement;
  final CognitiveCheckResponse finalResponse;

  const InterventionSessionResult({
    required this.protocolId,
    required this.startedAt,
    required this.completedAt,
    required this.completed,
    required this.userReportedImprovement,
    required this.finalResponse,
  });
}
