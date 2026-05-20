import 'experimental_protocol_models.dart';
import 'protocol_phase.dart';

class ProtocolSessionBuilder {
  const ProtocolSessionBuilder();

  ProtocolExecutionSession buildSession({
    required ExperimentalProtocol protocol,
    required DateTime startedAt,
  }) {
    return ProtocolExecutionSession(
      id: 'protocol-session-${protocol.id}-${startedAt.microsecondsSinceEpoch}',
      protocol: protocol,
      startedAt: startedAt,
      completedAt: null,
      currentPhaseIndex: 0,
      generatedMarkers: [
        'protocol_started',
        'protocol_phase_started:${protocol.phases.first.id}',
      ],
      benchmarkId:
          'benchmark-${protocol.id}-${startedAt.millisecondsSinceEpoch}',
      completed: false,
    );
  }

  List<String> buildPhaseMarkers(ProtocolPhase phase, {required bool started}) {
    return [
      started
          ? 'protocol_phase_started:${phase.id}'
          : 'protocol_phase_completed:${phase.id}',
    ];
  }

  Map<String, Object> buildReplayMetadata(ProtocolExecutionSession session) {
    return {
      'protocolId': session.protocol.id,
      'benchmarkId': session.benchmarkId,
      'phaseCount': session.protocol.phases.length,
      'totalDurationSeconds': session.protocol.totalDuration.inSeconds,
      'context': 'contexto experimental',
    };
  }

  Map<String, Object> buildContextualEvent(ProtocolPhase phase) {
    return {
      'category': phase.phaseType.name,
      'label': phase.title,
      'description': 'fase experimental em sessão controlada',
      'source': 'experimental_protocol',
    };
  }
}
