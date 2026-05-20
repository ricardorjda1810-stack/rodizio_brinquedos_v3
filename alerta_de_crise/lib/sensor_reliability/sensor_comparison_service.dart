import 'dart:math';

import 'sensor_divergence_detector.dart';
import 'sensor_reliability_models.dart';

class SensorComparisonService {
  final SensorDivergenceDetector _divergenceDetector;
  final DateTime Function() _now;

  const SensorComparisonService({
    SensorDivergenceDetector divergenceDetector =
        const SensorDivergenceDetector(),
    DateTime Function()? now,
  }) : _divergenceDetector = divergenceDetector,
       _now = now ?? DateTime.now;

  SensorComparisonResult compareSensors({
    required String primarySensor,
    required String referenceSensor,
    required List<SensorReading> primaryReadings,
    required List<SensorReading> referenceReadings,
  }) {
    final averageDriftMs = _divergenceDetector.averageTimingDriftMs(
      primaryReadings: primaryReadings,
      referenceReadings: referenceReadings,
    );
    final divergenceCount = _divergenceDetector.divergenceCount(
      primaryReadings: primaryReadings,
      referenceReadings: referenceReadings,
    );
    return SensorComparisonResult(
      primarySensor: primarySensor,
      referenceSensor: referenceSensor,
      heartRateAgreement: compareHeartRate(primaryReadings, referenceReadings),
      hrvAgreement: compareHrv(primaryReadings, referenceReadings),
      timingAgreement: compareTiming(primaryReadings, referenceReadings),
      divergenceCount: divergenceCount,
      averageDriftMs: averageDriftMs,
      confidenceDelta: _confidenceDelta(primaryReadings, referenceReadings),
      generatedAt: _now(),
    );
  }

  double compareHeartRate(
    List<SensorReading> primaryReadings,
    List<SensorReading> referenceReadings,
  ) {
    return _agreement(
      primaryReadings.map((reading) => reading.heartRate).toList(),
      referenceReadings.map((reading) => reading.heartRate).toList(),
    );
  }

  double compareHrv(
    List<SensorReading> primaryReadings,
    List<SensorReading> referenceReadings,
  ) {
    return _agreement(
      primaryReadings.map((reading) => reading.hrv).toList(),
      referenceReadings.map((reading) => reading.hrv).toList(),
    );
  }

  double compareTiming(
    List<SensorReading> primaryReadings,
    List<SensorReading> referenceReadings,
  ) {
    final drift = _divergenceDetector.averageTimingDriftMs(
      primaryReadings: primaryReadings,
      referenceReadings: referenceReadings,
    );
    return (100 - (drift / 25).clamp(0, 100)).toDouble();
  }

  double _confidenceDelta(
    List<SensorReading> primaryReadings,
    List<SensorReading> referenceReadings,
  ) {
    return (_average(primaryReadings.map((reading) => reading.confidence)) -
            _average(referenceReadings.map((reading) => reading.confidence)))
        .abs();
  }

  double _agreement(List<double> primary, List<double> reference) {
    if (primary.isEmpty && reference.isEmpty) return 100;
    if (primary.isEmpty || reference.isEmpty) return 0;
    final count = min(primary.length, reference.length);
    var totalDelta = 0.0;
    for (var index = 0; index < count; index += 1) {
      totalDelta += (primary[index] - reference[index]).abs();
    }
    final averageDelta = totalDelta / count;
    return (100 - averageDelta.clamp(0, 100)).toDouble();
  }

  double _average(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    return list.fold<double>(0, (sum, value) => sum + value) / list.length;
  }
}
