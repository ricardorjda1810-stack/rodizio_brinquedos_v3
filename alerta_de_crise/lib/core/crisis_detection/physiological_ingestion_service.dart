import 'package:flutter/foundation.dart';

import '../../adaptive_baseline/adaptive_baseline_models.dart';
import '../../adaptive_baseline/adaptive_baseline_service.dart';
import '../../sensor_quality/sensor_quality_models.dart';
import '../../sensor_quality/sensor_quality_service.dart';
import 'baseline_profile.dart';
import 'cognitive_check_response.dart';
import 'crisis_detection_service.dart';
import 'crisis_risk_result.dart';
import 'physiological_sample.dart';
import 'sensor_provider_registry.dart';

class PhysiologicalIngestionService {
  final SensorProviderRegistry _registry;
  final CrisisDetectionService _detectionService;
  final SensorQualityService _qualityService;
  final AdaptiveBaselineService _adaptiveBaselineService;
  SensorQualityEvaluation? _lastQualityEvaluation;

  PhysiologicalIngestionService({
    required SensorProviderRegistry registry,
    required CrisisDetectionService detectionService,
    SensorQualityService qualityService = const SensorQualityService(),
    AdaptiveBaselineService? adaptiveBaselineService,
  }) : _registry = registry,
       _detectionService = detectionService,
       _qualityService = qualityService,
       _adaptiveBaselineService =
           adaptiveBaselineService ?? AdaptiveBaselineService();

  SensorQualityEvaluation? get lastQualityEvaluation => _lastQualityEvaluation;

  Future<CrisisRiskResult?> processLatestSample({
    required BaselineProfile baseline,
    CognitiveCheckResponse cognitiveResponse = CognitiveCheckResponse.notAsked,
    AdaptiveBaselineProfile? adaptiveBaseline,
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

    final contextualBaseline = _contextualBaseline(
      fallbackBaseline: baseline,
      adaptiveBaseline: adaptiveBaseline,
      sample: sample,
    );

    return _detectionService.evaluateAndRecord(
      sample: sample,
      baseline: contextualBaseline,
      cognitiveResponse: cognitiveResponse,
      source: provider.type.name,
    );
  }

  BaselineProfile _contextualBaseline({
    required BaselineProfile fallbackBaseline,
    required AdaptiveBaselineProfile? adaptiveBaseline,
    required PhysiologicalSample sample,
  }) {
    if (adaptiveBaseline == null) {
      return fallbackBaseline;
    }

    final circadianProfile = _adaptiveBaselineService
        .getCurrentCircadianProfile(
          baseline: adaptiveBaseline,
          timestamp: sample.timestamp,
        );
    if (circadianProfile == null) {
      return adaptiveBaseline.globalBaseline;
    }

    return BaselineProfile(
      restingHeartRateBpm: circadianProfile.averageHeartRate,
      hrvRmssdMs:
          circadianProfile.averageHrv ??
          adaptiveBaseline.globalBaseline.hrvRmssdMs,
      respiratoryRate:
          circadianProfile.averageRespiratoryRate ??
          adaptiveBaseline.globalBaseline.respiratoryRate,
      movementIntensity: adaptiveBaseline.globalBaseline.movementIntensity,
    );
  }
}
