import 'protocol_phase.dart';

class ExperimentalProtocol {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final List<ProtocolPhase> phases;
  final Duration totalDuration;
  final List<String> recommendedSensors;

  const ExperimentalProtocol({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.phases,
    required this.totalDuration,
    required this.recommendedSensors,
  });

  String get safetyCopy =>
      'protocolo experimental para coleta fisiológica controlada; não representa avaliação clínica.';
}

class ProtocolExecutionSession {
  final String id;
  final ExperimentalProtocol protocol;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int currentPhaseIndex;
  final List<String> generatedMarkers;
  final String benchmarkId;
  final bool completed;

  const ProtocolExecutionSession({
    required this.id,
    required this.protocol,
    required this.startedAt,
    required this.completedAt,
    required this.currentPhaseIndex,
    required this.generatedMarkers,
    required this.benchmarkId,
    required this.completed,
  });

  ProtocolPhase? get currentPhase {
    if (currentPhaseIndex < 0 || currentPhaseIndex >= protocol.phases.length) {
      return null;
    }
    return protocol.phases[currentPhaseIndex];
  }

  Duration get elapsedPlannedDuration {
    final phaseCount = currentPhaseIndex.clamp(0, protocol.phases.length);
    return protocol.phases
        .take(phaseCount)
        .fold(Duration.zero, (total, phase) => total + phase.duration);
  }

  String get safetyCopy =>
      'sessão controlada de protocolo experimental em contexto experimental.';

  ProtocolExecutionSession copyWith({
    DateTime? completedAt,
    int? currentPhaseIndex,
    List<String>? generatedMarkers,
    bool? completed,
  }) {
    return ProtocolExecutionSession(
      id: id,
      protocol: protocol,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      generatedMarkers: generatedMarkers ?? this.generatedMarkers,
      benchmarkId: benchmarkId,
      completed: completed ?? this.completed,
    );
  }
}
