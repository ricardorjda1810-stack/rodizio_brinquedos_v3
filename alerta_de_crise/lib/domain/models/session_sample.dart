import 'risk_state.dart';

final class SessionSample {
  const SessionSample({
    required this.timestamp,
    required this.heartRate,
    required this.hrv,
    required this.riskScore,
    required this.riskState,
    required this.motionState,
    this.protocolStepLabel,
    this.sourceLabel,
    this.motionRmsMg,
  });

  final DateTime timestamp;
  final int heartRate;
  final int hrv;
  final int riskScore;
  final RiskState riskState;
  final String motionState;
  final String? protocolStepLabel;
  final String? sourceLabel;
  final double? motionRmsMg;

  factory SessionSample.fromJson(Map<String, Object?> json) {
    return SessionSample(
      timestamp: DateTime.parse(json['timestamp'] as String),
      heartRate: json['heartRate'] as int,
      hrv: json['hrv'] as int,
      riskScore: json['riskScore'] as int,
      riskState: RiskStateText.fromKey(json['riskState'] as String),
      motionState: json['motionState'] as String,
      protocolStepLabel: json['protocolStepLabel'] as String?,
      sourceLabel: json['sourceLabel'] as String?,
      motionRmsMg: _doubleOrNull(json['motionRmsMg']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'heartRate': heartRate,
      'hrv': hrv,
      'riskScore': riskScore,
      'riskState': riskState.key,
      'motionState': motionState,
      'protocolStepLabel': protocolStepLabel,
      'sourceLabel': sourceLabel,
      'motionRmsMg': motionRmsMg,
    };
  }

  static double? _doubleOrNull(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return null;
  }
}
