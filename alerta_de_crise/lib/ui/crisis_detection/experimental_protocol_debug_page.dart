import 'package:flutter/material.dart';

import '../../experimental_protocols/experimental_protocol_models.dart';
import '../../experimental_protocols/protocol_execution_service.dart';
import '../../experimental_protocols/protocol_templates.dart';

class ExperimentalProtocolDebugPage extends StatefulWidget {
  const ExperimentalProtocolDebugPage({super.key});

  @override
  State<ExperimentalProtocolDebugPage> createState() =>
      _ExperimentalProtocolDebugPageState();
}

class _ExperimentalProtocolDebugPageState
    extends State<ExperimentalProtocolDebugPage> {
  final ProtocolExecutionService _service = ProtocolExecutionService();
  late final List<ExperimentalProtocol> _protocols = ProtocolTemplates.all();
  late ExperimentalProtocol _selectedProtocol = _protocols.first;
  ProtocolExecutionSession? _session;

  Future<void> _startProtocol() async {
    final session = await _service.startProtocol(
      _selectedProtocol,
      persist: false,
    );
    setState(() => _session = session);
  }

  void _nextPhase() {
    setState(() => _session = _service.nextPhase());
  }

  void _completeProtocol() {
    setState(() => _session = _service.completeProtocol());
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final phase = session?.currentPhase;
    final remaining = session == null
        ? Duration.zero
        : _service.remainingDuration(session);

    return Scaffold(
      appBar: AppBar(title: const Text('Experimental Protocols')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'protocolo experimental; coleta fisiológica controlada; não representa avaliação clínica.',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ExperimentalProtocol>(
            initialValue: _selectedProtocol,
            decoration: const InputDecoration(labelText: 'Protocol'),
            items: _protocols
                .map(
                  (protocol) => DropdownMenuItem(
                    value: protocol,
                    child: Text(protocol.title),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedProtocol = value);
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _startProtocol,
                child: const Text('Start protocol'),
              ),
              OutlinedButton(
                onPressed: session == null || session.completed
                    ? null
                    : _nextPhase,
                child: const Text('Next phase'),
              ),
              FilledButton.tonal(
                onPressed: session == null || session.completed
                    ? null
                    : _completeProtocol,
                child: const Text('Complete'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricTile(
            title: 'Protocol',
            value: _selectedProtocol.title,
            subtitle: 'contexto experimental',
          ),
          _MetricTile(
            title: 'Total duration',
            value: '${_selectedProtocol.totalDuration.inMinutes} min',
            subtitle: 'sessão controlada',
          ),
          _MetricTile(
            title: 'Current phase',
            value: phase?.title ?? '-',
            subtitle: phase?.description ?? 'fase experimental',
          ),
          _MetricTile(
            title: 'Remaining time',
            value: '${remaining.inMinutes} min',
            subtitle: 'coleta fisiológica',
          ),
          _MetricTile(
            title: 'Markers',
            value: '${session?.generatedMarkers.length ?? 0}',
            subtitle: session?.generatedMarkers.join(', ') ?? 'sem sessão',
          ),
          const SizedBox(height: 8),
          for (final protocol in _protocols)
            Card(
              child: ListTile(
                title: Text(protocol.title),
                subtitle: Text(
                  '${protocol.phases.length} fases, ${protocol.totalDuration.inMinutes} min',
                ),
                trailing: const Icon(Icons.science_outlined),
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
