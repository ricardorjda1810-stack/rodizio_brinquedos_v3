import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/baseline_profile.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';
import 'package:signalflow/core/crisis_detection/physiological_sensor_provider.dart';
import 'package:signalflow/core/crisis_detection/sensor_provider_type.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/realtime_streaming/physiological_stream_buffer.dart';
import 'package:signalflow/realtime_streaming/realtime_ingestion_controller.dart';
import 'package:signalflow/realtime_streaming/realtime_pipeline_service.dart';
import 'package:signalflow/realtime_streaming/realtime_stream_models.dart';

void main() {
  group('RealtimePipelineService', () {
    late SignalFlowDatabase database;
    late RealtimePipelineService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = RealtimePipelineService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('ingests sample incrementally', () async {
      final buffer = PhysiologicalStreamBuffer(maxSize: 10);

      final snapshot = await service.ingestSample(
        sample: _sample(DateTime.utc(2026, 5, 18, 12), hr: 72),
        buffer: buffer,
        baseline: _baseline(),
      );

      expect(buffer.samples, hasLength(1));
      expect(snapshot.bufferSize, 1);
      expect(snapshot.rollingHeartRate, 72);
    });

    test('generates realtime snapshot', () async {
      final buffer = PhysiologicalStreamBuffer(maxSize: 10)
        ..addSample(_sample(DateTime.utc(2026, 5, 18, 11, 59, 50), hr: 72))
        ..addSample(_sample(DateTime.utc(2026, 5, 18, 12), hr: 92, hrv: 24));

      final snapshot = service.generateRealtimeSnapshot(
        buffer: buffer,
        baseline: _baseline(),
      );

      expect(snapshot.rollingHeartRate, greaterThan(70));
      expect(snapshot.latestEscalationProbability, greaterThan(0));
      expect(
        snapshot.safetyCopy,
        contains('não monitoramento médico contínuo'),
      );
    });

    test('persists Drift snapshot', () async {
      final buffer = PhysiologicalStreamBuffer(maxSize: 10);
      final snapshot = await service.ingestSample(
        sample: _sample(DateTime.utc(2026, 5, 18, 12), hr: 72),
        buffer: buffer,
        baseline: _baseline(),
        persist: true,
      );

      final loaded = await service.loadSnapshots();
      final rows = await database
          .select(database.realtimePipelineSnapshotsTable)
          .get();

      expect(loaded.single.id, snapshot.id);
      expect(rows.single.safetyCopy, contains('streaming experimental'));
    });

    test('migration 10 to 11 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 18);
      expect(
        migrationService.registeredMigrations.any(
          (migration) =>
              migration.fromVersion == 10 &&
              migration.toVersion == 11 &&
              migration.description.contains('Realtime streaming'),
        ),
        isTrue,
      );
    });

    test('controller pauses and resumes streaming', () async {
      final provider = _FakeProvider([
        _sample(DateTime.utc(2026, 5, 18, 12), hr: 72),
        _sample(DateTime.utc(2026, 5, 18, 12, 0, 1), hr: 74),
      ]);
      final controller = RealtimeIngestionController(
        provider: provider,
        buffer: PhysiologicalStreamBuffer(maxSize: 10),
        pipelineService: service,
        frequency: const Duration(minutes: 5),
        baseline: _baseline(),
      );

      await controller.startStreaming();
      controller.pauseStreaming();
      expect(controller.state, RealtimeStreamingState.paused);

      await controller.resumeStreaming();
      expect(controller.state, RealtimeStreamingState.running);
      expect(controller.latestSnapshot?.bufferSize, 2);
      controller.stopStreaming();
      expect(controller.state, RealtimeStreamingState.stopped);
    });
  });
}

BaselineProfile _baseline() {
  return const BaselineProfile(
    restingHeartRateBpm: 68,
    hrvRmssdMs: 42,
    respiratoryRate: 15,
    movementIntensity: 0.1,
  );
}

PhysiologicalSample _sample(
  DateTime timestamp, {
  required double hr,
  double? hrv = 40,
}) {
  return PhysiologicalSample(
    timestamp: timestamp,
    heartRateBpm: hr,
    hrvRmssdMs: hrv,
    movementIntensity: 0.1,
  );
}

class _FakeProvider implements PhysiologicalSensorProvider {
  final List<PhysiologicalSample> samples;
  int index = 0;

  _FakeProvider(this.samples);

  @override
  SensorProviderType get type => SensorProviderType.simulator;

  @override
  Future<PhysiologicalSample?> getLatestSample() async {
    if (index >= samples.length) {
      return null;
    }
    return samples[index++];
  }

  @override
  Future<List<PhysiologicalSample>> getRecentSamples({int limit = 30}) async {
    return samples.take(limit).toList(growable: false);
  }
}
