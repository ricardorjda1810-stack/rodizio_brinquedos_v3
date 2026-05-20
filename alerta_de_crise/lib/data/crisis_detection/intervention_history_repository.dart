import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/crisis_detection/cognitive_check_response.dart';
import '../../database/signalflow_database.dart';
import 'intervention_history_entry.dart';

class InterventionHistoryRepository {
  final SignalFlowDatabase? _database;
  final bool persistSyncWrites;
  final List<InterventionHistoryEntry> _entries = [];

  InterventionHistoryRepository({
    SignalFlowDatabase? database,
    this.persistSyncWrites = false,
  }) : _database = database;

  SignalFlowDatabase get _db => _database ?? SignalFlowDatabase.instance;

  void save(InterventionHistoryEntry entry) {
    _entries.add(entry);
    if (persistSyncWrites) {
      unawaited(_upsert(entry));
    }
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
    if (persistSyncWrites) {
      unawaited(clearPersistent());
    }
  }

  Future<void> savePersistent(InterventionHistoryEntry entry) async {
    _entries.add(entry);
    await _upsert(entry);
  }

  Future<void> _upsert(InterventionHistoryEntry entry) async {
    await _db
        .into(_db.interventionHistoryTable)
        .insertOnConflictUpdate(
          InterventionHistoryTableCompanion.insert(
            id: entry.id,
            protocolId: entry.protocolId,
            startedAt: entry.startedAt,
            completedAt: entry.completedAt,
            durationSeconds: entry.durationSeconds,
            completed: entry.completed,
            userReportedImprovement: entry.userReportedImprovement,
            finalResponse: entry.finalResponse.name,
            preScore: Value(entry.preInterventionScore),
            postScore: Value(entry.postInterventionScore),
            scoreDelta: Value(entry.scoreDelta),
          ),
        );
  }

  Future<List<InterventionHistoryEntry>> loadFromDatabase() async {
    final rows = await _db.select(_db.interventionHistoryTable).get();
    _entries
      ..clear()
      ..addAll(rows.map(_fromRow));
    return listAll();
  }

  Future<List<InterventionHistoryEntry>> listRecentPersistent({
    int limit = 20,
  }) async {
    if (limit <= 0) {
      return const [];
    }

    final rows =
        await (_db.select(_db.interventionHistoryTable)
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.completedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();

    return List.unmodifiable(rows.map(_fromRow));
  }

  Future<void> clearPersistent() async {
    _entries.clear();
    await _db.delete(_db.interventionHistoryTable).go();
  }

  InterventionHistoryEntry _fromRow(InterventionHistoryTableData row) {
    return InterventionHistoryEntry(
      id: row.id,
      protocolId: row.protocolId,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      durationSeconds: row.durationSeconds,
      completed: row.completed,
      userReportedImprovement: row.userReportedImprovement,
      finalResponse: CognitiveCheckResponse.values.byName(row.finalResponse),
      preInterventionScore: row.preScore,
      postInterventionScore: row.postScore,
      scoreDelta: row.scoreDelta,
    );
  }
}
