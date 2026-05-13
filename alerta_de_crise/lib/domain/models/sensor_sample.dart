final class SensorSample {
  const SensorSample({
    required this.id,
    required this.timestamp,
    required this.heartRate,
    required this.hrv,
    required this.motionState,
  });

  final String id;
  final DateTime timestamp;
  final int heartRate;
  final int hrv;
  final String motionState;
}
