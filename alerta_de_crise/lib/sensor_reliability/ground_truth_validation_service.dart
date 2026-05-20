import '../database/signalflow_database.dart';
import 'reliability_score_service.dart';
import 'sensor_comparison_service.dart';
import 'sensor_divergence_detector.dart';
import 'sensor_reliability_models.dart';

class GroundTruthValidationService {
  final SignalFlowDatabase _database;
  final SensorComparisonService _comparisonService;
  final SensorDivergenceDetector _divergenceDetector;
  final ReliabilityScoreService _scoreService;
  final DateTime Function() _now;

  GroundTruthValidationService({
    SignalFlowDatabase? database,
    SensorComparisonService comparisonService = const SensorComparisonService(),
    SensorDivergenceDetector divergenceDetector =
        const SensorDivergenceDetector(),
    ReliabilityScoreService scoreService = const ReliabilityScoreService(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _comparisonService = comparisonService,
       _divergenceDetector = divergenceDetector,
       _scoreService = scoreService,
       _now = now ?? DateTime.now;

  Future<SensorReliabilityReport> validateAgainstReference({
    required String primarySensor,
    String referenceSensor = 'Polar H10',
    required List<SensorReading> primaryReadings,
    required List<SensorReading> referenceReadings,
    bool persist = false,
  }) async {
    final comparison = _comparisonService.compareSensors(
      primarySensor: primarySensor,
      referenceSensor: referenceSensor,
      primaryReadings: primaryReadings,
      referenceReadings: referenceReadings,
    );
    final agreement = calculateReferenceAgreement(comparison);
    final profile = _scoreService.buildProfile(
      sensorType: primarySensor,
      readings: primaryReadings,
      agreementWithReference: agreement,
      timingDriftMs: comparison.averageDriftMs,
      generatedAt: _now(),
    );
    final divergences = _divergenceDetector.detectDivergences(
      primaryReadings: primaryReadings,
      referenceReadings: referenceReadings,
    );
    final report = SensorReliabilityReport(
      profile: profile,
      comparison: comparison,
      divergenceFactors: divergences,
      summary: generateValidationReport(profile, comparison, divergences),
    );
    if (persist) {
      await persistProfile(profile);
      await persistComparison(comparison);
    }
    return report;
  }

  List<String> generateValidationReport(
    SensorReliabilityProfile profile,
    SensorComparisonResult comparison,
    List<String> divergenceFactors,
  ) {
    return [
      'referência experimental: ${comparison.referenceSensor}; não representa validação clínica.',
      'confiabilidade do sensor ${profile.sensorType}: ${profile.reliabilityScore.toStringAsFixed(0)}.',
      'comparação técnica de sinais com ${divergenceFactors.length} divergência entre sensores.',
    ];
  }

  double calculateReferenceAgreement(SensorComparisonResult comparison) {
    return comparison.agreementScore;
  }

  Future<void> persistProfile(SensorReliabilityProfile profile) async {
    await _database
        .into(_database.sensorReliabilityProfilesTable)
        .insertOnConflictUpdate(
          SensorReliabilityProfilesTableCompanion.insert(
            sensorType: profile.sensorType,
            sampleCount: profile.sampleCount,
            averageConfidence: profile.averageConfidence,
            artifactRate: profile.artifactRate,
            missingDataRate: profile.missingDataRate,
            timingDriftMs: profile.timingDriftMs,
            agreementWithReference: profile.agreementWithReference,
            reliabilityScore: profile.reliabilityScore,
            generatedAt: profile.generatedAt,
            safetyCopy: profile.safetyCopy,
          ),
        );
  }

  Future<void> persistComparison(SensorComparisonResult comparison) async {
    await _database
        .into(_database.sensorComparisonResultsTable)
        .insert(
          SensorComparisonResultsTableCompanion.insert(
            id: 'comparison-${comparison.primarySensor}-${comparison.generatedAt.microsecondsSinceEpoch}',
            primarySensor: comparison.primarySensor,
            referenceSensor: comparison.referenceSensor,
            heartRateAgreement: comparison.heartRateAgreement,
            hrvAgreement: comparison.hrvAgreement,
            timingAgreement: comparison.timingAgreement,
            divergenceCount: comparison.divergenceCount,
            averageDriftMs: comparison.averageDriftMs,
            confidenceDelta: comparison.confidenceDelta,
            generatedAt: comparison.generatedAt,
            safetyCopy: comparison.safetyCopy,
          ),
        );
  }

  Future<List<SensorReliabilityProfile>> loadProfiles() async {
    final rows = await _database
        .select(_database.sensorReliabilityProfilesTable)
        .get();
    return rows.map(_profileFromRow).toList(growable: false);
  }

  SensorReliabilityProfile _profileFromRow(
    SensorReliabilityProfilesTableData row,
  ) {
    return SensorReliabilityProfile(
      sensorType: row.sensorType,
      sampleCount: row.sampleCount,
      averageConfidence: row.averageConfidence,
      artifactRate: row.artifactRate,
      missingDataRate: row.missingDataRate,
      timingDriftMs: row.timingDriftMs,
      agreementWithReference: row.agreementWithReference,
      reliabilityScore: row.reliabilityScore,
      generatedAt: row.generatedAt,
    );
  }
}
