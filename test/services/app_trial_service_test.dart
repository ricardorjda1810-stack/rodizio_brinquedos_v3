import 'package:flutter_test/flutter_test.dart';
import 'package:rodizio_brinquedos_v3/services/app_trial_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAppTrialSecureStore implements AppTrialSecureStore {
  final Map<String, String> values;

  _FakeAppTrialSecureStore([Map<String, String>? initialValues])
      : values = Map<String, String>.from(initialValues ?? const {});

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

String _date(DateTime value) => value.toUtc().toIso8601String();

Future<AppTrialService> _createService({
  Map<String, Object> preferences = const <String, Object>{},
  Map<String, String> secure = const <String, String>{},
  required DateTime Function() now,
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();
  final service = AppTrialService(
    preferences: prefs,
    secureStore: _FakeAppTrialSecureStore(secure),
    clock: now,
  );
  await service.initialize();
  return service;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('primeira abertura cria trial de 7 dias', () async {
    final now = DateTime.utc(2026, 1, 1, 9);
    final service = await _createService(now: () => now);

    expect(service.status.startedAt, now);
    expect(service.status.endsAt, now.add(AppTrialService.trialDuration));
    expect(service.status.trialUsed, isTrue);
    expect(service.status.isTrialActive, isTrue);
    expect(service.status.introPending, isTrue);
    expect(service.status.remainingDays, 7);
  });

  test('usuário sem assinatura e com trial ativo acessa o app', () async {
    final now = DateTime.utc(2026, 1, 2, 9);
    final service = await _createService(now: () => now);

    expect(
      service.status.allowsFullAppAccess(hasActiveSubscription: false),
      isTrue,
    );
  });

  test('usuário sem assinatura e com trial vencido é bloqueado', () async {
    final startedAt = DateTime.utc(2026, 1, 1, 9);
    final endsAt = startedAt.add(AppTrialService.trialDuration);
    final service = await _createService(
      preferences: <String, Object>{
        AppTrialService.appTrialStartedAtKey: _date(startedAt),
        AppTrialService.appTrialEndsAtKey: _date(endsAt),
        AppTrialService.appTrialUsedKey: true,
        AppTrialService.appTrialLastSeenAtKey: _date(endsAt),
      },
      now: () => DateTime.utc(2026, 1, 9, 9),
    );

    expect(service.status.isTrialExpired, isTrue);
    expect(
      service.status.allowsFullAppAccess(hasActiveSubscription: false),
      isFalse,
    );
  });

  test('usuário com assinatura ativa acessa mesmo com trial vencido', () async {
    final startedAt = DateTime.utc(2026, 1, 1, 9);
    final endsAt = startedAt.add(AppTrialService.trialDuration);
    final service = await _createService(
      preferences: <String, Object>{
        AppTrialService.appTrialStartedAtKey: _date(startedAt),
        AppTrialService.appTrialEndsAtKey: _date(endsAt),
        AppTrialService.appTrialUsedKey: true,
        AppTrialService.appTrialLastSeenAtKey: _date(endsAt),
      },
      now: () => DateTime.utc(2026, 1, 9, 9),
    );

    expect(service.status.isTrialExpired, isTrue);
    expect(
      service.status.allowsFullAppAccess(hasActiveSubscription: true),
      isTrue,
    );
  });

  test('voltar relógio não reativa nem aumenta o trial', () async {
    var currentTime = DateTime.utc(2026, 1, 1, 9);
    final secure = _FakeAppTrialSecureStore();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final firstService = AppTrialService(
      preferences: prefs,
      secureStore: secure,
      clock: () => currentTime,
    );
    await firstService.initialize();

    currentTime = DateTime.utc(2026, 1, 6, 9);
    await firstService.refreshForCurrentTime();
    final remainingBeforeRollback = firstService.status.remainingDays;
    expect(remainingBeforeRollback, 2);

    currentTime = DateTime.utc(2026, 1, 2, 9);
    final secondService = AppTrialService(
      preferences: prefs,
      secureStore: secure,
      clock: () => currentTime,
    );
    await secondService.initialize();

    expect(secondService.status.effectiveNow, DateTime.utc(2026, 1, 6, 9));
    expect(secondService.status.remainingDays, remainingBeforeRollback);
  });

  test('reinstalação não recria trial se Keychain indicar trial usado',
      () async {
    final startedAt = DateTime.utc(2026, 1, 1, 9);
    final endsAt = startedAt.add(AppTrialService.trialDuration);
    final service = await _createService(
      secure: <String, String>{
        AppTrialService.appTrialStartedAtKey: _date(startedAt),
        AppTrialService.appTrialEndsAtKey: _date(endsAt),
        AppTrialService.appTrialUsedKey: 'true',
        AppTrialService.appTrialLastSeenAtKey: _date(endsAt),
      },
      now: () => DateTime.utc(2026, 1, 10, 9),
    );

    expect(service.status.startedAt, startedAt);
    expect(service.status.endsAt, endsAt);
    expect(service.status.isTrialExpired, isTrue);
    expect(
      service.status.allowsFullAppAccess(hasActiveSubscription: false),
      isFalse,
    );
  });
}
