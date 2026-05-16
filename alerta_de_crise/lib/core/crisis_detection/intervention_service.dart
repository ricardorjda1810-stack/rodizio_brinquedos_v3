import 'cognitive_check_response.dart';
import 'intervention_protocol.dart';
import 'intervention_protocol_step.dart';
import 'intervention_session_result.dart';

class InterventionService {
  InterventionProtocol? _protocol;
  DateTime? _startedAt;
  int _currentStepIndex = 0;
  bool _isCompleted = false;

  InterventionProtocol? get protocol => _protocol;
  DateTime? get startedAt => _startedAt;
  int get currentStepIndex => _currentStepIndex;
  bool get isActive => _protocol != null && !_isCompleted;
  bool get isCompleted => _isCompleted;

  InterventionProtocolStep? get currentStep {
    final protocol = _protocol;
    if (protocol == null || protocol.steps.isEmpty) {
      return null;
    }

    return protocol.steps[_currentStepIndex];
  }

  void startProtocol({InterventionProtocol? protocol}) {
    _protocol = protocol ?? InterventionProtocol.standard();
    _startedAt = DateTime.now();
    _currentStepIndex = 0;
    _isCompleted = false;
  }

  InterventionProtocolStep? nextStep() {
    final protocol = _protocol;
    if (protocol == null || protocol.steps.isEmpty) {
      return null;
    }

    final lastIndex = protocol.steps.length - 1;
    if (_currentStepIndex < lastIndex) {
      _currentStepIndex += 1;
    }

    return protocol.steps[_currentStepIndex];
  }

  InterventionSessionResult complete({
    required bool userReportedImprovement,
    required CognitiveCheckResponse finalResponse,
  }) {
    final protocol = _protocol ?? InterventionProtocol.standard();
    final startedAt = _startedAt ?? DateTime.now();

    _protocol = protocol;
    _startedAt = startedAt;
    _isCompleted = true;

    return InterventionSessionResult(
      protocolId: protocol.id,
      startedAt: startedAt,
      completedAt: DateTime.now(),
      completed: true,
      userReportedImprovement: userReportedImprovement,
      finalResponse: finalResponse,
    );
  }
}
