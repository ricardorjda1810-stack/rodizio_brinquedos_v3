import 'package:drift/drift.dart';

import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../contextual_triggers/contextual_trigger_models.dart';
import '../database/signalflow_database.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import 'cognitive_feedback_models.dart';
import 'feedback_correlation_service.dart';
import 'perceived_state_models.dart';

class SubjectiveFeedbackService {
  final SignalFlowDatabase _database;
  final FeedbackCorrelationService _correlationService;
  final DateTime Function() _now;

  SubjectiveFeedbackService({
    SignalFlowDatabase? database,
    FeedbackCorrelationService correlationService =
        const FeedbackCorrelationService(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _correlationService = correlationService,
       _now = now ?? DateTime.now;

  Future<SubjectiveFeedbackEntry> submitFeedback({
    required PerceivedState perceivedState,
    List<String> contextualFactors = const [],
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<ContextualTriggerCorrelation> contextualCorrelations = const [],
    List<EscalationForecast> forecasts = const [],
    List<SubjectiveFeedbackEntry> history = const [],
    List<PhysiologicalEventMarker> relatedMarkers = const [],
    bool persist = true,
  }) async {
    final generatedAt = _now();
    final normalized = perceivedState.normalized();
    final correlation = _correlationService.correlateFeedback(
      perceivedState: normalized,
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      contextualCorrelations: contextualCorrelations,
      forecasts: forecasts,
      history: history,
    );
    final entry = SubjectiveFeedbackEntry(
      id: 'subjective-${generatedAt.microsecondsSinceEpoch}',
      generatedAt: generatedAt,
      perceivedState: normalized,
      contextualFactors: contextualFactors,
      physiologicalCorrelation: correlation.subjectiveCorrelation,
      confidence: correlation.confidence,
      relatedMarkers: relatedMarkers,
    );
    if (persist) {
      await persistFeedback(entry);
    }
    return entry;
  }

  Future<void> persistFeedback(SubjectiveFeedbackEntry entry) async {
    await _database
        .into(_database.subjectiveFeedbackEntriesTable)
        .insertOnConflictUpdate(_companionFor(entry));
  }

  Future<List<SubjectiveFeedbackEntry>> loadFeedback({int limit = 20}) async {
    final query = _database.select(_database.subjectiveFeedbackEntriesTable)
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.generatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  SubjectiveFeedbackSummary generateFeedbackSummary(
    List<SubjectiveFeedbackEntry> entries,
  ) {
    return SubjectiveFeedbackSummary(
      generatedAt: _now(),
      entryCount: entries.length,
      averagePerceivedStress: _average(
        entries.map((entry) => entry.perceivedState.perceivedStress.toDouble()),
      ),
      averagePerceivedFatigue: _average(
        entries.map(
          (entry) => entry.perceivedState.perceivedFatigue.toDouble(),
        ),
      ),
      averagePerceivedRecovery: _average(
        entries.map(
          (entry) => entry.perceivedState.perceivedRecovery.toDouble(),
        ),
      ),
      averagePhysiologicalCorrelation: _average(
        entries.map((entry) => entry.physiologicalCorrelation),
      ),
      patterns: [
        if (entries.any((entry) => entry.perceivedState.perceivedStress >= 7))
          'percepção subjetiva de stress elevada',
        if (entries
                .where((entry) => entry.perceivedState.perceivedFatigue >= 7)
                .length >=
            2)
          'fadiga subjetiva recorrente',
        if (entries.any((entry) => entry.perceivedState.perceivedRecovery >= 7))
          'recovery percebida por autoavaliação',
      ],
    );
  }

  double calculatePerceivedRecovery(List<SubjectiveFeedbackEntry> entries) {
    if (entries.isEmpty) return 0;
    return _average(
          entries.map(
            (entry) => entry.perceivedState.perceivedRecovery.toDouble(),
          ),
        ) *
        10;
  }

  SubjectiveFeedbackEntriesTableCompanion _companionFor(
    SubjectiveFeedbackEntry entry,
  ) {
    return SubjectiveFeedbackEntriesTableCompanion.insert(
      id: entry.id,
      generatedAt: entry.generatedAt,
      perceivedTimestamp: entry.perceivedState.timestamp,
      perceivedStress: entry.perceivedState.perceivedStress,
      perceivedFatigue: entry.perceivedState.perceivedFatigue,
      perceivedControl: entry.perceivedState.perceivedControl,
      perceivedRecovery: entry.perceivedState.perceivedRecovery,
      emotionalIntensity: entry.perceivedState.emotionalIntensity,
      notes: entry.perceivedState.notes,
      contextualFactors: entry.contextualFactors.join('|'),
      physiologicalCorrelation: entry.physiologicalCorrelation,
      confidence: entry.confidence,
      relatedMarkers: entry.relatedMarkers.map((marker) => marker.id).join('|'),
      safetyCopy: entry.safetyCopy,
    );
  }

  SubjectiveFeedbackEntry _fromRow(SubjectiveFeedbackEntriesTableData row) {
    return SubjectiveFeedbackEntry(
      id: row.id,
      generatedAt: row.generatedAt,
      perceivedState: PerceivedState(
        timestamp: row.perceivedTimestamp,
        perceivedStress: row.perceivedStress,
        perceivedFatigue: row.perceivedFatigue,
        perceivedControl: row.perceivedControl,
        perceivedRecovery: row.perceivedRecovery,
        emotionalIntensity: row.emotionalIntensity,
        notes: row.notes,
      ),
      contextualFactors: row.contextualFactors.isEmpty
          ? const []
          : row.contextualFactors.split('|'),
      physiologicalCorrelation: row.physiologicalCorrelation,
      confidence: row.confidence,
    );
  }

  double _average(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    return list.fold<double>(0, (sum, value) => sum + value) / list.length;
  }
}
