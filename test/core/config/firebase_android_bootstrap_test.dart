import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rodizio_brinquedos_v3/core/config/app_check_provider_selection.dart';
import 'package:rodizio_brinquedos_v3/firebase_options.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('Android possui opções Firebase production válidas', () {
    const options = DefaultFirebaseOptions.android;

    expect(options.projectId, 'rodizio-de-brinquedos');
    expect(options.appId, isNotEmpty);
    expect(options.appId, contains(':android:'));
    expect(options.apiKey, isNotEmpty);
    expect(options.messagingSenderId, isNotEmpty);
  });

  test('currentPlatform resolve Android sem UnsupportedError', () {
    const iosBefore = DefaultFirebaseOptions.ios;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(
      () => DefaultFirebaseOptions.currentPlatform,
      returnsNormally,
    );
    expect(
      DefaultFirebaseOptions.currentPlatform,
      same(DefaultFirebaseOptions.android),
    );
    expect(DefaultFirebaseOptions.ios, same(iosBefore));
  });

  test('opções Android não dependem de FIREBASE_ENV', () {
    final source = File('lib/firebase_options.dart').readAsStringSync();
    final androidStart = source.indexOf('static const FirebaseOptions android');
    final iosStart = source.indexOf('static const FirebaseOptions ios');

    expect(androidStart, greaterThanOrEqualTo(0));
    expect(iosStart, greaterThan(androidStart));
    expect(
      source.substring(androidStart, iosStart),
      isNot(contains('FIREBASE_ENV')),
    );
  });

  test('Android seleciona Debug Provider em debug', () {
    final providers = selectFirebaseAppCheckProviders(
      platform: AppCheckRuntimePlatform.android,
      buildMode: AppCheckBuildMode.debug,
    );

    expect(providers, isNotNull);
    expect(providers!.kind, AppCheckProviderKind.androidDebug);
    expect(providers.android, isA<AndroidDebugProvider>());
  });

  for (final mode in <AppCheckBuildMode>[
    AppCheckBuildMode.profile,
    AppCheckBuildMode.release,
  ]) {
    test('Android seleciona Play Integrity em ${mode.name}', () {
      final providers = selectFirebaseAppCheckProviders(
        platform: AppCheckRuntimePlatform.android,
        buildMode: mode,
      );

      expect(providers, isNotNull);
      expect(providers!.kind, AppCheckProviderKind.androidPlayIntegrity);
      expect(providers.android, isA<AndroidPlayIntegrityProvider>());
    });
  }

  test('bootstrap mantém ativação do App Check alcançável', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(
      mainSource,
      contains('await _activateFirebaseAppCheck('),
    );
    expect(
      RegExp(r'FirebaseAppCheck\.instance\.activate\(').allMatches(mainSource),
      hasLength(1),
    );
  });

  test('opções iOS permanecem disponíveis e identificadas', () {
    const options = DefaultFirebaseOptions.ios;

    expect(options.projectId, 'rodizio-de-brinquedos');
    expect(options.iosBundleId, 'com.rodiziobrinquedos.v3');
    expect(options.appId, isNotEmpty);
    expect(options.appId, contains(':ios:'));
    expect(options.apiKey, isNotEmpty);
    expect(options.messagingSenderId, isNotEmpty);
  });
}
