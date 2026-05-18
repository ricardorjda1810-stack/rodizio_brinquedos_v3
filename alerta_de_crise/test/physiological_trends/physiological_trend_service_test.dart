import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/physiological_trends/physiological_trend_service.dart';
import 'package:signalflow/physiological_trends/trend_window.dart';
import 'package:signalflow/session_timeline/physiological_event_marker.dart';

void main() {
  group('PhysiologicalTrendService', () {
    late SignalFlowDatabase database;
    late PhysiologicalTrendService service;
    late DateTime now;

    setUp(() {
      database = SignalFlowDatabase.memory();
      now = DateTime.utc(2026, 5, 17, 12);
      service = PhysiologicalTrendService(database: database, now: () => now);
    });

    tearDown(() async {
      await database.close();
    });

    test('calculates positive heart rate slope', () {
      final trend = service.calculateTrend(
        samples: _samples(
          now,
          heartRates: [70, 74, 78, 82],
          hrvs: [45, 44, 43, 42],
        ),
      );

      expect(trend.heartRateSlope, greaterThan(0));
    });

    test('calculates negative HRV slope', () {
      final trend = service.calculateTrend(
        samples: _samples(
          now,
          heartRates: [70, 72, 74, 76],
          hrvs: [48, 44, 40, 36],
        ),
      );

      expect(trend.hrvSlope, lessThan(0));
    });

    test('activation density is consistent', () {
      final trend = service.calculateTrend(
        samples: _samples(now, heartRates: [70, 72, 74], hrvs: [45, 44, 43]),
        markers: [
          _marker(EventType.elevatedHeartRate),
          _marker(EventType.manualMarker),
        ],
      );

      expect(trend.activationDensity, 0.5);
    });

    test('persists trends', () async {
      final trend = await service.analyzeRecentSamples(
        timelineId: 'timeline-1',
        samples: _samples(
          now,
          heartRates: [70, 76, 82, 88],
          hrvs: [48, 43, 38, 33],
        ),
        markers: [_marker(EventType.elevatedHeartRate)],
      );

      final rows = await database
          .select(database.physiologicalTrendsTable)
          .get();
      final loaded = await service.loadTrends(timelineId: 'timeline-1');

      expect(rows, hasLength(1));
      expect(loaded.single.escalationScore, trend.escalationScore);
      expect(loaded.single.window.label, TrendWindow.shortTerm.label);
    });

    test('migration 3 to 4 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 16);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 3 &&
              migration.toVersion == 4 &&
              migration.description.contains('Trend analysis'),
        ),
        isTrue,
      );
    });
  });
}

List<PhysiologicalSample> _samples(
  DateTime now, {
  required List<double> heartRates,
  required List<double> hrvs,
}) {
  return List.generate(heartRates.length, (index) {
    return PhysiologicalSample(
      timestamp: now.subtract(Duration(minutes: heartRates.length - index)),
      heartRateBpm: heartRates[index],
      hrvRmssdMs: hrvs[index],
      movementIntensity: 0.15,
    );
  });
}

PhysiologicalEventMarker _marker(EventType type) {
  return PhysiologicalEventMarker(
    id: 'marker-${type.name}',
    timestamp: DateTime.utc(2026, 5, 17, 11, 59),
    type: type,
    title: 'Marker',
    description: 'Debug marker',
    severity: Severity.medium,
    source: 'test',
  );
}
