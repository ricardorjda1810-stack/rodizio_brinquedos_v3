import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/baseline_profile.dart';
import 'package:signalflow/core/crisis_detection/crisis_detection_service.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_engine.dart';
import 'package:signalflow/core/crisis_detection/crisis_risk_result.dart';
import 'package:signalflow/core/crisis_detection/physiological_ingestion_service.dart';
import 'package:signalflow/core/crisis_detection/sensor_provider_registry.dart';
import 'package:signalflow/core/crisis_detection/simulated_sensor_provider.dart';
import 'package:signalflow/data/crisis_detection/crisis_risk_event_repository.dart';

void main() {
  group('PhysiologicalIngestionService', () {
    test('processes sample', () async {
      final repository = CrisisRiskEventRepository();
      final service = _service(repository);

      await service.processLatestSample(
        baseline: BaselineProfile.safeDefault(),
      );

      expect(repository.listAll(), hasLength(1));
    });

    test('returns CrisisRiskResult', () async {
      final service = _service(CrisisRiskEventRepository());

      final result = await service.processLatestSample(
        baseline: BaselineProfile.safeDefault(),
      );

      expect(result, isA<CrisisRiskResult>());
    });
  });
}

PhysiologicalIngestionService _service(CrisisRiskEventRepository repository) {
  return PhysiologicalIngestionService(
    registry: SensorProviderRegistry(
      defaultProvider: SimulatedSensorProvider(),
    ),
    detectionService: CrisisDetectionService(
      engine: const CrisisRiskEngine(),
      repository: repository,
    ),
  );
}
