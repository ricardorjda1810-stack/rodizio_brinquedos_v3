enum ProtocolPhaseType {
  resting,
  cognitive,
  contextual,
  breathing,
  recovery,
  subjectiveFeedback,
  custom,
}

class ProtocolPhase {
  final String id;
  final String title;
  final String description;
  final Duration duration;
  final String instructions;
  final ProtocolPhaseType phaseType;

  const ProtocolPhase({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.instructions,
    required this.phaseType,
  });

  Map<String, Object> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationSeconds': duration.inSeconds,
      'instructions': instructions,
      'phaseType': phaseType.name,
    };
  }

  factory ProtocolPhase.fromJson(Map<String, Object?> json) {
    return ProtocolPhase(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      instructions: json['instructions'] as String? ?? '',
      phaseType: ProtocolPhaseType.values.byName(
        json['phaseType'] as String? ?? ProtocolPhaseType.custom.name,
      ),
    );
  }
}
