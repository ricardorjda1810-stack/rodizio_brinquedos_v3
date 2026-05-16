class BaselineProfile {
  final double restingHeartRateBpm;
  final double hrvRmssdMs;
  final double respiratoryRate;
  final double movementIntensity;

  const BaselineProfile({
    required this.restingHeartRateBpm,
    required this.hrvRmssdMs,
    required this.respiratoryRate,
    required this.movementIntensity,
  });

  factory BaselineProfile.safeDefault() {
    return const BaselineProfile(
      restingHeartRateBpm: 72,
      hrvRmssdMs: 45,
      respiratoryRate: 16,
      movementIntensity: 0.15,
    );
  }
}
