import 'experimental_study_models.dart';

class StudyMetricsService {
  const StudyMetricsService();

  StudyMetrics calculateStudyMetrics({
    required List<ExperimentalStudySession> sessions,
    List<double> recoveryScores = const [],
    List<double> falseEscalationRates = const [],
    List<double> sensorReliabilityScores = const [],
  }) {
    return StudyMetrics(
      recoveryEfficiency: _averageOrDefault(recoveryScores, 0),
      falseEscalationRate: _averageOrDefault(falseEscalationRates, 0),
      multimodalAgreement: _averageOrDefault(
        sessions.map((session) => session.multimodalConsensusScore),
        0,
      ),
      resilienceTrend: calculateLongitudinalMetrics(recoveryScores),
      protocolCompletionRate: _completionRate(sessions),
      sensorReliability: _averageOrDefault(sensorReliabilityScores, 0),
      benchmarkConsistency: calculateStudyConsistency(sessions),
    );
  }

  double calculateLongitudinalMetrics(List<double> values) {
    if (values.length < 2) return values.isEmpty ? 0 : values.first;
    return (values.last - values.first + 50).clamp(0, 100).toDouble();
  }

  double calculateStudyConsistency(List<ExperimentalStudySession> sessions) {
    if (sessions.isEmpty) return 0;
    final benchmarkCount = sessions
        .where((session) => session.benchmarkGenerated)
        .length;
    final replayCount = sessions
        .where((session) => session.replayGenerated)
        .length;
    return (((benchmarkCount + replayCount) / (sessions.length * 2)) * 100)
        .clamp(0, 100)
        .toDouble();
  }

  double _completionRate(List<ExperimentalStudySession> sessions) {
    if (sessions.isEmpty) return 0;
    final completed = sessions.where((session) => session.success).length;
    return ((completed / sessions.length) * 100).clamp(0, 100).toDouble();
  }

  double _averageOrDefault(Iterable<double> values, double fallback) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return fallback;
    return list.fold<double>(0, (sum, value) => sum + value) / list.length;
  }
}
