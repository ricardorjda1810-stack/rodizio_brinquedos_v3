import '../session_timeline/physiological_event_marker.dart';
import 'physiological_trend_models.dart';

enum EscalationLevel { stable, elevated, escalating, critical }

class EscalationDetectionResult {
  final EscalationLevel level;
  final int score;
  final List<PhysiologicalEventMarker> markers;

  const EscalationDetectionResult({
    required this.level,
    required this.score,
    required this.markers,
  });
}

class EscalationDetectionService {
  const EscalationDetectionService();

  EscalationDetectionResult detectEscalation({
    required PhysiologicalTrend trend,
    String timelineId = 'debug',
  }) {
    final level = _levelFromScore(trend.escalationScore);
    final markers = <PhysiologicalEventMarker>[];

    if (level == EscalationLevel.escalating ||
        level == EscalationLevel.critical) {
      markers.add(
        PhysiologicalEventMarker(
          id: 'trend-${trend.generatedAt.microsecondsSinceEpoch}-escalating',
          timestamp: trend.generatedAt,
          type: EventType.escalatingPhysiology,
          title: 'Escalada fisiológica gradual',
          description:
              'Tendência progressiva de ativação acima do padrão observada.',
          severity: level == EscalationLevel.critical
              ? Severity.high
              : Severity.medium,
          source: 'trend_analysis:$timelineId',
        ),
      );
    }

    if (trend.heartRateSlope >= 0.08) {
      markers.add(
        PhysiologicalEventMarker(
          id: 'trend-${trend.generatedAt.microsecondsSinceEpoch}-hr',
          timestamp: trend.generatedAt,
          type: EventType.sustainedHeartRateElevation,
          title: 'FC em elevação sustentada',
          description: 'Frequência cardíaca com tendência de subida gradual.',
          severity: Severity.medium,
          source: 'trend_analysis:$timelineId',
        ),
      );
    }

    if (trend.hrvSlope <= -0.08) {
      markers.add(
        PhysiologicalEventMarker(
          id: 'trend-${trend.generatedAt.microsecondsSinceEpoch}-hrv',
          timestamp: trend.generatedAt,
          type: EventType.prolongedHrvSuppression,
          title: 'HRV em redução gradual',
          description: 'HRV com tendência de queda ao longo da janela.',
          severity: Severity.medium,
          source: 'trend_analysis:$timelineId',
        ),
      );
    }

    return EscalationDetectionResult(
      level: level,
      score: trend.escalationScore,
      markers: List.unmodifiable(markers),
    );
  }

  EscalationLevel _levelFromScore(int score) {
    if (score >= 75) {
      return EscalationLevel.critical;
    }
    if (score >= 50) {
      return EscalationLevel.escalating;
    }
    if (score >= 25) {
      return EscalationLevel.elevated;
    }
    return EscalationLevel.stable;
  }
}
