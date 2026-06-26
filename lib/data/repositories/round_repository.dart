import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

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

class RoundRepository {
  final AppDatabase? db;
  final WeeklyPlanningRepository? _weeklyPlanningRepository;

  RoundRepository(this.db, [this._weeklyPlanningRepository]);

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
  Future<StartRoundResult> startRound({int? size, DateTime? date}) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final roundDate = date ?? DateTime.now();
    final categoryConfigs =
        await _resolveRoundCategoryConfigsForDate(roundDate, d);
    final includedConfigs = categoryConfigs
        .where((config) => config.isIncluded && config.safeQuota > 0)
        .toList(growable: false);
    if (includedConfigs.isEmpty) {
      return const StartRoundResult.notCreated();
    }

    final selected = await _selectToysForCategoryConfigs(
      d,
      includedConfigs: includedConfigs,
      lastRoundToyIds: const <String>{},
    );

    if (selected.isEmpty) {
      return const StartRoundResult.notCreated();
    }

    final totalFromCategories = includedConfigs.fold<int>(
      0,
      (sum, config) => sum + config.safeQuota,
    );
    final requestedSize = totalFromCategories;
    final now = roundDate.millisecondsSinceEpoch;
    final newRoundId = const Uuid().v4();
    final finalSelection = requestedSize > 0 && selected.length > requestedSize
        ? selected.take(requestedSize).toList(growable: false)
        : selected;

    await d.transaction(() async {
      await (d.update(d.rounds)..where((r) => r.endAt.isNull()))
          .write(RoundsCompanion(endAt: Value(now)));

      await d.into(d.rounds).insert(
            RoundsCompanion.insert(
              id: newRoundId,
              startAt: now,
            ),
          );

      for (var i = 0; i < finalSelection.length; i++) {
        await d.into(d.roundToys).insert(
              RoundToysCompanion.insert(
                roundId: newRoundId,
                toyId: finalSelection[i].id,
                position: i,
              ),
            );
      }
    });

    return StartRoundResult.createdWithCount(finalSelection.length);
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
    final lastRoundToyIds = await _loadMostRecentRoundToyIds(d);
    final poolByKey = <String, _WeeklyPlanningToyPool>{};
    final usageByToyId = <String, int>{};
    final lastUsedDayByToyId = <String, int>{};
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
        final pool = await _weeklyPlanningPoolForKey(
          d,
          poolByKey: poolByKey,
          key: '__all__',
          categoryId: null,
          lastRoundToyIds: lastRoundToyIds,
        );
        selected.addAll(
          _selectWeeklyPlanningToys(
            pool: pool,
            count: settingsRepository.roundSize,
            dayIndex: dayIndex,
            selectedIds: selectedIds,
            usageByToyId: usageByToyId,
            lastUsedDayByToyId: lastUsedDayByToyId,
          ),
        );
        result[date.weekday] = selected;
        continue;
      }

      final includedConfigs = categoryConfigs
          .where((config) => config.isIncluded && config.safeQuota > 0)
          .toList(growable: false);
      for (final config in includedConfigs) {
        final pool = await _weeklyPlanningPoolForKey(
          d,
          poolByKey: poolByKey,
          key: 'category:${config.categoryId}',
          categoryId: config.categoryId,
          lastRoundToyIds: lastRoundToyIds,
        );
        selected.addAll(
          _selectWeeklyPlanningToys(
            pool: pool,
            count: config.safeQuota,
            dayIndex: dayIndex,
            selectedIds: selectedIds,
            usageByToyId: usageByToyId,
            lastUsedDayByToyId: lastUsedDayByToyId,
          ),
        );
      }

      result[date.weekday] = selected;
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
    final lastRoundToyIds = await _loadMostRecentRoundToyIds(d);

    if (categoryConfigs.isEmpty) {
      final settingsRepository = SettingsRepository(d);
      await settingsRepository.load();
      final toys = await _loadEligibleToys(d);
      return _prioritizeToysOutsideLastRound(toys, lastRoundToyIds)
          .take(settingsRepository.roundSize)
          .toList(growable: false);
    }

    return _selectToysForCategoryConfigs(
      d,
      includedConfigs: includedConfigs,
      lastRoundToyIds: lastRoundToyIds,
    );
  }

  Future<List<Toy>> _selectToysForCategoryConfigs(
    AppDatabase d, {
    required List<WeeklyPlanningCategoryConfig> includedConfigs,
    required Set<String> lastRoundToyIds,
  }) async {
    final requestedTotal = includedConfigs.fold<int>(
      0,
      (sum, config) => sum + config.safeQuota,
    );
    if (requestedTotal <= 0 || includedConfigs.isEmpty) {
      return const <Toy>[];
    }

    final orderedConfigs = _sortCategoryConfigsForCoverage(includedConfigs);
    final remainingQuotaByCategoryId = <String, int>{
      for (final config in includedConfigs) config.categoryId: config.safeQuota,
    };
    final poolsByCategoryId = <String, List<Toy>>{};
    final selected = <Toy>[];
    final selectedIds = <String>{};

    Future<List<Toy>> poolFor(WeeklyPlanningCategoryConfig config) async {
      final cached = poolsByCategoryId[config.categoryId];
      if (cached != null) return cached;

      final toys = await _loadEligibleToysForCategory(
        d,
        categoryId: config.categoryId,
      );
      final ordered = _prioritizeToysOutsideLastRound(toys, lastRoundToyIds);
      poolsByCategoryId[config.categoryId] = ordered;
      return ordered;
    }

    bool addToy(Toy toy) {
      if (!selectedIds.add(toy.id)) return false;
      selected.add(toy);
      return true;
    }

    for (final config in orderedConfigs) {
      if (selected.length >= requestedTotal) break;
      if (_officialOrderForConfig(config) == null) continue;
      if ((remainingQuotaByCategoryId[config.categoryId] ?? 0) <= 0) continue;

      final pool = await poolFor(config);
      for (final toy in pool) {
        if (!addToy(toy)) continue;
        remainingQuotaByCategoryId[config.categoryId] =
            (remainingQuotaByCategoryId[config.categoryId] ?? 0) - 1;
        break;
      }
    }

    for (final config in orderedConfigs) {
      if (selected.length >= requestedTotal) break;

      var remaining = remainingQuotaByCategoryId[config.categoryId] ?? 0;
      if (remaining <= 0) continue;

      final pool = await poolFor(config);
      for (final toy in pool) {
        if (remaining <= 0 || selected.length >= requestedTotal) break;
        if (!addToy(toy)) continue;
        remaining--;
      }
      remainingQuotaByCategoryId[config.categoryId] = remaining;
    }

    if (selected.length >= requestedTotal) return selected;

    for (final config in orderedConfigs) {
      if (selected.length >= requestedTotal) break;

      final pool = await poolFor(config);
      for (final toy in pool) {
        if (selected.length >= requestedTotal) break;
        addToy(toy);
      }
    }

    return selected;
  }

  Future<List<Toy>> _loadEligibleToysForCategory(
    AppDatabase d, {
    required String categoryId,
  }) {
    return (d.select(d.toys)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.asc,
                ),
            (t) => OrderingTerm(
                  expression: t.id,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  Future<List<Toy>> _loadEligibleToys(AppDatabase d) {
    return (d.select(d.toys)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.asc,
                ),
            (t) => OrderingTerm(
                  expression: t.id,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  Future<Set<String>> _loadMostRecentRoundToyIds(AppDatabase d) async {
    final latestRound = await (d.select(d.rounds)
          ..orderBy([
            (r) => OrderingTerm(
                  expression: r.startAt,
                  mode: OrderingMode.desc,
                ),
            (r) => OrderingTerm(
                  expression: r.id,
                  mode: OrderingMode.asc,
                ),
          ])
          ..limit(1))
        .getSingleOrNull();
    if (latestRound == null) return const <String>{};

    final rows = await (d.select(d.roundToys)
          ..where((rt) => rt.roundId.equals(latestRound.id)))
        .get();
    return {for (final row in rows) row.toyId};
  }

  List<Toy> _prioritizeToysOutsideLastRound(
    List<Toy> toys,
    Set<String> lastRoundToyIds,
  ) {
    if (lastRoundToyIds.isEmpty) return toys;

    return <Toy>[
      ...toys.where((toy) => !lastRoundToyIds.contains(toy.id)),
      ...toys.where((toy) => lastRoundToyIds.contains(toy.id)),
    ];
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

  Future<_WeeklyPlanningToyPool> _weeklyPlanningPoolForKey(
    AppDatabase d, {
    required Map<String, _WeeklyPlanningToyPool> poolByKey,
    required String key,
    required String? categoryId,
    required Set<String> lastRoundToyIds,
  }) async {
    final cached = poolByKey[key];
    if (cached != null) return cached;

    final toys = categoryId == null
        ? await _loadEligibleToys(d)
        : await _loadEligibleToysForCategory(d, categoryId: categoryId);
    final pool = _WeeklyPlanningToyPool(
      _prioritizeToysOutsideLastRound(toys, lastRoundToyIds),
    );
    poolByKey[key] = pool;
    return pool;
  }

  List<Toy> _selectWeeklyPlanningToys({
    required _WeeklyPlanningToyPool pool,
    required int count,
    required int dayIndex,
    required Set<String> selectedIds,
    required Map<String, int> usageByToyId,
    required Map<String, int> lastUsedDayByToyId,
  }) {
    if (count <= 0 || pool.toys.isEmpty) return const <Toy>[];

    final availableCount = pool.toys.where((toy) {
      return !selectedIds.contains(toy.id);
    }).length;
    final targetCount = count < availableCount ? count : availableCount;
    if (targetCount <= 0) return const <Toy>[];

    final selected = <Toy>[];
    while (selected.length < targetCount) {
      final candidates = pool.toys.where((toy) {
        return !selectedIds.contains(toy.id);
      }).toList(growable: false);
      if (candidates.isEmpty) break;

      final remainingCount = targetCount - selected.length;
      final nonConsecutiveCandidates = candidates.where((toy) {
        return lastUsedDayByToyId[toy.id] != dayIndex - 1;
      }).toList(growable: false);
      final effectiveCandidates =
          nonConsecutiveCandidates.length >= remainingCount
              ? nonConsecutiveCandidates
              : candidates;

      final orderedCandidates = effectiveCandidates.toList(growable: false)
        ..sort(
          (a, b) => _compareWeeklyPlanningCandidates(
            a,
            b,
            pool: pool,
            dayIndex: dayIndex,
            usageByToyId: usageByToyId,
            lastUsedDayByToyId: lastUsedDayByToyId,
          ),
        );
      final toy = orderedCandidates.first;
      selected.add(toy);
      selectedIds.add(toy.id);
      usageByToyId[toy.id] = (usageByToyId[toy.id] ?? 0) + 1;
      lastUsedDayByToyId[toy.id] = dayIndex;
      pool.cursor = (_toyPoolIndex(pool, toy) + 1) % pool.toys.length;
    }

    return selected;
  }

  int _compareWeeklyPlanningCandidates(
    Toy a,
    Toy b, {
    required _WeeklyPlanningToyPool pool,
    required int dayIndex,
    required Map<String, int> usageByToyId,
    required Map<String, int> lastUsedDayByToyId,
  }) {
    final byUsage = (usageByToyId[a.id] ?? 0).compareTo(
      usageByToyId[b.id] ?? 0,
    );
    if (byUsage != 0) return byUsage;

    final aWasUsedYesterday = lastUsedDayByToyId[a.id] == dayIndex - 1;
    final bWasUsedYesterday = lastUsedDayByToyId[b.id] == dayIndex - 1;
    if (aWasUsedYesterday != bWasUsedYesterday) {
      return aWasUsedYesterday ? 1 : -1;
    }

    final byCursorDistance = _toyPoolDistanceFromCursor(pool, a).compareTo(
      _toyPoolDistanceFromCursor(pool, b),
    );
    if (byCursorDistance != 0) return byCursorDistance;

    final byCreatedAt = a.createdAt.compareTo(b.createdAt);
    if (byCreatedAt != 0) return byCreatedAt;
    return a.id.compareTo(b.id);
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

  Future<void> setActiveRoundFromToyIds(List<String> toyIds) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final normalizedToyIds = <String>[];
    final seen = <String>{};
    for (final id in toyIds) {
      final trimmed = id.trim();
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed)) {
        normalizedToyIds.add(trimmed);
      }
    }

    await d.transaction(() async {
      final activeRound = await (d.select(d.rounds)
            ..where((r) => r.endAt.isNull())
            ..limit(1))
          .getSingleOrNull();

      final roundId = activeRound?.id ?? const Uuid().v4();
      if (activeRound == null) {
        await d.into(d.rounds).insert(
              RoundsCompanion.insert(
                id: roundId,
                startAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      }

      await (d.delete(d.roundToys)..where((rt) => rt.roundId.equals(roundId)))
          .go();

      if (normalizedToyIds.isEmpty) return;

      final existing = await (d.select(d.toys)
            ..where((t) => t.id.isIn(normalizedToyIds)))
          .get();
      final existingSet = {for (final toy in existing) toy.id};

      var position = 0;
      for (final toyId in normalizedToyIds) {
        if (!existingSet.contains(toyId)) continue;
        await d.into(d.roundToys).insert(
              RoundToysCompanion.insert(
                roundId: roundId,
                toyId: toyId,
                position: position,
              ),
            );
        position++;
      }
    });
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
