import 'package:flutter/material.dart';

import '../../core/crisis_detection/apple_health_sensor_provider.dart';
import '../../core/crisis_detection/sensor_provider_registry.dart';
import '../../core/crisis_detection/sensor_provider_type.dart';
import '../../platform/apple_health/apple_health_models.dart';
import '../../platform/apple_health/apple_health_service.dart';

class AppleHealthDebugPage extends StatefulWidget {
  const AppleHealthDebugPage({super.key});

  @override
  State<AppleHealthDebugPage> createState() => _AppleHealthDebugPageState();
}

class _AppleHealthDebugPageState extends State<AppleHealthDebugPage> {
  final AppleHealthService _service = AppleHealthService.defaultBridge();
  late final AppleHealthSensorProvider _provider = AppleHealthSensorProvider(
    service: _service,
  );
  late final SensorProviderRegistry _registry = SensorProviderRegistry()
    ..register(_provider);

  bool? _isAvailable;
  bool? _permissionsGranted;
  AppleHealthQuantitySample? _heartRate;
  AppleHealthQuantitySample? _hrv;
  AppleHealthQuantitySample? _spo2;
  String _statusMessage = 'HealthKit ainda não verificado.';

  @override
  Widget build(BuildContext context) {
    final providerType = _registry.getCurrent().type;

    return Scaffold(
      appBar: AppBar(title: const Text('Apple Health debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Bridge inicial para leitura pontual do Apple Health.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Provider atual', value: providerType.name),
          _InfoRow(label: 'Disponível', value: _formatBool(_isAvailable)),
          _InfoRow(
            label: 'Permissões',
            value: _formatBool(_permissionsGranted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _checkAvailability,
                child: const Text('Verificar HealthKit'),
              ),
              FilledButton.tonal(
                onPressed: _requestPermissions,
                child: const Text('Solicitar permissões'),
              ),
              OutlinedButton(
                onPressed: _loadLatest,
                child: const Text('Ler dados recentes'),
              ),
              OutlinedButton(
                onPressed: _useAppleHealthProvider,
                child: const Text('Usar provider Apple Health'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_statusMessage),
          const SizedBox(height: 16),
          _SampleRow(
            label: 'FC mais recente',
            sample: _heartRate,
            suffix: 'bpm',
          ),
          _SampleRow(label: 'HRV mais recente', sample: _hrv, suffix: 'ms'),
          _SampleRow(label: 'SpO2 mais recente', sample: _spo2, suffix: '%'),
          const SizedBox(height: 16),
          Text(
            'Esta tela faz leituras manuais e não ativa monitoramento contínuo.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _checkAvailability() async {
    final available = await _service.isAvailable();
    setState(() {
      _isAvailable = available;
      _statusMessage = available
          ? 'HealthKit disponível para verificação.'
          : 'HealthKit indisponível neste ambiente.';
    });
  }

  Future<void> _requestPermissions() async {
    final granted = await _provider.requestPermissions();
    setState(() {
      _permissionsGranted = granted;
      _statusMessage = granted
          ? 'Permissões de leitura concedidas.'
          : 'Permissões de leitura não concedidas.';
    });
  }

  Future<void> _loadLatest() async {
    final heartRate = await _service.getLatestHeartRate();
    final hrv = await _service.getLatestHrv();
    final spo2 = await _service.getLatestSpo2();

    setState(() {
      _heartRate = heartRate;
      _hrv = hrv;
      _spo2 = spo2;
      _statusMessage = heartRate == null
          ? 'Nenhuma frequência cardíaca recente encontrada.'
          : 'Dados recentes carregados.';
    });
  }

  void _useAppleHealthProvider() {
    setState(() {
      _registry.switchProvider(SensorProviderType.appleWatch);
      _statusMessage = 'Provider Apple Health selecionado nesta tela debug.';
    });
  }

  String _formatBool(bool? value) {
    return switch (value) {
      true => 'sim',
      false => 'não',
      null => 'não verificado',
    };
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: $value'),
    );
  }
}

class _SampleRow extends StatelessWidget {
  final String label;
  final AppleHealthQuantitySample? sample;
  final String suffix;

  const _SampleRow({
    required this.label,
    required this.sample,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final sample = this.sample;
    final value = sample == null
        ? 'não encontrado'
        : '${sample.normalizedValue.toStringAsFixed(1)} $suffix '
              '(${sample.timestamp.toIso8601String()})';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: $value'),
    );
  }
}
