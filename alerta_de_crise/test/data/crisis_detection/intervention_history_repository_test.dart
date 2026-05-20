import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/data/crisis_detection/intervention_history_entry.dart';
import 'package:signalflow/data/crisis_detection/intervention_history_repository.dart';

void main() {
  group('InterventionHistoryRepository', () {
    test('saves history', () {
      final repository = InterventionHistoryRepository();
      final entry = _entry(id: 'entry-1');

      repository.save(entry);

      expect(repository.listAll(), [entry]);
    });

    test('listRecent respects limit', () {
      final repository = InterventionHistoryRepository();
      final older = _entry(id: 'older', completedAt: DateTime(2026, 5, 16, 10));
      final newest = _entry(
        id: 'newest',
        completedAt: DateTime(2026, 5, 16, 10, 2),
      );
      final middle = _entry(
        id: 'middle',
        completedAt: DateTime(2026, 5, 16, 10, 1),
      );

      repository
        ..save(older)
        ..save(newest)
        ..save(middle);

      expect(repository.listRecent(limit: 2), [newest, middle]);
    });

    test('clear removes history', () {
      final repository = InterventionHistoryRepository();

      repository
        ..save(_entry(id: 'entry-1'))
        ..clear();

      expect(repository.listAll(), isEmpty);
      expect(repository.listRecent(), isEmpty);
    });

    test('preserves finalResponse', () {
      final repository = InterventionHistoryRepository();
      final entry = _entry(
        id: 'entry-1',
        finalResponse: CognitiveCheckResponse.feelingActivated,
      );

      repository.save(entry);

      expect(
        repository.listAll().single.finalResponse,
        CognitiveCheckResponse.feelingActivated,
      );
    });
  });
}

InterventionHistoryEntry _entry({
  required String id,
  DateTime? completedAt,
  CognitiveCheckResponse finalResponse = CognitiveCheckResponse.feelingOk,
}) {
  final startedAt = DateTime(2026, 5, 16, 9, 59);
  final completed = completedAt ?? DateTime(2026, 5, 16, 10);

  return InterventionHistoryEntry(
    id: id,
    protocolId: 'standard-guided-pause',
    startedAt: startedAt,
    completedAt: completed,
    durationSeconds: completed.difference(startedAt).inSeconds,
    completed: true,
    userReportedImprovement: true,
    finalResponse: finalResponse,
    preInterventionScore: 70,
    postInterventionScore: 45,
    scoreDelta: -25,
  );
}
