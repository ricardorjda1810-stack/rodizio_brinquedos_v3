import '../../domain/models/calibration_feedback.dart';
import '../../domain/models/collection_diagnostics.dart';
import '../../domain/models/feeling_level.dart';
import '../../domain/models/risk_event.dart';
import '../../domain/models/risk_state.dart';
import '../../domain/models/session_sample.dart';
import '../../domain/models/temporal_sample_analysis.dart';

final class CsvExporter {
  const CsvExporter();

  static const _header = [
    'id',
    'startedAt',
    'endedAt',
    'state',
    'maxScore',
    'beforeHeartRate',
    'beforeHrv',
    'afterHeartRate',
    'afterHrv',
    'title',
    'description',
    'feedback',
  ];

  String exportEvents(List<RiskEvent> events) {
    final rows = [_header, ...events.map(_eventToRow)];

    return rows.map(_rowToCsv).join('\n');
  }

  String exportSessionSamples(List<SessionSample> samples) {
    final rows = [
      [
        'timestamp',
        'heartRate',
        'hrv',
        'riskScore',
        'riskState',
        'motionState',
      ],
      ...samples.map(_sessionSampleToRow),
    ];

    return rows.map(_rowToCsv).join('\n');
  }

  String exportCollectionDiagnostics(CollectionDiagnostics diagnostics) {
    final rows = [
      [
        'totalSamples',
        'heartRateSamples',
        'hrvSamples',
        'missingHeartRateCount',
        'missingHrvCount',
        'duplicateSamplesSkipped',
        'firstSampleAt',
        'lastSampleAt',
        'averageIntervalSeconds',
        'minIntervalSeconds',
        'maxIntervalSeconds',
        'sourceLabel',
      ],
      [
        diagnostics.totalSamples.toString(),
        diagnostics.heartRateSamples.toString(),
        diagnostics.hrvSamples.toString(),
        diagnostics.missingHeartRateCount.toString(),
        diagnostics.missingHrvCount.toString(),
        diagnostics.duplicateSamplesSkipped.toString(),
        diagnostics.firstSampleAt?.toIso8601String() ?? '',
        diagnostics.lastSampleAt?.toIso8601String() ?? '',
        _formatSeconds(diagnostics.averageIntervalSeconds),
        _formatSeconds(diagnostics.minIntervalSeconds),
        _formatSeconds(diagnostics.maxIntervalSeconds),
        diagnostics.sourceLabel,
      ],
    ];

    return rows.map(_rowToCsv).join('\n');
  }

  String exportTemporalAnalysis(TemporalSampleAnalysis analysis) {
    final rows = [
      [
        'totalSamples',
        'firstSampleAt',
        'lastSampleAt',
        'durationSeconds',
        'averageIntervalSeconds',
        'medianIntervalSeconds',
        'minIntervalSeconds',
        'maxIntervalSeconds',
        'longGapCount',
        'longestGapSeconds',
        'samplesPerMinute',
        'qualityLabel',
      ],
      [
        analysis.totalSamples.toString(),
        analysis.firstSampleAt?.toIso8601String() ?? '',
        analysis.lastSampleAt?.toIso8601String() ?? '',
        _formatSeconds(analysis.durationSeconds),
        _formatSeconds(analysis.averageIntervalSeconds),
        _formatSeconds(analysis.medianIntervalSeconds),
        _formatSeconds(analysis.minIntervalSeconds),
        _formatSeconds(analysis.maxIntervalSeconds),
        analysis.longGapCount.toString(),
        _formatSeconds(analysis.longestGapSeconds),
        _formatSeconds(analysis.samplesPerMinute),
        analysis.qualityLabel,
      ],
    ];

    return rows.map(_rowToCsv).join('\n');
  }

  String exportCalibrationFeedbacks(List<CalibrationFeedback> feedbacks) {
    final rows = [
      [
        'id',
        'timestamp',
        'feelingLevel',
        'label',
        'heartRate',
        'hrv',
        'riskScore',
        'riskState',
      ],
      ...feedbacks.map(_calibrationFeedbackToRow),
    ];

    return rows.map(_rowToCsv).join('\n');
  }

  List<String> _calibrationFeedbackToRow(CalibrationFeedback feedback) {
    return [
      feedback.id,
      feedback.timestamp.toIso8601String(),
      feedback.feelingLevel.key,
      feedback.label,
      feedback.heartRate.toString(),
      feedback.hrv.toString(),
      feedback.riskScore.toString(),
      feedback.riskState.key,
    ];
  }

  List<String> _sessionSampleToRow(SessionSample sample) {
    return [
      sample.timestamp.toIso8601String(),
      sample.heartRate.toString(),
      sample.hrv.toString(),
      sample.riskScore.toString(),
      sample.riskState.key,
      sample.motionState,
    ];
  }

  List<String> _eventToRow(RiskEvent event) {
    return [
      event.id,
      event.startedAt.toIso8601String(),
      event.endedAt?.toIso8601String() ?? '',
      event.state.key,
      event.maxScore.toString(),
      event.beforeHeartRate.toString(),
      event.beforeHrv.toString(),
      event.afterHeartRate?.toString() ?? '',
      event.afterHrv?.toString() ?? '',
      event.title,
      event.description,
      event.feedback,
    ];
  }

  String _rowToCsv(List<String> row) {
    return row.map(_escapeCell).join(',');
  }

  String _escapeCell(String value) {
    final shouldEscape =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    if (!shouldEscape) {
      return value;
    }

    return '"${value.replaceAll('"', '""')}"';
  }

  String _formatSeconds(double value) {
    return value.toStringAsFixed(1);
  }
}
