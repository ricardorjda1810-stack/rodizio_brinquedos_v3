import 'dart:convert';

import 'package:drift/drift.dart';

import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../contextual_triggers/contextual_event.dart';
import '../data/crisis_detection/intervention_history_entry.dart';
import '../database/signalflow_database.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import 'intervention_effectiveness_service.dart';
import 'personalized_intervention_models.dart';

class InterventionAdaptationService {
  final SignalFlowDatabase _database;
  final InterventionEffectivenessService _effectivenessService;
  final DateTime Function() _now;

  InterventionAdaptationService({
    SignalFlowDatabase? database,
    InterventionEffectivenessService effectivenessService =
        const InterventionEffectivenessService(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _effectivenessService = effectivenessService,
       _now = now ?? DateTime.now;

  Future<List<ContextualInterventionRecommendation>> generateRecommendations({
    List<InterventionHistoryEntry> interventions = const [],
    List<InterventionLearningProfile>? profiles,
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
    List<ContextualEvent> contextEvents = const [],
    List<PhysiologicalTrend> trends = const [],
    bool persist = false,
  }) async {
    final sourceProfiles =
        profiles ??
        _effectivenessService
            .analyzeInterventionEffectiveness(
              interventions: interventions,
              recoveryProfiles: recoveryProfiles,
              forecasts: forecasts,
              contextEvents: contextEvents,
            )
            .map(
              (result) => updateLearningProfile(
                interventionType: result.interventionType,
                interventions: interventions
                    .where((item) => item.protocolId == result.interventionType)
                    .toList(growable: false),
                effectiveness: result,
                contextEvents: contextEvents,
              ),
            )
            .toList(growable: false);

    final recommendations = sourceProfiles
        .map((profile) {
          final expectedRecoveryBenefit = _expectedRecoveryBenefit(
            profile,
            recoveryProfiles,
          );
          final physiologicalPressure = _physiologicalPressure(
            forecasts: forecasts,
            trends: trends,
            recoveryProfiles: recoveryProfiles,
          );
          final contextualFit = _contextualFit(profile, contextEvents);
          final score =
              (profile.successRate * 0.24) +
              (profile.averageRecoveryImprovement * 0.24) +
              (contextualFit * 0.18) +
              (expectedRecoveryBenefit * 0.18) +
              (profile.confidence * 0.12) +
              (physiologicalPressure * 0.04);

          return ContextualInterventionRecommendation(
            interventionType: profile.interventionType,
            recommendationScore: score.clamp(0, 100).toDouble(),
            expectedRecoveryBenefit: expectedRecoveryBenefit,
            confidence:
                ((profile.confidence * 0.72) +
                        (_dataConfidence(
                              recoveryProfiles: recoveryProfiles,
                              forecasts: forecasts,
                              contextEvents: contextEvents,
                              trends: trends,
                            ) *
                            0.28))
                    .clamp(0, 100)
                    .toDouble(),
            contextualFactors: _contextualFactors(contextEvents, contextualFit),
            physiologicalFactors: _physiologicalFactors(forecasts, trends),
            recoveryFactors: _recoveryFactors(recoveryProfiles),
          );
        })
        .toList(growable: false);

    final ranked = rankInterventions(recommendations);
    if (persist) {
      await persistProfiles(sourceProfiles);
      await persistRecommendations(ranked);
    }
    return ranked;
  }

  InterventionLearningProfile updateLearningProfile({
    required String interventionType,
    required List<InterventionHistoryEntry> interventions,
    InterventionEffectivenessResult? effectiveness,
    List<ContextualEvent> contextEvents = const [],
  }) {
    final result =
        effectiveness ??
        _effectivenessService
            .analyzeInterventionEffectiveness(
              interventions: interventions,
              contextEvents: contextEvents,
            )
            .firstWhere(
              (item) => item.interventionType == interventionType,
              orElse: () => InterventionEffectivenessResult(
                interventionType: interventionType,
                effectivenessScore: 0,
                successRate: 0,
                recoveryBenefit: 0,
                escalationReduction: 0,
                recoverySpeed: 0,
                contextualPerformance: 0,
                confidence: 0,
              ),
            );

    final averageRecoveryTime = interventions.isEmpty
        ? Duration.zero
        : Duration(
            seconds:
                interventions
                    .map((item) => item.durationSeconds)
                    .fold<int>(0, (sum, value) => sum + value) ~/
                interventions.length,
          );

    return InterventionLearningProfile(
      interventionType: interventionType,
      successRate: result.successRate,
      averageRecoveryTime: averageRecoveryTime,
      averageRecoveryImprovement: result.recoveryBenefit,
      contextualPerformance: _contextualPerformanceMap(
        interventions: interventions,
        contextEvents: contextEvents,
      ),
      circadianPerformance: _circadianPerformanceMap(interventions),
      confidence: result.confidence,
      usageCount: interventions.length,
      updatedAt: _now(),
    );
  }

  List<ContextualInterventionRecommendation> rankInterventions(
    List<ContextualInterventionRecommendation> recommendations,
  ) {
    final ranked = [...recommendations]
      ..sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));
    return List.unmodifiable(ranked);
  }

  List<PhysiologicalEventMarker> buildOptionalMarkers({
    required List<ContextualInterventionRecommendation> recommendations,
    required String timelineId,
  }) {
    final markers = <PhysiologicalEventMarker>[];
    if (recommendations.isEmpty) {
      return markers;
    }
    final best = recommendations.first;
    final timestamp = _now();
    if (best.recommendationScore >= 65) {
      markers.add(
        _marker(
          timelineId: timelineId,
          timestamp: timestamp,
          type: EventType.interventionEffective,
          title: 'Intervenção observada com boa resposta',
          description:
              'Padrões de recuperação sugerem resposta fisiológica favorável para ${best.interventionType}.',
          severity: Severity.low,
        ),
      );
    }
    if (best.recommendationScore < 35) {
      markers.add(
        _marker(
          timelineId: timelineId,
          timestamp: timestamp,
          type: EventType.interventionLowEffect,
          title: 'Baixo efeito observado',
          description:
              'Intervenções observadas ainda têm benefício limitado nos padrões de recuperação.',
          severity: Severity.medium,
        ),
      );
    }
    markers.add(
      _marker(
        timelineId: timelineId,
        timestamp: timestamp,
        type: EventType.contextualRecommendationGenerated,
        title: 'Sugestão contextual gerada',
        description:
            'Adaptação experimental baseada em contexto, histórico e resposta fisiológica.',
        severity: Severity.low,
      ),
    );
    return List.unmodifiable(markers);
  }

  Future<void> persistProfiles(
    List<InterventionLearningProfile> profiles,
  ) async {
    for (final profile in profiles) {
      await _database
          .into(_database.interventionLearningProfilesTable)
          .insertOnConflictUpdate(
            InterventionLearningProfilesTableCompanion.insert(
              interventionType: profile.interventionType,
              successRate: profile.successRate,
              averageRecoveryTimeSeconds: profile.averageRecoveryTime.inSeconds,
              averageRecoveryImprovement: profile.averageRecoveryImprovement,
              contextualPerformanceJson: jsonEncode(
                profile.contextualPerformance,
              ),
              circadianPerformanceJson: jsonEncode(
                profile.circadianPerformance.map(
                  (key, value) => MapEntry(key.toString(), value),
                ),
              ),
              confidence: profile.confidence,
              usageCount: profile.usageCount,
              updatedAt: profile.updatedAt,
              safetyCopy: profile.safetyCopy,
            ),
          );
    }
  }

  Future<void> persistRecommendations(
    List<ContextualInterventionRecommendation> recommendations,
  ) async {
    final generatedAt = _now();
    for (final recommendation in recommendations) {
      await _database
          .into(_database.contextualInterventionRecommendationsTable)
          .insertOnConflictUpdate(
            ContextualInterventionRecommendationsTableCompanion.insert(
              id: 'intervention-recommendation-${recommendation.interventionType}-${generatedAt.microsecondsSinceEpoch}',
              generatedAt: generatedAt,
              interventionType: recommendation.interventionType,
              recommendationScore: recommendation.recommendationScore,
              expectedRecoveryBenefit: recommendation.expectedRecoveryBenefit,
              confidence: recommendation.confidence,
              contextualFactorsJson: jsonEncode(
                recommendation.contextualFactors,
              ),
              physiologicalFactorsJson: jsonEncode(
                recommendation.physiologicalFactors,
              ),
              recoveryFactorsJson: jsonEncode(recommendation.recoveryFactors),
              safetyCopy: recommendation.safetyCopy,
            ),
          );
    }
  }

  Future<List<InterventionLearningProfile>> loadProfiles() async {
    final rows = await _database
        .select(_database.interventionLearningProfilesTable)
        .get();
    return rows.map(_profileFromRow).toList(growable: false);
  }

  Future<List<ContextualInterventionRecommendation>> loadRecommendations({
    int limit = 20,
  }) async {
    final query =
        _database.select(_database.contextualInterventionRecommendationsTable)
          ..orderBy([
            (table) => OrderingTerm(
              expression: table.generatedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit);
    final rows = await query.get();
    return rows.map(_recommendationFromRow).toList(growable: false);
  }

  InterventionLearningProfile _profileFromRow(
    InterventionLearningProfilesTableData row,
  ) {
    final contextual = (jsonDecode(row.contextualPerformanceJson) as Map).map(
      (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
    );
    final circadian = (jsonDecode(row.circadianPerformanceJson) as Map).map(
      (key, value) =>
          MapEntry(int.parse(key.toString()), (value as num).toDouble()),
    );
    return InterventionLearningProfile(
      interventionType: row.interventionType,
      successRate: row.successRate,
      averageRecoveryTime: Duration(seconds: row.averageRecoveryTimeSeconds),
      averageRecoveryImprovement: row.averageRecoveryImprovement,
      contextualPerformance: contextual,
      circadianPerformance: circadian,
      confidence: row.confidence,
      usageCount: row.usageCount,
      updatedAt: row.updatedAt,
    );
  }

  ContextualInterventionRecommendation _recommendationFromRow(
    ContextualInterventionRecommendationsTableData row,
  ) {
    return ContextualInterventionRecommendation(
      interventionType: row.interventionType,
      recommendationScore: row.recommendationScore,
      expectedRecoveryBenefit: row.expectedRecoveryBenefit,
      confidence: row.confidence,
      contextualFactors: (jsonDecode(row.contextualFactorsJson) as List)
          .cast<String>(),
      physiologicalFactors: (jsonDecode(row.physiologicalFactorsJson) as List)
          .cast<String>(),
      recoveryFactors: (jsonDecode(row.recoveryFactorsJson) as List)
          .cast<String>(),
    );
  }

  double _expectedRecoveryBenefit(
    InterventionLearningProfile profile,
    List<AutonomicRecoveryProfile> recoveryProfiles,
  ) {
    final fatigue = _average(
      recoveryProfiles
          .map((profile) => profile.fatigueScore.toDouble())
          .toList(),
    );
    final fatigueAdjustment = fatigue >= 55 ? 8 : 0;
    return (profile.averageRecoveryImprovement + fatigueAdjustment)
        .clamp(0, 100)
        .toDouble();
  }

  double _physiologicalPressure({
    required List<EscalationForecast> forecasts,
    required List<PhysiologicalTrend> trends,
    required List<AutonomicRecoveryProfile> recoveryProfiles,
  }) {
    final forecast = _average(
      forecasts.map((item) => item.escalationProbability).toList(),
    );
    final trend = _average(
      trends.map((item) => item.escalationScore.toDouble()).toList(),
    );
    final fatigue = _average(
      recoveryProfiles.map((item) => item.fatigueScore.toDouble()).toList(),
    );
    return ((forecast * 0.36) + (trend * 0.34) + (fatigue * 0.3))
        .clamp(0, 100)
        .toDouble();
  }

  double _contextualFit(
    InterventionLearningProfile profile,
    List<ContextualEvent> contextEvents,
  ) {
    if (contextEvents.isEmpty) {
      return _average(profile.contextualPerformance.values.toList());
    }
    final values = contextEvents
        .map((event) => profile.contextualPerformance[event.category.name] ?? 0)
        .toList();
    return _average(values);
  }

  double _dataConfidence({
    required List<AutonomicRecoveryProfile> recoveryProfiles,
    required List<EscalationForecast> forecasts,
    required List<ContextualEvent> contextEvents,
    required List<PhysiologicalTrend> trends,
  }) {
    return ((recoveryProfiles.length * 12) +
            (forecasts.length * 10) +
            (contextEvents.length * 8) +
            (trends.length * 8))
        .clamp(0, 100)
        .toDouble();
  }

  List<String> _contextualFactors(
    List<ContextualEvent> contextEvents,
    double contextualFit,
  ) {
    final factors = <String>['sugestões contextuais'];
    if (contextEvents.isNotEmpty) {
      factors.add(
        'contexto atual: ${contextEvents.map((event) => event.category.name).toSet().join(', ')}',
      );
    }
    if (contextualFit >= 50) {
      factors.add('padrões observados em contexto semelhante');
    }
    return List.unmodifiable(factors);
  }

  List<String> _physiologicalFactors(
    List<EscalationForecast> forecasts,
    List<PhysiologicalTrend> trends,
  ) {
    final factors = <String>['resposta fisiológica observada'];
    if (_average(
          forecasts.map((item) => item.escalationProbability).toList(),
        ) >=
        55) {
      factors.add('probabilidade elevada de escalada fisiológica');
    }
    if (_average(
          trends.map((item) => item.escalationScore.toDouble()).toList(),
        ) >=
        55) {
      factors.add('tendência fisiológica acima do padrão');
    }
    return List.unmodifiable(factors);
  }

  List<String> _recoveryFactors(
    List<AutonomicRecoveryProfile> recoveryProfiles,
  ) {
    final factors = <String>['padrões de recuperação'];
    if (_average(
          recoveryProfiles.map((item) => item.fatigueScore.toDouble()).toList(),
        ) >=
        55) {
      factors.add('fadiga autonômica observada');
    }
    if (_average(
          recoveryProfiles.map((item) => item.recoveryRate * 100).toList(),
        ) >=
        55) {
      factors.add('recuperação recente favorável');
    }
    return List.unmodifiable(factors);
  }

  Map<String, double> _contextualPerformanceMap({
    required List<InterventionHistoryEntry> interventions,
    required List<ContextualEvent> contextEvents,
  }) {
    final map = <String, double>{};
    for (final category in ContextualCategory.values) {
      final events = contextEvents
          .where((event) => event.category == category)
          .toList(growable: false);
      if (events.isEmpty) {
        continue;
      }
      final associated = interventions
          .where((intervention) {
            return events.any(
              (event) =>
                  !event.timestamp.isAfter(intervention.completedAt) &&
                  intervention.completedAt.difference(event.timestamp) <=
                      const Duration(hours: 2),
            );
          })
          .toList(growable: false);
      if (associated.isEmpty) {
        continue;
      }
      map[category.name] =
          associated.where((item) => item.userReportedImprovement).length /
          associated.length *
          100;
    }
    return Map.unmodifiable(map);
  }

  Map<int, double> _circadianPerformanceMap(
    List<InterventionHistoryEntry> interventions,
  ) {
    final grouped = <int, List<InterventionHistoryEntry>>{};
    for (final intervention in interventions) {
      grouped
          .putIfAbsent(intervention.startedAt.hour, () => [])
          .add(intervention);
    }
    return Map.unmodifiable(
      grouped.map(
        (hour, items) => MapEntry(
          hour,
          items.where((item) => item.userReportedImprovement).length /
              items.length *
              100,
        ),
      ),
    );
  }

  PhysiologicalEventMarker _marker({
    required String timelineId,
    required DateTime timestamp,
    required EventType type,
    required String title,
    required String description,
    required Severity severity,
  }) {
    return PhysiologicalEventMarker(
      id: '$timelineId-${type.name}-${timestamp.microsecondsSinceEpoch}',
      timestamp: timestamp,
      type: type,
      title: title,
      description: description,
      severity: severity,
      source: 'personalized_intervention',
    );
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }
}
