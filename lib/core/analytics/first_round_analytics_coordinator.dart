import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RoundCreationSource {
  homeSuggestion('home_suggestion'),
  homeIpadSuggestion('home_ipad_suggestion'),
  homeIpadStart('home_ipad_start'),
  toysTab('toys_tab'),
  roundSuggestion('round_suggestion'),
  roundManual('round_manual');

  const RoundCreationSource(this.analyticsValue);

  final String analyticsValue;

  static RoundCreationSource? fromAnalyticsValue(String value) {
    for (final source in values) {
      if (source.analyticsValue == value) return source;
    }
    return null;
  }
}

enum FirstRoundAnalyticsState {
  notRecorded('not_recorded'),
  pending('pending'),
  sent('sent');

  const FirstRoundAnalyticsState(this.storageValue);

  final String storageValue;

  static FirstRoundAnalyticsState? fromStorageValue(String value) {
    for (final state in values) {
      if (state.storageValue == value) return state;
    }
    return null;
  }
}

typedef FirstRoundAnalyticsSender = Future<bool> Function({
  required int toyCount,
  required RoundCreationSource source,
});

class FirstRoundAnalyticsCoordinator {
  FirstRoundAnalyticsCoordinator({
    required Future<SharedPreferences> Function() preferencesProvider,
    required bool Function() isAnalyticsConfigured,
    required FirstRoundAnalyticsSender sendEvent,
  })  : _preferencesProvider = preferencesProvider,
        _isAnalyticsConfigured = isAnalyticsConfigured,
        _sendEvent = sendEvent;

  factory FirstRoundAnalyticsCoordinator.withSharedPreferences({
    required bool Function() isAnalyticsConfigured,
    required FirstRoundAnalyticsSender sendEvent,
  }) {
    return FirstRoundAnalyticsCoordinator(
      preferencesProvider: SharedPreferences.getInstance,
      isAnalyticsConfigured: isAnalyticsConfigured,
      sendEvent: sendEvent,
    );
  }

  static const String legacyLoggedKey = 'analytics_first_round_created_logged';
  static const String stateStorageKey =
      'analytics_first_round_created_state_v1';

  final Future<SharedPreferences> Function() _preferencesProvider;
  final bool Function() _isAnalyticsConfigured;
  final FirstRoundAnalyticsSender _sendEvent;

  Future<void> _operationTail = Future<void>.value();

  Future<void> recordFirstPersistence({
    required RoundCreationSource source,
    required int toyCount,
  }) {
    return _serialized(() async {
      final preferences = await _preferencesProvider();
      final current = await _loadOrMigrate(preferences);

      if (current.state == FirstRoundAnalyticsState.sent) return;
      if (current.state == FirstRoundAnalyticsState.pending) {
        await _trySendPending(preferences, current);
        return;
      }

      final pending = _FirstRoundAnalyticsRecord(
        state: FirstRoundAnalyticsState.pending,
        source: source,
        toyCount: toyCount < 0 ? 0 : toyCount,
      );
      final pendingSaved = await _save(preferences, pending);
      if (!pendingSaved) return;

      await _trySendPending(preferences, pending);
    });
  }

  Future<void> retryPending() {
    return _serialized(() async {
      final preferences = await _preferencesProvider();
      final current = await _loadOrMigrate(preferences);
      if (current.state != FirstRoundAnalyticsState.pending) return;
      await _trySendPending(preferences, current);
    });
  }

  @visibleForTesting
  Future<FirstRoundAnalyticsState> readState() {
    return _serialized(() async {
      final preferences = await _preferencesProvider();
      return (await _loadOrMigrate(preferences)).state;
    });
  }

  Future<_FirstRoundAnalyticsRecord> _loadOrMigrate(
    SharedPreferences preferences,
  ) async {
    final stored = preferences.getString(stateStorageKey);
    final decoded = _FirstRoundAnalyticsRecord.tryDecode(stored);
    if (decoded != null) return decoded;

    final migratedState = preferences.getBool(legacyLoggedKey) == true
        ? FirstRoundAnalyticsState.sent
        : FirstRoundAnalyticsState.notRecorded;
    final migrated = _FirstRoundAnalyticsRecord(state: migratedState);
    await _save(preferences, migrated);
    return migrated;
  }

  Future<void> _trySendPending(
    SharedPreferences preferences,
    _FirstRoundAnalyticsRecord pending,
  ) async {
    final source = pending.source;
    final toyCount = pending.toyCount;
    if (!_isAnalyticsConfigured() || source == null || toyCount == null) {
      return;
    }

    try {
      final accepted = await _sendEvent(
        toyCount: toyCount,
        source: source,
      );
      if (!accepted) return;

      const sent = _FirstRoundAnalyticsRecord(
        state: FirstRoundAnalyticsState.sent,
      );
      final sentSaved = await _save(preferences, sent);
      if (sentSaved) {
        await preferences.setBool(legacyLoggedKey, true);
      }
    } catch (error) {
      debugPrint('First round Analytics event remains pending: $error');
    }
  }

  Future<bool> _save(
    SharedPreferences preferences,
    _FirstRoundAnalyticsRecord record,
  ) async {
    try {
      return await preferences.setString(
        stateStorageKey,
        record.encode(),
      );
    } catch (error) {
      debugPrint('First round Analytics state could not be saved: $error');
      return false;
    }
  }

  Future<T> _serialized<T>(Future<T> Function() operation) {
    final result = _operationTail.then((_) => operation());
    _operationTail = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return result;
  }
}

class _FirstRoundAnalyticsRecord {
  const _FirstRoundAnalyticsRecord({
    required this.state,
    this.source,
    this.toyCount,
  });

  final FirstRoundAnalyticsState state;
  final RoundCreationSource? source;
  final int? toyCount;

  String encode() {
    return jsonEncode(<String, Object>{
      'state': state.storageValue,
      if (source != null) 'round_source': source!.analyticsValue,
      if (toyCount != null) 'toy_count': toyCount!,
    });
  }

  static _FirstRoundAnalyticsRecord? tryDecode(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) return null;

      final stateValue = decoded['state'];
      if (stateValue is! String) return null;
      final state = FirstRoundAnalyticsState.fromStorageValue(stateValue);
      if (state == null) return null;

      final sourceValue = decoded['round_source'];
      final source = sourceValue is String
          ? RoundCreationSource.fromAnalyticsValue(sourceValue)
          : null;
      final rawToyCount = decoded['toy_count'];
      final toyCount = rawToyCount is int ? rawToyCount : null;

      if (state == FirstRoundAnalyticsState.pending &&
          (source == null || toyCount == null)) {
        return null;
      }

      return _FirstRoundAnalyticsRecord(
        state: state,
        source: source,
        toyCount: toyCount,
      );
    } catch (_) {
      return null;
    }
  }
}
