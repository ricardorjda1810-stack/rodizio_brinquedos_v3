import '../../domain/models/sensor_sample.dart';
import 'sensor_provider.dart';

final class HealthKitSensorProvider implements SensorProvider {
  const HealthKitSensorProvider();

  @override
  SensorProviderType get type => SensorProviderType.healthkit;

  @override
  Future<SensorSample?> getLatestSample() async {
    // TODO: Solicitar e validar permissões do HealthKit antes da leitura.
    // TODO: Ler frequência cardíaca recente quando a integração real existir.
    // TODO: Ler HRV recente quando a integração real existir.
    return null;
  }

  @override
  Stream<SensorSample> watchSamples() {
    // TODO: Expor stream de amostras reais do ecossistema iOS/Apple Watch.
    return const Stream<SensorSample>.empty();
  }
}
