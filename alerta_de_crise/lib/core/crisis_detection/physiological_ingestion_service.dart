import 'package:flutter/foundation.dart';

import '../../sensor_quality/sensor_quality_models.dart';
import '../../sensor_quality/sensor_quality_service.dart';
import 'baseline_profile.dart';
import 'cognitive_check_response.dart';
import 'crisis_detection_service.dart';
import 'crisis_risk_result.dart';
import 'sensor_provider_registry.dart';

class PhysiologicalIngestionService {
  final SensorProviderRegistry _registry;
  final CrisisDetectionService _detectionService;
  final SensorQualityService _qualityService;
  SensorQualityEvaluation? _lastQualityEvaluation;

  PhysiologicalIngestionService({
    required SensorProviderRegistry registry,
    required CrisisDetectionService detectionService,
    SensorQualityService qualityService = const SensorQualityService(),
  }) : _registry = registry,
       _detectionService = detectionService,
       _qualityService = qualityService;

  SensorQualityEvaluation? get lastQualityEvaluation => _lastQualityEvaluation;

  Future<CrisisRiskResult?> processLatestSample({
    required BaselineProfile baseline,
    CognitiveCheckResponse cognitiveResponse = CognitiveCheckResponse.notAsked,
  }) async {
    final provider = _registry.getCurrent();
    final sample = await provider.getLatestSample();

    if (sample == null) {
      return null;
    }

    _lastQualityEvaluation = _qualityService.evaluateSampleQuality(
      sample: sample,
    );
    final warnings = _lastQualityEvaluation?.warnings ?? const [];
    if (warnings.isNotEmpty) {
      debugPrint(
        '[SignalFlowSensorQuality] provider=${provider.type.name} '
        'quality=${_lastQualityEvaluation?.signalQuality.name} '
        'score=${_lastQualityEvaluation?.confidenceScore.overallScore} '
        'warnings=${warnings.join(',')}',
      );
    }

    return _detectionService.evaluateAndRecord(
      sample: sample,
      baseline: baseline,
      cognitiveResponse: cognitiveResponse,
      source: provider.type.name,
    );
  }
}
