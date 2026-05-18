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
      'physiological_trends_table',
      'autonomic_recovery_profiles_table',
      'research_dashboard_snapshots_table',
      'escalation_forecasts_table',
      'contextual_events_table',
      'contextual_trigger_correlations_table',
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
    final trends = await _database
        .select(_database.physiologicalTrendsTable)
        .get();
    final recoveryProfiles = await _database
        .select(_database.autonomicRecoveryProfilesTable)
        .get();
    final dashboardSnapshots = await _database
        .select(_database.researchDashboardSnapshotsTable)
        .get();
    final forecasts = await _database
        .select(_database.escalationForecastsTable)
        .get();
    final contextualEvents = await _database
        .select(_database.contextualEventsTable)
        .get();
    final contextualCorrelations = await _database
        .select(_database.contextualTriggerCorrelationsTable)
        .get();

    _auditBaselines(baselines, issues, warnings);
    _auditCrisisEvents(crisisEvents, issues, warnings);
    _auditInterventions(interventions, issues, warnings);
    _auditConsents(consents, issues, warnings);
    _auditAdaptiveBaselines(adaptiveBaselines, issues, warnings);
    _auditCircadianProfiles(circadianProfiles, issues, warnings);
    _auditSessionTimelines(timelines, issues, warnings);
    _auditEventMarkers(markers, issues, warnings);
    _auditTrends(trends, issues, warnings);
    _auditRecoveryProfiles(recoveryProfiles, issues, warnings);
    _auditDashboardSnapshots(dashboardSnapshots, issues, warnings);
    _auditForecasts(forecasts, issues, warnings);
    _auditContextualEvents(contextualEvents, issues, warnings);
    _auditContextualCorrelations(contextualCorrelations, issues, warnings);

    final totalRecords =
        baselines.length +
        crisisEvents.length +
        interventions.length +
        consents.length +
        adaptiveBaselines.length +
        circadianProfiles.length +
        timelines.length +
        markers.length +
        trends.length +
        recoveryProfiles.length +
        dashboardSnapshots.length +
        forecasts.length +
        contextualEvents.length +
        contextualCorrelations.length;
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
      'escalatingPhysiology',
      'sustainedHeartRateElevation',
      'prolongedHrvSuppression',
      'incompleteRecovery',
      'prolongedActivation',
      'autonomicFatigue',
      'resilienceDegradation',
      'forecastElevatedRisk',
      'prolongedAutonomicLoad',
      'recoveryProtectiveEffect',
      'repeatedContextTrigger',
      'contextualEscalationPattern',
      'recoveryContextAssociation',
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

  void _auditTrends(
    List<PhysiologicalTrendsTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    for (final row in rows) {
      if (row.id.trim().isEmpty || row.timelineId.trim().isEmpty) {
        issues.add('Physiological trend with empty id or timelineId.');
      }
      if (row.windowLabel.trim().isEmpty || row.windowSeconds <= 0) {
        issues.add('Physiological trend ${row.id} has invalid window.');
      }
      if (row.escalationScore < 0 || row.escalationScore > 100) {
        issues.add(
          'Physiological trend ${row.id} has escalationScore outside 0..100.',
        );
      }
      if (row.activationDensity < 0 || row.activationDensity > 1) {
        issues.add(
          'Physiological trend ${row.id} has activationDensity outside 0..1.',
        );
      }
      if (row.averageHeartRate != null && row.averageHeartRate! <= 0) {
        warnings.add('Physiological trend ${row.id} has invalid average HR.');
      }
      if (row.averageHrv != null && row.averageHrv! <= 0) {
        warnings.add('Physiological trend ${row.id} has non-positive HRV.');
      }
    }
  }

  void _auditRecoveryProfiles(
    List<AutonomicRecoveryProfilesTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    const validLevels = {'resilient', 'stable', 'fatigued', 'overloaded'};
    for (final row in rows) {
      if (row.id.trim().isEmpty || row.timelineId.trim().isEmpty) {
        issues.add('Autonomic recovery profile with empty id or timelineId.');
      }
      if (row.windowLabel.trim().isEmpty || row.windowSeconds <= 0) {
        issues.add('Autonomic recovery profile ${row.id} has invalid window.');
      }
      if (row.recoveryRate < 0 || row.recoveryRate > 1) {
        issues.add(
          'Autonomic recovery profile ${row.id} has recoveryRate outside 0..1.',
        );
      }
      if (row.heartRateNormalization < 0 || row.heartRateNormalization > 1) {
        issues.add(
          'Autonomic recovery profile ${row.id} has HR normalization outside 0..1.',
        );
      }
      if (row.resilienceScore < 0 || row.resilienceScore > 100) {
        issues.add(
          'Autonomic recovery profile ${row.id} has resilienceScore outside 0..100.',
        );
      }
      if (row.fatigueScore < 0 || row.fatigueScore > 100) {
        issues.add(
          'Autonomic recovery profile ${row.id} has fatigueScore outside 0..100.',
        );
      }
      if (row.stressCarryover < 0 || row.stressCarryover > 1) {
        issues.add(
          'Autonomic recovery profile ${row.id} has stressCarryover outside 0..1.',
        );
      }
      if (!validLevels.contains(row.resilienceLevel)) {
        issues.add(
          'Autonomic recovery profile ${row.id} has invalid resilienceLevel.',
        );
      }
      if (row.baselineReturnSeconds != null && row.baselineReturnSeconds! < 0) {
        warnings.add(
          'Autonomic recovery profile ${row.id} has negative baseline return.',
        );
      }
    }
  }

  void _auditDashboardSnapshots(
    List<ResearchDashboardSnapshotsTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    for (final row in rows) {
      if (row.id.trim().isEmpty) {
        issues.add('Research dashboard snapshot with empty id.');
      }
      if (row.averageConfidence < 0 || row.averageConfidence > 100) {
        issues.add(
          'Research dashboard snapshot ${row.id} has confidence outside 0..100.',
        );
      }
      if (row.recoveryEfficiency < 0 || row.recoveryEfficiency > 100) {
        issues.add(
          'Research dashboard snapshot ${row.id} has recoveryEfficiency outside 0..100.',
        );
      }
      if (row.resilienceScore < 0 || row.resilienceScore > 100) {
        issues.add(
          'Research dashboard snapshot ${row.id} has resilienceScore outside 0..100.',
        );
      }
      if (row.fatigueScore < 0 || row.fatigueScore > 100) {
        issues.add(
          'Research dashboard snapshot ${row.id} has fatigueScore outside 0..100.',
        );
      }
      if (row.activationDensity < 0 || row.activationDensity > 1) {
        issues.add(
          'Research dashboard snapshot ${row.id} has activationDensity outside 0..1.',
        );
      }
      if (row.baselineStability < 0 || row.baselineStability > 100) {
        issues.add(
          'Research dashboard snapshot ${row.id} has baselineStability outside 0..100.',
        );
      }
      if (row.stressCarryover < 0 || row.stressCarryover > 1) {
        issues.add(
          'Research dashboard snapshot ${row.id} has stressCarryover outside 0..1.',
        );
      }
      if (row.autonomicLoad < 0 || row.autonomicLoad > 100) {
        issues.add(
          'Research dashboard snapshot ${row.id} has autonomicLoad outside 0..100.',
        );
      }
      if (row.averageHeartRate != null && row.averageHeartRate! <= 0) {
        warnings.add(
          'Research dashboard snapshot ${row.id} has invalid average HR.',
        );
      }
      if (row.averageHrv != null && row.averageHrv! <= 0) {
        warnings.add(
          'Research dashboard snapshot ${row.id} has non-positive HRV.',
        );
      }
    }
  }

  void _auditForecasts(
    List<EscalationForecastsTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    const validRiskLevels = {'low', 'moderate', 'elevated', 'high'};
    const validConfidenceLevels = {
      'lowConfidence',
      'mediumConfidence',
      'highConfidence',
    };

    for (final row in rows) {
      if (row.id.trim().isEmpty) {
        issues.add('Escalation forecast with empty id.');
      }
      if (row.forecastWindowSeconds <= 0 ||
          row.forecastWindowLabel.trim().isEmpty) {
        issues.add('Escalation forecast ${row.id} has invalid window.');
      }
      if (row.escalationProbability < 0 || row.escalationProbability > 100) {
        issues.add(
          'Escalation forecast ${row.id} has probability outside 0..100.',
        );
      }
      if (row.forecastConfidence < 0 || row.forecastConfidence > 100) {
        issues.add(
          'Escalation forecast ${row.id} has confidence outside 0..100.',
        );
      }
      if (!validConfidenceLevels.contains(row.forecastConfidenceLevel)) {
        issues.add(
          'Escalation forecast ${row.id} has invalid confidence level.',
        );
      }
      if (!validRiskLevels.contains(row.escalationRiskLevel)) {
        issues.add('Escalation forecast ${row.id} has invalid risk level.');
      }
      if (!_isValidJsonList(row.contributingFactorsJson)) {
        issues.add(
          'Escalation forecast ${row.id} has invalid contributing factors.',
        );
      }
      if (row.recoveryProtection < 0 || row.recoveryProtection > 100) {
        issues.add(
          'Escalation forecast ${row.id} has recoveryProtection outside 0..100.',
        );
      }
      if (row.autonomicLoad < 0 || row.autonomicLoad > 100) {
        issues.add(
          'Escalation forecast ${row.id} has autonomicLoad outside 0..100.',
        );
      }
      if (!row.safetyCopy.contains('não é diagnóstico')) {
        warnings.add(
          'Escalation forecast ${row.id} is missing explicit safety copy.',
        );
      }
    }
  }

  void _auditContextualEvents(
    List<ContextualEventsTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    const validCategories = {
      'work',
      'social',
      'sleep',
      'exercise',
      'caffeine',
      'conflict',
      'noise',
      'environment',
      'manual',
      'unknown',
    };
    const validIntensities = {'low', 'medium', 'high'};

    for (final row in rows) {
      if (row.id.trim().isEmpty) {
        issues.add('Contextual event with empty id.');
      }
      if (!validCategories.contains(row.category)) {
        issues.add('Contextual event ${row.id} has invalid category.');
      }
      if (!validIntensities.contains(row.intensity)) {
        issues.add('Contextual event ${row.id} has invalid intensity.');
      }
      if (row.label.trim().isEmpty) {
        warnings.add('Contextual event ${row.id} has empty label.');
      }
      if (row.source.trim().isEmpty) {
        warnings.add('Contextual event ${row.id} has empty source.');
      }
    }
  }

  void _auditContextualCorrelations(
    List<ContextualTriggerCorrelationsTableData> rows,
    List<String> issues,
    List<String> warnings,
  ) {
    const validCategories = {
      'work',
      'social',
      'sleep',
      'exercise',
      'caffeine',
      'conflict',
      'noise',
      'environment',
      'manual',
      'unknown',
    };

    for (final row in rows) {
      if (row.id.trim().isEmpty) {
        issues.add('Contextual correlation with empty id.');
      }
      if (!validCategories.contains(row.category)) {
        issues.add('Contextual correlation ${row.id} has invalid category.');
      }
      if (row.occurrenceCount < 0) {
        issues.add(
          'Contextual correlation ${row.id} has negative occurrence count.',
        );
      }
      if (row.escalationCorrelation < 0 || row.escalationCorrelation > 100) {
        issues.add(
          'Contextual correlation ${row.id} has escalationCorrelation outside 0..100.',
        );
      }
      if (row.recoveryImpact < 0 || row.recoveryImpact > 100) {
        issues.add(
          'Contextual correlation ${row.id} has recoveryImpact outside 0..100.',
        );
      }
      if (row.confidence < 0 || row.confidence > 100) {
        issues.add(
          'Contextual correlation ${row.id} has confidence outside 0..100.',
        );
      }
      if (!_isValidJsonList(row.associatedMarkersJson)) {
        issues.add(
          'Contextual correlation ${row.id} has invalid associated markers.',
        );
      }
      if (!row.safetyCopy.contains('correlação não implica causalidade')) {
        warnings.add(
          'Contextual correlation ${row.id} is missing explicit safety copy.',
        );
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
