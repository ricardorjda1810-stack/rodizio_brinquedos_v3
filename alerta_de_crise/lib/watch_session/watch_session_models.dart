import '../core/crisis_detection/physiological_sample.dart';

class WatchSessionSample {
  final DateTime timestamp;
  final double heartRateBpm;
  final double? hrvRmssdMs;
  final String source;

  const WatchSessionSample({
    required this.timestamp,
    required this.heartRateBpm,
    this.hrvRmssdMs,
    this.source = 'appleWatch',
  });

  factory WatchSessionSample.fromPhysiologicalSample(
    PhysiologicalSample sample, {
    String source = 'simulatedWatch',
  }) {
    return WatchSessionSample(
      timestamp: sample.timestamp,
      heartRateBpm: sample.heartRateBpm,
      hrvRmssdMs: sample.hrvRmssdMs,
      source: source,
    );
  }

  PhysiologicalSample toPhysiologicalSample() {
    return PhysiologicalSample(
      timestamp: timestamp,
      heartRateBpm: heartRateBpm,
      hrvRmssdMs: hrvRmssdMs,
      movementIntensity: 0,
    );
  }
}
