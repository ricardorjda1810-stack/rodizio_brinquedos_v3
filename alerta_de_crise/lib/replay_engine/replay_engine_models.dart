import '../contextual_triggers/contextual_event.dart';
import '../core/crisis_detection/physiological_sample.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/physiological_event_marker.dart';

enum ReplayScenarioType {
  stable,
  escalating,
  recovery,
  noisySignal,
  prolongedStress,
  circadianShift,
  contextualTrigger,
  syntheticMixed,
}

enum ReplayPlaybackState { stopped, running, paused }

class ReplayScenario {
  final String id;
  final String title;
  final String description;
  final DateTime generatedAt;
  final Duration duration;
  final int sampleCount;
  final ReplayScenarioType scenarioType;
  final String expectedEscalationLevel;
  final List<String> contextualFactors;

  const ReplayScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.generatedAt,
    required this.duration,
    required this.sampleCount,
    required this.scenarioType,
    required this.expectedEscalationLevel,
    required this.contextualFactors,
  });

  String get safetyCopy =>
      'simulação experimental; cenário sintético; não representa evento real.';
}

class SyntheticReplayDataset {
  final ReplayScenario scenario;
  final List<PhysiologicalSample> samples;
  final List<PhysiologicalEventMarker> markers;
  final List<ContextualEvent> contextualEvents;
  final List<EscalationForecast> forecasts;

  const SyntheticReplayDataset({
    required this.scenario,
    required this.samples,
    this.markers = const [],
    this.contextualEvents = const [],
    this.forecasts = const [],
  });
}

class ReplayTimelineState {
  final DateTime timestamp;
  final PhysiologicalSample? sample;
  final List<PhysiologicalEventMarker> markers;
  final List<ContextualEvent> contextualEvents;
  final EscalationForecast? forecast;
  final double progress;
  final int index;

  const ReplayTimelineState({
    required this.timestamp,
    required this.sample,
    required this.markers,
    required this.contextualEvents,
    required this.forecast,
    required this.progress,
    required this.index,
  });
}

class ReplaySession {
  final ReplayScenario scenario;
  final ReplayPlaybackState state;
  final double playbackSpeed;
  final ReplayTimelineState timelineState;
  final DateTime updatedAt;

  const ReplaySession({
    required this.scenario,
    required this.state,
    required this.playbackSpeed,
    required this.timelineState,
    required this.updatedAt,
  });
}

class ReplayValidationResult {
  final String id;
  final String scenarioId;
  final DateTime generatedAt;
  final double replayConsistency;
  final double timelineConsistency;
  final double forecastConsistency;
  final double escalationDetectionScore;
  final double recoveryModelingScore;
  final List<String> findings;

  const ReplayValidationResult({
    required this.id,
    required this.scenarioId,
    required this.generatedAt,
    required this.replayConsistency,
    required this.timelineConsistency,
    required this.forecastConsistency,
    required this.escalationDetectionScore,
    required this.recoveryModelingScore,
    required this.findings,
  });

  String get safetyCopy =>
      'validação offline por modelagem experimental; não representa evento real.';
}
