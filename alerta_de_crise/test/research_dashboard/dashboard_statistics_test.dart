import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/research_dashboard/dashboard_statistics.dart';
import 'package:signalflow/sensor_quality/sensor_confidence_score.dart';

void main() {
  group('DashboardStatistics', () {
    test('calculates consistent averages', () {
      final metrics = DashboardStatistics.calculateMetrics(
        trends: [_trend(70, 44, 0.1, 20), _trend(80, 40, 0.3, 40)],
        confidenceScores: [_confidence(80), _confidence(90)],
      );

      expect(metrics.averageHeartRate, 75);
      expect(metrics.averageHrv, 42);
      expect(metrics.averageConfidence, 85);
      expect(metrics.activationDensity, closeTo(0.2, 0.001));
    });

    test('counts escalations and calculates recovery efficiency', () {
      final metrics = DashboardStatistics.calculateMetrics(
        trends: [
          _trend(80, 38, 0.4, 55),
          _trend(90, 35, 0.7, 70),
          _trend(72, 44, 0.1, 20),
        ],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.5, resilience: 60, fatigue: 30),
          _recovery(recoveryRate: 0.7, resilience: 80, fatigue: 20),
        ],
      );

      expect(metrics.escalationCount, 2);
      expect(metrics.recoveryEfficiency, closeTo(60, 0.001));
      expect(metrics.resilienceScore, 70);
      expect(metrics.fatigueScore, 25);
    });

    test('generates longitudinal insights', () {
      final metrics = DashboardStatistics.calculateMetrics(
        trends: [_trend(74, 42, 0.2, 20), _trend(86, 34, 0.5, 68)],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.4, resilience: 55, fatigue: 45),
          _recovery(recoveryRate: 0.2, resilience: 40, fatigue: 65),
        ],
      );
      final insights = DashboardStatistics.calculateInsights(
        metrics: metrics,
        trends: [_trend(74, 42, 0.2, 20), _trend(86, 34, 0.5, 68)],
        recoveryProfiles: [
          _recovery(recoveryRate: 0.4, resilience: 55, fatigue: 45),
          _recovery(recoveryRate: 0.2, resilience: 40, fatigue: 65),
        ],
      );

      expect(insights.worseningTrend, isTrue);
      expect(insights.improvingTrend, isFalse);
      expect(insights.autonomicLoad, greaterThan(0));
    });
  });
}

PhysiologicalTrend _trend(
  double heartRate,
  double hrv,
  double activationDensity,
  int escalationScore,
) {
  return PhysiologicalTrend(
    averageHeartRate: heartRate,
    averageHrv: hrv,
    hrvSlope: -0.4,
    heartRateSlope: 0.6,
    activationDensity: activationDensity,
    escalationScore: escalationScore,
    generatedAt: DateTime.utc(2026, 5, 17),
    window: TrendWindow.mediumTerm,
  );
}

AutonomicRecoveryProfile _recovery({
  required double recoveryRate,
  required int resilience,
  required int fatigue,
}) {
  return AutonomicRecoveryProfile(
    recoveryRate: recoveryRate,
    hrvRecoverySlope: 0.4,
    heartRateNormalization: recoveryRate,
    baselineReturnTime: const Duration(minutes: 20),
    resilienceScore: resilience,
    fatigueScore: fatigue,
    stressCarryover: fatigue / 100,
    generatedAt: DateTime.utc(2026, 5, 17),
    resilienceLevel: resilience >= 70
        ? AutonomicResilienceLevel.stable
        : AutonomicResilienceLevel.fatigued,
  );
}

SensorConfidenceScore _confidence(int score) {
  return SensorConfidenceScore(
    overallScore: score,
    rrQuality: score,
    hrQuality: score,
    movementConfidence: score,
    contactConfidence: score,
    hasArtifacts: false,
    warnings: const [],
  );
}
