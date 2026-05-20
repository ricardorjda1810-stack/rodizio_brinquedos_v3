import 'dart:math';

import 'sensor_reliability_models.dart';

class SensorDivergenceDetector {
  const SensorDivergenceDetector();

  List<String> detectDivergences({
    required List<SensorReading> primaryReadings,
    required List<SensorReading> referenceReadings,
    double heartRateThreshold = 8,
    double hrvThreshold = 12,
    int timingThresholdMs = 1500,
    double confidenceThreshold = 20,
  }) {
    final count = min(primaryReadings.length, referenceReadings.length);
    final factors = <String>[];
    for (var index = 0; index < count; index += 1) {
      final primary = primaryReadings[index];
      final reference = referenceReadings[index];
      if ((primary.heartRate - reference.heartRate).abs() >
          heartRateThreshold) {
        factors.add('divergência HR na comparação de sinais.');
      }
      if ((primary.hrv - reference.hrv).abs() > hrvThreshold) {
        factors.add('divergência HRV na comparação de sinais.');
      }
      if (_driftMs(primary.timestamp, reference.timestamp) >
          timingThresholdMs) {
        factors.add('drift temporal entre sensores.');
      }
      if ((primary.confidence - reference.confidence).abs() >
          confidenceThreshold) {
        factors.add('confidence mismatch entre sensores.');
      }
      if (primary.missingData || reference.missingData) {
        factors.add('perda de sinal observada.');
      }
    }
    return List.unmodifiable(factors.toSet());
  }

  int divergenceCount({
    required List<SensorReading> primaryReadings,
    required List<SensorReading> referenceReadings,
  }) {
    return detectDivergences(
      primaryReadings: primaryReadings,
      referenceReadings: referenceReadings,
    ).length;
  }

  double averageTimingDriftMs({
    required List<SensorReading> primaryReadings,
    required List<SensorReading> referenceReadings,
  }) {
    final count = min(primaryReadings.length, referenceReadings.length);
    if (count == 0) return 0;
    var total = 0.0;
    for (var index = 0; index < count; index += 1) {
      total += _driftMs(
        primaryReadings[index].timestamp,
        referenceReadings[index].timestamp,
      );
    }
    return total / count;
  }

  double _driftMs(DateTime a, DateTime b) {
    return a.difference(b).inMilliseconds.abs().toDouble();
  }
}
