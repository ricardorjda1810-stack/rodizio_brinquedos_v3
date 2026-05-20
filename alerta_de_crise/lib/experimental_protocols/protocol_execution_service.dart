import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/signalflow_database.dart';
import 'experimental_protocol_models.dart';
import 'protocol_phase.dart';
import 'protocol_session_builder.dart';

class ProtocolExecutionService {
  final SignalFlowDatabase _database;
  final ProtocolSessionBuilder _builder;
  final DateTime Function() _now;
  ProtocolExecutionSession? _activeSession;

  ProtocolExecutionService({
    SignalFlowDatabase? database,
    ProtocolSessionBuilder builder = const ProtocolSessionBuilder(),
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _builder = builder,
       _now = now ?? DateTime.now;

  ProtocolExecutionSession? get activeSession => _activeSession;

  Future<ProtocolExecutionSession> startProtocol(
    ExperimentalProtocol protocol, {
    bool persist = false,
  }) async {
    final session = _builder.buildSession(
      protocol: protocol,
      startedAt: _now(),
    );
    _activeSession = session;
    if (persist) {
      await persistProtocol(protocol);
      await persistSession(session);
    }
    return session;
  }

  ProtocolExecutionSession nextPhase() {
    final session = _requireSession();
    final currentPhase = session.currentPhase;
    final nextIndex = session.currentPhaseIndex + 1;
    final markers = [...session.generatedMarkers];
    if (currentPhase != null) {
      markers.addAll(_builder.buildPhaseMarkers(currentPhase, started: false));
    }
    if (nextIndex >= session.protocol.phases.length) {
      return completeProtocol();
    }
    markers.addAll(
      _builder.buildPhaseMarkers(
        session.protocol.phases[nextIndex],
        started: true,
      ),
    );
    final updated = session.copyWith(
      currentPhaseIndex: nextIndex,
      generatedMarkers: markers,
    );
    _activeSession = updated;
    return updated;
  }

  ProtocolExecutionSession completePhase() {
    final session = _requireSession();
    final phase = session.currentPhase;
    if (phase == null) return session;
    final updated = session.copyWith(
      generatedMarkers: [
        ...session.generatedMarkers,
        ..._builder.buildPhaseMarkers(phase, started: false),
      ],
    );
    _activeSession = updated;
    return updated;
  }

  ProtocolExecutionSession completeProtocol() {
    final session = _requireSession();
    final markers = [...session.generatedMarkers];
    if (!markers.contains('protocol_completed')) {
      markers.add('protocol_completed');
    }
    final updated = session.copyWith(
      completedAt: _now(),
      currentPhaseIndex: session.protocol.phases.length,
      generatedMarkers: markers,
      completed: true,
    );
    _activeSession = updated;
    return updated;
  }

  Duration remainingDuration(ProtocolExecutionSession session) {
    if (session.completed) return Duration.zero;
    return session.protocol.phases
        .skip(session.currentPhaseIndex)
        .fold(Duration.zero, (total, phase) => total + phase.duration);
  }

  Future<void> persistProtocol(ExperimentalProtocol protocol) async {
    await _database
        .into(_database.experimentalProtocolsTable)
        .insertOnConflictUpdate(_protocolCompanion(protocol));
  }

  Future<void> persistSession(ProtocolExecutionSession session) async {
    await _database
        .into(_database.experimentalProtocolSessionsTable)
        .insertOnConflictUpdate(_sessionCompanion(session));
  }

  Future<List<ExperimentalProtocol>> loadProtocols() async {
    final rows = await _database
        .select(_database.experimentalProtocolsTable)
        .get();
    return rows.map(_protocolFromRow).toList(growable: false);
  }

  Future<List<ProtocolExecutionSession>> loadSessions({
    required List<ExperimentalProtocol> protocols,
  }) async {
    final byId = {for (final protocol in protocols) protocol.id: protocol};
    final rows = await _database
        .select(_database.experimentalProtocolSessionsTable)
        .get();
    return rows
        .where((row) => byId.containsKey(row.protocolId))
        .map((row) => _sessionFromRow(row, byId[row.protocolId]!))
        .toList(growable: false);
  }

  ExperimentalProtocolsTableCompanion _protocolCompanion(
    ExperimentalProtocol protocol,
  ) {
    return ExperimentalProtocolsTableCompanion.insert(
      id: protocol.id,
      title: protocol.title,
      description: protocol.description,
      createdAt: protocol.createdAt,
      phasesJson: jsonEncode(
        protocol.phases.map((phase) => phase.toJson()).toList(),
      ),
      totalDurationSeconds: protocol.totalDuration.inSeconds,
      recommendedSensorsJson: jsonEncode(protocol.recommendedSensors),
      safetyCopy: protocol.safetyCopy,
    );
  }

  ExperimentalProtocolSessionsTableCompanion _sessionCompanion(
    ProtocolExecutionSession session,
  ) {
    return ExperimentalProtocolSessionsTableCompanion.insert(
      id: session.id,
      protocolId: session.protocol.id,
      startedAt: session.startedAt,
      completedAt: Value(session.completedAt),
      currentPhaseIndex: session.currentPhaseIndex,
      completed: session.completed,
      generatedMarkersJson: jsonEncode(session.generatedMarkers),
      benchmarkId: session.benchmarkId,
      replayMetadataJson: jsonEncode(_builder.buildReplayMetadata(session)),
      safetyCopy: session.safetyCopy,
    );
  }

  ExperimentalProtocol _protocolFromRow(ExperimentalProtocolsTableData row) {
    final phasesJson = jsonDecode(row.phasesJson) as List;
    return ExperimentalProtocol(
      id: row.id,
      title: row.title,
      description: row.description,
      createdAt: row.createdAt,
      phases: phasesJson
          .cast<Map<String, Object?>>()
          .map(ProtocolPhase.fromJson)
          .toList(growable: false),
      totalDuration: Duration(seconds: row.totalDurationSeconds),
      recommendedSensors: (jsonDecode(row.recommendedSensorsJson) as List)
          .cast<String>()
          .toList(growable: false),
    );
  }

  ProtocolExecutionSession _sessionFromRow(
    ExperimentalProtocolSessionsTableData row,
    ExperimentalProtocol protocol,
  ) {
    return ProtocolExecutionSession(
      id: row.id,
      protocol: protocol,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      currentPhaseIndex: row.currentPhaseIndex,
      generatedMarkers: (jsonDecode(row.generatedMarkersJson) as List)
          .cast<String>()
          .toList(growable: false),
      benchmarkId: row.benchmarkId,
      completed: row.completed,
    );
  }

  ProtocolExecutionSession _requireSession() {
    final session = _activeSession;
    if (session == null) {
      throw StateError('Nenhum protocolo experimental ativo.');
    }
    return session;
  }
}
