import 'package:drift/drift.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';

class WeeklyPlanningDayConfig {
  final int weekday;
  final bool useDefault;
  final int? customSize;

  const WeeklyPlanningDayConfig({
    required this.weekday,
    required this.useDefault,
    required this.customSize,
  });

  bool get hasValidCustomSize =>
      customSize != null && customSize! >= 1 && customSize! <= 15;
}

class WeeklyPlanningRepository {
  final AppDatabase _db;
  final SettingsRepository _settingsRepository;

  const WeeklyPlanningRepository({
    required AppDatabase db,
    required SettingsRepository settingsRepository,
  })  : _db = db,
        _settingsRepository = settingsRepository;

  Future<void> ensureSeeded() async {
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      await _db.into(_db.weeklyPlanningSettings).insert(
            WeeklyPlanningSettingsCompanion.insert(
              weekday: Value(weekday),
              useDefault: const Value(true),
              customSize: const Value(null),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<List<WeeklyPlanningDayConfig>> getAll() async {
    await ensureSeeded();
    final rows = await _orderedQuery().get();
    return rows.map(_toConfig).toList(growable: false);
  }

  Stream<List<WeeklyPlanningDayConfig>> watchAll() {
    return Stream.fromFuture(ensureSeeded()).asyncExpand(
      (_) => _orderedQuery().watch().map(
            (rows) => rows.map(_toConfig).toList(growable: false),
          ),
    );
  }

  Future<WeeklyPlanningDayConfig?> getByWeekday(int weekday) async {
    if (!_isValidWeekday(weekday)) return null;

    await ensureSeeded();
    final row = await (_db.select(_db.weeklyPlanningSettings)
          ..where((table) => table.weekday.equals(weekday)))
        .getSingleOrNull();
    return row == null ? null : _toConfig(row);
  }

  Future<void> updateDayConfig({
    required int weekday,
    required bool useDefault,
    required int? customSize,
  }) async {
    if (!_isValidWeekday(weekday)) {
      throw ArgumentError.value(
        weekday,
        'weekday',
        'Use DateTime.weekday 1..7',
      );
    }
    if (!useDefault && !_isValidCustomSize(customSize)) {
      throw ArgumentError.value(
        customSize,
        'customSize',
        'Use null when useDefault is true, or an integer from 1 to 15.',
      );
    }

    await ensureSeeded();
    await (_db.update(_db.weeklyPlanningSettings)
          ..where((table) => table.weekday.equals(weekday)))
        .write(
      WeeklyPlanningSettingsCompanion(
        useDefault: Value(useDefault),
        customSize: Value(useDefault ? null : customSize),
      ),
    );
  }

  Future<int> resolveRoundSizeForDate(DateTime date) async {
    final defaultSize = _safeDefaultRoundSize;
    if (!_settingsRepository.weeklyPlanningEnabled) return defaultSize;

    final config = await getByWeekday(date.weekday);
    if (config == null || config.useDefault || !config.hasValidCustomSize) {
      return defaultSize;
    }

    return config.customSize!;
  }

  Selectable<WeeklyPlanningSetting> _orderedQuery() {
    return _db.select(_db.weeklyPlanningSettings)
      ..orderBy([
        (table) => OrderingTerm.asc(table.weekday),
      ]);
  }

  WeeklyPlanningDayConfig _toConfig(WeeklyPlanningSetting row) {
    return WeeklyPlanningDayConfig(
      weekday: row.weekday,
      useDefault: row.useDefault,
      customSize: row.customSize,
    );
  }

  int get _safeDefaultRoundSize =>
      _settingsRepository.roundSize.clamp(1, 15).toInt();

  bool _isValidWeekday(int weekday) {
    return weekday >= DateTime.monday && weekday <= DateTime.sunday;
  }

  bool _isValidCustomSize(int? customSize) {
    return customSize != null && customSize >= 1 && customSize <= 15;
  }
}
