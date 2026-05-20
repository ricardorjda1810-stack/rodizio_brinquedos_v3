import 'dart:async';

import '../../core/crisis_detection/baseline_profile.dart';
import '../../database/signalflow_database.dart';

class BaselineProfileRepository {
  static const _currentBaselineId = 'current';

  final SignalFlowDatabase? _database;
  final bool persistSyncWrites;
  BaselineProfile? _current;

  BaselineProfileRepository({
    SignalFlowDatabase? database,
    this.persistSyncWrites = false,
  }) : _database = database;

  SignalFlowDatabase get _db => _database ?? SignalFlowDatabase.instance;

  void save(BaselineProfile profile) {
    _current = profile;
    if (persistSyncWrites) {
      unawaited(savePersistent(profile));
    }
  }

  BaselineProfile? getCurrent() {
    return _current;
  }

  void clear() {
    _current = null;
    if (persistSyncWrites) {
      unawaited(clearPersistent());
    }
  }

  Future<void> savePersistent(BaselineProfile profile) async {
    _current = profile;
    await _db
        .into(_db.baselineProfilesTable)
        .insertOnConflictUpdate(
          BaselineProfilesTableCompanion.insert(
            id: _currentBaselineId,
            createdAt: DateTime.now(),
            restingHeartRate: profile.restingHeartRateBpm,
            hrvRmssd: profile.hrvRmssdMs,
            respiratoryRate: profile.respiratoryRate,
            movementIntensity: profile.movementIntensity,
          ),
        );
  }

  Future<BaselineProfile?> loadFromDatabase() async {
    final row = await (_db.select(
      _db.baselineProfilesTable,
    )..where((table) => table.id.equals(_currentBaselineId))).getSingleOrNull();
    _current = row == null ? null : _fromRow(row);
    return _current;
  }

  Future<void> clearPersistent() async {
    _current = null;
    await _db.delete(_db.baselineProfilesTable).go();
  }

  BaselineProfile _fromRow(BaselineProfilesTableData row) {
    return BaselineProfile(
      restingHeartRateBpm: row.restingHeartRate,
      hrvRmssdMs: row.hrvRmssd,
      respiratoryRate: row.respiratoryRate,
      movementIntensity: row.movementIntensity,
    );
  }
}
