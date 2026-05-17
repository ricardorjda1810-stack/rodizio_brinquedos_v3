import 'research_consent_models.dart';

class ResearchConsentRepository {
  ResearchConsent? _current;

  void save(ResearchConsent consent) {
    _current = consent;
  }

  ResearchConsent? getCurrent() {
    return _current;
  }

  void clear() {
    _current = null;
  }
}
