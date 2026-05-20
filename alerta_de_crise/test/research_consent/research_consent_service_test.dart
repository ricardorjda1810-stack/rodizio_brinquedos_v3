import 'package:flutter_test/flutter_test.dart';
import 'package:signalflow/research_consent/research_consent_models.dart';
import 'package:signalflow/research_consent/research_consent_repository.dart';
import 'package:signalflow/research_consent/research_consent_service.dart';

void main() {
  group('ResearchConsentService', () {
    test('acceptConsent saves accepted consent', () {
      final repository = ResearchConsentRepository();
      final now = DateTime.utc(2026, 5, 16, 12);
      final service = ResearchConsentService(
        repository: repository,
        now: () => now,
      );

      final consent = service.acceptConsent();

      expect(consent.accepted, isTrue);
      expect(repository.getCurrent(), same(consent));
    });

    test('revokeConsent disables active consent', () {
      final repository = ResearchConsentRepository();
      final service = ResearchConsentService(repository: repository);

      service.acceptConsent();
      service.revokeConsent();

      expect(service.hasValidConsent(), isFalse);
      expect(repository.getCurrent()?.accepted, isFalse);
    });

    test('hasValidConsent returns true for accepted current version', () {
      final service = ResearchConsentService(
        repository: ResearchConsentRepository(),
      );

      service.acceptConsent();

      expect(service.hasValidConsent(), isTrue);
    });

    test('hasValidConsent returns false for older version', () {
      final repository = ResearchConsentRepository();
      repository.save(
        ResearchConsent(
          accepted: true,
          acceptedAt: DateTime.utc(2026, 5, 16, 12),
          version: '0.9',
          allowsPhysiologicalCollection: true,
          allowsResearchExport: true,
          allowsReplayAnalysis: true,
        ),
      );
      final service = ResearchConsentService(repository: repository);

      expect(service.hasValidConsent(), isFalse);
    });

    test('version is preserved as current on accept', () {
      final service = ResearchConsentService(
        repository: ResearchConsentRepository(),
      );

      final consent = service.acceptConsent();

      expect(consent.version, ResearchConsentVersion.current);
    });

    test('acceptedAt is filled on accept', () {
      final now = DateTime.utc(2026, 5, 16, 12, 30);
      final service = ResearchConsentService(
        repository: ResearchConsentRepository(),
        now: () => now,
      );

      final consent = service.acceptConsent();

      expect(consent.acceptedAt, now);
    });
  });
}
