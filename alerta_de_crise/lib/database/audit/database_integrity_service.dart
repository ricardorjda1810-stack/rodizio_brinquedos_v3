import 'dart:convert';

import '../signalflow_database.dart';
import 'database_health_report.dart';

class DatabaseIntegrityService {
  final SignalFlowDatabase _database;
  final DateTime Function() _now;

  DatabaseIntegrityService({
    SignalFlowDatabase? database,
    DateTime Function()? now,
  }) : _database = database ?? SignalFlowDatabase.instance,
       _now = now ?? DateTime.now;

  Future<DatabaseHealthReport> runIntegrityAudit() async {
    final issues = <String>[];
    final warnings = <String>[];
    final tablesChecked = <String>[
      'baseline_profiles_table',
      'crisis_risk_events_table',
      'intervention_history_table',
      'research_consent_table',
      'adaptive_baseline_state_table',
      'circadian_profiles_table',
      'session_timeline_table',
      'physiological_event_markers_table',
    ];

    final baselines = await _database
        .select(_database.baselineProfilesTable)
        .get();
    final crisisEvents = await _database
        .select(_database.crisisRiskEventsTable)
        .get();
    final interventions = await _database
        .select(_database.interventionHistoryTable)
        .get();
    final consents = await _database
        .select(_database.researchConsentTable)
        .get();
    final adaptiveBaselines = await _database
        .select(_database.adaptiveBaselineStateTable)
        .get();
    final circadianProfiles = await _database
        .select(_database.circadianProfilesTable)
        .get();
    final timelines = await _database
        .select(_database.sessionTimelineTable)
        .get();
    final markers = await _database
        .select(_database.physiologicalEventMarkersTable)
        .get();

    _auditBaselines(baselines, issues, warnings);
    _auditCrisisEvents(crisisEvents, issues, warnings);
    _auditInterventions(interventions, issues, warnings);
    _auditConsents(consents, issues, warnings);
    _auditAdaptiveBaselines(adaptiveBaselines, issues, warnings);
    _auditCircadianProfiles(circadianProfiles, issues, warnings);
    _auditSessionTimelines(timelines, issues, warnings);
    _auditEventMarkers(markers, issues, warnings);

    final totalRecords =
        baselines.length +
        crisisEvents.length +
        interventions.length +
        consents.length +
        adaptiveBaselines.length +
        circadianProfiles.length +
        timelines.length +
        markers.length;
    final healthScore = _healthScore(issues: issues, warnings: warnings);

    return DatabaseHealthReport(
      generatedAt: _now(),
      schemaVersion: _database.schemaVersion,
      tablesChecked: tablesChecked,
      totalRecords: totalRecords,
      hasIntegrityIssues: issues.isNotEmpty,
      issues: List.unmodifiable(issues),
      warnings: List.unmodifiable(warnings),
      healthScore: healthScore,
    );
  }

  void _auditBaselines(
    List<BaselineProfilesTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    for (final row in rows) {
      if (row.id.trim().isEmpty) {
        issues.add('Baseline profile with empty id.');
      }
      if (row.restingHeartRate <= 0 || row.hrvRmssd <= 0) {
        issues.add(
          'Baseline profile ${row.id} has invalid physiological values.',
        );
      }
      if (row.movementIntensity < 0 || row.movementIntensity > 1) {
        issues.add('Baseline profile ${row.id} has movement outside 0..1.');
      }
      if (row.createdAt.isAfter(_now().add(const Duration(minutes: 5)))) {
        warnings.add('Baseline profile ${row.id} has a future timestamp.');
      }
    }
  }

  void _auditCrisisEvents(
    List<CrisisRiskEventsTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    for (final row in rows) {
      if (row.id.trim().isEmpty) {
        issues.add('Crisis event with empty id.');
      }
      if (row.score < 0 || row.score > 100) {
        issues.add('Crisis event ${row.id} has score outside 0..100.');
      }
      if (!_isValidJsonList(row.reasonCodesJson)) {
        issues.add('Crisis event ${row.id} has invalid reasonCodesJson.');
      }
      if (row.level.trim().isEmpty) {
        issues.add('Crisis event ${row.id} has empty level.');
      }
      if (row.recommendedAction.trim().isEmpty) {
        warnings.add('Crisis event ${row.id} has empty recommendedAction.');
      }
      if (row.source.trim().isEmpty) {
        warnings.add('Crisis event ${row.id} has empty source.');
      }
    }
  }

  void _auditInterventions(
    List<InterventionHistoryTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    for (final row in rows) {
      if (row.id.trim().isEmpty) {
        issues.add('Intervention entry with empty id.');
      }
      if (row.protocolId.trim().isEmpty) {
        issues.add('Intervention ${row.id} has empty protocolId.');
      }
      if (row.completedAt.isBefore(row.startedAt)) {
        issues.add('Intervention ${row.id} has completedAt before startedAt.');
      }
      if (row.durationSeconds < 0) {
        issues.add('Intervention ${row.id} has negative duration.');
      }
      if (!_isScoreOrNull(row.preScore) || !_isScoreOrNull(row.postScore)) {
        warnings.add('Intervention ${row.id} has score outside 0..100.');
      }
      if (row.preScore != null &&
          row.postScore != null &&
          row.scoreDelta != row.postScore! - row.preScore!) {
        warnings.add('Intervention ${row.id} has inconsistent scoreDelta.');
      }
    }
  }

  void _auditConsents(
    List<ResearchConsentTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    for (final row in rows) {
      if (row.id.trim().isEmpty) {
        issues.add('Research consent with empty id.');
      }
      if (row.version.trim().isEmpty) {
        issues.add('Research consent ${row.id} has empty version.');
      }
      if (row.accepted && row.acceptedAt == null) {
        warnings.add(
          'Research consent ${row.id} is accepted without acceptedAt.',
        );
      }
    }
  }

  void _auditAdaptiveBaselines(
    List<AdaptiveBaselineStateTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    for (final row in rows) {
      if (row.id.trim().isEmpty) {
        issues.add('Adaptive baseline with empty id.');
      }
      if (row.updatedAt.isBefore(row.createdAt)) {
        issues.add(
          'Adaptive baseline ${row.id} has updatedAt before createdAt.',
        );
      }
      if (row.totalSamples < 0) {
        issues.add('Adaptive baseline ${row.id} has negative sample count.');
      }
      if (row.restingHeartRate <= 0 || row.hrvRmssd <= 0) {
        issues.add('Adaptive baseline ${row.id} has invalid baseline values.');
      }
      if (row.movementIntensity < 0 || row.movementIntensity > 1) {
        warnings.add('Adaptive baseline ${row.id} has movement outside 0..1.');
      }
    }
  }

  void _auditCircadianProfiles(
    List<CircadianProfilesTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    for (final row in rows) {
      if (row.id.trim().isEmpty || row.baselineId.trim().isEmpty) {
        issues.add('Circadian profile with empty id or baselineId.');
      }
      if (row.windowLabel.trim().isEmpty) {
        issues.add('Circadian profile ${row.id} has empty window label.');
      }
      if (row.startHour < 0 ||
          row.startHour > 23 ||
          row.endHour < 0 ||
          row.endHour > 23) {
        issues.add('Circadian profile ${row.id} has invalid hour window.');
      }
      if (row.sampleCount < 0) {
        issues.add('Circadian profile ${row.id} has negative sample count.');
      }
      if (row.averageHeartRate <= 0) {
        issues.add('Circadian profile ${row.id} has invalid heart rate.');
      }
      if (row.averageHrv != null && row.averageHrv! <= 0) {
        warnings.add('Circadian profile ${row.id} has non-positive HRV.');
      }
    }
  }

  void _auditSessionTimelines(
    List<SessionTimelineTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    for (final row in rows) {
      if (row.id.trim().isEmpty) {
        issues.add('Session timeline with empty id.');
      }
      if (row.endedAt != null && row.endedAt!.isBefore(row.startedAt)) {
        issues.add('Session timeline ${row.id} has endedAt before startedAt.');
      }
      if (row.totalSamples < 0 || row.totalEvents < 0) {
        issues.add('Session timeline ${row.id} has negative counters.');
      }
      if (row.averageHeartRate != null && row.averageHeartRate! <= 0) {
        warnings.add('Session timeline ${row.id} has invalid average HR.');
      }
      if (row.minHrv != null && row.minHrv! <= 0) {
        warnings.add('Session timeline ${row.id} has non-positive min HRV.');
      }
    }
  }

  void _auditEventMarkers(
    List<PhysiologicalEventMarkersTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    const validTypes = {
      'elevatedHeartRate',
      'hrvDrop',
      'interventionStarted',
      'interventionCompleted',
      'movementArtifact',
      'lowConfidenceSignal',
      'manualMarker',
      'circadianTransition',
    };
    const validSeverities = {'low', 'medium', 'high'};

    for (final row in rows) {
      if (row.id.trim().isEmpty || row.timelineId.trim().isEmpty) {
        issues.add('Physiological marker with empty id or timelineId.');
      }
      if (!validTypes.contains(row.type)) {
        issues.add('Physiological marker ${row.id} has invalid type.');
      }
      if (!validSeverities.contains(row.severity)) {
        issues.add('Physiological marker ${row.id} has invalid severity.');
      }
      if (row.title.trim().isEmpty) {
        warnings.add('Physiological marker ${row.id} has empty title.');
      }
      if (row.source.trim().isEmpty) {
        warnings.add('Physiological marker ${row.id} has empty source.');
      }
    }
  }

  bool _isValidJsonList(String value) {
    try {
      return jsonDecode(value) is List;
    } catch (_) {
      return false;
    }
  }

  bool _isScoreOrNull(int? value) {
    return value == null || (value >= 0 && value <= 100);
  }

  int _healthScore({
    required List<String> issues,
    required List<String> warnings,
  }) {
    final score = 100 - (issues.length * 20) - (warnings.length * 5);
    return score.clamp(0, 100);
  }
}
