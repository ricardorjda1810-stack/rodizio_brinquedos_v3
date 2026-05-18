import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/session_timeline_models.dart';
import 'longitudinal_analysis_models.dart';

class SessionComparisonService {
  const SessionComparisonService();

  SessionComparisonResult compareSessions({
    List<SessionTimeline> sessions = const [],
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
  }) {
    final recoveryTrend = detectEvolutionTrend(
      recoveryProfiles.map((profile) => profile.recoveryRate * 100).toList(),
      higherIsBetter: true,
    );
    final resilienceTrend = detectEvolutionTrend(
      recoveryProfiles
          .map((profile) => profile.resilienceScore.toDouble())
          .toList(),
      higherIsBetter: true,
    );
    final escalationTrend = detectEvolutionTrend([
      ...trends.map((trend) => trend.escalationScore.toDouble()),
      ...forecasts.map((forecast) => forecast.escalationProbability),
    ], higherIsBetter: false);
    return SessionComparisonResult(
      comparedSessions: sessions.length,
      recoveryTrend: recoveryTrend,
      resilienceTrend: resilienceTrend,
      escalationTrend: escalationTrend,
      hasRecurringIncompleteRecovery:
          recoveryProfiles
              .where((profile) => profile.recoveryRate < 0.42)
              .length >=
          2,
      confidence: _confidence(
        sessions.length +
            trends.length +
            recoveryProfiles.length +
            forecasts.length,
      ),
    );
  }

  SessionComparisonResult comparePeriods({
    required List<SessionTimeline> earlierSessions,
    required List<SessionTimeline> laterSessions,
    List<AutonomicRecoveryProfile> earlierRecovery = const [],
    List<AutonomicRecoveryProfile> laterRecovery = const [],
    List<PhysiologicalTrend> earlierTrends = const [],
    List<PhysiologicalTrend> laterTrends = const [],
  }) {
    return SessionComparisonResult(
      comparedSessions: earlierSessions.length + laterSessions.length,
      recoveryTrend: _trendFromDelta(
        _average(
              laterRecovery
                  .map((profile) => profile.recoveryRate * 100)
                  .toList(),
            ) -
            _average(
              earlierRecovery
                  .map((profile) => profile.recoveryRate * 100)
                  .toList(),
            ),
        higherIsBetter: true,
      ),
      resilienceTrend: _trendFromDelta(
        _average(
              laterRecovery
                  .map((profile) => profile.resilienceScore.toDouble())
                  .toList(),
            ) -
            _average(
              earlierRecovery
                  .map((profile) => profile.resilienceScore.toDouble())
                  .toList(),
            ),
        higherIsBetter: true,
      ),
      escalationTrend: _trendFromDelta(
        _average(
              laterTrends
                  .map((trend) => trend.escalationScore.toDouble())
                  .toList(),
            ) -
            _average(
              earlierTrends
                  .map((trend) => trend.escalationScore.toDouble())
                  .toList(),
            ),
        higherIsBetter: false,
      ),
      hasRecurringIncompleteRecovery:
          laterRecovery
              .where((profile) => profile.recoveryRate < 0.42)
              .length >=
          2,
      confidence: _confidence(
        earlierSessions.length +
            laterSessions.length +
            earlierRecovery.length +
            laterRecovery.length +
            earlierTrends.length +
            laterTrends.length,
      ),
    );
  }

  LongitudinalEvolutionTrend detectEvolutionTrend(
    List<double> values, {
    required bool higherIsBetter,
  }) {
    if (values.length < 2) {
      return LongitudinalEvolutionTrend.stable;
    }
    final midpoint = values.length ~/ 2;
    final delta =
        _average(values.skip(midpoint).toList()) -
        _average(values.take(midpoint).toList());
    return _trendFromDelta(delta, higherIsBetter: higherIsBetter);
  }

  LongitudinalEvolutionTrend _trendFromDelta(
    double delta, {
    required bool higherIsBetter,
  }) {
    if (delta.abs() < 5) {
      return LongitudinalEvolutionTrend.stable;
    }
    final better = higherIsBetter ? delta > 0 : delta < 0;
    return better
        ? LongitudinalEvolutionTrend.improving
        : LongitudinalEvolutionTrend.worsening;
  }

  double _confidence(int dataPoints) {
    return (dataPoints * 8).clamp(0, 100).toDouble();
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }
}
