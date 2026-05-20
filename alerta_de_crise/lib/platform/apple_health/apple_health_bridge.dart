import 'package:health/health.dart';

import 'apple_health_models.dart';

abstract class AppleHealthBridge {
  Future<void> configure();

  Future<bool?> hasPermissions(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  });

  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  });

  Future<List<AppleHealthQuantitySample>> getQuantitySamples({
    required HealthDataType type,
    required AppleHealthMetric metric,
    required DateTime startTime,
    required DateTime endTime,
  });
}

class HealthPackageAppleHealthBridge implements AppleHealthBridge {
  final Health _health;

  HealthPackageAppleHealthBridge({Health? health})
    : _health = health ?? Health();

  @override
  Future<void> configure() {
    return _health.configure();
  }

  @override
  Future<bool?> hasPermissions(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) {
    return _health.hasPermissions(types, permissions: permissions);
  }

  @override
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) {
    return _health.requestAuthorization(types, permissions: permissions);
  }

  @override
  Future<List<AppleHealthQuantitySample>> getQuantitySamples({
    required HealthDataType type,
    required AppleHealthMetric metric,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final points = await _health.getHealthDataFromTypes(
      types: [type],
      preferredUnits: {
        HealthDataType.HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
        HealthDataType.HEART_RATE_VARIABILITY_SDNN: HealthDataUnit.MILLISECOND,
        HealthDataType.BLOOD_OXYGEN: HealthDataUnit.PERCENT,
      },
      startTime: startTime,
      endTime: endTime,
    );

    return points
        .map((point) => _toQuantitySample(point, metric))
        .whereType<AppleHealthQuantitySample>()
        .where((sample) => sample.isValid)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  AppleHealthQuantitySample? _toQuantitySample(
    HealthDataPoint point,
    AppleHealthMetric metric,
  ) {
    final value = point.value;
    if (value is! NumericHealthValue) {
      return null;
    }

    return AppleHealthQuantitySample(
      metric: metric,
      value: value.numericValue.toDouble(),
      timestamp: point.dateTo,
      sourceName: point.sourceName,
    );
  }
}
