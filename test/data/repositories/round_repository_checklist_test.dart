import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';

void main() {
  late AppDatabase db;
  late RoundRepository roundRepository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    roundRepository = RoundRepository(db);
    await _insertToy(db, id: 'toy_a');
    await _insertToy(db, id: 'toy_b');
  });

  tearDown(() async {
    await db.close();
  });

  test('checklistDateKey usa apenas o dia local normalizado', () {
    expect(
      RoundRepository.checklistDateKey(DateTime(2026, 1, 2, 23, 59)),
      '2026-01-02',
    );
  });

  test('toggleToyCollectedForDate marca e desmarca o brinquedo do dia',
      () async {
    final date = DateTime(2026, 1, 5);

    expect(await roundRepository.loadRoundChecklistForDate(date), isEmpty);

    final firstToggle = await roundRepository.toggleToyCollectedForDate(
      date: date,
      toyId: 'toy_a',
    );
    expect(firstToggle, isTrue);
    expect(await roundRepository.loadRoundChecklistForDate(date), {
      'toy_a': true,
    });

    final secondToggle = await roundRepository.toggleToyCollectedForDate(
      date: date,
      toyId: 'toy_a',
    );
    expect(secondToggle, isFalse);
    expect(await roundRepository.loadRoundChecklistForDate(date), {
      'toy_a': false,
    });
  });

  test('marcações de checklist não vazam entre dias', () async {
    final firstDate = DateTime(2026, 1, 5);
    final nextDate = DateTime(2026, 1, 6);

    await roundRepository.setToyCollectedForDate(
      date: firstDate,
      toyId: 'toy_a',
      collected: true,
    );

    expect(await roundRepository.loadRoundChecklistForDate(firstDate), {
      'toy_a': true,
    });
    expect(await roundRepository.loadRoundChecklistForDate(nextDate), isEmpty);
  });

  test('clearRoundChecklistForDate limpa somente o dia escolhido', () async {
    final firstDate = DateTime(2026, 1, 5);
    final nextDate = DateTime(2026, 1, 6);

    await roundRepository.setToyCollectedForDate(
      date: firstDate,
      toyId: 'toy_a',
      collected: true,
    );
    await roundRepository.setToyCollectedForDate(
      date: nextDate,
      toyId: 'toy_b',
      collected: true,
    );

    await roundRepository.clearRoundChecklistForDate(firstDate);

    expect(await roundRepository.loadRoundChecklistForDate(firstDate), isEmpty);
    expect(await roundRepository.loadRoundChecklistForDate(nextDate), {
      'toy_b': true,
    });
  });

  test('RoundChecklistProgress conta itens separados e detecta rodada pronta',
      () {
    final progress = RoundChecklistProgress.fromToyIds(
      const ['toy_a', 'toy_a', 'toy_b'],
      const {
        'toy_a': true,
        'toy_b': false,
        'toy_c': true,
      },
    );

    expect(progress.collectedCount, 1);
    expect(progress.totalCount, 2);
    expect(progress.isReady, isFalse);
    expect(progress.fraction, 0.5);
    expect(progress.label, '1 de 2 brinquedos separados');

    final ready = RoundChecklistProgress.fromToyIds(
      const ['toy_a', 'toy_b'],
      const {
        'toy_a': true,
        'toy_b': true,
      },
    );

    expect(ready.collectedCount, 2);
    expect(ready.totalCount, 2);
    expect(ready.isReady, isTrue);
    expect(ready.fraction, 1);
    expect(ready.label, 'Rodada pronta');
  });
}

Future<void> _insertToy(
  AppDatabase db, {
  required String id,
}) async {
  await db.into(db.toys).insert(
        ToysCompanion.insert(
          id: id,
          categoryId: const Value('corpo'),
          name: 'Toy $id',
          createdAt: DateTime(2026, 1, 1).millisecondsSinceEpoch,
          boxId: const Value(null),
          locationText: const Value(null),
          photoPath: const Value(null),
        ),
      );
}
