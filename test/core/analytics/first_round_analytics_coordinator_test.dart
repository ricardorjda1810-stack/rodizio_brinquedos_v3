import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/first_round_analytics_coordinator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late bool analyticsConfigured;
  late List<_SentFirstRoundEvent> sentEvents;
  late FirstRoundAnalyticsCoordinator coordinator;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    analyticsConfigured = false;
    sentEvents = <_SentFirstRoundEvent>[];
    coordinator = FirstRoundAnalyticsCoordinator(
      preferencesProvider: SharedPreferences.getInstance,
      isAnalyticsConfigured: () => analyticsConfigured,
      sendEvent: ({
        required int toyCount,
        required RoundCreationSource source,
      }) async {
        sentEvents.add(
          _SentFirstRoundEvent(toyCount: toyCount, source: source),
        );
        return true;
      },
    );
  });

  test('Analytics indisponível mantém estado e parâmetros pendentes', () async {
    await coordinator.recordFirstPersistence(
      source: RoundCreationSource.homeSuggestion,
      toyCount: 7,
    );

    expect(
      await coordinator.readState(),
      FirstRoundAnalyticsState.pending,
    );
    expect(sentEvents, isEmpty);

    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(
      FirstRoundAnalyticsCoordinator.stateStorageKey,
    );
    final record = jsonDecode(encoded!) as Map<String, dynamic>;
    expect(record['state'], 'pending');
    expect(record['round_source'], 'home_suggestion');
    expect(record['toy_count'], 7);
  });

  test('configuração posterior reprocessa pending e grava sent', () async {
    await coordinator.recordFirstPersistence(
      source: RoundCreationSource.homeIpadSuggestion,
      toyCount: 5,
    );

    analyticsConfigured = true;
    await coordinator.retryPending();

    expect(await coordinator.readState(), FirstRoundAnalyticsState.sent);
    expect(sentEvents, hasLength(1));
    expect(sentEvents.single.source, RoundCreationSource.homeIpadSuggestion);
    expect(sentEvents.single.toyCount, 5);
  });

  test('exceção do Analytics conserva pending', () async {
    analyticsConfigured = true;
    coordinator = FirstRoundAnalyticsCoordinator(
      preferencesProvider: SharedPreferences.getInstance,
      isAnalyticsConfigured: () => analyticsConfigured,
      sendEvent: ({
        required int toyCount,
        required RoundCreationSource source,
      }) async {
        throw StateError('falha simulada');
      },
    );

    await coordinator.recordFirstPersistence(
      source: RoundCreationSource.homeIpadStart,
      toyCount: 4,
    );

    expect(
      await coordinator.readState(),
      FirstRoundAnalyticsState.pending,
    );
  });

  test('sucesso e reinicialização com sent não duplicam evento', () async {
    analyticsConfigured = true;
    await coordinator.recordFirstPersistence(
      source: RoundCreationSource.toysTab,
      toyCount: 3,
    );

    final restarted = FirstRoundAnalyticsCoordinator(
      preferencesProvider: SharedPreferences.getInstance,
      isAnalyticsConfigured: () => analyticsConfigured,
      sendEvent: ({
        required int toyCount,
        required RoundCreationSource source,
      }) async {
        sentEvents.add(
          _SentFirstRoundEvent(toyCount: toyCount, source: source),
        );
        return true;
      },
    );
    await restarted.retryPending();
    await restarted.recordFirstPersistence(
      source: RoundCreationSource.roundManual,
      toyCount: 8,
    );

    expect(await restarted.readState(), FirstRoundAnalyticsState.sent);
    expect(sentEvents, hasLength(1));
  });

  test('duas chamadas concorrentes produzem um único disparo', () async {
    analyticsConfigured = true;

    await Future.wait(<Future<void>>[
      coordinator.recordFirstPersistence(
        source: RoundCreationSource.roundSuggestion,
        toyCount: 6,
      ),
      coordinator.recordFirstPersistence(
        source: RoundCreationSource.roundSuggestion,
        toyCount: 6,
      ),
    ]);

    expect(sentEvents, hasLength(1));
    expect(await coordinator.readState(), FirstRoundAnalyticsState.sent);
  });

  test('chave legada true migra para sent sem disparo', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      FirstRoundAnalyticsCoordinator.legacyLoggedKey: true,
    });
    analyticsConfigured = true;

    await coordinator.retryPending();
    await coordinator.recordFirstPersistence(
      source: RoundCreationSource.roundManual,
      toyCount: 2,
    );

    expect(await coordinator.readState(), FirstRoundAnalyticsState.sent);
    expect(sentEvents, isEmpty);
  });

  test('fontes canônicas permanecem estáveis', () {
    expect(
      RoundCreationSource.values
          .map((source) => source.analyticsValue)
          .toList(growable: false),
      <String>[
        'home_suggestion',
        'home_ipad_suggestion',
        'home_ipad_start',
        'toys_tab',
        'round_suggestion',
        'round_manual',
      ],
    );
  });

  test('inventário contém os 14 nomes customizados autorizados', () {
    expect(
      AppAnalytics.knownEventNames,
      <String>{
        'app_open',
        'toy_created',
        'first_round_created',
        'round_created',
        'suggestion_opened',
        'suggestion_used',
        'weekly_planning_opened',
        'paywall_viewed',
        'premium_plan_selected',
        'purchase_started',
        'purchase_completed',
        'purchase_restored',
        'purchase_failed',
        'purchase_canceled',
      },
    );
  });
}

class _SentFirstRoundEvent {
  const _SentFirstRoundEvent({
    required this.toyCount,
    required this.source,
  });

  final int toyCount;
  final RoundCreationSource source;
}
