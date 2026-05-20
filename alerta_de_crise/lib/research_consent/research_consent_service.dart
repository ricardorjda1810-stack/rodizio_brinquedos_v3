import 'research_consent_models.dart';
import 'research_consent_repository.dart';

class ResearchConsentService {
  final ResearchConsentRepository _repository;
  final DateTime Function() _now;

  ResearchConsentService({
    required ResearchConsentRepository repository,
    DateTime Function()? now,
  }) : _repository = repository,
       _now = now ?? DateTime.now;

  ResearchConsent? get currentConsent => _repository.getCurrent();

  ResearchConsent acceptConsent({
    bool allowsPhysiologicalCollection = true,
    bool allowsResearchExport = true,
    bool allowsReplayAnalysis = true,
  }) {
    final consent = ResearchConsent(
      accepted: true,
      acceptedAt: _now(),
      version: ResearchConsentVersion.current,
      allowsPhysiologicalCollection: allowsPhysiologicalCollection,
      allowsResearchExport: allowsResearchExport,
      allowsReplayAnalysis: allowsReplayAnalysis,
    );

    _repository.save(consent);
    return consent;
  }

  void revokeConsent() {
    _repository.save(ResearchConsent.revoked());
  }

  bool hasValidConsent() {
    final consent = _repository.getCurrent();
    return consent != null && consent.accepted && consent.isCurrentVersion;
  }
}
