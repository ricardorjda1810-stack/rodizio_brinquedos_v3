import 'package:flutter/material.dart';

import '../../sensor_reliability/ground_truth_validation_service.dart';
import '../../sensor_reliability/sensor_reliability_models.dart';

class SensorReliabilityDebugPage extends StatefulWidget {
  const SensorReliabilityDebugPage({super.key});

  @override
  State<SensorReliabilityDebugPage> createState() =>
      _SensorReliabilityDebugPageState();
}

class _SensorReliabilityDebugPageState
    extends State<SensorReliabilityDebugPage> {
  final GroundTruthValidationService _validationService =
      GroundTruthValidationService();
  SensorReliabilityReport? _report;
  bool _simulateDivergence = false;

  Future<void> _validate() async {
    final reference = _polarReference();
    final primary = _simulateDivergence
        ? _appleDivergentSamples()
        : _appleAlignedSamples();
    final report = await _validationService.validateAgainstReference(
      primarySensor: 'Apple Health',
      primaryReadings: primary,
      referenceReadings: reference,
    );
    setState(() => _report = report);
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    final comparison = report?.comparison;
    final profile = report?.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Reliability')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'referência experimental; comparação técnica de sinais; não representa validação clínica.',
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _simulateDivergence,
            onChanged: (value) => setState(() => _simulateDivergence = value),
            title: const Text('Simular divergência'),
            subtitle: const Text('divergência entre sensores'),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _validate,
                child: const Text('Validar contra referência'),
              ),
              OutlinedButton(
                onPressed: _validate,
                child: const Text('Recalcular'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricTile(
            title: 'HR agreement',
            value: comparison?.heartRateAgreement.toStringAsFixed(0) ?? '-',
            subtitle: 'comparação de sinais',
          ),
          _MetricTile(
            title: 'HRV agreement',
            value: comparison?.hrvAgreement.toStringAsFixed(0) ?? '-',
            subtitle: 'referência experimental',
          ),
          _MetricTile(
            title: 'Timing drift',
            value: comparison?.averageDriftMs.toStringAsFixed(0) ?? '-',
            subtitle: 'drift temporal',
          ),
          _MetricTile(
            title: 'Confidence delta',
            value: comparison?.confidenceDelta.toStringAsFixed(0) ?? '-',
            subtitle: 'confiabilidade do sensor',
          ),
          _MetricTile(
            title: 'Reliability score',
            value: profile?.reliabilityScore.toStringAsFixed(0) ?? '-',
            subtitle: profile?.safetyCopy ?? 'validação experimental',
          ),
          _MetricTile(
            title: 'Divergence count',
            value: comparison?.divergenceCount.toString() ?? '-',
            subtitle: 'divergência entre sensores',
          ),
          for (final line in report?.summary ?? const <String>[])
            Card(
              child: ListTile(
                title: const Text('Ground truth experimental report'),
                subtitle: Text(line),
              ),
            ),
          for (final factor in report?.divergenceFactors ?? const <String>[])
            Card(
              child: ListTile(
                title: const Text('Divergence factor'),
                subtitle: Text(factor),
              ),
            ),
        ],
      ),
    );
  }

  List<SensorReading> _polarReference() {
    final start = DateTime.utc(2026, 5, 18, 12);
    return [
      SensorReading(
        sensorType: 'Polar H10',
        timestamp: start,
        heartRate: 72,
        hrv: 42,
        confidence: 94,
      ),
      SensorReading(
        sensorType: 'Polar H10',
        timestamp: start.add(const Duration(seconds: 10)),
        heartRate: 74,
        hrv: 40,
        confidence: 95,
      ),
      SensorReading(
        sensorType: 'Polar H10',
        timestamp: start.add(const Duration(seconds: 20)),
        heartRate: 78,
        hrv: 37,
        confidence: 93,
      ),
    ];
  }

  List<SensorReading> _appleAlignedSamples() {
    final start = DateTime.utc(2026, 5, 18, 12);
    return [
      SensorReading(
        sensorType: 'Apple Health',
        timestamp: start.add(const Duration(milliseconds: 120)),
        heartRate: 73,
        hrv: 41,
        confidence: 88,
      ),
      SensorReading(
        sensorType: 'Apple Health',
        timestamp: start.add(const Duration(seconds: 10, milliseconds: 140)),
        heartRate: 75,
        hrv: 39,
        confidence: 87,
      ),
      SensorReading(
        sensorType: 'Apple Health',
        timestamp: start.add(const Duration(seconds: 20, milliseconds: 160)),
        heartRate: 79,
        hrv: 36,
        confidence: 86,
      ),
    ];
  }

  List<SensorReading> _appleDivergentSamples() {
    final start = DateTime.utc(2026, 5, 18, 12);
    return [
      SensorReading(
        sensorType: 'Apple Health',
        timestamp: start.add(const Duration(seconds: 3)),
        heartRate: 88,
        hrv: 25,
        confidence: 60,
      ),
      SensorReading(
        sensorType: 'Apple Health',
        timestamp: start.add(const Duration(seconds: 13)),
        heartRate: 92,
        hrv: 23,
        confidence: 58,
        artifact: true,
      ),
      SensorReading(
        sensorType: 'Apple Health',
        timestamp: start.add(const Duration(seconds: 23)),
        heartRate: 95,
        hrv: 22,
        confidence: 55,
        missingData: true,
      ),
    ];
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(value),
      ),
    );
  }
}
