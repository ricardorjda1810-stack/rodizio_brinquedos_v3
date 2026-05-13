import 'models/risk_state.dart';
import 'models/sensitivity_level.dart';
import 'models/sensor_sample.dart';

final class RiskEngine {
  const RiskEngine();

  static const int fallbackHeartRate = 72;
  static const int fallbackHrv = 42;

  RiskEvaluation evaluate(
    SensorSample sample, {
    required int baselineHeartRate,
    required int baselineHrv,
    required SensitivityLevel sensitivity,
  }) {
    final heartRateScore = (sample.heartRate - baselineHeartRate).clamp(0, 40);
    final hrvScore = (baselineHrv - sample.hrv).clamp(0, 40);
    final motionDiscount = sample.motionState == 'parado' ? 0 : 18;
    final score = (heartRateScore * 2 + hrvScore * 2 - motionDiscount)
        .clamp(0, 100)
        .toInt();

    final state = score >= sensitivity.alertThreshold
        ? RiskState.alerta
        : score >= 35
        ? RiskState.atencao
        : RiskState.normal;

    return RiskEvaluation(
      state: state,
      score: score,
      message: _messageFor(state),
    );
  }

  String _messageFor(RiskState state) {
    return switch (state) {
      RiskState.normal =>
        'Sinais estáveis no momento. Continue observando seu ritmo.',
      RiskState.atencao =>
        'Seu corpo está com sinais leves de ativação. Vale reduzir o ritmo agora.',
      RiskState.alerta =>
        'Seu corpo apresentou sinais de ativação. Uma regulação curta pode ajudar agora.',
    };
  }
}

final class RiskEvaluation {
  const RiskEvaluation({
    required this.state,
    required this.score,
    required this.message,
  });

  final RiskState state;
  final int score;
  final String message;
}
