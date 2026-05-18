import '../contextual_triggers/contextual_event.dart';
import '../core/crisis_detection/physiological_sample.dart';
import '../predictive_forecasting/physiological_forecast_window.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import 'replay_engine_models.dart';

class SyntheticScenarioGenerator {
  final DateTime Function() _now;

  const SyntheticScenarioGenerator({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  SyntheticReplayDataset generateSyntheticScenario({
    ReplayScenarioType type = ReplayScenarioType.syntheticMixed,
    int sampleCount = 24,
    Duration interval = const Duration(seconds: 30),
  }) {
    switch (type) {
      case ReplayScenarioType.escalating:
      case ReplayScenarioType.prolongedStress:
      case ReplayScenarioType.contextualTrigger:
        return generateEscalationScenario(
          sampleCount: sampleCount,
          interval: interval,
          type: type,
        );
      case ReplayScenarioType.recovery:
        return generateRecoveryScenario(
          sampleCount: sampleCount,
          interval: interval,
        );
      case ReplayScenarioType.noisySignal:
      case ReplayScenarioType.circadianShift:
      case ReplayScenarioType.stable:
      case ReplayScenarioType.syntheticMixed:
        return _buildDataset(
          type: type,
          sampleCount: sampleCount,
          interval: interval,
        );
    }
  }

  SyntheticReplayDataset generateEscalationScenario({
    int sampleCount = 24,
    Duration interval = const Duration(seconds: 30),
    ReplayScenarioType type = ReplayScenarioType.escalating,
  }) {
    return _buildDataset(
      type: type,
      sampleCount: sampleCount,
      interval: interval,
    );
  }

  SyntheticReplayDataset generateRecoveryScenario({
    int sampleCount = 24,
    Duration interval = const Duration(seconds: 30),
  }) {
    return _buildDataset(
      type: ReplayScenarioType.recovery,
      sampleCount: sampleCount,
      interval: interval,
    );
  }

  SyntheticReplayDataset _buildDataset({
    required ReplayScenarioType type,
    required int sampleCount,
    required Duration interval,
  }) {
    final count = sampleCount.clamp(2, 500);
    final generatedAt = _now();
    final start = generatedAt.subtract(interval * (count - 1));
    final samples = List<PhysiologicalSample>.generate(count, (index) {
      final progress = count == 1 ? 0.0 : index / (count - 1);
      return _sampleForType(type, start.add(interval * index), progress, index);
    }, growable: false);
    final scenario = ReplayScenario(
      id: 'replay-${type.name}-${generatedAt.microsecondsSinceEpoch}',
      title: _titleFor(type),
      description:
          'simulação experimental de replay fisiológico para validação offline.',
      generatedAt: generatedAt,
      duration: interval * (count - 1),
      sampleCount: samples.length,
      scenarioType: type,
      expectedEscalationLevel: _expectedEscalationFor(type),
      contextualFactors: _contextualFactorsFor(type),
    );
    return SyntheticReplayDataset(
      scenario: scenario,
      samples: samples,
      markers: _markersFor(type, samples),
      contextualEvents: _contextualEventsFor(type, generatedAt, samples),
      forecasts: _forecastsFor(type, generatedAt),
    );
  }

  PhysiologicalSample _sampleForType(
    ReplayScenarioType type,
    DateTime timestamp,
    double progress,
    int index,
  ) {
    final jitter = index.isEven ? 1.5 : -1.0;
    switch (type) {
      case ReplayScenarioType.stable:
        return PhysiologicalSample(
          timestamp: timestamp,
          heartRateBpm: 70 + jitter,
          hrvRmssdMs: 42 - jitter,
          movementIntensity: 0.1,
        );
      case ReplayScenarioType.escalating:
      case ReplayScenarioType.contextualTrigger:
        return PhysiologicalSample(
          timestamp: timestamp,
          heartRateBpm: 72 + (28 * progress) + jitter,
          hrvRmssdMs: 42 - (18 * progress),
          movementIntensity: 0.12,
        );
      case ReplayScenarioType.recovery:
        return PhysiologicalSample(
          timestamp: timestamp,
          heartRateBpm: 98 - (26 * progress) + jitter,
          hrvRmssdMs: 24 + (18 * progress),
          movementIntensity: 0.08,
        );
      case ReplayScenarioType.noisySignal:
        return PhysiologicalSample(
          timestamp: timestamp,
          heartRateBpm: 78 + (index.isEven ? 14 : -10),
          hrvRmssdMs: index % 3 == 0 ? null : 34 + jitter,
          movementIntensity: index.isEven ? 0.7 : 0.2,
        );
      case ReplayScenarioType.prolongedStress:
        return PhysiologicalSample(
          timestamp: timestamp,
          heartRateBpm: 86 + (8 * progress) + jitter,
          hrvRmssdMs: 30 - (6 * progress),
          movementIntensity: 0.18,
        );
      case ReplayScenarioType.circadianShift:
        return PhysiologicalSample(
          timestamp: timestamp,
          heartRateBpm: 68 + (progress > 0.55 ? 16 : 2) + jitter,
          hrvRmssdMs: 44 - (progress > 0.55 ? 12 : 2),
          movementIntensity: 0.1,
        );
      case ReplayScenarioType.syntheticMixed:
        return PhysiologicalSample(
          timestamp: timestamp,
          heartRateBpm:
              72 + (progress * 16) - (progress > 0.7 ? 10 : 0) + jitter,
          hrvRmssdMs: 42 - (progress * 14) + (progress > 0.7 ? 8 : 0),
          movementIntensity: 0.15,
        );
    }
  }

  List<PhysiologicalEventMarker> _markersFor(
    ReplayScenarioType type,
    List<PhysiologicalSample> samples,
  ) {
    if (samples.isEmpty) {
      return const [];
    }
    final timestamp = samples[(samples.length * 0.65).floor()].timestamp;
    return [
      PhysiologicalEventMarker(
        id: 'marker-${type.name}-${timestamp.microsecondsSinceEpoch}',
        timestamp: timestamp,
        type: _markerTypeFor(type),
        title: 'modelagem experimental',
        description: 'cenário sintético para validação offline',
        severity: _severityFor(type),
        source: 'replay_engine',
      ),
    ];
  }

  List<ContextualEvent> _contextualEventsFor(
    ReplayScenarioType type,
    DateTime generatedAt,
    List<PhysiologicalSample> samples,
  ) {
    if (type != ReplayScenarioType.contextualTrigger &&
        type != ReplayScenarioType.syntheticMixed) {
      return const [];
    }
    return [
      ContextualEvent(
        id: 'context-${generatedAt.microsecondsSinceEpoch}',
        timestamp: samples.first.timestamp,
        category: ContextualCategory.work,
        label: 'contexto simulado',
        description: 'cenário sintético; não representa evento real',
        intensity: ContextualIntensity.medium,
        source: 'replay_engine',
      ),
    ];
  }

  List<EscalationForecast> _forecastsFor(
    ReplayScenarioType type,
    DateTime generatedAt,
  ) {
    final probability = switch (type) {
      ReplayScenarioType.stable => 16.0,
      ReplayScenarioType.recovery => 28.0,
      ReplayScenarioType.noisySignal => 44.0,
      ReplayScenarioType.escalating ||
      ReplayScenarioType.contextualTrigger ||
      ReplayScenarioType.prolongedStress => 76.0,
      ReplayScenarioType.circadianShift => 52.0,
      ReplayScenarioType.syntheticMixed => 58.0,
    };
    return [
      EscalationForecast(
        id: 'forecast-${type.name}-${generatedAt.microsecondsSinceEpoch}',
        generatedAt: generatedAt,
        forecastWindow: PhysiologicalForecastWindow.nearFuture,
        escalationProbability: probability,
        forecastConfidence: ForecastConfidenceResult(
          score: probability > 65 ? 70 : 58,
          level: probability > 65
              ? ForecastConfidenceLevel.highConfidence
              : ForecastConfidenceLevel.mediumConfidence,
          factors: const ['cenário sintético', 'validação offline'],
        ),
        escalationRiskLevel: _riskLevelFor(probability),
        contributingFactors: _contextualFactorsFor(type),
        recoveryProtection: type == ReplayScenarioType.recovery ? 78 : 34,
        autonomicLoad: probability,
      ),
    ];
  }

  ForecastRiskLevel _riskLevelFor(double probability) {
    if (probability >= 75) return ForecastRiskLevel.high;
    if (probability >= 55) return ForecastRiskLevel.elevated;
    if (probability >= 30) return ForecastRiskLevel.moderate;
    return ForecastRiskLevel.low;
  }

  EventType _markerTypeFor(ReplayScenarioType type) {
    return switch (type) {
      ReplayScenarioType.recovery => EventType.recoveryProtectiveEffect,
      ReplayScenarioType.stable => EventType.manualMarker,
      ReplayScenarioType.noisySignal => EventType.lowConfidenceSignal,
      _ => EventType.forecastElevatedRisk,
    };
  }

  Severity _severityFor(ReplayScenarioType type) {
    return switch (type) {
      ReplayScenarioType.escalating ||
      ReplayScenarioType.contextualTrigger ||
      ReplayScenarioType.prolongedStress => Severity.high,
      ReplayScenarioType.noisySignal ||
      ReplayScenarioType.circadianShift ||
      ReplayScenarioType.syntheticMixed => Severity.medium,
      ReplayScenarioType.stable || ReplayScenarioType.recovery => Severity.low,
    };
  }

  String _titleFor(ReplayScenarioType type) {
    return switch (type) {
      ReplayScenarioType.stable => 'Stable synthetic replay',
      ReplayScenarioType.escalating => 'Escalating synthetic replay',
      ReplayScenarioType.recovery => 'Recovery synthetic replay',
      ReplayScenarioType.noisySignal => 'Noisy signal replay',
      ReplayScenarioType.prolongedStress => 'Prolonged stress replay',
      ReplayScenarioType.circadianShift => 'Circadian shift replay',
      ReplayScenarioType.contextualTrigger => 'Contextual trigger replay',
      ReplayScenarioType.syntheticMixed => 'Mixed synthetic replay',
    };
  }

  String _expectedEscalationFor(ReplayScenarioType type) {
    return switch (type) {
      ReplayScenarioType.stable => 'low',
      ReplayScenarioType.recovery => 'moderate_then_reducing',
      ReplayScenarioType.noisySignal => 'uncertain',
      ReplayScenarioType.escalating ||
      ReplayScenarioType.contextualTrigger ||
      ReplayScenarioType.prolongedStress => 'elevated',
      ReplayScenarioType.circadianShift => 'moderate',
      ReplayScenarioType.syntheticMixed => 'variable',
    };
  }

  List<String> _contextualFactorsFor(ReplayScenarioType type) {
    return switch (type) {
      ReplayScenarioType.contextualTrigger => const [
        'contexto',
        'gatilho potencial',
      ],
      ReplayScenarioType.noisySignal => const ['qualidade de sinal reduzida'],
      ReplayScenarioType.prolongedStress => const [
        'carga autonômica prolongada',
      ],
      ReplayScenarioType.circadianShift => const ['variação circadiana'],
      _ => const ['cenário sintético'],
    };
  }
}
