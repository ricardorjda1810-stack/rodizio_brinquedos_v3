import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/physiological_trends/escalation_detection_service.dart';
import 'package:signalflow/physiological_trends/physiological_trend_models.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/session_timeline/physiological_event_marker.dart';

void main() {
  group('EscalationDetectionService', () {
    const service = EscalationDetectionService();

    test('detects escalation', () {
      final result = service.detectEscalation(trend: _trend(score: 60));

      expect(result.level, EscalationLevel.escalating);
      expect(
        result.markers.map((marker) => marker.type),
        contains(EventType.escalatingPhysiology),
      );
    });

    test('detects stable state', () {
      final result = service.detectEscalation(trend: _trend(score: 5));

      expect(result.level, EscalationLevel.stable);
      expect(result.markers, isEmpty);
    });

    test('detects critical level', () {
      final result = service.detectEscalation(trend: _trend(score: 82));

      expect(result.level, EscalationLevel.critical);
      expect(result.markers.first.severity, Severity.high);
    });

    test('adds sustained HR and HRV markers', () {
      final result = service.detectEscalation(
        trend: _trend(score: 70, heartRateSlope: 1.2, hrvSlope: -1.4),
      );

      expect(
        result.markers.map((marker) => marker.type),
        containsAll([
          EventType.sustainedHeartRateElevation,
          EventType.prolongedHrvSuppression,
        ]),
      );
    });
  });
}

PhysiologicalTrend _trend({
  required int score,
  double heartRateSlope = 0,
  double hrvSlope = 0,
}) {
  return PhysiologicalTrend(
    averageHeartRate: 82,
    averageHrv: 38,
    hrvSlope: hrvSlope,
    heartRateSlope: heartRateSlope,
    activationDensity: 0.5,
    escalationScore: score,
    generatedAt: DateTime.utc(2026, 5, 17, 12),
    window: TrendWindow.shortTerm,
  );
}
