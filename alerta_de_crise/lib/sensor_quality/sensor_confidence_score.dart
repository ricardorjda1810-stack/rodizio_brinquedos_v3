class SensorConfidenceScore {
  final int overallScore;
  final int rrQuality;
  final int hrQuality;
  final int movementConfidence;
  final int contactConfidence;
  final bool hasArtifacts;
  final List<String> warnings;

  const SensorConfidenceScore({
    required this.overallScore,
    required this.rrQuality,
    required this.hrQuality,
    required this.movementConfidence,
    required this.contactConfidence,
    required this.hasArtifacts,
    required this.warnings,
  });
}
