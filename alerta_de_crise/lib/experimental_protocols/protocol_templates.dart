import 'experimental_protocol_models.dart';
import 'protocol_phase.dart';

class ProtocolTemplates {
  static List<ExperimentalProtocol> all({DateTime? createdAt}) {
    return [
      basicRecoveryProtocol(createdAt: createdAt),
      escalationObservationProtocol(createdAt: createdAt),
      circadianBaselineProtocol(createdAt: createdAt),
    ];
  }

  static ExperimentalProtocol basicRecoveryProtocol({DateTime? createdAt}) {
    final phases = [
      const ProtocolPhase(
        id: 'resting-5m',
        title: '5 min resting',
        description: 'fase experimental de repouso para coleta fisiológica.',
        duration: Duration(minutes: 5),
        instructions: 'Manter uma sessão controlada em contexto experimental.',
        phaseType: ProtocolPhaseType.resting,
      ),
      const ProtocolPhase(
        id: 'breathing-5m',
        title: '5 min breathing',
        description: 'fase experimental de respiração observada.',
        duration: Duration(minutes: 5),
        instructions: 'Registrar sinais durante a coleta fisiológica.',
        phaseType: ProtocolPhaseType.breathing,
      ),
      const ProtocolPhase(
        id: 'recovery-5m',
        title: '5 min recovery',
        description: 'fase experimental de recuperação observada.',
        duration: Duration(minutes: 5),
        instructions: 'Encerrar com observação em sessão controlada.',
        phaseType: ProtocolPhaseType.recovery,
      ),
    ];
    return _build(
      id: 'basic-recovery-protocol',
      title: 'Basic Recovery Protocol',
      description: 'protocolo experimental de recuperação fisiológica.',
      phases: phases,
      createdAt: createdAt,
    );
  }

  static ExperimentalProtocol escalationObservationProtocol({
    DateTime? createdAt,
  }) {
    final phases = [
      _phase('resting', 'Resting', ProtocolPhaseType.resting),
      _phase('cognitive-task', 'Cognitive task', ProtocolPhaseType.cognitive),
      _phase(
        'contextual-stress',
        'Contextual stress',
        ProtocolPhaseType.contextual,
      ),
      _phase('recovery', 'Recovery', ProtocolPhaseType.recovery),
      _phase(
        'subjective-feedback',
        'Subjective feedback',
        ProtocolPhaseType.subjectiveFeedback,
      ),
    ];
    return _build(
      id: 'escalation-observation-protocol',
      title: 'Escalation Observation Protocol',
      description:
          'protocolo experimental para observar sinais em contexto experimental.',
      phases: phases,
      createdAt: createdAt,
    );
  }

  static ExperimentalProtocol circadianBaselineProtocol({DateTime? createdAt}) {
    final phases = [
      _phase('morning-resting', 'Morning resting', ProtocolPhaseType.resting),
      _phase(
        'afternoon-resting',
        'Afternoon resting',
        ProtocolPhaseType.resting,
      ),
      _phase('evening-resting', 'Evening resting', ProtocolPhaseType.resting),
    ];
    return _build(
      id: 'circadian-baseline-protocol',
      title: 'Circadian Baseline Protocol',
      description: 'protocolo experimental de baseline circadiano.',
      phases: phases,
      createdAt: createdAt,
    );
  }

  static ProtocolPhase _phase(String id, String title, ProtocolPhaseType type) {
    return ProtocolPhase(
      id: id,
      title: title,
      description: 'fase experimental para coleta fisiológica controlada.',
      duration: const Duration(minutes: 5),
      instructions: 'Seguir em sessão controlada sem linguagem clínica.',
      phaseType: type,
    );
  }

  static ExperimentalProtocol _build({
    required String id,
    required String title,
    required String description,
    required List<ProtocolPhase> phases,
    DateTime? createdAt,
  }) {
    final total = phases.fold<Duration>(
      Duration.zero,
      (duration, phase) => duration + phase.duration,
    );
    return ExperimentalProtocol(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt ?? DateTime.utc(2026, 1, 1),
      phases: List.unmodifiable(phases),
      totalDuration: total,
      recommendedSensors: const ['rr_intervals', 'heart_rate', 'hrv'],
    );
  }

  const ProtocolTemplates._();
}
