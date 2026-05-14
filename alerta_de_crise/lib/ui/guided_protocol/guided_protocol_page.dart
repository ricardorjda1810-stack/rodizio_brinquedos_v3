import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/sensors/sensor_provider.dart';
import '../../domain/models/feeling_level.dart';
import '../theme/ui_tokens.dart';

final class GuidedProtocolPage extends StatefulWidget {
  const GuidedProtocolPage({super.key});

  @override
  State<GuidedProtocolPage> createState() => _GuidedProtocolPageState();
}

final class _GuidedProtocolPageState extends State<GuidedProtocolPage> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final session = appState.currentGuidedProtocolSession;
    final step = appState.currentGuidedProtocolStep;
    final lastSession = appState.lastGuidedProtocolSession;

    return Scaffold(
      appBar: AppBar(title: const Text('Protocolo guiado')),
      body: ListView(
        padding: const EdgeInsets.all(UiTokens.m),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(UiTokens.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session == null ? 'Pronto para iniciar' : 'Protocolo ativo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  const Text(
                    'As fases organizam a coleta em repouso, ativação leve, recuperação e feedback subjetivo.',
                    style: TextStyle(color: UiTokens.textSoft, height: 1.35),
                  ),
                  const SizedBox(height: UiTokens.m),
                  FilledButton(
                    onPressed: session == null
                        ? appState.startGuidedProtocol
                        : null,
                    child: const Text('Iniciar protocolo'),
                  ),
                ],
              ),
            ),
          ),
          if (session != null && step != null) ...[
            const SizedBox(height: UiTokens.m),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UiTokens.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fase atual: ${step.label}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: UiTokens.s),
                    Text(
                      step.instruction,
                      style: const TextStyle(
                        color: UiTokens.textSoft,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: UiTokens.m),
                    Text(
                      'Timer: ${_timerLabel(session.stepStartedAt, step.duration)}',
                      style: const TextStyle(
                        color: UiTokens.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: UiTokens.s),
                    Text(
                      'Samples nesta sessão: ${session.samples.length}',
                      style: const TextStyle(color: UiTokens.textSoft),
                    ),
                    const SizedBox(height: UiTokens.s),
                    Text(
                      'Fonte atual: ${_sourceLabel(appState.sensorProviderType)}',
                      style: const TextStyle(color: UiTokens.textSoft),
                    ),
                    if (step.id == 'feedback') ...[
                      const SizedBox(height: UiTokens.m),
                      Wrap(
                        spacing: UiTokens.s,
                        runSpacing: UiTokens.s,
                        children: FeelingLevel.values.map((level) {
                          final selected = session.feedback == level;
                          return ChoiceChip(
                            label: Text(level.label),
                            selected: selected,
                            onSelected: (_) =>
                                appState.submitGuidedProtocolFeedback(level),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: UiTokens.m),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                session.currentStepIndex <
                                    appState.guidedProtocol.steps.length - 1
                                ? appState.advanceGuidedProtocolStep
                                : null,
                            child: const Text('Avançar etapa'),
                          ),
                        ),
                        const SizedBox(width: UiTokens.s),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: appState.endGuidedProtocol,
                            child: const Text('Encerrar protocolo'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: UiTokens.m),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(UiTokens.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Último protocolo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  if (lastSession == null)
                    const Text(
                      'Nenhum protocolo encerrado ainda.',
                      style: TextStyle(color: UiTokens.textSoft),
                    )
                  else ...[
                    Text(
                      'Samples salvos: ${lastSession.samples.length}',
                      style: const TextStyle(color: UiTokens.textSoft),
                    ),
                    Text(
                      'Feedback: ${lastSession.feedback?.label ?? 'não informado'}',
                      style: const TextStyle(color: UiTokens.textSoft),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timerLabel(DateTime startedAt, Duration? duration) {
    final elapsed = _now.difference(startedAt);
    if (duration == null) {
      return _formatDuration(elapsed);
    }

    final remaining = duration - elapsed;
    return '${_formatDuration(remaining.isNegative ? Duration.zero : remaining)} restantes';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _sourceLabel(SensorProviderType type) {
    return switch (type) {
      SensorProviderType.mock => 'Simulação',
      SensorProviderType.healthkit => 'HealthKit',
    };
  }
}
