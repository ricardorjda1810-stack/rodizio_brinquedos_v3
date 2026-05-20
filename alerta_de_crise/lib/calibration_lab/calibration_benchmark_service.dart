import 'package:drift/drift.dart';

import '../database/signalflow_database.dart';
import '../replay_benchmark/replay_benchmark_runner.dart';
import 'calibration_models.dart';
import 'calibration_profile.dart';
import 'threshold_tuning_service.dart';

class CalibrationBenchmarkService {
  final SignalFlowDatabase _database;
  final ReplayBenchmarkRunner _runner;
  final ThresholdTuningService _tuning;
  final DateTime Function() _now;

  CalibrationBenchmarkService({
    SignalFlowDatabase? database,
    ReplayBenchmarkRunner? runner,
    ThresholdTuningService tuning = const ThresholdTuningService(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _runner = runner ?? ReplayBenchmarkRunner(database: database),
       _tuning = tuning,
       _now = now ?? DateTime.now;

  Future<CalibrationBenchmarkResult> runCalibrationBenchmark({
    required CalibrationProfile profile,
    required String sessionId,
    bool persist = false,
  }) async {
    final applied = _tuning.applyProfile(profile);
    final benchmark = await _runner.runBenchmark(
      sessionId: sessionId,
      replayScenario: 'calibration-${applied.id}',
      expectedForecasts: const [25, 42, 58, 48],
      replayForecasts: _forecastSeries(applied),
      expectedRecovery: const [84, 78, 72],
      replayRecovery: _recoverySeries(applied),
      confidenceScores: _confidenceSeries(applied),
      multimodalAgreementScores: _fusionSeries(applied),
      falseEscalations: _falseEscalations(applied),
      totalReplays: 5,
    );
    final createdAt = _now();
    final result = CalibrationBenchmarkResult(
      id: 'calibration-${applied.id}-${createdAt.microsecondsSinceEpoch}',
      createdAt: createdAt,
      profile: applied,
      sessionId: sessionId,
      forecastConsistency: benchmark.forecastConsistency,
      recoveryConsistency: benchmark.recoveryConsistency,
      falseEscalationRate: benchmark.falseEscalationRate,
      multimodalAgreement: benchmark.multimodalAgreement,
      confidenceConsistency: benchmark.confidenceConsistency,
      benchmarkScore: _scoreFor(applied, benchmark.benchmarkScore),
      rankingPosition: 0,
    );
    if (persist) {
      await persistProfile(applied);
      await persistResult(result);
    }
    return result;
  }

  Future<List<CalibrationBenchmarkResult>> compareProfiles({
    required List<CalibrationProfile> profiles,
    required String sessionId,
    bool persist = false,
  }) async {
    final results = <CalibrationBenchmarkResult>[];
    for (final profile in profiles) {
      results.add(
        await runCalibrationBenchmark(
          profile: profile,
          sessionId: sessionId,
          persist: persist,
        ),
      );
    }
    final ranked = [...results]
      ..sort((a, b) => b.benchmarkScore.compareTo(a.benchmarkScore));
    return [
      for (var index = 0; index < ranked.length; index += 1)
        CalibrationBenchmarkResult(
          id: ranked[index].id,
          createdAt: ranked[index].createdAt,
          profile: ranked[index].profile,
          sessionId: ranked[index].sessionId,
          forecastConsistency: ranked[index].forecastConsistency,
          recoveryConsistency: ranked[index].recoveryConsistency,
          falseEscalationRate: ranked[index].falseEscalationRate,
          multimodalAgreement: ranked[index].multimodalAgreement,
          confidenceConsistency: ranked[index].confidenceConsistency,
          benchmarkScore: ranked[index].benchmarkScore,
          rankingPosition: index + 1,
        ),
    ];
  }

  Future<CalibrationProfile> selectBestProfile({
    required List<CalibrationProfile> profiles,
    required String sessionId,
  }) async {
    final ranked = await compareProfiles(
      profiles: profiles,
      sessionId: sessionId,
    );
    return ranked.first.profile;
  }

  Future<void> persistProfile(CalibrationProfile profile) async {
    await _database
        .into(_database.calibrationProfilesTable)
        .insertOnConflictUpdate(
          CalibrationProfilesTableCompanion.insert(
            id: profile.id,
            name: profile.name,
            description: profile.description,
            createdAt: profile.createdAt,
            heartRateSensitivity: profile.heartRateSensitivity,
            hrvSuppressionSensitivity: profile.hrvSuppressionSensitivity,
            recoverySensitivity: profile.recoverySensitivity,
            forecastSensitivity: profile.forecastSensitivity,
            confidenceWeight: profile.confidenceWeight,
            fusionWeight: profile.fusionWeight,
            escalationThreshold: profile.escalationThreshold,
            recoveryThreshold: profile.recoveryThreshold,
            safetyCopy: profile.safetyCopy,
          ),
        );
  }

  Future<void> persistResult(CalibrationBenchmarkResult result) async {
    await _database
        .into(_database.calibrationBenchmarkResultsTable)
        .insertOnConflictUpdate(
          CalibrationBenchmarkResultsTableCompanion.insert(
            id: result.id,
            createdAt: result.createdAt,
            profileId: result.profile.id,
            profileName: result.profile.name,
            sessionId: result.sessionId,
            forecastConsistency: result.forecastConsistency,
            recoveryConsistency: result.recoveryConsistency,
            falseEscalationRate: result.falseEscalationRate,
            multimodalAgreement: result.multimodalAgreement,
            confidenceConsistency: result.confidenceConsistency,
            benchmarkScore: result.benchmarkScore,
            rankingPosition: result.rankingPosition,
            safetyCopy: result.safetyCopy,
          ),
        );
  }

  Future<List<CalibrationBenchmarkResult>> loadResults({int limit = 20}) async {
    final query = _database.select(_database.calibrationBenchmarkResultsTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  List<double> _forecastSeries(CalibrationProfile profile) {
    final sensitivityDelta = (profile.forecastSensitivity - 0.9) * 10;
    final thresholdDelta = (65 - profile.escalationThreshold) * 0.2;
    return [
      25 + sensitivityDelta,
      42 + sensitivityDelta + thresholdDelta,
      58 + sensitivityDelta + thresholdDelta,
      48 + thresholdDelta,
    ];
  }

  List<double> _recoverySeries(CalibrationProfile profile) {
    final recoveryDelta = (profile.recoverySensitivity - 0.9) * 8;
    return [84 + recoveryDelta, 78 + recoveryDelta, 72 + recoveryDelta];
  }

  List<double> _confidenceSeries(CalibrationProfile profile) {
    final confidenceBase = 78 + (profile.confidenceWeight * 12);
    return [confidenceBase, confidenceBase + 1, confidenceBase - 1];
  }

  List<double> _fusionSeries(CalibrationProfile profile) {
    final fusionBase = 76 + (profile.fusionWeight * 14);
    return [fusionBase, fusionBase + 2, fusionBase + 1];
  }

  int _falseEscalations(CalibrationProfile profile) {
    if (profile.escalationThreshold < 58) return 2;
    if (profile.escalationThreshold < 66) return 1;
    return 0;
  }

  double _scoreFor(CalibrationProfile profile, double benchmarkScore) {
    final thresholdPenalty = (65 - profile.escalationThreshold).abs() * 0.15;
    final weightBalancePenalty =
        (profile.confidenceWeight - profile.fusionWeight).abs() * 4;
    return (benchmarkScore - thresholdPenalty - weightBalancePenalty)
        .clamp(0, 100)
        .toDouble();
  }

  CalibrationBenchmarkResult _fromRow(
    CalibrationBenchmarkResultsTableData row,
  ) {
    final profile = CalibrationProfile(
      id: row.profileId,
      name: row.profileName,
      description: 'perfil carregado de validação offline.',
      createdAt: row.createdAt,
      heartRateSensitivity: 1,
      hrvSuppressionSensitivity: 1,
      recoverySensitivity: 1,
      forecastSensitivity: 1,
      confidenceWeight: 0.5,
      fusionWeight: 0.5,
      escalationThreshold: 65,
      recoveryThreshold: 58,
    );
    return CalibrationBenchmarkResult(
      id: row.id,
      createdAt: row.createdAt,
      profile: profile,
      sessionId: row.sessionId,
      forecastConsistency: row.forecastConsistency,
      recoveryConsistency: row.recoveryConsistency,
      falseEscalationRate: row.falseEscalationRate,
      multimodalAgreement: row.multimodalAgreement,
      confidenceConsistency: row.confidenceConsistency,
      benchmarkScore: row.benchmarkScore,
      rankingPosition: row.rankingPosition,
    );
  }
}
