import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import 'contextual_event.dart';
import 'contextual_pattern_analysis.dart';
import 'contextual_trigger_models.dart';

class BehavioralCorrelationService {
  final ContextualPatternAnalysis _patternAnalysis;

  const BehavioralCorrelationService({
    ContextualPatternAnalysis patternAnalysis =
        const ContextualPatternAnalysis(),
  }) : _patternAnalysis = patternAnalysis;

  List<ContextualTriggerCorrelation> analyzeCorrelations({
    List<ContextualEvent> events = const [],
    List<PhysiologicalEventMarker> markers = const [],
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<EscalationForecast> forecasts = const [],
  }) {
    final correlations = <ContextualTriggerCorrelation>[];
    for (final category in ContextualCategory.values) {
      final categoryEvents = events
          .where((event) => event.category == category)
          .toList(growable: false);
      if (categoryEvents.isEmpty) {
        continue;
      }

      final associatedMarkers = markers
          .where(
            (marker) => categoryEvents.any(
              (event) =>
                  _associatedWithPhysiology(event.timestamp, marker.timestamp),
            ),
          )
          .toList(growable: false);
      final escalationCorrelation = _escalationCorrelation(
        events: categoryEvents,
        associatedMarkers: associatedMarkers,
        trends: trends,
        forecasts: forecasts,
      );
      final recoveryImpact = _recoveryImpact(
        events: categoryEvents,
        recoveryProfiles: recoveryProfiles,
      );
      final confidence = _confidence(
        occurrenceCount: categoryEvents.length,
        associatedMarkers: associatedMarkers.length,
        trends: trends.length,
        forecasts: forecasts.length,
      );

      correlations.add(
        ContextualTriggerCorrelation(
          category: category,
          occurrenceCount: categoryEvents.length,
          escalationCorrelation: escalationCorrelation,
          recoveryImpact: recoveryImpact,
          confidence: confidence,
          lastOccurrence: _lastOccurrence(categoryEvents),
          associatedMarkers: associatedMarkers,
        ),
      );
    }

    correlations.sort(
      (a, b) => b.escalationCorrelation.compareTo(a.escalationCorrelation),
    );
    return List.unmodifiable(correlations);
  }

  List<ContextualPattern> detectRecurringPatterns({
    required List<ContextualEvent> events,
    required List<PhysiologicalEventMarker> markers,
  }) {
    return _patternAnalysis.detectPatterns(events: events, markers: markers);
  }

  List<ContextualInsight> generateContextualInsights({
    required List<ContextualTriggerCorrelation> correlations,
    required List<ContextualPattern> patterns,
  }) {
    final insights = <ContextualInsight>[
      const ContextualInsight(
        title: 'Análise experimental',
        description:
            'correlação não implica causalidade; gatilhos potenciais indicam padrões observados junto a sinais fisiológicos.',
        confidence: 100,
      ),
    ];

    for (final correlation in correlations.take(4)) {
      if (correlation.escalationCorrelation >= 45) {
        insights.add(
          ContextualInsight(
            title: 'Correlação contextual observada',
            description:
                '${correlation.category.name}: ${correlation.occurrenceCount} ocorrências com sinais fisiológicos próximos.',
            confidence: correlation.confidence,
          ),
        );
      } else if (correlation.recoveryImpact >= 35) {
        insights.add(
          ContextualInsight(
            title: 'Associação com recuperação',
            description:
                '${correlation.category.name}: padrões observados sugerem impacto na recuperação autonômica.',
            confidence: correlation.confidence,
          ),
        );
      }
    }

    for (final pattern
        in patterns.where((pattern) => pattern.occurrenceCount >= 3).take(3)) {
      insights.add(
        ContextualInsight(
          title: 'Padrão recorrente de contexto',
          description:
              '${pattern.category.name} aparece com frequência perto das ${pattern.commonHour}h e associação ${pattern.associationDensity.toStringAsFixed(2)}.',
          confidence: (pattern.associationDensity * 100)
              .clamp(0, 100)
              .toDouble(),
        ),
      );
    }

    return List.unmodifiable(insights);
  }

  bool _associatedWithPhysiology(DateTime eventTime, DateTime signalTime) {
    final delta = signalTime.difference(eventTime);
    return !delta.isNegative && delta <= const Duration(minutes: 45);
  }

  double _escalationCorrelation({
    required List<ContextualEvent> events,
    required List<PhysiologicalEventMarker> associatedMarkers,
    required List<PhysiologicalTrend> trends,
    required List<EscalationForecast> forecasts,
  }) {
    final markerDensity = events.isEmpty
        ? 0.0
        : (associatedMarkers.length / events.length).clamp(0, 1).toDouble();
    final nearbyTrend = _average(
      trends
          .where(
            (trend) => events.any(
              (event) =>
                  _associatedWithPhysiology(event.timestamp, trend.generatedAt),
            ),
          )
          .map((trend) => trend.escalationScore.toDouble())
          .toList(),
    );
    final nearbyForecast = _average(
      forecasts
          .where(
            (forecast) => events.any(
              (event) => _associatedWithPhysiology(
                event.timestamp,
                forecast.generatedAt,
              ),
            ),
          )
          .map((forecast) => forecast.escalationProbability)
          .toList(),
    );
    return ((markerDensity * 45) +
            (nearbyTrend * 0.35) +
            (nearbyForecast * 0.2))
        .clamp(0, 100)
        .toDouble();
  }

  double _recoveryImpact({
    required List<ContextualEvent> events,
    required List<AutonomicRecoveryProfile> recoveryProfiles,
  }) {
    final nearbyFatigue = _average(
      recoveryProfiles
          .where(
            (profile) => events.any(
              (event) => _associatedWithPhysiology(
                event.timestamp,
                profile.generatedAt,
              ),
            ),
          )
          .map((profile) => profile.fatigueScore.toDouble())
          .toList(),
    );
    final nearbyCarryover = _average(
      recoveryProfiles
          .where(
            (profile) => events.any(
              (event) => _associatedWithPhysiology(
                event.timestamp,
                profile.generatedAt,
              ),
            ),
          )
          .map((profile) => profile.stressCarryover * 100)
          .toList(),
    );
    return ((nearbyFatigue * 0.55) + (nearbyCarryover * 0.45))
        .clamp(0, 100)
        .toDouble();
  }

  double _confidence({
    required int occurrenceCount,
    required int associatedMarkers,
    required int trends,
    required int forecasts,
  }) {
    final volume = (occurrenceCount * 14).clamp(0, 56);
    final associations = (associatedMarkers * 12).clamp(0, 28);
    final physiology = ((trends + forecasts) * 4).clamp(0, 16);
    return (volume + associations + physiology).clamp(0, 100).toDouble();
  }

  DateTime? _lastOccurrence(List<ContextualEvent> events) {
    if (events.isEmpty) {
      return null;
    }
    return events
        .map((event) => event.timestamp)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  double _average(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return total / values.length;
  }
}
