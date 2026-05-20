import 'sensor_reliability_models.dart';

class ReliabilityScoreService {
  const ReliabilityScoreService();

  double calculateReliabilityScore({
    required double averageConfidence,
    required double artifactRate,
    required double missingDataRate,
    required double timingDriftMs,
    required double agreementWithReference,
  }) {
    final artifactPenalty = artifactRate.clamp(0, 100) * 0.22;
    final missingPenalty = missingDataRate.clamp(0, 100) * 0.2;
    final driftPenalty = (timingDriftMs / 100).clamp(0, 20).toDouble();
    final score =
        (averageConfidence * 0.28) +
        (agreementWithReference * 0.44) -
        artifactPenalty -
        missingPenalty -
        driftPenalty +
        _agreementBonus(agreementWithReference);
    return score.clamp(0, 100).toDouble();
  }

  SensorReliabilityProfile buildProfile({
    required String sensorType,
    required List<SensorReading> readings,
    required double agreementWithReference,
    required double timingDriftMs,
    required DateTime generatedAt,
  }) {
    final sampleCount = readings.length;
    final averageConfidence = _average(readings.map((r) => r.confidence));
    final artifactRate = sampleCount == 0
        ? 0.0
        : readings.where((r) => r.artifact).length / sampleCount * 100;
    final missingDataRate = sampleCount == 0
        ? 0.0
        : readings.where((r) => r.missingData).length / sampleCount * 100;
    final reliabilityScore = calculateReliabilityScore(
      averageConfidence: averageConfidence,
      artifactRate: artifactRate,
      missingDataRate: missingDataRate,
      timingDriftMs: timingDriftMs,
      agreementWithReference: agreementWithReference,
    );
    return SensorReliabilityProfile(
      sensorType: sensorType,
      sampleCount: sampleCount,
      averageConfidence: averageConfidence,
      artifactRate: artifactRate,
      missingDataRate: missingDataRate,
      timingDriftMs: timingDriftMs,
      agreementWithReference: agreementWithReference,
      reliabilityScore: reliabilityScore,
      generatedAt: generatedAt,
    );
  }

  double _agreementBonus(double agreement) {
    return agreement >= 90 ? 5 : 0;
  }

  double _average(Iterable<double> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    return list.fold<double>(0, (sum, value) => sum + value) / list.length;
  }
}
