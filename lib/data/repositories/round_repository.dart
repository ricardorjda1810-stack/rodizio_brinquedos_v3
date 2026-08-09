import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/first_round_analytics_coordinator.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/weekly_planning_repository.dart';
import 'package:rodizio_brinquedos_v3/domain/child_age/age_preset.dart';

class RoundToyWithBox {
  final Toy toy;
  final Boxe? box;
  final int position;

  const RoundToyWithBox({
    required this.toy,
    required this.box,
    required this.position,
  });
}

class RoundChecklistProgress {
  final int collectedCount;
  final int totalCount;

  const RoundChecklistProgress({
    required this.collectedCount,
    required this.totalCount,
  });

  factory RoundChecklistProgress.fromToyIds(
    Iterable<String> toyIds,
    Map<String, bool> checklistByToyId,
  ) {
    final uniqueToyIds = <String>{};
    for (final toyId in toyIds) {
      final normalized = toyId.trim();
      if (normalized.isNotEmpty) uniqueToyIds.add(normalized);
    }

    final collected =
        uniqueToyIds.where((toyId) => checklistByToyId[toyId] == true).length;

    return RoundChecklistProgress(
      collectedCount: collected,
      totalCount: uniqueToyIds.length,
    );
  }

  bool get isReady => totalCount > 0 && collectedCount >= totalCount;

  double get fraction => totalCount == 0
      ? 0
      : (collectedCount / totalCount).clamp(0, 1).toDouble();

  String get label {
    if (isReady) return 'Rodada pronta';
    return '$collectedCount de $totalCount brinquedos separados';
  }
}

class CategoryDistributionItem {
  final String categoryId;
  final String categoryLabel;
  final int count;
  final double percentage;

  const CategoryDistributionItem({
    required this.categoryId,
    required this.categoryLabel,
    required this.count,
    required this.percentage,
  });
}

class CategoryDistributionStats {
  final int total;
  final List<CategoryDistributionItem> items;
  final String suggestion;
  final bool canOptimize;
  final String? dominantCategoryId;
  final String? dominantCategoryLabel;
  final String? lowCategoryId;
  final String? lowCategoryLabel;

  const CategoryDistributionStats({
    required this.total,
    required this.items,
    required this.suggestion,
    required this.canOptimize,
    this.dominantCategoryId,
    this.dominantCategoryLabel,
    this.lowCategoryId,
    this.lowCategoryLabel,
  });
}

class OptimizeActiveRoundResult {
  final bool success;
  final String reason;
  final String? removedToyId;
  final String? addedToyId;
  final String? removedCategory;
  final String? addedCategory;
  final String? removedToyName;
  final String? addedToyName;

  const OptimizeActiveRoundResult({
    required this.success,
    required this.reason,
    this.removedToyId,
    this.addedToyId,
    this.removedCategory,
    this.addedCategory,
    this.removedToyName,
    this.addedToyName,
  });
}

class StartRoundResult {
  final bool created;
  final int selectedCount;

  const StartRoundResult({
    required this.created,
    required this.selectedCount,
  });

  const StartRoundResult.notCreated()
      : created = false,
        selectedCount = 0;

  const StartRoundResult.createdWithCount(int count)
      : created = true,
        selectedCount = count;
}

class _BalanceCategoryInfo {
  final String id;
  final String label;
  final int count;
  final double percentage;

  const _BalanceCategoryInfo({
    required this.id,
    required this.label,
    required this.count,
    required this.percentage,
  });
}

class _BalanceEvaluation {
  final int total;
  final List<_BalanceCategoryInfo> categories;
  final _BalanceCategoryInfo? dominant;
  final _BalanceCategoryInfo? low;
  final String suggestion;

  const _BalanceEvaluation({
    required this.total,
    required this.categories,
    required this.dominant,
    required this.low,
    required this.suggestion,
  });

  bool get canOptimize => total >= 10 && dominant != null && low != null;
}

class _ActiveRoundToy {
  final String toyId;
  final String toyName;
  final String categoryId;
  final String categoryLabel;
  final int position;

  const _ActiveRoundToy({
    required this.toyId,
    required this.toyName,
    required this.categoryId,
    required this.categoryLabel,
    required this.position,
  });
}

class _ToyCandidate {
  final String toyId;
  final String toyName;
  final String categoryId;
  final String categoryLabel;

  const _ToyCandidate({
    required this.toyId,
    required this.toyName,
    required this.categoryId,
    required this.categoryLabel,
  });
}

class _WeeklyPlanningToyPool {
  final List<Toy> toys;
  int cursor;

  _WeeklyPlanningToyPool(this.toys) : cursor = 0;
}

class _ToyUsageStats {
  int usageCount;
  int? lastUsedAt;

  _ToyUsageStats({
    required this.usageCount,
    required this.lastUsedAt,
  });

  _ToyUsageStats copy() {
    return _ToyUsageStats(
      usageCount: usageCount,
      lastUsedAt: lastUsedAt,
    );
  }
}

class _RoundSelectionContext {
  final Set<String> lastRoundToyIds;
  final Map<String, _ToyUsageStats> usageByToyId;

  const _RoundSelectionContext({
    required this.lastRoundToyIds,
    required this.usageByToyId,
  });
}

class _DayBounds {
  final int startAt;
  final int endAt;

  const _DayBounds({
    required this.startAt,
    required this.endAt,
  });
}

class RoundRepository {
  static const String _demoActiveRoundId = 'demo_active_round';

  final AppDatabase? db;
  final WeeklyPlanningRepository? _weeklyPlanningRepository;
  FirstRoundAnalyticsCoordinator? _firstRoundAnalyticsCoordinator;

  RoundRepository(
    this.db, [
    this._weeklyPlanningRepository,
    FirstRoundAnalyticsCoordinator? firstRoundAnalyticsCoordinator,
  ]) : _firstRoundAnalyticsCoordinator = firstRoundAnalyticsCoordinator;

  void attachFirstRoundAnalytics(
    FirstRoundAnalyticsCoordinator coordinator,
  ) {
    _firstRoundAnalyticsCoordinator = coordinator;
  }

  static const String insufficientTotalReason = 'insufficient_total';
  static const String noDominantOrLowReason = 'no_dominant_or_low';
  static const String noDominantInRoundReason = 'no_dominant_in_round';
  static const String noCandidateToAddReason = 'no_candidate_to_add';
  static const String noActiveRoundReason = 'no_active_round';

  static String checklistDateKey(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  Stream<Round?> watchActiveRound() {
    final d = db;
    if (d == null) return const Stream<Round?>.empty();

    final query = d.select(d.rounds)
      ..where((r) => r.endAt.isNull())
      ..limit(1);

    return query.watchSingleOrNull();
  }

  Stream<List<RoundToyWithBox>> watchActiveRoundToysWithBox() {
    final d = db;
    if (d == null) return const Stream<List<RoundToyWithBox>>.empty();

    final r = d.rounds;
    final rt = d.roundToys;
    final t = d.toys;
    final b = d.boxes;

    final query = d.select(rt).join([
      innerJoin(r, r.id.equalsExp(rt.roundId) & r.endAt.isNull()),
      innerJoin(t, t.id.equalsExp(rt.toyId)),
      leftOuterJoin(b, b.id.equalsExp(t.boxId)),
    ])
      ..orderBy([
        OrderingTerm(expression: rt.position, mode: OrderingMode.asc),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return RoundToyWithBox(
          toy: row.readTable(t),
          box: row.readTableOrNull(b),
          position: row.readTable(rt).position,
        );
      }).toList();
    });
  }

  Stream<Map<String, bool>> watchRoundChecklistForDate(DateTime date) {
    final d = db;
    if (d == null) return Stream.value(const <String, bool>{});

    final dateKey = checklistDateKey(date);
    final query = d.select(d.roundToyChecklistItems)
      ..where((row) => row.dateKey.equals(dateKey));

    return query.watch().map(
          (rows) => <String, bool>{
            for (final row in rows) row.toyId: row.collected,
          },
        );
  }

  Future<Map<String, bool>> loadRoundChecklistForDate(DateTime date) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final dateKey = checklistDateKey(date);
    final rows = await (d.select(d.roundToyChecklistItems)
          ..where((row) => row.dateKey.equals(dateKey)))
        .get();

    return <String, bool>{
      for (final row in rows) row.toyId: row.collected,
    };
  }

  Future<bool> toggleToyCollectedForDate({
    required DateTime date,
    required String toyId,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final normalizedToyId = toyId.trim();
    if (normalizedToyId.isEmpty) return false;

    final dateKey = checklistDateKey(date);
    final existing = await (d.select(d.roundToyChecklistItems)
          ..where(
            (row) =>
                row.dateKey.equals(dateKey) & row.toyId.equals(normalizedToyId),
          ))
        .getSingleOrNull();
    final nextCollected = !(existing?.collected ?? false);

    await setToyCollectedForDate(
      date: date,
      toyId: normalizedToyId,
      collected: nextCollected,
    );

    return nextCollected;
  }

  Future<void> setToyCollectedForDate({
    required DateTime date,
    required String toyId,
    required bool collected,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final normalizedToyId = toyId.trim();
    if (normalizedToyId.isEmpty) return;

    await d.into(d.roundToyChecklistItems).insertOnConflictUpdate(
          RoundToyChecklistItemsCompanion.insert(
            dateKey: checklistDateKey(date),
            toyId: normalizedToyId,
            collected: Value(collected),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> clearRoundChecklistForDate(DateTime date) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final dateKey = checklistDateKey(date);
    await (d.delete(d.roundToyChecklistItems)
          ..where((row) => row.dateKey.equals(dateKey)))
        .go();
  }

  Future<CategoryDistributionStats> getCategoryDistributionForStats() async {
    final d = db;
    if (d == null) {
      return const CategoryDistributionStats(
        total: 0,
        items: <CategoryDistributionItem>[],
        suggestion:
            'Cadastre pelo menos 10 brinquedos para o equilíbrio por categorias funcionar.',
        canOptimize: false,
      );
    }

    final evaluation = await _evaluateCategoryBalance(d);
    return CategoryDistributionStats(
      total: evaluation.total,
      items: evaluation.categories
          .map(
            (item) => CategoryDistributionItem(
              categoryId: item.id,
              categoryLabel: item.label,
              count: item.count,
              percentage: item.percentage,
            ),
          )
          .toList(growable: false),
      suggestion: evaluation.suggestion,
      canOptimize: evaluation.canOptimize,
      dominantCategoryId: evaluation.dominant?.id,
      dominantCategoryLabel: evaluation.dominant?.label,
      lowCategoryId: evaluation.low?.id,
      lowCategoryLabel: evaluation.low?.label,
    );
  }

  Future<OptimizeActiveRoundResult>
      optimizeActiveRoundByCategoryBalance() async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final activeRound = await (d.select(d.rounds)
          ..where((r) => r.endAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (activeRound == null) {
      return const OptimizeActiveRoundResult(
        success: false,
        reason: noActiveRoundReason,
      );
    }

    final evaluation = await _evaluateCategoryBalance(d);
    if (evaluation.total < 10) {
      return const OptimizeActiveRoundResult(
        success: false,
        reason: insufficientTotalReason,
      );
    }
    if (evaluation.dominant == null || evaluation.low == null) {
      return const OptimizeActiveRoundResult(
        success: false,
        reason: noDominantOrLowReason,
      );
    }

    final activeRoundToys = await _loadActiveRoundToys(d, activeRound.id);
    final toRemove = activeRoundToys.lastWhere(
      (item) => item.categoryId == evaluation.dominant!.id,
      orElse: () => const _ActiveRoundToy(
        toyId: '',
        toyName: '',
        categoryId: '',
        categoryLabel: '',
        position: -1,
      ),
    );
    if (toRemove.toyId.isEmpty) {
      return const OptimizeActiveRoundResult(
        success: false,
        reason: noDominantInRoundReason,
      );
    }

    final activeToyIds = {for (final item in activeRoundToys) item.toyId};
    final candidateToAdd = await _loadLowCategoryCandidate(
      d,
      excludedToyIds: activeToyIds,
      lowCategoryId: evaluation.low!.id,
    );
    if (candidateToAdd == null) {
      return const OptimizeActiveRoundResult(
        success: false,
        reason: noCandidateToAddReason,
      );
    }

    await d.transaction(() async {
      await (d.delete(d.roundToys)
            ..where((rt) =>
                rt.roundId.equals(activeRound.id) &
                rt.toyId.equals(toRemove.toyId)))
          .go();

      await d.into(d.roundToys).insert(
            RoundToysCompanion.insert(
              roundId: activeRound.id,
              toyId: candidateToAdd.toyId,
              position: toRemove.position,
            ),
          );

      await d.into(d.historyEvents).insert(
            HistoryEventsCompanion.insert(
              eventType: 'round_optimized',
              createdAt: DateTime.now().millisecondsSinceEpoch,
              payload: jsonEncode({
                'roundId': activeRound.id,
                'removedToyId': toRemove.toyId,
                'addedToyId': candidateToAdd.toyId,
                'dominantCategory': evaluation.dominant!.label,
                'lowCategory': evaluation.low!.label,
                'strategyVersion': 'opt_v1',
                'totalToysConsidered': evaluation.total,
                'dominantPct': evaluation.dominant!.percentage,
                'lowPct': evaluation.low!.percentage,
              }),
            ),
          );
    });

    return OptimizeActiveRoundResult(
      success: true,
      reason: 'success',
      removedToyId: toRemove.toyId,
      addedToyId: candidateToAdd.toyId,
      removedCategory: toRemove.categoryLabel,
      addedCategory: candidateToAdd.categoryLabel,
      removedToyName: toRemove.toyName,
      addedToyName: candidateToAdd.toyName,
    );
  }

  // `size` remains in the public API for compatibility. The effective round
  // size is derived from the sum of included category quotas.
  Future<StartRoundResult> startRound({
    int? size,
    DateTime? date,
    RoundCreationSource source = RoundCreationSource.roundManual,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final roundDate = date ?? DateTime.now();
    final selected = await suggestRoundForDate(roundDate);
    if (selected.isEmpty) {
      return const StartRoundResult.notCreated();
    }

    final validated = await _validateToyIdsForDate(
      d,
      selected.map((toy) => toy.id),
      roundDate,
    );
    await _writeEffectiveRoundForDate(
      d,
      roundDate,
      validated,
      source: source,
    );
    return StartRoundResult.createdWithCount(validated.length);
  }

  Future<List<WeeklyPlanningCategoryConfig>>
      _resolveRoundCategoryConfigsForDate(
    DateTime date,
    AppDatabase d,
  ) async {
    final weeklyPlanningRepository = _weeklyPlanningRepository;
    if (weeklyPlanningRepository != null) {
      return weeklyPlanningRepository.resolveCategoryConfigForDate(date);
    }

    final settingsRepository = SettingsRepository(d);
    await settingsRepository.load();
    return WeeklyPlanningRepository(
      db: d,
      settingsRepository: settingsRepository,
    ).resolveCategoryConfigForDate(date);
  }

  Future<List<Toy>> suggestRoundForToday() {
    return suggestRoundForDate(DateTime.now());
  }

  Future<Map<int, List<Toy>>> suggestWeeklyPlanningForWeek(
    DateTime weekStart,
  ) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final normalizedWeekStart = _startOfWeek(weekStart);
    final selectionContext = await _loadSelectionContextForDate(
      d,
      normalizedWeekStart,
      includeSameDayRoundAsPrevious: false,
    );
    var lastRoundToyIds = selectionContext.lastRoundToyIds;
    final usageByToyId = <String, _ToyUsageStats>{
      for (final entry in selectionContext.usageByToyId.entries)
        entry.key: entry.value.copy(),
    };
    final poolByKey = <String, _WeeklyPlanningToyPool>{};
    final result = <int, List<Toy>>{};

    SettingsRepository? settingsRepository;

    for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
      final date = normalizedWeekStart.add(Duration(days: dayIndex));
      final categoryConfigs =
          await _resolveRoundCategoryConfigsForDate(date, d);
      final selected = <Toy>[];
      final selectedIds = <String>{};

      if (categoryConfigs.isEmpty) {
        settingsRepository ??= SettingsRepository(d);
        await settingsRepository.load();
        final fallbackConfigs = await _fallbackCategoryConfigs(
          d,
          total: settingsRepository.roundSize,
        );
        selected.addAll(await _selectToysForCategoryConfigs(
          d,
          includedConfigs: fallbackConfigs,
          lastRoundToyIds: lastRoundToyIds,
          usageByToyId: usageByToyId,
          weeklyPoolsByCategoryId: poolByKey,
        ));
      } else {
        final includedConfigs = categoryConfigs
            .where((config) => config.isIncluded && config.safeQuota > 0)
            .toList(growable: false);
        selected.addAll(await _selectToysForCategoryConfigs(
          d,
          includedConfigs: includedConfigs,
          lastRoundToyIds: lastRoundToyIds,
          usageByToyId: usageByToyId,
          weeklyPoolsByCategoryId: poolByKey,
        ));
      }

      selectedIds.addAll(selected.map((toy) => toy.id));
      for (final toy in selected) {
        final stats = usageByToyId.putIfAbsent(
          toy.id,
          () => _ToyUsageStats(usageCount: 0, lastUsedAt: null),
        );
        stats.usageCount++;
        stats.lastUsedAt = date.millisecondsSinceEpoch;
      }
      result[date.weekday] = selected;
      lastRoundToyIds = selectedIds;
    }

    return result;
  }

  Future<List<Toy>> suggestRoundForDate(DateTime date) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final categoryConfigs = await _resolveRoundCategoryConfigsForDate(date, d);
    final includedConfigs = categoryConfigs
        .where((config) => config.isIncluded && config.safeQuota > 0)
        .toList(growable: false);
    final selectionContext = await _loadSelectionContextForDate(d, date);

    if (categoryConfigs.isEmpty) {
      final settingsRepository = SettingsRepository(d);
      await settingsRepository.load();
      final fallbackConfigs = await _fallbackCategoryConfigs(
        d,
        total: settingsRepository.roundSize,
      );
      return _selectToysForCategoryConfigs(
        d,
        includedConfigs: fallbackConfigs,
        lastRoundToyIds: selectionContext.lastRoundToyIds,
        usageByToyId: selectionContext.usageByToyId,
      );
    }

    return _selectToysForCategoryConfigs(
      d,
      includedConfigs: includedConfigs,
      lastRoundToyIds: selectionContext.lastRoundToyIds,
      usageByToyId: selectionContext.usageByToyId,
    );
  }

  Future<List<Toy>> _selectToysForCategoryConfigs(
    AppDatabase d, {
    required List<WeeklyPlanningCategoryConfig> includedConfigs,
    required Set<String> lastRoundToyIds,
    required Map<String, _ToyUsageStats> usageByToyId,
    Map<String, _WeeklyPlanningToyPool>? weeklyPoolsByCategoryId,
  }) async {
    final requestedTotal = includedConfigs.fold<int>(
      0,
      (sum, config) => sum + config.safeQuota,
    );
    if (requestedTotal <= 0 || includedConfigs.isEmpty) {
      return const <Toy>[];
    }

    final orderedConfigs = _sortCategoryConfigsForCoverage(includedConfigs);
    final categoryIds = {
      for (final config in includedConfigs) config.categoryId,
    };
    final eligibleToys = await (d.select(d.toys)
          ..where((toy) => toy.categoryId.isIn(categoryIds)))
        .get();
    final poolsByCategoryId = <String, List<Toy>>{
      for (final categoryId in categoryIds) categoryId: <Toy>[],
    };
    for (final toy in eligibleToys) {
      poolsByCategoryId[toy.categoryId]?.add(toy);
    }

    for (final entry in poolsByCategoryId.entries) {
      entry.value.sort((a, b) {
        final byCreatedAt = a.createdAt.compareTo(b.createdAt);
        if (byCreatedAt != 0) return byCreatedAt;
        return a.id.compareTo(b.id);
      });
      weeklyPoolsByCategoryId?.putIfAbsent(
        entry.key,
        () => _WeeklyPlanningToyPool(entry.value.toList(growable: false)),
      );
    }

    final selected = <Toy>[];
    final selectedIds = <String>{};
    final selectedCountByCategoryId = <String, int>{
      for (final config in includedConfigs) config.categoryId: 0,
    };

    Toy? takeBest(WeeklyPlanningCategoryConfig config) {
      final candidates = (poolsByCategoryId[config.categoryId] ?? const <Toy>[])
          .where((toy) => !selectedIds.contains(toy.id))
          .toList(growable: false)
        ..sort(
          (a, b) => _compareSelectionCandidates(
            a,
            b,
            lastRoundToyIds: lastRoundToyIds,
            usageByToyId: usageByToyId,
            weeklyPool: weeklyPoolsByCategoryId?[config.categoryId],
          ),
        );
      if (candidates.isEmpty) return null;
      final toy = candidates.first;
      selectedIds.add(toy.id);
      selected.add(toy);
      selectedCountByCategoryId[config.categoryId] =
          (selectedCountByCategoryId[config.categoryId] ?? 0) + 1;

      final weeklyPool = weeklyPoolsByCategoryId?[config.categoryId];
      if (weeklyPool != null && weeklyPool.toys.isNotEmpty) {
        weeklyPool.cursor =
            (_toyPoolIndex(weeklyPool, toy) + 1) % weeklyPool.toys.length;
      }
      return toy;
    }

    for (final config in orderedConfigs) {
      if (selected.length >= requestedTotal) break;
      if (_officialOrderForConfig(config) == null) continue;
      takeBest(config);
    }

    for (final config in orderedConfigs) {
      if (selected.length >= requestedTotal) break;

      while ((selectedCountByCategoryId[config.categoryId] ?? 0) <
              config.safeQuota &&
          selected.length < requestedTotal) {
        if (takeBest(config) == null) break;
      }
    }

    while (selected.length < requestedTotal) {
      final configsWithCandidates = orderedConfigs.where((config) {
        return (poolsByCategoryId[config.categoryId] ?? const <Toy>[])
            .any((toy) => !selectedIds.contains(toy.id));
      }).toList(growable: false);
      if (configsWithCandidates.isEmpty) break;

      configsWithCandidates.sort((a, b) {
        final aCount = selectedCountByCategoryId[a.categoryId] ?? 0;
        final bCount = selectedCountByCategoryId[b.categoryId] ?? 0;
        final byProportion =
            (aCount * b.safeQuota).compareTo(bCount * a.safeQuota);
        if (byProportion != 0) return byProportion;
        return orderedConfigs.indexOf(a).compareTo(orderedConfigs.indexOf(b));
      });
      if (takeBest(configsWithCandidates.first) == null) break;
    }

    return selected;
  }

  Future<List<WeeklyPlanningCategoryConfig>> _fallbackCategoryConfigs(
    AppDatabase d, {
    required int total,
  }) async {
    final categories = await (d.select(d.categoryDefinitions)
          ..where(
            (category) =>
                category.isActive.equals(true) &
                category.id.isIn(AgePresetCatalog.officialCategoryIds),
          )
          ..orderBy([
            (category) => OrderingTerm.asc(category.sortOrder),
            (category) => OrderingTerm.asc(category.name),
          ]))
        .get();
    if (categories.isEmpty || total <= 0) {
      return const <WeeklyPlanningCategoryConfig>[];
    }

    final baseQuota = total ~/ categories.length;
    var remaining = total % categories.length;
    return categories.map((category) {
      final quota = baseQuota + (remaining > 0 ? 1 : 0);
      if (remaining > 0) remaining--;
      return WeeklyPlanningCategoryConfig(
        categoryId: category.id,
        categoryName: category.name,
        isIncluded: quota > 0,
        quota: quota,
      );
    }).where((config) {
      return config.isIncluded && config.safeQuota > 0;
    }).toList(growable: false);
  }

  Future<_RoundSelectionContext> _loadSelectionContextForDate(
    AppDatabase d,
    DateTime date, {
    bool includeSameDayRoundAsPrevious = true,
  }) async {
    final bounds = _dayBounds(date);
    final sameDayRound = includeSameDayRoundAsPrevious
        ? await _loadLatestRoundBetween(d, bounds)
        : null;
    final previousRound = sameDayRound ??
        await (d.select(d.rounds)
              ..where(
                  (round) => round.startAt.isSmallerThanValue(bounds.startAt))
              ..orderBy([
                (round) => OrderingTerm.desc(round.startAt),
                (round) => OrderingTerm.desc(round.id),
              ])
              ..limit(1))
            .getSingleOrNull();

    return _RoundSelectionContext(
      lastRoundToyIds: previousRound == null
          ? const <String>{}
          : await _loadRoundToyIds(d, previousRound.id),
      usageByToyId: await _loadUsageStatsBefore(d, bounds.startAt),
    );
  }

  Future<Map<String, _ToyUsageStats>> _loadUsageStatsBefore(
    AppDatabase d,
    int cutoff,
  ) async {
    final rows = await d.customSelect(
      '''
      WITH effective_rounds AS (
        SELECT r.id, r.start_at
        FROM rounds AS r
        WHERE r.start_at < ?
          AND NOT EXISTS (
            SELECT 1
            FROM rounds AS newer
            WHERE date(newer.start_at / 1000, 'unixepoch', 'localtime') =
                  date(r.start_at / 1000, 'unixepoch', 'localtime')
              AND (
                newer.start_at > r.start_at OR
                (newer.start_at = r.start_at AND newer.id > r.id)
              )
          )
      )
      SELECT
        rt.toy_id AS toy_id,
        COUNT(*) AS usage_count,
        MAX(er.start_at) AS last_used_at
      FROM round_toys AS rt
      INNER JOIN effective_rounds AS er ON er.id = rt.round_id
      GROUP BY rt.toy_id
      ''',
      variables: [Variable<int>(cutoff)],
      readsFrom: {d.rounds, d.roundToys},
    ).get();

    return <String, _ToyUsageStats>{
      for (final row in rows)
        row.read<String>('toy_id'): _ToyUsageStats(
          usageCount: row.read<int>('usage_count'),
          lastUsedAt: row.readNullable<int>('last_used_at'),
        ),
    };
  }

  int _compareSelectionCandidates(
    Toy a,
    Toy b, {
    required Set<String> lastRoundToyIds,
    required Map<String, _ToyUsageStats> usageByToyId,
    _WeeklyPlanningToyPool? weeklyPool,
  }) {
    final aWasInLastRound = lastRoundToyIds.contains(a.id);
    final bWasInLastRound = lastRoundToyIds.contains(b.id);
    if (aWasInLastRound != bWasInLastRound) {
      return aWasInLastRound ? 1 : -1;
    }

    final aStats = usageByToyId[a.id];
    final bStats = usageByToyId[b.id];
    final aNeverUsed = (aStats?.usageCount ?? 0) == 0;
    final bNeverUsed = (bStats?.usageCount ?? 0) == 0;
    if (aNeverUsed != bNeverUsed) return aNeverUsed ? -1 : 1;

    final aLastUsedAt = aStats?.lastUsedAt;
    final bLastUsedAt = bStats?.lastUsedAt;
    if (aLastUsedAt != bLastUsedAt) {
      if (aLastUsedAt == null) return -1;
      if (bLastUsedAt == null) return 1;
      final byLastUse = aLastUsedAt.compareTo(bLastUsedAt);
      if (byLastUse != 0) return byLastUse;
    }

    final byUsage =
        (aStats?.usageCount ?? 0).compareTo(bStats?.usageCount ?? 0);
    if (byUsage != 0) return byUsage;

    if (weeklyPool != null) {
      final byCursorDistance =
          _toyPoolDistanceFromCursor(weeklyPool, a).compareTo(
        _toyPoolDistanceFromCursor(weeklyPool, b),
      );
      if (byCursorDistance != 0) return byCursorDistance;
    }

    final byCreatedAt = a.createdAt.compareTo(b.createdAt);
    if (byCreatedAt != 0) return byCreatedAt;
    return a.id.compareTo(b.id);
  }

  _DayBounds _dayBounds(DateTime date) {
    final local = date.toLocal();
    final start = DateTime(local.year, local.month, local.day);
    return _DayBounds(
      startAt: start.millisecondsSinceEpoch,
      endAt: start.add(const Duration(days: 1)).millisecondsSinceEpoch,
    );
  }

  Future<Round?> _loadLatestRoundBetween(
    AppDatabase d,
    _DayBounds bounds,
  ) {
    return (d.select(d.rounds)
          ..where(
            (round) =>
                round.startAt.isBiggerOrEqualValue(bounds.startAt) &
                round.startAt.isSmallerThanValue(bounds.endAt),
          )
          ..orderBy([
            (round) => OrderingTerm.desc(round.startAt),
            (round) => OrderingTerm.desc(round.id),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Set<String>> _loadRoundToyIds(
    AppDatabase d,
    String roundId,
  ) async {
    final rows = await (d.select(d.roundToys)
          ..where((roundToy) => roundToy.roundId.equals(roundId)))
        .get();
    return {for (final row in rows) row.toyId};
  }

  List<WeeklyPlanningCategoryConfig> _sortCategoryConfigsForCoverage(
    List<WeeklyPlanningCategoryConfig> configs,
  ) {
    final indexed = <({int index, WeeklyPlanningCategoryConfig config})>[
      for (var index = 0; index < configs.length; index++)
        (index: index, config: configs[index]),
    ];

    indexed.sort((a, b) {
      final aOfficialOrder = _officialOrderForConfig(a.config);
      final bOfficialOrder = _officialOrderForConfig(b.config);
      if (aOfficialOrder != null || bOfficialOrder != null) {
        final byOfficial = (aOfficialOrder ?? 1000).compareTo(
          bOfficialOrder ?? 1000,
        );
        if (byOfficial != 0) return byOfficial;
      }
      return a.index.compareTo(b.index);
    });

    return indexed.map((entry) => entry.config).toList(growable: false);
  }

  int? _officialOrderForConfig(WeeklyPlanningCategoryConfig config) {
    final normalizedId = _normalizeCategoryKey(config.categoryId);
    final normalizedName = _normalizeCategoryKey(config.categoryName);

    for (var index = 0;
        index < AgePresetCatalog.officialCategories.length;
        index++) {
      final official = AgePresetCatalog.officialCategories[index];
      if (normalizedId == official.id ||
          _officialNameMatches(normalizedName, official)) {
        return index;
      }
    }
    return null;
  }

  bool _officialNameMatches(
      String normalizedName, OfficialAgeCategory official) {
    for (final candidate in AgePresetCatalog.categoryNameCandidates(official)) {
      if (normalizedName == _normalizeCategoryKey(candidate)) return true;
    }
    return false;
  }

  String _normalizeCategoryKey(String value) {
    var normalized = value.trim().toLowerCase();
    const replacements = <String, String>{
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'ê': 'e',
      'è': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    for (final entry in replacements.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }

    return normalized.replaceAll(RegExp(r'\s+'), ' ');
  }

  int _toyPoolDistanceFromCursor(_WeeklyPlanningToyPool pool, Toy toy) {
    final index = _toyPoolIndex(pool, toy);
    if (index < 0) return pool.toys.length;
    return (index - pool.cursor) % pool.toys.length;
  }

  int _toyPoolIndex(_WeeklyPlanningToyPool pool, Toy toy) {
    for (var index = 0; index < pool.toys.length; index++) {
      if (pool.toys[index].id == toy.id) return index;
    }
    return -1;
  }

  DateTime _startOfWeek(DateTime date) {
    final localDate = DateTime(date.year, date.month, date.day);
    return localDate.subtract(Duration(days: localDate.weekday - 1));
  }

  Future<void> endActiveRound() async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    await (d.update(d.rounds)..where((r) => r.endAt.isNull()))
        .write(RoundsCompanion(endAt: Value(now)));
  }

  Future<void> setActiveRoundFromToyIds(
    List<String> toyIds, {
    DateTime? date,
    RoundCreationSource source = RoundCreationSource.roundManual,
  }) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final roundDate = date ?? DateTime.now();
    final validated = await _validateToyIdsForDate(d, toyIds, roundDate);
    if (validated.isEmpty) {
      throw StateError('A rodada precisa ter ao menos um brinquedo válido.');
    }
    await _writeEffectiveRoundForDate(
      d,
      roundDate,
      validated,
      source: source,
    );
  }

  Future<List<Toy>> _validateToyIdsForDate(
    AppDatabase d,
    Iterable<String> toyIds,
    DateTime date,
  ) async {
    final normalizedToyIds = <String>[];
    final seen = <String>{};
    for (final id in toyIds) {
      final normalized = id.trim();
      if (normalized.isEmpty || !seen.add(normalized)) continue;
      normalizedToyIds.add(normalized);
    }
    if (normalizedToyIds.isEmpty) return const <Toy>[];

    var categoryConfigs = await _resolveRoundCategoryConfigsForDate(date, d);
    if (categoryConfigs.isEmpty) {
      final settingsRepository = SettingsRepository(d);
      await settingsRepository.load();
      categoryConfigs = await _fallbackCategoryConfigs(
        d,
        total: settingsRepository.roundSize,
      );
    }
    final includedCategoryIds = categoryConfigs
        .where((config) => config.isIncluded && config.safeQuota > 0)
        .map((config) => config.categoryId)
        .toSet();

    final toyTable = d.toys;
    final categoryTable = d.categoryDefinitions;
    final query = d.select(toyTable).join([
      innerJoin(
        categoryTable,
        categoryTable.id.equalsExp(toyTable.categoryId),
      ),
    ])
      ..where(toyTable.id.isIn(normalizedToyIds))
      ..where(categoryTable.isActive.equals(true));
    final rows = await query.get();
    final toysById = <String, Toy>{
      for (final row in rows)
        row.readTable(toyTable).id: row.readTable(toyTable),
    };

    final missingOrInactive = normalizedToyIds.where((id) {
      return !toysById.containsKey(id);
    }).toList(growable: false);
    if (missingOrInactive.isNotEmpty) {
      throw StateError(
        'Brinquedos inexistentes ou com categoria inativa: '
        '${missingOrInactive.join(', ')}',
      );
    }

    final outsideIncludedCategories = normalizedToyIds.where((id) {
      return !includedCategoryIds.contains(toysById[id]!.categoryId);
    }).toList(growable: false);
    if (outsideIncludedCategories.isNotEmpty) {
      throw StateError(
        'Brinquedos fora das categorias incluídas para a data: '
        '${outsideIncludedCategories.join(', ')}',
      );
    }

    return normalizedToyIds.map((id) => toysById[id]!).toList(growable: false);
  }

  Future<void> _writeEffectiveRoundForDate(
    AppDatabase d,
    DateTime date,
    List<Toy> toys, {
    required RoundCreationSource source,
  }) async {
    final bounds = _dayBounds(date);
    final eventAt = date.millisecondsSinceEpoch;
    var createdFirstPersistedRound = false;

    await d.transaction(() async {
      final hadPersistedUserRound = await (d.select(d.rounds)
                ..where((round) => round.id.equals(_demoActiveRoundId).not())
                ..limit(1))
              .getSingleOrNull() !=
          null;
      final existingRound = await _loadLatestRoundBetween(d, bounds);
      final existingUserRound =
          existingRound?.id == _demoActiveRoundId ? null : existingRound;
      final roundId = existingUserRound?.id ?? const Uuid().v4();

      await (d.update(d.rounds)
            ..where(
              (round) => round.endAt.isNull() & round.id.equals(roundId).not(),
            ))
          .write(RoundsCompanion(endAt: Value(eventAt)));

      if (existingUserRound == null) {
        await d.into(d.rounds).insert(
              RoundsCompanion.insert(
                id: roundId,
                startAt: eventAt,
              ),
            );
      } else {
        await (d.update(d.rounds)..where((round) => round.id.equals(roundId)))
            .write(const RoundsCompanion(endAt: Value(null)));
      }

      await (d.delete(d.roundToys)
            ..where((roundToy) => roundToy.roundId.equals(roundId)))
          .go();

      for (var position = 0; position < toys.length; position++) {
        await d.into(d.roundToys).insert(
              RoundToysCompanion.insert(
                roundId: roundId,
                toyId: toys[position].id,
                position: position,
              ),
            );
      }

      createdFirstPersistedRound = !hadPersistedUserRound;
    });

    if (createdFirstPersistedRound) {
      await _firstRoundAnalyticsCoordinator?.recordFirstPersistence(
        source: source,
        toyCount: toys.length,
      );
    }
  }

  Future<_BalanceEvaluation> _evaluateCategoryBalance(AppDatabase d) async {
    final categoryRows = await (d.select(d.categoryDefinitions)
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
    final categoryLabels = <String, String>{
      for (final row in categoryRows) row.id: row.name.trim(),
    };

    final toys = await (d.select(d.toys)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
          ]))
        .get();

    final total = toys.length;
    if (total < 10) {
      return const _BalanceEvaluation(
        total: 0,
        categories: <_BalanceCategoryInfo>[],
        dominant: null,
        low: null,
        suggestion:
            'Cadastre pelo menos 10 brinquedos para o equilíbrio por categorias funcionar.',
      );
    }

    final counts = <String, int>{};
    for (final toy in toys) {
      final categoryId =
          toy.categoryId.trim().isEmpty ? 'outros' : toy.categoryId.trim();
      counts[categoryId] = (counts[categoryId] ?? 0) + 1;
    }

    final categories = counts.entries.map(
      (entry) {
        final percentage = entry.value / total;
        final label =
            categoryLabels[entry.key] ?? _fallbackCategoryLabel(entry.key);
        return _BalanceCategoryInfo(
          id: entry.key,
          label: label,
          count: entry.value,
          percentage: percentage,
        );
      },
    ).toList()
      ..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        if (byCount != 0) return byCount;
        return a.label.toLowerCase().compareTo(b.label.toLowerCase());
      });

    _BalanceCategoryInfo? dominant;
    for (final item in categories) {
      if (item.percentage <= 0.35) continue;
      if (dominant == null || item.percentage > dominant.percentage) {
        dominant = item;
        continue;
      }
      if (item.percentage == dominant.percentage &&
          item.label.toLowerCase().compareTo(dominant.label.toLowerCase()) <
              0) {
        dominant = item;
      }
    }

    _BalanceCategoryInfo? low;
    for (final item in categories) {
      if (item.percentage >= 0.15) continue;
      if (low == null || item.percentage < low.percentage) {
        low = item;
        continue;
      }
      if (item.percentage == low.percentage &&
          item.label.toLowerCase().compareTo(low.label.toLowerCase()) < 0) {
        low = item;
      }
    }

    final suggestion =
        _buildSuggestion(total: total, dominant: dominant, low: low);

    return _BalanceEvaluation(
      total: total,
      categories: categories,
      dominant: dominant,
      low: low,
      suggestion: suggestion,
    );
  }

  Future<List<_ActiveRoundToy>> _loadActiveRoundToys(
      AppDatabase d, String roundId) async {
    final rt = d.roundToys;
    final t = d.toys;
    final c = d.categoryDefinitions;

    final rows = await (d.select(rt).join([
      innerJoin(t, t.id.equalsExp(rt.toyId)),
      leftOuterJoin(c, c.id.equalsExp(t.categoryId)),
    ])
          ..where(rt.roundId.equals(roundId))
          ..orderBy([
            OrderingTerm(expression: rt.position, mode: OrderingMode.asc),
            OrderingTerm(expression: t.id, mode: OrderingMode.asc),
          ]))
        .get();

    return rows.map((row) {
      final toy = row.readTable(t);
      final category = row.readTableOrNull(c);
      return _ActiveRoundToy(
        toyId: toy.id,
        toyName: toy.name.trim().isEmpty ? 'Sem nome' : toy.name.trim(),
        categoryId:
            toy.categoryId.trim().isEmpty ? 'outros' : toy.categoryId.trim(),
        categoryLabel: category?.name.trim().isNotEmpty == true
            ? category!.name.trim()
            : _fallbackCategoryLabel(toy.categoryId),
        position: row.readTable(rt).position,
      );
    }).toList(growable: false);
  }

  Future<_ToyCandidate?> _loadLowCategoryCandidate(
    AppDatabase d, {
    required Set<String> excludedToyIds,
    required String lowCategoryId,
  }) async {
    final t = d.toys;
    final c = d.categoryDefinitions;

    final query = d.select(t).join([
      leftOuterJoin(c, c.id.equalsExp(t.categoryId)),
    ])
      ..where(t.categoryId.equals(lowCategoryId));

    if (excludedToyIds.isNotEmpty) {
      query.where(t.id.isNotIn(excludedToyIds));
    }

    query.orderBy([
      OrderingTerm(expression: t.name.lower(), mode: OrderingMode.asc),
      OrderingTerm(expression: t.id, mode: OrderingMode.asc),
    ]);

    final rows = await query.get();
    if (rows.isEmpty) return null;

    final row = rows.first;
    final toy = row.readTable(t);
    final category = row.readTableOrNull(c);
    return _ToyCandidate(
      toyId: toy.id,
      toyName: toy.name.trim().isEmpty ? 'Sem nome' : toy.name.trim(),
      categoryId: toy.categoryId,
      categoryLabel: category?.name.trim().isNotEmpty == true
          ? category!.name.trim()
          : _fallbackCategoryLabel(toy.categoryId),
    );
  }

  String _buildSuggestion({
    required int total,
    required _BalanceCategoryInfo? dominant,
    required _BalanceCategoryInfo? low,
  }) {
    if (total < 10) {
      return 'Cadastre pelo menos 10 brinquedos para o equilíbrio por categorias funcionar.';
    }
    if (dominant != null && low != null) {
      return 'Sugestão: reduzir ${dominant.label} e incluir ${low.label}.';
    }
    if (low != null) {
      return 'Sugestão: incluir mais ${low.label} na rodada.';
    }
    return 'Tudo equilibrado ✅';
  }

  static String _fallbackCategoryLabel(String rawId) {
    final trimmed = rawId.trim();
    if (trimmed.isEmpty) return 'Outros';
    final withSpaces = trimmed.replaceAll('_', ' ').trim();
    if (withSpaces.isEmpty) return 'Outros';
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }
}
