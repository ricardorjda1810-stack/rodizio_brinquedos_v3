import 'dart:convert';

import 'package:drift/drift.dart';

import '../autonomic_recovery/autonomic_recovery_models.dart';
import '../cognitive_feedback/cognitive_feedback_models.dart';
import '../contextual_triggers/contextual_trigger_models.dart';
import '../database/signalflow_database.dart';
import '../physiological_trends/physiological_trend_models.dart';
import '../predictive_forecasting/predictive_forecast_models.dart';
import '../sensor_quality/sensor_confidence_score.dart';
import 'cross_modal_models.dart';
import 'integrated_consensus_engine.dart';
import 'signal_weighting_service.dart';

class PhysiologicalFusionService {
  final SignalFlowDatabase _database;
  final SignalWeightingService _weightingService;
  final IntegratedConsensusEngine _consensusEngine;

  PhysiologicalFusionService({
    SignalFlowDatabase? database,
    SignalWeightingService weightingService = const SignalWeightingService(),
    IntegratedConsensusEngine consensusEngine =
        const IntegratedConsensusEngine(),
  }) : _database = database ?? SignalFlowDatabase.instance,
       _weightingService = weightingService,
       _consensusEngine = consensusEngine;

  Future<PhysiologicalFusionResult> generateFusion({
    SensorConfidenceScore? sensorConfidence,
    List<PhysiologicalTrend> trends = const [],
    List<AutonomicRecoveryProfile> recoveryProfiles = const [],
    List<ContextualTriggerCorrelation> contextualCorrelations = const [],
    List<SubjectiveFeedbackEntry> subjectiveFeedback = const [],
    List<EscalationForecast> forecasts = const [],
    bool persist = true,
  }) async {
    final weights = _weightingService.calculateSignalWeights(
      sensorConfidence: sensorConfidence,
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      contextualCorrelations: contextualCorrelations,
      subjectiveFeedback: subjectiveFeedback,
      forecasts: forecasts,
    );
    final conflicts = _weightingService.detectSignalConflict(
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      subjectiveFeedback: subjectiveFeedback,
      forecasts: forecasts,
    );
    final consensus = _consensusEngine.buildConsensus(
      sensorConfidence: sensorConfidence,
      trends: trends,
      recoveryProfiles: recoveryProfiles,
      contextualCorrelations: contextualCorrelations,
      subjectiveFeedback: subjectiveFeedback,
      forecasts: forecasts,
      weights: weights,
    );
    final result = PhysiologicalFusionResult(
      consensus: consensus,
      weights: weights,
      signalConflicts: conflicts,
      recommendations: _recommendations(consensus),
    );
    if (persist) {
      await persistConsensus(consensus);
    }
    return result;
  }

  Future<void> persistConsensus(IntegratedPhysiologicalConsensus consensus) {
    return _database
        .into(_database.integratedConsensusSnapshotsTable)
        .insertOnConflictUpdate(_companionFor(consensus));
  }

  Future<List<IntegratedPhysiologicalConsensus>> loadConsensus({
    int limit = 20,
  }) async {
    final query = _database.select(_database.integratedConsensusSnapshotsTable)
      ..orderBy([
        (table) => OrderingTerm(
          expression: table.generatedAt,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  List<String> _recommendations(IntegratedPhysiologicalConsensus consensus) {
    return [
      if (consensus.integratedStressLoad >= 70)
        'observar sinais combinados com confiança experimental',
      if (consensus.signalAgreement < 55)
        'revisar conflito de sinais antes de interpretar consenso fisiológico',
      if (consensus.multimodalConfidence.level == MultimodalConfidenceLevel.low)
        'coletar mais dados antes de usar integração multimodal',
    ];
  }

  IntegratedConsensusSnapshotsTableCompanion _companionFor(
    IntegratedPhysiologicalConsensus consensus,
  ) {
    return IntegratedConsensusSnapshotsTableCompanion.insert(
      id: consensus.id,
      generatedAt: consensus.generatedAt,
      integratedStressLoad: consensus.integratedStressLoad,
      integratedRecoveryState: consensus.integratedRecoveryState,
      integratedResilience: consensus.integratedResilience,
      multimodalConfidence: consensus.multimodalConfidence.score,
      multimodalConfidenceLevel: consensus.multimodalConfidence.level.name,
      signalAgreement: consensus.signalAgreement,
      contributingSignalsJson: jsonEncode(consensus.contributingSignals),
      disagreementFactorsJson: jsonEncode(consensus.disagreementFactors),
      safetyCopy: consensus.safetyCopy,
    );
  }

  IntegratedPhysiologicalConsensus _fromRow(
    IntegratedConsensusSnapshotsTableData row,
  ) {
    return IntegratedPhysiologicalConsensus(
      id: row.id,
      generatedAt: row.generatedAt,
      integratedStressLoad: row.integratedStressLoad,
      integratedRecoveryState: row.integratedRecoveryState,
      integratedResilience: row.integratedResilience,
      multimodalConfidence: MultimodalConfidenceResult(
        score: row.multimodalConfidence,
        level: MultimodalConfidenceLevel.values.byName(
          row.multimodalConfidenceLevel,
        ),
        factors: const ['persisted'],
      ),
      signalAgreement: row.signalAgreement,
      contributingSignals: List<String>.from(
        jsonDecode(row.contributingSignalsJson) as List,
      ),
      disagreementFactors: List<String>.from(
        jsonDecode(row.disagreementFactorsJson) as List,
      ),
    );
  }
}
