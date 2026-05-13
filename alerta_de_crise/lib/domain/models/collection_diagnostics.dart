import 'session_sample.dart';

final class CollectionDiagnostics {
  const CollectionDiagnostics({
    required this.totalSamples,
    required this.heartRateSamples,
    required this.hrvSamples,
    required this.missingHeartRateCount,
    required this.missingHrvCount,
    required this.duplicateSamplesSkipped,
    required this.firstSampleAt,
    required this.lastSampleAt,
    required this.averageIntervalSeconds,
    required this.minIntervalSeconds,
    required this.maxIntervalSeconds,
    required this.sourceLabel,
  });

  factory CollectionDiagnostics.empty({required String sourceLabel}) {
    return CollectionDiagnostics(
      totalSamples: 0,
      heartRateSamples: 0,
      hrvSamples: 0,
      missingHeartRateCount: 0,
      missingHrvCount: 0,
      duplicateSamplesSkipped: 0,
      firstSampleAt: null,
      lastSampleAt: null,
      averageIntervalSeconds: 0,
      minIntervalSeconds: 0,
      maxIntervalSeconds: 0,
      sourceLabel: sourceLabel,
    );
  }

  final int totalSamples;
  final int heartRateSamples;
  final int hrvSamples;
  final int missingHeartRateCount;
  final int missingHrvCount;
  final int duplicateSamplesSkipped;
  final DateTime? firstSampleAt;
  final DateTime? lastSampleAt;
  final double averageIntervalSeconds;
  final double minIntervalSeconds;
  final double maxIntervalSeconds;
  final String sourceLabel;

  CollectionDiagnostics addSample(SessionSample sample) {
    final hasHeartRate = sample.heartRate > 0;
    final hasHrv =
        sample.hrv > 0 && sample.motionState != 'healthkit-hrv-indisponivel';
    final intervalSeconds = lastSampleAt == null
        ? 0.0
        : sample.timestamp.difference(lastSampleAt!).inMilliseconds / 1000;
    final intervalCount = totalSamples - 1;
    final nextIntervalCount = totalSamples;
    final nextAverage = nextIntervalCount == 0
        ? 0.0
        : ((averageIntervalSeconds * intervalCount) + intervalSeconds) /
              nextIntervalCount;

    return CollectionDiagnostics(
      totalSamples: totalSamples + 1,
      heartRateSamples: heartRateSamples + (hasHeartRate ? 1 : 0),
      hrvSamples: hrvSamples + (hasHrv ? 1 : 0),
      missingHeartRateCount: missingHeartRateCount + (hasHeartRate ? 0 : 1),
      missingHrvCount: missingHrvCount + (hasHrv ? 0 : 1),
      duplicateSamplesSkipped: duplicateSamplesSkipped,
      firstSampleAt: firstSampleAt ?? sample.timestamp,
      lastSampleAt: sample.timestamp,
      averageIntervalSeconds: nextAverage,
      minIntervalSeconds: totalSamples == 0
          ? 0.0
          : _minPositive(minIntervalSeconds, intervalSeconds),
      maxIntervalSeconds: totalSamples == 0
          ? 0.0
          : _max(maxIntervalSeconds, intervalSeconds),
      sourceLabel: sourceLabel,
    );
  }

  CollectionDiagnostics skipDuplicate() {
    return CollectionDiagnostics(
      totalSamples: totalSamples,
      heartRateSamples: heartRateSamples,
      hrvSamples: hrvSamples,
      missingHeartRateCount: missingHeartRateCount,
      missingHrvCount: missingHrvCount,
      duplicateSamplesSkipped: duplicateSamplesSkipped + 1,
      firstSampleAt: firstSampleAt,
      lastSampleAt: lastSampleAt,
      averageIntervalSeconds: averageIntervalSeconds,
      minIntervalSeconds: minIntervalSeconds,
      maxIntervalSeconds: maxIntervalSeconds,
      sourceLabel: sourceLabel,
    );
  }

  static double _minPositive(double current, double next) {
    if (current <= 0) {
      return next;
    }

    if (next <= 0) {
      return current;
    }

    return next < current ? next : current;
  }

  static double _max(double current, double next) {
    return next > current ? next : current;
  }
}
