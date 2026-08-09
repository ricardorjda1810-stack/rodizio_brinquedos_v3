import 'package:firebase_core/firebase_core.dart';

enum FirebaseEnvironment {
  staging(
    projectId: 'rodizio-de-brinquedos-staging',
    appId: '1:346014753075:ios:a014794eac1aa24cf51e46',
  ),
  production(
    projectId: 'rodizio-de-brinquedos',
    appId: '1:713670498412:ios:a73ec27898054ea1f2e049',
  );

  const FirebaseEnvironment({
    required this.projectId,
    required this.appId,
  });

  final String projectId;
  final String appId;

  static FirebaseEnvironment fromBuildConfiguration() {
    const configuredValue = String.fromEnvironment('FIREBASE_ENV');
    return switch (configuredValue) {
      'staging' => FirebaseEnvironment.staging,
      'production' => FirebaseEnvironment.production,
      _ => throw StateError(
          'FIREBASE_ENV must be explicitly set to staging or production.',
        ),
    };
  }

  void validate(FirebaseOptions options) {
    if (options.projectId != projectId || options.appId != appId) {
      throw StateError(
        'Firebase configuration does not match the declared '
        'FIREBASE_ENV=$name.',
      );
    }
  }
}
