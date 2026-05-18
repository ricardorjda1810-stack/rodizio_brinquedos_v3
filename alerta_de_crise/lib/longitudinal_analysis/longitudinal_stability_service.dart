import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../session_timeline/session_timeline_models.dart';

class LongitudinalStabilityService {
  const LongitudinalStabilityService();

  double calculateStability({
    List<SessionTimeline> sessions = const [],
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
  }) {
    final heartRateStability = _stabilityFromValues(
      sessions.map((session) => session.averageHeartRate).whereType<double>(),
    );
    final hrvStability = _stabilityFromValues(
      sessions.map((session) => session.averageHrv).whereType<double>(),
    );
    final escalationStability = _stabilityFromValues(
      trends.map((trend) => trend.escalationScore.toDouble()),
    );
    final recoveryStability = _stabilityFromValues(
      recoveryProfiles.map((profile) => profile.recoveryRate * 100),
    );
    final values = [
      heartRateStability,
      hrvStability,
      escalationStability,
      recoveryStability,
    ].where((value) => value > 0).toList();
    return _average(values).clamp(0, 100).toDouble();
  }

  double calculateVariability({
    List<SessionTimeline> sessions = const [],
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
  }) {
    final heartRateVariability = _normalizedSpread(
      sessions.map((session) => session.averageHeartRate).whereType<double>(),
    );
    final hrvVariability = _normalizedSpread(
      sessions.map((session) => session.averageHrv).whereType<double>(),
    );
    final escalationVariability = _normalizedSpread(
      trends.map((trend) => trend.escalationScore.toDouble()),
    );
    final fatigueVariability = _normalizedSpread(
      recoveryProfiles.map((profile) => profile.fatigueScore.toDouble()),
    );
    return _average([
      heartRateVariability,
      hrvVariability,
      escalationVariability,
      fatigueVariability,
    ]).clamp(0, 100).toDouble();
  }

  bool detectPersistentDrift({
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
  }) {
    final escalationSlope = _slope(
      trends.map((trend) => trend.escalationScore.toDouble()).toList(),
    );
    final fatigueSlope = _slope(
      recoveryProfiles
          .map((profile) => profile.fatigueScore.toDouble())
          .toList(),
    );
    final recoverySlope = _slope(
      recoveryProfiles.map((profile) => profile.recoveryRate * 100).toList(),
    );
    return escalationSlope > 6 || fatigueSlope > 6 || recoverySlope < -6;
  }

  double calculateCircadianConsistency(List<SessionTimeline> sessions) {
    if (sessions.length < 2) {
      return sessions.isEmpty ? 0 : 55;
    }
    final hours = sessions.map((session) => session.startedAt.hour.toDouble());
    return _stabilityFromValues(hours);
  }

  double _stabilityFromValues(Iterable<double> source) {
    final values = source.toList();
    if (values.length < 2) {
      return values.isEmpty ? 0 : 80;
    }
    return (100 - _normalizedSpread(values)).clamp(0, 100).toDouble();
  }

  double _normalizedSpread(Iterable<double> source) {
    final values = source.toList();
    if (values.length < 2) {
      return 0;
    }
    final average = _average(values).abs();
    if (average == 0) {
      return 0;
    }
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    return ((max - min).abs() / average * 100).clamp(0, 100).toDouble();
  }

  double _slope(List<double> values) {
    if (values.length < 2) {
      return 0;
    }
    final midpoint = values.length ~/ 2;
    final first = _average(values.take(midpoint).toList());
    final second = _average(values.skip(midpoint).toList());
    return second - first;
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }
}
