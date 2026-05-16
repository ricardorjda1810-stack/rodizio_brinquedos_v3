import 'baseline_builder.dart';
import 'baseline_profile.dart';
import 'baseline_session_result.dart';
import 'physiological_sample.dart';

class BaselineSessionService {
  final BaselineBuilder _builder;

  const BaselineSessionService({
    BaselineBuilder builder = const BaselineBuilder(),
  }) : _builder = builder;

  BaselineSessionResult createInitialBaseline({
    required List<PhysiologicalSample> samples,
  }) {
    final baseline = _builder.build(samples);

    return BaselineSessionResult(
      baseline: baseline,
      sampleCount: samples.length,
      createdAt: DateTime.now(),
      usedFallbackDefaults: _isSafeDefault(baseline),
    );
  }

  bool _isSafeDefault(BaselineProfile baseline) {
    final fallback = BaselineProfile.safeDefault();

    return baseline.restingHeartRateBpm == fallback.restingHeartRateBpm &&
        baseline.hrvRmssdMs == fallback.hrvRmssdMs &&
        baseline.respiratoryRate == fallback.respiratoryRate &&
        baseline.movementIntensity == fallback.movementIntensity;
  }
}
