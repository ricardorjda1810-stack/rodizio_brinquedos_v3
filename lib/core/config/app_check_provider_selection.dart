import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:rodizio_brinquedos_v3/core/config/firebase_environment.dart';

enum AppCheckRuntimePlatform {
  android,
  ios,
  unsupported,
}

enum AppCheckBuildMode {
  debug,
  profile,
  release,
}

enum AppCheckProviderKind {
  androidDebug,
  androidPlayIntegrity,
  appleDebug,
  appleAppAttest,
  appleAppAttestWithDeviceCheckFallback,
}

class FirebaseAppCheckProviderSelection {
  const FirebaseAppCheckProviderSelection({
    required this.kind,
    required this.android,
    required this.apple,
  });

  final AppCheckProviderKind kind;
  final AndroidAppCheckProvider android;
  final AppleAppCheckProvider apple;
}

FirebaseAppCheckProviderSelection? selectFirebaseAppCheckProviders({
  required AppCheckRuntimePlatform platform,
  required AppCheckBuildMode buildMode,
  FirebaseEnvironment? iosEnvironment,
}) {
  switch (platform) {
    case AppCheckRuntimePlatform.android:
      if (buildMode == AppCheckBuildMode.debug) {
        return const FirebaseAppCheckProviderSelection(
          kind: AppCheckProviderKind.androidDebug,
          android: AndroidDebugProvider(),
          apple: AppleDebugProvider(),
        );
      }
      return const FirebaseAppCheckProviderSelection(
        kind: AppCheckProviderKind.androidPlayIntegrity,
        android: AndroidPlayIntegrityProvider(),
        apple: AppleDebugProvider(),
      );
    case AppCheckRuntimePlatform.ios:
      if (buildMode == AppCheckBuildMode.debug) {
        return const FirebaseAppCheckProviderSelection(
          kind: AppCheckProviderKind.appleDebug,
          android: AndroidDebugProvider(),
          apple: AppleDebugProvider(),
        );
      }
      return switch (iosEnvironment) {
        FirebaseEnvironment.staging => const FirebaseAppCheckProviderSelection(
            kind: AppCheckProviderKind.appleAppAttest,
            android: AndroidPlayIntegrityProvider(),
            apple: AppleAppAttestProvider(),
          ),
        FirebaseEnvironment.production =>
          const FirebaseAppCheckProviderSelection(
            kind: AppCheckProviderKind.appleAppAttestWithDeviceCheckFallback,
            android: AndroidPlayIntegrityProvider(),
            apple: AppleAppAttestWithDeviceCheckFallbackProvider(),
          ),
        null => throw StateError(
            'The iOS Firebase environment must be configured outside debug.',
          ),
      };
    case AppCheckRuntimePlatform.unsupported:
      return null;
  }
}
