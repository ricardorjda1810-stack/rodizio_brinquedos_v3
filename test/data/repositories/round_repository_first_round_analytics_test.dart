import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/first_round_analytics_coordinator.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ToyRepository toyRepository;
  late List<_RepositoryFirstRoundEvent> sentEvents;
  late FirstRoundAnalyticsCoordinator coordinator;
  late RoundRepository roundRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    db = AppDatabase(NativeDatabase.memory());
    toyRepository = ToyRepository(db);
    sentEvents = <_RepositoryFirstRoundEvent>[];
    coordinator = FirstRoundAnalyticsCoordinator(
      preferencesProvider: SharedPreferences.getInstance,
      isAnalyticsConfigured: () => true,
      sendEvent: ({
        required int toyCount,
        required RoundCreationSource source,
      }) async {
        sentEvents.add(
          _RepositoryFirstRoundEvent(
            toyCount: toyCount,
            source: source,
          ),
        );
        return true;
      },
    );
    roundRepository = RoundRepository(db, null, coordinator);

    await toyRepository.ensureSeedData();
    await toyRepository.setCategoryIncludedInRound(
      categoryId: 'corpo',
      isIncluded: true,
    );
    await toyRepository.setCategoryQuotaInRound(
      categoryId: 'corpo',
      quota: 3,
    );
    await _insertToy(db, id: 'toy_1', createdAt: 100);
    await _insertToy(db, id: 'toy_2', createdAt: 200);
  });

  tearDown(() async {
    await db.close();
  });

  test('primeira persistência dispara uma vez e rodada posterior não duplica',
      () async {
    await roundRepository.setActiveRoundFromToyIds(
      const <String>['toy_1'],
      date: DateTime(2026, 7, 28, 10),
      source: RoundCreationSource.homeSuggestion,
    );
    await roundRepository.setActiveRoundFromToyIds(
      const <String>['toy_2'],
      date: DateTime(2026, 7, 29, 10),
      source: RoundCreationSource.roundManual,
    );

    expect(sentEvents, hasLength(1));
    expect(sentEvents.single.source, RoundCreationSource.homeSuggestion);
    expect(sentEvents.single.toyCount, 1);
    expect(await coordinator.readState(), FirstRoundAnalyticsState.sent);
    expect(await db.select(db.rounds).get(), hasLength(2));
  });

  test('rodada demo não impede a primeira persistência do usuário', () async {
    await db.into(db.rounds).insert(
          RoundsCompanion.insert(
            id: 'demo_active_round',
            startAt: DateTime(2026, 7, 28, 8).millisecondsSinceEpoch,
          ),
        );
    await db.into(db.roundToys).insert(
          const RoundToysCompanion(
            roundId: Value('demo_active_round'),
            toyId: Value('toy_1'),
            position: Value(0),
          ),
        );

    await roundRepository.setActiveRoundFromToyIds(
      const <String>['toy_2'],
      date: DateTime(2026, 7, 28, 10),
      source: RoundCreationSource.homeSuggestion,
    );

    expect(sentEvents, hasLength(1));
    expect(sentEvents.single.source, RoundCreationSource.homeSuggestion);
    expect(sentEvents.single.toyCount, 1);

    final rounds = await db.select(db.rounds).get();
    final demoRound = rounds.singleWhere(
      (round) => round.id == 'demo_active_round',
    );
    final userRound = rounds.singleWhere(
      (round) => round.id != 'demo_active_round',
    );
    expect(demoRound.endAt, isNotNull);
    expect(userRound.endAt, isNull);
  });

  test('startRound usa a mesma decisão central e preserva a origem', () async {
    final result = await roundRepository.startRound(
      date: DateTime(2026, 7, 28, 10),
      source: RoundCreationSource.toysTab,
    );

    expect(result.created, isTrue);
    expect(sentEvents, hasLength(1));
    expect(sentEvents.single.source, RoundCreationSource.toysTab);
    expect(sentEvents.single.toyCount, result.selectedCount);
  });

  test('falha de persistência não tenta first_round_created', () async {
    await expectLater(
      roundRepository.setActiveRoundFromToyIds(
        const <String>['toy_inexistente'],
        source: RoundCreationSource.roundSuggestion,
      ),
      throwsStateError,
    );

    expect(sentEvents, isEmpty);
    expect(await db.select(db.rounds).get(), isEmpty);
  });

  test('usuário com rodada preexistente não recebe ativação retroativa',
      () async {
    await db.into(db.rounds).insert(
          RoundsCompanion.insert(
            id: 'round_preexistente',
            startAt: DateTime(2026, 7, 27, 10).millisecondsSinceEpoch,
            endAt: Value(
              DateTime(2026, 7, 27, 11).millisecondsSinceEpoch,
            ),
          ),
        );

    await roundRepository.setActiveRoundFromToyIds(
      const <String>['toy_1'],
      date: DateTime(2026, 7, 28, 10),
      source: RoundCreationSource.homeIpadStart,
    );

    expect(sentEvents, isEmpty);
    expect(await db.select(db.rounds).get(), hasLength(2));
  });

  test('todos os fluxos ativos encaminham uma origem canônica', () async {
    final mainShell = await File('lib/ui/main_shell.dart').readAsString();
    final roundPage = await File('lib/ui/rodada_page.dart').readAsString();
    final toysPage = await File('lib/ui/brinquedos_page.dart').readAsString();
    final manualPage =
        await File('lib/ui/brincadeira_pronta_page.dart').readAsString();

    expect(
      mainShell,
      contains('source: RoundCreationSource.homeSuggestion'),
    );
    expect(
      mainShell,
      contains('source: RoundCreationSource.homeIpadSuggestion'),
    );
    expect(
      mainShell,
      contains('source: RoundCreationSource.homeIpadStart'),
    );
    expect(
      toysPage,
      contains('source: RoundCreationSource.toysTab'),
    );
    expect(
      roundPage,
      contains('source: RoundCreationSource.roundSuggestion'),
    );
    expect(
      manualPage,
      contains('source: RoundCreationSource.roundManual'),
    );
  });
}

Future<void> _insertToy(
  AppDatabase db, {
  required String id,
  required int createdAt,
}) async {
  await db.into(db.toys).insert(
        ToysCompanion.insert(
          id: id,
          categoryId: const Value('corpo'),
          name: 'Toy $id',
          createdAt: createdAt,
          boxId: const Value(null),
          locationText: const Value(null),
          photoPath: const Value(null),
        ),
      );
}

class _RepositoryFirstRoundEvent {
  const _RepositoryFirstRoundEvent({
    required this.toyCount,
    required this.source,
  });

  final int toyCount;
  final RoundCreationSource source;
}
