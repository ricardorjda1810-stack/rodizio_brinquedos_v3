// lib/data/repositories/settings_repository.dart
import 'dart:async';

import 'package:drift/drift.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';

class SettingsRepository {
  final AppDatabase? _db;

  // Historical/global round size stream. Weekly planning uses this value as the
  // default when a day is configured to follow the global setting.
  final _roundSizeCtrl = StreamController<int>.broadcast();
  final _hapticEnabledCtrl = StreamController<bool>.broadcast();
  final _soundEnabledCtrl = StreamController<bool>.broadcast();
  final _darkModeEnabledCtrl = StreamController<bool>.broadcast();
  final _weeklyPlanningEnabledCtrl = StreamController<bool>.broadcast();

  // Mirrors the `round_ui_settings.per_category_limit` field used by settings
  // and as the global default for weekly planning.
  int _roundSize = 7;
  bool _hapticEnabled = true;
  bool _soundEnabled = false;
  bool _darkModeEnabled = false;
  bool _weeklyPlanningEnabled = false;

  SettingsRepository([this._db]);

  Stream<int> watchRoundSize() => _roundSizeCtrl.stream;
  Stream<bool> watchHapticEnabled() => _hapticEnabledCtrl.stream;
  Stream<bool> watchSoundEnabled() => _soundEnabledCtrl.stream;
  Stream<bool> watchDarkModeEnabled() => _darkModeEnabledCtrl.stream;
  Stream<bool> watchWeeklyPlanningEnabled() =>
      _weeklyPlanningEnabledCtrl.stream;

  int get roundSize => _roundSize;
  bool get hapticEnabled => _hapticEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get weeklyPlanningEnabled => _weeklyPlanningEnabled;

  Future<void> load() async {
    final db = _db;
    if (db == null) return;

    await _ensureRoundUiSettingsRow(db);
    final row = await (db.select(db.roundUiSettings)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    _roundSize = row.perCategoryLimit.clamp(1, 50).toInt();
    _hapticEnabled = row.hapticEnabled;
    _soundEnabled = row.soundEnabled;
    _darkModeEnabled = row.darkModeEnabled;
    _weeklyPlanningEnabled = await _loadWeeklyPlanningEnabled(db);
    _roundSizeCtrl.add(_roundSize);
    _hapticEnabledCtrl.add(_hapticEnabled);
    _soundEnabledCtrl.add(_soundEnabled);
    _darkModeEnabledCtrl.add(_darkModeEnabled);
    _weeklyPlanningEnabledCtrl.add(_weeklyPlanningEnabled);
  }

  // Compatibility-only setter for the historical UI setting.
  Future<void> setRoundSize(int value) async {
    final db = _db;
    final v = value.clamp(1, 50).toInt();
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

  Future<void> setDarkModeEnabled(bool value) async {
    final db = _db;
    _darkModeEnabled = value;
    _darkModeEnabledCtrl.add(_darkModeEnabled);

    if (db == null) return;
    await _ensureRoundUiSettingsRow(db);
    await (db.update(db.roundUiSettings)..where((t) => t.id.equals(1))).write(
      RoundUiSettingsCompanion(
        darkModeEnabled: Value(value),
      ),
    );
  }

  Future<void> setWeeklyPlanningEnabled(bool value) async {
    final db = _db;
    _weeklyPlanningEnabled = value;
    _weeklyPlanningEnabledCtrl.add(_weeklyPlanningEnabled);

    if (db == null) return;
    await _ensureRoundUiSettingsRow(db);
    await db.customUpdate(
      '''
      UPDATE round_ui_settings
      SET weekly_planning_enabled = ?
      WHERE id = 1
      ''',
      variables: [Variable<int>(value ? 1 : 0)],
      updates: {db.roundUiSettings},
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
            darkModeEnabled: const Value(false),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await _ensureWeeklyPlanningColumn(db);
  }

  Future<bool> _loadWeeklyPlanningEnabled(AppDatabase db) async {
    final row = await db.customSelect(
      '''
      SELECT weekly_planning_enabled
      FROM round_ui_settings
      WHERE id = 1
      ''',
      readsFrom: {db.roundUiSettings},
    ).getSingleOrNull();
    return (row?.read<int>('weekly_planning_enabled') ?? 0) != 0;
  }

  Future<void> _ensureWeeklyPlanningColumn(AppDatabase db) async {
    final columns = await db.customSelect(
      'PRAGMA table_info(round_ui_settings)',
      readsFrom: {db.roundUiSettings},
    ).get();
    final exists = columns
        .any((row) => row.read<String>('name') == 'weekly_planning_enabled');
    if (exists) return;

    await db.customStatement(
      '''
      ALTER TABLE round_ui_settings
      ADD COLUMN weekly_planning_enabled INTEGER NOT NULL DEFAULT 0
      ''',
    );
  }

  void dispose() {
    _roundSizeCtrl.close();
    _hapticEnabledCtrl.close();
    _soundEnabledCtrl.close();
    _darkModeEnabledCtrl.close();
    _weeklyPlanningEnabledCtrl.close();
  }
}
