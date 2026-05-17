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

    _auditBaselines(baselines, issues, warnings);
    _auditCrisisEvents(crisisEvents, issues, warnings);
    _auditInterventions(interventions, issues, warnings);
    _auditConsents(consents, issues, warnings);

    final totalRecords =
        baselines.length +
        crisisEvents.length +
        interventions.length +
        consents.length;
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
