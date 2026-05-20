import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/signalflow_database.dart';
import 'realtime_session_recorder.dart';
import 'session_export_builder.dart';
import 'session_recorder_models.dart';
import 'session_snapshot_models.dart';

class SessionRecordingService {
  final SignalFlowDatabase _database;
  final RealtimeSessionRecorder _recorder;
  final SessionExportBuilder _exportBuilder;

  SessionRecordingService({
    SignalFlowDatabase? database,
    RealtimeSessionRecorder? recorder,
    SessionExportBuilder exportBuilder = const SessionExportBuilder(),
  }) : _database = database ?? SignalFlowDatabase.instance,
       _recorder = recorder ?? RealtimeSessionRecorder(),
       _exportBuilder = exportBuilder;

  RecordingSessionState? get currentState => _recorder.currentState;

  Future<RecordingSessionState> createRecording({
    String? protocolId,
    bool persist = false,
  }) async {
    final state = _recorder.startRecording(protocolId: protocolId);
    if (persist) {
      await persistRecording(state);
    }
    return state;
  }

  RecordingSessionState recordSnapshot(
    SessionSnapshot snapshot, {
    int forecasts = 0,
    int insights = 0,
    int contextEvents = 0,
    int subjectiveEntries = 0,
  }) {
    return _recorder.recordSnapshot(
      snapshot,
      forecasts: forecasts,
      insights: insights,
      contextEvents: contextEvents,
      subjectiveEntries: subjectiveEntries,
    );
  }

  RecordingSessionState pauseRecording() => _recorder.pauseRecording();

  RecordingSessionState resumeRecording() => _recorder.resumeRecording();

  Future<RecordingSessionState> finalizeRecording({bool persist = true}) async {
    final state = _recorder.stopRecording();
    if (persist) {
      await persistRecording(state);
    }
    return state;
  }

  Map<String, Object?> buildReplayDataset(RecordingSessionState state) {
    return _exportBuilder.buildSessionExport(
      session: state.session,
      snapshots: state.snapshots,
      markers: state.markers,
    );
  }

  Future<void> persistRecording(RecordingSessionState state) async {
    await _database
        .into(_database.recordedExperimentalSessionsTable)
        .insertOnConflictUpdate(_sessionCompanion(state.session));
    for (var index = 0; index < state.snapshots.length; index += 1) {
      await _database
          .into(_database.sessionSnapshotsTable)
          .insertOnConflictUpdate(
            _snapshotCompanion(
              sessionId: state.session.id,
              snapshot: state.snapshots[index],
              index: index,
            ),
          );
    }
  }

  Future<List<RecordedExperimentalSession>> loadRecordings() async {
    final rows = await _database
        .select(_database.recordedExperimentalSessionsTable)
        .get();
    return rows.map(_sessionFromRow).toList(growable: false);
  }

  RecordedExperimentalSessionsTableCompanion _sessionCompanion(
    RecordedExperimentalSession session,
  ) {
    return RecordedExperimentalSessionsTableCompanion.insert(
      id: session.id,
      startedAt: session.startedAt,
      completedAt: Value(session.completedAt),
      protocolId: Value(session.protocolId),
      totalSamples: session.totalSamples,
      totalMarkers: session.totalMarkers,
      totalForecasts: session.totalForecasts,
      totalInsights: session.totalInsights,
      totalContextEvents: session.totalContextEvents,
      totalSubjectiveEntries: session.totalSubjectiveEntries,
      averageHeartRate: session.averageHeartRate,
      averageHrv: session.averageHrv,
      averageConfidence: session.averageConfidence,
      escalationEvents: session.escalationEvents,
      recoveryEvents: session.recoveryEvents,
      safetyCopy: session.safetyCopy,
    );
  }

  SessionSnapshotsTableCompanion _snapshotCompanion({
    required String sessionId,
    required SessionSnapshot snapshot,
    required int index,
  }) {
    return SessionSnapshotsTableCompanion.insert(
      id: '$sessionId-snapshot-$index',
      sessionId: sessionId,
      timestamp: snapshot.timestamp,
      heartRate: snapshot.heartRate,
      hrv: snapshot.hrv,
      confidence: snapshot.confidence,
      escalationLevel: snapshot.escalationLevel,
      forecastProbability: snapshot.forecastProbability,
      recoveryState: snapshot.recoveryState,
      resilience: snapshot.resilience,
      contextualState: snapshot.contextualState,
      multimodalConsensus: snapshot.multimodalConsensus,
      rawJson: jsonEncode(snapshot.toJson()),
      safetyCopy:
          'registro experimental de snapshot fisiológico; dataset reproduzível.',
    );
  }

  RecordedExperimentalSession _sessionFromRow(
    RecordedExperimentalSessionsTableData row,
  ) {
    return RecordedExperimentalSession(
      id: row.id,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      protocolId: row.protocolId,
      totalSamples: row.totalSamples,
      totalMarkers: row.totalMarkers,
      totalForecasts: row.totalForecasts,
      totalInsights: row.totalInsights,
      totalContextEvents: row.totalContextEvents,
      totalSubjectiveEntries: row.totalSubjectiveEntries,
      averageHeartRate: row.averageHeartRate,
      averageHrv: row.averageHrv,
      averageConfidence: row.averageConfidence,
      escalationEvents: row.escalationEvents,
      recoveryEvents: row.recoveryEvents,
    );
  }
}
