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

  const FirebaseEnvironment({required this.projectId, required this.appId});

  final String projectId;
  final String appId;

  static const String configuredValue = String.fromEnvironment('FIREBASE_ENV');

  static FirebaseEnvironment resolveIos({
    required String configuredValue,
    required FirebaseOptions options,
  }) {
    return switch (configuredValue) {
      'staging' => _validated(FirebaseEnvironment.staging, options),
      'production' => _validated(FirebaseEnvironment.production, options),
      '' => _fromOptions(options),
      _ => throw StateError(
          'FIREBASE_ENV must be empty, staging, or production.',
        ),
    };
  }

  void validate(FirebaseOptions options) {
    if (!_matches(options)) {
      throw StateError(
        'Firebase configuration does not match the declared '
        'FIREBASE_ENV=$name.',
      );
    }
  }

  bool _matches(FirebaseOptions options) {
    return options.projectId == projectId && options.appId == appId;
  }

  static FirebaseEnvironment _validated(
    FirebaseEnvironment environment,
    FirebaseOptions options,
  ) {
    environment.validate(options);
    return environment;
  }

  static FirebaseEnvironment _fromOptions(FirebaseOptions options) {
    final matches = FirebaseEnvironment.values
        .where((environment) => environment._matches(options))
        .toList(growable: false);
    if (matches.length == 1) return matches.single;
    throw StateError('Firebase options do not match a known iOS environment.');
  }
}
