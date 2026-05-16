class InterventionProtocolStep {
  final String title;
  final String description;
  final int durationSeconds;
  final bool requiresUserConfirmation;

  const InterventionProtocolStep({
    required this.title,
    required this.description,
    required this.durationSeconds,
    this.requiresUserConfirmation = false,
  });

  static const breathing = InterventionProtocolStep(
    title: 'Respiração guiada',
    description:
        'Faça uma pausa e acompanhe uma respiração lenta e confortável.',
    durationSeconds: 60,
  );

  static const grounding = InterventionProtocolStep(
    title: 'Grounding curto',
    description:
        'Observe o ambiente ao redor e nomeie pontos de apoio presentes.',
    durationSeconds: 45,
  );

  static const hydration = InterventionProtocolStep(
    title: 'Pausa breve',
    description: 'Se for confortável, beba água e mantenha o corpo em repouso.',
    durationSeconds: 30,
  );

  static const recoveryCheck = InterventionProtocolStep(
    title: 'Pergunta de recuperação',
    description: 'Registre como os sinais de ativação parecem estar agora.',
    durationSeconds: 0,
    requiresUserConfirmation: true,
  );
}
