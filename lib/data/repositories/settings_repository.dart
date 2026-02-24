// lib/data/repositories/settings_repository.dart
import 'dart:async';

import 'package:drift/drift.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';

class SettingsRepository {
  final AppDatabase? _db;

  final _roundSizeCtrl = StreamController<int>.broadcast();
  final _hapticEnabledCtrl = StreamController<bool>.broadcast();
  final _soundEnabledCtrl = StreamController<bool>.broadcast();

  int _roundSize = 7;
  bool _hapticEnabled = true;
  bool _soundEnabled = false;

  SettingsRepository([this._db]);

  Stream<int> watchRoundSize() => _roundSizeCtrl.stream;
  Stream<bool> watchHapticEnabled() => _hapticEnabledCtrl.stream;
  Stream<bool> watchSoundEnabled() => _soundEnabledCtrl.stream;

  int get roundSize => _roundSize;
  bool get hapticEnabled => _hapticEnabled;
  bool get soundEnabled => _soundEnabled;

  Future<void> load() async {
    final db = _db;
    if (db == null) return;

    await _ensureRoundUiSettingsRow(db);
    final row = await (db.select(db.roundUiSettings)..where((t) => t.id.equals(1))).getSingle();
    _roundSize = row.perCategoryLimit.clamp(1, 50);
    _hapticEnabled = row.hapticEnabled;
    _soundEnabled = row.soundEnabled;
    _roundSizeCtrl.add(_roundSize);
    _hapticEnabledCtrl.add(_hapticEnabled);
    _soundEnabledCtrl.add(_soundEnabled);
  }

  Future<void> setRoundSize(int value) async {
    final db = _db;
    final v = value.clamp(1, 50);
    _roundSize = v;
    _roundSizeCtrl.add(_roundSize);

    if (db == null) return;
    await _ensureRoundUiSettingsRow(db);
    await (db.update(db.roundUiSettings)..where((t) => t.id.equals(1))).write(
      RoundUiSettingsCompanion(
        perCategoryLimit: Value(v),
      ),
    );
  }

  Future<void> setHapticEnabled(bool value) async {
    final db = _db;
    _hapticEnabled = value;
    _hapticEnabledCtrl.add(_hapticEnabled);

    if (db == null) return;
    await _ensureRoundUiSettingsRow(db);
    await (db.update(db.roundUiSettings)..where((t) => t.id.equals(1))).write(
      RoundUiSettingsCompanion(
        hapticEnabled: Value(value),
      ),
    );
  }

  Future<void> setSoundEnabled(bool value) async {
    final db = _db;
    _soundEnabled = value;
    _soundEnabledCtrl.add(_soundEnabled);

    if (db == null) return;
    await _ensureRoundUiSettingsRow(db);
    await (db.update(db.roundUiSettings)..where((t) => t.id.equals(1))).write(
      RoundUiSettingsCompanion(
        soundEnabled: Value(value),
      ),
    );
  }

  Future<void> resetRoundDefaults() async {
    await setRoundSize(7);
  }

  Future<void> _ensureRoundUiSettingsRow(AppDatabase db) async {
    await db.into(db.roundUiSettings).insert(
          RoundUiSettingsCompanion.insert(
            id: const Value(1),
            perCategoryLimit: const Value(7),
            hapticEnabled: const Value(true),
            soundEnabled: const Value(false),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  void dispose() {
    _roundSizeCtrl.close();
    _hapticEnabledCtrl.close();
    _soundEnabledCtrl.close();
  }
}
