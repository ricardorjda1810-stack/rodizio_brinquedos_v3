import '../../data/crisis_detection/crisis_risk_event.dart';
import '../../data/crisis_detection/crisis_risk_event_repository.dart';
import 'baseline_profile.dart';
import 'cognitive_check_response.dart';
import 'crisis_risk_engine.dart';
import 'crisis_risk_result.dart';
import 'physiological_sample.dart';

class CrisisDetectionService {
  final CrisisRiskEngine _engine;
  final CrisisRiskEventRepository _repository;

  const CrisisDetectionService({
    required CrisisRiskEngine engine,
    required CrisisRiskEventRepository repository,
  }) : _engine = engine,
       _repository = repository;

  CrisisRiskResult evaluateAndRecord({
    required PhysiologicalSample sample,
    required BaselineProfile baseline,
    CognitiveCheckResponse cognitiveResponse = CognitiveCheckResponse.notAsked,
    String source = 'debug',
  }) {
    final result = _engine.evaluate(
      sample: sample,
      baseline: baseline,
      cognitiveResponse: cognitiveResponse,
    );

    final event = CrisisRiskEvent(
      id: 'crisis-risk-${DateTime.now().microsecondsSinceEpoch}',
      timestamp: sample.timestamp,
      score: result.score,
      level: result.level,
      reasonCodes: result.reasonCodes,
      recommendedAction: result.recommendedAction,
      cognitiveResponse: cognitiveResponse,
      source: source,
    );

    _repository.save(event);

    return result;
  }
}
