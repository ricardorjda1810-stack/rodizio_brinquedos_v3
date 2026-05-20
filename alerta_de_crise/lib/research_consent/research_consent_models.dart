class ResearchConsentVersion {
  static const current = '1.0';

  const ResearchConsentVersion._();
}

class ResearchConsent {
  final bool accepted;
  final DateTime? acceptedAt;
  final String version;
  final bool allowsPhysiologicalCollection;
  final bool allowsResearchExport;
  final bool allowsReplayAnalysis;

  const ResearchConsent({
    required this.accepted,
    required this.acceptedAt,
    required this.version,
    required this.allowsPhysiologicalCollection,
    required this.allowsResearchExport,
    required this.allowsReplayAnalysis,
  });

  factory ResearchConsent.revoked({
    String version = ResearchConsentVersion.current,
  }) {
    return ResearchConsent(
      accepted: false,
      acceptedAt: null,
      version: version,
      allowsPhysiologicalCollection: false,
      allowsResearchExport: false,
      allowsReplayAnalysis: false,
    );
  }

  bool get isCurrentVersion => version == ResearchConsentVersion.current;
}
