import '../core/crisis_detection/crisis_risk_result.dart';
import '../data/crisis_detection/crisis_risk_event.dart';
import '../data/crisis_detection/intervention_history_entry.dart';

class ResearchExportStatistics {
  final int totalCrises;
  final int totalInterventions;
  final int totalHighIntervention;
  final double averageScore;
  final double averageImprovement;
  final double perceivedImprovementRate;
  final double averageInterventionDurationSeconds;

  const ResearchExportStatistics({
    required this.totalCrises,
    required this.totalInterventions,
    required this.totalHighIntervention,
    required this.averageScore,
    required this.averageImprovement,
    required this.perceivedImprovementRate,
    required this.averageInterventionDurationSeconds,
  });

  factory ResearchExportStatistics.empty() {
    return const ResearchExportStatistics(
      totalCrises: 0,
      totalInterventions: 0,
      totalHighIntervention: 0,
      averageScore: 0,
      averageImprovement: 0,
      perceivedImprovementRate: 0,
      averageInterventionDurationSeconds: 0,
    );
  }

  factory ResearchExportStatistics.fromData({
    required List<CrisisRiskEvent> crisisEvents,
    required List<InterventionHistoryEntry> interventions,
  }) {
    final deltas = interventions
        .map((entry) => entry.scoreDelta)
        .whereType<int>()
        .toList();
    final improvedCount = interventions
        .where((entry) => entry.userReportedImprovement)
        .length;

    return ResearchExportStatistics(
      totalCrises: crisisEvents.length,
      totalInterventions: interventions.length,
      totalHighIntervention: crisisEvents
          .where((event) => event.level == CrisisRiskLevel.highIntervention)
          .length,
      averageScore: _average(crisisEvents.map((event) => event.score).toList()),
      averageImprovement: _average(deltas),
      perceivedImprovementRate: interventions.isEmpty
          ? 0
          : improvedCount / interventions.length,
      averageInterventionDurationSeconds: _average(
        interventions.map((entry) => entry.durationSeconds).toList(),
      ),
    );
  }

  static double _average(List<num> values) {
    if (values.isEmpty) {
      return 0;
    }

    return values.fold<double>(0, (sum, value) => sum + value) / values.length;
  }
}
