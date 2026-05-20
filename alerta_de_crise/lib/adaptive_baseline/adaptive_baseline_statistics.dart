import 'dart:math';

import '../core/crisis_detection/physiological_sample.dart';
import 'circadian_profile.dart';
import 'circadian_window.dart';

class AdaptiveBaselineStatistics {
  final double stabilityScore;
  final double heartRateTrend;
  final double heartRateStandardDeviation;

  const AdaptiveBaselineStatistics({
    required this.stabilityScore,
    required this.heartRateTrend,
    required this.heartRateStandardDeviation,
  });

  factory AdaptiveBaselineStatistics.fromSamples(
    List<PhysiologicalSample> samples,
  ) {
    if (samples.length < 2) {
      return const AdaptiveBaselineStatistics(
        stabilityScore: 100,
        heartRateTrend: 0,
        heartRateStandardDeviation: 0,
      );
    }

    final heartRates = samples.map((sample) => sample.heartRateBpm).toList();
    final average = _average(heartRates);
    final standardDeviation = _standardDeviation(heartRates, average);
    final midpoint = heartRates.length ~/ 2;
    final firstHalf = heartRates.take(midpoint).toList();
    final secondHalf = heartRates.skip(midpoint).toList();
    final trend = _average(secondHalf) - _average(firstHalf);
    final stability = (100 - standardDeviation).clamp(0, 100).toDouble();

    return AdaptiveBaselineStatistics(
      stabilityScore: stability,
      heartRateTrend: trend,
      heartRateStandardDeviation: standardDeviation,
    );
  }

  static Map<CircadianWindow, List<PhysiologicalSample>> groupByWindow(
    List<PhysiologicalSample> samples,
  ) {
    final grouped = {
      for (final window in CircadianWindow.defaults)
        window: <PhysiologicalSample>[],
    };

    for (final sample in samples) {
      grouped[CircadianWindow.forTimestamp(sample.timestamp)]!.add(sample);
    }

    return grouped;
  }

  static CircadianProfile? buildProfileForWindow(
    CircadianWindow window,
    List<PhysiologicalSample> samples, {
    DateTime? updatedAt,
  }) {
    if (samples.isEmpty) {
      return null;
    }

    final hrvValues = samples
        .map((sample) => sample.hrvRmssdMs)
        .whereType<double>()
        .toList();
    final respiratoryRates = samples
        .map((sample) => sample.respiratoryRate)
        .whereType<double>()
        .toList();

    return CircadianProfile(
      window: window,
      averageHeartRate: _average(
        samples.map((sample) => sample.heartRateBpm).toList(),
      ),
      averageHrv: hrvValues.isEmpty ? null : _average(hrvValues),
      averageRespiratoryRate: respiratoryRates.isEmpty
          ? null
          : _average(respiratoryRates),
      sampleCount: samples.length,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  static double _average(List<double> values) {
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double _standardDeviation(List<double> values, double average) {
    final variance =
        values.map((value) => pow(value - average, 2)).reduce((a, b) => a + b) /
        values.length;
    return sqrt(variance);
  }
}
