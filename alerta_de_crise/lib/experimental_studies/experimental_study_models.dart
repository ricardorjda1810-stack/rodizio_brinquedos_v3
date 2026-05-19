class ExperimentalStudy {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String protocolId;
  final int totalSessions;
  final int totalParticipants;
  final Duration targetDuration;
  final List<String> studyTags;
  final List<String> enabledSensors;
  final bool active;

  const ExperimentalStudy({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.protocolId,
    required this.totalSessions,
    required this.totalParticipants,
    required this.targetDuration,
    required this.studyTags,
    required this.enabledSensors,
    required this.active,
  });

  ExperimentalStudy copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? protocolId,
    int? totalSessions,
    int? totalParticipants,
    Duration? targetDuration,
    List<String>? studyTags,
    List<String>? enabledSensors,
    bool? active,
  }) {
    return ExperimentalStudy(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      protocolId: protocolId ?? this.protocolId,
      totalSessions: totalSessions ?? this.totalSessions,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      targetDuration: targetDuration ?? this.targetDuration,
      studyTags: studyTags ?? this.studyTags,
      enabledSensors: enabledSensors ?? this.enabledSensors,
      active: active ?? this.active,
    );
  }

  String get safetyCopy =>
      'estudo experimental; coleta fisiológica experimental; não representa estudo clínico.';
}

class ExperimentalStudySession {
  final String id;
  final String studyId;
  final String sessionId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool success;
  final bool replayGenerated;
  final bool benchmarkGenerated;
  final bool subjectiveFeedbackIncluded;
  final double multimodalConsensusScore;

  const ExperimentalStudySession({
    required this.id,
    required this.studyId,
    required this.sessionId,
    required this.startedAt,
    this.completedAt,
    required this.success,
    required this.replayGenerated,
    required this.benchmarkGenerated,
    required this.subjectiveFeedbackIncluded,
    required this.multimodalConsensusScore,
  });

  ExperimentalStudySession copyWith({
    String? id,
    String? studyId,
    String? sessionId,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? success,
    bool? replayGenerated,
    bool? benchmarkGenerated,
    bool? subjectiveFeedbackIncluded,
    double? multimodalConsensusScore,
  }) {
    return ExperimentalStudySession(
      id: id ?? this.id,
      studyId: studyId ?? this.studyId,
      sessionId: sessionId ?? this.sessionId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      success: success ?? this.success,
      replayGenerated: replayGenerated ?? this.replayGenerated,
      benchmarkGenerated: benchmarkGenerated ?? this.benchmarkGenerated,
      subjectiveFeedbackIncluded:
          subjectiveFeedbackIncluded ?? this.subjectiveFeedbackIncluded,
      multimodalConsensusScore:
          multimodalConsensusScore ?? this.multimodalConsensusScore,
    );
  }

  String get safetyCopy =>
      'sessão experimental vinculada a estudo experimental; não representa estudo clínico.';
}

class StudyMetrics {
  final double recoveryEfficiency;
  final double falseEscalationRate;
  final double multimodalAgreement;
  final double resilienceTrend;
  final double protocolCompletionRate;
  final double sensorReliability;
  final double benchmarkConsistency;

  const StudyMetrics({
    required this.recoveryEfficiency,
    required this.falseEscalationRate,
    required this.multimodalAgreement,
    required this.resilienceTrend,
    required this.protocolCompletionRate,
    required this.sensorReliability,
    required this.benchmarkConsistency,
  });
}

class StudySnapshot {
  final ExperimentalStudy study;
  final List<ExperimentalStudySession> sessions;
  final StudyMetrics metrics;
  final List<String> summary;

  const StudySnapshot({
    required this.study,
    required this.sessions,
    required this.metrics,
    required this.summary,
  });
}
