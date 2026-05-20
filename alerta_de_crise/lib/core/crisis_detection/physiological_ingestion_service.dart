import 'package:flutter/foundation.dart';

import '../../adaptive_baseline/adaptive_baseline_models.dart';
import '../../adaptive_baseline/adaptive_baseline_service.dart';
import '../../physiological_trends/physiological_trend_service.dart';
import '../../sensor_quality/sensor_quality_models.dart';
import '../../sensor_quality/sensor_quality_service.dart';
import '../../session_timeline/physiological_event_marker.dart';
import '../../session_timeline/session_timeline_service.dart';
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
  final SessionTimelineService? _timelineService;
  final PhysiologicalTrendService? _trendService;
  SensorQualityEvaluation? _lastQualityEvaluation;

  PhysiologicalIngestionService({
    required SensorProviderRegistry registry,
    required CrisisDetectionService detectionService,
    SensorQualityService qualityService = const SensorQualityService(),
    AdaptiveBaselineService? adaptiveBaselineService,
    SessionTimelineService? timelineService,
    PhysiologicalTrendService? trendService,
  }) : _registry = registry,
       _detectionService = detectionService,
       _qualityService = qualityService,
       _adaptiveBaselineService =
           adaptiveBaselineService ?? AdaptiveBaselineService(),
       _timelineService = timelineService,
       _trendService = trendService;

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
    await _recordTimelineQualityMarkers(sample, warnings);

    final contextualBaseline = _contextualBaseline(
      fallbackBaseline: baseline,
      adaptiveBaseline: adaptiveBaseline,
      sample: sample,
    );

    final result = _detectionService.evaluateAndRecord(
      sample: sample,
      baseline: contextualBaseline,
      cognitiveResponse: cognitiveResponse,
      source: provider.type.name,
    );
    await _recordTimelineSampleAndRiskMarkers(
      sample: sample,
      baseline: contextualBaseline,
      source: provider.type.name,
    );
    await _recordTrendIfAvailable(adaptiveBaseline);
    return result;
  }

  Future<void> _recordTrendIfAvailable(
    AdaptiveBaselineProfile? adaptiveBaseline,
  ) async {
    final timelineService = _timelineService;
    final trendService = _trendService;
    final timeline = timelineService?.currentTimeline;
    if (timelineService == null ||
        trendService == null ||
        timeline == null ||
        !timelineService.isActive ||
        timelineService.samples.length < 3) {
      return;
    }

    await trendService.analyzeTimeline(
      timeline: timeline,
      samples: timelineService.samples,
      markers: timelineService.markers,
      timelineService: timelineService,
      adaptiveBaseline: adaptiveBaseline,
    );
  }

  Future<void> _recordTimelineQualityMarkers(
    PhysiologicalSample sample,
    List<String> warnings,
  ) async {
    final timelineService = _timelineService;
    if (timelineService == null || !timelineService.isActive) {
      return;
    }

    if (warnings.contains('high_movement_reduces_confidence')) {
      await timelineService.addMarker(
        _marker(
          sample: sample,
          type: EventType.movementArtifact,
          title: 'Movimento elevado',
          description: 'Movimento pode reduzir a confiança do sinal.',
          severity: Severity.medium,
          source: 'sensor_quality',
        ),
      );
    }

    final evaluation = _lastQualityEvaluation;
    if (evaluation != null && evaluation.confidenceScore.overallScore < 50) {
      await timelineService.addMarker(
        _marker(
          sample: sample,
          type: EventType.lowConfidenceSignal,
          title: 'Sinal com baixa confiança',
          description: 'Qualidade do sinal fisiológico ficou degradada.',
          severity: Severity.medium,
          source: 'sensor_quality',
        ),
      );
    }
  }

  Future<void> _recordTimelineSampleAndRiskMarkers({
    required PhysiologicalSample sample,
    required BaselineProfile baseline,
    required String source,
  }) async {
    final timelineService = _timelineService;
    if (timelineService == null || !timelineService.isActive) {
      return;
    }

    await timelineService.addSample(sample);
    if (sample.heartRateBpm >= baseline.restingHeartRateBpm + 15 &&
        sample.movementIntensity <= 0.35) {
      await timelineService.addMarker(
        _marker(
          sample: sample,
          type: EventType.elevatedHeartRate,
          title: 'FC acima do padrão',
          description: 'Frequência cardíaca acima do baseline contextual.',
          severity: Severity.medium,
          source: source,
        ),
      );
    }

    final hrv = sample.hrvRmssdMs;
    if (hrv != null && hrv < baseline.hrvRmssdMs * 0.75) {
      await timelineService.addMarker(
        _marker(
          sample: sample,
          type: EventType.hrvDrop,
          title: 'HRV abaixo do padrão',
          description: 'HRV abaixo do baseline contextual.',
          severity: Severity.medium,
          source: source,
        ),
      );
    }
  }

  PhysiologicalEventMarker _marker({
    required PhysiologicalSample sample,
    required EventType type,
    required String title,
    required String description,
    required Severity severity,
    required String source,
  }) {
    return PhysiologicalEventMarker(
      id: 'marker-${sample.timestamp.microsecondsSinceEpoch}-${type.name}',
      timestamp: sample.timestamp,
      type: type,
      title: title,
      description: description,
      severity: severity,
      source: source,
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
