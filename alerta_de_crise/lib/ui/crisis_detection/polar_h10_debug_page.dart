import 'package:flutter/material.dart';

import '../../core/crisis_detection/polar_h10_sensor_provider.dart';
import '../../core/crisis_detection/physiological_sample.dart';
import '../../polar_h10/polar_h10_device.dart';
import '../../polar_h10/polar_h10_rr_sample.dart';
import '../../polar_h10/polar_h10_service.dart';
import '../../polar_h10/polar_h10_statistics.dart';

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
  PolarH10Device? _selectedDevice;
  PolarH10RrSample? _latestRr;
  PhysiologicalSample? _latestSample;
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

  @override
  void dispose() {
    _service.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latestRr = _latestRr;
    final latestSample = _latestSample;

    return Scaffold(
      appBar: AppBar(title: const Text('Polar H10 debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Integração BLE experimental para RR intervals.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Uso local de pesquisa/autoconhecimento. Não interpreta ECG e não realiza diagnóstico.',
          ),
          const SizedBox(height: 16),
          _StatusCard(status: _status, connected: _service.isConnected),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _scan,
            child: const Text('Scan Polar H10'),
          ),
          const SizedBox(height: 12),
          for (final device in _devices)
            Card(
              child: ListTile(
                title: Text(device.name.isEmpty ? 'Polar H10' : device.name),
                subtitle: Text('${device.id} · RSSI ${device.rssi}'),
                selected: _selectedDevice?.id == device.id,
                trailing: FilledButton.tonal(
                  onPressed: _busy ? null : () => _connect(device),
                  child: const Text('Conectar'),
                ),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: _busy ? null : _refreshLatest,
            child: const Text('Atualizar leitura'),
          ),
          const SizedBox(height: 16),
          _MetricCard(
            title: 'Leitura atual',
            rows: [
              _MetricRow('FC atual', latestSample?.heartRateBpm),
              _MetricRow('RR atual ms', latestRr?.rrIntervalMs),
              _MetricRow('RMSSD simples', _statistics.rmssdMs),
              _MetricRow('SDNN simples', _statistics.sdnnMs),
              _MetricRow(
                'Sensor contact',
                latestRr == null ? null : (latestRr.contactDetected ? 1 : 0),
                formatter: (value) => value == 1 ? 'sim' : 'não',
              ),
              _MetricRow(
                'Samples RR',
                _statistics.sampleCount.toDouble(),
                formatter: (value) => value.toInt().toString(),
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
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Erro no scan: $error';
      });
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

    try {
      await _service.connect(device);
      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Conectado. Aguardando RR intervals.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Erro ao conectar: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _refreshLatest() async {
    final latestRr = await _service.getLatestRrSample();
    final latestSample = await _provider.getLatestSample();
    final recent = await _service.getRecentRrSamples();
    if (!mounted) {
      return;
    }

    setState(() {
      _latestRr = latestRr;
      _latestSample = latestSample;
      _statistics = PolarH10Statistics.fromSamples(recent);
      _status = latestRr == null
          ? 'Sem RR interval recebido ainda.'
          : 'Último RR recebido.';
    });
  }
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.rows});

  final String title;
  final List<_MetricRow> rows;

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

class _MetricRow extends StatelessWidget {
  const _MetricRow(this.label, this.value, {this.formatter});

  final String label;
  final double? value;
  final String Function(double value)? formatter;

  @override
  Widget build(BuildContext context) {
    final metricValue = value;
    final text = metricValue == null
        ? 'n/a'
        : formatter?.call(metricValue) ?? metricValue.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Text(text),
        ],
      ),
    );
  }
}
