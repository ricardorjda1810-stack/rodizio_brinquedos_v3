// lib/main.dart
import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:rodizio_brinquedos_v3/bootstrap.dart'
    if (dart.library.html) 'package:rodizio_brinquedos_v3/bootstrap_web.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
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
      Intl.defaultLocale = 'pt_BR';
      runApp(const Bootstrap());
    },
    (error, stackTrace) {
      unawaited(
        _recordCrashlyticsError(
          error,
          stackTrace,
          fatal: true,
        ),
      );
    },
  );
}

Future<void> _initializeFirebaseServices() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _crashlyticsEnabled = true;
    await AppAnalytics.logAppOpen();
  } catch (error) {
    _crashlyticsEnabled = false;
    debugPrint('Firebase initialization skipped: $error');
  }
}

void _configureGlobalErrorHandling() {
  final defaultFlutterOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    defaultFlutterOnError?.call(details);
    unawaited(_recordFlutterFatalError(details));
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    if (!_crashlyticsEnabled) return false;
    unawaited(
      _recordCrashlyticsError(
        error,
        stackTrace,
        fatal: true,
      ),
    );
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
