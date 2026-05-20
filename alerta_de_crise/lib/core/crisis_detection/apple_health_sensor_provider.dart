import '../../platform/apple_health/apple_health_models.dart';
import '../../platform/apple_health/apple_health_service.dart';
import '../../sensor_quality/sensor_quality_models.dart';
import '../../sensor_quality/sensor_quality_service.dart';
import 'physiological_sample.dart';
import 'physiological_sensor_provider.dart';
import 'sensor_provider_type.dart';

class AppleHealthSensorProvider implements PhysiologicalSensorProvider {
  final AppleHealthService _service;
  final SensorQualityService _qualityService;
  SensorQualityEvaluation? _lastQualityEvaluation;

  AppleHealthSensorProvider({
    required AppleHealthService service,
    SensorQualityService qualityService = const SensorQualityService(),
  }) : _service = service,
       _qualityService = qualityService;

  factory AppleHealthSensorProvider.defaultService() {
    return AppleHealthSensorProvider(
      service: AppleHealthService.defaultBridge(),
    );
  }

  @override
  SensorProviderType get type => SensorProviderType.appleWatch;

  SensorQualityEvaluation? get lastQualityEvaluation => _lastQualityEvaluation;

  Future<bool> requestPermissions() {
    return _service.requestPermissions();
  }

  Future<bool> isAvailable() {
    return _service.isAvailable();
  }

  @override
  Future<PhysiologicalSample?> getLatestSample() async {
    final hasPermissions = await _ensurePermissions();
    if (!hasPermissions) {
      return null;
    }

    final reading = await _service.getLatestReading();
    final sample = _sampleFromReading(reading);
    _lastQualityEvaluation = sample == null
        ? null
        : _qualityService.evaluateSampleQuality(sample: sample);
    return sample;
  }

  @override
  Future<List<PhysiologicalSample>> getRecentSamples({int limit = 30}) async {
    if (limit <= 0) {
      return const [];
    }

    final hasPermissions = await _ensurePermissions();
    if (!hasPermissions) {
      return const [];
    }

    final heartRateSamples = await _service.getRecentHeartRateSamples(
      limit: limit,
    );

    final samples = List<PhysiologicalSample>.unmodifiable(
      heartRateSamples
          .map(_sampleFromHeartRate)
          .whereType<PhysiologicalSample>(),
    );
    if (samples.isNotEmpty) {
      _lastQualityEvaluation = _qualityService.evaluateSampleQuality(
        sample: samples.last,
      );
    }

    return samples;
  }

  Future<bool> _ensurePermissions() async {
    if (await _service.hasPermissions()) {
      return true;
    }

    return _service.requestPermissions();
  }

  PhysiologicalSample? _sampleFromReading(AppleHealthReading reading) {
    final heartRate = reading.heartRate;
    if (heartRate == null) {
      return null;
    }

    return PhysiologicalSample(
      timestamp: reading.latestTimestamp ?? heartRate.timestamp,
      heartRateBpm: heartRate.normalizedValue,
      hrvRmssdMs: reading.hrv?.normalizedValue,
      spo2Percent: reading.spo2?.normalizedValue,
      movementIntensity: 0,
    );
  }

  PhysiologicalSample? _sampleFromHeartRate(
    AppleHealthQuantitySample heartRate,
  ) {
    if (!heartRate.isValid) {
      return null;
    }

    return PhysiologicalSample(
      timestamp: heartRate.timestamp,
      heartRateBpm: heartRate.normalizedValue,
      movementIntensity: 0,
    );
  }
}
