// lib/main.dart
import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:rodizio_brinquedos_v3/bootstrap.dart'
    if (dart.library.html) 'package:rodizio_brinquedos_v3/bootstrap_web.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/core/config/app_check_provider_selection.dart';
import 'package:rodizio_brinquedos_v3/core/config/firebase_environment.dart';
import 'package:rodizio_brinquedos_v3/firebase_options.dart';

bool _crashlyticsEnabled = false;

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await _initializeFirebaseServices();
      _configureGlobalErrorHandling();
      _configureCrashlyticsDebugTestHook();
      await initializeDateFormatting('pt_BR', null);
      await initializeDateFormatting('en_US', null);
      final platformLocale = PlatformDispatcher.instance.locale;
      Intl.defaultLocale =
          platformLocale.languageCode == 'en' ? 'en_US' : 'pt_BR';
      runApp(const Bootstrap());
    },
    (error, stackTrace) {
      unawaited(_recordCrashlyticsError(error, stackTrace, fatal: true));
    },
  );
}

Future<void> _initializeFirebaseServices() async {
  final requiresExplicitIosEnvironment =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  FirebaseEnvironment? iosEnvironment;

  try {
    if (requiresExplicitIosEnvironment) {
      final environment = FirebaseEnvironment.fromBuildConfiguration();
      iosEnvironment = environment;
      final app = await Firebase.initializeApp();
      environment.validate(app.options);
      await AppAnalytics.configureEnvironment(environment: environment.name);
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await AppAnalytics.configureEnvironment(
        environment: FirebaseEnvironment.production.name,
      );
    }
    _crashlyticsEnabled = true;
    await _activateFirebaseAppCheck(iosEnvironment: iosEnvironment);
    await AppAnalytics.logAppOpen();
  } catch (error, stackTrace) {
    _crashlyticsEnabled = false;
    if (requiresExplicitIosEnvironment) {
      debugPrint(
          'Firebase initialization failed for the declared iOS environment.');
      Error.throwWithStackTrace(error, stackTrace);
    }
    debugPrint('Firebase initialization skipped: $error');
  }
}

Future<void> _activateFirebaseAppCheck({
  required FirebaseEnvironment? iosEnvironment,
}) async {
  final providers = selectFirebaseAppCheckProviders(
    platform: _currentAppCheckPlatform(),
    buildMode: _currentAppCheckBuildMode(),
    iosEnvironment: iosEnvironment,
  );
  if (providers == null) return;

  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: providers.android,
      providerApple: providers.apple,
    );
  } catch (error, stackTrace) {
    await _recordCrashlyticsError(error, stackTrace, fatal: false);
  }
}

AppCheckRuntimePlatform _currentAppCheckPlatform() {
  if (kIsWeb) return AppCheckRuntimePlatform.unsupported;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => AppCheckRuntimePlatform.android,
    TargetPlatform.iOS => AppCheckRuntimePlatform.ios,
    _ => AppCheckRuntimePlatform.unsupported,
  };
}

AppCheckBuildMode _currentAppCheckBuildMode() {
  if (kDebugMode) return AppCheckBuildMode.debug;
  if (kProfileMode) return AppCheckBuildMode.profile;
  return AppCheckBuildMode.release;
}

void _configureGlobalErrorHandling() {
  final defaultFlutterOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    defaultFlutterOnError?.call(details);
    unawaited(_recordFlutterFatalError(details));
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    if (!_crashlyticsEnabled) return false;
    unawaited(_recordCrashlyticsError(error, stackTrace, fatal: true));
    return true;
  };
}

Future<void> _recordFlutterFatalError(FlutterErrorDetails details) async {
  if (!_crashlyticsEnabled) return;

  try {
    await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  } catch (error) {
    debugPrint('Crashlytics Flutter error skipped: $error');
  }
}

Future<void> _recordCrashlyticsError(
  Object error,
  StackTrace stackTrace, {
  required bool fatal,
}) async {
  if (!_crashlyticsEnabled) return;

  try {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      fatal: fatal,
    );
  } catch (recordError) {
    debugPrint('Crashlytics error report skipped: $recordError');
  }
}

void _configureCrashlyticsDebugTestHook() {
  assert(() {
    // Manual debug-only test hook:
    // temporarily uncomment the next line while running a dev build on iOS.
    // if (_crashlyticsEnabled) FirebaseCrashlytics.instance.crash();
    return true;
  }());
}
