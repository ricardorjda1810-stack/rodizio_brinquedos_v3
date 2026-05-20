import 'session_sample.dart';

final class PhaseAnalysis {
  const PhaseAnalysis({
    required this.stepLabel,
    required this.sampleCount,
    required this.averageHeartRate,
    required this.minHeartRate,
    required this.maxHeartRate,
    required this.averageHrv,
    required this.minHrv,
    required this.maxHrv,
    required this.firstTimestamp,
    required this.lastTimestamp,
    required this.durationSeconds,
  });

  final String stepLabel;
  final int sampleCount;
  final double averageHeartRate;
  final int minHeartRate;
  final int maxHeartRate;
  final double? averageHrv;
  final int? minHrv;
  final int? maxHrv;
  final DateTime firstTimestamp;
  final DateTime lastTimestamp;
  final double durationSeconds;

  factory PhaseAnalysis.fromSamples({
    required String stepLabel,
    required List<SessionSample> samples,
  }) {
    assert(samples.isNotEmpty, 'PhaseAnalysis requires at least one sample.');

    final sortedSamples = List<SessionSample>.of(samples)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final heartRates = sortedSamples.map((sample) => sample.heartRate).toList();
    final hrvValues = sortedSamples
        .where(_hasAvailableHrv)
        .map((sample) => sample.hrv)
        .toList();
    final firstTimestamp = sortedSamples.first.timestamp;
    final lastTimestamp = sortedSamples.last.timestamp;

    return PhaseAnalysis(
      stepLabel: stepLabel,
      sampleCount: sortedSamples.length,
      averageHeartRate: _average(heartRates),
      minHeartRate: heartRates.reduce(_min),
      maxHeartRate: heartRates.reduce(_max),
      averageHrv: hrvValues.isEmpty ? null : _average(hrvValues),
      minHrv: hrvValues.isEmpty ? null : hrvValues.reduce(_min),
      maxHrv: hrvValues.isEmpty ? null : hrvValues.reduce(_max),
      firstTimestamp: firstTimestamp,
      lastTimestamp: lastTimestamp,
      durationSeconds: lastTimestamp
          .difference(firstTimestamp)
          .inSeconds
          .toDouble(),
    );
  }

  static bool _hasAvailableHrv(SessionSample sample) {
    return sample.motionState != 'healthkit-hrv-indisponivel' && sample.hrv > 0;
  }

  static double _average(List<int> values) {
    return values.fold<int>(0, (sum, value) => sum + value) / values.length;
  }

  static int _min(int a, int b) => a < b ? a : b;

  static int _max(int a, int b) => a > b ? a : b;
}
