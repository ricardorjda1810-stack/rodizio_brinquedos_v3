import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/baseline_profile.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_result.dart';
import 'package:signalflow/data/crisis_detection/baseline_profile_repository.dart';
import 'package:signalflow/data/crisis_detection/crisis_risk_event.dart';
import 'package:signalflow/data/crisis_detection/crisis_risk_event_repository.dart';
import 'package:signalflow/data/crisis_detection/intervention_history_entry.dart';
import 'package:signalflow/data/crisis_detection/intervention_history_repository.dart';
import 'package:signalflow/database/signalflow_database.dart';
import 'package:signalflow/research_consent/research_consent_models.dart';
import 'package:signalflow/research_consent/research_consent_repository.dart';

void main() {
  group('SignalFlowDatabase', () {
    late SignalFlowDatabase database;

    setUp(() {
      database = SignalFlowDatabase.memory();
    });

    tearDown(() async {
      await database.close();
    });

    test('persists baseline profile across repository instances', () async {
      final baseline = BaselineProfile(
        restingHeartRateBpm: 68,
        hrvRmssdMs: 42,
        respiratoryRate: 15,
        movementIntensity: 0.12,
      );
      await BaselineProfileRepository(
        database: database,
      ).savePersistent(baseline);

      final reloadedRepository = BaselineProfileRepository(database: database);
      final loaded = await reloadedRepository.loadFromDatabase();

      expect(loaded?.restingHeartRateBpm, 68);
      expect(reloadedRepository.getCurrent()?.hrvRmssdMs, 42);
    });

    test(
      'persists crisis events and serializes reason codes as JSON',
      () async {
        final repository = CrisisRiskEventRepository(database: database);
        final event = _event(
          id: 'event-1',
          timestamp: DateTime.utc(2026, 5, 17, 10),
          reasonCodes: ['hrv_drop', 'user_reports_activation'],
        );

        await repository.savePersistent(event);

        final reloadedRepository = CrisisRiskEventRepository(
          database: database,
        );
        final events = await reloadedRepository.loadFromDatabase();

        expect(events, hasLength(1));
        expect(events.single.reasonCodes, [
          'hrv_drop',
          'user_reports_activation',
        ]);
        expect(
          events.single.timestamp.isAtSameMomentAs(
            DateTime.utc(2026, 5, 17, 10),
          ),
          isTrue,
        );
      },
    );

    test(
      'supports multiple crisis event inserts and recent ordering',
      () async {
        final repository = CrisisRiskEventRepository(database: database);
        await repository.savePersistent(
          _event(id: 'older', timestamp: DateTime.utc(2026, 5, 17, 9)),
        );
        await repository.savePersistent(
          _event(id: 'newer', timestamp: DateTime.utc(2026, 5, 17, 11)),
        );

        final recent = await repository.listRecentPersistent(limit: 1);

        expect(recent.single.id, 'newer');
      },
    );

    test('persists intervention history timestamps and scores', () async {
      final repository = InterventionHistoryRepository(database: database);
      final entry = _interventionEntry(
        id: 'entry-1',
        startedAt: DateTime.utc(2026, 5, 17, 10),
        completedAt: DateTime.utc(2026, 5, 17, 10, 5),
      );

      await repository.savePersistent(entry);

      final reloadedRepository = InterventionHistoryRepository(
        database: database,
      );
      final entries = await reloadedRepository.loadFromDatabase();

      expect(
        entries.single.completedAt.isAtSameMomentAs(
          DateTime.utc(2026, 5, 17, 10, 5),
        ),
        isTrue,
      );
      expect(entries.single.scoreDelta, -25);
      expect(entries.single.finalResponse, CognitiveCheckResponse.feelingOk);
    });

    test('persists and clears research consent', () async {
      final repository = ResearchConsentRepository(database: database);
      final consent = ResearchConsent(
        accepted: true,
        acceptedAt: DateTime.utc(2026, 5, 17, 12),
        version: ResearchConsentVersion.current,
        allowsPhysiologicalCollection: true,
        allowsResearchExport: true,
        allowsReplayAnalysis: false,
      );

      await repository.savePersistent(consent);
      final loaded = await ResearchConsentRepository(
        database: database,
      ).loadFromDatabase();

      expect(loaded?.accepted, isTrue);
      expect(loaded?.allowsReplayAnalysis, isFalse);

      await repository.clearPersistent();
      expect(await repository.loadFromDatabase(), isNull);
    });

    test('clearAllSignalFlowTables removes persisted rows', () async {
      await CrisisRiskEventRepository(
        database: database,
      ).savePersistent(_event(id: 'event-1'));
      await InterventionHistoryRepository(
        database: database,
      ).savePersistent(_interventionEntry(id: 'entry-1'));

      await database.clearAllSignalFlowTables();

      expect(
        await CrisisRiskEventRepository(database: database).loadFromDatabase(),
        isEmpty,
      );
      expect(
        await InterventionHistoryRepository(
          database: database,
        ).loadFromDatabase(),
        isEmpty,
      );
    });
  });
}

CrisisRiskEvent _event({
  required String id,
  DateTime? timestamp,
  List<String> reasonCodes = const [
    'heart_rate_above_baseline_without_movement',
  ],
}) {
  return CrisisRiskEvent(
    id: id,
    timestamp: timestamp ?? DateTime.utc(2026, 5, 17, 10),
    score: 55,
    level: CrisisRiskLevel.moderateAlert,
    reasonCodes: reasonCodes,
    recommendedAction: 'Sugerir pausa curta e pergunta cognitiva.',
    cognitiveResponse: CognitiveCheckResponse.feelingActivated,
    source: 'database-test',
  );
}

InterventionHistoryEntry _interventionEntry({
  required String id,
  DateTime? startedAt,
  DateTime? completedAt,
}) {
  return InterventionHistoryEntry(
    id: id,
    protocolId: 'standard',
    startedAt: startedAt ?? DateTime.utc(2026, 5, 17, 10),
    completedAt: completedAt ?? DateTime.utc(2026, 5, 17, 10, 5),
    durationSeconds: 300,
    completed: true,
    userReportedImprovement: true,
    finalResponse: CognitiveCheckResponse.feelingOk,
    preInterventionScore: 70,
    postInterventionScore: 45,
    scoreDelta: -25,
  );
}
