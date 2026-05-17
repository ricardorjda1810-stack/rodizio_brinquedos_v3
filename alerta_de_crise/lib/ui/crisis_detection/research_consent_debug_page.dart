import 'package:flutter/material.dart';

import '../../research_consent/research_consent_models.dart';
import '../../research_consent/research_consent_repository.dart';
import '../../research_consent/research_consent_service.dart';
import '../../research_consent/research_safety_copy.dart';

class ResearchConsentDebugPage extends StatefulWidget {
  const ResearchConsentDebugPage({super.key});

  @override
  State<ResearchConsentDebugPage> createState() =>
      _ResearchConsentDebugPageState();
}

class _ResearchConsentDebugPageState extends State<ResearchConsentDebugPage> {
  late final ResearchConsentRepository _repository;
  late final ResearchConsentService _service;
  ResearchConsent? _currentConsent;

  @override
  void initState() {
    super.initState();
    _repository = ResearchConsentRepository();
    _service = ResearchConsentService(repository: _repository);
    _currentConsent = _service.currentConsent;
  }

  void _acceptConsent() {
    setState(() {
      _currentConsent = _service.acceptConsent();
    });
  }

  void _revokeConsent() {
    _service.revokeConsent();
    setState(() {
      _currentConsent = _service.currentConsent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final consent = _currentConsent;
    final hasValidConsent = _service.hasValidConsent();

    return Scaffold(
      appBar: AppBar(title: const Text('Consentimento de pesquisa')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Fluxo experimental local',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Este painel interno registra consentimento local para pesquisa, '
            'autoconhecimento, coleta de sinais fisiológicos, replay e exportação.',
          ),
          const SizedBox(height: 16),
          Text(
            'Segurança e limites',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final copy in ResearchSafetyCopy.all)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(copy)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text('Status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            hasValidConsent ? 'Consentimento ativo' : 'Sem consentimento ativo',
          ),
          Text('Versão atual: ${ResearchConsentVersion.current}'),
          Text('Versão aceita: ${consent?.version ?? 'nenhuma'}'),
          Text(
            'Aceito em: ${consent?.acceptedAt?.toIso8601String() ?? 'não registrado'}',
          ),
          Text(
            'Coleta fisiológica: ${_permissionLabel(consent?.allowsPhysiologicalCollection)}',
          ),
          Text(
            'Exportação de pesquisa: ${_permissionLabel(consent?.allowsResearchExport)}',
          ),
          Text('Replay: ${_permissionLabel(consent?.allowsReplayAnalysis)}'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _acceptConsent,
            child: const Text('Aceitar consentimento'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _revokeConsent,
            child: const Text('Revogar consentimento'),
          ),
        ],
      ),
    );
  }

  String _permissionLabel(bool? value) {
    return value == true ? 'permitido' : 'não permitido';
  }
}
