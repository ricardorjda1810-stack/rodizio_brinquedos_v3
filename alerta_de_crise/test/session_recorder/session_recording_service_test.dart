import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/session_recorder/realtime_session_recorder.dart';
import 'package:signalflow/session_recorder/session_recording_service.dart';
import 'package:signalflow/session_recorder/session_snapshot_models.dart';

void main() {
  group('SessionRecordingService', () {
    late SignalFlowDatabase database;
    late SessionRecordingService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = SessionRecordingService(
        database: database,
        recorder: RealtimeSessionRecorder(
          now: () => DateTime.utc(2026, 5, 18, 12),
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('creates and finalizes recording', () async {
      await service.createRecording(protocolId: 'protocol-1');
      service.recordSnapshot(_snapshot(heartRate: 72, hrv: 42));

      final completed = await service.finalizeRecording(persist: false);

      expect(completed.session.protocolId, 'protocol-1');
      expect(completed.session.totalSamples, 1);
      expect(completed.session.averageHeartRate, 72);
      expect(completed.session.averageHrv, 42);
    });

    test('generates replay dataset', () async {
      await service.createRecording();
      service.recordSnapshot(_snapshot(), forecasts: 1, insights: 1);
      final completed = await service.finalizeRecording(persist: false);

      final dataset = service.buildReplayDataset(completed);

      expect(dataset['metadata'], isA<Map<String, Object?>>());
      expect(dataset['summary'], isA<Map<String, Object>>());
      expect(dataset['snapshots'], isA<List>());
      expect('${dataset['safetyCopy']}', contains('registro experimental'));
      expect('${dataset['safetyCopy']}', contains('não representa'));
    });

    test('persists Drift recording and snapshots', () async {
      await service.createRecording(protocolId: 'protocol-1');
      service.recordSnapshot(_snapshot(heartRate: 74, hrv: 41));
      service.recordSnapshot(_snapshot(heartRate: 78, hrv: 39));

      await service.finalizeRecording();

      final sessionRows = await database
          .select(database.recordedExperimentalSessionsTable)
          .get();
      final snapshotRows = await database
          .select(database.sessionSnapshotsTable)
          .get();
      expect(sessionRows, hasLength(1));
      expect(snapshotRows, hasLength(2));
      expect(sessionRows.single.totalSamples, 2);
      expect(sessionRows.single.safetyCopy, contains('dataset fisiológico'));
    });

    test('migration 17 to 18 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 22);
      final migration = migrationService.registeredMigrations.firstWhere(
        (migration) => migration.toVersion == 18,
      );
      expect(migration.fromVersion, 17);
      expect(migration.toVersion, 18);
      expect(migration.description, contains('Experimental session recording'));
    });

    test('session summary is consistent', () async {
      await service.createRecording();
      service.recordSnapshot(
        _snapshot(heartRate: 80, hrv: 40),
        forecasts: 1,
        contextEvents: 1,
        subjectiveEntries: 1,
      );
      service.recordSnapshot(
        _snapshot(heartRate: 90, hrv: 30, escalationLevel: 'elevated'),
        forecasts: 1,
      );

      final completed = await service.finalizeRecording(persist: false);
      final summary =
          service.buildReplayDataset(completed)['summary']
              as Map<String, Object>;

      expect(summary['totalSamples'], 2);
      expect(summary['averageHeartRate'], 85);
      expect(summary['averageHrv'], 35);
      expect(summary['escalationEvents'], 1);
    });
  });
}

SessionSnapshot _snapshot({
  double heartRate = 80,
  double hrv = 40,
  String escalationLevel = 'low',
}) {
  return SessionSnapshot(
    timestamp: DateTime.utc(2026, 5, 18, 12),
    heartRate: heartRate,
    hrv: hrv,
    confidence: 80,
    escalationLevel: escalationLevel,
    forecastProbability: 20,
    recoveryState: 'recovering',
    resilience: 70,
    contextualState: 'contexto experimental',
    multimodalConsensus: 'consenso fisiológico',
  );
}
