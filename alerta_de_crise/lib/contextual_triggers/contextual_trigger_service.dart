import 'dart:convert';

import 'package:drift/drift.dart';

import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../database/signalflow_database.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import 'behavioral_correlation_service.dart';
import 'contextual_event.dart';
import 'contextual_trigger_models.dart';

class ContextualTriggerService {
  final SignalFlowDatabase _database;
  final BehavioralCorrelationService _correlationService;
  final DateTime Function() _now;

  ContextualTriggerService({
    SignalFlowDatabase? database,
    BehavioralCorrelationService correlationService =
        const BehavioralCorrelationService(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _correlationService = correlationService,
       _now = now ?? DateTime.now;

  Future<ContextualEvent> registerEvent({
    String? id,
    DateTime? timestamp,
    required ContextualCategory category,
    required String label,
    String description = '',
    ContextualIntensity intensity = ContextualIntensity.medium,
    String source = 'manual',
  }) async {
    final eventTime = timestamp ?? _now();
    final event = ContextualEvent(
      id: id ?? 'context-${eventTime.microsecondsSinceEpoch}',
      timestamp: eventTime,
      category: category,
      label: label,
      description: description,
      intensity: intensity,
      source: source,
    );
    await persistEvent(event);
    return event;
  }

  Future<void> persistEvent(ContextualEvent event) async {
    await _database
        .into(_database.contextualEventsTable)
        .insertOnConflictUpdate(
          ContextualEventsTableCompanion.insert(
            id: event.id,
            timestamp: event.timestamp,
            category: event.category.name,
            label: event.label,
            description: event.description,
            intensity: event.intensity.name,
            source: event.source,
          ),
        );
  }

  Future<List<ContextualEvent>> loadRecentEvents({int limit = 30}) async {
    final query = _database.select(_database.contextualEventsTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.timestamp, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_eventFromRow).toList(growable: false);
  }

  List<PhysiologicalEventMarker> buildOptionalMarkers({
    required List<ContextualTriggerCorrelation> correlations,
    required String timelineId,
  }) {
    final markers = <PhysiologicalEventMarker>[];
    for (final correlation in correlations.take(3)) {
      final timestamp = correlation.lastOccurrence ?? _now();
      if (correlation.occurrenceCount >= 3) {
        markers.add(
          _marker(
            timelineId: timelineId,
            timestamp: timestamp,
            type: EventType.repeatedContextTrigger,
            title: 'Contexto recorrente observado',
            description:
                'Padrões observados de ${correlation.category.name}; gatilhos potenciais não indicam causalidade.',
            severity: Severity.low,
          ),
        );
      }
      if (correlation.escalationCorrelation >= 55) {
        markers.add(
          _marker(
            timelineId: timelineId,
            timestamp: timestamp,
            type: EventType.contextualEscalationPattern,
            title: 'Correlação contexto-fisiologia',
            description:
                'Correlação experimental entre contexto e sinais fisiológicos de escalada.',
            severity: Severity.medium,
          ),
        );
      }
      if (correlation.recoveryImpact >= 50) {
        markers.add(
          _marker(
            timelineId: timelineId,
            timestamp: timestamp,
            type: EventType.recoveryContextAssociation,
            title: 'Associação contexto-recuperação',
            description:
                'Padrões observados sugerem associação contextual com recuperação autonômica.',
            severity: Severity.low,
          ),
        );
      }
    }
    return List.unmodifiable(markers);
  }

  Future<List<ContextualTriggerCorrelation>> consolidatePatterns({
    List<ContextualEvent>? events,
    List<PhysiologicalEventMarker> markers = const [],
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
    bool persist = false,
  }) async {
    final sourceEvents = events ?? await loadRecentEvents(limit: 200);
    final correlations = _correlationService.analyzeCorrelations(
      events: sourceEvents,
      markers: markers,
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      forecasts: forecasts,
    );
    if (persist) {
      await persistCorrelations(correlations);
    }
    return correlations;
  }

  Future<void> persistCorrelations(
    List<ContextualTriggerCorrelation> correlations,
  ) async {
    final generatedAt = _now();
    for (final correlation in correlations) {
      await _database
          .into(_database.contextualTriggerCorrelationsTable)
          .insertOnConflictUpdate(
            ContextualTriggerCorrelationsTableCompanion.insert(
              id: 'context-correlation-${correlation.category.name}-${generatedAt.microsecondsSinceEpoch}',
              generatedAt: generatedAt,
              category: correlation.category.name,
              occurrenceCount: correlation.occurrenceCount,
              escalationCorrelation: correlation.escalationCorrelation,
              recoveryImpact: correlation.recoveryImpact,
              confidence: correlation.confidence,
              lastOccurrence: Value(correlation.lastOccurrence),
              associatedMarkersJson: jsonEncode(
                correlation.associatedMarkers
                    .map((marker) => marker.id)
                    .toList(),
              ),
              safetyCopy: correlation.safetyCopy,
            ),
          );
    }
  }

  Future<List<ContextualTriggerCorrelation>> loadCorrelations({
    int limit = 20,
  }) async {
    final query = _database.select(_database.contextualTriggerCorrelationsTable)
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.generatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_correlationFromRow).toList(growable: false);
  }

  ContextualEvent _eventFromRow(ContextualEventsTableData row) {
    return ContextualEvent(
      id: row.id,
      timestamp: row.timestamp,
      category: ContextualCategory.values.byName(row.category),
      label: row.label,
      description: row.description,
      intensity: ContextualIntensity.values.byName(row.intensity),
      source: row.source,
    );
  }

  ContextualTriggerCorrelation _correlationFromRow(
    ContextualTriggerCorrelationsTableData row,
  ) {
    return ContextualTriggerCorrelation(
      category: ContextualCategory.values.byName(row.category),
      occurrenceCount: row.occurrenceCount,
      escalationCorrelation: row.escalationCorrelation,
      recoveryImpact: row.recoveryImpact,
      confidence: row.confidence,
      lastOccurrence: row.lastOccurrence,
      associatedMarkers: const [],
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
      source: 'contextual_triggers',
    );
  }
}
