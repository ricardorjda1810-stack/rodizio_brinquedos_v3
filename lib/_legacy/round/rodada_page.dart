import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';

class RodadaPage extends StatefulWidget {
  final RoundRepository roundRepository;
  final SettingsRepository settingsRepository;

  const RodadaPage({
    super.key,
    required this.roundRepository,
    required this.settingsRepository,
  });

  @override
  State<RodadaPage> createState() => _RodadaPageState();
}

class _RodadaPageState extends State<RodadaPage> {
  RoundRepository get roundRepository => widget.roundRepository;
  SettingsRepository get settingsRepository => widget.settingsRepository;

  Future<void> _startRound(BuildContext context) async {
    // Historical screen: the current app derives active round size from
    // category quotas, so this legacy view no longer overrides it with the
    // old RoundUiSettings.perCategoryLimit value.
    final result = await roundRepository.startRound();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.created
              ? 'Rodada criada com ${result.selectedCount} brinquedos.'
              : 'Nenhum brinquedo dispon\u00edvel para iniciar a rodada.',
        ),
      ),
    );
  }

  Future<void> _endRound(BuildContext context) async {
    await roundRepository.endActiveRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rodada'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<int>(
          stream: settingsRepository.watchRoundSize(),
          initialData: settingsRepository.roundSize,
          builder: (context, snapSettings) {
            final roundSize = snapSettings.data ?? settingsRepository.roundSize;

            return StreamBuilder(
              stream: roundRepository.watchActiveRound(),
              builder: (context, snapRound) {
                final round = snapRound.data;

                if (snapRound.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (round == null) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.refresh_outlined),
                      title: const Text('Sem rodada ativa'),
                      subtitle: Text(
                        'Compatibilidade hist\u00f3rica: limite legado salvo = $roundSize',
                      ),
                      trailing: FilledButton(
                        onPressed: () => _startRound(context),
                        child: const Text('INICIAR'),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_outline),
                        title: const Text('Rodada ativa'),
                        subtitle: Text(
                          'Compatibilidade hist\u00f3rica: limite legado salvo = $roundSize',
                        ),
                        trailing: OutlinedButton(
                          onPressed: () => _endRound(context),
                          child: const Text('ENCERRAR'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: StreamBuilder<List<RoundToyWithBox>>(
                        stream: roundRepository.watchActiveRoundToysWithBox(),
                        builder: (context, snapItems) {
                          final items = snapItems.data ?? const <RoundToyWithBox>[];

                          if (snapItems.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (items.isEmpty) {
                            return const Center(
                              child: Text('Nenhum brinquedo na rodada.'),
                            );
                          }

                          return ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = items[index];

                              final toyText = item.toy.toString();
                              final boxText = item.box?.toString() ?? 'Sem caixa';

                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.toys_outlined),
                                  title: Text(toyText),
                                  subtitle: Text(
                                    'Caixa: $boxText \u2022 Posi\u00e7\u00e3o: ${item.position + 1}',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
