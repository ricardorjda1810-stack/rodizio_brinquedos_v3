// lib/ui/caixas_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/box_create_page.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class CaixasPage extends StatelessWidget {
  static const double _gridInfoHeight = 80;

  final ToyRepository toyRepository;
  final SettingsRepository settingsRepository;
  final void Function(String boxId) onOpenBrinquedosForBox;

  const CaixasPage({
    super.key,
    required this.toyRepository,
    required this.settingsRepository,
    required this.onOpenBrinquedosForBox,
  });

  String _boxTitle(Boxe box) {
    final local = box.local.trim();
    if (local.isEmpty) return 'Caixa ${box.number}';
    return 'Caixa ${box.number} - $local';
  }

  Future<void> _openAddBoxPage(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BoxCreatePage(
          toyRepository: toyRepository,
          settingsRepository: settingsRepository,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String boxId, String label) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir caixa?'),
        content:
            Text('"$label" sera apagada e os brinquedos ficarao sem caixa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await AppFeedback(settingsRepository).onDeleteConfirmed();
      await toyRepository.deleteBox(boxId: boxId);
    }
  }

  Future<void> _pickBoxPhoto(BuildContext context, Boxe box) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      await toyRepository.pickAndSaveBoxPhoto(boxId: box.id, source: source);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar foto da caixa: $e')),
      );
    }
  }

  Future<void> _editBoxLocal(BuildContext context, Boxe box) async {
    final locations = await toyRepository.watchLocations().first;
    if (!context.mounted) return;
    if (locations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum local configurado.')),
      );
      return;
    }

    final hasCurrent = locations.any((l) => l.name == box.local);
    var selectedLocationId = hasCurrent
        ? locations.firstWhere((l) => l.name == box.local).id
        : locations.first.id;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: const Text('Editar local'),
          content: DropdownButtonFormField<String>(
            initialValue: selectedLocationId,
            decoration: const InputDecoration(
              labelText: 'Local',
            ),
            items: locations
                .map(
                  (l) => DropdownMenuItem<String>(
                    value: l.id,
                    child: Text(l.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setLocalState(() => selectedLocationId = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              onPressed: () {
                final selected =
                    locations.firstWhere((l) => l.id == selectedLocationId);
                Navigator.of(ctx).pop(selected.name);
              },
              child: const Text('SALVAR'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    try {
      await toyRepository.updateBoxLocal(
        boxId: box.id,
        local: result,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar local da caixa: $e')),
      );
    }
  }

  Future<void> _editBoxNotes(BuildContext context, Boxe box) async {
    final controller = TextEditingController(text: box.notes ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Informacoes da caixa'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          maxLength: 120,
          inputFormatters: [
            LengthLimitingTextInputFormatter(120),
          ],
          decoration: const InputDecoration(
            labelText: 'Informacoes importantes (opcional)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result == null) return;

    try {
      await toyRepository.updateBoxNotes(
        boxId: box.id,
        notes: result,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar informacoes da caixa: $e')),
      );
    }
  }

  Widget _buildBoxCard(
    BuildContext context, {
    required Boxe box,
    required int count,
  }) {
    final title = _boxTitle(box);
    final hasPhoto = (box.photoPath ?? '').trim().isNotEmpty;
    final notes = (box.notes ?? '').trim();
    final subtitle =
        notes.isEmpty ? '$count brinquedos' : '$count brinquedos\n$notes';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onOpenBrinquedosForBox(box.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  (box.photoPath ?? '').trim().isEmpty
                      ? Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.inventory_2_outlined),
                          ),
                        )
                      : Image.file(
                          File((box.photoPath ?? '').trim()),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) => Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.inventory_2_outlined),
                            ),
                          ),
                        ),
                  Positioned(
                    right: UiTokens.xs,
                    top: UiTokens.xs,
                    child: PopupMenuButton<String>(
                      tooltip: 'Acoes da caixa',
                      onSelected: (value) async {
                        if (value == 'edit_local') {
                          await _editBoxLocal(context, box);
                          return;
                        }
                        if (value == 'photo') {
                          await _pickBoxPhoto(context, box);
                          return;
                        }
                        if (value == 'edit_notes') {
                          await _editBoxNotes(context, box);
                          return;
                        }
                        if (value == 'delete') {
                          await _confirmDelete(context, box.id, title);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'edit_local',
                          child: Text('Editar local'),
                        ),
                        PopupMenuItem<String>(
                          value: 'photo',
                          child: Text(
                            hasPhoto ? 'Trocar foto' : 'Adicionar foto',
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'edit_notes',
                          child: Text('Editar informacoes'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Excluir'),
                        ),
                      ],
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.92),
                          borderRadius:
                              BorderRadius.circular(UiTokens.radiusButton),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(Icons.more_vert, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  UiTokens.s, UiTokens.xs, UiTokens.s, 2),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  UiTokens.s, 0, UiTokens.s, UiTokens.xs),
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UiTokens.m),
          child: StreamBuilder<List<Boxe>>(
            stream: toyRepository.watchBoxes(),
            builder: (context, boxesSnapshot) {
              final boxes = boxesSnapshot.data ?? const <Boxe>[];

              if (boxesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (boxes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          'Nenhuma caixa cadastrada. Crie sua primeira caixa.'),
                      const SizedBox(height: UiTokens.s),
                      FilledButton(
                        onPressed: () => _openAddBoxPage(context),
                        child: const Text('Criar caixa'),
                      ),
                    ],
                  ),
                );
              }

              return StreamBuilder<List<ToyCatalogItem>>(
                stream: toyRepository.watchCatalog(),
                builder: (context, catalogSnapshot) {
                  if (catalogSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !catalogSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items =
                      catalogSnapshot.data ?? const <ToyCatalogItem>[];
                  final toyCountByBoxId = <String, int>{};
                  for (final item in items) {
                    final boxId = item.toy.boxId;
                    if (boxId == null) continue;
                    toyCountByBoxId[boxId] = (toyCountByBoxId[boxId] ?? 0) + 1;
                  }

                  final width = MediaQuery.sizeOf(context).width;
                  final cols = width < 600 ? 2 : 4;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final tileWidth =
                          (constraints.maxWidth - (UiTokens.s * (cols - 1))) /
                              cols;
                      final tileHeight = tileWidth + _gridInfoHeight;

                      return GridView.builder(
                        padding: const EdgeInsets.only(bottom: 96),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: UiTokens.s,
                          mainAxisSpacing: UiTokens.s,
                          mainAxisExtent: tileHeight,
                        ),
                        itemCount: boxes.length,
                        itemBuilder: (ctx, i) {
                          final box = boxes[i];
                          final count = toyCountByBoxId[box.id] ?? 0;
                          return _buildBoxCard(
                            ctx,
                            box: box,
                            count: count,
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddBoxPage(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova caixa'),
      ),
    );
  }
}
