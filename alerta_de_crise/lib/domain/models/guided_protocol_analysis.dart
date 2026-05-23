import 'phase_analysis.dart';
import 'session_sample.dart';

final class GuidedProtocolAnalysis {
  const GuidedProtocolAnalysis({
    required this.phases,
    required this.totalSamples,
    required this.overallAverageHeartRate,
    required this.overallAverageHrv,
  });

  factory GuidedProtocolAnalysis.fromSamples(List<SessionSample> samples) {
    final labeledSamples = samples
        .where((sample) => sample.protocolStepLabel?.isNotEmpty ?? false)
        .toList();
    final groupedSamples = <String, List<SessionSample>>{};

    for (final sample in labeledSamples) {
      groupedSamples
          .putIfAbsent(sample.protocolStepLabel!, () => <SessionSample>[])
          .add(sample);
    }

    final phases =
        groupedSamples.entries
            .map(
              (entry) => PhaseAnalysis.fromSamples(
                stepLabel: entry.key,
                samples: entry.value,
              ),
            )
            .toList()
          ..sort(_comparePhases);

    final heartRates = labeledSamples
        .map((sample) => sample.heartRate)
        .toList();
    final hrvValues = labeledSamples
        .where(_hasAvailableHrv)
        .map((sample) => sample.hrv)
        .toList();

    return GuidedProtocolAnalysis(
      phases: phases,
      totalSamples: labeledSamples.length,
      overallAverageHeartRate: heartRates.isEmpty ? 0 : _average(heartRates),
      overallAverageHrv: hrvValues.isEmpty ? null : _average(hrvValues),
    );
  }

  final List<PhaseAnalysis> phases;
  final int totalSamples;
  final double overallAverageHeartRate;
  final double? overallAverageHrv;

  bool get hasEnoughDataForCompleteAnalysis {
    final phaseLabels = phases.map((phase) => phase.stepLabel).toSet();
    return totalSamples >= 3 &&
        phaseLabels.contains('Repouso') &&
        phaseLabels.contains('Ativação leve') &&
        phaseLabels.contains('Recuperação');
  }

  List<String> get missingRequiredPhaseLabels {
    final phaseLabels = phases.map((phase) => phase.stepLabel).toSet();
    return [
      if (!phaseLabels.contains('Repouso')) 'Repouso inicial',
      if (!phaseLabels.contains('Ativação leve')) 'Movimento leve/controlado',
      if (!phaseLabels.contains('Recuperação')) 'Recuperação',
    ];
  }

  static int _comparePhases(PhaseAnalysis a, PhaseAnalysis b) {
    return _phaseOrder(a.stepLabel).compareTo(_phaseOrder(b.stepLabel));
  }

  static int _phaseOrder(String label) {
    return switch (label) {
      'Repouso' => 0,
      'Ativação leve' => 1,
      'Recuperação' => 2,
      'Feedback' => 3,
      _ => 4,
    };
  }

  static bool _hasAvailableHrv(SessionSample sample) {
    return sample.motionState != 'healthkit-hrv-indisponivel' && sample.hrv > 0;
  }

  static double _average(List<int> values) {
    return values.fold<int>(0, (sum, value) => sum + value) / values.length;
  }
}
