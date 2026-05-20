import 'dart:math';

import 'sensor_quality_models.dart';

class RrArtifactDetector {
  const RrArtifactDetector();

  RrArtifactReport detect({
    required List<double> rrIntervalsMs,
    required double heartRateBpm,
  }) {
    final warnings = <String>[];
    final invalidIntervalCount = rrIntervalsMs
        .where((rr) => rr < 250 || rr > 2500)
        .length;

    if (invalidIntervalCount > 0) {
      warnings.add('rr_interval_out_of_range');
    }

    final hasInvalidHeartRate = heartRateBpm < 25 || heartRateBpm > 240;
    if (hasInvalidHeartRate) {
      warnings.add('heart_rate_out_of_range');
    }

    final abruptChangeCount = _countAbruptChanges(rrIntervalsMs);
    if (abruptChangeCount > 0) {
      warnings.add('abrupt_rr_change');
    }

    final hasExtremeJitter = _hasExtremeJitter(rrIntervalsMs);
    if (hasExtremeJitter) {
      warnings.add('extreme_rr_jitter');
    }

    return RrArtifactReport(
      totalIntervals: rrIntervalsMs.length,
      invalidIntervalCount: invalidIntervalCount,
      abruptChangeCount: abruptChangeCount,
      hasInvalidHeartRate: hasInvalidHeartRate,
      hasExtremeJitter: hasExtremeJitter,
      warnings: List.unmodifiable(warnings),
    );
  }

  int _countAbruptChanges(List<double> rrIntervalsMs) {
    if (rrIntervalsMs.length < 2) {
      return 0;
    }

    var count = 0;
    for (var i = 1; i < rrIntervalsMs.length; i += 1) {
      final previous = rrIntervalsMs[i - 1];
      final current = rrIntervalsMs[i];
      if (previous <= 0 || current <= 0) {
        continue;
      }

      final absoluteDelta = (current - previous).abs();
      final relativeDelta = absoluteDelta / previous;
      if (absoluteDelta > 350 || relativeDelta > 0.35) {
        count += 1;
      }
    }

    return count;
  }

  bool _hasExtremeJitter(List<double> rrIntervalsMs) {
    if (rrIntervalsMs.length < 3) {
      return false;
    }

    final valid = rrIntervalsMs.where((rr) => rr >= 250 && rr <= 2500).toList();
    if (valid.length < 3) {
      return false;
    }

    return valid.reduce(max) - valid.reduce(min) > 600;
  }
}
