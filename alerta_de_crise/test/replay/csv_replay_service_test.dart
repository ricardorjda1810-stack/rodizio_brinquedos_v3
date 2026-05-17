import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/crisis_detection_service.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_engine.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';
import 'package:signalflow/data/crisis_detection/crisis_risk_event_repository.dart';
import 'package:signalflow/replay/csv_replay_service.dart';

void main() {
  group('CsvReplayService', () {
    test('replay calculates statistics and creates valid session', () {
      final repository = CrisisRiskEventRepository();
      final createdAt = DateTime(2026, 5, 16, 11);
      final service = CsvReplayService(
        detectionService: CrisisDetectionService(
          engine: const CrisisRiskEngine(),
          repository: repository,
        ),
        clock: () => createdAt,
      );

      final session = service.runReplay(samples: _samples());

      expect(session.id, 'csv-replay-${createdAt.microsecondsSinceEpoch}');
      expect(session.totalSamples, 5);
      expect(session.processedSamples, 5);
      expect(session.startedAt, _samples().first.timestamp);
      expect(session.completedAt, _samples().last.timestamp);
      expect(session.averageScore, greaterThan(0));
      expect(session.highestScore, greaterThanOrEqualTo(session.averageScore));
      expect(repository.listAll(), hasLength(5));
    });

    test('averageScore and highestScore are consistent', () {
      final service = CsvReplayService(
        detectionService: CrisisDetectionService(
          engine: const CrisisRiskEngine(),
          repository: CrisisRiskEventRepository(),
        ),
      );

      final session = service.runReplay(samples: _samples());

      expect(session.averageScore, session.statistics.averageScore);
      expect(session.highestScore, session.statistics.highestScore);
      expect(session.highInterventionCount, 0);
      expect(session.statistics.averageHeartRate, closeTo(88.8, 0.1));
      expect(session.statistics.averageHrv, closeTo(36.6, 0.1));
    });
  });
}

List<PhysiologicalSample> _samples() {
  return [
    _sample(0, 72, 45),
    _sample(5, 88, 38),
    _sample(10, 96, 30),
    _sample(15, 102, 25),
    _sample(20, 86, 45, movement: 0.7),
  ];
}

PhysiologicalSample _sample(
  int seconds,
  double heartRate,
  double hrv, {
  double movement = 0.1,
}) {
  return PhysiologicalSample(
    timestamp: DateTime(2026, 5, 16, 10, 0, seconds),
    heartRateBpm: heartRate,
    hrvRmssdMs: hrv,
    spo2Percent: 98,
    movementIntensity: movement,
    respiratoryRate: 16,
  );
}
