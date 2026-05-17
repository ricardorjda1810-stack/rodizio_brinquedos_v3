class PolarH10RrSample {
  final DateTime timestamp;
  final double rrIntervalMs;
  final double heartRate;
  final bool contactDetected;

  const PolarH10RrSample({
    required this.timestamp,
    required this.rrIntervalMs,
    required this.heartRate,
    required this.contactDetected,
  });

  bool get isValid {
    return rrIntervalMs >= 250 && rrIntervalMs <= 2500 && heartRate > 0;
  }
}
