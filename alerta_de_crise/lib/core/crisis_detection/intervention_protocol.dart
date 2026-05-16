import 'intervention_protocol_step.dart';

class InterventionProtocol {
  final String id;
  final String title;
  final String description;
  final List<InterventionProtocolStep> steps;

  const InterventionProtocol({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
  });

  factory InterventionProtocol.standard() {
    return const InterventionProtocol(
      id: 'standard-guided-pause',
      title: 'Pausa guiada',
      description:
          'Sequência curta para apoiar recuperação fisiológica durante ativação acima do padrão.',
      steps: [
        InterventionProtocolStep.breathing,
        InterventionProtocolStep.grounding,
        InterventionProtocolStep.hydration,
        InterventionProtocolStep.recoveryCheck,
      ],
    );
  }
}
