import '../core/crisis_detection/physiological_sample.dart';
import 'physiological_signal_quality.dart';
import 'rr_artifact_detector.dart';
import 'sensor_confidence_score.dart';
import 'sensor_quality_models.dart';

class SensorQualityService {
  final RrArtifactDetector _artifactDetector;

  const SensorQualityService({
    RrArtifactDetector artifactDetector = const RrArtifactDetector(),
  }) : _artifactDetector = artifactDetector;

  SensorQualityEvaluation evaluateSampleQuality({
    required PhysiologicalSample sample,
    List<double> rrIntervalsMs = const [],
    bool? contactDetected,
  }) {
    final artifactReport = _artifactDetector.detect(
      rrIntervalsMs: rrIntervalsMs,
      heartRateBpm: sample.heartRateBpm,
    );
    final warnings = <String>[...artifactReport.warnings];

    final rrQuality = _rrQuality(rrIntervalsMs, artifactReport);
    final hrQuality = _hrQuality(sample.heartRateBpm);
    final movementConfidence = _movementConfidence(sample.movementIntensity);
    final contactConfidence = _contactConfidence(contactDetected);

    if (sample.movementIntensity > 0.65) {
      warnings.add('high_movement_reduces_confidence');
    }

    if (contactDetected == false) {
      warnings.add('sensor_contact_not_detected');
    }

    final overallScore =
        ((rrQuality * 0.30) +
                (hrQuality * 0.35) +
                (movementConfidence * 0.20) +
                (contactConfidence * 0.15))
            .round()
            .clamp(0, 100);
    final signalQuality = _qualityFromScore(overallScore);

    return SensorQualityEvaluation(
      artifactReport: artifactReport,
      signalQuality: signalQuality,
      confidenceScore: SensorConfidenceScore(
        overallScore: overallScore,
        rrQuality: rrQuality,
        hrQuality: hrQuality,
        movementConfidence: movementConfidence,
        contactConfidence: contactConfidence,
        hasArtifacts: artifactReport.hasArtifacts,
        warnings: List.unmodifiable(warnings),
      ),
    );
  }

  int _rrQuality(List<double> rrIntervalsMs, RrArtifactReport report) {
    if (rrIntervalsMs.isEmpty) {
      return 75;
    }

    var score = 100;
    score -= report.invalidIntervalCount * 30;
    score -= report.abruptChangeCount * 20;
    if (report.hasExtremeJitter) {
      score -= 25;
    }

    return score.clamp(0, 100);
  }

  int _hrQuality(double heartRateBpm) {
    if (heartRateBpm < 25 || heartRateBpm > 240) {
      return 10;
    }

    if (heartRateBpm < 35 || heartRateBpm > 210) {
      return 60;
    }

    return 100;
  }

  int _movementConfidence(double movementIntensity) {
    if (movementIntensity < 0 || movementIntensity > 1) {
      return 20;
    }

    if (movementIntensity <= 0.35) {
      return 100;
    }

    if (movementIntensity <= 0.65) {
      return 75;
    }

    return 45;
  }

  int _contactConfidence(bool? contactDetected) {
    if (contactDetected == null) {
      return 80;
    }

    return contactDetected ? 100 : 20;
  }

  PhysiologicalSignalQuality _qualityFromScore(int score) {
    if (score >= 90) {
      return PhysiologicalSignalQuality.excellent;
    }
    if (score >= 75) {
      return PhysiologicalSignalQuality.good;
    }
    if (score >= 50) {
      return PhysiologicalSignalQuality.degraded;
    }

    return PhysiologicalSignalQuality.poor;
  }
}
