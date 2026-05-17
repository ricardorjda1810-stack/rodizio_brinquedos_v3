import 'package:flutter/material.dart';

import 'debug_hub_models.dart';
import 'debug_hub_sections.dart';

class SignalFlowDebugHubPage extends StatelessWidget {
  const SignalFlowDebugHubPage({super.key, this.sections});

  final List<DebugHubSection>? sections;

  @override
  Widget build(BuildContext context) {
    final debugSections = sections ?? SignalFlowDebugHubSections.build();

    return Scaffold(
      appBar: AppBar(title: const Text('SignalFlow Debug Hub')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'SignalFlow Experimental Debug',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('171 tests passing'),
          const Text('research/debug only'),
          const SizedBox(height: 16),
          const _SafetyBanner(),
          const SizedBox(height: 16),
          for (final section in debugSections) ...[
            _DebugHubSectionView(section: section),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Ferramenta experimental de pesquisa/autoconhecimento. '
          'Não substitui avaliação médica.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DebugHubSectionView extends StatelessWidget {
  const _DebugHubSectionView({required this.section});

  final DebugHubSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                section.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final item in section.items)
              ListTile(
                title: Text(item.label),
                subtitle: Text(item.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute<void>(builder: item.builder));
                },
              ),
          ],
        ),
      ),
    );
  }
}
