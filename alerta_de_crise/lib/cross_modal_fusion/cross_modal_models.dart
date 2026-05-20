enum MultimodalConfidenceLevel { low, medium, high }

class SignalWeights {
  final double rrQuality;
  final double hrv;
  final double recovery;
  final double trends;
  final double context;
  final double subjectiveFeedback;
  final double confidenceScore;

  const SignalWeights({
    required this.rrQuality,
    required this.hrv,
    required this.recovery,
    required this.trends,
    required this.context,
    required this.subjectiveFeedback,
    required this.confidenceScore,
  });

  Map<String, double> toMap() {
    return {
      'rrQuality': rrQuality,
      'hrv': hrv,
      'recovery': recovery,
      'trends': trends,
      'context': context,
      'subjectiveFeedback': subjectiveFeedback,
      'confidenceScore': confidenceScore,
    };
  }
}

class MultimodalConfidenceResult {
  final double score;
  final MultimodalConfidenceLevel level;
  final List<String> factors;

  const MultimodalConfidenceResult({
    required this.score,
    required this.level,
    required this.factors,
  });
}

class IntegratedPhysiologicalConsensus {
  final String id;
  final DateTime generatedAt;
  final double integratedStressLoad;
  final double integratedRecoveryState;
  final double integratedResilience;
  final MultimodalConfidenceResult multimodalConfidence;
  final double signalAgreement;
  final List<String> contributingSignals;
  final List<String> disagreementFactors;

  const IntegratedPhysiologicalConsensus({
    required this.id,
    required this.generatedAt,
    required this.integratedStressLoad,
    required this.integratedRecoveryState,
    required this.integratedResilience,
    required this.multimodalConfidence,
    required this.signalAgreement,
    required this.contributingSignals,
    required this.disagreementFactors,
  });

  String get safetyCopy =>
      'consenso experimental por fusão multimodal; não representa avaliação clínica.';
}

class PhysiologicalFusionResult {
  final IntegratedPhysiologicalConsensus consensus;
  final SignalWeights weights;
  final List<String> signalConflicts;
  final List<String> recommendations;

  const PhysiologicalFusionResult({
    required this.consensus,
    required this.weights,
    required this.signalConflicts,
    required this.recommendations,
  });
}
