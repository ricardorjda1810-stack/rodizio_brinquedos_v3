import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/baseline_profile.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/core/crisis_detection/crisis_detection_service.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_engine.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_result.dart';
import 'package:signalflow/core/crisis_detection/physiological_sample.dart';
import 'package:signalflow/data/crisis_detection/crisis_risk_event_repository.dart';

void main() {
  group('CrisisDetectionService', () {
    test('evaluateAndRecord returns CrisisRiskResult', () {
      final repository = CrisisRiskEventRepository();
      final service = _service(repository);

      final result = service.evaluateAndRecord(
        sample: _sample(),
        baseline: BaselineProfile.safeDefault(),
      );

      expect(result, isA<CrisisRiskResult>());
    });

    test('evaluateAndRecord saves a CrisisRiskEvent', () {
      final repository = CrisisRiskEventRepository();
      final service = _service(repository);

      service.evaluateAndRecord(
        sample: _sample(),
        baseline: BaselineProfile.safeDefault(),
      );

      expect(repository.listAll(), hasLength(1));
    });

    test('saved event preserves result fields and cognitive response', () {
      final repository = CrisisRiskEventRepository();
      final service = _service(repository);

      final result = service.evaluateAndRecord(
        sample: _sample(heartRateBpm: 106, hrvRmssdMs: 20),
        baseline: BaselineProfile.safeDefault(),
        cognitiveResponse: CognitiveCheckResponse.needsHelp,
      );
      final event = repository.listAll().single;

      expect(event.score, result.score);
      expect(event.level, result.level);
      expect(event.reasonCodes, result.reasonCodes);
      expect(event.recommendedAction, result.recommendedAction);
      expect(event.cognitiveResponse, CognitiveCheckResponse.needsHelp);
    });

    test("default source is 'debug'", () {
      final repository = CrisisRiskEventRepository();
      final service = _service(repository);

      service.evaluateAndRecord(
        sample: _sample(),
        baseline: BaselineProfile.safeDefault(),
      );

      expect(repository.listAll().single.source, 'debug');
    });

    test('custom source is preserved', () {
      final repository = CrisisRiskEventRepository();
      final service = _service(repository);

      service.evaluateAndRecord(
        sample: _sample(),
        baseline: BaselineProfile.safeDefault(),
        source: 'simulator:normal',
      );

      expect(repository.listAll().single.source, 'simulator:normal');
    });

    test('multiple evaluations generate different ids', () async {
      final repository = CrisisRiskEventRepository();
      final service = _service(repository);

      service.evaluateAndRecord(
        sample: _sample(),
        baseline: BaselineProfile.safeDefault(),
      );
      await Future<void>.delayed(const Duration(microseconds: 1));
      service.evaluateAndRecord(
        sample: _sample(),
        baseline: BaselineProfile.safeDefault(),
      );

      final ids = repository.listAll().map((event) => event.id).toSet();

      expect(repository.listAll(), hasLength(2));
      expect(ids, hasLength(2));
    });
  });
}

CrisisDetectionService _service(CrisisRiskEventRepository repository) {
  return CrisisDetectionService(
    engine: const CrisisRiskEngine(),
    repository: repository,
  );
}

PhysiologicalSample _sample({
  double heartRateBpm = 72,
  double hrvRmssdMs = 45,
}) {
  return PhysiologicalSample(
    timestamp: DateTime(2026, 5, 16, 10),
    heartRateBpm: heartRateBpm,
    movementIntensity: 0.1,
    hrvRmssdMs: hrvRmssdMs,
    spo2Percent: 98,
    respiratoryRate: 16,
  );
}
