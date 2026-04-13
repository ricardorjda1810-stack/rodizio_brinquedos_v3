import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/photo_crop_page.dart';
import 'package:rodizio_brinquedos_v3/ui/photo_viewer_page.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

const String _toyBoxNoSelectionValue = '__sem_selecao_caixa__';
const String _toyBoxWithoutBoxValue = '__sem_caixa__';
const String _toyBoxRequiredMessage =
    'Selecione uma caixa ou escolha "Sem caixa" para salvar o brinquedo.';

class ToyDetailPage extends StatelessWidget {
  static const String _detailsMenuRename = 'rename';
  static const String _detailsMenuCategory = 'category';
  static const String _detailsMenuBox = 'box';
  static const String _detailsMenuDelete = 'delete';
  static const String _photoMenuCamera = 'camera';
  static const String _photoMenuGallery = 'gallery';
  static const String _photoMenuRemove = 'remove';

  final String toyId;
  final ToyRepository toyRepository;

  const ToyDetailPage({
    super.key,
    required this.toyId,
    required this.toyRepository,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, imageQuality: 85);
      if (image == null || !context.mounted) return;

      final croppedPath = await PhotoCropPage.open(
        context,
        sourcePath: image.path,
      );
      if (croppedPath == null || !context.mounted) return;

      await toyRepository.saveToyPhoto(
        toyId: toyId,
        croppedPhotoPath: croppedPath,
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao salvar foto: $e')),
      );
    }
  }

  Future<void> _remove(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await toyRepository.removeToyPhoto(toyId: toyId);
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao remover foto: $e')),
      );
    }
  }

  Future<void> _renameToy(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName.trim());
    final messenger = ScaffoldMessenger.of(context);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar nome'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Nome do brinquedo'),
            onSubmitted: (_) => Navigator.of(ctx).pop(controller.text.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (newName == null) return;
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nome nao pode ficar vazio.')),
      );
      return;
    }

    try {
      await toyRepository.updateToyName(toyId: toyId, name: trimmed);
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao salvar nome: $e')),
      );
    }
  }

  Future<void> _editToyCategory(
    BuildContext context, {
    required String currentCategoryId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final selectedCategoryId = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String selectedId = currentCategoryId;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar categoria'),
              content: StreamBuilder(
                stream: toyRepository.watchCategories(activeOnly: true),
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? const [];
                  if (categories.isEmpty) {
                    return const Text('Nenhuma categoria ativa.');
                  }

                  if (!categories.any((c) => c.id == selectedId)) {
                    selectedId = categories.first.id;
                  }

                  return SizedBox(
                    width: double.maxFinite,
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedId,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: [
                        for (final c in categories)
                          DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedId = value);
                      },
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(selectedId),
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedCategoryId == null ||
        selectedCategoryId.trim().isEmpty ||
        selectedCategoryId == currentCategoryId) {
      return;
    }

    try {
      await toyRepository.updateToyCategory(
        toyId: toyId,
        categoryId: selectedCategoryId,
      );
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Categoria atualizada.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao atualizar categoria: $e')),
      );
    }
  }

  Future<void> _editToyBox(
    BuildContext context, {
    required String? currentBoxId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final boxes = await toyRepository.watchBoxes().first;
    if (!context.mounted) return;

    String selectedBoxSelection = currentBoxId ?? _toyBoxNoSelectionValue;
    if (currentBoxId != null && !boxes.any((b) => b.id == currentBoxId)) {
      selectedBoxSelection = _toyBoxNoSelectionValue;
    }

    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Editar caixa'),
            content: DropdownButtonFormField<String?>(
              initialValue: selectedBoxSelection,
              decoration: const InputDecoration(labelText: 'Caixa'),
              items: <DropdownMenuItem<String?>>[
                const DropdownMenuItem<String?>(
                  value: _toyBoxNoSelectionValue,
                  child: Text('Selecione uma caixa ou "Sem caixa"'),
                ),
                const DropdownMenuItem<String?>(
                  value: _toyBoxWithoutBoxValue,
                  child: Text('Sem caixa'),
                ),
                ...boxes.map(
                  (b) => DropdownMenuItem<String?>(
                    value: b.id,
                    child: Text('Caixa ${b.number} - ${b.local}'),
                  ),
                ),
              ],
              onChanged: (value) {
                setDialogState(
                  () => selectedBoxSelection = value ?? _toyBoxNoSelectionValue,
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (selectedBoxSelection == _toyBoxNoSelectionValue) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text(_toyBoxRequiredMessage)),
                    );
                    return;
                  }

                  Navigator.of(ctx).pop(
                    selectedBoxSelection == _toyBoxWithoutBoxValue
                        ? null
                        : selectedBoxSelection,
                  );
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );

    if (result == currentBoxId) return;

    try {
      await toyRepository.setToyBox(toyId: toyId, boxId: result);
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Caixa atualizada.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao atualizar caixa: $e')),
      );
    }
  }

  Future<void> _deleteToy(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir brinquedo?'),
        content: const Text('Esta acao nao pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: UiTokens.danger,
              foregroundColor: UiTokens.surface,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    if (!context.mounted) return;

    try {
      await toyRepository.deleteToy(toyId: toyId);
      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir brinquedo: $e')));
    }
  }

  void _openPhotoViewer(
    BuildContext context, {
    required String photoPath,
    required String title,
    required String boxLabel,
    required String categoryLabel,
    required String locationFieldLabel,
    required String locationLabel,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoViewerPage(
          photoPath: photoPath,
          title: title,
          boxLabel: boxLabel,
          categoryLabel: categoryLabel,
          locationFieldLabel: locationFieldLabel,
          locationLabel: locationLabel,
        ),
      ),
    );
  }

  Widget _photoOrPlaceholder(BuildContext context, String? path) {
    final textTheme = Theme.of(context).textTheme;

    final p = (path ?? '').trim();
    if (p.isEmpty) {
      return Container(
        color: UiTokens.primarySoft,
        child: Center(child: Text('Sem foto', style: textTheme.bodySmall)),
      );
    }

    return Image.file(
      File(p),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) {
        return Container(
          color: UiTokens.primarySoft,
          child: Center(child: Text('Sem foto', style: textTheme.bodySmall)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryDefinition>>(
      stream: toyRepository.watchCategories(),
      builder: (context, categoriesSnapshot) {
        final categories = categoriesSnapshot.data ?? const <CategoryDefinition>[];

        return StreamBuilder<ToyWithBox?>(
          stream: toyRepository.watchToyWithBox(toyId: toyId),
          builder: (context, snapshot) {
            final data = snapshot.data;

            final title = (data == null || data.toy.name.trim().isEmpty)
                ? 'Brinquedo'
                : data.toy.name;

            final photoPath = data?.toy.photoPath;
            final box = data?.box;
            final boxLabel = (box == null)
                ? 'Sem caixa'
                : 'Caixa ${box.number} - ${box.local}';
            final locationText = (data?.toy.locationText ?? '').trim();
            final categoryId = (data?.toy.categoryId ?? '').trim();
            final categoryLabel = categories
                    .where((c) => c.id == categoryId)
                    .map((c) => c.name.trim())
                    .cast<String?>()
                    .firstWhere(
                      (c) => c != null && c.isNotEmpty,
                      orElse: () => null,
                    ) ??
                'Sem categoria';
            final effectiveLocationLabel = box != null
                ? (box.local.trim().isEmpty ? 'Sem local' : box.local.trim())
                : (locationText.isEmpty ? 'Sem local' : locationText);
            final locationFieldLabel =
                box != null ? 'Local da caixa' : 'Local fora da caixa';

            return Scaffold(
              backgroundColor: UiTokens.bg,
              appBar: AppBar(title: Text(title)),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UiTokens.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSurfaceCard(
                        padding: const EdgeInsets.all(UiTokens.spacingLg),
                        color: UiTokens.primarySoft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: UiTokens.spacingXs),
                                  Text(
                                    'Uma vis\u00e3o simples e organizada das informa\u00e7\u00f5es principais.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: UiTokens.spacingSm),
                            PopupMenuButton<String>(
                              tooltip: 'A\u00e7\u00f5es do brinquedo',
                              onSelected: (value) {
                                if (data == null) return;
                                if (value == _detailsMenuRename) {
                                  _renameToy(context, data.toy.name);
                                  return;
                                }
                                if (value == _detailsMenuCategory) {
                                  _editToyCategory(
                                    context,
                                    currentCategoryId: data.toy.categoryId,
                                  );
                                  return;
                                }
                                if (value == _detailsMenuBox) {
                                  _editToyBox(
                                    context,
                                    currentBoxId: data.toy.boxId,
                                  );
                                  return;
                                }
                                if (value == _detailsMenuDelete) {
                                  _deleteToy(context);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem<String>(
                                  value: _detailsMenuRename,
                                  child: Text('Editar nome'),
                                ),
                                PopupMenuItem<String>(
                                  value: _detailsMenuCategory,
                                  child: Text('Editar categoria'),
                                ),
                                PopupMenuItem<String>(
                                  value: _detailsMenuBox,
                                  child: Text('Editar caixa'),
                                ),
                                PopupMenuItem<String>(
                                  value: _detailsMenuDelete,
                                  child: Text('Excluir brinquedo'),
                                ),
                              ],
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: UiTokens.surface.withValues(alpha: 0.8),
                                  borderRadius:
                                      BorderRadius.circular(UiTokens.radiusLg),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.more_horiz),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UiTokens.spacingMd),
                      AppSurfaceCard(
                        padding: const EdgeInsets.all(UiTokens.spacingMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Foto',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: UiTokens.spacingMd),
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  UiTokens.radiusCard,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: photoPath == null || photoPath.trim().isEmpty
                                        ? null
                                        : () => _openPhotoViewer(
                                              context,
                                              photoPath: photoPath,
                                              title: title,
                                              boxLabel: boxLabel,
                                              categoryLabel: categoryLabel,
                                              locationFieldLabel:
                                                  locationFieldLabel,
                                              locationLabel:
                                                  effectiveLocationLabel,
                                            ),
                                    child: _photoOrPlaceholder(
                                      context,
                                      photoPath,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: UiTokens.spacingSm),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Toque na foto para abrir em destaque.',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  tooltip: 'A\u00e7\u00f5es da foto',
                                  onSelected: (value) {
                                    if (value == _photoMenuCamera) {
                                      _pick(context, ImageSource.camera);
                                      return;
                                    }
                                    if (value == _photoMenuGallery) {
                                      _pick(context, ImageSource.gallery);
                                      return;
                                    }
                                    if (value == _photoMenuRemove) {
                                      _remove(context);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem<String>(
                                      value: _photoMenuCamera,
                                      child: Text('Tirar foto'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: _photoMenuGallery,
                                      child: Text('Escolher da galeria'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: _photoMenuRemove,
                                      child: Text('Remover foto'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UiTokens.spacingMd),
                      AppSurfaceCard(
                        padding: const EdgeInsets.all(UiTokens.spacingMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informa\u00e7\u00f5es',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: UiTokens.spacingMd),
                            _InfoBlock(
                              label: 'Nome',
                              value: title,
                            ),
                            const SizedBox(height: UiTokens.spacingMd),
                            _InfoBlock(
                              label: 'Caixa',
                              value: boxLabel,
                            ),
                            const SizedBox(height: UiTokens.spacingMd),
                            _InfoBlock(
                              label: 'Categoria',
                              value: categoryLabel,
                              accent: true,
                            ),
                            const SizedBox(height: UiTokens.spacingMd),
                            _InfoBlock(
                              label: box != null
                                  ? 'Local da caixa'
                                  : 'Local sem caixa',
                              value: effectiveLocationLabel,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _InfoBlock({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: UiTokens.spacingXs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(UiTokens.spacingMd),
          decoration: BoxDecoration(
            color: accent ? UiTokens.primarySoft : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(UiTokens.radiusLg),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accent ? UiTokens.primaryStrong : colorScheme.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}
