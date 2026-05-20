class SessionSnapshot {
  final DateTime timestamp;
  final double heartRate;
  final double hrv;
  final double confidence;
  final String escalationLevel;
  final double forecastProbability;
  final String recoveryState;
  final double resilience;
  final String contextualState;
  final String multimodalConsensus;

  const SessionSnapshot({
    required this.timestamp,
    required this.heartRate,
    required this.hrv,
    required this.confidence,
    required this.escalationLevel,
    required this.forecastProbability,
    required this.recoveryState,
    required this.resilience,
    required this.contextualState,
    required this.multimodalConsensus,
  });

  Map<String, Object> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'heartRate': heartRate,
      'hrv': hrv,
      'confidence': confidence,
      'escalationLevel': escalationLevel,
      'forecastProbability': forecastProbability,
      'recoveryState': recoveryState,
      'resilience': resilience,
      'contextualState': contextualState,
      'multimodalConsensus': multimodalConsensus,
    };
  }
}
