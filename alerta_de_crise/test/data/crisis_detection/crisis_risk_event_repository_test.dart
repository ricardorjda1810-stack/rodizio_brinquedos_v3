import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_result.dart';
import 'package:signalflow/data/crisis_detection/crisis_risk_event.dart';
import 'package:signalflow/data/crisis_detection/crisis_risk_event_repository.dart';

void main() {
  group('CrisisRiskEventRepository', () {
    test('saves event', () {
      final repository = CrisisRiskEventRepository();
      final event = _event(id: 'event-1');

      repository.save(event);

      expect(repository.listAll(), [event]);
    });

    test('lists all events in insertion order', () {
      final repository = CrisisRiskEventRepository();
      final first = _event(id: 'event-1');
      final second = _event(id: 'event-2');

      repository
        ..save(first)
        ..save(second);

      expect(repository.listAll(), [first, second]);
    });

    test('lists recent events with limit', () {
      final repository = CrisisRiskEventRepository();
      final older = _event(id: 'older', timestamp: DateTime(2026, 5, 16, 10));
      final newest = _event(
        id: 'newest',
        timestamp: DateTime(2026, 5, 16, 10, 2),
      );
      final middle = _event(
        id: 'middle',
        timestamp: DateTime(2026, 5, 16, 10, 1),
      );

      repository
        ..save(older)
        ..save(newest)
        ..save(middle);

      expect(repository.listRecent(limit: 2), [newest, middle]);
    });

    test('clears events', () {
      final repository = CrisisRiskEventRepository();

      repository
        ..save(_event(id: 'event-1'))
        ..clear();

      expect(repository.listAll(), isEmpty);
      expect(repository.listRecent(), isEmpty);
    });

    test('preserves reason codes and recommended action', () {
      final repository = CrisisRiskEventRepository();
      final event = _event(
        id: 'event-1',
        reasonCodes: const [
          'heart_rate_above_baseline_without_movement',
          'hrv_drop',
        ],
        recommendedAction: 'Observar por mais alguns instantes.',
      );

      repository.save(event);
      final saved = repository.listAll().single;

      expect(saved.reasonCodes, [
        'heart_rate_above_baseline_without_movement',
        'hrv_drop',
      ]);
      expect(saved.recommendedAction, 'Observar por mais alguns instantes.');
    });
  });
}

CrisisRiskEvent _event({
  required String id,
  DateTime? timestamp,
  List<String> reasonCodes = const [],
  String recommendedAction = 'Nenhuma ação necessária.',
}) {
  return CrisisRiskEvent(
    id: id,
    timestamp: timestamp ?? DateTime(2026, 5, 16, 10),
    score: 0,
    level: CrisisRiskLevel.normal,
    reasonCodes: reasonCodes,
    recommendedAction: recommendedAction,
    cognitiveResponse: CognitiveCheckResponse.notAsked,
    source: 'simulator',
  );
}
