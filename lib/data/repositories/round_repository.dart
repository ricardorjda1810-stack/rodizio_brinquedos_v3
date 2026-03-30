import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';

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

class RoundRepository {
  final AppDatabase? db;

  RoundRepository(this.db);

  static const String insufficientTotalReason = 'insufficient_total';
  static const String noDominantOrLowReason = 'no_dominant_or_low';
  static const String noDominantInRoundReason = 'no_dominant_in_round';
  static const String noCandidateToAddReason = 'no_candidate_to_add';
  static const String noActiveRoundReason = 'no_active_round';

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

  Future<OptimizeActiveRoundResult> optimizeActiveRoundByCategoryBalance() async {
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
                rt.roundId.equals(activeRound.id) & rt.toyId.equals(toRemove.toyId)))
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

  // `size` remains only as an explicit override for compatibility/test flows.
  // The current app behavior derives the effective round size from category quotas.
  Future<void> startRound({int? size}) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final resolvedSize =
        size ?? await _deriveRoundSizeFromCategoryQuotas(d);
    final requestedSize = resolvedSize <= 0 ? 0 : resolvedSize;
    final now = DateTime.now().millisecondsSinceEpoch;
    final newRoundId = const Uuid().v4();

    await d.transaction(() async {
      await (d.update(d.rounds)..where((r) => r.endAt.isNull()))
          .write(RoundsCompanion(endAt: Value(now)));

      await d.into(d.rounds).insert(
            RoundsCompanion.insert(
              id: newRoundId,
              startAt: now,
            ),
          );

      if (requestedSize == 0) return;

      final categoryRows = await (d.select(d.categoryDefinitions).join([
        innerJoin(
          d.roundCategorySettings,
          d.roundCategorySettings.categoryId
                  .equalsExp(d.categoryDefinitions.id) &
              d.roundCategorySettings.isIncluded.equals(true),
        ),
      ])
            ..where(d.categoryDefinitions.isActive.equals(true))
            ..orderBy([OrderingTerm.asc(d.categoryDefinitions.name)]))
          .get();

      if (categoryRows.isEmpty) return;

      final selected = <Toy>[];
      var remaining = requestedSize;

      for (final row in categoryRows) {
        if (remaining <= 0) break;

        final category = row.readTable(d.categoryDefinitions);
        final setting = row.readTable(d.roundCategorySettings);
        final quota = setting.quota < 0 ? 0 : setting.quota;
        if (quota == 0) continue;

        final limit = quota < remaining ? quota : remaining;
        final toysForCategory = await (d.select(d.toys)
              ..where((t) => t.categoryId.equals(category.id))
              ..orderBy([
                (t) => OrderingTerm(
                    expression: t.createdAt, mode: OrderingMode.asc),
                (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
              ])
              ..limit(limit))
            .get();

        selected.addAll(toysForCategory);
        remaining -= toysForCategory.length;
      }

      for (var i = 0; i < selected.length; i++) {
        await d.into(d.roundToys).insert(
              RoundToysCompanion.insert(
                roundId: newRoundId,
                toyId: selected[i].id,
                position: i,
              ),
            );
      }
    });
  }

  Future<int> _deriveRoundSizeFromCategoryQuotas(AppDatabase d) async {
    final rows = await (d.select(d.roundCategorySettings).join([
      innerJoin(
        d.categoryDefinitions,
        d.categoryDefinitions.id.equalsExp(d.roundCategorySettings.categoryId),
      ),
    ])
          ..where(
            d.roundCategorySettings.isIncluded.equals(true) &
                d.categoryDefinitions.isActive.equals(true),
          ))
        .get();

    var total = 0;
    for (final row in rows) {
      final quota = row.readTable(d.roundCategorySettings).quota;
      if (quota > 0) {
        total += quota;
      }
    }
    return total;
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
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
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
      final categoryId = toy.categoryId.trim().isEmpty ? 'outros' : toy.categoryId.trim();
      counts[categoryId] = (counts[categoryId] ?? 0) + 1;
    }

    final categories = counts.entries
        .map(
          (entry) {
            final percentage = entry.value / total;
            final label = categoryLabels[entry.key] ?? _fallbackCategoryLabel(entry.key);
            return _BalanceCategoryInfo(
              id: entry.key,
              label: label,
              count: entry.value,
              percentage: percentage,
            );
          },
        )
        .toList()
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
          item.label.toLowerCase().compareTo(dominant.label.toLowerCase()) < 0) {
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

    final suggestion = _buildSuggestion(total: total, dominant: dominant, low: low);

    return _BalanceEvaluation(
      total: total,
      categories: categories,
      dominant: dominant,
      low: low,
      suggestion: suggestion,
    );
  }

  Future<List<_ActiveRoundToy>> _loadActiveRoundToys(AppDatabase d, String roundId) async {
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
        categoryId: toy.categoryId.trim().isEmpty ? 'outros' : toy.categoryId.trim(),
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
