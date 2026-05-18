import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/database/audit/database_integrity_service.dart';
import 'package:signalflow/database/signalflow_database.dart';

void main() {
  group('DatabaseIntegrityService', () {
    late SignalFlowDatabase database;
    late DatabaseIntegrityService service;

    setUp(() {
      database = SignalFlowDatabase.memory();
      service = DatabaseIntegrityService(
        database: database,
        now: () => DateTime.utc(2026, 5, 17, 12),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('returns valid health report for empty database', () async {
      final report = await service.runIntegrityAudit();

      expect(report.schemaVersion, 13);
      expect(report.tablesChecked, hasLength(22));
      expect(report.totalRecords, 0);
      expect(report.hasIntegrityIssues, isFalse);
      expect(report.healthScore, 100);
    });

    test('generates issues for invalid score and invalid JSON', () async {
      await database
          .into(database.crisisRiskEventsTable)
          .insert(
            CrisisRiskEventsTableCompanion.insert(
              id: 'bad-event',
              timestamp: DateTime.utc(2026, 5, 17, 10),
              score: 120,
              level: 'moderateAlert',
              reasonCodesJson: 'not-json',
              recommendedAction: 'Observar sinais fisiológicos.',
              cognitiveResponse: 'notAsked',
              source: 'test',
            ),
          );

      final report = await service.runIntegrityAudit();

      expect(report.hasIntegrityIssues, isTrue);
      expect(report.issues, contains(contains('score outside 0..100')));
      expect(report.issues, contains(contains('invalid reasonCodesJson')));
      expect(report.healthScore, lessThan(100));
    });

    test('generates warnings for empty optional semantic fields', () async {
      await database
          .into(database.crisisRiskEventsTable)
          .insert(
            CrisisRiskEventsTableCompanion.insert(
              id: 'warning-event',
              timestamp: DateTime.utc(2026, 5, 17, 10),
              score: 40,
              level: 'mildAttention',
              reasonCodesJson: '[]',
              recommendedAction: '',
              cognitiveResponse: 'notAsked',
              source: '',
            ),
          );

      final report = await service.runIntegrityAudit();

      expect(report.hasIntegrityIssues, isFalse);
      expect(report.warnings, hasLength(2));
      expect(report.healthScore, 90);
    });

    test('detects inconsistent intervention timestamps', () async {
      await database
          .into(database.interventionHistoryTable)
          .insert(
            InterventionHistoryTableCompanion.insert(
              id: 'bad-intervention',
              protocolId: 'standard',
              startedAt: DateTime.utc(2026, 5, 17, 10, 5),
              completedAt: DateTime.utc(2026, 5, 17, 10),
              durationSeconds: 300,
              completed: true,
              userReportedImprovement: true,
              finalResponse: 'feelingOk',
              preScore: const Value(70),
              postScore: const Value(45),
              scoreDelta: const Value(5),
            ),
          );

      final report = await service.runIntegrityAudit();

      expect(report.issues, contains(contains('completedAt before startedAt')));
      expect(report.warnings, contains(contains('inconsistent scoreDelta')));
    });

    test('detects empty consent version', () async {
      await database
          .into(database.researchConsentTable)
          .insert(
            ResearchConsentTableCompanion.insert(
              id: 'current',
              accepted: true,
              acceptedAt: const Value(null),
              version: '',
              allowsPhysiologicalCollection: true,
              allowsResearchExport: true,
              allowsReplayAnalysis: true,
            ),
          );

      final report = await service.runIntegrityAudit();

      expect(report.issues, contains(contains('empty version')));
      expect(
        report.warnings,
        contains(contains('accepted without acceptedAt')),
      );
    });

    test('detects inconsistent timeline timestamps', () async {
      await database
          .into(database.sessionTimelineTable)
          .insert(
            SessionTimelineTableCompanion.insert(
              id: 'bad-timeline',
              startedAt: DateTime.utc(2026, 5, 17, 10, 5),
              endedAt: Value(DateTime.utc(2026, 5, 17, 10)),
              totalSamples: 0,
              totalEvents: 0,
              averageHeartRate: const Value(null),
              averageHrv: const Value(null),
              maxHeartRate: const Value(null),
              minHrv: const Value(null),
            ),
          );

      final report = await service.runIntegrityAudit();

      expect(report.issues, contains(contains('endedAt before startedAt')));
    });

    test('detects invalid event marker metadata', () async {
      await database
          .into(database.physiologicalEventMarkersTable)
          .insert(
            PhysiologicalEventMarkersTableCompanion.insert(
              id: 'bad-marker',
              timelineId: 'timeline-1',
              timestamp: DateTime.utc(2026, 5, 17, 10),
              type: 'unknown',
              title: '',
              description: 'Evento inválido.',
              severity: 'urgent',
              source: '',
            ),
          );

      final report = await service.runIntegrityAudit();

      expect(report.issues, contains(contains('invalid type')));
      expect(report.issues, contains(contains('invalid severity')));
      expect(report.warnings, contains(contains('empty title')));
      expect(report.warnings, contains(contains('empty source')));
    });

    test('detects invalid physiological trend metadata', () async {
      await database
          .into(database.physiologicalTrendsTable)
          .insert(
            PhysiologicalTrendsTableCompanion.insert(
              id: 'bad-trend',
              timelineId: 'timeline-1',
              generatedAt: DateTime.utc(2026, 5, 17, 10),
              windowLabel: '',
              windowSeconds: 0,
              averageHeartRate: const Value(-1),
              averageHrv: const Value(-1),
              hrvSlope: -1,
              heartRateSlope: 1,
              activationDensity: 2,
              escalationScore: 120,
            ),
          );

      final report = await service.runIntegrityAudit();

      expect(report.issues, contains(contains('invalid window')));
      expect(report.issues, contains(contains('escalationScore outside')));
      expect(report.issues, contains(contains('activationDensity outside')));
      expect(report.warnings, contains(contains('invalid average HR')));
      expect(report.warnings, contains(contains('non-positive HRV')));
    });

    test('detects invalid autonomic recovery profile metadata', () async {
      await database
          .into(database.autonomicRecoveryProfilesTable)
          .insert(
            AutonomicRecoveryProfilesTableCompanion.insert(
              id: 'bad-recovery',
              timelineId: 'timeline-1',
              generatedAt: DateTime.utc(2026, 5, 17, 10),
              windowLabel: '',
              windowSeconds: 0,
              recoveryRate: 2,
              hrvRecoverySlope: 1,
              heartRateNormalization: -1,
              baselineReturnSeconds: const Value(-1),
              resilienceScore: 120,
              fatigueScore: -1,
              stressCarryover: 2,
              resilienceLevel: 'invalid',
            ),
          );

      final report = await service.runIntegrityAudit();

      expect(report.issues, contains(contains('invalid window')));
      expect(report.issues, contains(contains('recoveryRate outside')));
      expect(report.issues, contains(contains('HR normalization outside')));
      expect(report.issues, contains(contains('resilienceScore outside')));
      expect(report.issues, contains(contains('fatigueScore outside')));
      expect(report.issues, contains(contains('stressCarryover outside')));
      expect(report.issues, contains(contains('invalid resilienceLevel')));
      expect(report.warnings, contains(contains('negative baseline return')));
    });
  });
}
