import 'package:flutter/material.dart';

import '../../experimental_studies/experimental_study_models.dart';
import '../../experimental_studies/study_metrics_service.dart';
import '../../experimental_studies/study_runner_service.dart';
import '../../experimental_studies/study_summary_generator.dart';

class ExperimentalStudyDebugPage extends StatefulWidget {
  const ExperimentalStudyDebugPage({super.key});

  @override
  State<ExperimentalStudyDebugPage> createState() =>
      _ExperimentalStudyDebugPageState();
}

class _ExperimentalStudyDebugPageState
    extends State<ExperimentalStudyDebugPage> {
  final StudyRunnerService _runner = StudyRunnerService();
  final StudyMetricsService _metricsService = const StudyMetricsService();
  final StudySummaryGenerator _summaryGenerator = const StudySummaryGenerator();
  ExperimentalStudy? _study;
  ExperimentalStudySession? _activeSession;
  final List<ExperimentalStudySession> _sessions = [];
  StudyMetrics? _metrics;
  List<String> _summary = const [];

  Future<void> _createStudy() async {
    final study = await _runner.startStudy(
      title: 'Benchmark longitudinal debug',
      description: 'estudo experimental para coleta experimental estruturada.',
      protocolId: 'basic-recovery-protocol',
      totalParticipants: 1,
      studyTags: const ['coorte experimental', 'benchmark longitudinal'],
      enabledSensors: const ['Polar H10', 'Apple Health'],
    );
    setState(() {
      _study = study;
      _sessions.clear();
      _metrics = null;
      _summary = const [];
    });
  }

  Future<void> _startSession() async {
    final study = _study;
    if (study == null || _activeSession != null) return;
    final session = await _runner.startStudySession(
      study: study,
      sessionId: 'debug-session-${_sessions.length + 1}',
    );
    setState(() => _activeSession = session);
  }

  Future<void> _completeSession() async {
    final session = _activeSession;
    if (session == null) return;
    final completed = await _runner.completeStudySession(
      sessionRecordId: session.id,
      replayGenerated: true,
      benchmarkGenerated: true,
      subjectiveFeedbackIncluded: true,
      multimodalConsensusScore: 84,
    );
    setState(() {
      _activeSession = null;
      _sessions.add(completed);
      _recalculateMetrics();
    });
  }

  void _recalculateMetrics() {
    _metrics = _metricsService.calculateStudyMetrics(
      sessions: _sessions,
      recoveryScores: const [72, 78, 82],
      falseEscalationRates: const [8, 6, 5],
      sensorReliabilityScores: const [86, 88, 90],
    );
  }

  Future<void> _generateSummary() async {
    final study = _study;
    if (study == null) return;
    _recalculateMetrics();
    final metrics = _metrics!;
    setState(() {
      _summary = [
        ..._summaryGenerator.generateLongitudinalSummary(study, metrics),
        ..._summaryGenerator.generateRecoverySummary(metrics),
        ..._summaryGenerator.generateForecastSummary(metrics),
        ..._summaryGenerator.generateContextualSummary(study),
        ..._summaryGenerator.generateBenchmarkSummary(metrics),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics;

    return Scaffold(
      appBar: AppBar(title: const Text('Experimental Studies')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'estudo experimental; coleta fisiológica experimental; não representa estudo clínico.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _createStudy,
                child: const Text('Create study'),
              ),
              OutlinedButton(
                onPressed: _study == null ? null : _startSession,
                child: const Text('Start session'),
              ),
              OutlinedButton(
                onPressed: _activeSession == null ? null : _completeSession,
                child: const Text('Complete session'),
              ),
              OutlinedButton(
                onPressed: _study == null ? null : _generateSummary,
                child: const Text('Generate summary'),
              ),
              OutlinedButton(
                onPressed: _study == null
                    ? null
                    : () {
                        _recalculateMetrics();
                        setState(() {});
                      },
                child: const Text('Recalculate metrics'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricTile(
            title: 'Total sessions',
            value: _sessions.length.toString(),
            subtitle: 'sessão experimental',
          ),
          _MetricTile(
            title: 'Recovery efficiency',
            value: metrics?.recoveryEfficiency.toStringAsFixed(0) ?? '-',
            subtitle: 'estudo experimental',
          ),
          _MetricTile(
            title: 'Multimodal agreement',
            value: metrics?.multimodalAgreement.toStringAsFixed(0) ?? '-',
            subtitle: 'coorte experimental',
          ),
          _MetricTile(
            title: 'Benchmark score',
            value: metrics?.benchmarkConsistency.toStringAsFixed(0) ?? '-',
            subtitle: 'benchmark longitudinal',
          ),
          _MetricTile(
            title: 'Resilience trend',
            value: metrics?.resilienceTrend.toStringAsFixed(0) ?? '-',
            subtitle: 'coleta experimental',
          ),
          _MetricTile(
            title: 'Replay dataset',
            value: _sessions.any((session) => session.replayGenerated)
                ? 'ready'
                : '-',
            subtitle: 'gerar replay dataset',
          ),
          for (final line in _summary)
            Card(
              child: ListTile(
                title: const Text('Study summary'),
                subtitle: Text(line),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(value),
      ),
    );
  }
}
