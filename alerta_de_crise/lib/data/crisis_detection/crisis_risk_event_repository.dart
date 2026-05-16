import 'crisis_risk_event.dart';

class CrisisRiskEventRepository {
  final List<CrisisRiskEvent> _events = [];

  void save(CrisisRiskEvent event) {
    _events.add(event);
  }

  List<CrisisRiskEvent> listAll() {
    return List.unmodifiable(_events);
  }

  List<CrisisRiskEvent> listRecent({int limit = 20}) {
    if (limit <= 0) {
      return const [];
    }

    final sortedEvents = [..._events]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return List.unmodifiable(sortedEvents.take(limit));
  }

  void clear() {
    _events.clear();
  }
}
