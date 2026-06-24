import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef AppTrialClock = DateTime Function();

abstract class AppTrialSecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class FlutterSecureAppTrialStore implements AppTrialSecureStore {
  final FlutterSecureStorage _storage;

  const FlutterSecureAppTrialStore([
    this._storage = const FlutterSecureStorage(),
  ]);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

@immutable
class AppTrialStatus {
  final DateTime? startedAt;
  final DateTime? endsAt;
  final DateTime lastSeenAt;
  final DateTime effectiveNow;
  final bool trialUsed;
  final bool introPending;

  const AppTrialStatus({
    required this.startedAt,
    required this.endsAt,
    required this.lastSeenAt,
    required this.effectiveNow,
    required this.trialUsed,
    required this.introPending,
  });

  factory AppTrialStatus.empty(DateTime now) {
    return AppTrialStatus(
      startedAt: null,
      endsAt: null,
      lastSeenAt: now,
      effectiveNow: now,
      trialUsed: false,
      introPending: false,
    );
  }

  bool get hasTrialDates => startedAt != null && endsAt != null;

  bool get isTrialActive => hasTrialDates && effectiveNow.isBefore(endsAt!);

  bool get isTrialExpired => trialUsed && !isTrialActive;

  bool allowsFullAppAccess({required bool hasActiveSubscription}) {
    return hasActiveSubscription || isTrialActive;
  }

  int get remainingDays {
    final end = endsAt;
    if (end == null || !isTrialActive) return 0;
    final remaining = end.difference(effectiveNow);
    if (remaining <= Duration.zero) return 0;
    return math.max(1, (remaining.inSeconds / Duration.secondsPerDay).ceil());
  }

  String? get homeNotice {
    if (!isTrialActive) return null;
    if (remainingDays <= 1) {
      return 'Seu teste grátis termina hoje';
    }
    return 'Teste grátis ativo — faltam $remainingDays dias';
  }

  AppTrialStatus copyWith({
    DateTime? startedAt,
    DateTime? endsAt,
    DateTime? lastSeenAt,
    DateTime? effectiveNow,
    bool? trialUsed,
    bool? introPending,
  }) {
    return AppTrialStatus(
      startedAt: startedAt ?? this.startedAt,
      endsAt: endsAt ?? this.endsAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      effectiveNow: effectiveNow ?? this.effectiveNow,
      trialUsed: trialUsed ?? this.trialUsed,
      introPending: introPending ?? this.introPending,
    );
  }
}

class AppTrialService extends ChangeNotifier {
  static const Duration trialDuration = Duration(days: 7);

  static const String appTrialStartedAtKey = 'appTrialStartedAt';
  static const String appTrialEndsAtKey = 'appTrialEndsAt';
  static const String appTrialUsedKey = 'appTrialUsed';
  static const String appTrialLastSeenAtKey = 'appTrialLastSeenAt';
  static const String _appTrialIntroSeenKey = 'appTrialIntroSeen';

  final SharedPreferences _preferences;
  final AppTrialSecureStore _secureStore;
  final AppTrialClock _clock;

  AppTrialStatus _status;
  Timer? _expiryTimer;
  bool _initialized = false;

  AppTrialService({
    required SharedPreferences preferences,
    required AppTrialSecureStore secureStore,
    AppTrialClock? clock,
  })  : _preferences = preferences,
        _secureStore = secureStore,
        _clock = clock ?? DateTime.now,
        _status = AppTrialStatus.empty((clock ?? DateTime.now)());

  static Future<AppTrialService> create() async {
    final preferences = await SharedPreferences.getInstance();
    final service = AppTrialService(
      preferences: preferences,
      secureStore: const FlutterSecureAppTrialStore(),
    );
    await service.initialize();
    return service;
  }

  AppTrialStatus get status => _status;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final localStartedAt = _readLocalDate(appTrialStartedAtKey);
    final localEndsAt = _readLocalDate(appTrialEndsAtKey);
    final localLastSeenAt = _readLocalDate(appTrialLastSeenAtKey);
    final localTrialUsed = _preferences.getBool(appTrialUsedKey) ?? false;

    final secureStartedAt = _parseDate(
      await _readSecure(appTrialStartedAtKey),
    );
    final secureEndsAt = _parseDate(await _readSecure(appTrialEndsAtKey));
    final secureLastSeenAt = _parseDate(
      await _readSecure(appTrialLastSeenAtKey),
    );
    final secureTrialUsed =
        _parseBool(await _readSecure(appTrialUsedKey)) ?? false;

    final previousLastSeen = _maxDate(localLastSeenAt, secureLastSeenAt);
    var effectiveNow = _safeNow(previousLastSeen);
    var startedAt = _earliestDate(localStartedAt, secureStartedAt);
    var endsAt = _earliestDate(localEndsAt, secureEndsAt);
    var trialUsed = localTrialUsed || secureTrialUsed;
    var introPending = false;

    if (startedAt == null && endsAt == null && !trialUsed) {
      startedAt = effectiveNow;
      endsAt = startedAt.add(trialDuration);
      trialUsed = true;
      introPending = !(_preferences.getBool(_appTrialIntroSeenKey) ?? false);
    } else if (trialUsed && (startedAt == null || endsAt == null)) {
      final fallbackEnd = endsAt ?? previousLastSeen ?? effectiveNow;
      endsAt = fallbackEnd;
      startedAt = startedAt ?? fallbackEnd.subtract(trialDuration);
      trialUsed = true;
    } else {
      introPending = false;
    }

    final lastSeenAt = _maxDate(previousLastSeen, effectiveNow) ?? effectiveNow;
    effectiveNow = _safeNow(lastSeenAt);
    _status = AppTrialStatus(
      startedAt: startedAt,
      endsAt: endsAt,
      lastSeenAt: lastSeenAt,
      effectiveNow: effectiveNow,
      trialUsed: trialUsed,
      introPending: introPending,
    );

    await _persistStatus(_status);
    _scheduleExpiryNotification();
    notifyListeners();
  }

  Future<void> markIntroSeen() async {
    await _preferences.setBool(_appTrialIntroSeenKey, true);
    if (!_status.introPending) return;
    _status = _status.copyWith(introPending: false);
    notifyListeners();
  }

  @visibleForTesting
  Future<void> refreshForCurrentTime() async {
    final previousLastSeen = _status.lastSeenAt;
    final effectiveNow = _safeNow(previousLastSeen);
    final lastSeenAt = _maxDate(previousLastSeen, effectiveNow) ?? effectiveNow;
    _status = _status.copyWith(
      effectiveNow: effectiveNow,
      lastSeenAt: lastSeenAt,
    );
    await _persistStatus(_status);
    _scheduleExpiryNotification();
    notifyListeners();
  }

  DateTime _safeNow(DateTime? previousLastSeen) {
    final now = _clock();
    if (previousLastSeen != null && now.isBefore(previousLastSeen)) {
      return previousLastSeen;
    }
    return now;
  }

  Future<void> _persistStatus(AppTrialStatus status) async {
    final startedAt = status.startedAt;
    final endsAt = status.endsAt;

    if (startedAt != null) {
      await _writeLocalAndSecure(appTrialStartedAtKey, _formatDate(startedAt));
    }
    if (endsAt != null) {
      await _writeLocalAndSecure(appTrialEndsAtKey, _formatDate(endsAt));
    }
    await _preferences.setBool(appTrialUsedKey, status.trialUsed);
    await _writeSecure(appTrialUsedKey, status.trialUsed.toString());
    await _writeLocalAndSecure(
      appTrialLastSeenAtKey,
      _formatDate(status.lastSeenAt),
    );
  }

  Future<void> _writeLocalAndSecure(String key, String value) async {
    await _preferences.setString(key, value);
    await _writeSecure(key, value);
  }

  void _scheduleExpiryNotification() {
    _expiryTimer?.cancel();
    final end = _status.endsAt;
    if (end == null || !_status.isTrialActive) return;

    final delay = end.difference(_clock());
    if (delay <= Duration.zero) {
      unawaited(refreshForCurrentTime());
      return;
    }

    _expiryTimer = Timer(delay, () {
      unawaited(refreshForCurrentTime());
    });
  }

  DateTime? _readLocalDate(String key) =>
      _parseDate(_preferences.getString(key));

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _formatDate(DateTime value) => value.toUtc().toIso8601String();

  bool? _parseBool(String? value) {
    switch (value?.toLowerCase()) {
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        return null;
    }
  }

  DateTime? _maxDate(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  DateTime? _earliestDate(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isBefore(b) ? a : b;
  }

  Future<String?> _readSecure(String key) async {
    try {
      return await _secureStore.read(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeSecure(String key, String value) async {
    try {
      await _secureStore.write(key, value);
    } catch (_) {
      // Secure storage is a hardening layer. Local trial state remains the
      // fallback when Keychain/secure storage is temporarily unavailable.
    }
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }
}
