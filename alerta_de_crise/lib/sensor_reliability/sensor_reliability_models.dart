class SensorReading {
  final String sensorType;
  final DateTime timestamp;
  final double heartRate;
  final double hrv;
  final double confidence;
  final bool artifact;
  final bool missingData;

  const SensorReading({
    required this.sensorType,
    required this.timestamp,
    required this.heartRate,
    required this.hrv,
    required this.confidence,
    this.artifact = false,
    this.missingData = false,
  });
}

class SensorReliabilityProfile {
  final String sensorType;
  final int sampleCount;
  final double averageConfidence;
  final double artifactRate;
  final double missingDataRate;
  final double timingDriftMs;
  final double agreementWithReference;
  final double reliabilityScore;
  final DateTime generatedAt;

  const SensorReliabilityProfile({
    required this.sensorType,
    required this.sampleCount,
    required this.averageConfidence,
    required this.artifactRate,
    required this.missingDataRate,
    required this.timingDriftMs,
    required this.agreementWithReference,
    required this.reliabilityScore,
    required this.generatedAt,
  });

  String get safetyCopy =>
      'referência experimental; confiabilidade do sensor; não representa validação clínica.';
}

class SensorComparisonResult {
  final String primarySensor;
  final String referenceSensor;
  final double heartRateAgreement;
  final double hrvAgreement;
  final double timingAgreement;
  final int divergenceCount;
  final double averageDriftMs;
  final double confidenceDelta;
  final DateTime generatedAt;

  const SensorComparisonResult({
    required this.primarySensor,
    required this.referenceSensor,
    required this.heartRateAgreement,
    required this.hrvAgreement,
    required this.timingAgreement,
    required this.divergenceCount,
    required this.averageDriftMs,
    required this.confidenceDelta,
    required this.generatedAt,
  });

  double get agreementScore =>
      ((heartRateAgreement * 0.35) +
              (hrvAgreement * 0.3) +
              (timingAgreement * 0.2) +
              ((100 - confidenceDelta).clamp(0, 100) * 0.15))
          .clamp(0, 100)
          .toDouble();

  String get safetyCopy =>
      'comparação técnica de sinais com referência experimental; não representa validação clínica.';
}

class SensorReliabilityReport {
  final SensorReliabilityProfile profile;
  final SensorComparisonResult comparison;
  final List<String> divergenceFactors;
  final List<String> summary;

  const SensorReliabilityReport({
    required this.profile,
    required this.comparison,
    required this.divergenceFactors,
    required this.summary,
  });
}
