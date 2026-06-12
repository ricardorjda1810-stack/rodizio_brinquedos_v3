import 'dart:async';

import 'package:drift/drift.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/weekly_planning/week_day_summary.dart';

class WeeklyPlanningCategoryConfig {
  final String categoryId;
  final String categoryName;
  final bool isIncluded;
  final int quota;

  const WeeklyPlanningCategoryConfig({
    required this.categoryId,
    required this.categoryName,
    required this.isIncluded,
    required this.quota,
  });

  int get safeQuota => quota < 0 ? 0 : quota;
}

class WeeklyPlanningDayConfig {
  final int weekday;
  final bool useDefault;
  final List<WeeklyPlanningCategoryConfig> categories;

  const WeeklyPlanningDayConfig({
    required this.weekday,
    required this.useDefault,
    required this.categories,
  });

  int get total {
    var value = 0;
    for (final category in categories) {
      if (!category.isIncluded) continue;
      value += category.safeQuota;
    }
    return value;
  }
}

class CategoryBalanceAdjustmentSuggestion {
  final String categoryId;
  final String categoryName;
  final String message;
  final int targetWeekday;
  final int deltaQuota;

  const CategoryBalanceAdjustmentSuggestion({
    required this.categoryId,
    required this.categoryName,
    required this.message,
    required this.targetWeekday,
    this.deltaQuota = 1,
  });
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
      await _ensureCategoryRowsForWeekday(weekday);
    }
  }

  Future<List<WeeklyPlanningDayConfig>> getAll() async {
    await ensureSeeded();
    final rows = await _orderedDayQuery().get();
    final result = <WeeklyPlanningDayConfig>[];
    for (final row in rows) {
      result.add(await _toDayConfig(row));
    }
    return result;
  }

  Stream<List<WeeklyPlanningDayConfig>> watchAll() {
    return _watchPlanningChanges().asyncMap((_) => getAll());
  }

  Stream<List<WeekDaySummary>> watchWeekSummary() {
    return _watchPlanningChanges().asyncMap((_) => _buildWeekSummary());
  }

  Future<WeeklyPlanningDayConfig?> getByWeekday(int weekday) async {
    if (!_isValidWeekday(weekday)) return null;

    await ensureSeeded();
    final row = await (_db.select(_db.weeklyPlanningSettings)
          ..where((table) => table.weekday.equals(weekday)))
        .getSingleOrNull();
    return row == null ? null : _toDayConfig(row);
  }

  Future<void> setUseDefault({
    required int weekday,
    required bool useDefault,
  }) async {
    if (!_isValidWeekday(weekday)) {
      throw ArgumentError.value(
          weekday, 'weekday', 'Use DateTime.weekday 1..7');
    }

    await ensureSeeded();
    final current = await _dayRowForWeekday(weekday);
    if (!useDefault && (current == null || current.useDefault)) {
      await _resetWeeklyCategoryRowsFromDefault(weekday);
    } else {
      await _ensureCategoryRowsForWeekday(weekday);
    }
    await (_db.update(_db.weeklyPlanningSettings)
          ..where((table) => table.weekday.equals(weekday)))
        .write(
      WeeklyPlanningSettingsCompanion(
        useDefault: Value(useDefault),
        customSize: const Value(null),
      ),
    );
  }

  Future<void> updateCategoryConfig({
    required int weekday,
    required String categoryId,
    required bool isIncluded,
    required int quota,
  }) async {
    if (!_isValidWeekday(weekday)) {
      throw ArgumentError.value(
          weekday, 'weekday', 'Use DateTime.weekday 1..7');
    }
    final normalizedCategoryId = categoryId.trim();
    if (normalizedCategoryId.isEmpty) {
      throw ArgumentError.value(categoryId, 'categoryId', 'Use a valid id');
    }

    await ensureSeeded();
    await _writeWeeklyCategoryConfig(
      weekday: weekday,
      categoryId: normalizedCategoryId,
      isIncluded: isIncluded,
      quota: quota,
    );
  }

  Future<void> restoreDefaultWeek() async {
    await ensureSeeded();

    await _db.transaction(() async {
      await _restoreRoundCategoryDefaults();

      for (var weekday = DateTime.monday;
          weekday <= DateTime.sunday;
          weekday++) {
        await (_db.update(_db.weeklyPlanningSettings)
              ..where((table) => table.weekday.equals(weekday)))
            .write(
          const WeeklyPlanningSettingsCompanion(
            useDefault: Value(true),
            customSize: Value(null),
          ),
        );
        await (_db.delete(_db.weeklyPlanningCategorySettings)
              ..where((table) => table.weekday.equals(weekday)))
            .go();
      }
    });
  }

  Future<CategoryBalanceAdjustmentSuggestion?>
      suggestCategoryBalanceAdjustment({
    DateTime? now,
  }) async {
    await ensureSeeded();

    final reference = now ?? DateTime.now();
    final cutoff =
        reference.subtract(const Duration(days: 7)).millisecondsSinceEpoch;

    final categories = await (_db.select(_db.categoryDefinitions)
          ..where((category) => category.isActive.equals(true))
          ..orderBy([
            (category) => OrderingTerm.asc(category.sortOrder),
            (category) => OrderingTerm.asc(category.name),
          ]))
        .get();
    if (categories.length < 2) return null;

    final availableCounts = <String, int>{};
    final toys = await _db.select(_db.toys).get();
    for (final toy in toys) {
      final categoryId = toy.categoryId.trim();
      if (categoryId.isEmpty) continue;
      availableCounts[categoryId] = (availableCounts[categoryId] ?? 0) + 1;
    }

    final eligibleCategories = categories
        .where((category) => (availableCounts[category.id] ?? 0) > 0)
        .toList(growable: false);
    if (eligibleCategories.length < 2) return null;

    final recentCounts = <String, int>{
      for (final category in eligibleCategories) category.id: 0,
    };
    final r = _db.rounds;
    final rt = _db.roundToys;
    final t = _db.toys;
    final recentRows = await (_db.select(rt).join([
      innerJoin(r, r.id.equalsExp(rt.roundId)),
      innerJoin(t, t.id.equalsExp(rt.toyId)),
    ])
          ..where(r.startAt.isBiggerOrEqualValue(cutoff)))
        .get();

    for (final row in recentRows) {
      final toy = row.readTable(t);
      final categoryId = toy.categoryId.trim();
      if (!recentCounts.containsKey(categoryId)) continue;
      recentCounts[categoryId] = (recentCounts[categoryId] ?? 0) + 1;
    }

    final sortedByPresence = eligibleCategories.toList(growable: false)
      ..sort((a, b) {
        final byCount =
            (recentCounts[a.id] ?? 0).compareTo(recentCounts[b.id] ?? 0);
        if (byCount != 0) return byCount;
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final leastPresent = sortedByPresence.first;
    final minCount = recentCounts[leastPresent.id] ?? 0;
    final maxCount = recentCounts.values.fold<int>(
      0,
      (currentMax, count) => count > currentMax ? count : currentMax,
    );
    if (minCount == maxCount) return null;

    final categoryName = leastPresent.name.trim();
    return CategoryBalanceAdjustmentSuggestion(
      categoryId: leastPresent.id,
      categoryName: categoryName,
      targetWeekday: _nextWeekday(reference.weekday),
      message:
          '$categoryName apareceu pouco esta semana. Deseja incluir mais 1 brinquedo de $categoryName no planejamento de amanh\u00E3?',
    );
  }

  Future<void> applyCategoryBalanceAdjustment(
    CategoryBalanceAdjustmentSuggestion suggestion,
  ) async {
    if (!_isValidWeekday(suggestion.targetWeekday)) return;

    await ensureSeeded();
    final current = await _dayRowForWeekday(suggestion.targetWeekday);
    if (current == null || current.useDefault) {
      await _resetWeeklyCategoryRowsFromDefault(suggestion.targetWeekday);
    } else {
      await _ensureCategoryRowsForWeekday(suggestion.targetWeekday);
    }
    final configs = await _loadCustomCategoryConfigs(suggestion.targetWeekday);
    final target = configs.where((category) {
      return category.categoryId == suggestion.categoryId;
    }).firstOrNull;
    if (target == null) return;

    final total = _sumIncludedQuotas(configs);
    final reducers = configs.where((category) {
      return category.categoryId != suggestion.categoryId &&
          category.isIncluded &&
          category.safeQuota > 0;
    }).toList(growable: false)
      ..sort((a, b) {
        final byQuota = b.safeQuota.compareTo(a.safeQuota);
        if (byQuota != 0) return byQuota;
        return a.categoryName.toLowerCase().compareTo(
              b.categoryName.toLowerCase(),
            );
      });

    final reducer = total >= 7 && reducers.isNotEmpty ? reducers.first : null;

    await _db.transaction(() async {
      await (_db.update(_db.weeklyPlanningSettings)
            ..where((table) => table.weekday.equals(suggestion.targetWeekday)))
          .write(
        const WeeklyPlanningSettingsCompanion(
          useDefault: Value(false),
          customSize: Value(null),
        ),
      );

      await _writeWeeklyCategoryConfig(
        weekday: suggestion.targetWeekday,
        categoryId: target.categoryId,
        isIncluded: true,
        quota: target.safeQuota + suggestion.deltaQuota,
      );

      if (reducer != null) {
        final nextQuota = reducer.safeQuota - 1;
        await _writeWeeklyCategoryConfig(
          weekday: suggestion.targetWeekday,
          categoryId: reducer.categoryId,
          isIncluded: nextQuota > 0,
          quota: nextQuota < 0 ? 0 : nextQuota,
        );
      }
    });
  }

  Future<List<WeeklyPlanningCategoryConfig>> getCategoriesForWeekday(
    int weekday,
  ) async {
    if (!_isValidWeekday(weekday)) {
      return const <WeeklyPlanningCategoryConfig>[];
    }

    await ensureSeeded();
    await _ensureCategoryRowsForWeekday(weekday);
    return _loadCustomCategoryConfigs(weekday);
  }

  Stream<List<WeeklyPlanningCategoryConfig>> watchCategoriesForWeekday(
    int weekday,
  ) {
    if (!_isValidWeekday(weekday)) {
      return const Stream<List<WeeklyPlanningCategoryConfig>>.empty();
    }

    return _watchPlanningChanges().asyncMap((_) => getCategoriesForWeekday(
          weekday,
        ));
  }

  Future<List<WeeklyPlanningCategoryConfig>> getDefaultCategoryConfig() async {
    return _loadDefaultCategoryConfigs();
  }

  Stream<List<WeeklyPlanningCategoryConfig>> watchDefaultCategoryConfig() {
    return _watchPlanningChanges().asyncMap((_) => getDefaultCategoryConfig());
  }

  Future<List<WeeklyPlanningCategoryConfig>> resolveCategoryConfigForDate(
    DateTime date,
  ) async {
    final defaultConfig = await _loadDefaultCategoryConfigs();
    if (!_settingsRepository.weeklyPlanningEnabled) return defaultConfig;

    final day = await getByWeekday(date.weekday);
    if (day == null || day.useDefault) return defaultConfig;

    final customConfig = await _loadCustomCategoryConfigs(date.weekday);
    if (!_hasValidIncludedQuota(customConfig)) return defaultConfig;
    return customConfig;
  }

  Stream<void> _watchPlanningChanges() {
    return Stream<void>.multi((controller) {
      var closed = false;
      final subscriptions = <StreamSubscription<dynamic>>[];

      void emit() {
        if (!closed) controller.add(null);
      }

      subscriptions.add(
        _db.select(_db.weeklyPlanningSettings).watch().listen((_) => emit()),
      );
      subscriptions.add(
        _db
            .select(_db.weeklyPlanningCategorySettings)
            .watch()
            .listen((_) => emit()),
      );
      subscriptions.add(
        _db.select(_db.roundCategorySettings).watch().listen((_) => emit()),
      );
      subscriptions.add(
        _db.select(_db.roundUiSettings).watch().listen((_) => emit()),
      );
      subscriptions.add(
        _db.select(_db.categoryDefinitions).watch().listen((_) => emit()),
      );

      emit();

      controller.onCancel = () async {
        closed = true;
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      };
    });
  }

  Selectable<WeeklyPlanningSetting> _orderedDayQuery() {
    return _db.select(_db.weeklyPlanningSettings)
      ..orderBy([
        (table) => OrderingTerm.asc(table.weekday),
      ]);
  }

  Future<WeeklyPlanningSetting?> _dayRowForWeekday(int weekday) {
    return (_db.select(_db.weeklyPlanningSettings)
          ..where((table) => table.weekday.equals(weekday)))
        .getSingleOrNull();
  }

  Future<WeeklyPlanningDayConfig> _toDayConfig(
    WeeklyPlanningSetting row,
  ) async {
    final categories = row.useDefault
        ? await _loadDefaultCategoryConfigs()
        : await _loadCustomCategoryConfigs(row.weekday);
    return WeeklyPlanningDayConfig(
      weekday: row.weekday,
      useDefault: row.useDefault,
      categories: categories,
    );
  }

  Future<List<WeekDaySummary>> _buildWeekSummary() async {
    await ensureSeeded();
    final defaultCategories = await _loadDefaultCategoryConfigs();
    final defaultTotal = _sumIncludedQuotas(defaultCategories);
    final today = DateTime.now().weekday;
    final planningEnabled = _settingsRepository.weeklyPlanningEnabled;
    final rows = await _orderedDayQuery().get();
    final rowsByWeekday = <int, WeeklyPlanningSetting>{
      for (final row in rows) row.weekday: row,
    };

    final result = <WeekDaySummary>[];
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final row = rowsByWeekday[weekday];
      final usesDefault = !planningEnabled || row == null || row.useDefault;
      final total = usesDefault
          ? defaultTotal
          : _sumIncludedQuotas(await _loadCustomCategoryConfigs(weekday));

      result.add(
        WeekDaySummary(
          weekday: weekday,
          shortLabel: _shortWeekdayLabel(weekday),
          fullLabel: _fullWeekdayLabel(weekday),
          totalToys: total,
          usesDefault: usesDefault,
          isToday: weekday == today,
        ),
      );
    }
    return result;
  }

  Future<List<WeeklyPlanningCategoryConfig>> _loadDefaultCategoryConfigs() {
    final c = _db.categoryDefinitions;
    final s = _db.roundCategorySettings;

    final query = _db.select(c).join([
      leftOuterJoin(s, s.categoryId.equalsExp(c.id)),
    ])
      ..where(c.isActive.equals(true))
      ..orderBy([
        OrderingTerm.asc(c.sortOrder),
        OrderingTerm.asc(c.name),
      ]);

    return query.get().then(
          (rows) => rows.map((row) {
            final category = row.readTable(c);
            final setting = row.readTableOrNull(s);
            return WeeklyPlanningCategoryConfig(
              categoryId: category.id,
              categoryName: category.name,
              isIncluded: setting?.isIncluded ?? true,
              quota: setting?.quota ?? 1,
            );
          }).toList(growable: false),
        );
  }

  Future<List<WeeklyPlanningCategoryConfig>> _loadCustomCategoryConfigs(
    int weekday,
  ) async {
    await _ensureCategoryRowsForWeekday(weekday);

    final c = _db.categoryDefinitions;
    final s = _db.weeklyPlanningCategorySettings;

    final query = _db.select(c).join([
      leftOuterJoin(
        s,
        s.categoryId.equalsExp(c.id) & s.weekday.equals(weekday),
      ),
    ])
      ..where(c.isActive.equals(true))
      ..orderBy([
        OrderingTerm.asc(c.sortOrder),
        OrderingTerm.asc(c.name),
      ]);

    final rows = await query.get();
    return rows.map((row) {
      final category = row.readTable(c);
      final setting = row.readTableOrNull(s);
      return WeeklyPlanningCategoryConfig(
        categoryId: category.id,
        categoryName: category.name,
        isIncluded: setting?.isIncluded ?? true,
        quota: setting?.quota ?? 1,
      );
    }).toList(growable: false);
  }

  Future<void> _ensureCategoryRowsForWeekday(int weekday) async {
    final defaults = await _loadDefaultCategoryConfigs();
    for (final category in defaults) {
      await _db.into(_db.weeklyPlanningCategorySettings).insert(
            WeeklyPlanningCategorySettingsCompanion.insert(
              weekday: weekday,
              categoryId: category.categoryId,
              isIncluded: Value(category.isIncluded),
              quota: Value(category.safeQuota),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<void> _resetWeeklyCategoryRowsFromDefault(int weekday) async {
    final defaults = await _loadDefaultCategoryConfigs();
    await (_db.delete(_db.weeklyPlanningCategorySettings)
          ..where((table) => table.weekday.equals(weekday)))
        .go();

    for (final category in defaults) {
      await _writeWeeklyCategoryConfig(
        weekday: weekday,
        categoryId: category.categoryId,
        isIncluded: category.isIncluded,
        quota: category.safeQuota,
      );
    }
  }

  Future<void> _writeWeeklyCategoryConfig({
    required int weekday,
    required String categoryId,
    required bool isIncluded,
    required int quota,
  }) {
    return _db.into(_db.weeklyPlanningCategorySettings).insertOnConflictUpdate(
          WeeklyPlanningCategorySettingsCompanion.insert(
            weekday: weekday,
            categoryId: categoryId,
            isIncluded: Value(isIncluded),
            quota: Value(quota < 0 ? 0 : quota),
          ),
        );
  }

  Future<void> _restoreRoundCategoryDefaults() async {
    const defaultQuotas = <String, int>{
      'livros': 1,
      'construcao': 2,
      'faz_de_conta': 1,
      'movimento': 1,
      'coordenacao': 2,
    };

    final categories = await _db.select(_db.categoryDefinitions).get();
    for (final category in categories) {
      final quota = defaultQuotas[category.id] ?? 0;
      await _db.into(_db.roundCategorySettings).insertOnConflictUpdate(
            RoundCategorySettingsCompanion.insert(
              categoryId: category.id,
              isIncluded: Value(quota > 0),
              quota: Value(quota),
            ),
          );
    }
  }

  bool _hasValidIncludedQuota(List<WeeklyPlanningCategoryConfig> categories) {
    for (final category in categories) {
      if (category.isIncluded && category.safeQuota > 0) return true;
    }
    return false;
  }

  int _sumIncludedQuotas(List<WeeklyPlanningCategoryConfig> categories) {
    var total = 0;
    for (final category in categories) {
      if (!category.isIncluded) continue;
      total += category.safeQuota;
    }
    return total;
  }

  String _shortWeekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Seg';
      case DateTime.tuesday:
        return 'Ter';
      case DateTime.wednesday:
        return 'Qua';
      case DateTime.thursday:
        return 'Qui';
      case DateTime.friday:
        return 'Sex';
      case DateTime.saturday:
        return 'Sáb';
      case DateTime.sunday:
        return 'Dom';
      default:
        return '';
    }
  }

  String _fullWeekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Segunda-feira';
      case DateTime.tuesday:
        return 'Terça-feira';
      case DateTime.wednesday:
        return 'Quarta-feira';
      case DateTime.thursday:
        return 'Quinta-feira';
      case DateTime.friday:
        return 'Sexta-feira';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return '';
    }
  }

  bool _isValidWeekday(int weekday) {
    return weekday >= DateTime.monday && weekday <= DateTime.sunday;
  }

  int _nextWeekday(int weekday) {
    if (!_isValidWeekday(weekday)) return DateTime.monday;
    return weekday == DateTime.sunday ? DateTime.monday : weekday + 1;
  }
}
