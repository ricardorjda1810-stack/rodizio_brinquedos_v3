import '../data/crisis_detection/crisis_risk_event.dart';
import '../data/crisis_detection/intervention_history_entry.dart';
import '../replay/csv_replay_session.dart';
import 'research_csv_exporter.dart';
import 'research_export_models.dart';
import 'research_export_statistics.dart';

typedef ResearchExportClock = DateTime Function();

class ResearchExportService {
  final ResearchCsvExporter _csvExporter;
  final ResearchExportClock _clock;

  const ResearchExportService({
    ResearchCsvExporter csvExporter = const ResearchCsvExporter(),
    ResearchExportClock? clock,
  }) : _csvExporter = csvExporter,
       _clock = clock ?? DateTime.now;

  ResearchExportBundle generateResearchBundle({
    required List<CrisisRiskEvent> crisisEvents,
    required List<InterventionHistoryEntry> interventions,
    required List<CsvReplaySession> replaySessions,
  }) {
    final statistics = ResearchExportStatistics.fromData(
      crisisEvents: crisisEvents,
      interventions: interventions,
    );
    final crisisCsv = _csvExporter.exportCrisisEvents(crisisEvents);
    final interventionCsv = _csvExporter.exportInterventionHistory(
      interventions,
    );
    final replayCsv = _csvExporter.exportReplaySessions(replaySessions);
    final fullCsv = _csvExporter.exportFullBundle(
      crisisEvents: crisisEvents,
      interventions: interventions,
      replaySessions: replaySessions,
    );

    return ResearchExportBundle(
      generatedAt: _clock(),
      totalEvents: crisisEvents.length,
      totalInterventions: interventions.length,
      totalReplaySessions: replaySessions.length,
      statistics: statistics,
      csvContents: {
        ResearchExportType.crisisEvents: crisisCsv,
        ResearchExportType.interventionHistory: interventionCsv,
        ResearchExportType.replaySessions: replayCsv,
        ResearchExportType.fullBundle: fullCsv,
      },
    );
  }
}
