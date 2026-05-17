import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/research_consent/research_consent_models.dart';
import 'package:signalflow/research_consent/research_consent_repository.dart';

void main() {
  group('ResearchConsentRepository', () {
    test('save/getCurrent stores consent', () {
      final repository = ResearchConsentRepository();
      final acceptedAt = DateTime.utc(2026, 5, 16, 10);
      final consent = ResearchConsent(
        accepted: true,
        acceptedAt: acceptedAt,
        version: ResearchConsentVersion.current,
        allowsPhysiologicalCollection: true,
        allowsResearchExport: true,
        allowsReplayAnalysis: true,
      );

      repository.save(consent);

      expect(repository.getCurrent(), same(consent));
    });

    test('clear removes consent', () {
      final repository = ResearchConsentRepository()
        ..save(
          ResearchConsent(
            accepted: true,
            acceptedAt: DateTime.utc(2026, 5, 16, 10),
            version: ResearchConsentVersion.current,
            allowsPhysiologicalCollection: true,
            allowsResearchExport: true,
            allowsReplayAnalysis: true,
          ),
        );

      repository.clear();

      expect(repository.getCurrent(), isNull);
    });
  });
}
