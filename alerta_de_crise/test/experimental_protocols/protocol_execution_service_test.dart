import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/database/audit/database_migration_service.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/experimental_protocols/protocol_execution_service.dart';
import 'package:signalflow/experimental_protocols/protocol_templates.dart';

void main() {
  group('ProtocolExecutionService', () {
    late SignalFlowDatabase database;
    late ProtocolExecutionService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = ProtocolExecutionService(
        database: database,
        now: () => DateTime.utc(2026, 5, 18, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('starts protocol and generates markers', () async {
      final protocol = ProtocolTemplates.basicRecoveryProtocol();

      final session = await service.startProtocol(protocol);

      expect(session.protocol.id, protocol.id);
      expect(session.currentPhase?.title, '5 min resting');
      expect(session.generatedMarkers, contains('protocol_started'));
      expect(
        session.generatedMarkers,
        contains('protocol_phase_started:resting-5m'),
      );
    });

    test('phases advance correctly and protocol completes', () async {
      final protocol = ProtocolTemplates.basicRecoveryProtocol();
      await service.startProtocol(protocol);

      final secondPhase = service.nextPhase();
      final thirdPhase = service.nextPhase();
      final completed = service.nextPhase();

      expect(secondPhase.currentPhase?.title, '5 min breathing');
      expect(thirdPhase.currentPhase?.title, '5 min recovery');
      expect(completed.completed, isTrue);
      expect(completed.currentPhase, isNull);
      expect(completed.generatedMarkers, contains('protocol_completed'));
    });

    test('remaining duration decreases across phases', () async {
      final protocol = ProtocolTemplates.basicRecoveryProtocol();

      final started = await service.startProtocol(protocol);
      final secondPhase = service.nextPhase();

      expect(service.remainingDuration(started), const Duration(minutes: 15));
      expect(
        service.remainingDuration(secondPhase),
        const Duration(minutes: 10),
      );
    });

    test('persists Drift protocol and session', () async {
      final protocol = ProtocolTemplates.basicRecoveryProtocol();

      final session = await service.startProtocol(protocol, persist: true);

      final protocolRows = await database
          .select(database.experimentalProtocolsTable)
          .get();
      final sessionRows = await database
          .select(database.experimentalProtocolSessionsTable)
          .get();
      expect(protocolRows, hasLength(1));
      expect(sessionRows, hasLength(1));
      expect(sessionRows.single.id, session.id);
      expect(
        sessionRows.single.generatedMarkersJson,
        contains('protocol_started'),
      );
    });

    test('migration 16 to 17 is registered', () {
      final migrationService = DatabaseMigrationService(database: database);

      expect(migrationService.currentSchemaVersion, 20);
      final migration = migrationService.registeredMigrations.firstWhere(
        (migration) => migration.toVersion == 17,
      );
      expect(migration.fromVersion, 16);
      expect(migration.toVersion, 17);
      expect(migration.description, contains('Experimental protocol'));
    });
  });
}
