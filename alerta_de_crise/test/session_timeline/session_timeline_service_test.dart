import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/session_timeline/physiological_event_marker.dart';
import 'package:signalflow/session_timeline/session_timeline_service.dart';

void main() {
  group('SessionTimelineService', () {
    late SignalFlowDatabase database;
    late DateTime currentTime;
    late SessionTimelineService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      currentTime = DateTime.utc(2026, 5, 17, 12);
      service = SessionTimelineService(
        database: database,
        now: () => currentTime,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('timeline starts', () async {
      final timeline = await service.startTimeline(id: 'timeline-1');

      expect(timeline.id, 'timeline-1');
      expect(timeline.startedAt, currentTime);
      expect(timeline.isActive, isTrue);
      expect(timeline.totalSamples, 0);
    });

    test('timeline completes', () async {
      await service.startTimeline(id: 'timeline-1');
      currentTime = currentTime.add(const Duration(minutes: 2));

      final timeline = await service.completeTimeline();

      expect(timeline, isNotNull);
      expect(timeline!.endedAt, currentTime);
      expect(timeline.isActive, isFalse);
    });

    test('markers are added in temporal order', () async {
      await service.startTimeline(id: 'timeline-1');
      final later = currentTime.add(const Duration(seconds: 20));
      final earlier = currentTime.add(const Duration(seconds: 10));

      await service.addMarker(_marker(id: 'later', timestamp: later));
      await service.addMarker(_marker(id: 'earlier', timestamp: earlier));

      expect(service.markers.map((marker) => marker.id), ['earlier', 'later']);
      expect(service.currentTimeline?.totalEvents, 2);
    });

    test('statistics are consistent', () async {
      await service.startTimeline(id: 'timeline-1');
      await service.addSample(
        _sample(timestamp: currentTime, heartRate: 72, hrv: 45),
      );
      await service.addSample(
        _sample(
          timestamp: currentTime.add(const Duration(seconds: 30)),
          heartRate: 95,
          hrv: 30,
        ),
      );
      await service.addMarker(
        _marker(
          id: 'activation',
          timestamp: currentTime.add(const Duration(seconds: 10)),
          type: EventType.elevatedHeartRate,
        ),
      );
      await service.addMarker(
        _marker(
          id: 'intervention',
          timestamp: currentTime.add(const Duration(seconds: 40)),
          type: EventType.interventionStarted,
        ),
      );

      final statistics = service.getTimelineStatistics();

      expect(statistics.maxHeartRate, 95);
      expect(statistics.minHrv, 30);
      expect(statistics.totalInterventions, 1);
      expect(statistics.averageSecondsBetweenEvents, 30);
    });

    test('activation density is consistent', () async {
      await service.startTimeline(id: 'timeline-1');
      await service.addMarker(
        _marker(id: 'activation', type: EventType.elevatedHeartRate),
      );
      await service.addMarker(
        _marker(id: 'manual', type: EventType.manualMarker),
      );

      final statistics = service.getTimelineStatistics();

      expect(statistics.activationDensity, 0.5);
    });

    test('timestamps are preserved in persisted marker', () async {
      await service.startTimeline(id: 'timeline-1');
      final timestamp = currentTime.add(const Duration(seconds: 12));
      await service.addMarker(_marker(id: 'marker-1', timestamp: timestamp));

      final loaded = await service.loadMarkers('timeline-1');

      expect(loaded.single.timestamp.isAtSameMomentAs(timestamp), isTrue);
      expect(loaded.single.type, EventType.manualMarker);
    });

    test('persists timeline rows in Drift', () async {
      await service.startTimeline(id: 'timeline-1');
      await service.addSample(_sample(timestamp: currentTime));
      await service.completeTimeline();

      final rows = await database.select(database.sessionTimelineTable).get();

      expect(rows.single.id, 'timeline-1');
      expect(rows.single.totalSamples, 1);
      expect(rows.single.endedAt, isNotNull);
    });

    test('migration schema 2 to 3 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 11);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 2 &&
              migration.toVersion == 3 &&
              migration.description.contains('timeline'),
        ),
        isTrue,
      );
    });
  });
}

PhysiologicalSample _sample({
  required DateTime timestamp,
  double heartRate = 72,
  double? hrv = 45,
}) {
  return PhysiologicalSample(
    timestamp: timestamp,
    heartRateBpm: heartRate,
    hrvRmssdMs: hrv,
    movementIntensity: 0.15,
  );
}

PhysiologicalEventMarker _marker({
  String id = 'marker',
  DateTime? timestamp,
  EventType type = EventType.manualMarker,
}) {
  return PhysiologicalEventMarker(
    id: id,
    timestamp: timestamp ?? DateTime.utc(2026, 5, 17, 12),
    type: type,
    title: 'Marcador',
    description: 'Evento de timeline.',
    severity: Severity.medium,
    source: 'test',
  );
}
