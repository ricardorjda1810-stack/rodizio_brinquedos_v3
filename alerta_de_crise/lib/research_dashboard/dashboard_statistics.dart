import '../adaptive_baseline/adaptive_baseline_models.dart';
import '../adaptive_baseline/adaptive_baseline_statistics.dart';
import '../core/crisis_detection/physiological_sample.dart';
import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../data/crisis_detection/intervention_history_entry.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../sensor_quality/sensor_confidence_score.dart';
import '../session_timeline/session_timeline_models.dart';
import 'dashboard_metrics.dart';
import 'longitudinal_insights.dart';

class DashboardStatistics {
  const DashboardStatistics._();

  static DashboardMetrics calculateMetrics({
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<InterventionHistoryEntry> interventions = const [],
    List<SessionTimeline> timelines = const [],
    List<SensorConfidenceScore> confidenceScores = const [],
    AdaptiveBaselineProfile? adaptiveBaseline,
  }) {
    final averageHeartRate =
        _averageNullable(trends.map((trend) => trend.averageHeartRate)) ??
        _averageNullable(
          timelines.map((timeline) => timeline.averageHeartRate),
        );
    final averageHrv =
        _averageNullable(trends.map((trend) => trend.averageHrv)) ??
        _averageNullable(timelines.map((timeline) => timeline.averageHrv));
    final activationDensity =
        _average(trends.map((trend) => trend.activationDensity).toList()) ?? 0;
    final recoveryEfficiency =
        (_average(
              recoveryProfiles.map((profile) => profile.recoveryRate).toList(),
            ) ??
            0) *
        100;
    final resilienceScore = _roundAverage(
      recoveryProfiles.map((profile) => profile.resilienceScore).toList(),
    );
    final fatigueScore = _roundAverage(
      recoveryProfiles.map((profile) => profile.fatigueScore).toList(),
    );

    return DashboardMetrics(
      averageHeartRate: averageHeartRate,
      averageHrv: averageHrv,
      averageConfidence:
          _average(
            confidenceScores
                .map((score) => score.overallScore.toDouble())
                .toList(),
          ) ??
          0,
      escalationCount: trends
          .where((trend) => trend.escalationScore >= 50)
          .length,
      interventionCount: interventions.length,
      recoveryEfficiency: recoveryEfficiency.clamp(0, 100).toDouble(),
      resilienceScore: resilienceScore.clamp(0, 100),
      fatigueScore: fatigueScore.clamp(0, 100),
      activationDensity: activationDensity.clamp(0, 1).toDouble(),
      baselineStability: _baselineStability(adaptiveBaseline),
      stressCarryover:
          _average(
            recoveryProfiles.map((profile) => profile.stressCarryover).toList(),
          ) ??
          0,
    );
  }

  static LongitudinalInsights calculateInsights({
    required DashboardMetrics metrics,
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
  }) {
    final escalationDelta = _secondHalfAverage(
      trends.map((trend) => trend.escalationScore.toDouble()).toList(),
    );
    final recoveryDelta = _secondHalfAverage(
      recoveryProfiles.map((profile) => profile.recoveryRate).toList(),
    );
    final autonomicLoad = _autonomicLoad(metrics);

    return LongitudinalInsights(
      improvingTrend:
          escalationDelta != null &&
          escalationDelta < -5 &&
          metrics.fatigueScore < 50,
      worseningTrend:
          escalationDelta != null &&
          escalationDelta > 5 &&
          (metrics.fatigueScore >= 50 || metrics.stressCarryover >= 0.5),
      recoveryTrend: recoveryDelta == null
          ? metrics.recoveryEfficiency >= 60
          : recoveryDelta >= 0,
      confidenceTrend: metrics.averageConfidence >= 70,
      circadianStability: metrics.baselineStability >= 70,
      autonomicLoad: autonomicLoad,
    );
  }

  static double? _averageNullable(Iterable<double?> values) {
    return _average(values.whereType<double>().toList());
  }

  static double? _average(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }

  static int _roundAverage(List<int> values) {
    final average = _average(values.map((value) => value.toDouble()).toList());
    return average == null ? 0 : average.round();
  }

  static double _baselineStability(AdaptiveBaselineProfile? adaptiveBaseline) {
    if (adaptiveBaseline == null ||
        adaptiveBaseline.circadianProfiles.isEmpty) {
      return 100;
    }
    final statistics = AdaptiveBaselineStatistics.fromSamples(
      adaptiveBaseline.circadianProfiles
          .asMap()
          .entries
          .map(
            (entry) => _physiologicalSample(
              heartRate: entry.value.averageHeartRate,
              index: entry.key,
            ),
          )
          .toList(),
    );
    return statistics.stabilityScore;
  }

  static double? _secondHalfAverage(List<double> values) {
    if (values.length < 2) {
      return null;
    }
    final midpoint = values.length ~/ 2;
    final first = values.take(midpoint).toList();
    final second = values.skip(midpoint).toList();
    final firstAverage = _average(first);
    final secondAverage = _average(second);
    if (firstAverage == null || secondAverage == null) {
      return null;
    }
    return secondAverage - firstAverage;
  }

  static double _autonomicLoad(DashboardMetrics metrics) {
    final escalationLoad = (metrics.escalationCount * 12).clamp(0, 35);
    final activationLoad = metrics.activationDensity * 25;
    final fatigueLoad = metrics.fatigueScore * 0.25;
    final carryoverLoad = metrics.stressCarryover * 25;
    final resilienceOffset = (100 - metrics.resilienceScore) * 0.1;
    return (escalationLoad +
            activationLoad +
            fatigueLoad +
            carryoverLoad +
            resilienceOffset)
        .clamp(0, 100)
        .toDouble();
  }
}

PhysiologicalSample _physiologicalSample({
  required double heartRate,
  required int index,
}) {
  return PhysiologicalSample(
    timestamp: DateTime.utc(2026, 1, 1).add(Duration(hours: index)),
    heartRateBpm: heartRate,
    movementIntensity: 0,
  );
}
