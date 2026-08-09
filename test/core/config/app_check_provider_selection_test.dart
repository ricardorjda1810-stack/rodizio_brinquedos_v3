import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rodizio_brinquedos_v3/core/config/app_check_provider_selection.dart';
import 'package:rodizio_brinquedos_v3/core/config/firebase_environment.dart';

void main() {
  FirebaseAppCheckProviderSelection select({
    required AppCheckRuntimePlatform platform,
    required AppCheckBuildMode buildMode,
    FirebaseEnvironment? environment,
  }) {
    return selectFirebaseAppCheckProviders(
      platform: platform,
      buildMode: buildMode,
      iosEnvironment: environment,
    )!;
  }

  test('Android debug usa AndroidDebugProvider', () {
    final providers = select(
      platform: AppCheckRuntimePlatform.android,
      buildMode: AppCheckBuildMode.debug,
    );

    expect(providers.kind, AppCheckProviderKind.androidDebug);
    expect(providers.android, isA<AndroidDebugProvider>());
  });

  for (final mode in <AppCheckBuildMode>[
    AppCheckBuildMode.profile,
    AppCheckBuildMode.release,
  ]) {
    test('Android ${mode.name} usa Play Integrity', () {
      final providers = select(
        platform: AppCheckRuntimePlatform.android,
        buildMode: mode,
      );

      expect(providers.kind, AppCheckProviderKind.androidPlayIntegrity);
      expect(providers.android, isA<AndroidPlayIntegrityProvider>());
    });
  }

  for (final environment in FirebaseEnvironment.values) {
    test('Android release ignora FIREBASE_ENV=${environment.name}', () {
      final providers = select(
        platform: AppCheckRuntimePlatform.android,
        buildMode: AppCheckBuildMode.release,
        environment: environment,
      );

      expect(providers.kind, AppCheckProviderKind.androidPlayIntegrity);
      expect(providers.android, isA<AndroidPlayIntegrityProvider>());
    });

    test('iOS debug ${environment.name} usa AppleDebugProvider', () {
      final providers = select(
        platform: AppCheckRuntimePlatform.ios,
        buildMode: AppCheckBuildMode.debug,
        environment: environment,
      );

      expect(providers.kind, AppCheckProviderKind.appleDebug);
      expect(providers.apple, isA<AppleDebugProvider>());
    });
  }

  for (final mode in <AppCheckBuildMode>[
    AppCheckBuildMode.profile,
    AppCheckBuildMode.release,
  ]) {
    test('iOS staging ${mode.name} usa App Attest estrito', () {
      final providers = select(
        platform: AppCheckRuntimePlatform.ios,
        buildMode: mode,
        environment: FirebaseEnvironment.staging,
      );

      expect(providers.kind, AppCheckProviderKind.appleAppAttest);
      expect(providers.apple, isA<AppleAppAttestProvider>());
      expect(
        providers.apple,
        isNot(isA<AppleAppAttestWithDeviceCheckFallbackProvider>()),
      );
    });

    test('iOS production ${mode.name} preserva fallback', () {
      final providers = select(
        platform: AppCheckRuntimePlatform.ios,
        buildMode: mode,
        environment: FirebaseEnvironment.production,
      );

      expect(
        providers.kind,
        AppCheckProviderKind.appleAppAttestWithDeviceCheckFallback,
      );
      expect(
        providers.apple,
        isA<AppleAppAttestWithDeviceCheckFallbackProvider>(),
      );
      expect(providers.apple, isNot(isA<AppleAppAttestProvider>()));
    });
  }

  test('plataforma não suportada não ativa App Check', () {
    final providers = selectFirebaseAppCheckProviders(
      platform: AppCheckRuntimePlatform.unsupported,
      buildMode: AppCheckBuildMode.release,
      iosEnvironment: FirebaseEnvironment.production,
    );

    expect(providers, isNull);
  });

  test('main mantém exatamente uma chamada funcional de activate', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(
      RegExp(r'FirebaseAppCheck\.instance\.activate\(').allMatches(mainSource),
      hasLength(1),
    );
  });

  test('Android nunca fica sem provider nos modos suportados', () {
    for (final mode in AppCheckBuildMode.values) {
      final providers = selectFirebaseAppCheckProviders(
        platform: AppCheckRuntimePlatform.android,
        buildMode: mode,
      );

      expect(providers, isNotNull, reason: mode.name);
      expect(providers!.android, isA<AndroidAppCheckProvider>());
    }
  });
}
