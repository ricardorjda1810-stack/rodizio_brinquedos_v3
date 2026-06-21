import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/photo_crop_page.dart';
import 'package:rodizio_brinquedos_v3/ui/photo_viewer_page.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_category_form_options.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
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
  final PurchaseService? purchaseService;
  final int topNavigationIndex;
  final VoidCallback? onOpenHomeTab;
  final VoidCallback? onOpenRoundTab;
  final VoidCallback? onOpenWeeklyPlanning;
  final VoidCallback? onOpenToysTab;
  final VoidCallback? onOpenBoxesTab;
  final VoidCallback? onOpenSettings;

  const ToyDetailPage({
    super.key,
    required this.toyId,
    required this.toyRepository,
    this.purchaseService,
    this.topNavigationIndex = 1,
    this.onOpenHomeTab,
    this.onOpenRoundTab,
    this.onOpenWeeklyPlanning,
    this.onOpenToysTab,
    this.onOpenBoxesTab,
    this.onOpenSettings,
  });

  Widget _dropdownLabel(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

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
    await toyRepository.ensureOfficialToyFormCategories();
    if (!context.mounted) return;

    final selectedCategoryId = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String? selectedId = currentCategoryId;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar categoria'),
              content: StreamBuilder(
                stream: toyRepository.watchCategories(activeOnly: true),
                builder: (context, snapshot) {
                  final allCategories = snapshot.data ?? const [];
                  final categories = officialToyFormCategories(allCategories);
                  if (categories.isEmpty) {
                    return const Text('Nenhuma categoria oficial ativa.');
                  }

                  final currentIsOfficial =
                      categories.any((c) => c.id == currentCategoryId);
                  if (!categories.any((c) => c.id == selectedId)) {
                    selectedId = null;
                  }
                  final currentLabel = _categoryNameForId(
                    allCategories,
                    currentCategoryId,
                  );

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!currentIsOfficial && currentLabel != null) ...[
                        Text(
                          'Categoria atual: $currentLabel',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: UiTokens.spacingSm),
                      ],
                      SizedBox(
                        width: double.maxFinite,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Categoria oficial',
                          ),
                          hint: const Text('Escolha uma categoria'),
                          items: [
                            for (final c in categories)
                              DropdownMenuItem<String>(
                                value: c.id,
                                child: _dropdownLabel(toyFormCategoryName(c)),
                              ),
                          ],
                          onChanged: (value) {
                            setDialogState(() => selectedId = value);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: selectedId == null
                      ? null
                      : () => Navigator.of(ctx).pop(selectedId),
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

  String? _categoryNameForId(
    List<CategoryDefinition> categories,
    String categoryId,
  ) {
    final trimmed = categoryId.trim();
    if (trimmed.isEmpty) return null;
    for (final category in categories) {
      if (category.id == trimmed) return category.name;
    }
    return trimmed;
  }

  Future<void> _editToyBox(
    BuildContext context, {
    required String? currentBoxId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final boxes = await toyRepository.watchBoxes().first;
    if (!context.mounted) return;

    String selectedBoxSelection = currentBoxId ?? _toyBoxNoSelectionValue;
    var confirmed = false;
    if (currentBoxId != null && !boxes.any((b) => b.id == currentBoxId)) {
      selectedBoxSelection = _toyBoxNoSelectionValue;
    }

    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Editar caixa'),
            content: SizedBox(
              width: double.maxFinite,
              child: DropdownButtonFormField<String?>(
                initialValue: selectedBoxSelection,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Caixa'),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(
                    value: _toyBoxNoSelectionValue,
                    child: _dropdownLabel('Selecionar caixa'),
                  ),
                  DropdownMenuItem<String?>(
                    value: _toyBoxWithoutBoxValue,
                    child: _dropdownLabel('Sem caixa'),
                  ),
                  ...boxes.map(
                    (b) => DropdownMenuItem<String?>(
                      value: b.id,
                      child: _dropdownLabel('Caixa ${b.number} - ${b.local}'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setDialogState(
                    () =>
                        selectedBoxSelection = value ?? _toyBoxNoSelectionValue,
                  );
                },
              ),
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

                  confirmed = true;
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

    if (!confirmed) return;
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

  VoidCallback _navigationAction(BuildContext context, VoidCallback? action) {
    return action ?? () => Navigator.of(context).maybePop();
  }

  Widget _buildIpadTopNavigation(BuildContext context) {
    return AppTopNavigation(
      currentIndex: topNavigationIndex,
      onHomeTap: _navigationAction(context, onOpenHomeTab),
      onRoundTap: _navigationAction(context, onOpenRoundTab),
      onWeeklyPlanningTap: _navigationAction(context, onOpenWeeklyPlanning),
      onToysTap: _navigationAction(context, onOpenToysTab),
      onBoxesTap: _navigationAction(context, onOpenBoxesTab),
      onSettingsTap: _navigationAction(context, onOpenSettings),
    );
  }

  Widget _buildPhotoMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Ações da foto',
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
    );
  }

  Widget _buildMobileScaffold(
    BuildContext context, {
    required _ToyDetailViewData detail,
  }) {
    final data = detail.data;

    return Scaffold(
      backgroundColor: UiTokens.bg,
      appBar: AppBar(title: Text(detail.title)),
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
                            detail.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: UiTokens.spacingXs),
                          Text(
                            'Uma visão simples e organizada das informações principais.',
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
                      tooltip: 'Ações do brinquedo',
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
                          borderRadius: BorderRadius.circular(
                            UiTokens.radiusLg,
                          ),
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
                            onTap: detail.photoPath == null ||
                                    detail.photoPath!.trim().isEmpty
                                ? null
                                : () => _openPhotoViewer(
                                      context,
                                      photoPath: detail.photoPath!,
                                      title: detail.title,
                                      boxLabel: detail.boxLabel,
                                      categoryLabel: detail.categoryLabel,
                                      locationFieldLabel:
                                          detail.locationFieldLabel,
                                      locationLabel:
                                          detail.effectiveLocationLabel,
                                    ),
                            child: _photoOrPlaceholder(
                              context,
                              detail.photoPath,
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
                        _buildPhotoMenuButton(context),
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
                      'Informações',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: UiTokens.spacingMd),
                    _InfoBlock(label: 'Nome', value: detail.title),
                    const SizedBox(height: UiTokens.spacingMd),
                    _InfoBlock(label: 'Caixa', value: detail.boxLabel),
                    const SizedBox(height: UiTokens.spacingMd),
                    _InfoBlock(
                      label: 'Categoria',
                      value: detail.categoryLabel,
                      accent: true,
                    ),
                    const SizedBox(height: UiTokens.spacingMd),
                    _InfoBlock(
                      label: detail.box != null
                          ? 'Local da caixa'
                          : 'Local sem caixa',
                      value: detail.effectiveLocationLabel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIpadScaffold(
    BuildContext context, {
    required _ToyDetailViewData detail,
  }) {
    final bottomPadding = AppBottomNavigation.reservedScrollPadding(context);

    return Scaffold(
      backgroundColor: _ToyDetailIpadPalette.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(24, 18, 24, bottomPadding),
          physics: const BouncingScrollPhysics(),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1032),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIpadTopNavigation(context),
                    const SizedBox(height: 18),
                    _ToyDetailIpadHeader(
                      detail: detail,
                      onEdit: detail.data == null
                          ? null
                          : () => _renameToy(context, detail.data!.toy.name),
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final gap = constraints.maxWidth >= 980 ? 22.0 : 18.0;
                        final leftWidth = (constraints.maxWidth - gap) * 0.43;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: leftWidth.clamp(360.0, 500.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ToyDetailIpadPhotoCard(
                                    detail: detail,
                                    photo: _photoOrPlaceholder(
                                      context,
                                      detail.photoPath,
                                    ),
                                    onOpenPhoto: detail.photoPath == null ||
                                            detail.photoPath!.trim().isEmpty
                                        ? null
                                        : () => _openPhotoViewer(
                                              context,
                                              photoPath: detail.photoPath!,
                                              title: detail.title,
                                              boxLabel: detail.boxLabel,
                                              categoryLabel:
                                                  detail.categoryLabel,
                                              locationFieldLabel:
                                                  detail.locationFieldLabel,
                                              locationLabel:
                                                  detail.effectiveLocationLabel,
                                            ),
                                    photoMenu: _buildPhotoMenuButton(context),
                                  ),
                                  const SizedBox(height: 16),
                                  _ToyDetailIpadPreviewCard(detail: detail),
                                ],
                              ),
                            ),
                            SizedBox(width: gap),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ToyDetailIpadOrganizationCard(
                                    detail: detail,
                                    onEditCategory: detail.data == null
                                        ? null
                                        : () => _editToyCategory(
                                              context,
                                              currentCategoryId:
                                                  detail.data!.toy.categoryId,
                                            ),
                                    onEditBox: detail.data == null
                                        ? null
                                        : () => _editToyBox(
                                              context,
                                              currentBoxId:
                                                  detail.data!.toy.boxId,
                                            ),
                                  ),
                                  const SizedBox(height: 16),
                                  _ToyDetailIpadRotationCard(detail: detail),
                                  const SizedBox(height: 16),
                                  _ToyDetailIpadActionsCard(
                                    detail: detail,
                                    onRename: detail.data == null
                                        ? null
                                        : () => _renameToy(
                                              context,
                                              detail.data!.toy.name,
                                            ),
                                    onEditCategory: detail.data == null
                                        ? null
                                        : () => _editToyCategory(
                                              context,
                                              currentCategoryId:
                                                  detail.data!.toy.categoryId,
                                            ),
                                    onEditBox: detail.data == null
                                        ? null
                                        : () => _editToyBox(
                                              context,
                                              currentBoxId:
                                                  detail.data!.toy.boxId,
                                            ),
                                    onPhoto: () => _pick(
                                      context,
                                      ImageSource.gallery,
                                    ),
                                    onDelete: detail.data == null
                                        ? null
                                        : () => _deleteToy(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryDefinition>>(
      stream: toyRepository.watchCategories(),
      builder: (context, categoriesSnapshot) {
        final categories =
            categoriesSnapshot.data ?? const <CategoryDefinition>[];

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
            final detail = _ToyDetailViewData(
              data: data,
              title: title,
              photoPath: photoPath,
              box: box,
              boxLabel: boxLabel,
              categoryLabel: categoryLabel,
              effectiveLocationLabel: effectiveLocationLabel,
              locationFieldLabel: locationFieldLabel,
            );
            final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

            if (isTablet) {
              return _buildIpadScaffold(context, detail: detail);
            }

            return _buildMobileScaffold(context, detail: detail);
          },
        );
      },
    );
  }
}

class _ToyDetailViewData {
  final ToyWithBox? data;
  final String title;
  final String? photoPath;
  final Boxe? box;
  final String boxLabel;
  final String categoryLabel;
  final String effectiveLocationLabel;
  final String locationFieldLabel;

  const _ToyDetailViewData({
    required this.data,
    required this.title,
    required this.photoPath,
    required this.box,
    required this.boxLabel,
    required this.categoryLabel,
    required this.effectiveLocationLabel,
    required this.locationFieldLabel,
  });

  bool get hasPhoto => (photoPath ?? '').trim().isNotEmpty;

  bool get hasCompleteOrganization {
    return categoryLabel != 'Sem categoria' &&
        boxLabel != 'Sem caixa' &&
        effectiveLocationLabel != 'Sem local';
  }
}

class _ToyDetailIpadPalette {
  _ToyDetailIpadPalette._();

  static const Color bg = Color(0xFFFDF7F0);
  static const Color card = Colors.white;
  static const Color orange = Color(0xFFF97316);
  static const Color orangeDark = Color(0xFFC2410C);
  static const Color orangeLight = Color(0xFFFFF3E7);
  static const Color orangeBorder = Color(0xFFFED7AA);
  static const Color text = Color(0xFF25180A);
  static const Color textMid = Color(0xFF6B4F30);
  static const Color textMuted = Color(0xFFA8896A);
  static const Color border = Color(0xFFF3E2D0);
  static const Color photoBg = Color(0xFFF7EDE2);
  static const Color green = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFEAFBF0);
  static const Color greenBorder = Color(0xFFBBF7D0);
  static const Color red = Color(0xFFB91C1C);
  static const Color redLight = Color(0xFFFFF1F2);
  static const Color redBorder = Color(0xFFFECACA);
}

class _ToyDetailIpadSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ToyDetailIpadSurface({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _ToyDetailIpadPalette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _ToyDetailIpadPalette.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140C1A12),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ToyDetailIpadHeader extends StatelessWidget {
  final _ToyDetailViewData detail;
  final VoidCallback? onEdit;
  final VoidCallback onBack;

  const _ToyDetailIpadHeader({
    required this.detail,
    required this.onEdit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return _ToyDetailIpadSurface(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  _ToyDetailIpadPalette.orange,
                  Color(0xFFFBBF24),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33F97316),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.toys_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RODÍZIO DE BRINQUEDOS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _ToyDetailIpadPalette.orange,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  detail.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textTitle.copyWith(
                    color: _ToyDetailIpadPalette.text,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${detail.categoryLabel} · ${detail.effectiveLocationLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _ToyDetailIpadPalette.textMid,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Voltar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _ToyDetailIpadPalette.orangeDark,
              side: const BorderSide(color: _ToyDetailIpadPalette.orangeBorder),
              minimumSize: const Size(128, 52),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Editar'),
            style: FilledButton.styleFrom(
              backgroundColor: _ToyDetailIpadPalette.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(128, 52),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToyDetailIpadPhotoCard extends StatelessWidget {
  final _ToyDetailViewData detail;
  final Widget photo;
  final VoidCallback? onOpenPhoto;
  final Widget photoMenu;

  const _ToyDetailIpadPhotoCard({
    required this.detail,
    required this.photo,
    required this.onOpenPhoto,
    required this.photoMenu,
  });

  @override
  Widget build(BuildContext context) {
    return _ToyDetailIpadSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Foto do brinquedo',
                  style: UiTokens.textSectionTitle.copyWith(
                    color: _ToyDetailIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              photoMenu,
            ],
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Material(
                color: _ToyDetailIpadPalette.photoBg,
                child: InkWell(
                  onTap: onOpenPhoto,
                  child: photo,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                detail.hasPhoto
                    ? Icons.zoom_out_map_rounded
                    : Icons.add_photo_alternate_outlined,
                color: _ToyDetailIpadPalette.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  detail.hasPhoto
                      ? 'Toque na foto para abrir em destaque.'
                      : 'Adicione uma foto para facilitar a identificação.',
                  style: UiTokens.textCaption.copyWith(
                    color: _ToyDetailIpadPalette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToyDetailIpadPreviewCard extends StatelessWidget {
  final _ToyDetailViewData detail;

  const _ToyDetailIpadPreviewCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return _ToyDetailIpadSurface(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _ToyDetailIpadPalette.orangeLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _ToyDetailIpadPalette.orangeBorder),
            ),
            child: const Icon(
              Icons.view_agenda_outlined,
              color: _ToyDetailIpadPalette.orange,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prévia no catálogo',
                  style: UiTokens.textCaption.copyWith(
                    color: _ToyDetailIpadPalette.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textBody.copyWith(
                    color: _ToyDetailIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  detail.categoryLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _ToyDetailIpadPalette.orangeDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToyDetailIpadOrganizationCard extends StatelessWidget {
  final _ToyDetailViewData detail;
  final VoidCallback? onEditCategory;
  final VoidCallback? onEditBox;

  const _ToyDetailIpadOrganizationCard({
    required this.detail,
    required this.onEditCategory,
    required this.onEditBox,
  });

  @override
  Widget build(BuildContext context) {
    return _ToyDetailIpadSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ToyDetailIpadSectionTitle(
            icon: Icons.inventory_2_outlined,
            title: 'Organização',
            subtitle: 'Onde este brinquedo fica guardado',
          ),
          const SizedBox(height: 18),
          _ToyDetailIpadInfoRow(
            label: 'Caixa',
            value: detail.boxLabel,
            icon: Icons.inventory_2_outlined,
            onTap: onEditBox,
          ),
          const Divider(height: 22, color: _ToyDetailIpadPalette.border),
          _ToyDetailIpadInfoRow(
            label: detail.locationFieldLabel,
            value: detail.effectiveLocationLabel,
            icon: Icons.place_outlined,
          ),
          const Divider(height: 22, color: _ToyDetailIpadPalette.border),
          _ToyDetailIpadInfoRow(
            label: 'Categoria',
            value: detail.categoryLabel,
            icon: Icons.category_outlined,
            onTap: onEditCategory,
            accent: true,
          ),
          const Divider(height: 22, color: _ToyDetailIpadPalette.border),
          _ToyDetailIpadInfoRow(
            label: 'Estado',
            value: detail.hasCompleteOrganization
                ? 'Organização completa'
                : 'Precisa revisar',
            icon: detail.hasCompleteOrganization
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            semantic: detail.hasCompleteOrganization,
          ),
        ],
      ),
    );
  }
}

class _ToyDetailIpadRotationCard extends StatelessWidget {
  final _ToyDetailViewData detail;

  const _ToyDetailIpadRotationCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return _ToyDetailIpadSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ToyDetailIpadSectionTitle(
            icon: Icons.autorenew_rounded,
            title: 'No rodízio',
            subtitle: 'Status usado pelas sugestões reais do app',
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _ToyDetailIpadPalette.greenLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _ToyDetailIpadPalette.greenBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: _ToyDetailIpadPalette.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disponível para rodadas',
                        style: UiTokens.textBody.copyWith(
                          color: _ToyDetailIpadPalette.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'As sugestões usam a categoria, caixa e local cadastrados.',
                        style: UiTokens.textCaption.copyWith(
                          color: _ToyDetailIpadPalette.textMid,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Este cadastro não tem pausa, doação ou previsão individual nesta versão.',
            style: UiTokens.textCaption.copyWith(
              color: _ToyDetailIpadPalette.textMuted,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToyDetailIpadActionsCard extends StatelessWidget {
  final _ToyDetailViewData detail;
  final VoidCallback? onRename;
  final VoidCallback? onEditCategory;
  final VoidCallback? onEditBox;
  final VoidCallback onPhoto;
  final VoidCallback? onDelete;

  const _ToyDetailIpadActionsCard({
    required this.detail,
    required this.onRename,
    required this.onEditCategory,
    required this.onEditBox,
    required this.onPhoto,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _ToyDetailIpadSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ToyDetailIpadSectionTitle(
            icon: Icons.touch_app_outlined,
            title: 'Ações',
            subtitle: 'Atalhos de edição deste brinquedo',
          ),
          const SizedBox(height: 14),
          _ToyDetailIpadActionRow(
            icon: Icons.edit_note_rounded,
            title: 'Editar nome',
            subtitle: detail.title,
            onTap: onRename,
          ),
          const Divider(height: 16, color: _ToyDetailIpadPalette.border),
          _ToyDetailIpadActionRow(
            icon: Icons.category_outlined,
            title: 'Editar categoria',
            subtitle: detail.categoryLabel,
            onTap: onEditCategory,
          ),
          const Divider(height: 16, color: _ToyDetailIpadPalette.border),
          _ToyDetailIpadActionRow(
            icon: Icons.inventory_2_outlined,
            title: 'Editar caixa',
            subtitle: detail.boxLabel,
            onTap: onEditBox,
          ),
          const Divider(height: 16, color: _ToyDetailIpadPalette.border),
          _ToyDetailIpadActionRow(
            icon: Icons.photo_camera_outlined,
            title: 'Alterar foto',
            subtitle: detail.hasPhoto ? 'Foto cadastrada' : 'Sem foto',
            onTap: onPhoto,
          ),
          const SizedBox(height: 18),
          _ToyDetailIpadActionRow(
            icon: Icons.delete_outline_rounded,
            title: 'Excluir brinquedo',
            subtitle: 'Remove o brinquedo do catálogo',
            onTap: onDelete,
            destructive: true,
          ),
        ],
      ),
    );
  }
}

class _ToyDetailIpadSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ToyDetailIpadSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _ToyDetailIpadPalette.orangeLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _ToyDetailIpadPalette.orangeBorder),
          ),
          child: Icon(icon, color: _ToyDetailIpadPalette.orange, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: UiTokens.textSectionTitle.copyWith(
                  color: _ToyDetailIpadPalette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textCaption.copyWith(
                  color: _ToyDetailIpadPalette.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToyDetailIpadInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool accent;
  final bool semantic;

  const _ToyDetailIpadInfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.accent = false,
    this.semantic = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = semantic
        ? _ToyDetailIpadPalette.green
        : accent
            ? _ToyDetailIpadPalette.orange
            : _ToyDetailIpadPalette.textMid;
    final background = semantic
        ? _ToyDetailIpadPalette.greenLight
        : accent
            ? _ToyDetailIpadPalette.orangeLight
            : _ToyDetailIpadPalette.photoBg;
    final border = semantic
        ? _ToyDetailIpadPalette.greenBorder
        : accent
            ? _ToyDetailIpadPalette.orangeBorder
            : _ToyDetailIpadPalette.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: Icon(icon, color: foreground, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: UiTokens.textCaption.copyWith(
                      color: _ToyDetailIpadPalette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UiTokens.textBody.copyWith(
                      color: _ToyDetailIpadPalette.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: _ToyDetailIpadPalette.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToyDetailIpadActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  const _ToyDetailIpadActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        destructive ? _ToyDetailIpadPalette.red : _ToyDetailIpadPalette.orange;
    final background = destructive
        ? _ToyDetailIpadPalette.redLight
        : _ToyDetailIpadPalette.orangeLight;
    final border = destructive
        ? _ToyDetailIpadPalette.redBorder
        : _ToyDetailIpadPalette.orangeBorder;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: border),
                ),
                child: Icon(icon, color: foreground, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textBody.copyWith(
                        color: destructive
                            ? _ToyDetailIpadPalette.red
                            : _ToyDetailIpadPalette.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textCaption.copyWith(
                        color: _ToyDetailIpadPalette.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                destructive
                    ? Icons.warning_amber_rounded
                    : Icons.chevron_right_rounded,
                color: destructive
                    ? _ToyDetailIpadPalette.red
                    : _ToyDetailIpadPalette.textMuted,
              ),
            ],
          ),
        ),
      ),
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
            color: accent
                ? UiTokens.primarySoft
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(UiTokens.radiusLg),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      accent ? UiTokens.primaryStrong : colorScheme.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}
