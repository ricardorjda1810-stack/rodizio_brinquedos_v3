import 'package:flutter/material.dart';

import '../../data/repositories/onboarding_repository.dart';
import '../theme/ui_tokens.dart';

final class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    this.repository = const OnboardingRepository(),
    super.key,
  });

  final OnboardingRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(UiTokens.l),
          children: [
            const SizedBox(height: UiTokens.xl),
            Text(
              'Alerta de Crise',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: UiTokens.text,
              ),
            ),
            const SizedBox(height: UiTokens.m),
            const Text(
              'O app observa sinais de ativação fisiológica e ajuda você a fazer uma regulação curta.',
              style: TextStyle(
                color: UiTokens.textSoft,
                fontSize: 18,
                height: 1.35,
              ),
            ),
            const SizedBox(height: UiTokens.m),
            const Text(
              'Este app não realiza diagnóstico, não substitui atendimento profissional e não deve ser usado em emergências.',
              style: TextStyle(
                color: UiTokens.textSoft,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: UiTokens.xl),
            FilledButton(
              onPressed: () => _finishOnboarding(context),
              child: const Text('Entendi e começar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishOnboarding(BuildContext context) async {
    await repository.markOnboardingSeen();
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed('/home');
  }
}
