import 'baseline_profile.dart';
import 'physiological_sample.dart';

class BaselineBuilder {
  const BaselineBuilder();

  BaselineProfile build(List<PhysiologicalSample> samples) {
    final validSamples = samples.where(_isValidSample).toList();
    final fallback = BaselineProfile.safeDefault();

    if (validSamples.length < 5) {
      return fallback;
    }

    final restingSamples = validSamples
        .where((sample) => sample.movementIntensity <= 0.35)
        .toList();
    final heartRateSamples = restingSamples.length >= 5
        ? restingSamples
        : validSamples;
    final heartRates = heartRateSamples
        .map((sample) => sample.heartRateBpm)
        .toList(growable: false);
    final hrvValues = validSamples
        .map((sample) => sample.hrvRmssdMs)
        .whereType<double>()
        .toList(growable: false);
    final respiratoryRates = validSamples
        .map((sample) => sample.respiratoryRate)
        .whereType<double>()
        .toList(growable: false);
    final movementIntensities = validSamples
        .map((sample) => sample.movementIntensity)
        .toList(growable: false);

    return BaselineProfile(
      restingHeartRateBpm: _median(heartRates),
      hrvRmssdMs: hrvValues.isEmpty ? fallback.hrvRmssdMs : _median(hrvValues),
      respiratoryRate: respiratoryRates.isEmpty
          ? fallback.respiratoryRate
          : _median(respiratoryRates),
      movementIntensity: _median(movementIntensities),
    );
  }

  bool _isValidSample(PhysiologicalSample sample) {
    final hrv = sample.hrvRmssdMs;
    final respiratoryRate = sample.respiratoryRate;

    return sample.heartRateBpm >= 35 &&
        sample.heartRateBpm <= 220 &&
        sample.movementIntensity >= 0 &&
        sample.movementIntensity <= 1 &&
        (hrv == null || hrv > 0 && hrv < 250) &&
        (respiratoryRate == null ||
            respiratoryRate >= 6 && respiratoryRate <= 40);
  }

  double _median(List<double> values) {
    final sortedValues = [...values]..sort();
    final middle = sortedValues.length ~/ 2;

    if (sortedValues.length.isOdd) {
      return sortedValues[middle];
    }

    return (sortedValues[middle - 1] + sortedValues[middle]) / 2;
  }
}
