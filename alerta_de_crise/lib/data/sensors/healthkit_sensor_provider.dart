import 'package:health/health.dart';

import '../../domain/models/sensor_sample.dart';
import 'sensor_provider.dart';

final class HealthKitSensorProvider implements SensorProvider {
  HealthKitSensorProvider({Health? health}) : _health = health ?? Health();

  static const List<HealthDataType> plannedTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
  ];

  static const List<HealthDataAccess> plannedPermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  final Health _health;
  String _permissionStatusMessage = 'Permissão HealthKit ainda não solicitada.';
  static const int _fallbackHrv = 40;

  @override
  SensorProviderType get type => SensorProviderType.healthkit;

  @override
  String get permissionStatusMessage => _permissionStatusMessage;

  @override
  Future<bool> requestPermissions() async {
    try {
      await _health.configure();
      final granted = await _health.requestAuthorization(
        plannedTypes,
        permissions: plannedPermissions,
      );
      _permissionStatusMessage = granted
          ? 'Permissão HealthKit concedida.'
          : 'Permissão HealthKit não concedida.';
      return granted;
    } catch (_) {
      _permissionStatusMessage =
          'Permissão HealthKit indisponível neste ambiente.';
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      await _health.configure();
      final granted = await _health.hasPermissions(
        plannedTypes,
        permissions: plannedPermissions,
      );
      if (granted == null) {
        _permissionStatusMessage =
            'O iOS não informa o status de leitura do HealthKit. Solicite permissão para continuar a preparação.';
        return false;
      }
      _permissionStatusMessage = granted
          ? 'Permissão HealthKit concedida.'
          : 'Permissão HealthKit ainda não concedida.';
      return granted;
    } catch (_) {
      _permissionStatusMessage =
          'Permissão HealthKit indisponível neste ambiente.';
      return false;
    }
  }

  @override
  Future<SensorSample?> getLatestSample() async {
    try {
      final canRead = await _ensurePermissionsForRead();
      if (!canRead) {
        return null;
      }

      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 30));
      final heartRatePoint = await _latestPoint(
        HealthDataType.HEART_RATE,
        start,
        now,
      );
      if (heartRatePoint == null) {
        _permissionStatusMessage =
            'Nenhum dado recente encontrado no HealthKit.';
        return null;
      }

      final hrvPoint = await _latestPoint(
        HealthDataType.HEART_RATE_VARIABILITY_SDNN,
        start,
        now,
      );
      final heartRate = _numericValue(heartRatePoint)?.round();
      if (heartRate == null || heartRate <= 0) {
        _permissionStatusMessage =
            'Nenhum dado recente encontrado no HealthKit.';
        return null;
      }

      final hrv = _numericValue(hrvPoint)?.round();
      final hasRealHrv = hrv != null && hrv > 0;
      final timestamp = _latestTimestamp(heartRatePoint, hrvPoint);
      _permissionStatusMessage = hasRealHrv
          ? 'Último dado do HealthKit carregado.'
          : 'Última frequência cardíaca carregada. HRV recente não encontrado.';

      return SensorSample(
        id:
            'healthkit-${timestamp.microsecondsSinceEpoch}'
            '${hasRealHrv ? '' : '-fc-only'}',
        timestamp: timestamp,
        heartRate: heartRate,
        hrv: hasRealHrv ? hrv : _fallbackHrv,
        motionState: hasRealHrv ? 'healthkit' : 'healthkit-hrv-indisponivel',
      );
    } catch (_) {
      _permissionStatusMessage =
          'Não foi possível ler dados recentes do HealthKit.';
      return null;
    }
  }

  @override
  Stream<SensorSample> watchSamples() {
    // TODO: Expor stream de amostras reais do ecossistema iOS/Apple Watch.
    return const Stream<SensorSample>.empty();
  }

  Future<bool> _ensurePermissionsForRead() async {
    final granted = await hasPermissions();
    if (granted) {
      return true;
    }

    return requestPermissions();
  }

  Future<HealthDataPoint?> _latestPoint(
    HealthDataType type,
    DateTime start,
    DateTime end,
  ) async {
    final points = await _health.getHealthDataFromTypes(
      types: [type],
      preferredUnits: {
        HealthDataType.HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
        HealthDataType.HEART_RATE_VARIABILITY_SDNN: HealthDataUnit.MILLISECOND,
      },
      startTime: start,
      endTime: end,
    );
    if (points.isEmpty) {
      return null;
    }

    points.sort((a, b) => b.dateTo.compareTo(a.dateTo));
    return points.first;
  }

  num? _numericValue(HealthDataPoint? point) {
    final value = point?.value;
    if (value is! NumericHealthValue) {
      return null;
    }

    return value.numericValue;
  }

  DateTime _latestTimestamp(
    HealthDataPoint heartRatePoint,
    HealthDataPoint? hrvPoint,
  ) {
    final hrvDate = hrvPoint?.dateTo;
    if (hrvDate != null && hrvDate.isAfter(heartRatePoint.dateTo)) {
      return hrvDate;
    }

    return heartRatePoint.dateTo;
  }
}
