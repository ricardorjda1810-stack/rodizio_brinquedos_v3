import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/sensors/sensor_provider.dart';
import '../../domain/models/risk_event.dart';
import '../../domain/models/risk_state.dart';
import '../theme/ui_tokens.dart';
import '../widgets/simple_timeline_chart.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final sample = appState.currentSample;
    final riskState = appState.currentRiskState;
    final events = appState.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerta de Crise'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(UiTokens.m),
        children: [
          _StatusCard(
            state: riskState,
            score: appState.currentScore,
            baselineHeartRate: appState.baselineHeartRate,
            baselineHrv: appState.baselineHrv,
            heartRate: sample.heartRate,
            hrv: sample.hrv,
            message: appState.currentStatusMessage,
            sourceMessage: _sourceMessage(appState),
          ),
          if (appState.hasPendingAlert) ...[
            const SizedBox(height: UiTokens.m),
            _PendingAlertCard(
              onRegulate: () {
                appState.startAlertIntervention();
                Navigator.of(context).pushNamed('/intervention');
              },
              onDismiss: appState.dismissPendingAlert,
            ),
          ],
          const SizedBox(height: UiTokens.m),
          FilledButton(
            onPressed: () {
              appState.startGuidedRegulation();
              Navigator.of(context).pushNamed('/intervention');
            },
            child: const Text('Iniciar regulação agora'),
          ),
          const SizedBox(height: UiTokens.m),
          _ManualStartCard(
            onStart: () {
              appState.startManualIntervention();
              Navigator.of(context).pushNamed('/intervention');
            },
          ),
          const SizedBox(height: UiTokens.s),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: UiTokens.s,
              children: [
                TextButton(
                  onPressed: appState.isSimulationRunning
                      ? appState.stopSimulation
                      : appState.startSimulation,
                  child: Text(
                    appState.isSimulationRunning
                        ? 'Parar simulação'
                        : 'Iniciar simulação',
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/research'),
                  child: const Text('Modo pesquisa'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/calibration'),
                  child: const Text('Registrar como estou'),
                ),
              ],
            ),
          ),
          const SizedBox(height: UiTokens.l),
          const _SectionTitle('Último evento'),
          const SizedBox(height: UiTokens.s),
          if (events.isEmpty)
            const _EmptyLastEventCard()
          else
            _LastEventCard(event: events.first),
          const SizedBox(height: UiTokens.s),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushNamed('/history'),
            child: const Text('Ver histórico'),
          ),
          const SizedBox(height: UiTokens.l),
          _TimelineSection(
            heartRates: _lastValues(
              appState.recentSamples.map((sample) => sample.heartRate).toList(),
            ),
            hrvs: _lastValues(
              appState.recentSamples.map((sample) => sample.hrv).toList(),
            ),
            scores: _lastValues(appState.recentScores),
            state: riskState,
          ),
          const SizedBox(height: UiTokens.l),
          const _SectionTitle('Insights rápidos'),
          const SizedBox(height: UiTokens.s),
          const _InsightCard(
            title: 'Horário mais sensível',
            value: 'Entre 18h e 21h',
          ),
          const _InsightCard(
            title: 'Sinal mais frequente',
            value: 'FC sobe antes do desconforto percebido',
          ),
          const _InsightCard(
            title: 'Intervenção mais útil',
            value: 'Respiração guiada de 2 minutos',
          ),
        ],
      ),
    );
  }

  static List<int> _lastValues(List<int> values) {
    if (values.length <= 20) {
      return values;
    }

    return values.sublist(values.length - 20);
  }

  static String _sourceMessage(AppState appState) {
    if (appState.sensorProviderType != SensorProviderType.healthkit) {
      return 'Fonte atual: Simulação';
    }

    if (appState.hasLoadedHealthKitSample) {
      return 'Fonte atual: HealthKit';
    }

    return 'Fonte atual: HealthKit - nenhum dado real carregado.';
  }
}

final class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.state,
    required this.score,
    required this.baselineHeartRate,
    required this.baselineHrv,
    required this.heartRate,
    required this.hrv,
    required this.message,
    required this.sourceMessage,
  });

  final RiskState state;
  final int score;
  final int baselineHeartRate;
  final int baselineHrv;
  final int heartRate;
  final int hrv;
  final String message;
  final String sourceMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estado atual',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                _RiskChip(state: state),
              ],
            ),
            const SizedBox(height: UiTokens.l),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Frequência',
                    value: '$heartRate bpm',
                  ),
                ),
                const SizedBox(width: UiTokens.s),
                Expanded(
                  child: _MetricTile(label: 'HRV', value: '$hrv ms'),
                ),
              ],
            ),
            const SizedBox(height: UiTokens.s),
            _MetricTile(label: 'Score atual', value: '$score/100'),
            const SizedBox(height: UiTokens.s),
            Text(
              'Seu padrão recente: FC $baselineHeartRate bpm • HRV $baselineHrv ms',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: UiTokens.textFaint,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: UiTokens.m),
            Text(
              sourceMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: UiTokens.textFaint,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: UiTokens.s),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: UiTokens.textSoft,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _PendingAlertCard extends StatelessWidget {
  const _PendingAlertCard({required this.onRegulate, required this.onDismiss});

  final VoidCallback onRegulate;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: UiTokens.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(UiTokens.radiusCard),
        border: Border.all(color: UiTokens.danger.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sinais de ativação em atenção',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: UiTokens.danger,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: UiTokens.s),
            const Text(
              'Seu corpo apresentou sinais de ativação. Uma regulação curta pode ajudar agora.',
              style: TextStyle(color: UiTokens.textSoft, height: 1.35),
            ),
            const SizedBox(height: UiTokens.m),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onRegulate,
                    child: const Text('Regular agora'),
                  ),
                ),
                const SizedBox(width: UiTokens.s),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    child: const Text('Estou bem'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _ManualStartCard extends StatelessWidget {
  const _ManualStartCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Percebi sinais de ativação',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: UiTokens.s),
            const Text(
              'Use este botão para iniciar uma regulação manual antes de um alerta automático.',
              style: TextStyle(color: UiTokens.textSoft, height: 1.35),
            ),
            const SizedBox(height: UiTokens.m),
            OutlinedButton(
              onPressed: onStart,
              child: const Text('Iniciar regulação manual'),
            ),
          ],
        ),
      ),
    );
  }
}

final class _LastEventCard extends StatelessWidget {
  const _LastEventCard({required this.event});

  final RiskEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _RiskChip(state: event.state),
              ],
            ),
            const SizedBox(height: UiTokens.s),
            Text(
              event.description,
              style: const TextStyle(color: UiTokens.textSoft, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

final class _EmptyLastEventCard extends StatelessWidget {
  const _EmptyLastEventCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(UiTokens.m),
        child: Text(
          'Nenhum evento registrado ainda.',
          style: TextStyle(color: UiTokens.textSoft),
        ),
      ),
    );
  }
}

final class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UiTokens.s),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(UiTokens.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: UiTokens.textFaint),
              ),
              const SizedBox(height: UiTokens.xs),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _TimelineSection extends StatelessWidget {
  const _TimelineSection({
    required this.heartRates,
    required this.hrvs,
    required this.scores,
    required this.state,
  });

  final List<int> heartRates;
  final List<int> hrvs;
  final List<int> scores;
  final RiskState state;

  @override
  Widget build(BuildContext context) {
    final trend = _trendFor(scores);
    final message = switch (trend) {
      'Subindo' => 'Seu nível de ativação está aumentando.',
      'Reduzindo' => 'Seu corpo está retornando ao equilíbrio.',
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Evolução recente'),
        const SizedBox(height: UiTokens.s),
        Row(
          children: [
            Expanded(
              child: Text(
                'Tendência: $trend',
                style: const TextStyle(
                  color: UiTokens.textSoft,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _RiskChip(state: state),
          ],
        ),
        if (message != null) ...[
          const SizedBox(height: UiTokens.s),
          Text(
            message,
            style: TextStyle(
              color: trend == 'Subindo' ? UiTokens.warning : UiTokens.success,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
        const SizedBox(height: UiTokens.s),
        SimpleTimelineChart(
          values: heartRates,
          color: UiTokens.danger,
          label: 'FC',
        ),
        const SizedBox(height: UiTokens.s),
        SimpleTimelineChart(
          values: hrvs,
          color: UiTokens.secondary,
          label: 'HRV',
        ),
        const SizedBox(height: UiTokens.s),
        SimpleTimelineChart(
          values: scores,
          color: UiTokens.primary,
          label: 'Score',
        ),
      ],
    );
  }

  static String _trendFor(List<int> values) {
    if (values.length < 2) {
      return 'Estável';
    }

    final delta = values.last - values.first;
    if (delta >= 5) {
      return 'Subindo';
    }
    if (delta <= -5) {
      return 'Reduzindo';
    }

    return 'Estável';
  }
}

final class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: UiTokens.bg,
        borderRadius: BorderRadius.circular(UiTokens.radiusButton),
        border: Border.all(color: UiTokens.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: UiTokens.textFaint)),
            const SizedBox(height: UiTokens.xs),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

final class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.state});

  final RiskState state;

  @override
  Widget build(BuildContext context) {
    final color = UiTokens.riskColor(state.key);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(UiTokens.radiusPill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiTokens.m,
          vertical: UiTokens.s,
        ),
        child: Text(
          UiTokens.riskLabel(state.key),
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}
