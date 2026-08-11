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

enum _FirebaseStartupStage {
  resolveEnvironment('resolve_environment'),
  initializeDefaultApp('initialize_default_app'),
  validateOptions('validate_options'),
  configureAnalytics('configure_analytics'),
  activateAppCheck('activate_app_check'),
  logAppOpen('log_app_open');

  const _FirebaseStartupStage(this.label);

  final String label;
}

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final firebaseEnvironment = await _initializeFirebaseServices();
      _configureGlobalErrorHandling();
      _configureCrashlyticsDebugTestHook();
      await initializeDateFormatting('pt_BR', null);
      await initializeDateFormatting('en_US', null);
      final platformLocale = PlatformDispatcher.instance.locale;
      Intl.defaultLocale =
          platformLocale.languageCode == 'en' ? 'en_US' : 'pt_BR';
      runApp(Bootstrap(firebaseEnvironment: firebaseEnvironment));
    },
    (error, stackTrace) {
      unawaited(_recordCrashlyticsError(error, stackTrace, fatal: true));
    },
  );
}

Future<FirebaseEnvironment?> _initializeFirebaseServices() async {
  final requiresExplicitIosEnvironment =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  var startupStage = _FirebaseStartupStage.initializeDefaultApp;
  FirebaseEnvironment? iosEnvironment;
  FirebaseOptions? initializedOptions;

  try {
    if (requiresExplicitIosEnvironment) {
      startupStage = _FirebaseStartupStage.initializeDefaultApp;
      final app = await Firebase.initializeApp();
      initializedOptions = app.options;
      startupStage = _FirebaseStartupStage.resolveEnvironment;
      final environment = FirebaseEnvironment.resolveIos(
        configuredValue: FirebaseEnvironment.configuredValue,
        options: app.options,
      );
      iosEnvironment = environment;
      startupStage = _FirebaseStartupStage.validateOptions;
      environment.validate(app.options);
      startupStage = _FirebaseStartupStage.configureAnalytics;
      await AppAnalytics.configureEnvironment(environment: environment.name);
    } else {
      startupStage = _FirebaseStartupStage.initializeDefaultApp;
      final app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      initializedOptions = app.options;
      startupStage = _FirebaseStartupStage.configureAnalytics;
      await AppAnalytics.configureEnvironment(
        environment: FirebaseEnvironment.production.name,
      );
    }
    _crashlyticsEnabled = true;
    startupStage = _FirebaseStartupStage.activateAppCheck;
    await _activateFirebaseAppCheck(iosEnvironment: iosEnvironment);
    startupStage = _FirebaseStartupStage.logAppOpen;
    await AppAnalytics.logAppOpen();
    if (requiresExplicitIosEnvironment && iosEnvironment != null) {
      _logFirebaseStartupSuccess(iosEnvironment);
    }
  } catch (error, stackTrace) {
    if (requiresExplicitIosEnvironment) {
      _logFirebaseStartupFailure(
        stage: startupStage,
        error: error,
        stackTrace: stackTrace,
        environment: iosEnvironment,
        initializedOptions: initializedOptions,
      );
      _crashlyticsEnabled = false;
      debugPrint(
        'Firebase initialization failed for the declared iOS environment.',
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
    _crashlyticsEnabled = false;
    debugPrint('Firebase initialization skipped: $error');
  }
  return iosEnvironment;
}

void _logFirebaseStartupFailure({
  required _FirebaseStartupStage stage,
  required Object error,
  required StackTrace stackTrace,
  required FirebaseEnvironment? environment,
  required FirebaseOptions? initializedOptions,
}) {
  const marker = '[FirebaseStartup]';

  debugPrint('$marker status=failed');
  debugPrint('$marker stage=${stage.label}');
  debugPrint('$marker error_type=${error.runtimeType}');
  debugPrint('$marker error_message=$error');
  debugPrint('$marker firebase_env=${_configuredFirebaseEnvironmentForLog()}');
  debugPrint(
    '$marker expected_environment=${environment?.name ?? '<unresolved>'}',
  );
  debugPrint(
    '$marker expected_project_id=${environment?.projectId ?? '<unavailable>'}',
  );
  debugPrint(
    '$marker expected_app_id=${environment?.appId ?? '<unavailable>'}',
  );
  if (initializedOptions != null) {
    debugPrint('$marker received_project_id=${initializedOptions.projectId}');
    debugPrint('$marker received_app_id=${initializedOptions.appId}');
  }
  for (final line in stackTrace.toString().split('\n')) {
    if (line.isNotEmpty) debugPrint('$marker stack_trace=$line');
  }
}

void _logFirebaseStartupSuccess(FirebaseEnvironment environment) {
  const marker = '[FirebaseStartup]';
  final resolutionSource = FirebaseEnvironment.configuredValue.isEmpty
      ? 'firebase_options'
      : 'dart_define';
  debugPrint(
    '$marker status=initialized '
    'configured_env=${_configuredFirebaseEnvironmentForLog()} '
    'resolved_environment=${environment.name} '
    'resolution_source=$resolutionSource',
  );
}

String _configuredFirebaseEnvironmentForLog() {
  return switch (FirebaseEnvironment.configuredValue) {
    'staging' || 'production' => FirebaseEnvironment.configuredValue,
    '' => '<empty>',
    _ => '<unsupported>',
  };
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
