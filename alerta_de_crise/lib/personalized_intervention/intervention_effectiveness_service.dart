import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../contextual_triggers/contextual_event.dart';
import '../data/crisis_detection/intervention_history_entry.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import 'personalized_intervention_models.dart';

class InterventionEffectivenessService {
  const InterventionEffectivenessService();

  List<InterventionEffectivenessResult> analyzeInterventionEffectiveness({
    List<InterventionHistoryEntry> interventions = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
    List<ContextualEvent> contextEvents = const [],
  }) {
    final grouped = <String, List<InterventionHistoryEntry>>{};
    for (final intervention in interventions) {
      grouped.putIfAbsent(intervention.protocolId, () => []).add(intervention);
    }

    final results = <InterventionEffectivenessResult>[];
    for (final entry in grouped.entries) {
      final items = entry.value;
      final successRate =
          items.where((item) => item.userReportedImprovement).length /
          items.length *
          100;
      final recoveryBenefit = calculateRecoveryBenefit(
        interventions: items,
        recoveryProfiles: recoveryProfiles,
      );
      final contextualPerformance = calculateContextualPerformance(
        interventions: items,
        contextEvents: contextEvents,
      );
      final escalationReduction = _average(
        items
            .map((item) => item.scoreDelta)
            .whereType<int>()
            .map((delta) => (-delta).clamp(0, 100).toDouble())
            .toList(),
      );
      final recoverySpeed = _recoverySpeed(items);
      final forecastPressure = _average(
        forecasts.map((forecast) => forecast.escalationProbability).toList(),
      );
      final effectivenessScore =
          (successRate * 0.28) +
          (recoveryBenefit * 0.27) +
          (escalationReduction * 0.22) +
          (recoverySpeed * 0.13) +
          (contextualPerformance * 0.1) -
          (forecastPressure * 0.04);

      results.add(
        InterventionEffectivenessResult(
          interventionType: entry.key,
          effectivenessScore: effectivenessScore.clamp(0, 100).toDouble(),
          successRate: successRate.clamp(0, 100).toDouble(),
          recoveryBenefit: recoveryBenefit,
          escalationReduction: escalationReduction,
          recoverySpeed: recoverySpeed,
          contextualPerformance: contextualPerformance,
          confidence: _confidence(items.length, recoveryProfiles.length),
        ),
      );
    }

    results.sort(
      (a, b) => b.effectivenessScore.compareTo(a.effectivenessScore),
    );
    return List.unmodifiable(results);
  }

  double calculateRecoveryBenefit({
    required List<InterventionHistoryEntry> interventions,
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
  }) {
    final scoreBenefit = _average(
      interventions
          .map((item) => item.scoreDelta)
          .whereType<int>()
          .map((delta) => (-delta).clamp(0, 100).toDouble())
          .toList(),
    );
    final nearbyRecovery = _average(
      recoveryProfiles.map((profile) {
        final efficiency =
            (profile.recoveryRate * 45) +
            (profile.heartRateNormalization * 30) +
            (profile.resilienceScore * 0.25) -
            (profile.fatigueScore * 0.15);
        return efficiency.clamp(0, 100).toDouble();
      }).toList(),
    );
    if (scoreBenefit == 0 && nearbyRecovery == 0) {
      return 0;
    }
    return ((scoreBenefit * 0.62) + (nearbyRecovery * 0.38))
        .clamp(0, 100)
        .toDouble();
  }

  double calculateContextualPerformance({
    required List<InterventionHistoryEntry> interventions,
    List<ContextualEvent> contextEvents = const [],
  }) {
    if (interventions.isEmpty) {
      return 0;
    }
    final associatedCount = interventions.where((intervention) {
      return contextEvents.any(
        (event) =>
            !event.timestamp.isAfter(intervention.completedAt) &&
            intervention.completedAt.difference(event.timestamp) <=
                const Duration(hours: 2),
      );
    }).length;
    final associationScore = associatedCount / interventions.length * 100;
    final improvementScore =
        interventions.where((item) => item.userReportedImprovement).length /
        interventions.length *
        100;
    return ((associationScore * 0.45) + (improvementScore * 0.55))
        .clamp(0, 100)
        .toDouble();
  }

  double _recoverySpeed(List<InterventionHistoryEntry> interventions) {
    final values = interventions.map((item) {
      if (item.durationSeconds <= 0) {
        return 0.0;
      }
      final minutes = item.durationSeconds / 60;
      return (100 - (minutes * 8)).clamp(0, 100).toDouble();
    }).toList();
    return _average(values);
  }

  double _confidence(int usageCount, int recoveryCount) {
    return ((usageCount * 18) + (recoveryCount * 8)).clamp(0, 100).toDouble();
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }
}
