import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/active_round_list.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/empty_state.dart';

class BrincadeiraProntaPage extends StatefulWidget {
  final ToyRepository toyRepository;
  final RoundRepository roundRepository;
  final List<ToyWithBox> initialSelection;
  final String ageLabel;
  final String recommendedText;
  final int recommendedMin;
  final int recommendedMax;

  const BrincadeiraProntaPage({
    super.key,
    required this.toyRepository,
    required this.roundRepository,
    required this.initialSelection,
    required this.ageLabel,
    required this.recommendedText,
    required this.recommendedMin,
    required this.recommendedMax,
  });

  @override
  State<BrincadeiraProntaPage> createState() => _BrincadeiraProntaPageState();
}

class _BrincadeiraProntaPageState extends State<BrincadeiraProntaPage> {
  static const int _maxSelected = 12;
  late List<ToyWithBox> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final seen = <String>{};
    _selected =
        widget.initialSelection.where((it) => seen.add(it.toy.id)).toList();
  }

  bool get _outsideRecommended =>
      _selected.length < widget.recommendedMin ||
      _selected.length > widget.recommendedMax;

  String _subtitle(ToyWithBox item) {
    final box = item.box;
    final localExtra = (item.toy.locationText ?? '').trim();

    if (box != null) {
      final local = box.local.trim();
      if (local.isEmpty) return 'Caixa ${box.number}';
      return 'Caixa ${box.number} - $local';
    }

    if (localExtra.isNotEmpty) return localExtra;
    return 'Sem caixa';
  }

  Future<void> _addToy() async {
    if (_selected.length >= _maxSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite de 12 brinquedos no conjunto.')),
      );
      return;
    }

    final selectedIds = {for (final it in _selected) it.toy.id};
    final picked = await showModalBottomSheet<ToyWithBox>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: StreamBuilder<List<ToyWithBox>>(
            stream: widget.toyRepository.watchAllWithBox(),
            builder: (context, snapshot) {
              final all = snapshot.data ?? const <ToyWithBox>[];
              final available =
                  all.where((it) => !selectedIds.contains(it.toy.id)).toList();

              if (available.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(UiTokens.m),
                  child: Center(
                    child: Text('Nenhum brinquedo disponivel para adicionar.'),
                  ),
                );
              }

              return ListView.separated(
                itemCount: available.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = available[index];
                  final title = item.toy.name.trim().isEmpty
                      ? 'Sem nome'
                      : item.toy.name.trim();

                  return ListTile(
                    leading: RoundToyThumb(path: item.toy.photoPath),
                    title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _subtitle(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.of(ctx).pop(item),
                  );
                },
              );
            },
          ),
        );
      },
    );

    if (picked == null || !mounted) return;
    setState(() => _selected = [..._selected, picked]);
  }

  void _removeToy(String toyId) {
    setState(
      () => _selected = _selected.where((it) => it.toy.id != toyId).toList(),
    );
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione ao menos 1 brinquedo para salvar.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.roundRepository
          .setActiveRoundFromToyIds(_selected.map((it) => it.toy.id).toList());
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar conjunto: $e')),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiTokens.bg,
      appBar: AppBar(
        title: const Text('Brincadeira pronta'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UiTokens.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSurfaceCard(
                padding: const EdgeInsets.all(UiTokens.spacingLg),
                color: UiTokens.primarySoft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use estes brinquedos agora',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: UiTokens.spacingXs),
                    Text(
                      'Faixa et\u00e1ria: ${widget.ageLabel} (recomendado: ${widget.recommendedText})',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    if (_outsideRecommended) ...[
                      const SizedBox(height: UiTokens.spacingSm),
                      Text(
                        'Aviso: a quantidade atual est\u00e1 fora do recomendado para a faixa.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: UiTokens.spacingMd),
              AppSurfaceCard(
                padding: const EdgeInsets.all(UiTokens.spacingMd),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selected.length} brinquedos selecionados',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _addToy,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: UiTokens.spacingMd),
              Expanded(
                child: _selected.isEmpty
                    ? EmptyState(
                        icon: Icons.toys_outlined,
                        title: 'Nenhum brinquedo no conjunto',
                        message:
                            'Adicione ao menos um brinquedo para montar a brincadeira pronta.',
                        actionLabel: 'Adicionar',
                        onAction: _addToy,
                      )
                    : AppSurfaceCard(
                        padding: const EdgeInsets.all(UiTokens.spacingMd),
                        child: ListView.separated(
                          itemCount: _selected.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _selected[index];
                            final title = item.toy.name.trim().isEmpty
                                ? 'Sem nome'
                                : item.toy.name.trim();
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: RoundToyThumb(path: item.toy.photoPath),
                              title: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                _subtitle(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: UiTokens.danger,
                                ),
                                onPressed: () => _removeToy(item.toy.id),
                                child: const Text('Remover'),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          UiTokens.m,
          UiTokens.xs,
          UiTokens.m,
          UiTokens.m,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    _saving ? null : () => Navigator.of(context).pop(false),
                child: const Text('Descartar'),
              ),
            ),
            const SizedBox(width: UiTokens.s),
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Salvando...' : 'Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
