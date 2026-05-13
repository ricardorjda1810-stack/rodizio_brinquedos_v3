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
          ? 'Permissão HealthKit concedida. A coleta real ainda não está ativa.'
          : 'Permissão HealthKit não concedida. A coleta real ainda não está ativa.';
      return granted;
    } catch (_) {
      _permissionStatusMessage =
          'Permissão HealthKit indisponível neste ambiente. A coleta real ainda não está ativa.';
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
          ? 'Permissão HealthKit concedida. A coleta real ainda não está ativa.'
          : 'Permissão HealthKit ainda não concedida.';
      return granted;
    } catch (_) {
      _permissionStatusMessage =
          'Permissão HealthKit indisponível neste ambiente. A coleta real ainda não está ativa.';
      return false;
    }
  }

  @override
  Future<SensorSample?> getLatestSample() async {
    // TODO(Pacote 17C): Ler frequência cardíaca recente após autorização.
    // TODO(Pacote 17C): Ler HRV SDNN recente após autorização.
    // TODO(Pacote 17C): Mapear ausência de dados reais para fallback seguro.
    return null;
  }

  @override
  Stream<SensorSample> watchSamples() {
    // TODO: Expor stream de amostras reais do ecossistema iOS/Apple Watch.
    return const Stream<SensorSample>.empty();
  }
}
