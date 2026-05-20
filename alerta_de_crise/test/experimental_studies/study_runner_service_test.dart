import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/experimental_studies/study_runner_service.dart';

void main() {
  group('StudyRunnerService', () {
    late SignalFlowDatabase database;
    late StudyRunnerService service;
    late DateTime fixedNow;

    setUp(() {
      database = SignalFlowDatabase.memory();
      fixedNow = DateTime(2026, 1, 1, 9);
      service = StudyRunnerService(database: database, now: () => fixedNow);
    });

    tearDown(() async {
      await database.close();
    });

    test('creates study, runs session, and generates summary', () async {
      final study = await service.startStudy(
        title: 'Estudo experimental de recuperação',
        description: 'coleta experimental para benchmark longitudinal',
        protocolId: 'protocol-basic',
        persist: true,
      );

      final startedSession = await service.startStudySession(
        study: study,
        sessionId: 'session-1',
        persist: true,
      );

      final completedSession = await service.completeStudySession(
        sessionRecordId: startedSession.id,
        multimodalConsensusScore: 84,
        persist: true,
      );

      final snapshot = await service.finalizeStudy(
        study: study,
        sessions: [completedSession],
        recoveryScores: [72, 81],
        falseEscalationRates: [5],
        sensorReliabilityScores: [90],
      );

      expect(study.active, isTrue);
      expect(startedSession.success, isFalse);
      expect(completedSession.success, isTrue);
      expect(completedSession.replayGenerated, isTrue);
      expect(completedSession.benchmarkGenerated, isTrue);
      expect(snapshot.study.active, isFalse);
      expect(snapshot.study.totalSessions, 1);
      expect(snapshot.metrics.recoveryEfficiency, 76.5);
      expect(snapshot.summary.join(' '), contains('estudo experimental'));
      expect(snapshot.summary.join(' '), contains('benchmark longitudinal'));
      expect(
        snapshot.summary.join(' '),
        contains('não representa estudo clínico'),
      );
    });

    test('persists Drift study and session rows', () async {
      final study = await service.startStudy(
        title: 'Coorte experimental',
        description: 'sessão experimental estruturada',
        protocolId: 'protocol-basic',
        persist: true,
      );
      final startedSession = await service.startStudySession(
        study: study,
        sessionId: 'session-1',
        persist: true,
      );
      await service.completeStudySession(
        sessionRecordId: startedSession.id,
        persist: true,
      );

      final studies = await database
          .select(database.experimentalStudiesTable)
          .get();
      final sessions = await database
          .select(database.experimentalStudySessionsTable)
          .get();

      expect(studies, hasLength(1));
      expect(sessions, hasLength(1));
      expect(studies.single.safetyCopy, contains('estudo experimental'));
      expect(sessions.single.safetyCopy, contains('sessão experimental'));
    });

    test('registers migration 21 to 22 for experimental study persistence', () {
      final migrationService = DatabaseMigrationService(database: database);
      final migration = migrationService.registeredMigrations.firstWhere(
        (entry) => entry.toVersion == 22,
      );

      expect(migrationService.currentSchemaVersion, 22);
      expect(migration.fromVersion, 21);
      expect(migration.toVersion, 22);
      expect(migration.description, contains('Experimental study persistence'));
    });
  });
}
