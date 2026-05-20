import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/contextual_triggers/contextual_event.dart';
import 'package:signalflow/contextual_triggers/contextual_trigger_service.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/session_timeline/physiological_event_marker.dart';

void main() {
  group('ContextualTriggerService', () {
    late SignalFlowDatabase database;
    late ContextualTriggerService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = ContextualTriggerService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('registers contextual event', () async {
      final event = await service.registerEvent(
        category: ContextualCategory.work,
        label: 'Work block',
        description: 'Contexto de trabalho',
        intensity: ContextualIntensity.high,
      );

      final rows = await database.select(database.contextualEventsTable).get();

      expect(event.category, ContextualCategory.work);
      expect(rows.single.label, 'Work block');
      expect(rows.single.intensity, ContextualIntensity.high.name);
    });

    test('persists and loads recent events', () async {
      await service.registerEvent(
        id: 'event-1',
        category: ContextualCategory.caffeine,
        label: 'Coffee',
      );
      await service.registerEvent(
        id: 'event-2',
        timestamp: DateTime.utc(2026, 5, 18, 12, 10),
        category: ContextualCategory.noise,
        label: 'Noise',
      );

      final events = await service.loadRecentEvents();

      expect(events, hasLength(2));
      expect(events.first.category, ContextualCategory.noise);
    });

    test('persists correlations with Drift', () async {
      final now = DateTime.utc(2026, 5, 18, 12);
      final event = await service.registerEvent(
        timestamp: now,
        category: ContextualCategory.social,
        label: 'Social context',
      );
      final correlations = await service.consolidatePatterns(
        events: [event],
        markers: [_marker(now.add(const Duration(minutes: 20)))],
        persist: true,
      );

      final rows = await database
          .select(database.contextualTriggerCorrelationsTable)
          .get();
      final loaded = await service.loadCorrelations();

      expect(correlations.single.category, ContextualCategory.social);
      expect(
        rows.single.safetyCopy,
        contains('correlação não implica causalidade'),
      );
      expect(loaded.single.category, ContextualCategory.social);
    });

    test('builds optional contextual markers', () async {
      final now = DateTime.utc(2026, 5, 18, 12);
      final correlations = await service.consolidatePatterns(
        events: [
          _event('manual-1', now),
          _event('manual-2', now.add(const Duration(minutes: 5))),
          _event('manual-3', now.add(const Duration(minutes: 10))),
        ],
        markers: [_marker(now.add(const Duration(minutes: 20)))],
      );

      final markers = service.buildOptionalMarkers(
        correlations: correlations,
        timelineId: 'timeline-context',
      );

      expect(
        markers.map((marker) => marker.type),
        contains(EventType.repeatedContextTrigger),
      );
    });

    test('migration 7 to 8 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 22);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 7 &&
              migration.toVersion == 8 &&
              migration.description.contains('Contextual trigger'),
        ),
        isTrue,
      );
    });
  });
}

ContextualEvent _event(String id, DateTime timestamp) {
  return ContextualEvent(
    id: id,
    timestamp: timestamp,
    category: ContextualCategory.manual,
    label: 'Manual',
    description: 'Contexto manual',
    intensity: ContextualIntensity.medium,
    source: 'test',
  );
}

PhysiologicalEventMarker _marker(DateTime timestamp) {
  return PhysiologicalEventMarker(
    id: 'marker-${timestamp.microsecondsSinceEpoch}',
    timestamp: timestamp,
    type: EventType.contextualEscalationPattern,
    title: 'Sinais fisiológicos',
    description: 'Marcador de teste',
    severity: Severity.medium,
    source: 'test',
  );
}
