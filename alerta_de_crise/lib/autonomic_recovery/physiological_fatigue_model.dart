import '../core/crisis_detection/physiological_sample.dart';

class PhysiologicalFatigueModel {
  const PhysiologicalFatigueModel();

  double stressCarryover({
    required double activationDensity,
    required bool incompleteRecovery,
    required double previousCarryover,
  }) {
    var carryover = previousCarryover + (activationDensity * 0.35);
    if (incompleteRecovery) {
      carryover += 0.30;
    } else {
      carryover -= 0.20;
    }
    return carryover.clamp(0, 1);
  }

  bool hasIncompleteRecovery({
    required List<PhysiologicalSample> samples,
    required double baselineHeartRate,
    required double baselineHrv,
  }) {
    if (samples.isEmpty) {
      return true;
    }
    final latest = [...samples]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final last = latest.last;
    final hrv = last.hrvRmssdMs;
    final heartRateStillElevated = last.heartRateBpm > baselineHeartRate + 8;
    final hrvStillSuppressed = hrv != null && hrv < baselineHrv * 0.80;
    return heartRateStillElevated || hrvStillSuppressed;
  }

  int fatigueScore({
    required double stressCarryover,
    required double activationDensity,
    required bool incompleteRecovery,
  }) {
    var score = (stressCarryover * 55).round();
    score += (activationDensity * 30).round();
    if (incompleteRecovery) {
      score += 15;
    }
    return score.clamp(0, 100);
  }
}
