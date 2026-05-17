import '../../polar_h10/polar_h10_rr_sample.dart';
import '../../polar_h10/polar_h10_service.dart';
import '../../polar_h10/polar_h10_statistics.dart';
import 'physiological_sample.dart';
import 'physiological_sensor_provider.dart';
import 'sensor_provider_type.dart';

class PolarH10SensorProvider implements PhysiologicalSensorProvider {
  final PolarH10Service _service;

  const PolarH10SensorProvider({required PolarH10Service service})
    : _service = service;

  factory PolarH10SensorProvider.defaultService() {
    return PolarH10SensorProvider(service: PolarH10Service());
  }

  @override
  SensorProviderType get type => SensorProviderType.polarH10;

  @override
  Future<PhysiologicalSample?> getLatestSample() async {
    final rrSample = await _service.getLatestRrSample();
    if (rrSample == null || !rrSample.isValid) {
      return null;
    }

    final recentRrSamples = await _service.getRecentRrSamples();
    return _sampleFromRr(
      rrSample,
      statistics: PolarH10Statistics.fromSamples(recentRrSamples),
    );
  }

  @override
  Future<List<PhysiologicalSample>> getRecentSamples({int limit = 30}) async {
    if (limit <= 0) {
      return const [];
    }

    final rrSamples = await _service.getRecentRrSamples(limit: limit);
    final statistics = PolarH10Statistics.fromSamples(rrSamples);

    return List.unmodifiable(
      rrSamples
          .where((sample) => sample.isValid)
          .map((sample) => _sampleFromRr(sample, statistics: statistics)),
    );
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
