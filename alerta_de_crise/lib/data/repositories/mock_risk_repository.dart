import '../../domain/models/risk_event.dart';
import '../../domain/models/risk_state.dart';
import '../../domain/models/sensor_sample.dart';

final class MockRiskRepository {
  const MockRiskRepository();

  SensorSample getCurrentSample() {
    return SensorSample(
      id: 'sample-current',
      timestamp: DateTime.now(),
      heartRate: 92,
      hrv: 28,
      motionState: 'parado',
    );
  }

  RiskState getCurrentRiskState() {
    return RiskState.atencao;
  }

  String getCurrentStatusMessage() {
    return 'Seu corpo está com sinais leves de ativação. Vale reduzir o ritmo agora.';
  }

  List<RiskEvent> getRecentEvents() {
    final now = DateTime.now();

    return [
      RiskEvent(
        id: 'event-1',
        startedAt: now.subtract(const Duration(hours: 2, minutes: 20)),
        endedAt: now.subtract(const Duration(hours: 2, minutes: 12)),
        state: RiskState.alerta,
        maxScore: 82,
        beforeHeartRate: 108,
        beforeHrv: 21,
        afterHeartRate: 88,
        afterHrv: 34,
        title: 'Alerta automático',
        description:
            'Sinais de ativação aumentaram enquanto o corpo estava parado.',
        feedback: 'Sim, melhorei',
      ),
      RiskEvent(
        id: 'event-2',
        startedAt: now.subtract(const Duration(days: 1, hours: 3)),
        endedAt: now.subtract(const Duration(days: 1, hours: 2, minutes: 55)),
        state: RiskState.atencao,
        maxScore: 63,
        beforeHeartRate: 96,
        beforeHrv: 26,
        afterHeartRate: 84,
        afterHrv: 33,
        title: 'Intervenção manual',
        description:
            'Regulação iniciada ao perceber sinais de ativação em atenção.',
        feedback: 'Mais ou menos',
      ),
      RiskEvent(
        id: 'event-3',
        startedAt: now.subtract(const Duration(days: 3, hours: 1)),
        endedAt: now.subtract(const Duration(days: 3, minutes: 48)),
        state: RiskState.alerta,
        maxScore: 78,
        beforeHeartRate: 104,
        beforeHrv: 22,
        afterHeartRate: 90,
        afterHrv: 31,
        title: 'Alerta automático anterior',
        description:
            'Sinais de ativação em atenção por alguns minutos, seguidos de respiração guiada.',
        feedback: 'Não, ainda preciso de apoio',
      ),
    ];
  }
}
