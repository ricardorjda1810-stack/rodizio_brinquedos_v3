import 'physiological_signal_quality.dart';
import 'sensor_confidence_score.dart';

class RrArtifactReport {
  final int totalIntervals;
  final int invalidIntervalCount;
  final int abruptChangeCount;
  final bool hasInvalidHeartRate;
  final bool hasExtremeJitter;
  final List<String> warnings;

  const RrArtifactReport({
    required this.totalIntervals,
    required this.invalidIntervalCount,
    required this.abruptChangeCount,
    required this.hasInvalidHeartRate,
    required this.hasExtremeJitter,
    required this.warnings,
  });

  bool get hasArtifacts {
    return invalidIntervalCount > 0 ||
        abruptChangeCount > 0 ||
        hasInvalidHeartRate ||
        hasExtremeJitter;
  }
}

class SensorQualityEvaluation {
  final SensorConfidenceScore confidenceScore;
  final PhysiologicalSignalQuality signalQuality;
  final RrArtifactReport artifactReport;

  const SensorQualityEvaluation({
    required this.confidenceScore,
    required this.signalQuality,
    required this.artifactReport,
  });

  List<String> get warnings => confidenceScore.warnings;
}
