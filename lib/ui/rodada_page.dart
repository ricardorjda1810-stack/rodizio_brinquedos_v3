import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/brincadeira_pronta_page.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/active_round_list.dart';

class RodadaPage extends StatefulWidget {
  final RoundRepository roundRepository;
  final SettingsRepository settingsRepository;
  final ToyRepository toyRepository;
  final VoidCallback onOpenRodizioTab;
  final VoidCallback onOpenBrinquedosTab;

  const RodadaPage({
    super.key,
    required this.roundRepository,
    required this.settingsRepository,
    required this.toyRepository,
    required this.onOpenRodizioTab,
    required this.onOpenBrinquedosTab,
  });

  @override
  State<RodadaPage> createState() => _RodadaPageState();
}

class _RodadaPageState extends State<RodadaPage> {
  bool _creatingRound = false;
  bool _pickupMode = false;
  final Set<String> _pickedToyIds = <String>{};

  AppFeedback get _feedback => AppFeedback(widget.settingsRepository);

  Future<void> _createFirstRound() async {
    if (_creatingRound) return;
    setState(() => _creatingRound = true);
    try {
      await widget.roundRepository
          .startRound(size: widget.settingsRepository.roundSize);
      await _feedback.onRoundStarted();
      if (!mounted) return;
      widget.onOpenRodizioTab();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel criar a rodada: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _creatingRound = false);
      }
    }
  }

  int _daysToSwap(int startAtMs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime.fromMillisecondsSinceEpoch(startAtMs);
    final startDay = DateTime(start.year, start.month, start.day);
    final nextSwap = startDay.add(const Duration(days: 7));
    final diff = nextSwap.difference(today).inDays;
    return diff <= 0 ? 0 : diff;
  }

  Future<void> _openQuickSessionDialog({
    required List<ToyWithBox> toys,
    required List<RoundToyWithBox> activeRoundToys,
    required bool hasActiveRound,
  }) async {
    if (toys.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cadastre brinquedos para montar o conjunto.')),
      );
      return;
    }

    var selected = _AgeRangeOption.values[2];
    final picked = await showDialog<_AgeRangeOption>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Escolha a faixa etaria'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vou montar um conjunto com a quantidade ideal de brinquedos visiveis por vez.',
                  ),
                  const SizedBox(height: UiTokens.s),
                  Wrap(
                    spacing: UiTokens.xs,
                    runSpacing: UiTokens.xs,
                    children: _AgeRangeOption.values.map((option) {
                      return ChoiceChip(
                        label: Text(option.label),
                        selected: selected == option,
                        onSelected: (_) {
                          setDialogState(() => selected = option);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(selected),
                  child: const Text('Montar conjunto'),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked == null || !mounted) return;

    final selectedToys = _selectQuickSessionToys(
      toys: toys,
      activeRoundToyIds: activeRoundToys.map((it) => it.toy.id).toSet(),
      targetCount: picked.count,
      hasActiveRound: hasActiveRound,
    );

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BrincadeiraProntaPage(
          toyRepository: widget.toyRepository,
          roundRepository: widget.roundRepository,
          initialSelection: selectedToys,
          ageLabel: picked.label,
          recommendedText: '${picked.recommendedMin}-${picked.recommendedMax}',
          recommendedMin: picked.recommendedMin,
          recommendedMax: picked.recommendedMax,
        ),
      ),
    );

    if (saved == true && mounted) {
      widget.onOpenRodizioTab();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rodada ativa atualizada.')),
      );
    }
  }

  List<ToyWithBox> _selectQuickSessionToys({
    required List<ToyWithBox> toys,
    required Set<String> activeRoundToyIds,
    required int targetCount,
    required bool hasActiveRound,
  }) {
    final sorted = [...toys]..sort((a, b) {
        final an = a.toy.name.trim().toLowerCase();
        final bn = b.toy.name.trim().toLowerCase();
        final byName = an.compareTo(bn);
        if (byName != 0) return byName;
        return a.toy.id.compareTo(b.toy.id);
      });

    final ordered = hasActiveRound
        ? <ToyWithBox>[
            ...sorted.where((it) => !activeRoundToyIds.contains(it.toy.id)),
            ...sorted.where((it) => activeRoundToyIds.contains(it.toy.id)),
          ]
        : sorted;

    return ordered.take(targetCount.clamp(0, ordered.length)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Round?>(
      stream: widget.roundRepository.watchActiveRound(),
      builder: (context, roundSnapshot) {
        final activeRound = roundSnapshot.data;
        final hasActiveRound = activeRound != null;

        return StreamBuilder<List<RoundToyWithBox>>(
          stream: widget.roundRepository.watchActiveRoundToysWithBox(),
          builder: (context, roundToysSnapshot) {
            final activeRoundToys =
                roundToysSnapshot.data ?? const <RoundToyWithBox>[];
            final availableNow = activeRoundToys.length;
            final daysToSwap =
                activeRound == null ? 0 : _daysToSwap(activeRound.startAt);
            final isSwapDay = hasActiveRound && daysToSwap == 0;

            return StreamBuilder<List<ToyWithBox>>(
              stream: widget.toyRepository.watchAllWithBox(),
              builder: (context, toysSnapshot) {
                final allToys = toysSnapshot.data ?? const <ToyWithBox>[];
                final totalToys = allToys.length;
                final stored = (totalToys - availableNow) < 0
                    ? 0
                    : (totalToys - availableNow);

                final waiting = roundSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    roundToysSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    toysSnapshot.connectionState == ConnectionState.waiting &&
                    !roundSnapshot.hasData &&
                    !roundToysSnapshot.hasData &&
                    !toysSnapshot.hasData;

                if (waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  padding: const EdgeInsets.all(UiTokens.m),
                  children: [
                    _RoundStatusHeader(
                      hasActiveRound: hasActiveRound,
                      availableNow: availableNow,
                      isSwapDay: isSwapDay,
                      daysToSwap: daysToSwap,
                    ),
                    const SizedBox(height: UiTokens.m),
                    if (!hasActiveRound) ...[
                      const _EmptyRoundCallout(),
                    ],
                    const SizedBox(height: UiTokens.s),
                    _PrimaryActionButton(
                      label: hasActiveRound
                          ? 'Trocar brinquedos'
                          : (_creatingRound
                              ? 'Criando rodada...'
                              : (totalToys == 0
                                  ? 'Criar primeira rodada'
                                  : 'Criar rodada')),
                      icon: hasActiveRound
                          ? Icons.sync_alt_outlined
                          : Icons.autorenew,
                      onPressed: hasActiveRound
                          ? widget.onOpenRodizioTab
                          : _createFirstRound,
                    ),
                    const SizedBox(height: UiTokens.s),
                    _SecondaryActionButton(
                      label: 'Cadastrar brinquedos',
                      icon: Icons.toys_outlined,
                      onPressed: widget.onOpenBrinquedosTab,
                    ),
                    const SizedBox(height: UiTokens.s),
                    _SecondaryActionButton(
                      label: 'Montar brincadeira agora',
                      icon: Icons.bolt_outlined,
                      onPressed: () => _openQuickSessionDialog(
                        toys: allToys,
                        activeRoundToys: activeRoundToys,
                        hasActiveRound: hasActiveRound,
                      ),
                    ),
                    const SizedBox(height: UiTokens.m),
                    _InventorySummaryBar(
                      total: totalToys,
                      available: availableNow,
                      stored: stored,
                    ),
                    if (hasActiveRound) ...[
                      const SizedBox(height: UiTokens.m),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Modo retirada',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Switch(
                            value: _pickupMode,
                            onChanged: (value) {
                              setState(() {
                                _pickupMode = value;
                                if (!value) {
                                  _pickedToyIds.clear();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      if (_pickupMode)
                        Padding(
                          padding: const EdgeInsets.only(bottom: UiTokens.s),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Marque o brinquedo apos a retirada',
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ActiveRoundList(
                        roundRepository: widget.roundRepository,
                        toyRepository: widget.toyRepository,
                        dense: false,
                        maxItems: null,
                        title: 'Brinquedos da rodada ativa',
                        showPickupSwitch: _pickupMode,
                        pickedToyIds: _pickedToyIds,
                        onTogglePicked: (toyId) {
                          setState(() {
                            if (_pickedToyIds.contains(toyId)) {
                              _pickedToyIds.remove(toyId);
                            } else {
                              _pickedToyIds.add(toyId);
                            }
                          });
                        },
                      ),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _RoundStatusHeader extends StatelessWidget {
  final bool hasActiveRound;
  final int availableNow;
  final bool isSwapDay;
  final int daysToSwap;

  const _RoundStatusHeader({
    required this.hasActiveRound,
    required this.availableNow,
    required this.isSwapDay,
    required this.daysToSwap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final title = hasActiveRound ? 'Rodada ativa' : 'Nenhuma rodada ativa';
    final subtitle = hasActiveRound
        ? (isSwapDay
            ? 'Hoje e dia de trocar os brinquedos'
            : '$availableNow brinquedos disponiveis • Troca em $daysToSwap dias')
        : 'Crie uma rodada para montar o plano da semana.';
    final verticalPadding = hasActiveRound ? UiTokens.m : UiTokens.s;

    return Container(
      padding: EdgeInsets.fromLTRB(
        UiTokens.m,
        verticalPadding,
        UiTokens.m,
        verticalPadding,
      ),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(UiTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: UiTokens.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onPrimaryContainer,
                ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _InventorySummaryBar extends StatelessWidget {
  final int total;
  final int available;
  final int stored;

  const _InventorySummaryBar({
    required this.total,
    required this.available,
    required this.stored,
  });

  @override
  Widget build(BuildContext context) {
    final allZero = total == 0 && available == 0 && stored == 0;

    Widget item(String label, int value) {
      return Expanded(
        child: Column(
          children: [
            Text(
              allZero ? '—' : '$value',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: UiTokens.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiTokens.s,
          vertical: UiTokens.m,
        ),
        child: Column(
          children: [
            Row(
              children: [
                item('Total cadastrados', total),
                item('Disponiveis', available),
                item('Guardados', stored),
              ],
            ),
            if (allZero) ...[
              const SizedBox(height: UiTokens.s),
              Text(
                'Cadastre brinquedos para ver seus numeros aqui.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyRoundCallout extends StatelessWidget {
  const _EmptyRoundCallout();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    Widget step(IconData icon, String text, Color iconColor) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: onSurfaceVariant,
                  ),
            ),
          ),
        ],
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiTokens.m,
          vertical: UiTokens.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Como funciona?',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: UiTokens.s),
            Text(
              'Menos brinquedos por vez = mais interesse.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: UiTokens.s),
            Text(
              'Dicas rapidas:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: UiTokens.xs),
            step(
              Icons.inventory_2_outlined,
              'Caixas (opcional)',
              colorScheme.primary,
            ),
            const SizedBox(height: UiTokens.xs),
            step(
              Icons.photo_camera_outlined,
              'Brinquedos (com foto)',
              colorScheme.secondary,
            ),
            const SizedBox(height: UiTokens.xs),
            step(Icons.autorenew, 'Criar a rodada', colorScheme.tertiary),
          ],
        ),
      ),
    );
  }
}

enum _AgeRangeOption {
  m0to6(
    label: '0-6 meses',
    count: 3,
    recommendedMin: 2,
    recommendedMax: 4,
  ),
  m6to12(
    label: '6-12 meses',
    count: 5,
    recommendedMin: 4,
    recommendedMax: 6,
  ),
  y1to2(
    label: '1-2 anos',
    count: 6,
    recommendedMin: 4,
    recommendedMax: 8,
  ),
  y2to4(
    label: '2-4 anos',
    count: 8,
    recommendedMin: 6,
    recommendedMax: 10,
  );

  final String label;
  final int count;
  final int recommendedMin;
  final int recommendedMax;

  const _AgeRangeOption({
    required this.label,
    required this.count,
    required this.recommendedMin,
    required this.recommendedMax,
  });
}
