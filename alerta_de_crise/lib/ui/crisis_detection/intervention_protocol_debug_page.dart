import 'package:flutter/material.dart';

import '../../core/crisis_detection/cognitive_check_response.dart';
import '../../core/crisis_detection/intervention_outcome_service.dart';
import '../../core/crisis_detection/intervention_protocol_step.dart';
import '../../core/crisis_detection/intervention_service.dart';
import '../../core/crisis_detection/intervention_session_result.dart';
import '../../data/crisis_detection/intervention_history_entry.dart';
import '../../data/crisis_detection/intervention_history_repository.dart';
import 'intervention_history_debug_page.dart';

class InterventionProtocolDebugPage extends StatefulWidget {
  const InterventionProtocolDebugPage({super.key});

  @override
  State<InterventionProtocolDebugPage> createState() =>
      _InterventionProtocolDebugPageState();
}

class _InterventionProtocolDebugPageState
    extends State<InterventionProtocolDebugPage> {
  static const int _preInterventionScore = 70;

  final InterventionService _service = InterventionService()..startProtocol();
  final InterventionHistoryRepository _historyRepository =
      InterventionHistoryRepository(persistSyncWrites: true);
  late final InterventionOutcomeService _outcomeService =
      InterventionOutcomeService(repository: _historyRepository);
  InterventionSessionResult? _result;
  InterventionHistoryEntry? _historyEntry;
  bool _userReportedImprovement = true;
  CognitiveCheckResponse _finalResponse = CognitiveCheckResponse.feelingOk;

  @override
  Widget build(BuildContext context) {
    final protocol = _service.protocol;
    final step = _service.currentStep;
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('Protocolo guiado debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            protocol?.title ?? 'Pausa guiada',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            protocol?.description ??
                'Fluxo interno para recuperação fisiológica.',
          ),
          const SizedBox(height: 16),
          if (step != null)
            _StepCard(index: _service.currentStepIndex, step: step),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _result == null ? _nextStep : null,
            child: const Text('Próxima etapa'),
          ),
          const SizedBox(height: 16),
          _ScorePreviewCard(
            preInterventionScore: _preInterventionScore,
            postInterventionScore: _postInterventionScore,
          ),
          const SizedBox(height: 16),
          _CompletionControls(
            userReportedImprovement: _userReportedImprovement,
            finalResponse: _finalResponse,
            onImprovementChanged: (value) {
              setState(() {
                _userReportedImprovement = value;
              });
            },
            onResponseChanged: (value) {
              setState(() {
                _finalResponse = value;
              });
            },
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _result == null ? _completeProtocol : null,
            child: const Text('Finalizar protocolo'),
          ),
          if (result != null) ...[
            const SizedBox(height: 16),
            _ResultCard(result: result, historyEntry: _historyEntry),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _openHistory,
              child: const Text('Ver histórico debug'),
            ),
          ],
        ],
      ),
    );
  }

  void _nextStep() {
    setState(() {
      _service.nextStep();
    });
  }

  void _completeProtocol() {
    setState(() {
      final result = _service.complete(
        userReportedImprovement: _userReportedImprovement,
        finalResponse: _finalResponse,
      );
      _result = result;
      _historyEntry = _outcomeService.recordOutcome(
        result: result,
        preInterventionScore: _preInterventionScore,
        postInterventionScore: _postInterventionScore,
      );
    });
  }

  int get _postInterventionScore {
    if (!_userReportedImprovement) {
      return _preInterventionScore;
    }

    return (_preInterventionScore - 25).clamp(0, 100);
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            InterventionHistoryDebugPage(repository: _historyRepository),
      ),
    );
  }
}

class _ScorePreviewCard extends StatelessWidget {
  const _ScorePreviewCard({
    required this.preInterventionScore,
    required this.postInterventionScore,
  });

  final int preInterventionScore;
  final int postInterventionScore;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resposta fisiológica simulada',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Score antes: $preInterventionScore'),
            Text('Score depois estimado: $postInterventionScore'),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.index, required this.step});

  final int index;
  final InterventionProtocolStep step;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Etapa ${index + 1}: ${step.title}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(step.description),
            const SizedBox(height: 8),
            Text('Duração sugerida: ${step.durationSeconds}s'),
            Text(
              'Confirmação: ${step.requiresUserConfirmation ? 'sim' : 'não'}',
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionControls extends StatelessWidget {
  const _CompletionControls({
    required this.userReportedImprovement,
    required this.finalResponse,
    required this.onImprovementChanged,
    required this.onResponseChanged,
  });

  final bool userReportedImprovement;
  final CognitiveCheckResponse finalResponse;
  final ValueChanged<bool> onImprovementChanged;
  final ValueChanged<CognitiveCheckResponse> onResponseChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Você se sente melhor?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Sim'),
                  selected: userReportedImprovement,
                  onSelected: (_) => onImprovementChanged(true),
                ),
                ChoiceChip(
                  label: const Text('Não'),
                  selected: !userReportedImprovement,
                  onSelected: (_) => onImprovementChanged(false),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Resposta final',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final response in [
                  CognitiveCheckResponse.feelingOk,
                  CognitiveCheckResponse.feelingActivated,
                  CognitiveCheckResponse.needsHelp,
                ])
                  ChoiceChip(
                    label: Text(response.name),
                    selected: finalResponse == response,
                    onSelected: (_) => onResponseChanged(response),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.historyEntry});

  final InterventionSessionResult result;
  final InterventionHistoryEntry? historyEntry;

  @override
  Widget build(BuildContext context) {
    final entry = historyEntry;
    final durationSeconds = result.completedAt
        .difference(result.startedAt)
        .inSeconds
        .clamp(0, 999999);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultado final',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Protocolo: ${result.protocolId}'),
            Text('Concluído: ${result.completed ? 'sim' : 'não'}'),
            Text('Duração total: ${durationSeconds}s'),
            Text(
              'Houve melhora: ${result.userReportedImprovement ? 'sim' : 'não'}',
            ),
            Text('Resposta final: ${result.finalResponse.name}'),
            if (entry != null) ...[
              const SizedBox(height: 8),
              Text('Score pré: ${entry.preInterventionScore ?? 'n/a'}'),
              Text('Score pós: ${entry.postInterventionScore ?? 'n/a'}'),
              Text('Delta: ${entry.scoreDelta ?? 'n/a'}'),
            ],
          ],
        ),
      ),
    );
  }
}
