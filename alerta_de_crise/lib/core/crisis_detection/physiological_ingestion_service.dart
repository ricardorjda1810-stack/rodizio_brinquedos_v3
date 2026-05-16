import 'baseline_profile.dart';
import 'cognitive_check_response.dart';
import 'crisis_detection_service.dart';
import 'crisis_risk_result.dart';
import 'sensor_provider_registry.dart';

class PhysiologicalIngestionService {
  final SensorProviderRegistry _registry;
  final CrisisDetectionService _detectionService;

  const PhysiologicalIngestionService({
    required SensorProviderRegistry registry,
    required CrisisDetectionService detectionService,
  }) : _registry = registry,
       _detectionService = detectionService;

  Future<CrisisRiskResult?> processLatestSample({
    required BaselineProfile baseline,
    CognitiveCheckResponse cognitiveResponse = CognitiveCheckResponse.notAsked,
  }) async {
    final provider = _registry.getCurrent();
    final sample = await provider.getLatestSample();

    if (sample == null) {
      return null;
    }

    return _detectionService.evaluateAndRecord(
      sample: sample,
      baseline: baseline,
      cognitiveResponse: cognitiveResponse,
      source: provider.type.name,
    );
  }
}
