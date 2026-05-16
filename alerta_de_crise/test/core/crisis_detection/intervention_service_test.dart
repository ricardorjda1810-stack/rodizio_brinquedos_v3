import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/core/crisis_detection/cognitive_check_response.dart';
import 'package:signalflow/core/crisis_detection/intervention_protocol.dart';
import 'package:signalflow/core/crisis_detection/intervention_service.dart';

void main() {
  group('InterventionService', () {
    test('startProtocol starts correctly', () {
      final service = InterventionService();

      service.startProtocol();

      expect(service.isActive, isTrue);
      expect(service.protocol?.id, InterventionProtocol.standard().id);
      expect(service.currentStepIndex, 0);
      expect(service.currentStep?.title, 'Respiração guiada');
      expect(service.startedAt, isNotNull);
    });

    test('nextStep advances steps', () {
      final service = InterventionService()..startProtocol();

      final next = service.nextStep();

      expect(service.currentStepIndex, 1);
      expect(next?.title, 'Grounding curto');
    });

    test('complete creates a valid InterventionSessionResult', () {
      final service = InterventionService()..startProtocol();

      final result = service.complete(
        userReportedImprovement: true,
        finalResponse: CognitiveCheckResponse.feelingOk,
      );

      expect(result.protocolId, InterventionProtocol.standard().id);
      expect(result.completed, isTrue);
      expect(service.isCompleted, isTrue);
    });

    test('completedAt is after or equal to startedAt', () async {
      final service = InterventionService()..startProtocol();
      await Future<void>.delayed(const Duration(milliseconds: 1));

      final result = service.complete(
        userReportedImprovement: true,
        finalResponse: CognitiveCheckResponse.feelingOk,
      );

      expect(result.completedAt.isBefore(result.startedAt), isFalse);
    });

    test('userReportedImprovement is preserved', () {
      final service = InterventionService()..startProtocol();

      final result = service.complete(
        userReportedImprovement: false,
        finalResponse: CognitiveCheckResponse.feelingActivated,
      );

      expect(result.userReportedImprovement, isFalse);
    });

    test('finalResponse is preserved', () {
      final service = InterventionService()..startProtocol();

      final result = service.complete(
        userReportedImprovement: true,
        finalResponse: CognitiveCheckResponse.needsHelp,
      );

      expect(result.finalResponse, CognitiveCheckResponse.needsHelp);
    });

    test('does not advance beyond the last step', () {
      final service = InterventionService()..startProtocol();
      final lastIndex = InterventionProtocol.standard().steps.length - 1;

      for (var index = 0; index < 10; index += 1) {
        service.nextStep();
      }

      expect(service.currentStepIndex, lastIndex);
      expect(service.currentStep?.title, 'Pergunta de recuperação');
    });
  });
}
