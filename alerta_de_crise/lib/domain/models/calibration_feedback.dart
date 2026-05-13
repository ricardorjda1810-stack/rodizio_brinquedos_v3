import 'feeling_level.dart';
import 'risk_state.dart';

final class CalibrationFeedback {
  const CalibrationFeedback({
    required this.id,
    required this.timestamp,
    required this.feelingLevel,
    required this.label,
    required this.heartRate,
    required this.hrv,
    required this.riskScore,
    required this.riskState,
  });

  final String id;
  final DateTime timestamp;
  final FeelingLevel feelingLevel;
  final String label;
  final int heartRate;
  final int hrv;
  final int riskScore;
  final RiskState riskState;

  factory CalibrationFeedback.fromJson(Map<String, Object?> json) {
    return CalibrationFeedback(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      feelingLevel: FeelingLevelText.fromKey(json['feelingLevel'] as String),
      label: json['label'] as String,
      heartRate: json['heartRate'] as int,
      hrv: json['hrv'] as int,
      riskScore: json['riskScore'] as int,
      riskState: RiskStateText.fromKey(json['riskState'] as String),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'feelingLevel': feelingLevel.key,
      'label': label,
      'heartRate': heartRate,
      'hrv': hrv,
      'riskScore': riskScore,
      'riskState': riskState.key,
    };
  }
}
