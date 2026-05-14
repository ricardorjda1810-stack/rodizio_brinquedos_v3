import 'session_sample.dart';

final class TemporalSampleAnalysis {
  const TemporalSampleAnalysis({
    required this.totalSamples,
    required this.firstSampleAt,
    required this.lastSampleAt,
    required this.durationSeconds,
    required this.intervalsSeconds,
    required this.averageIntervalSeconds,
    required this.medianIntervalSeconds,
    required this.minIntervalSeconds,
    required this.maxIntervalSeconds,
    required this.longGapCount,
    required this.longestGapSeconds,
    required this.samplesPerMinute,
    required this.qualityLabel,
  });

  factory TemporalSampleAnalysis.fromSamples(List<SessionSample> samples) {
    if (samples.isEmpty) {
      return const TemporalSampleAnalysis(
        totalSamples: 0,
        firstSampleAt: null,
        lastSampleAt: null,
        durationSeconds: 0,
        intervalsSeconds: [],
        averageIntervalSeconds: 0,
        medianIntervalSeconds: 0,
        minIntervalSeconds: 0,
        maxIntervalSeconds: 0,
        longGapCount: 0,
        longestGapSeconds: 0,
        samplesPerMinute: 0,
        qualityLabel: 'Sem dados',
      );
    }

    final sortedSamples = List<SessionSample>.of(samples)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final firstSampleAt = sortedSamples.first.timestamp;
    final lastSampleAt = sortedSamples.last.timestamp;
    final durationSeconds =
        lastSampleAt.difference(firstSampleAt).inMilliseconds / 1000;
    final intervals = <double>[];

    for (var index = 1; index < sortedSamples.length; index++) {
      intervals.add(
        sortedSamples[index].timestamp
                .difference(sortedSamples[index - 1].timestamp)
                .inMilliseconds /
            1000,
      );
    }

    final averageInterval = intervals.isEmpty
        ? 0.0
        : intervals.reduce((a, b) => a + b) / intervals.length;
    final sortedIntervals = List<double>.of(intervals)..sort();
    final medianInterval = _median(sortedIntervals);
    final minInterval = sortedIntervals.isEmpty ? 0.0 : sortedIntervals.first;
    final maxInterval = sortedIntervals.isEmpty ? 0.0 : sortedIntervals.last;
    final longGapCount = intervals.where((interval) => interval > 90).length;
    final samplesPerMinute = durationSeconds <= 0
        ? 0.0
        : sortedSamples.length / (durationSeconds / 60);

    return TemporalSampleAnalysis(
      totalSamples: sortedSamples.length,
      firstSampleAt: firstSampleAt,
      lastSampleAt: lastSampleAt,
      durationSeconds: durationSeconds,
      intervalsSeconds: intervals,
      averageIntervalSeconds: averageInterval,
      medianIntervalSeconds: medianInterval,
      minIntervalSeconds: minInterval,
      maxIntervalSeconds: maxInterval,
      longGapCount: longGapCount,
      longestGapSeconds: maxInterval,
      samplesPerMinute: samplesPerMinute,
      qualityLabel: _qualityLabel(sortedSamples.length, averageInterval),
    );
  }

  final int totalSamples;
  final DateTime? firstSampleAt;
  final DateTime? lastSampleAt;
  final double durationSeconds;
  final List<double> intervalsSeconds;
  final double averageIntervalSeconds;
  final double medianIntervalSeconds;
  final double minIntervalSeconds;
  final double maxIntervalSeconds;
  final int longGapCount;
  final double longestGapSeconds;
  final double samplesPerMinute;
  final String qualityLabel;

  static double _median(List<double> sortedValues) {
    if (sortedValues.isEmpty) {
      return 0;
    }

    final middle = sortedValues.length ~/ 2;
    if (sortedValues.length.isOdd) {
      return sortedValues[middle];
    }

    return (sortedValues[middle - 1] + sortedValues[middle]) / 2;
  }

  static String _qualityLabel(int totalSamples, double averageIntervalSeconds) {
    if (totalSamples == 0) {
      return 'Sem dados';
    }

    if (averageIntervalSeconds > 180) {
      return 'Muito esparso';
    }

    if (averageIntervalSeconds > 90) {
      return 'Esparso';
    }

    if (averageIntervalSeconds > 30) {
      return 'Moderado';
    }

    return 'Bom';
  }
}
