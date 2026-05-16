import 'intervention_history_entry.dart';

class InterventionHistoryRepository {
  final List<InterventionHistoryEntry> _entries = [];

  void save(InterventionHistoryEntry entry) {
    _entries.add(entry);
  }

  List<InterventionHistoryEntry> listAll() {
    return List.unmodifiable(_entries);
  }

  List<InterventionHistoryEntry> listRecent({int limit = 20}) {
    if (limit <= 0) {
      return const [];
    }

    final sortedEntries = [..._entries]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return List.unmodifiable(sortedEntries.take(limit));
  }

  void clear() {
    _entries.clear();
  }
}
