import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/crisis_detection/cognitive_check_response.dart';
import '../../core/crisis_detection/crisis_risk_result.dart';
import '../../database/signalflow_database.dart';
import 'crisis_risk_event.dart';

class CrisisRiskEventRepository {
  final SignalFlowDatabase? _database;
  final bool persistSyncWrites;
  final List<CrisisRiskEvent> _events = [];

  CrisisRiskEventRepository({
    SignalFlowDatabase? database,
    this.persistSyncWrites = false,
  }) : _database = database;

  SignalFlowDatabase get _db => _database ?? SignalFlowDatabase.instance;

  void save(CrisisRiskEvent event) {
    _events.add(event);
    if (persistSyncWrites) {
      unawaited(_upsert(event));
    }
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
    if (persistSyncWrites) {
      unawaited(clearPersistent());
    }
  }

  Future<void> savePersistent(CrisisRiskEvent event) async {
    _events.add(event);
    await _upsert(event);
  }

  Future<void> _upsert(CrisisRiskEvent event) async {
    await _db
        .into(_db.crisisRiskEventsTable)
        .insertOnConflictUpdate(
          CrisisRiskEventsTableCompanion.insert(
            id: event.id,
            timestamp: event.timestamp,
            score: event.score,
            level: event.level.name,
            reasonCodesJson: jsonEncode(event.reasonCodes),
            recommendedAction: event.recommendedAction,
            cognitiveResponse: event.cognitiveResponse.name,
            source: event.source,
          ),
        );
  }

  Future<List<CrisisRiskEvent>> loadFromDatabase() async {
    final rows = await _db.select(_db.crisisRiskEventsTable).get();
    _events
      ..clear()
      ..addAll(rows.map(_fromRow));
    return listAll();
  }

  Future<List<CrisisRiskEvent>> listRecentPersistent({int limit = 20}) async {
    if (limit <= 0) {
      return const [];
    }

    final rows =
        await (_db.select(_db.crisisRiskEventsTable)
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.timestamp,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();

    return List.unmodifiable(rows.map(_fromRow));
  }

  Future<void> clearPersistent() async {
    _events.clear();
    await _db.delete(_db.crisisRiskEventsTable).go();
  }

  CrisisRiskEvent _fromRow(CrisisRiskEventsTableData row) {
    return CrisisRiskEvent(
      id: row.id,
      timestamp: row.timestamp,
      score: row.score,
      level: CrisisRiskLevel.values.byName(row.level),
      reasonCodes: (jsonDecode(row.reasonCodesJson) as List<dynamic>)
          .cast<String>(),
      recommendedAction: row.recommendedAction,
      cognitiveResponse: CognitiveCheckResponse.values.byName(
        row.cognitiveResponse,
      ),
      source: row.source,
    );
  }
}
