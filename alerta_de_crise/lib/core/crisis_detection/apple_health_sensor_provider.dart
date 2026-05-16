import '../../platform/apple_health/apple_health_models.dart';
import '../../platform/apple_health/apple_health_service.dart';
import 'physiological_sample.dart';
import 'physiological_sensor_provider.dart';
import 'sensor_provider_type.dart';

class AppleHealthSensorProvider implements PhysiologicalSensorProvider {
  final AppleHealthService _service;

  const AppleHealthSensorProvider({required AppleHealthService service})
    : _service = service;

  factory AppleHealthSensorProvider.defaultService() {
    return AppleHealthSensorProvider(
      service: AppleHealthService.defaultBridge(),
    );
  }

  @override
  SensorProviderType get type => SensorProviderType.appleWatch;

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
    return _sampleFromReading(reading);
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

    return List.unmodifiable(
      heartRateSamples
          .map(_sampleFromHeartRate)
          .whereType<PhysiologicalSample>(),
    );
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
