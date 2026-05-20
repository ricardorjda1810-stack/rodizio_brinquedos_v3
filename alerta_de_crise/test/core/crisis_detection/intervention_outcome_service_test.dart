import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/core/crisis_detection/intervention_outcome_service.dart';
import 'package:signalflow/core/crisis_detection/intervention_session_result.dart';
import 'package:signalflow/data/crisis_detection/intervention_history_repository.dart';

void main() {
  group('InterventionOutcomeService', () {
    test('saves history entry', () {
      final repository = InterventionHistoryRepository();
      final service = InterventionOutcomeService(repository: repository);

      final entry = service.recordOutcome(result: _result());

      expect(repository.listAll(), [entry]);
    });

    test('calculates scoreDelta correctly', () {
      final repository = InterventionHistoryRepository();
      final service = InterventionOutcomeService(repository: repository);

      final entry = service.recordOutcome(
        result: _result(),
        preInterventionScore: 70,
        postInterventionScore: 45,
      );

      expect(entry.scoreDelta, -25);
    });

    test('scoreDelta is negative when perceived improvement lowers score', () {
      final repository = InterventionHistoryRepository();
      final service = InterventionOutcomeService(repository: repository);

      final entry = service.recordOutcome(
        result: _result(userReportedImprovement: true),
        preInterventionScore: 60,
        postInterventionScore: 35,
      );

      expect(entry.userReportedImprovement, isTrue);
      expect(entry.scoreDelta, lessThan(0));
    });

    test('preserves timestamps', () {
      final repository = InterventionHistoryRepository();
      final service = InterventionOutcomeService(repository: repository);
      final result = _result();

      final entry = service.recordOutcome(result: result);

      expect(entry.startedAt, result.startedAt);
      expect(entry.completedAt, result.completedAt);
    });

    test('preserves finalResponse', () {
      final repository = InterventionHistoryRepository();
      final service = InterventionOutcomeService(repository: repository);

      final entry = service.recordOutcome(
        result: _result(finalResponse: CognitiveCheckResponse.needsHelp),
      );

      expect(entry.finalResponse, CognitiveCheckResponse.needsHelp);
    });
  });
}

InterventionSessionResult _result({
  bool userReportedImprovement = true,
  CognitiveCheckResponse finalResponse = CognitiveCheckResponse.feelingOk,
}) {
  final startedAt = DateTime(2026, 5, 16, 10);

  return InterventionSessionResult(
    protocolId: 'standard-guided-pause',
    startedAt: startedAt,
    completedAt: startedAt.add(const Duration(seconds: 90)),
    completed: true,
    userReportedImprovement: userReportedImprovement,
    finalResponse: finalResponse,
  );
}
