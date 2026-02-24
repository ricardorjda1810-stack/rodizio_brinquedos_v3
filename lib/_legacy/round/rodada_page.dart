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

  Future<void> _startRound(BuildContext context, int roundSize) async {
    await roundRepository.startRound(size: roundSize);
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

                // Sem rodada ativa
                if (round == null) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.refresh_outlined),
                      title: const Text('Sem rodada ativa'),
                      subtitle: Text('Tamanho: $roundSize'),
                      trailing: FilledButton(
                        onPressed: () => _startRound(context, roundSize),
                        child: const Text('INICIAR'),
                      ),
                    ),
                  );
                }

                // Com rodada ativa -> lista de brinquedos com Caixa/Local
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_outline),
                        title: const Text('Rodada ativa'),
                        subtitle: Text('Tamanho: $roundSize'),
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
                                  subtitle: Text('Caixa: $boxText • Posição: ${item.position + 1}'),
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
