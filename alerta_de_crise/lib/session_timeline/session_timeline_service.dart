import 'package:drift/drift.dart';

import '../core/crisis_detection/physiological_sample.dart';
import '../database/signalflow_database.dart';
import 'physiological_event_marker.dart';
import 'session_timeline_models.dart';
import 'session_timeline_statistics.dart';

class SessionTimelineService {
  final SignalFlowDatabase? _database;
  final DateTime Function() _now;
  final List<PhysiologicalSample> _samples = [];
  final List<PhysiologicalEventMarker> _markers = [];

  SessionTimeline? _currentTimeline;

  SessionTimelineService({
    SignalFlowDatabase? database,
    DateTime Function()? now,
  }) : _database = database,
       _now = now ?? DateTime.now;

  SignalFlowDatabase get _db => _database ?? SignalFlowDatabase.instance;

  SessionTimeline? get currentTimeline => _currentTimeline;
  List<PhysiologicalSample> get samples => List.unmodifiable(_samples);
  List<PhysiologicalEventMarker> get markers => List.unmodifiable(_markers);
  bool get isActive => _currentTimeline?.isActive ?? false;

  Future<SessionTimeline> startTimeline({String? id}) async {
    final startedAt = _now();
    _samples.clear();
    _markers.clear();
    _currentTimeline = SessionTimeline(
      id: id ?? 'timeline-${startedAt.microsecondsSinceEpoch}',
      startedAt: startedAt,
      endedAt: null,
      totalSamples: 0,
      totalEvents: 0,
      averageHeartRate: null,
      averageHrv: null,
      maxHeartRate: null,
      minHrv: null,
    );
    await _persistTimeline(_currentTimeline!);
    return _currentTimeline!;
  }

  Future<SessionTimeline?> addSample(PhysiologicalSample sample) async {
    if (_currentTimeline == null) {
      return null;
    }
    _samples.add(sample);
    _currentTimeline = _buildTimeline(endedAt: _currentTimeline!.endedAt);
    await _persistTimeline(_currentTimeline!);
    return _currentTimeline;
  }

  Future<PhysiologicalEventMarker?> addMarker(
    PhysiologicalEventMarker marker,
  ) async {
    final timeline = _currentTimeline;
    if (timeline == null) {
      return null;
    }
    _markers.add(marker);
    _markers.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _currentTimeline = _buildTimeline(endedAt: timeline.endedAt);
    await _persistTimeline(_currentTimeline!);
    await _db
        .into(_db.physiologicalEventMarkersTable)
        .insertOnConflictUpdate(
          PhysiologicalEventMarkersTableCompanion.insert(
            id: marker.id,
            timelineId: timeline.id,
            timestamp: marker.timestamp,
            type: marker.type.name,
            title: marker.title,
            description: marker.description,
            severity: marker.severity.name,
            source: marker.source,
          ),
        );
    return marker;
  }

  Future<SessionTimeline?> completeTimeline() async {
    if (_currentTimeline == null) {
      return null;
    }
    _currentTimeline = _buildTimeline(endedAt: _now());
    await _persistTimeline(_currentTimeline!);
    return _currentTimeline;
  }

  SessionTimelineStatistics getTimelineStatistics() {
    final timeline = _currentTimeline;
    if (timeline == null) {
      return SessionTimelineStatistics.calculate(
        startedAt: _now(),
        endedAt: _now(),
        samples: const [],
        markers: const [],
      );
    }

    return SessionTimelineStatistics.calculate(
      startedAt: timeline.startedAt,
      endedAt: timeline.endedAt,
      samples: _samples,
      markers: _markers,
    );
  }

  Future<List<PhysiologicalEventMarker>> loadMarkers(String timelineId) async {
    final rows = await (_db.select(
      _db.physiologicalEventMarkersTable,
    )..where((table) => table.timelineId.equals(timelineId))).get();

    return rows.map(_markerFromRow).toList(growable: false);
  }

  SessionTimeline _buildTimeline({required DateTime? endedAt}) {
    final current = _currentTimeline!;
    return SessionTimeline(
      id: current.id,
      startedAt: current.startedAt,
      endedAt: endedAt,
      totalSamples: _samples.length,
      totalEvents: _markers.length,
      averageHeartRate: _average(
        _samples.map((sample) => sample.heartRateBpm).toList(),
      ),
      averageHrv: _average(
        _samples
            .map((sample) => sample.hrvRmssdMs)
            .whereType<double>()
            .toList(),
      ),
      maxHeartRate: _max(
        _samples.map((sample) => sample.heartRateBpm).toList(),
      ),
      minHrv: _min(
        _samples
            .map((sample) => sample.hrvRmssdMs)
            .whereType<double>()
            .toList(),
      ),
    );
  }

  Future<void> _persistTimeline(SessionTimeline timeline) async {
    await _db
        .into(_db.sessionTimelineTable)
        .insertOnConflictUpdate(
          SessionTimelineTableCompanion.insert(
            id: timeline.id,
            startedAt: timeline.startedAt,
            endedAt: Value(timeline.endedAt),
            totalSamples: timeline.totalSamples,
            totalEvents: timeline.totalEvents,
            averageHeartRate: Value(timeline.averageHeartRate),
            averageHrv: Value(timeline.averageHrv),
            maxHeartRate: Value(timeline.maxHeartRate),
            minHrv: Value(timeline.minHrv),
          ),
        );
  }

  PhysiologicalEventMarker _markerFromRow(
    PhysiologicalEventMarkersTableData row,
  ) {
    return PhysiologicalEventMarker(
      id: row.id,
      timestamp: row.timestamp,
      type: EventType.values.byName(row.type),
      title: row.title,
      description: row.description,
      severity: Severity.values.byName(row.severity),
      source: row.source,
    );
  }

  double? _average(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a + b) / values.length;
  }

  double? _max(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a > b ? a : b);
  }

  double? _min(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a < b ? a : b);
  }
}
