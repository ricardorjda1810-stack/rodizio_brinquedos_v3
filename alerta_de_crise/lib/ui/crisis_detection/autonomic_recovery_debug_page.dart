import 'package:flutter/material.dart';

import '../../autonomic_recovery/autonomic_recovery_models.dart';
import '../../autonomic_recovery/recovery_analysis_service.dart';
import '../../core/crisis_detection/baseline_profile.dart';
import '../../core/crisis_detection/physiological_sample.dart';
import '../../session_timeline/physiological_event_marker.dart';

class AutonomicRecoveryDebugPage extends StatefulWidget {
  const AutonomicRecoveryDebugPage({super.key});

  @override
  State<AutonomicRecoveryDebugPage> createState() =>
      _AutonomicRecoveryDebugPageState();
}

class _AutonomicRecoveryDebugPageState
    extends State<AutonomicRecoveryDebugPage> {
  final _service = const RecoveryAnalysisService();
  AutonomicRecoveryProfile? _profile;

  Future<void> _simulateFastRecovery() async {
    final now = DateTime.now();
    final profile = await _service.analyzeRecovery(
      samples: [
        _sample(now.subtract(const Duration(minutes: 5)), 105, 28),
        _sample(now.subtract(const Duration(minutes: 3)), 88, 36),
        _sample(now.subtract(const Duration(minutes: 1)), 74, 42),
      ],
      baseline: BaselineProfile.safeDefault(),
      markers: [_activationMarker(now.subtract(const Duration(minutes: 4)))],
      timelineId: 'recovery-debug-fast',
    );
    setState(() => _profile = profile);
  }

  Future<void> _simulateSlowRecovery() async {
    final now = DateTime.now();
    final profile = await _service.analyzeRecovery(
      samples: [
        _sample(now.subtract(const Duration(minutes: 25)), 108, 28),
        _sample(now.subtract(const Duration(minutes: 15)), 101, 29),
        _sample(now.subtract(const Duration(minutes: 5)), 96, 30),
      ],
      baseline: BaselineProfile.safeDefault(),
      markers: [
        _activationMarker(now.subtract(const Duration(minutes: 20))),
        _activationMarker(now.subtract(const Duration(minutes: 10))),
      ],
      timelineId: 'recovery-debug-slow',
      previousStressCarryover: 0.4,
    );
    setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Autonomic Recovery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Modelagem experimental de recuperação fisiológica e resiliência. '
            'Não é diagnóstico médico.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _simulateFastRecovery,
                child: const Text('Simular recuperação rápida'),
              ),
              OutlinedButton(
                onPressed: _simulateSlowRecovery,
                child: const Text('Simular recuperação lenta'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MetricTile(
            label: 'Resilience score',
            value: '${profile?.resilienceScore ?? '-'}',
          ),
          _MetricTile(
            label: 'Fatigue score',
            value: '${profile?.fatigueScore ?? '-'}',
          ),
          _MetricTile(
            label: 'Stress carryover',
            value: profile?.stressCarryover.toStringAsFixed(2) ?? '-',
          ),
          _MetricTile(
            label: 'Baseline return time',
            value: profile?.baselineReturnTime == null
                ? '-'
                : '${profile!.baselineReturnTime!.inSeconds}s',
          ),
          _MetricTile(
            label: 'Recovery slope',
            value: profile?.hrvRecoverySlope.toStringAsFixed(2) ?? '-',
          ),
          _MetricTile(
            label: 'Recovery rate',
            value: profile?.recoveryRate.toStringAsFixed(2) ?? '-',
          ),
          _MetricTile(
            label: 'Level',
            value: profile?.resilienceLevel.name ?? '-',
          ),
        ],
      ),
    );
  }

  PhysiologicalSample _sample(DateTime timestamp, double hr, double hrv) {
    return PhysiologicalSample(
      timestamp: timestamp,
      heartRateBpm: hr,
      hrvRmssdMs: hrv,
      movementIntensity: 0.18,
    );
  }

  PhysiologicalEventMarker _activationMarker(DateTime timestamp) {
    return PhysiologicalEventMarker(
      id: 'activation-${timestamp.microsecondsSinceEpoch}',
      timestamp: timestamp,
      type: EventType.elevatedHeartRate,
      title: 'Ativação fisiológica',
      description: 'Marcador simulado para recuperação.',
      severity: Severity.medium,
      source: 'debug',
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      trailing: Text(value),
    );
  }
}
