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
    required this.averageMotionRmsMg,
    required this.predominantMotionState,
    required this.sourceLabel,
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
  final double? averageMotionRmsMg;
  final String predominantMotionState;
  final String sourceLabel;

  bool get isContaminatedByMovement {
    if (stepLabel != 'Repouso') {
      return false;
    }

    final motion = predominantMotionState.toLowerCase();
    return motion.contains('moderado') ||
        motion.contains('alto') ||
        (averageMotionRmsMg ?? 0) >= 180;
  }

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
    final motionValues = sortedSamples
        .map((sample) => sample.motionRmsMg)
        .whereType<double>()
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
      averageMotionRmsMg: motionValues.isEmpty
          ? null
          : _averageDouble(motionValues),
      predominantMotionState: _predominantMotionState(sortedSamples),
      sourceLabel: _predominantSourceLabel(sortedSamples),
    );
  }

  static bool _hasAvailableHrv(SessionSample sample) {
    return sample.motionState != 'healthkit-hrv-indisponivel' && sample.hrv > 0;
  }

  static double _average(List<int> values) {
    return values.fold<int>(0, (sum, value) => sum + value) / values.length;
  }

  static double _averageDouble(List<double> values) {
    return values.fold<double>(0, (sum, value) => sum + value) / values.length;
  }

  static String _predominantMotionState(List<SessionSample> samples) {
    return _mostCommon(
      samples
          .map((sample) => sample.motionState)
          .where((value) => value.trim().isNotEmpty),
      fallback: 'indisponível',
    );
  }

  static String _predominantSourceLabel(List<SessionSample> samples) {
    return _mostCommon(
      samples
          .map((sample) => sample.sourceLabel)
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty),
      fallback: 'fonte não registrada',
    );
  }

  static String _mostCommon(
    Iterable<String> values, {
    required String fallback,
  }) {
    final counts = <String, int>{};
    for (final value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }

    if (counts.isEmpty) {
      return fallback;
    }

    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static int _min(int a, int b) => a < b ? a : b;

  static int _max(int a, int b) => a > b ? a : b;
}
