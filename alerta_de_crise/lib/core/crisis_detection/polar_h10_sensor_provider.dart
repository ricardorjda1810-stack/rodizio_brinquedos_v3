import '../../polar_h10/polar_h10_rr_sample.dart';
import '../../polar_h10/polar_h10_service.dart';
import '../../polar_h10/polar_h10_statistics.dart';
import '../../sensor_quality/sensor_quality_models.dart';
import '../../sensor_quality/sensor_quality_service.dart';
import 'physiological_sample.dart';
import 'physiological_sensor_provider.dart';
import 'sensor_provider_type.dart';

class PolarH10SensorProvider implements PhysiologicalSensorProvider {
  final PolarH10Service _service;
  final SensorQualityService _qualityService;
  SensorQualityEvaluation? _lastQualityEvaluation;

  PolarH10SensorProvider({
    required PolarH10Service service,
    SensorQualityService qualityService = const SensorQualityService(),
  }) : _service = service,
       _qualityService = qualityService;

  factory PolarH10SensorProvider.defaultService() {
    return PolarH10SensorProvider(service: PolarH10Service());
  }

  @override
  SensorProviderType get type => SensorProviderType.polarH10;

  SensorQualityEvaluation? get lastQualityEvaluation => _lastQualityEvaluation;

  @override
  Future<PhysiologicalSample?> getLatestSample() async {
    final rrSample = await _service.getLatestRrSample();
    if (rrSample == null || !rrSample.isValid) {
      return null;
    }

    final recentRrSamples = await _service.getRecentRrSamples();
    final sample = _sampleFromRr(
      rrSample,
      statistics: PolarH10Statistics.fromSamples(recentRrSamples),
    );
    _lastQualityEvaluation = _qualityService.evaluateSampleQuality(
      sample: sample,
      rrIntervalsMs: recentRrSamples
          .map((sample) => sample.rrIntervalMs)
          .toList(growable: false),
      contactDetected: rrSample.contactDetected,
    );

    return sample;
  }

  @override
  Future<List<PhysiologicalSample>> getRecentSamples({int limit = 30}) async {
    if (limit <= 0) {
      return const [];
    }

    final rrSamples = await _service.getRecentRrSamples(limit: limit);
    final statistics = PolarH10Statistics.fromSamples(rrSamples);

    final samples = List<PhysiologicalSample>.unmodifiable(
      rrSamples
          .where((sample) => sample.isValid)
          .map((sample) => _sampleFromRr(sample, statistics: statistics)),
    );
    if (samples.isNotEmpty) {
      final latestRr = rrSamples.last;
      _lastQualityEvaluation = _qualityService.evaluateSampleQuality(
        sample: samples.last,
        rrIntervalsMs: rrSamples
            .map((sample) => sample.rrIntervalMs)
            .toList(growable: false),
        contactDetected: latestRr.contactDetected,
      );
    }

    return samples;
  }

  PhysiologicalSample _sampleFromRr(
    PolarH10RrSample sample, {
    required PolarH10Statistics statistics,
  }) {
    return PhysiologicalSample(
      timestamp: sample.timestamp,
      heartRateBpm: sample.heartRate,
      hrvRmssdMs: statistics.rmssdMs,
      movementIntensity: 0,
    );
  }
}
