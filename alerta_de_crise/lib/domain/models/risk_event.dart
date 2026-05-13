import 'risk_state.dart';

final class RiskEvent {
  const RiskEvent({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.state,
    required this.maxScore,
    required this.beforeHeartRate,
    required this.beforeHrv,
    this.afterHeartRate,
    this.afterHrv,
    required this.title,
    required this.description,
    required this.feedback,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final RiskState state;
  final int maxScore;
  final int beforeHeartRate;
  final int beforeHrv;
  final int? afterHeartRate;
  final int? afterHrv;
  final String title;
  final String description;
  final String feedback;

  factory RiskEvent.fromJson(Map<String, Object?> json) {
    return RiskEvent(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: _dateTimeOrNull(json['endedAt']),
      state: RiskStateText.fromKey(json['state'] as String),
      maxScore: json['maxScore'] as int,
      beforeHeartRate: json['beforeHeartRate'] as int,
      beforeHrv: json['beforeHrv'] as int,
      afterHeartRate: json['afterHeartRate'] as int?,
      afterHrv: json['afterHrv'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      feedback: json['feedback'] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'state': state.key,
      'maxScore': maxScore,
      'beforeHeartRate': beforeHeartRate,
      'beforeHrv': beforeHrv,
      'afterHeartRate': afterHeartRate,
      'afterHrv': afterHrv,
      'title': title,
      'description': description,
      'feedback': feedback,
    };
  }

  RiskEvent copyWith({
    DateTime? endedAt,
    int? afterHeartRate,
    int? afterHrv,
    String? feedback,
  }) {
    return RiskEvent(
      id: id,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      state: state,
      maxScore: maxScore,
      beforeHeartRate: beforeHeartRate,
      beforeHrv: beforeHrv,
      afterHeartRate: afterHeartRate ?? this.afterHeartRate,
      afterHrv: afterHrv ?? this.afterHrv,
      title: title,
      description: description,
      feedback: feedback ?? this.feedback,
    );
  }

  static DateTime? _dateTimeOrNull(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.parse(value);
  }
}
