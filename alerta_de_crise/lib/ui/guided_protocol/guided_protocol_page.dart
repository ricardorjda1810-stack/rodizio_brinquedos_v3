import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/export/csv_exporter.dart';
import '../../data/sensors/sensor_provider.dart';
import '../../domain/models/experimental_insight.dart';
import '../../domain/models/feeling_level.dart';
import '../../domain/models/guided_protocol_analysis.dart';
import '../../domain/models/phase_analysis.dart';
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
    final analysis = session != null
        ? appState.currentGuidedProtocolAnalysis
        : appState.lastGuidedProtocolAnalysis;
    final insights = session != null
        ? appState.currentExperimentalInsights
        : appState.lastExperimentalInsights;

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
          _PhaseAnalysisCard(analysis: analysis),
          const SizedBox(height: UiTokens.m),
          _ExperimentalInsightsCard(insights: insights),
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
      SensorProviderType.polarH10 => 'Polar H10',
    };
  }
}

final class _PhaseAnalysisCard extends StatelessWidget {
  const _PhaseAnalysisCard({required this.analysis});

  final GuidedProtocolAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análise por fase',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.s),
            if (!analysis.hasEnoughDataForCompleteAnalysis)
              const Text(
                'Dados insuficientes para análise completa.',
                style: TextStyle(color: UiTokens.textFaint, height: 1.35),
              ),
            if (analysis.phases.isEmpty) ...[
              const SizedBox(height: UiTokens.s),
              const Text(
                'Nenhuma amostra com fase registrada ainda.',
                style: TextStyle(color: UiTokens.textSoft),
              ),
            ] else ...[
              const SizedBox(height: UiTokens.m),
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: _PhaseHeartRatePainter(analysis.phases),
                ),
              ),
              const SizedBox(height: UiTokens.m),
              ...analysis.phases.map((phase) => _PhaseSummary(phase: phase)),
              const SizedBox(height: UiTokens.s),
              Text(
                'FC média geral: ${_formatNumber(analysis.overallAverageHeartRate)}',
                style: const TextStyle(
                  color: UiTokens.textSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'HRV média geral: ${analysis.overallAverageHrv == null ? 'sem dados' : _formatNumber(analysis.overallAverageHrv!)}',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
              const SizedBox(height: UiTokens.m),
              OutlinedButton(
                onPressed: () => _showProtocolAnalysisCsv(context, analysis),
                child: const Text('Exportar análise do protocolo CSV'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showProtocolAnalysisCsv(
    BuildContext context,
    GuidedProtocolAnalysis analysis,
  ) {
    const exporter = CsvExporter();
    final csv = exporter.exportGuidedProtocolAnalysis(analysis);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('CSV da análise do protocolo'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                csv,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: UiTokens.textSoft,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(0);
  }
}

final class _ExperimentalInsightsCard extends StatelessWidget {
  const _ExperimentalInsightsCard({required this.insights});

  final List<ExperimentalInsight> insights;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights experimentais',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.s),
            const Text(
              'Regras simples comparam os dados coletados, sem diagnóstico ou previsão.',
              style: TextStyle(color: UiTokens.textFaint, height: 1.35),
            ),
            if (insights.isEmpty) ...[
              const SizedBox(height: UiTokens.s),
              const Text(
                'Nenhum insight experimental disponível ainda.',
                style: TextStyle(color: UiTokens.textSoft),
              ),
            ] else ...[
              const SizedBox(height: UiTokens.m),
              ...insights.map((insight) {
                return _InsightSummary(insight: insight);
              }),
              const SizedBox(height: UiTokens.s),
              OutlinedButton(
                onPressed: () => _showInsightsCsv(context, insights),
                child: const Text('Exportar insights CSV'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInsightsCsv(
    BuildContext context,
    List<ExperimentalInsight> insights,
  ) {
    const exporter = CsvExporter();
    final csv = exporter.exportExperimentalInsights(insights);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('CSV dos insights'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                csv,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: UiTokens.textSoft,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

final class _InsightSummary extends StatelessWidget {
  const _InsightSummary({required this.insight});

  final ExperimentalInsight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: UiTokens.s),
      padding: const EdgeInsets.all(UiTokens.s),
      decoration: BoxDecoration(
        border: Border.all(color: UiTokens.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.title,
            style: const TextStyle(
              color: UiTokens.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.description,
            style: const TextStyle(color: UiTokens.textSoft, height: 1.35),
          ),
          const SizedBox(height: 4),
          Text(
            '${insight.category.label} • Confiança ${insight.confidenceLabel} • ${insight.valueSummary}',
            style: const TextStyle(
              color: UiTokens.textFaint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

final class _PhaseSummary extends StatelessWidget {
  const _PhaseSummary({required this.phase});

  final PhaseAnalysis phase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UiTokens.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${phase.stepLabel} -> FC média ${_formatNumber(phase.averageHeartRate)}',
            style: const TextStyle(
              color: UiTokens.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Samples: ${phase.sampleCount} • FC min ${phase.minHeartRate} • FC max ${phase.maxHeartRate}',
            style: const TextStyle(color: UiTokens.textSoft),
          ),
          Text(
            'HRV média: ${phase.averageHrv == null ? 'sem dados' : _formatNumber(phase.averageHrv!)} • Duração: ${_formatNumber(phase.durationSeconds)}s',
            style: const TextStyle(color: UiTokens.textSoft),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(0);
  }
}

final class _PhaseHeartRatePainter extends CustomPainter {
  const _PhaseHeartRatePainter(this.phases);

  final List<PhaseAnalysis> phases;

  @override
  void paint(Canvas canvas, Size size) {
    if (phases.isEmpty) {
      return;
    }

    final axisPaint = Paint()
      ..color = UiTokens.border
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = UiTokens.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = UiTokens.primary;
    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final minValue = phases
        .map((phase) => phase.averageHeartRate)
        .reduce((a, b) => a < b ? a : b);
    final maxValue = phases
        .map((phase) => phase.averageHeartRate)
        .reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs() < 1 ? 1 : maxValue - minValue;
    final chartHeight = size.height - 28;
    final stepWidth = phases.length == 1
        ? size.width
        : size.width / (phases.length - 1);
    final points = <Offset>[];

    canvas.drawLine(
      Offset(0, chartHeight),
      Offset(size.width, chartHeight),
      axisPaint,
    );

    for (var index = 0; index < phases.length; index += 1) {
      final phase = phases[index];
      final x = phases.length == 1 ? size.width / 2 : stepWidth * index;
      final normalized = (phase.averageHeartRate - minValue) / range;
      final y = chartHeight - (normalized * (chartHeight - 12)) - 6;
      final point = Offset(x, y);
      points.add(point);

      fillPaint.color = _phaseColor(phase.stepLabel);
      canvas.drawCircle(point, 4, fillPaint);

      labelPainter.text = TextSpan(
        text: _shortLabel(phase.stepLabel),
        style: const TextStyle(color: UiTokens.textFaint, fontSize: 11),
      );
      labelPainter.layout(maxWidth: 72);
      labelPainter.paint(
        canvas,
        Offset(
          (x - labelPainter.width / 2)
              .clamp(0, size.width - labelPainter.width)
              .toDouble(),
          chartHeight + 6,
        ),
      );
    }

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PhaseHeartRatePainter oldDelegate) {
    return oldDelegate.phases != phases;
  }

  Color _phaseColor(String label) {
    return switch (label) {
      'Repouso' => UiTokens.secondary,
      'Ativação leve' => UiTokens.warning,
      'Recuperação' => UiTokens.primary,
      _ => UiTokens.textFaint,
    };
  }

  String _shortLabel(String label) {
    return switch (label) {
      'Ativação leve' => 'Ativação',
      _ => label,
    };
  }
}
