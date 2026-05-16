import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:signalflow/core/crisis_detection/apple_health_sensor_provider.dart';
import 'package:signalflow/core/crisis_detection/sensor_provider_type.dart';
import 'package:signalflow/platform/apple_health/apple_health_bridge.dart';
import 'package:signalflow/platform/apple_health/apple_health_models.dart';
import 'package:signalflow/platform/apple_health/apple_health_service.dart';

void main() {
  group('AppleHealthSensorProvider', () {
    test('converts Apple Health reading to PhysiologicalSample', () async {
      final timestamp = DateTime(2026, 5, 16, 10);
      final provider = AppleHealthSensorProvider(
        service: AppleHealthService(
          bridge: _FakeAppleHealthBridge(
            samples: {
              HealthDataType.HEART_RATE: [
                AppleHealthQuantitySample(
                  metric: AppleHealthMetric.heartRate,
                  value: 82,
                  timestamp: timestamp,
                ),
              ],
              HealthDataType.HEART_RATE_VARIABILITY_SDNN: [
                AppleHealthQuantitySample(
                  metric: AppleHealthMetric.hrvSdnn,
                  value: 38,
                  timestamp: timestamp,
                ),
              ],
              HealthDataType.BLOOD_OXYGEN: [
                AppleHealthQuantitySample(
                  metric: AppleHealthMetric.spo2,
                  value: 0.98,
                  timestamp: timestamp,
                ),
              ],
            },
          ),
        ),
      );

      final sample = await provider.getLatestSample();

      expect(provider.type, SensorProviderType.appleWatch);
      expect(sample?.heartRateBpm, 82);
      expect(sample?.hrvRmssdMs, 38);
      expect(sample?.spo2Percent, 98);
      expect(sample?.movementIntensity, 0);
    });

    test('returns null when heart rate is missing', () async {
      final provider = AppleHealthSensorProvider(
        service: AppleHealthService(bridge: _FakeAppleHealthBridge()),
      );

      final sample = await provider.getLatestSample();

      expect(sample, isNull);
    });

    test('recent samples respects limit', () async {
      final bridge = _FakeAppleHealthBridge(
        samples: {
          HealthDataType.HEART_RATE: List.generate(
            4,
            (index) => AppleHealthQuantitySample(
              metric: AppleHealthMetric.heartRate,
              value: 70 + index.toDouble(),
              timestamp: DateTime(2026, 5, 16, 10, index),
            ),
          ),
        },
      );
      final provider = AppleHealthSensorProvider(
        service: AppleHealthService(bridge: bridge),
      );

      final samples = await provider.getRecentSamples(limit: 2);

      expect(samples, hasLength(2));
      expect(samples.first.heartRateBpm, 73);
    });
  });
}

class _FakeAppleHealthBridge implements AppleHealthBridge {
  _FakeAppleHealthBridge({this.samples = const {}});

  final Map<HealthDataType, List<AppleHealthQuantitySample>> samples;

  @override
  Future<void> configure() async {}

  @override
  Future<List<AppleHealthQuantitySample>> getQuantitySamples({
    required HealthDataType type,
    required AppleHealthMetric metric,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final values = List<AppleHealthQuantitySample>.of(
      samples[type] ?? const [],
    );
    values.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return values;
  }

  @override
  Future<bool?> hasPermissions(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) async {
    return true;
  }

  @override
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) async {
    return true;
  }
}
