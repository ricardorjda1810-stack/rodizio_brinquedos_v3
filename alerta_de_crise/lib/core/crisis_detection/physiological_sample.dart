class PhysiologicalSample {
  final DateTime timestamp;
  final double heartRateBpm;
  final double? hrvRmssdMs;
  final double? spo2Percent;
  final double movementIntensity;
  final double? respiratoryRate;

  const PhysiologicalSample({
    required this.timestamp,
    required this.heartRateBpm,
    required this.movementIntensity,
    this.hrvRmssdMs,
    this.spo2Percent,
    this.respiratoryRate,
  });
}
