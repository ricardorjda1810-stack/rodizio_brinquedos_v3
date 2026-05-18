import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/autonomic_recovery/autonomic_recovery_models.dart';
import 'package:signalflow/contextual_triggers/behavioral_correlation_service.dart';
import 'package:signalflow/contextual_triggers/contextual_event.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/session_timeline/physiological_event_marker.dart';

void main() {
  group('BehavioralCorrelationService', () {
    const service = BehavioralCorrelationService();

    test('detects contextual correlation', () {
      final now = DateTime.utc(2026, 5, 18, 12);
      final correlations = service.analyzeCorrelations(
        events: [
          _event('work-1', now, ContextualCategory.work),
          _event(
            'work-2',
            now.add(const Duration(minutes: 10)),
            ContextualCategory.work,
          ),
        ],
        markers: [_marker(now.add(const Duration(minutes: 20)))],
        trends: [_trend(now.add(const Duration(minutes: 25)), 72)],
      );

      final work = correlations.singleWhere(
        (correlation) => correlation.category == ContextualCategory.work,
      );
      expect(work.escalationCorrelation, greaterThan(40));
      expect(work.associatedMarkers, isNotEmpty);
    });

    test('detects recurring pattern', () {
      final now = DateTime.utc(2026, 5, 18, 9);
      final patterns = service.detectRecurringPatterns(
        events: [
          _event('noise-1', now, ContextualCategory.noise),
          _event(
            'noise-2',
            now.add(const Duration(days: 1)),
            ContextualCategory.noise,
          ),
          _event(
            'noise-3',
            now.add(const Duration(days: 2)),
            ContextualCategory.noise,
          ),
        ],
        markers: [
          _marker(now.add(const Duration(minutes: 20))),
          _marker(now.add(const Duration(days: 1, minutes: 25))),
        ],
      );

      final noise = patterns.singleWhere(
        (pattern) => pattern.category == ContextualCategory.noise,
      );
      expect(noise.occurrenceCount, 3);
      expect(noise.commonHour, 9);
      expect(noise.associationDensity, greaterThan(0));
    });

    test('confidence is consistent with volume and associations', () {
      final now = DateTime.utc(2026, 5, 18, 12);
      final low = service
          .analyzeCorrelations(
            events: [_event('manual-1', now, ContextualCategory.manual)],
            markers: const [],
          )
          .single;
      final higher = service
          .analyzeCorrelations(
            events: [
              _event('manual-1', now, ContextualCategory.manual),
              _event(
                'manual-2',
                now.add(const Duration(minutes: 5)),
                ContextualCategory.manual,
              ),
              _event(
                'manual-3',
                now.add(const Duration(minutes: 10)),
                ContextualCategory.manual,
              ),
            ],
            markers: [_marker(now.add(const Duration(minutes: 20)))],
            trends: [_trend(now.add(const Duration(minutes: 30)), 60)],
          )
          .single;

      expect(higher.confidence, greaterThan(low.confidence));
    });

    test('generates contextual insights', () {
      final now = DateTime.utc(2026, 5, 18, 12);
      final correlations = service.analyzeCorrelations(
        events: [
          _event('conflict-1', now, ContextualCategory.conflict),
          _event(
            'conflict-2',
            now.add(const Duration(minutes: 10)),
            ContextualCategory.conflict,
          ),
          _event(
            'conflict-3',
            now.add(const Duration(minutes: 20)),
            ContextualCategory.conflict,
          ),
        ],
        markers: [_marker(now.add(const Duration(minutes: 25)))],
        trends: [_trend(now.add(const Duration(minutes: 30)), 78)],
        recoveryProfiles: [_recovery(now.add(const Duration(minutes: 35)))],
      );
      final patterns = service.detectRecurringPatterns(
        events: [
          _event('conflict-1', now, ContextualCategory.conflict),
          _event(
            'conflict-2',
            now.add(const Duration(minutes: 10)),
            ContextualCategory.conflict,
          ),
          _event(
            'conflict-3',
            now.add(const Duration(minutes: 20)),
            ContextualCategory.conflict,
          ),
        ],
        markers: [_marker(now.add(const Duration(minutes: 25)))],
      );

      final insights = service.generateContextualInsights(
        correlations: correlations,
        patterns: patterns,
      );

      expect(insights, isNotEmpty);
      expect(
        insights.first.description,
        contains('correlação não implica causalidade'),
      );
      expect(
        insights.map((insight) => insight.description).join(' '),
        contains('gatilhos potenciais'),
      );
    });
  });
}

ContextualEvent _event(
  String id,
  DateTime timestamp,
  ContextualCategory category,
) {
  return ContextualEvent(
    id: id,
    timestamp: timestamp,
    category: category,
    label: category.name,
    description: 'contexto de teste',
    intensity: ContextualIntensity.medium,
    source: 'test',
  );
}

PhysiologicalEventMarker _marker(DateTime timestamp) {
  return PhysiologicalEventMarker(
    id: 'marker-${timestamp.microsecondsSinceEpoch}',
    timestamp: timestamp,
    type: EventType.escalatingPhysiology,
    title: 'Sinais fisiológicos',
    description: 'Marcador de teste',
    severity: Severity.medium,
    source: 'test',
  );
}

PhysiologicalTrend _trend(DateTime generatedAt, int score) {
  return PhysiologicalTrend(
    averageHeartRate: 82,
    averageHrv: 34,
    hrvSlope: -0.3,
    heartRateSlope: 0.5,
    activationDensity: 0.5,
    escalationScore: score,
    generatedAt: generatedAt,
    window: TrendWindow.shortTerm,
  );
}

AutonomicRecoveryProfile _recovery(DateTime generatedAt) {
  return AutonomicRecoveryProfile(
    recoveryRate: 0.35,
    hrvRecoverySlope: 0.2,
    heartRateNormalization: 0.3,
    baselineReturnTime: const Duration(minutes: 30),
    resilienceScore: 42,
    fatigueScore: 68,
    stressCarryover: 0.62,
    generatedAt: generatedAt,
    resilienceLevel: AutonomicResilienceLevel.fatigued,
  );
}
