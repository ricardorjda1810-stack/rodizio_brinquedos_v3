import 'session_sample.dart';

final class ResearchSession {
  const ResearchSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.notes,
    required this.samples,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? notes;
  final List<SessionSample> samples;

  bool get isActive => endedAt == null;

  factory ResearchSession.fromJson(Map<String, Object?> json) {
    final samplesJson = json['samples'];

    return ResearchSession(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: _dateTimeOrNull(json['endedAt']),
      notes: json['notes'] as String?,
      samples: samplesJson is List
          ? samplesJson
                .whereType<Map>()
                .map(
                  (sampleJson) => SessionSample.fromJson(
                    Map<String, Object?>.from(sampleJson),
                  ),
                )
                .toList()
          : const [],
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'notes': notes,
      'samples': samples.map((sample) => sample.toJson()).toList(),
    };
  }

  ResearchSession copyWith({
    DateTime? endedAt,
    String? notes,
    List<SessionSample>? samples,
  }) {
    return ResearchSession(
      id: id,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      notes: notes ?? this.notes,
      samples: samples ?? this.samples,
    );
  }

  static DateTime? _dateTimeOrNull(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.parse(value);
  }
}
