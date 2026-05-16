import '../../data/crisis_detection/intervention_history_entry.dart';
import '../../data/crisis_detection/intervention_history_repository.dart';
import 'intervention_session_result.dart';

class InterventionOutcomeService {
  final InterventionHistoryRepository _repository;

  const InterventionOutcomeService({
    required InterventionHistoryRepository repository,
  }) : _repository = repository;

  InterventionHistoryEntry recordOutcome({
    required InterventionSessionResult result,
    int? preInterventionScore,
    int? postInterventionScore,
  }) {
    final scoreDelta =
        preInterventionScore == null || postInterventionScore == null
        ? null
        : postInterventionScore - preInterventionScore;
    final entry = InterventionHistoryEntry(
      id: 'intervention-${DateTime.now().microsecondsSinceEpoch}',
      protocolId: result.protocolId,
      startedAt: result.startedAt,
      completedAt: result.completedAt,
      durationSeconds: result.completedAt
          .difference(result.startedAt)
          .inSeconds
          .clamp(0, 999999),
      completed: result.completed,
      userReportedImprovement: result.userReportedImprovement,
      finalResponse: result.finalResponse,
      preInterventionScore: preInterventionScore,
      postInterventionScore: postInterventionScore,
      scoreDelta: scoreDelta,
    );

    _repository.save(entry);

    return entry;
  }
}
