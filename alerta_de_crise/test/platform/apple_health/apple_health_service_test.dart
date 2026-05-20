import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:signalflow/platform/apple_health/apple_health_bridge.dart';
import 'package:signalflow/platform/apple_health/apple_health_models.dart';
import 'package:signalflow/platform/apple_health/apple_health_service.dart';

void main() {
  group('AppleHealthService', () {
    test('requests read permissions for heart rate, hrv and spo2', () async {
      final bridge = _FakeAppleHealthBridge();
      final service = AppleHealthService(bridge: bridge);

      final granted = await service.requestPermissions();

      expect(granted, isTrue);
      expect(bridge.requestedTypes, AppleHealthService.readableTypes);
      expect(bridge.requestedPermissions, AppleHealthService.readPermissions);
    });

    test('returns latest heart rate sample sorted by timestamp', () async {
      final older = DateTime(2026, 5, 16, 10);
      final newer = DateTime(2026, 5, 16, 10, 1);
      final bridge = _FakeAppleHealthBridge(
        samples: {
          HealthDataType.HEART_RATE: [
            AppleHealthQuantitySample(
              metric: AppleHealthMetric.heartRate,
              value: 72,
              timestamp: older,
            ),
            AppleHealthQuantitySample(
              metric: AppleHealthMetric.heartRate,
              value: 80,
              timestamp: newer,
            ),
          ],
        },
      );
      final service = AppleHealthService(bridge: bridge);

      final sample = await service.getLatestHeartRate();

      expect(sample?.normalizedValue, 80);
      expect(sample?.timestamp, newer);
    });

    test('normalizes fractional spo2 value to percentage', () {
      final sample = AppleHealthQuantitySample(
        metric: AppleHealthMetric.spo2,
        value: 0.97,
        timestamp: DateTime(2026, 5, 16),
      );

      expect(sample.normalizedValue, 97);
      expect(sample.isValid, isTrue);
    });
  });
}

class _FakeAppleHealthBridge implements AppleHealthBridge {
  _FakeAppleHealthBridge({this.samples = const {}});

  final Map<HealthDataType, List<AppleHealthQuantitySample>> samples;
  List<HealthDataType> requestedTypes = const [];
  List<HealthDataAccess>? requestedPermissions;

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
    requestedTypes = types;
    requestedPermissions = permissions;
    return true;
  }
}
