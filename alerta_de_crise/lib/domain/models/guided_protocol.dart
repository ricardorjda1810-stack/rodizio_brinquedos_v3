import 'feeling_level.dart';
import 'session_sample.dart';

final class GuidedProtocol {
  const GuidedProtocol({required this.id, required this.steps});

  factory GuidedProtocol.initial() {
    return const GuidedProtocol(
      id: 'guided-research-v1',
      steps: [
        GuidedProtocolStep(
          id: 'rest',
          label: 'Repouso',
          instruction: 'Fique sentado e respire naturalmente.',
          duration: Duration(minutes: 2),
        ),
        GuidedProtocolStep(
          id: 'light-activation',
          label: 'Ativação leve',
          instruction:
              'Caminhe devagar ou faça movimento leve, se for confortável.',
          duration: Duration(minutes: 2),
        ),
        GuidedProtocolStep(
          id: 'recovery',
          label: 'Recuperação',
          instruction: 'Sente-se novamente e observe sua respiração.',
          duration: Duration(minutes: 2),
        ),
        GuidedProtocolStep(
          id: 'feedback',
          label: 'Feedback',
          instruction: 'Como você se sente agora?',
          duration: null,
        ),
      ],
    );
  }

  final String id;
  final List<GuidedProtocolStep> steps;
}

final class GuidedProtocolStep {
  const GuidedProtocolStep({
    required this.id,
    required this.label,
    required this.instruction,
    required this.duration,
  });

  final String id;
  final String label;
  final String instruction;
  final Duration? duration;

  bool get hasTimer => duration != null;
}

final class GuidedProtocolSession {
  const GuidedProtocolSession({
    required this.id,
    required this.protocolId,
    required this.startedAt,
    required this.currentStepIndex,
    required this.stepStartedAt,
    required this.samples,
    this.endedAt,
    this.feedback,
  });

  final String id;
  final String protocolId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int currentStepIndex;
  final DateTime stepStartedAt;
  final List<SessionSample> samples;
  final FeelingLevel? feedback;

  bool get isActive => endedAt == null;

  GuidedProtocolSession copyWith({
    DateTime? endedAt,
    int? currentStepIndex,
    DateTime? stepStartedAt,
    List<SessionSample>? samples,
    FeelingLevel? feedback,
  }) {
    return GuidedProtocolSession(
      id: id,
      protocolId: protocolId,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      stepStartedAt: stepStartedAt ?? this.stepStartedAt,
      samples: samples ?? this.samples,
      feedback: feedback ?? this.feedback,
    );
  }
}
