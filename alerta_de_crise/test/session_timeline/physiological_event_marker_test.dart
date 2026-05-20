import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/session_timeline/physiological_event_marker.dart';

void main() {
  group('PhysiologicalEventMarker', () {
    test('preserves timestamp type and severity', () {
      final timestamp = DateTime.utc(2026, 5, 17, 12);
      final marker = PhysiologicalEventMarker(
        id: 'marker-1',
        timestamp: timestamp,
        type: EventType.manualMarker,
        title: 'Contexto',
        description: 'Marcador manual de pesquisa.',
        severity: Severity.low,
        source: 'test',
      );

      expect(marker.id, 'marker-1');
      expect(marker.timestamp, timestamp);
      expect(marker.type, EventType.manualMarker);
      expect(marker.severity, Severity.low);
      expect(marker.source, 'test');
    });
  });
}
