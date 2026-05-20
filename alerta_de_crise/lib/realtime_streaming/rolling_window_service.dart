import '../core/crisis_detection/baseline_profile.dart';
import '../core/crisis_detection/crisis_risk_engine.dart';
import '../core/crisis_detection/physiological_sample.dart';
import 'realtime_stream_models.dart';

class RollingWindowService {
  final CrisisRiskEngine _riskEngine;

  const RollingWindowService({
    CrisisRiskEngine riskEngine = const CrisisRiskEngine(),
  }) : _riskEngine = riskEngine;

  RollingWindow generateRollingWindow({
    required List<PhysiologicalSample> samples,
    required Duration duration,
    DateTime? now,
  }) {
    final generatedAt = now ?? DateTime.now();
    final start = generatedAt.subtract(duration);
    final windowSamples = samples
        .where((sample) => !sample.timestamp.isBefore(start))
        .toList(growable: false);
    return RollingWindow(
      duration: duration,
      samples: List.unmodifiable(windowSamples),
      generatedAt: generatedAt,
    );
  }

  RollingMetrics calculateRollingMetrics({
    required RollingWindow window,
    BaselineProfile? baseline,
  }) {
    final samples = window.samples;
    final hrvSamples = samples
        .map((sample) => sample.hrvRmssdMs)
        .whereType<double>()
        .toList();
    final confidence = _rollingConfidence(samples);
    final escalationDensity = baseline == null
        ? _activationDensity(samples)
        : _escalationDensity(samples: samples, baseline: baseline);
    return RollingMetrics(
      averageHeartRate: _average(
        samples.map((sample) => sample.heartRateBpm).toList(),
      ),
      averageHrv: _average(hrvSamples),
      confidence: confidence,
      escalationDensity: escalationDensity,
      sampleCount: samples.length,
    );
  }

  List<PhysiologicalSample> trimOldSamples({
    required List<PhysiologicalSample> samples,
    required Duration maxAge,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final start = reference.subtract(maxAge);
    return List.unmodifiable(
      samples.where((sample) => !sample.timestamp.isBefore(start)),
    );
  }

  double _rollingConfidence(List<PhysiologicalSample> samples) {
    if (samples.isEmpty) {
      return 0;
    }
    final hrvRatio =
        samples.where((sample) => sample.hrvRmssdMs != null).length /
        samples.length;
    final movementPenalty = _average(
      samples.map((sample) => sample.movementIntensity).toList(),
    );
    return ((hrvRatio * 70) + 30 - (movementPenalty * 25))
        .clamp(0, 100)
        .toDouble();
  }

  double _activationDensity(List<PhysiologicalSample> samples) {
    if (samples.isEmpty) {
      return 0;
    }
    final averageHr = _average(
      samples.map((sample) => sample.heartRateBpm).toList(),
    );
    final activeCount = samples
        .where(
          (sample) =>
              sample.heartRateBpm >= averageHr + 8 &&
              sample.movementIntensity <= 0.35,
        )
        .length;
    return (activeCount / samples.length * 100).clamp(0, 100).toDouble();
  }

  double _escalationDensity({
    required List<PhysiologicalSample> samples,
    required BaselineProfile baseline,
  }) {
    if (samples.isEmpty) {
      return 0;
    }
    final elevated = samples.where((sample) {
      final risk = _riskEngine.evaluate(sample: sample, baseline: baseline);
      return risk.score >= 30;
    }).length;
    return (elevated / samples.length * 100).clamp(0, 100).toDouble();
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }
}
