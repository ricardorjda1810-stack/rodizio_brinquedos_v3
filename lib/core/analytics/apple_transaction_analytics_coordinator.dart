import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppleTransactionAnalyticsState {
  pending('pending'),
  sent('sent');

  const AppleTransactionAnalyticsState(this.storageValue);

  final String storageValue;

  static AppleTransactionAnalyticsState? fromStorageValue(String value) {
    for (final state in values) {
      if (state.storageValue == value) return state;
    }
    return null;
  }
}

typedef AppleTransactionAnalyticsSender = Future<void> Function(
  String transactionId,
);

class AppleTransactionAnalyticsCoordinator {
  AppleTransactionAnalyticsCoordinator({
    required Future<SharedPreferences> Function() preferencesProvider,
    required bool Function() isAnalyticsConfigured,
    required AppleTransactionAnalyticsSender sendTransaction,
  })  : _preferencesProvider = preferencesProvider,
        _isAnalyticsConfigured = isAnalyticsConfigured,
        _sendTransaction = sendTransaction;

  factory AppleTransactionAnalyticsCoordinator.withSharedPreferences({
    required bool Function() isAnalyticsConfigured,
    required AppleTransactionAnalyticsSender sendTransaction,
  }) {
    return AppleTransactionAnalyticsCoordinator(
      preferencesProvider: SharedPreferences.getInstance,
      isAnalyticsConfigured: isAnalyticsConfigured,
      sendTransaction: sendTransaction,
    );
  }

  static const String storageKey = 'analytics_apple_transaction_ledger_v1';
  static const int maxStoredTransactions = 200;

  final Future<SharedPreferences> Function() _preferencesProvider;
  final bool Function() _isAnalyticsConfigured;
  final AppleTransactionAnalyticsSender _sendTransaction;

  final Set<String> _attemptedFromPurchaseUpdates = <String>{};
  Future<void> _operationTail = Future<void>.value();

  Future<void> recordNewPurchase(String transactionId) {
    return _serialized(() async {
      if (transactionId.trim().isEmpty) return;

      final preferences = await _preferencesProvider();
      final records = _load(preferences);
      final existing = _find(records, transactionId);
      if (existing?.state == AppleTransactionAnalyticsState.sent) return;

      if (existing == null) {
        records.add(
          _AppleTransactionAnalyticsRecord(
            transactionId: transactionId,
            state: AppleTransactionAnalyticsState.pending,
          ),
        );
        if (!await _save(preferences, records)) return;
      }

      if (_attemptedFromPurchaseUpdates.contains(transactionId)) return;
      await _trySendPending(
        preferences,
        records,
        transactionId,
        markPurchaseUpdateAttempt: true,
      );
    });
  }

  Future<void> retryPending() {
    return _serialized(() async {
      if (!_isAnalyticsConfigured()) return;

      final preferences = await _preferencesProvider();
      final records = _load(preferences);
      final pendingIds = records
          .where(
            (record) => record.state == AppleTransactionAnalyticsState.pending,
          )
          .map((record) => record.transactionId)
          .toList(growable: false);

      for (final transactionId in pendingIds) {
        await _trySendPending(
          preferences,
          records,
          transactionId,
          markPurchaseUpdateAttempt: false,
        );
      }
    });
  }

  @visibleForTesting
  Future<AppleTransactionAnalyticsState?> readState(String transactionId) {
    return stateForTransaction(transactionId);
  }

  Future<AppleTransactionAnalyticsState?> stateForTransaction(
    String transactionId,
  ) {
    return _serialized(() async {
      final preferences = await _preferencesProvider();
      return _find(_load(preferences), transactionId)?.state;
    });
  }

  @visibleForTesting
  Future<int> readStoredCount() {
    return _serialized(() async {
      final preferences = await _preferencesProvider();
      return _load(preferences).length;
    });
  }

  Future<void> _trySendPending(
    SharedPreferences preferences,
    List<_AppleTransactionAnalyticsRecord> records,
    String transactionId, {
    required bool markPurchaseUpdateAttempt,
  }) async {
    if (!_isAnalyticsConfigured()) return;

    final record = _find(records, transactionId);
    if (record == null ||
        record.state != AppleTransactionAnalyticsState.pending) {
      return;
    }

    if (markPurchaseUpdateAttempt) {
      _attemptedFromPurchaseUpdates.add(transactionId);
    }

    try {
      await _sendTransaction(transactionId);
    } catch (_) {
      debugPrint('Apple transaction Analytics remains pending.');
      return;
    }

    record.state = AppleTransactionAnalyticsState.sent;
    if (!await _save(preferences, records)) {
      record.state = AppleTransactionAnalyticsState.pending;
    }
  }

  List<_AppleTransactionAnalyticsRecord> _load(
    SharedPreferences preferences,
  ) {
    final encoded = preferences.getString(storageKey);
    if (encoded == null || encoded.isEmpty) {
      return <_AppleTransactionAnalyticsRecord>[];
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List<dynamic>) {
        return <_AppleTransactionAnalyticsRecord>[];
      }

      return decoded
          .map(_AppleTransactionAnalyticsRecord.tryDecode)
          .whereType<_AppleTransactionAnalyticsRecord>()
          .toList();
    } catch (_) {
      return <_AppleTransactionAnalyticsRecord>[];
    }
  }

  Future<bool> _save(
    SharedPreferences preferences,
    List<_AppleTransactionAnalyticsRecord> records,
  ) async {
    _prune(records);
    try {
      return await preferences.setString(
        storageKey,
        jsonEncode(
          records.map((record) => record.encode()).toList(growable: false),
        ),
      );
    } catch (_) {
      debugPrint('Apple transaction Analytics state could not be saved.');
      return false;
    }
  }

  void _prune(List<_AppleTransactionAnalyticsRecord> records) {
    while (records.length > maxStoredTransactions) {
      final oldestSentIndex = records.indexWhere(
        (record) => record.state == AppleTransactionAnalyticsState.sent,
      );
      records.removeAt(oldestSentIndex >= 0 ? oldestSentIndex : 0);
    }
  }

  _AppleTransactionAnalyticsRecord? _find(
    List<_AppleTransactionAnalyticsRecord> records,
    String transactionId,
  ) {
    for (final record in records) {
      if (record.transactionId == transactionId) return record;
    }
    return null;
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

class _AppleTransactionAnalyticsRecord {
  _AppleTransactionAnalyticsRecord({
    required this.transactionId,
    required this.state,
  });

  final String transactionId;
  AppleTransactionAnalyticsState state;

  Map<String, String> encode() {
    return <String, String>{
      'transaction_id': transactionId,
      'state': state.storageValue,
    };
  }

  static _AppleTransactionAnalyticsRecord? tryDecode(Object? value) {
    if (value is! Map<String, dynamic>) return null;

    final transactionId = value['transaction_id'];
    final stateValue = value['state'];
    if (transactionId is! String ||
        transactionId.trim().isEmpty ||
        stateValue is! String) {
      return null;
    }
    final state = AppleTransactionAnalyticsState.fromStorageValue(stateValue);
    if (state == null) return null;

    return _AppleTransactionAnalyticsRecord(
      transactionId: transactionId,
      state: state,
    );
  }
}
