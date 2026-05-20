import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/experimental_protocols/protocol_phase.dart';
import 'package:signalflow/experimental_protocols/protocol_templates.dart';

void main() {
  group('ProtocolTemplates', () {
    test('creates valid templates', () {
      final templates = ProtocolTemplates.all(
        createdAt: DateTime.utc(2026, 5, 18),
      );

      expect(templates, hasLength(3));
      expect(
        templates.map((template) => template.title),
        containsAll([
          'Basic Recovery Protocol',
          'Escalation Observation Protocol',
          'Circadian Baseline Protocol',
        ]),
      );
      expect(templates.every((template) => template.phases.isNotEmpty), isTrue);
      expect(
        templates.every((template) => template.totalDuration.inSeconds > 0),
        isTrue,
      );
    });

    test('basic recovery protocol has expected duration and phases', () {
      final protocol = ProtocolTemplates.basicRecoveryProtocol();

      expect(protocol.totalDuration, const Duration(minutes: 15));
      expect(protocol.phases.map((phase) => phase.phaseType), [
        ProtocolPhaseType.resting,
        ProtocolPhaseType.breathing,
        ProtocolPhaseType.recovery,
      ]);
      expect(protocol.safetyCopy, contains('protocolo experimental'));
      expect(protocol.safetyCopy, contains('não representa avaliação clínica'));
    });
  });
}
