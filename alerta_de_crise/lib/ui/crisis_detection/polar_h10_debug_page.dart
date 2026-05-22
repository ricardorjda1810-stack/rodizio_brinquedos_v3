import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/crisis_detection/environmental_audio_context.dart';
import '../../core/crisis_detection/polar_h10_sensor_provider.dart';
import '../../core/crisis_detection/physiological_sample.dart';
import '../../polar_h10/polar_h10_device.dart';
import '../../polar_h10/polar_h10_models.dart';
import '../../polar_h10/polar_h10_rr_sample.dart';
import '../../polar_h10/polar_h10_service.dart';
import '../../polar_h10/polar_h10_statistics.dart';
import '../../sensor_quality/sensor_quality_models.dart';

class PolarH10DebugPage extends StatefulWidget {
  const PolarH10DebugPage({super.key, PolarH10Service? service})
    : _service = service;

  final PolarH10Service? _service;

  @override
  State<PolarH10DebugPage> createState() => _PolarH10DebugPageState();
}

class _PolarH10DebugPageState extends State<PolarH10DebugPage> {
  late final PolarH10Service _service = widget._service ?? PolarH10Service();
  late final PolarH10SensorProvider _provider = PolarH10SensorProvider(
    service: _service,
  );

  List<PolarH10Device> _devices = const [];
  final List<String> _diagnosticLog = [];
  Timer? _refreshTimer;
  PolarH10Device? _selectedDevice;
  PolarH10RrSample? _latestRr;
  PhysiologicalSample? _latestSample;
  SensorQualityEvaluation? _qualityEvaluation;
  PolarH10Statistics _statistics = const PolarH10Statistics(
    sampleCount: 0,
    averageRrMs: null,
    sdnnMs: null,
    rmssdMs: null,
    minHeartRate: null,
    maxHeartRate: null,
  );
  String _status = 'Desconectado';
  bool _busy = false;
  int _lastLoggedRrCount = 0;

  @override
  void initState() {
    super.initState();
    _addLog('Diagnóstico Polar H10 inicializado.');
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _refreshLatest(silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _service.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latestRr = _latestRr;
    final latestSample = _latestSample;
    final quality = _qualityEvaluation;
    final selectedDevice = _selectedDevice;
    final lastError = _service.lastError;
    final scanStarted = _service.lastScanStartedAt != null;
    final h10Found = _devices.isNotEmpty || _service.lastScanDevices.isNotEmpty;
    final signalStatus = _signalStatus(quality);
    final motionClass = _motionClass(latestSample?.movementIntensity);

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico Polar H10')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Diagnóstico Polar H10',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Área técnica para validar BLE e sinais vindos do Polar H10. '
            'HealthKit permanece separado no diagnóstico bruto HealthKit.',
          ),
          const SizedBox(height: 16),
          _StatusCard(status: _status, connected: _service.isConnected),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: _busy ? null : _scan,
                child: const Text('Scan Polar H10'),
              ),
              FilledButton.tonal(
                onPressed: _busy ? null : () => _refreshLatest(),
                child: const Text('Atualizar leitura'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final device in _devices)
            Card(
              child: ListTile(
                title: Text(device.name.isEmpty ? 'Polar H10' : device.name),
                subtitle: Text('${device.id} · RSSI ${device.rssi}'),
                selected: selectedDevice?.id == device.id,
                trailing: FilledButton.tonal(
                  onPressed: _busy ? null : () => _connect(device),
                  child: const Text('Conectar'),
                ),
              ),
            ),
          const SizedBox(height: 16),
          _DiagnosticCard(
            title: 'Estado do BLE',
            rows: [
              _DiagnosticRow(
                'Bluetooth disponível/autorizado',
                _bleAuthorizationLabel(),
              ),
              _DiagnosticRow('Scan iniciado', _yesNo(scanStarted)),
              _DiagnosticRow('Dispositivos encontrados', '${_devices.length}'),
              _DiagnosticRow('H10 encontrado', _yesNo(h10Found)),
              _DiagnosticRow('H10 conectado', _yesNo(_service.isConnected)),
              _DiagnosticRow('Estado interno', _service.connectionStatus.name),
              _DiagnosticRow('Erro de conexão/scan', lastError?.toString()),
            ],
          ),
          const SizedBox(height: 12),
          _DiagnosticCard(
            title: 'Identificação do sensor',
            rows: [
              _DiagnosticRow('Nome do dispositivo', selectedDevice?.name),
              _DiagnosticRow('Device ID', selectedDevice?.id),
              _DiagnosticRow('RSSI', selectedDevice?.rssi.toString()),
              _DiagnosticRow(
                'Timestamp da conexão',
                _time(_service.connectedAt),
              ),
              _DiagnosticRow(
                'Último scan iniciado',
                _time(_service.lastScanStartedAt),
              ),
              _DiagnosticRow(
                'Último scan concluído',
                _time(_service.lastScanCompletedAt),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DiagnosticCard(
            title: 'Dados cardíacos do Polar H10',
            rows: [
              _DiagnosticRow('Origem dos dados', 'Polar H10 BLE'),
              _DiagnosticRow(
                'Último FC/BPM recebido',
                _number(latestSample?.heartRateBpm),
              ),
              _DiagnosticRow(
                'Timestamp da última FC',
                _time(_service.lastHeartRateAt ?? latestRr?.timestamp),
              ),
              _DiagnosticRow(
                'Amostras de FC na sessão',
                '${_service.heartRateSampleCount}',
              ),
              _DiagnosticRow(
                'RR intervals recebidos',
                '${_service.rrIntervalCount}',
              ),
              _DiagnosticRow(
                'Último RR interval em ms',
                _number(latestRr?.rrIntervalMs),
              ),
              _DiagnosticRow(
                'Quantidade de RR intervals na sessão',
                '${_service.rrIntervalCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DiagnosticCard(
            title: 'HRV calculada do H10',
            rows: [
              _DiagnosticRow('RMSSD atual', _number(_statistics.rmssdMs)),
              _DiagnosticRow('SDNN atual', _number(_statistics.sdnnMs)),
              _DiagnosticRow('Janela usada', 'até 30 RR intervals recentes'),
              _DiagnosticRow(
                'RR válidos na janela',
                '${_statistics.sampleCount}',
              ),
              _DiagnosticRow(
                'RR descartados por artefato na sessão',
                '${_service.discardedRrIntervalCount}',
              ),
              _DiagnosticRow('Qualidade da janela', signalStatus),
              _DiagnosticRow(
                'Avisos de qualidade',
                quality?.warnings.isEmpty ?? true
                    ? null
                    : quality!.warnings.join('; '),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DiagnosticCard(
            title: 'Acelerômetro H10',
            rows: [
              const _DiagnosticRow(
                'Stream de acelerômetro',
                'inativo neste build',
              ),
              const _DiagnosticRow('Último X/Y/Z', 'n/a'),
              const _DiagnosticRow('motionRmsMg', 'n/a'),
              _DiagnosticRow('Classificação', motionClass),
              const _DiagnosticRow('Timestamp da última amostra', 'n/a'),
            ],
          ),
          const SizedBox(height: 12),
          _DiagnosticCard(
            title: 'Qualidade do sinal',
            rows: [
              _DiagnosticRow(
                'signalQuality atual',
                quality?.signalQuality.name,
              ),
              _DiagnosticRow('Status inferido', signalStatus),
              _DiagnosticRow(
                'RR inválidos detectados',
                '${quality?.artifactReport.invalidIntervalCount ?? 0}',
              ),
              _DiagnosticRow(
                'Mudanças abruptas detectadas',
                '${quality?.artifactReport.abruptChangeCount ?? 0}',
              ),
              _DiagnosticRow(
                'Contato do sensor',
                latestRr == null ? null : _yesNo(latestRr.contactDetected),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DiagnosticCard(
            title: 'Contexto ambiental',
            rows: [
              const _DiagnosticRow(
                'Origem',
                'Apple Watch/HealthKit, se disponível',
              ),
              _DiagnosticRow(
                'EnvironmentalContext atual',
                'EnvironmentalContext.${EnvironmentalContext.none.name}',
              ),
              const _DiagnosticRow(
                'Observação',
                'Sem dado ambiental local nesta tela; H10 não depende do Watch.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DiagnosticCard(
            title: 'Log técnico',
            rows: [
              _DiagnosticRow(
                'Eventos recentes',
                _diagnosticLog.isEmpty
                    ? 'sem eventos'
                    : _diagnosticLog.reversed.take(8).join('\n'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _scan() async {
    setState(() {
      _busy = true;
      _status = 'Escaneando...';
    });
    _addLog('scan BLE iniciado.');

    try {
      final devices = await _service.scanDevices();
      if (!mounted) {
        return;
      }

      setState(() {
        _devices = devices;
        _status = devices.isEmpty
            ? 'Nenhum Polar H10 encontrado.'
            : 'Dispositivos encontrados: ${devices.length}';
      });
      _addLog('scan BLE concluído: ${devices.length} dispositivo(s).');
      if (devices.isNotEmpty) {
        _addLog(
          'H10 encontrado: ${devices.map((device) => device.label).join(', ')}.',
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Erro no scan: $error';
      });
      _addLog('erro no scan BLE: $error');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _connect(PolarH10Device device) async {
    setState(() {
      _busy = true;
      _selectedDevice = device;
      _status = 'Conectando a ${device.label}...';
    });
    _addLog('tentando conectar em ${device.label}.');

    try {
      await _service.connect(device);
      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Conectado. Aguardando RR intervals.';
      });
      _addLog('conexão estabelecida com ${device.label}.');
      await _refreshLatest(silent: true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Erro ao conectar: $error';
      });
      _addLog('erro ao conectar: $error');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _refreshLatest({bool silent = false}) async {
    final latestRr = await _service.getLatestRrSample();
    final latestSample = await _provider.getLatestSample();
    final recent = await _service.getRecentRrSamples();
    if (!mounted) {
      return;
    }

    final statistics = PolarH10Statistics.fromSamples(recent);
    setState(() {
      _latestRr = latestRr;
      _latestSample = latestSample;
      _qualityEvaluation = _provider.lastQualityEvaluation;
      _statistics = statistics;
      if (!silent) {
        _status = latestRr == null
            ? 'Sem RR interval recebido ainda.'
            : 'Último RR recebido.';
      }
    });

    if (_service.rrIntervalCount > _lastLoggedRrCount) {
      _lastLoggedRrCount = _service.rrIntervalCount;
      _addLog(
        'dados H10 recebidos: FC ${_number(latestSample?.heartRateBpm)}, '
        'RR ${_number(latestRr?.rrIntervalMs)} ms.',
      );
    }
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final entry = '$timestamp $message';
    debugPrint('[PolarH10Diagnostics] $entry');
    if (!mounted) {
      _diagnosticLog.add(entry);
      return;
    }
    setState(() {
      _diagnosticLog.add(entry);
      if (_diagnosticLog.length > 40) {
        _diagnosticLog.removeRange(0, _diagnosticLog.length - 40);
      }
    });
  }

  String _bleAuthorizationLabel() {
    final status = _service.connectionStatus;
    if (_service.lastError != null) {
      return 'erro reportado pelo BLE: ${_service.lastError}';
    }
    if (status == PolarH10ConnectionStatus.scanning ||
        status == PolarH10ConnectionStatus.connecting ||
        status == PolarH10ConnectionStatus.connected) {
      return 'inferido como disponível pelo fluxo BLE';
    }
    return 'não verificado diretamente; inicie um scan';
  }

  String _signalStatus(SensorQualityEvaluation? quality) {
    if (!_service.isConnected) {
      return 'disconnected';
    }
    if (_statistics.sampleCount < 3) {
      return 'sparse';
    }
    if (quality?.artifactReport.hasArtifacts ?? false) {
      return 'noisy';
    }
    return quality?.signalQuality.name ?? 'good';
  }

  String _motionClass(double? movementIntensity) {
    if (movementIntensity == null) {
      return 'indisponível';
    }
    if (movementIntensity >= 0.75) {
      return 'movimento alto';
    }
    if (movementIntensity >= 0.45) {
      return 'movimento moderado';
    }
    if (movementIntensity > 0.1) {
      return 'movimento leve';
    }
    return 'parado';
  }

  String _yesNo(bool value) => value ? 'sim' : 'não';

  String? _number(double? value) => value?.toStringAsFixed(1);

  String? _time(DateTime? value) => value?.toIso8601String();
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status, required this.connected});

  final String status;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(status),
            const SizedBox(height: 4),
            Text('Conexão: ${connected ? 'ativa' : 'inativa'}'),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticCard extends StatelessWidget {
  const _DiagnosticCard({required this.title, required this.rows});

  final String title;
  final List<_DiagnosticRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final row in rows) row,
          ],
        ),
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow(this.label, this.value);

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = value == null || value!.trim().isEmpty ? 'n/a' : value!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: Text(text, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
