import '../core/crisis_detection/crisis_risk_result.dart';
import '../core/crisis_detection/physiological_sample.dart';

class CsvReplayStatistics {
  final double averageScore;
  final int highestScore;
  final int mildAttentionCount;
  final int moderateAlertCount;
  final int highInterventionCount;
  final double averageHeartRate;
  final double? averageHrv;

  const CsvReplayStatistics({
    required this.averageScore,
    required this.highestScore,
    required this.mildAttentionCount,
    required this.moderateAlertCount,
    required this.highInterventionCount,
    required this.averageHeartRate,
    required this.averageHrv,
  });

  factory CsvReplayStatistics.empty() {
    return const CsvReplayStatistics(
      averageScore: 0,
      highestScore: 0,
      mildAttentionCount: 0,
      moderateAlertCount: 0,
      highInterventionCount: 0,
      averageHeartRate: 0,
      averageHrv: null,
    );
  }

  factory CsvReplayStatistics.fromResults({
    required List<PhysiologicalSample> samples,
    required List<CrisisRiskResult> results,
  }) {
    if (samples.isEmpty || results.isEmpty) {
      return CsvReplayStatistics.empty();
    }

    final scores = results.map((result) => result.score).toList();
    final hrvValues = samples
        .map((sample) => sample.hrvRmssdMs)
        .whereType<double>()
        .toList();

    return CsvReplayStatistics(
      averageScore: _average(scores),
      highestScore: scores.reduce((a, b) => a > b ? a : b),
      mildAttentionCount: _countLevel(results, CrisisRiskLevel.mildAttention),
      moderateAlertCount: _countLevel(results, CrisisRiskLevel.moderateAlert),
      highInterventionCount: _countLevel(
        results,
        CrisisRiskLevel.highIntervention,
      ),
      averageHeartRate: _average(
        samples.map((sample) => sample.heartRateBpm).toList(),
      ),
      averageHrv: hrvValues.isEmpty ? null : _average(hrvValues),
    );
  }

  static int _countLevel(
    List<CrisisRiskResult> results,
    CrisisRiskLevel level,
  ) {
    return results.where((result) => result.level == level).length;
  }

  static double _average(List<num> values) {
    if (values.isEmpty) {
      return 0;
    }

    return values.fold<double>(0, (sum, value) => sum + value) / values.length;
  }
}
