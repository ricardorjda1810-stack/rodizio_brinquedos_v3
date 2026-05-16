import 'baseline_profile.dart';

class BaselineSessionResult {
  final BaselineProfile baseline;
  final int sampleCount;
  final DateTime createdAt;
  final bool usedFallbackDefaults;

  const BaselineSessionResult({
    required this.baseline,
    required this.sampleCount,
    required this.createdAt,
    required this.usedFallbackDefaults,
  });
}
