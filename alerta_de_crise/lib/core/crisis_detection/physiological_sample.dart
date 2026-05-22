class PhysiologicalSample {
  final DateTime timestamp;
  final double heartRateBpm;
  final double? hrvRmssdMs;
  final double? hrvSdnnMs;
  final double? spo2Percent;
  final double movementIntensity;
  final double? respiratoryRate;
  final double signalQuality;
  final bool probableSleep;

  const PhysiologicalSample({
    required this.timestamp,
    required this.heartRateBpm,
    required this.movementIntensity,
    this.hrvRmssdMs,
    this.hrvSdnnMs,
    this.spo2Percent,
    this.respiratoryRate,
    this.signalQuality = 1,
    this.probableSleep = false,
  });
}
