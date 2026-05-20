import 'package:drift/drift.dart';

import '../adaptive_baseline/adaptive_baseline_models.dart';
import '../core/crisis_detection/baseline_profile.dart';
import '../core/crisis_detection/physiological_sample.dart';
import '../database/signalflow_database.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../session_timeline/physiological_event_marker.dart';
import '../session_timeline/session_timeline_models.dart';
import '../session_timeline/session_timeline_service.dart';
import 'autonomic_recovery_models.dart';
import 'physiological_fatigue_model.dart';
import 'recovery_window.dart';
import 'resilience_score_service.dart';

class RecoveryAnalysisService {
  final SignalFlowDatabase? _database;
  final ResilienceScoreService _resilienceScoreService;
  final PhysiologicalFatigueModel _fatigueModel;
  final DateTime Function() _now;

  const RecoveryAnalysisService({
    SignalFlowDatabase? database,
    ResilienceScoreService resilienceScoreService =
        const ResilienceScoreService(),
    PhysiologicalFatigueModel fatigueModel = const PhysiologicalFatigueModel(),
    DateTime Function()? now,
  }) : _database = database,
       _resilienceScoreService = resilienceScoreService,
       _fatigueModel = fatigueModel,
       _now = now ?? DateTime.now;

  SignalFlowDatabase get _db => _database ?? SignalFlowDatabase.instance;

  Future<AutonomicRecoveryProfile> analyzeRecovery({
    required List<PhysiologicalSample> samples,
    required BaselineProfile baseline,
    List<PhysiologicalEventMarker> markers = const [],
    RecoveryWindow window = RecoveryWindow.shortRecovery,
    String timelineId = 'recovery-debug',
    SessionTimeline? timeline,
    SessionTimelineService? timelineService,
    PhysiologicalTrend? trend,
    AdaptiveBaselineProfile? adaptiveBaseline,
    double previousStressCarryover = 0,
  }) async {
    final generatedAt = _now();
    final cutoff = generatedAt.subtract(window.duration);
    final windowSamples =
        samples.where((sample) => !sample.timestamp.isBefore(cutoff)).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final effectiveBaseline = _baselineForRecovery(
      fallback: baseline,
      adaptiveBaseline: adaptiveBaseline,
    );
    final baselineReturnTime = calculateBaselineReturn(
      samples: windowSamples,
      baseline: effectiveBaseline,
    );
    final hrvRecoverySlope = calculateRecoverySlope(
      windowSamples.map((sample) => sample.hrvRmssdMs).whereType<double>(),
    );
    final heartRateNormalization = _heartRateNormalization(
      samples: windowSamples,
      baseline: effectiveBaseline,
    );
    final recoveryRate = _recoveryRate(
      baselineReturnTime: baselineReturnTime,
      heartRateNormalization: heartRateNormalization,
      hrvRecoverySlope: hrvRecoverySlope,
      window: window,
    );
    final activationDensity = _activationDensity(markers, trend);
    final incompleteRecovery = _fatigueModel.hasIncompleteRecovery(
      samples: windowSamples,
      baselineHeartRate: effectiveBaseline.restingHeartRateBpm,
      baselineHrv: effectiveBaseline.hrvRmssdMs,
    );
    final score = _resilienceScoreService.calculate(
      recoveryRate: recoveryRate,
      heartRateNormalization: heartRateNormalization,
      hrvRecoverySlope: hrvRecoverySlope,
      activationDensity: activationDensity,
      incompleteRecovery: incompleteRecovery,
      baselineReturnTime: baselineReturnTime,
      previousStressCarryover: previousStressCarryover,
    );
    final profile = AutonomicRecoveryProfile(
      recoveryRate: recoveryRate,
      hrvRecoverySlope: hrvRecoverySlope,
      heartRateNormalization: heartRateNormalization,
      baselineReturnTime: baselineReturnTime,
      resilienceScore: score.resilienceScore,
      fatigueScore: score.fatigueScore,
      stressCarryover: score.stressCarryover,
      generatedAt: generatedAt,
      resilienceLevel: score.level,
    );

    await persistProfile(
      timelineId: timeline?.id ?? timelineId,
      window: window,
      profile: profile,
    );
    await _recordRecoveryMarkers(
      profile: profile,
      timelineService: timelineService,
    );

    return profile;
  }

  Duration? calculateBaselineReturn({
    required List<PhysiologicalSample> samples,
    required BaselineProfile baseline,
  }) {
    if (samples.isEmpty) {
      return null;
    }
    final ordered = [...samples]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final peak = ordered.reduce(
      (a, b) => a.heartRateBpm >= b.heartRateBpm ? a : b,
    );
    for (final sample in ordered.where(
      (sample) => !sample.timestamp.isBefore(peak.timestamp),
    )) {
      final hrv = sample.hrvRmssdMs;
      final heartRateRecovered =
          sample.heartRateBpm <= baseline.restingHeartRateBpm + 5;
      final hrvRecovered = hrv == null || hrv >= baseline.hrvRmssdMs * 0.85;
      if (heartRateRecovered && hrvRecovered) {
        return sample.timestamp.difference(peak.timestamp);
      }
    }
    return null;
  }

  double calculateRecoverySlope(Iterable<double> values) {
    final series = values.toList();
    if (series.length < 2) {
      return 0;
    }
    final n = series.length;
    final meanX = (n - 1) / 2;
    final meanY = series.reduce((a, b) => a + b) / n;
    var numerator = 0.0;
    var denominator = 0.0;
    for (var i = 0; i < n; i += 1) {
      final dx = i - meanX;
      numerator += dx * (series[i] - meanY);
      denominator += dx * dx;
    }
    if (denominator == 0) {
      return 0;
    }
    return numerator / denominator;
  }

  Future<void> persistProfile({
    required String timelineId,
    required RecoveryWindow window,
    required AutonomicRecoveryProfile profile,
  }) async {
    await _db
        .into(_db.autonomicRecoveryProfilesTable)
        .insert(
          AutonomicRecoveryProfilesTableCompanion.insert(
            id:
                'recovery-$timelineId-${window.label}-'
                '${profile.generatedAt.microsecondsSinceEpoch}',
            timelineId: timelineId,
            generatedAt: profile.generatedAt,
            windowLabel: window.label,
            windowSeconds: window.duration.inSeconds,
            recoveryRate: profile.recoveryRate,
            hrvRecoverySlope: profile.hrvRecoverySlope,
            heartRateNormalization: profile.heartRateNormalization,
            baselineReturnSeconds: Value(profile.baselineReturnTime?.inSeconds),
            resilienceScore: profile.resilienceScore,
            fatigueScore: profile.fatigueScore,
            stressCarryover: profile.stressCarryover,
            resilienceLevel: profile.resilienceLevel.name,
          ),
        );
  }

  Future<List<AutonomicRecoveryProfile>> loadProfiles({
    required String timelineId,
  }) async {
    final rows = await (_db.select(
      _db.autonomicRecoveryProfilesTable,
    )..where((table) => table.timelineId.equals(timelineId))).get();
    return rows.map(_profileFromRow).toList(growable: false);
  }

  BaselineProfile _baselineForRecovery({
    required BaselineProfile fallback,
    required AdaptiveBaselineProfile? adaptiveBaseline,
  }) {
    return adaptiveBaseline?.globalBaseline ?? fallback;
  }

  double _heartRateNormalization({
    required List<PhysiologicalSample> samples,
    required BaselineProfile baseline,
  }) {
    if (samples.length < 2) {
      return 0;
    }
    final peak = samples
        .map((sample) => sample.heartRateBpm)
        .reduce((a, b) => a > b ? a : b);
    final latest = samples.last.heartRateBpm;
    final activationRange = peak - baseline.restingHeartRateBpm;
    if (activationRange <= 0) {
      return 1;
    }
    return ((peak - latest) / activationRange).clamp(0, 1);
  }

  double _recoveryRate({
    required Duration? baselineReturnTime,
    required double heartRateNormalization,
    required double hrvRecoverySlope,
    required RecoveryWindow window,
  }) {
    final baselineReturnFactor = baselineReturnTime == null
        ? 0.0
        : 1 -
              (baselineReturnTime.inSeconds / window.duration.inSeconds).clamp(
                0,
                1,
              );
    final hrvFactor = hrvRecoverySlope <= 0
        ? 0.0
        : (hrvRecoverySlope / 5).clamp(0, 1);
    return ((baselineReturnFactor * 0.45) +
            (heartRateNormalization * 0.40) +
            (hrvFactor * 0.15))
        .clamp(0, 1);
  }

  double _activationDensity(
    List<PhysiologicalEventMarker> markers,
    PhysiologicalTrend? trend,
  ) {
    if (trend != null) {
      return trend.activationDensity;
    }
    if (markers.isEmpty) {
      return 0;
    }
    final activationCount = markers
        .where(
          (marker) =>
              marker.type == EventType.elevatedHeartRate ||
              marker.type == EventType.hrvDrop ||
              marker.type == EventType.escalatingPhysiology ||
              marker.type == EventType.sustainedHeartRateElevation ||
              marker.type == EventType.prolongedHrvSuppression,
        )
        .length;
    return activationCount / markers.length;
  }

  Future<void> _recordRecoveryMarkers({
    required AutonomicRecoveryProfile profile,
    required SessionTimelineService? timelineService,
  }) async {
    if (timelineService == null || !timelineService.isActive) {
      return;
    }
    final markerSpecs =
        <({EventType type, String title, String description})>[];
    if (profile.baselineReturnTime == null) {
      markerSpecs.add((
        type: EventType.incompleteRecovery,
        title: 'Recuperação incompleta',
        description: 'Retorno ao padrão fisiológico não observado na janela.',
      ));
    }
    if (profile.recoveryRate < 0.30) {
      markerSpecs.add((
        type: EventType.prolongedActivation,
        title: 'Ativação prolongada',
        description: 'Recuperação fisiológica lenta na janela analisada.',
      ));
    }
    if (profile.fatigueScore >= 55) {
      markerSpecs.add((
        type: EventType.autonomicFatigue,
        title: 'Fadiga fisiológica experimental',
        description: 'Carryover e densidade de ativação elevados.',
      ));
    }
    if (profile.resilienceLevel == AutonomicResilienceLevel.fatigued ||
        profile.resilienceLevel == AutonomicResilienceLevel.overloaded) {
      markerSpecs.add((
        type: EventType.resilienceDegradation,
        title: 'Resiliência fisiológica reduzida',
        description: 'Score de resiliência abaixo do padrão esperado.',
      ));
    }

    for (final spec in markerSpecs) {
      await timelineService.addMarker(
        PhysiologicalEventMarker(
          id:
              'recovery-${profile.generatedAt.microsecondsSinceEpoch}-'
              '${spec.type.name}',
          timestamp: profile.generatedAt,
          type: spec.type,
          title: spec.title,
          description: spec.description,
          severity:
              profile.resilienceLevel == AutonomicResilienceLevel.overloaded
              ? Severity.high
              : Severity.medium,
          source: 'autonomic_recovery',
        ),
      );
    }
  }

  AutonomicRecoveryProfile _profileFromRow(
    AutonomicRecoveryProfilesTableData row,
  ) {
    return AutonomicRecoveryProfile(
      recoveryRate: row.recoveryRate,
      hrvRecoverySlope: row.hrvRecoverySlope,
      heartRateNormalization: row.heartRateNormalization,
      baselineReturnTime: row.baselineReturnSeconds == null
          ? null
          : Duration(seconds: row.baselineReturnSeconds!),
      resilienceScore: row.resilienceScore,
      fatigueScore: row.fatigueScore,
      stressCarryover: row.stressCarryover,
      generatedAt: row.generatedAt,
      resilienceLevel: AutonomicResilienceLevel.values.byName(
        row.resilienceLevel,
      ),
    );
  }
}
