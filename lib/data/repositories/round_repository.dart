// lib/data/repositories/round_repository.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';

class RoundToyWithBox {
  final Toy toy;
  final Boxe? box; // tipo gerado pelo Drift
  final int position;

  const RoundToyWithBox({
    required this.toy,
    required this.box,
    required this.position,
  });
}

class RoundRepository {
  final AppDatabase? db;

  RoundRepository(this.db);

  static const int defaultRoundSize = 7;

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

  Future<void> startRound({int size = defaultRoundSize}) async {
    final d = db;
    if (d == null) {
      throw StateError('RoundRepository.db is null. Use um Fake no teste.');
    }

    final requestedSize = size <= 0 ? 0 : size;
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
}
