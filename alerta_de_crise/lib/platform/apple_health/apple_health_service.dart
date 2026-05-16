import 'package:health/health.dart';

import 'apple_health_bridge.dart';
import 'apple_health_models.dart';

class AppleHealthService {
  final AppleHealthBridge _bridge;

  const AppleHealthService({required AppleHealthBridge bridge})
    : _bridge = bridge;

  factory AppleHealthService.defaultBridge() {
    return AppleHealthService(bridge: HealthPackageAppleHealthBridge());
  }

  static const List<HealthDataType> readableTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.BLOOD_OXYGEN,
  ];

  static const List<HealthDataAccess> readPermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<bool> isAvailable() async {
    try {
      await _bridge.configure();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      await _bridge.configure();
      return _bridge.requestAuthorization(
        readableTypes,
        permissions: readPermissions,
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    try {
      await _bridge.configure();
      final granted = await _bridge.hasPermissions(
        readableTypes,
        permissions: readPermissions,
      );
      return granted == true;
    } catch (_) {
      return false;
    }
  }

  Future<AppleHealthQuantitySample?> getLatestHeartRate() {
    return _getLatest(
      type: HealthDataType.HEART_RATE,
      metric: AppleHealthMetric.heartRate,
    );
  }

  Future<AppleHealthQuantitySample?> getLatestHrv() {
    return _getLatest(
      type: HealthDataType.HEART_RATE_VARIABILITY_SDNN,
      metric: AppleHealthMetric.hrvSdnn,
    );
  }

  Future<AppleHealthQuantitySample?> getLatestSpo2() {
    return _getLatest(
      type: HealthDataType.BLOOD_OXYGEN,
      metric: AppleHealthMetric.spo2,
    );
  }

  Future<AppleHealthReading> getLatestReading() async {
    final heartRate = await getLatestHeartRate();
    final hrv = await getLatestHrv();
    final spo2 = await getLatestSpo2();

    return AppleHealthReading(heartRate: heartRate, hrv: hrv, spo2: spo2);
  }

  Future<List<AppleHealthQuantitySample>> getRecentHeartRateSamples({
    int limit = 30,
    Duration window = const Duration(minutes: 30),
  }) async {
    return _getRecent(
      type: HealthDataType.HEART_RATE,
      metric: AppleHealthMetric.heartRate,
      limit: limit,
      window: window,
    );
  }

  Future<AppleHealthQuantitySample?> _getLatest({
    required HealthDataType type,
    required AppleHealthMetric metric,
    Duration window = const Duration(minutes: 30),
  }) async {
    final samples = await _getRecent(
      type: type,
      metric: metric,
      limit: 1,
      window: window,
    );

    return samples.isEmpty ? null : samples.first;
  }

  Future<List<AppleHealthQuantitySample>> _getRecent({
    required HealthDataType type,
    required AppleHealthMetric metric,
    required int limit,
    required Duration window,
  }) async {
    if (limit <= 0) {
      return const [];
    }

    final end = DateTime.now();
    final samples = await _bridge.getQuantitySamples(
      type: type,
      metric: metric,
      startTime: end.subtract(window),
      endTime: end,
    );

    return List.unmodifiable(samples.take(limit));
  }
}
