import '../core/crisis_detection/baseline_profile.dart';
import 'circadian_profile.dart';

class AdaptiveBaselineProfile {
  final BaselineProfile globalBaseline;
  final List<CircadianProfile> circadianProfiles;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalSamples;

  const AdaptiveBaselineProfile({
    required this.globalBaseline,
    required this.circadianProfiles,
    required this.createdAt,
    required this.updatedAt,
    required this.totalSamples,
  });
}
