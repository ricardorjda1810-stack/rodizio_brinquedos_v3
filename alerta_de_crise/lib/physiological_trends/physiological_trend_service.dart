import 'package:drift/drift.dart';

import '../adaptive_baseline/adaptive_baseline_models.dart';
import '../core/crisis_detection/physiological_sample.dart';
import '../database/signalflow_database.dart';
import '../session_timeline/physiological_event_marker.dart';
import '../session_timeline/session_timeline_models.dart';
import '../session_timeline/session_timeline_service.dart';
import 'escalation_detection_service.dart';
import 'physiological_drift_analysis.dart';
import 'physiological_trend_models.dart';
import 'trend_window.dart';

class PhysiologicalTrendService {
  final SignalFlowDatabase? _database;
  final EscalationDetectionService _escalationDetectionService;
  final DateTime Function() _now;

  const PhysiologicalTrendService({
    SignalFlowDatabase? database,
    EscalationDetectionService escalationDetectionService =
        const EscalationDetectionService(),
    DateTime Function()? now,
  }) : _database = database,
       _escalationDetectionService = escalationDetectionService,
       _now = now ?? DateTime.now;

  SignalFlowDatabase get _db => _database ?? SignalFlowDatabase.instance;

  Future<PhysiologicalTrend> analyzeTimeline({
    required SessionTimeline timeline,
    required List<PhysiologicalSample> samples,
    required List<PhysiologicalEventMarker> markers,
    TrendWindow window = TrendWindow.shortTerm,
    SessionTimelineService? timelineService,
    AdaptiveBaselineProfile? adaptiveBaseline,
  }) async {
    final trend = calculateTrend(
      samples: samples,
      markers: markers,
      window: window,
      adaptiveBaseline: adaptiveBaseline,
    );
    await persistTrend(timelineId: timeline.id, trend: trend);

    final detection = _escalationDetectionService.detectEscalation(
      trend: trend,
      timelineId: timeline.id,
    );
    if (timelineService != null && timelineService.isActive) {
      for (final marker in detection.markers) {
        await timelineService.addMarker(marker);
      }
    }

    return trend;
  }

  Future<PhysiologicalTrend> analyzeRecentSamples({
    required List<PhysiologicalSample> samples,
    List<PhysiologicalEventMarker> markers = const [],
    TrendWindow window = TrendWindow.shortTerm,
    String timelineId = 'recent-samples',
    AdaptiveBaselineProfile? adaptiveBaseline,
  }) async {
    final trend = calculateTrend(
      samples: samples,
      markers: markers,
      window: window,
      adaptiveBaseline: adaptiveBaseline,
    );
    await persistTrend(timelineId: timelineId, trend: trend);
    return trend;
  }

  PhysiologicalTrend calculateTrend({
    required List<PhysiologicalSample> samples,
    List<PhysiologicalEventMarker> markers = const [],
    TrendWindow window = TrendWindow.shortTerm,
    AdaptiveBaselineProfile? adaptiveBaseline,
  }) {
    final generatedAt = _now();
    final cutoff = generatedAt.subtract(window.duration);
    final windowSamples =
        samples.where((sample) => !sample.timestamp.isBefore(cutoff)).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final windowMarkers = markers
        .where((marker) => !marker.timestamp.isBefore(cutoff))
        .toList();
    final activationDensity = _activationDensity(windowMarkers);
    final drift = PhysiologicalDriftAnalysis.fromSamples(
      samples: windowSamples,
      activationDensity: activationDensity,
    );
    final score = _escalationScore(
      drift: drift,
      activationDensity: activationDensity,
      samples: windowSamples,
      adaptiveBaseline: adaptiveBaseline,
    );

    return PhysiologicalTrend(
      averageHeartRate: _average(
        windowSamples.map((sample) => sample.heartRateBpm).toList(),
      ),
      averageHrv: _average(
        windowSamples
            .map((sample) => sample.hrvRmssdMs)
            .whereType<double>()
            .toList(),
      ),
      hrvSlope: drift.hrvSlope,
      heartRateSlope: drift.heartRateSlope,
      activationDensity: activationDensity,
      escalationScore: score,
      generatedAt: generatedAt,
      window: window,
    );
  }

  Future<void> persistTrend({
    required String timelineId,
    required PhysiologicalTrend trend,
  }) async {
    await _db
        .into(_db.physiologicalTrendsTable)
        .insert(
          PhysiologicalTrendsTableCompanion.insert(
            id:
                'trend-$timelineId-${trend.window.label}-'
                '${trend.generatedAt.microsecondsSinceEpoch}',
            timelineId: timelineId,
            generatedAt: trend.generatedAt,
            windowLabel: trend.window.label,
            windowSeconds: trend.window.duration.inSeconds,
            averageHeartRate: Value(trend.averageHeartRate),
            averageHrv: Value(trend.averageHrv),
            hrvSlope: trend.hrvSlope,
            heartRateSlope: trend.heartRateSlope,
            activationDensity: trend.activationDensity,
            escalationScore: trend.escalationScore,
          ),
        );
  }

  Future<List<PhysiologicalTrend>> loadTrends({
    required String timelineId,
  }) async {
    final rows = await (_db.select(
      _db.physiologicalTrendsTable,
    )..where((table) => table.timelineId.equals(timelineId))).get();
    return rows.map(_trendFromRow).toList(growable: false);
  }

  double _activationDensity(List<PhysiologicalEventMarker> markers) {
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

  int _escalationScore({
    required PhysiologicalDriftAnalysis drift,
    required double activationDensity,
    required List<PhysiologicalSample> samples,
    required AdaptiveBaselineProfile? adaptiveBaseline,
  }) {
    var score = 0;
    if (drift.heartRateIncreasing) {
      score += 25;
    }
    if (drift.hrvDecreasing) {
      score += 25;
    }
    if (activationDensity >= 0.50) {
      score += 20;
    } else if (activationDensity >= 0.25) {
      score += 10;
    }
    if (_isAboveAdaptiveBaseline(samples, adaptiveBaseline)) {
      score += 15;
    }
    if (samples.length >= 5) {
      score += 5;
    }
    return score.clamp(0, 100);
  }

  bool _isAboveAdaptiveBaseline(
    List<PhysiologicalSample> samples,
    AdaptiveBaselineProfile? baseline,
  ) {
    if (baseline == null || samples.isEmpty) {
      return false;
    }
    final averageHeartRate = _average(
      samples.map((sample) => sample.heartRateBpm).toList(),
    );
    if (averageHeartRate == null) {
      return false;
    }
    return averageHeartRate >= baseline.globalBaseline.restingHeartRateBpm + 10;
  }

  PhysiologicalTrend _trendFromRow(PhysiologicalTrendsTableData row) {
    return PhysiologicalTrend(
      averageHeartRate: row.averageHeartRate,
      averageHrv: row.averageHrv,
      hrvSlope: row.hrvSlope,
      heartRateSlope: row.heartRateSlope,
      activationDensity: row.activationDensity,
      escalationScore: row.escalationScore,
      generatedAt: row.generatedAt,
      window: TrendWindow(
        duration: Duration(seconds: row.windowSeconds),
        label: row.windowLabel,
      ),
    );
  }

  double? _average(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a + b) / values.length;
  }
}
