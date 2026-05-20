import 'dart:async';

import 'package:drift/drift.dart';

import '../database/signalflow_database.dart';
import 'research_consent_models.dart';

class ResearchConsentRepository {
  static const _currentConsentId = 'current';

  final SignalFlowDatabase? _database;
  final bool persistSyncWrites;
  ResearchConsent? _current;

  ResearchConsentRepository({
    SignalFlowDatabase? database,
    this.persistSyncWrites = false,
  }) : _database = database;

  SignalFlowDatabase get _db => _database ?? SignalFlowDatabase.instance;

  void save(ResearchConsent consent) {
    _current = consent;
    if (persistSyncWrites) {
      unawaited(savePersistent(consent));
    }
  }

  ResearchConsent? getCurrent() {
    return _current;
  }

  void clear() {
    _current = null;
    if (persistSyncWrites) {
      unawaited(clearPersistent());
    }
  }

  Future<void> savePersistent(ResearchConsent consent) async {
    _current = consent;
    await _db
        .into(_db.researchConsentTable)
        .insertOnConflictUpdate(
          ResearchConsentTableCompanion.insert(
            id: _currentConsentId,
            accepted: consent.accepted,
            acceptedAt: Value(consent.acceptedAt),
            version: consent.version,
            allowsPhysiologicalCollection:
                consent.allowsPhysiologicalCollection,
            allowsResearchExport: consent.allowsResearchExport,
            allowsReplayAnalysis: consent.allowsReplayAnalysis,
          ),
        );
  }

  Future<ResearchConsent?> loadFromDatabase() async {
    final row = await (_db.select(
      _db.researchConsentTable,
    )..where((table) => table.id.equals(_currentConsentId))).getSingleOrNull();
    _current = row == null ? null : _fromRow(row);
    return _current;
  }

  Future<void> clearPersistent() async {
    _current = null;
    await _db.delete(_db.researchConsentTable).go();
  }

  ResearchConsent _fromRow(ResearchConsentTableData row) {
    return ResearchConsent(
      accepted: row.accepted,
      acceptedAt: row.acceptedAt,
      version: row.version,
      allowsPhysiologicalCollection: row.allowsPhysiologicalCollection,
      allowsResearchExport: row.allowsResearchExport,
      allowsReplayAnalysis: row.allowsReplayAnalysis,
    );
  }
}
