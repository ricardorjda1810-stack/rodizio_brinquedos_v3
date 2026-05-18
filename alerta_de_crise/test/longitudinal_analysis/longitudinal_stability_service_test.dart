import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/longitudinal_analysis/longitudinal_stability_service.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/session_timeline/session_timeline_models.dart';

void main() {
  group('LongitudinalStabilityService', () {
    const service = LongitudinalStabilityService();

    test('calculates consistent stability score', () {
      final stability = service.calculateStability(
        sessions: [
          _session('s1', 70, 42),
          _session('s2', 71, 41),
          _session('s3', 72, 40),
        ],
        trends: [_trend(38), _trend(40), _trend(42)],
        recoveryProfiles: [_recovery(0.58, 42), _recovery(0.6, 40)],
      );

      expect(stability, greaterThan(85));
      expect(stability, lessThanOrEqualTo(100));
    });

    test('calculates variability consistently', () {
      final low = service.calculateVariability(
        sessions: [_session('s1', 70, 42), _session('s2', 71, 41)],
      );
      final high = service.calculateVariability(
        sessions: [_session('s1', 66, 50), _session('s2', 92, 24)],
        trends: [_trend(20), _trend(82)],
      );

      expect(high, greaterThan(low));
    });

    test('detects persistent drift', () {
      final drift = service.detectPersistentDrift(
        trends: [_trend(30), _trend(44), _trend(62), _trend(78)],
        recoveryProfiles: [
          _recovery(0.7, 30),
          _recovery(0.58, 42),
          _recovery(0.44, 58),
          _recovery(0.32, 70),
        ],
      );

      expect(drift, isTrue);
    });
  });
}

SessionTimeline _session(String id, double heartRate, double hrv) {
  return SessionTimeline(
    id: id,
    startedAt: DateTime.utc(2026, 5, 18, 9),
    endedAt: DateTime.utc(2026, 5, 18, 9, 30),
    totalSamples: 60,
    totalEvents: 2,
    averageHeartRate: heartRate,
    averageHrv: hrv,
    maxHeartRate: heartRate + 12,
    minHrv: hrv - 6,
  );
}

PhysiologicalTrend _trend(int score) {
  return PhysiologicalTrend(
    averageHeartRate: 72,
    averageHrv: 40,
    hrvSlope: -0.2,
    heartRateSlope: 0.3,
    activationDensity: score / 100,
    escalationScore: score,
    generatedAt: DateTime.utc(2026, 5, 18),
    window: TrendWindow.longTerm,
  );
}

AutonomicRecoveryProfile _recovery(double rate, int fatigue) {
  return AutonomicRecoveryProfile(
    recoveryRate: rate,
    hrvRecoverySlope: 0.2,
    heartRateNormalization: rate,
    baselineReturnTime: const Duration(minutes: 20),
    resilienceScore: 100 - fatigue,
    fatigueScore: fatigue,
    stressCarryover: fatigue / 100,
    generatedAt: DateTime.utc(2026, 5, 18),
    resilienceLevel: AutonomicResilienceLevel.stable,
  );
}
