import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/export/csv_exporter.dart';
import '../../data/sensors/polar_h10_session_sensor_provider.dart';
import '../../data/sensors/sensor_provider.dart';
import '../../domain/models/feeling_level.dart';
import '../../domain/models/research_session.dart';
import '../../domain/models/risk_state.dart';
import '../../domain/models/sensor_sample.dart';
import '../../domain/models/session_sample.dart';
import '../../domain/models/temporal_sample_analysis.dart';
import '../theme/ui_tokens.dart';

final class ResearchPage extends StatelessWidget {
  const ResearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final session = appState.currentResearchSession;
    final lastSample = session?.samples.lastOrNull;
    final lastEndedSession = appState.lastResearchSession;

    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisa')),
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
                    appState.hasActiveResearchSession
                        ? 'Sessão ativa'
                        : 'Sem sessão ativa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  Text(
                    'Amostras coletadas: ${session?.samples.length ?? 0}',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                  const SizedBox(height: UiTokens.s),
                  Text(
                    'Fonte atual: ${_sourceLabel(appState.sensorProviderType)}',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                  if (appState.sensorProviderType !=
                      SensorProviderType.mock) ...[
                    const SizedBox(height: UiTokens.s),
                    Text(
                      'Samples reais coletados: ${appState.activeResearchSessionSampleCount}',
                      style: const TextStyle(color: UiTokens.textSoft),
                    ),
                    const SizedBox(height: UiTokens.s),
                    Text(
                      'Último sample: ${_formatOptionalDateTime(appState.lastResearchSessionSampleTimestamp)}',
                      style: const TextStyle(color: UiTokens.textSoft),
                    ),
                    const SizedBox(height: UiTokens.s),
                    const Text(
                      'Foreground only',
                      style: TextStyle(
                        color: UiTokens.textFaint,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (session != null) ...[
                    const SizedBox(height: UiTokens.s),
                    Text(
                      'Início: ${_formatDateTime(session.startedAt)}',
                      style: const TextStyle(color: UiTokens.textSoft),
                    ),
                  ],
                  const SizedBox(height: UiTokens.m),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: appState.hasActiveResearchSession
                              ? null
                              : appState.startResearchSession,
                          child: const Text('Iniciar sessão'),
                        ),
                      ),
                      const SizedBox(width: UiTokens.s),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: appState.hasActiveResearchSession
                              ? appState.endResearchSession
                              : null,
                          child: const Text('Encerrar sessão'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UiTokens.s),
                  OutlinedButton(
                    onPressed: appState.isSimulationRunning
                        ? appState.stopSimulation
                        : appState.startSimulation,
                    child: Text(
                      appState.isSimulationRunning
                          ? 'Parar simulação'
                          : 'Iniciar simulação',
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/guided-protocol'),
                    child: const Text('Protocolo guiado'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: UiTokens.m),
          _LastSampleCard(sample: lastSample),
          const SizedBox(height: UiTokens.m),
          _DiagnosticsCard(appState: appState),
          const SizedBox(height: UiTokens.m),
          _SessionDebugCard(appState: appState),
          const SizedBox(height: UiTokens.m),
          _TemporalAnalysisCard(analysis: appState.currentTemporalAnalysis),
          const SizedBox(height: UiTokens.m),
          _PolarH10DiagnosticsCard(appState: appState),
          const SizedBox(height: UiTokens.m),
          _HealthKitDebugCard(appState: appState),
          const SizedBox(height: UiTokens.m),
          _EndedSessionsCard(session: lastEndedSession),
          const SizedBox(height: UiTokens.m),
          _LastGuidedProtocolCard(appState: appState),
          const SizedBox(height: UiTokens.m),
          OutlinedButton(
            onPressed: session == null
                ? null
                : () => _showSessionCsv(context, session),
            child: const Text('Exportar CSV da sessão'),
          ),
          const SizedBox(height: UiTokens.s),
          OutlinedButton(
            onPressed: () => _showDiagnosticsCsv(context, appState),
            child: const Text('Exportar diagnóstico CSV'),
          ),
          const SizedBox(height: UiTokens.s),
          OutlinedButton(
            onPressed: () => _showTemporalAnalysisCsv(context, appState),
            child: const Text('Exportar análise temporal CSV'),
          ),
          const SizedBox(height: UiTokens.s),
          OutlinedButton(
            onPressed: lastEndedSession == null
                ? null
                : () => _showSessionCsv(context, lastEndedSession),
            child: const Text('Exportar CSV da última sessão encerrada'),
          ),
        ],
      ),
    );
  }

  void _showSessionCsv(BuildContext context, ResearchSession session) {
    const exporter = CsvExporter();
    final csv = exporter.exportSessionSamples(session.samples);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('CSV da sessão'),
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

  void _showDiagnosticsCsv(BuildContext context, AppState appState) {
    const exporter = CsvExporter();
    final csv = exporter.exportCollectionDiagnostics(
      appState.collectionDiagnostics,
    );

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('CSV do diagnóstico'),
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

  void _showTemporalAnalysisCsv(BuildContext context, AppState appState) {
    const exporter = CsvExporter();
    final csv = exporter.exportTemporalAnalysis(
      appState.currentTemporalAnalysis.totalSamples > 0
          ? appState.currentTemporalAnalysis
          : appState.lastClosedSessionTemporalAnalysis,
    );

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('CSV da análise temporal'),
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

  static String _formatDateTime(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    final day = twoDigits(dateTime.day);
    final month = twoDigits(dateTime.month);
    final hour = twoDigits(dateTime.hour);
    final minute = twoDigits(dateTime.minute);

    return '$day/$month/${dateTime.year} $hour:$minute';
  }

  static String _formatOptionalDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'nenhum dado carregado';
    }

    return _formatDateTime(dateTime);
  }

  static String _sourceLabel(SensorProviderType type) {
    return switch (type) {
      SensorProviderType.mock => 'Simulação',
      SensorProviderType.healthkit => 'HealthKit',
      SensorProviderType.polarH10 => 'Polar H10',
    };
  }
}

final class _SessionDebugCard extends StatelessWidget {
  const _SessionDebugCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug da sessão',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.s),
            Text(
              'Stream ativa: ${appState.isCurrentProviderSessionCollectionActive ? 'sim' : 'não'}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Provider atual: ${ResearchPage._sourceLabel(appState.sensorProviderType)}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Total emitido: ${appState.emittedSamples}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Total salvo: ${appState.savedSamples}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Total ignorado: ${appState.ignoredSamples}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            const SizedBox(height: UiTokens.s),
            Text(
              'Último sample emitido: ${_formatSensorSample(appState.lastPipelineEmittedSample)}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Último sample salvo: ${_formatSessionSample(appState.lastPipelineSavedSample)}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Último sample ignorado: ${_formatSensorSample(appState.lastPipelineIgnoredSample)}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Motivo do último descarte: ${appState.lastPipelineIgnoreReason}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSensorSample(SensorSample? sample) {
    if (sample == null) {
      return 'nenhum';
    }

    return '${sample.heartRate} bpm, ${_formatSensorHrv(sample)} '
        '${_formatTime(sample.timestamp)}';
  }

  String _formatSessionSample(SessionSample? sample) {
    if (sample == null) {
      return 'nenhum';
    }

    return '${sample.heartRate} bpm, ${_formatHrv(sample)} '
        '${_formatTime(sample.timestamp)}';
  }

  String _formatHrv(SessionSample sample) {
    if (sample.motionState == 'healthkit-hrv-indisponivel') {
      return 'HRV indisponível';
    }

    return 'HRV ${sample.hrv} ms';
  }

  String _formatSensorHrv(SensorSample sample) {
    if (sample.motionState == 'healthkit-hrv-indisponivel') {
      return 'HRV indisponível';
    }

    return 'HRV ${sample.hrv} ms';
  }

  String _formatTime(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}:${twoDigits(dateTime.second)}';
  }
}

final class _LastGuidedProtocolCard extends StatelessWidget {
  const _LastGuidedProtocolCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final session = appState.lastGuidedProtocolSession;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última sessão de protocolo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.s),
            if (session == null)
              const Text(
                'Nenhum protocolo guiado encerrado ainda.',
                style: TextStyle(color: UiTokens.textSoft),
              )
            else ...[
              Text(
                'Samples: ${session.samples.length}',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
              Text(
                'Feedback: ${session.feedback?.label ?? 'não informado'}',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _TemporalAnalysisCard extends StatelessWidget {
  const _TemporalAnalysisCard({required this.analysis});

  final TemporalSampleAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análise temporal',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.s),
            Text(
              'Total de samples: ${analysis.totalSamples}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Duração analisada: ${_formatSeconds(analysis.durationSeconds)}s',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            if (analysis.totalSamples < 2) ...[
              const SizedBox(height: UiTokens.s),
              const Text(
                'Aguardando mais amostras para calcular intervalos.',
                style: TextStyle(color: UiTokens.textFaint, height: 1.35),
              ),
            ] else ...[
              Text(
                'Intervalo médio: ${_formatSeconds(analysis.averageIntervalSeconds)}s',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
              Text(
                'Intervalo mediano: ${_formatSeconds(analysis.medianIntervalSeconds)}s',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
              Text(
                'Menor intervalo: ${_formatSeconds(analysis.minIntervalSeconds)}s',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
              Text(
                'Maior intervalo: ${_formatSeconds(analysis.maxIntervalSeconds)}s',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
              Text(
                'Gaps longos: ${analysis.longGapCount}',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
              Text(
                'Maior gap: ${_formatSeconds(analysis.longestGapSeconds)}s',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
              Text(
                'Samples por minuto: ${analysis.samplesPerMinute.toStringAsFixed(2)}',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
            ],
            Text(
              'Qualidade: ${analysis.qualityLabel}',
              style: const TextStyle(
                color: UiTokens.textSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSeconds(double value) {
    return value.toStringAsFixed(1);
  }
}

final class _HealthKitDebugCard extends StatelessWidget {
  const _HealthKitDebugCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final isHealthKit =
        appState.sensorProviderType == SensorProviderType.healthkit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnóstico bruto HealthKit',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.s),
            OutlinedButton(
              onPressed: isHealthKit && !appState.isHealthKitDebugRunning
                  ? appState.runHealthKitDebugDiagnostics
                  : null,
              child: Text(
                appState.isHealthKitDebugRunning
                    ? 'Executando diagnóstico'
                    : 'Executar diagnóstico',
              ),
            ),
            const SizedBox(height: UiTokens.s),
            SelectableText(
              appState.healthKitDebugStatus,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: UiTokens.textSoft,
                fontFamily: 'monospace',
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _PolarH10DiagnosticsCard extends StatelessWidget {
  const _PolarH10DiagnosticsCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final diagnostics = appState.polarH10Diagnostics;
    final isPolarH10 =
        appState.sensorProviderType == SensorProviderType.polarH10;
    final device =
        diagnostics.selectedDevice ?? diagnostics.devices.firstOrNull;
    final latestRr = diagnostics.latestRr;
    final latestAccelerometer = diagnostics.latestAccelerometerSample;
    final statistics = diagnostics.statistics;
    final signalStatus = _signalStatus(diagnostics);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnóstico Polar H10',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.s),
            const Text(
              'Fonte: Polar H10. Estes dados não vêm do HealthKit.',
              style: TextStyle(color: UiTokens.textSoft, height: 1.35),
            ),
            const SizedBox(height: UiTokens.s),
            Wrap(
              spacing: UiTokens.s,
              runSpacing: UiTokens.s,
              children: [
                OutlinedButton(
                  onPressed: appState.scanPolarH10,
                  child: const Text('Procurar Polar H10'),
                ),
                FilledButton.tonal(
                  onPressed: diagnostics.h10Found
                      ? appState.connectPolarH10
                      : null,
                  child: const Text('Conectar Polar H10'),
                ),
              ],
            ),
            const SizedBox(height: UiTokens.s),
            _DebugLine(
              'Provider selecionado',
              ResearchPage._sourceLabel(appState.sensorProviderType),
            ),
            _DebugLine(
              'Status',
              diagnostics.h10Connected
                  ? 'Polar H10 conectado'
                  : 'Polar H10 não conectado',
            ),
            _DebugLine(
              'Bluetooth autorizado/disponível',
              diagnostics.bluetoothStatus,
            ),
            _DebugLine('Scan BLE iniciado', _yesNo(diagnostics.scanStarted)),
            _DebugLine(
              'Dispositivos encontrados',
              '${diagnostics.devices.length}',
            ),
            _DebugLine('H10 encontrado', _yesNo(diagnostics.h10Found)),
            _DebugLine('H10 conectado', _yesNo(diagnostics.h10Connected)),
            _DebugLine('Nome do dispositivo', device?.name),
            _DebugLine('Device ID', device?.id),
            _DebugLine('RSSI', device?.rssi.toString()),
            _DebugLine('Último erro BLE', diagnostics.lastError?.toString()),
            _DebugLine(
              'Última conexão/tentativa',
              _formatOptionalDateTime(
                diagnostics.connectedAt ?? diagnostics.lastConnectionAttemptAt,
              ),
            ),
            const SizedBox(height: UiTokens.s),
            _DebugLine('Última FC/BPM H10', _number(latestRr?.heartRate)),
            _DebugLine(
              'Timestamp da última FC',
              _formatOptionalDateTime(diagnostics.lastHeartRateAt),
            ),
            _DebugLine(
              'Amostras de FC H10',
              '${diagnostics.heartRateSampleCount}',
            ),
            _DebugLine(
              'RR intervals recebidos na sessão',
              '${diagnostics.rrIntervalCount}',
            ),
            _DebugLine(
              'Último RR interval em ms',
              _number(latestRr?.rrIntervalMs),
            ),
            _DebugLine(
              'RR intervals válidos na sessão',
              '${diagnostics.validRrIntervalCount}',
            ),
            _DebugLine(
              'RR intervals descartados na sessão',
              '${diagnostics.discardedRrIntervalCount}',
            ),
            _DebugLine('RMSSD calculado', _number(statistics.rmssdMs)),
            _DebugLine('SDNN calculado', _number(statistics.sdnnMs)),
            const _DebugLine('Janela HRV', 'até 30 RR intervals recentes'),
            _DebugLine('Qualidade da janela', signalStatus),
            _DebugLine(
              'Acelerômetro H10 ativo',
              _yesNo(diagnostics.accelerometerActive),
            ),
            _DebugLine(
              'Recebido pelo app em',
              _formatOptionalDateTime(latestAccelerometer?.receivedAt),
            ),
            _DebugLine(
              'Timestamp bruto do sensor',
              _formatOptionalDateTime(latestAccelerometer?.timestamp),
            ),
            _DebugLine(
              'Últimos valores X/Y/Z',
              latestAccelerometer == null
                  ? null
                  : '${latestAccelerometer.xMg} / ${latestAccelerometer.yMg} / ${latestAccelerometer.zMg} mg',
            ),
            _DebugLine(
              'Amostras de acelerômetro',
              '${diagnostics.accelerometerSampleCount}',
            ),
            _DebugLine('motionRmsMg', _number(diagnostics.motionRmsMg)),
            _DebugLine(
              'Classificação de movimento',
              diagnostics.motionClass.label,
            ),
            _DebugLine(
              'Último erro acelerômetro',
              diagnostics.lastAccelerometerError?.toString(),
            ),
            if (!isPolarH10) ...[
              const SizedBox(height: UiTokens.s),
              const Text(
                'A sessão atual não está usando o Polar H10. Use Procurar/Conectar para trocar o provider.',
                style: TextStyle(color: UiTokens.textFaint, height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _yesNo(bool value) => value ? 'sim' : 'não';

  static String? _number(num? value) => value?.toStringAsFixed(1);

  static String _formatOptionalDateTime(DateTime? value) {
    return value == null ? 'n/a' : value.toIso8601String();
  }

  static String _signalStatus(PolarH10Diagnostics diagnostics) {
    if (!diagnostics.h10Connected) {
      return 'disconnected';
    }
    if (diagnostics.statistics.sampleCount < 3) {
      return 'sparse';
    }
    if (diagnostics.qualityEvaluation?.artifactReport.hasArtifacts ?? false) {
      return 'noisy';
    }
    return diagnostics.qualityEvaluation?.signalQuality.name ?? 'good';
  }
}

final class _DebugLine extends StatelessWidget {
  const _DebugLine(this.label, this.value);

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = value == null || value!.trim().isEmpty ? 'n/a' : value!;

    return Padding(
      padding: const EdgeInsets.only(bottom: UiTokens.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: UiTokens.textSoft),
            ),
          ),
          const SizedBox(width: UiTokens.s),
          Expanded(
            flex: 3,
            child: Text(
              text,
              textAlign: TextAlign.end,
              style: const TextStyle(color: UiTokens.textSoft),
            ),
          ),
        ],
      ),
    );
  }
}

final class _DiagnosticsCard extends StatelessWidget {
  const _DiagnosticsCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final diagnostics = appState.collectionDiagnostics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnóstico da coleta',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.s),
            Text(
              'Total de samples: ${diagnostics.totalSamples}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Samples com FC: ${diagnostics.heartRateSamples}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Samples com HRV: ${diagnostics.hrvSamples}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'HRV ausente: ${diagnostics.missingHrvCount}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Intervalo médio: ${_formatSeconds(diagnostics.averageIntervalSeconds)}s',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Menor intervalo: ${_formatSeconds(diagnostics.minIntervalSeconds)}s',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Maior intervalo: ${_formatSeconds(diagnostics.maxIntervalSeconds)}s',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Duplicados ignorados: ${diagnostics.duplicateSamplesSkipped}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            Text(
              'Fonte: ${diagnostics.sourceLabel}',
              style: const TextStyle(color: UiTokens.textSoft),
            ),
            if (appState.sensorProviderType ==
                SensorProviderType.healthkit) ...[
              const SizedBox(height: UiTokens.s),
              const Text(
                'A frequência dos dados depende do Apple Watch, do iOS e da disponibilidade no HealthKit.',
                style: TextStyle(color: UiTokens.textFaint, height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatSeconds(double value) {
    return value.toStringAsFixed(1);
  }
}

final class _EndedSessionsCard extends StatelessWidget {
  const _EndedSessionsCard({required this.session});

  final ResearchSession? session;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final session = this.session;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sessões encerradas: ${appState.researchSessions.length}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: UiTokens.s),
            if (session == null)
              const Text(
                'Nenhuma sessão encerrada ainda.',
                style: TextStyle(color: UiTokens.textSoft),
              )
            else ...[
              Text(
                'Última sessão encerrada',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: UiTokens.textFaint),
              ),
              const SizedBox(height: UiTokens.xs),
              Text(
                'Amostras: ${session.samples.length}',
                style: const TextStyle(color: UiTokens.textSoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _LastSampleCard extends StatelessWidget {
  const _LastSampleCard({required this.sample});

  final SessionSample? sample;

  @override
  Widget build(BuildContext context) {
    final sample = this.sample;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.m),
        child: sample == null
            ? const Text(
                'Nenhuma amostra coletada ainda.',
                style: TextStyle(color: UiTokens.textSoft),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última amostra',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: UiTokens.s),
                  Text(
                    'FC ${sample.heartRate} bpm • ${_formatHrv(sample)}',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                  const SizedBox(height: UiTokens.xs),
                  Text(
                    'Score ${sample.riskScore}/100 • ${sample.riskState.label}',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                  const SizedBox(height: UiTokens.xs),
                  Text(
                    'Movimento: ${sample.motionState}',
                    style: const TextStyle(color: UiTokens.textSoft),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatHrv(SessionSample sample) {
    if (sample.motionState == 'healthkit-hrv-indisponivel') {
      return 'HRV indisponível';
    }

    return 'HRV ${sample.hrv} ms';
  }
}
