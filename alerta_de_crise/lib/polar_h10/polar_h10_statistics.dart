import 'dart:math';

import 'polar_h10_rr_sample.dart';

class PolarH10Statistics {
  final int sampleCount;
  final double? averageRrMs;
  final double? sdnnMs;
  final double? rmssdMs;
  final double? minHeartRate;
  final double? maxHeartRate;

  const PolarH10Statistics({
    required this.sampleCount,
    required this.averageRrMs,
    required this.sdnnMs,
    required this.rmssdMs,
    required this.minHeartRate,
    required this.maxHeartRate,
  });

  factory PolarH10Statistics.fromSamples(List<PolarH10RrSample> samples) {
    final validSamples = samples.where((sample) => sample.isValid).toList();
    if (validSamples.isEmpty) {
      return const PolarH10Statistics(
        sampleCount: 0,
        averageRrMs: null,
        sdnnMs: null,
        rmssdMs: null,
        minHeartRate: null,
        maxHeartRate: null,
      );
    }

    final rrValues = validSamples.map((sample) => sample.rrIntervalMs).toList();
    final heartRates = validSamples.map((sample) => sample.heartRate).toList();
    final averageRr = _average(rrValues);

    return PolarH10Statistics(
      sampleCount: validSamples.length,
      averageRrMs: averageRr,
      sdnnMs: _standardDeviation(rrValues, averageRr),
      rmssdMs: _rmssd(rrValues),
      minHeartRate: heartRates.reduce(min),
      maxHeartRate: heartRates.reduce(max),
    );
  }

  static double _average(List<double> values) {
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double _standardDeviation(List<double> values, double average) {
    if (values.length < 2) {
      return 0;
    }

    final variance =
        values
            .map((value) => pow(value - average, 2).toDouble())
            .reduce((a, b) => a + b) /
        values.length;
    return sqrt(variance);
  }

  static double _rmssd(List<double> rrValues) {
    if (rrValues.length < 2) {
      return 0;
    }

    final squaredDiffs = <double>[];
    for (var i = 1; i < rrValues.length; i += 1) {
      squaredDiffs.add(pow(rrValues[i] - rrValues[i - 1], 2).toDouble());
    }

    return sqrt(_average(squaredDiffs));
  }
}
