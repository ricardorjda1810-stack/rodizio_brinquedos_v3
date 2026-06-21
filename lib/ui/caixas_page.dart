// lib/ui/caixas_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/features/brinquedos/brinquedos_catalog_state.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/box_create_page.dart';
import 'package:rodizio_brinquedos_v3/ui/locations_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/photo_crop_page.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/empty_state.dart';

class CaixasPage extends StatefulWidget {
  final ToyRepository toyRepository;
  final SettingsRepository settingsRepository;
  final PurchaseService? purchaseService;
  final void Function(String boxId) onOpenBrinquedosForBox;
  final VoidCallback? onOpenHomeTab;
  final VoidCallback? onOpenRoundTab;
  final VoidCallback? onOpenWeeklyPlanning;
  final VoidCallback? onOpenToysTab;
  final VoidCallback? onOpenBoxesTab;
  final VoidCallback? onOpenSettings;

  const CaixasPage({
    super.key,
    required this.toyRepository,
    required this.settingsRepository,
    this.purchaseService,
    required this.onOpenBrinquedosForBox,
    this.onOpenHomeTab,
    this.onOpenRoundTab,
    this.onOpenWeeklyPlanning,
    this.onOpenToysTab,
    this.onOpenBoxesTab,
    this.onOpenSettings,
  });

  @override
  State<CaixasPage> createState() => _CaixasPageState();
}

class _CaixasPageState extends State<CaixasPage> {
  String? _expandedBoxId;

  int _responsiveColumnCount(double maxWidth) {
    if (maxWidth >= 1080) return 3;
    if (maxWidth >= 560) return 2;
    return 1;
  }

  String _boxTitle(Boxe box) {
    final local = box.local.trim();
    if (local.isEmpty) return 'Caixa ${box.number}';
    return 'Caixa ${box.number} - $local';
  }

  Future<void> _openAddBoxPage(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BoxCreatePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
          topNavigationIndex: 2,
          onOpenHomeTab: widget.onOpenHomeTab,
          onOpenRoundTab: widget.onOpenRoundTab,
          onOpenWeeklyPlanning: widget.onOpenWeeklyPlanning,
          onOpenToysTab: widget.onOpenToysTab,
          onOpenBoxesTab: widget.onOpenBoxesTab,
          onOpenSettings: widget.onOpenSettings,
        ),
      ),
    );
  }

  Future<void> _openLocationsPage(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocationsManagePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
          topNavigationIndex: 2,
          onOpenHomeTab: widget.onOpenHomeTab,
          onOpenRoundTab: widget.onOpenRoundTab,
          onOpenWeeklyPlanning: widget.onOpenWeeklyPlanning,
          onOpenToysTab: widget.onOpenToysTab,
          onOpenBoxesTab: widget.onOpenBoxesTab,
          onOpenSettings: widget.onOpenSettings,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String boxId,
    String label,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir caixa?'),
        content: Text(
          '"$label" sera apagada e os brinquedos ficarao sem caixa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: UiTokens.danger,
              foregroundColor: UiTokens.surface,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await AppFeedback(widget.settingsRepository).onDeleteConfirmed();
      await widget.toyRepository.deleteBox(boxId: boxId);
      if (!mounted) return;
      if (_expandedBoxId == boxId) {
        setState(() => _expandedBoxId = null);
      }
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
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, imageQuality: 85);
      if (image == null || !context.mounted) return;

      final croppedPath = await PhotoCropPage.open(
        context,
        sourcePath: image.path,
      );
      if (croppedPath == null || !context.mounted) return;

      await widget.toyRepository.saveBoxPhoto(
        boxId: box.id,
        croppedPhotoPath: croppedPath,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar foto da caixa: $e')),
      );
    }
  }

  Future<void> _editBoxLocal(BuildContext context, Boxe box) async {
    final locations = await widget.toyRepository.watchLocations().first;
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
            decoration: const InputDecoration(labelText: 'Local'),
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
                final selected = locations.firstWhere(
                  (l) => l.id == selectedLocationId,
                );
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
      await widget.toyRepository.updateBoxLocal(boxId: box.id, local: result);
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
          inputFormatters: [LengthLimitingTextInputFormatter(120)],
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
      await widget.toyRepository.updateBoxNotes(boxId: box.id, notes: result);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar informacoes da caixa: $e')),
      );
    }
  }

  void _toggleExpandedBox(String boxId) {
    setState(() {
      _expandedBoxId = _expandedBoxId == boxId ? null : boxId;
    });
  }

  void _openToyDetail(BuildContext context, String toyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToyDetailPage(
          toyId: toyId,
          toyRepository: widget.toyRepository,
          purchaseService: widget.purchaseService,
          topNavigationIndex: 2,
          onOpenHomeTab: widget.onOpenHomeTab,
          onOpenRoundTab: widget.onOpenRoundTab,
          onOpenWeeklyPlanning: widget.onOpenWeeklyPlanning,
          onOpenToysTab: widget.onOpenToysTab,
          onOpenBoxesTab: widget.onOpenBoxesTab,
          onOpenSettings: widget.onOpenSettings,
        ),
      ),
    );
  }

  Future<void> _assignToyToBox(
    BuildContext context,
    ToyCatalogItem item,
    List<Boxe> boxes,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (boxes.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Crie uma caixa antes de atribuir.')),
      );
      return;
    }

    var selectedBoxId = boxes.first.id;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Atribuir brinquedo'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedBoxId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Caixa'),
                items: [
                  for (final box in boxes)
                    DropdownMenuItem<String>(
                      value: box.id,
                      child: Text(
                        _boxTitle(box),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() => selectedBoxId = value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(selectedBoxId),
                  child: const Text('Atribuir'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result == item.toy.boxId) return;

    try {
      await widget.toyRepository.setToyBox(toyId: item.toy.id, boxId: result);
      if (!context.mounted) return;
      messenger
          .showSnackBar(const SnackBar(content: Text('Caixa atualizada.')));
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao atualizar caixa: $e')),
      );
    }
  }

  Widget _buildToyList(List<ToyCatalogItem> boxItems) {
    if (boxItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          UiTokens.s,
          0,
          UiTokens.s,
          UiTokens.s,
        ),
        child: Text(
          'Nenhum brinquedo nesta caixa.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiTokens.s,
        UiTokens.xs,
        UiTokens.s,
        UiTokens.s,
      ),
      child: Column(
        children: List<Widget>.generate(boxItems.length, (index) {
          final item = boxItems[index];
          final toyName =
              item.toy.name.trim().isEmpty ? 'Sem nome' : item.toy.name.trim();
          final categoryName = item.category?.name.trim();
          final subtitle = (categoryName == null || categoryName.isEmpty)
              ? 'Brinquedo da caixa'
              : categoryName;

          return Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(UiTokens.radiusButton),
                onTap: () => _openToyDetail(context, item.toy.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiTokens.xs,
                    vertical: UiTokens.s,
                  ),
                  child: Row(
                    children: [
                      _ToyThumb(path: item.toy.photoPath),
                      const SizedBox(width: UiTokens.s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              if (index < boxItems.length - 1)
                const Divider(height: 1, thickness: 0.6),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBoxCard(
    BuildContext context, {
    required Boxe box,
    required int count,
    required List<ToyCatalogItem> boxItems,
  }) {
    final title = _boxTitle(box);
    final hasPhoto = (box.photoPath ?? '').trim().isNotEmpty;
    final notes = (box.notes ?? '').trim();
    final toyCountLabel = count == 1 ? '1 brinquedo' : '$count brinquedos';
    final subtitle = notes.isEmpty ? toyCountLabel : '$toyCountLabel\n$notes';
    final isExpanded = _expandedBoxId == box.id;

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiTokens.radiusCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => _toggleExpandedBox(box.id),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    (box.photoPath ?? '').trim().isEmpty
                        ? Container(
                            color: const Color(0xFFF4E9DA),
                            child: const Center(
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 28,
                                color: Color(0xFFA8896A),
                              ),
                            ),
                          )
                        : Image.file(
                            File((box.photoPath ?? '').trim()),
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFF4E9DA),
                              child: const Center(
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 28,
                                  color: Color(0xFFA8896A),
                                ),
                              ),
                            ),
                          ),
                    Positioned(
                      left: UiTokens.spacingSm,
                      right: UiTokens.spacingSm,
                      bottom: UiTokens.spacingSm,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UiTokens.s,
                            vertical: UiTokens.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.92),
                            borderRadius:
                                BorderRadius.circular(UiTokens.radiusButton),
                          ),
                          child: Text(
                            isExpanded
                                ? 'Ocultar brinquedos'
                                : 'Ver brinquedos',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: UiTokens.spacingSm,
                      top: UiTokens.spacingSm,
                      child: PopupMenuButton<String>(
                        tooltip: 'A\u00e7\u00f5es da caixa',
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
                          if (value == 'open_toys') {
                            widget.onOpenBrinquedosForBox(box.id);
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
                            child: Text('Editar informa\u00e7\u00f5es'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'open_toys',
                            child: Text('Abrir em Brinquedos'),
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
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.more_vert, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UiTokens.spacingMd,
                UiTokens.spacingMd,
                UiTokens.spacingMd,
                UiTokens.spacingXs,
              ),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: UiTokens.spacingMd),
              child: Text(
                subtitle,
                maxLines: isExpanded ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UiTokens.spacingMd,
                UiTokens.spacingSm,
                UiTokens.spacingMd,
                UiTokens.spacingSm,
              ),
              child: Wrap(
                spacing: UiTokens.spacingXs,
                runSpacing: UiTokens.spacingXs,
                children: [
                  _BoxMetaChip(
                    icon: Icons.location_on_outlined,
                    label: box.local.trim().isEmpty
                        ? 'Sem local'
                        : box.local.trim(),
                  ),
                  _BoxMetaChip(
                    icon: Icons.toys_outlined,
                    label: toyCountLabel,
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildToyList(boxItems),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIpadScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: _BoxesIpadPalette.bg,
      body: SafeArea(
        child: StreamBuilder<List<Boxe>>(
          stream: widget.toyRepository.watchBoxes(),
          builder: (context, boxesSnapshot) {
            final boxes = boxesSnapshot.data ?? const <Boxe>[];
            if (boxesSnapshot.connectionState == ConnectionState.waiting &&
                boxes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return StreamBuilder<List<ToyCatalogItem>>(
              stream: widget.toyRepository.watchCatalog(),
              builder: (context, catalogSnapshot) {
                if (catalogSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    !catalogSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = catalogSnapshot.data ?? const <ToyCatalogItem>[];
                return StreamBuilder<List<LocationDefinition>>(
                  stream: widget.toyRepository.watchLocations(),
                  builder: (context, locationsSnapshot) {
                    final locations =
                        locationsSnapshot.data ?? const <LocationDefinition>[];
                    return _buildIpadContent(
                      context,
                      boxes: boxes,
                      items: items,
                      locations: locations,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildIpadContent(
    BuildContext context, {
    required List<Boxe> boxes,
    required List<ToyCatalogItem> items,
    required List<LocationDefinition> locations,
  }) {
    final bottomPadding = AppBottomNavigation.reservedScrollPadding(context);
    final sortedBoxes = [...boxes]
      ..sort((a, b) => a.number.compareTo(b.number));
    final toysByBoxId = <String, List<ToyCatalogItem>>{};
    for (final item in items) {
      final boxId = item.toy.boxId;
      if (boxId == null) continue;
      toysByBoxId.putIfAbsent(boxId, () => <ToyCatalogItem>[]).add(item);
    }

    final unboxed = items.where((item) => item.toy.boxId == null).toList();
    final activeBoxes =
        sortedBoxes.where((box) => (toysByBoxId[box.id] ?? []).isNotEmpty);
    final usedLocations = <String>{
      for (final box in sortedBoxes)
        if (box.local.trim().isNotEmpty) box.local.trim(),
      for (final item in unboxed)
        if ((item.toy.locationText ?? '').trim().isNotEmpty)
          (item.toy.locationText ?? '').trim(),
    };
    final locationCount = usedLocations.isNotEmpty
        ? usedLocations.length
        : locations.where((location) => location.name.trim().isNotEmpty).length;
    final summary = _BoxesIpadSummary(
      boxCount: sortedBoxes.length,
      toyCount: items.length,
      locationCount: locationCount,
      activeBoxCount: activeBoxes.length,
      unboxedCount: unboxed.length,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnsHeight =
            (constraints.maxHeight - bottomPadding - 24 - 142 - 18)
                .clamp(760.0, 880.0)
                .toDouble();

        return ListView(
          padding: EdgeInsets.fromLTRB(28, 24, 28, bottomPadding),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1032),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BoxesIpadHeader(
                      summary: summary,
                      onNewBox: () => _openAddBoxPage(context),
                      onOpenLocations: () => _openLocationsPage(context),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: columnsHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _BoxesIpadMainPanel(
                              boxes: sortedBoxes,
                              toysByBoxId: toysByBoxId,
                              unboxed: unboxed,
                              summary: summary,
                              onOpenBox: widget.onOpenBrinquedosForBox,
                              onOpenUnboxed: () =>
                                  widget.onOpenBrinquedosForBox(
                                BrinquedosCatalogState.boxFilterNone,
                              ),
                              onNewBox: () => _openAddBoxPage(context),
                            ),
                          ),
                          const SizedBox(width: 18),
                          SizedBox(
                            width: 332,
                            child: _BoxesIpadSideColumn(
                              boxes: sortedBoxes,
                              unboxed: unboxed,
                              summary: summary,
                              onAssignToy: (item) =>
                                  _assignToyToBox(context, item, sortedBoxes),
                              onOpenToy: (item) =>
                                  _openToyDetail(context, item.toy.id),
                              onNewBox: () => _openAddBoxPage(context),
                              onOpenAllToys: () =>
                                  widget.onOpenBrinquedosForBox(
                                BrinquedosCatalogState.boxFilterAll,
                              ),
                              onOpenUnboxed: () =>
                                  widget.onOpenBrinquedosForBox(
                                BrinquedosCatalogState.boxFilterNone,
                              ),
                              onOpenLocations: () =>
                                  _openLocationsPage(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIpad = MediaQuery.sizeOf(context).shortestSide >= 600;
    if (isIpad) return _buildIpadScaffold(context);

    final bottomNavigationReserve =
        AppBottomNavigation.reservedScrollPadding(context);

    return Scaffold(
      backgroundColor: UiTokens.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UiTokens.m),
          child: StreamBuilder<List<Boxe>>(
            stream: widget.toyRepository.watchBoxes(),
            builder: (context, boxesSnapshot) {
              final boxes = boxesSnapshot.data ?? const <Boxe>[];

              if (boxesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (boxes.isEmpty) {
                return EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Nenhuma caixa cadastrada',
                  message:
                      'Crie a primeira caixa para organizar os brinquedos da casa com mais leveza.',
                  actionLabel: 'Criar caixa',
                  onAction: () => _openAddBoxPage(context),
                );
              }

              return StreamBuilder<List<ToyCatalogItem>>(
                stream: widget.toyRepository.watchCatalog(),
                builder: (context, catalogSnapshot) {
                  if (catalogSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !catalogSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items =
                      catalogSnapshot.data ?? const <ToyCatalogItem>[];
                  final toyCountByBoxId = <String, int>{};
                  final toysByBoxId = <String, List<ToyCatalogItem>>{};
                  for (final item in items) {
                    final boxId = item.toy.boxId;
                    if (boxId == null) continue;
                    toyCountByBoxId[boxId] = (toyCountByBoxId[boxId] ?? 0) + 1;
                    toysByBoxId
                        .putIfAbsent(boxId, () => <ToyCatalogItem>[])
                        .add(item);
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = _responsiveColumnCount(constraints.maxWidth);
                      final totalSpacing = UiTokens.s * (cols - 1);
                      final tileWidth =
                          (constraints.maxWidth - totalSpacing) / cols;

                      return SingleChildScrollView(
                        padding:
                            EdgeInsets.only(bottom: bottomNavigationReserve),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSurfaceCard(
                              padding: const EdgeInsets.all(UiTokens.spacingMd),
                              color: const Color(0xFFFFF5E8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Caixas da casa',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: UiTokens.spacingXs),
                                  Text(
                                    'Visualize onde cada grupo est\u00e1 guardado e abra os brinquedos de forma mais organizada.',
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
                            const SizedBox(height: UiTokens.spacingMd),
                            Wrap(
                              spacing: UiTokens.s,
                              runSpacing: UiTokens.s,
                              children:
                                  List<Widget>.generate(boxes.length, (i) {
                                final box = boxes[i];
                                final count = toyCountByBoxId[box.id] ?? 0;
                                final boxItems = toysByBoxId[box.id] ??
                                    const <ToyCatalogItem>[];
                                return SizedBox(
                                  width: tileWidth,
                                  child: _buildBoxCard(
                                    context,
                                    box: box,
                                    count: count,
                                    boxItems: boxItems,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
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
        label: const Text('Criar caixa'),
      ),
    );
  }
}

class _BoxesIpadSummary {
  final int boxCount;
  final int toyCount;
  final int locationCount;
  final int activeBoxCount;
  final int unboxedCount;

  const _BoxesIpadSummary({
    required this.boxCount,
    required this.toyCount,
    required this.locationCount,
    required this.activeBoxCount,
    required this.unboxedCount,
  });
}

class _BoxesIpadPalette {
  _BoxesIpadPalette._();

  static const Color bg = Color(0xFFFDF7F0);
  static const Color card = Colors.white;
  static const Color orange = Color(0xFFF97316);
  static const Color orangeDark = Color(0xFFC2410C);
  static const Color orangeLight = Color(0xFFFFF5E8);
  static const Color orangeBorder = Color(0xFFFDDCBA);
  static const Color text = Color(0xFF25180A);
  static const Color textMid = Color(0xFF6B4F30);
  static const Color textMuted = Color(0xFFA8896A);
  static const Color border = Color(0x1FB98750);
  static const Color photoBg = Color(0xFFF4E9DA);
}

class _BoxesIpadSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _BoxesIpadSurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _BoxesIpadPalette.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12AA6E32),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
          BoxShadow(color: Color(0x0EAA6E32), spreadRadius: 1),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _BoxesIpadHeader extends StatelessWidget {
  final _BoxesIpadSummary summary;
  final VoidCallback onNewBox;
  final VoidCallback onOpenLocations;

  const _BoxesIpadHeader({
    required this.summary,
    required this.onNewBox,
    required this.onOpenLocations,
  });

  @override
  Widget build(BuildContext context) {
    return _BoxesIpadSurface(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_BoxesIpadPalette.orange, Color(0xFFFBBF24)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4DF97316),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RODÍZIO DE BRINQUEDOS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _BoxesIpadPalette.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Caixas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textTitle.copyWith(
                    color: _BoxesIpadPalette.text,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Veja onde os brinquedos ficam guardados.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _BoxesIpadPalette.textMuted,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          _BoxesIpadHeaderCount(summary: summary),
          const SizedBox(width: 14),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onNewBox,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Nova caixa'),
                style: FilledButton.styleFrom(
                  backgroundColor: _BoxesIpadPalette.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(146, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  textStyle: UiTokens.textButton.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  elevation: 4,
                  shadowColor: const Color(0x59F97316),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onOpenLocations,
                icon: const Icon(Icons.place_outlined, size: 18),
                label: const Text('Ver locais'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _BoxesIpadPalette.orangeLight,
                  foregroundColor: _BoxesIpadPalette.orangeDark,
                  side: const BorderSide(
                    color: _BoxesIpadPalette.orangeBorder,
                    width: 1.5,
                  ),
                  minimumSize: const Size(132, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  textStyle: UiTokens.textButton.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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

class _BoxesIpadHeaderCount extends StatelessWidget {
  final _BoxesIpadSummary summary;

  const _BoxesIpadHeaderCount({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 102),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: _BoxesIpadPalette.orangeLight,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _BoxesIpadPalette.orangeBorder, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${summary.boxCount}',
            style: UiTokens.textTitle.copyWith(
              color: _BoxesIpadPalette.orange,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            summary.boxCount == 1 ? 'caixa' : 'caixas',
            maxLines: 1,
            style: UiTokens.textMicro.copyWith(
              color: _BoxesIpadPalette.textMid,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxesIpadMainPanel extends StatelessWidget {
  final List<Boxe> boxes;
  final Map<String, List<ToyCatalogItem>> toysByBoxId;
  final List<ToyCatalogItem> unboxed;
  final _BoxesIpadSummary summary;
  final ValueChanged<String> onOpenBox;
  final VoidCallback onOpenUnboxed;
  final VoidCallback onNewBox;

  const _BoxesIpadMainPanel({
    required this.boxes,
    required this.toysByBoxId,
    required this.unboxed,
    required this.summary,
    required this.onOpenBox,
    required this.onOpenUnboxed,
    required this.onNewBox,
  });

  @override
  Widget build(BuildContext context) {
    final organized = summary.toyCount - summary.unboxedCount;
    final containerLabel = summary.boxCount == 1 ? 'container' : 'containers';
    final toyLabel =
        organized == 1 ? 'brinquedo organizado' : 'brinquedos organizados';
    final subtitle =
        '${summary.boxCount} $containerLabel · $organized $toyLabel · ${summary.unboxedCount} sem caixa';

    return _BoxesIpadSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minhas caixas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textSectionTitle.copyWith(
                    color: _BoxesIpadPalette.text,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _BoxesIpadPalette.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _BoxesIpadPill(
                      icon: Icons.inventory_2_outlined,
                      label:
                          '${summary.activeBoxCount} ${summary.activeBoxCount == 1 ? 'caixa ativa' : 'caixas ativas'}',
                      foreground: _BoxesIpadPalette.orange,
                      background: _BoxesIpadPalette.orangeLight,
                      border: _BoxesIpadPalette.orangeBorder,
                    ),
                    _BoxesIpadPill(
                      icon: Icons.category_outlined,
                      label: '${summary.unboxedCount} sem caixa',
                      foreground: const Color(0xFF2563EB),
                      background: const Color(0xFFEFF6FF),
                      border: const Color(0xFFBFDBFE),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _BoxesIpadPalette.border),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              child: boxes.isEmpty && unboxed.isEmpty
                  ? _BoxesIpadEmptyBoxes(onNewBox: onNewBox)
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (final box in boxes) ...[
                          _BoxesIpadBoxRow(
                            title: _boxTitleForDisplay(box),
                            subtitle: box.local.trim().isEmpty
                                ? 'Sem local definido'
                                : box.local.trim(),
                            countLabel: _toyCountLabel(
                              toysByBoxId[box.id]?.length ?? 0,
                            ),
                            icon: Icons.inventory_2_outlined,
                            toys:
                                toysByBoxId[box.id] ?? const <ToyCatalogItem>[],
                            onTap: () => onOpenBox(box.id),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (unboxed.isNotEmpty)
                          _BoxesIpadBoxRow(
                            title: 'Sem caixa',
                            subtitle: 'Brinquedos que precisam de organização',
                            countLabel: _toyCountLabel(unboxed.length),
                            icon: Icons.inbox_outlined,
                            toys: unboxed,
                            highlighted: true,
                            onTap: onOpenUnboxed,
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxesIpadEmptyBoxes extends StatelessWidget {
  final VoidCallback onNewBox;

  const _BoxesIpadEmptyBoxes({required this.onNewBox});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: _BoxesIpadPalette.orangeLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _BoxesIpadPalette.orangeBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: _BoxesIpadPalette.orange,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'Nenhuma caixa cadastrada',
            style: UiTokens.textCaption.copyWith(
              color: _BoxesIpadPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Crie a primeira caixa para organizar os brinquedos da casa.',
            textAlign: TextAlign.center,
            style: UiTokens.textMicro.copyWith(
              color: _BoxesIpadPalette.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onNewBox,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Nova caixa'),
          ),
        ],
      ),
    );
  }
}

class _BoxesIpadBoxRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String countLabel;
  final IconData icon;
  final List<ToyCatalogItem> toys;
  final bool highlighted;
  final VoidCallback onTap;

  const _BoxesIpadBoxRow({
    required this.title,
    required this.subtitle,
    required this.countLabel,
    required this.icon,
    required this.toys,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: highlighted ? const Color(0xFFFFFBEB) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: highlighted
                  ? const Color(0xFFFDE68A)
                  : _BoxesIpadPalette.border,
              width: 1.35,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0DAA6E32),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: highlighted
                      ? const Color(0xFFFFF7ED)
                      : _BoxesIpadPalette.photoBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _BoxesIpadPalette.border),
                ),
                child: Icon(
                  icon,
                  color: highlighted
                      ? _BoxesIpadPalette.orange
                      : _BoxesIpadPalette.textMuted,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textCaption.copyWith(
                        color: _BoxesIpadPalette.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textMicro.copyWith(
                        color: _BoxesIpadPalette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _BoxesIpadMiniThumbs(items: toys),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _BoxesIpadBadge(label: countLabel),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _BoxesIpadPalette.orangeLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _BoxesIpadPalette.orangeBorder),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: _BoxesIpadPalette.orange,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoxesIpadMiniThumbs extends StatelessWidget {
  final List<ToyCatalogItem> items;

  const _BoxesIpadMiniThumbs({required this.items});

  @override
  Widget build(BuildContext context) {
    final visible = items.take(4).toList();
    if (visible.isEmpty) {
      return Text(
        'Nenhum brinquedo nesta caixa',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: UiTokens.textMicro.copyWith(
          color: _BoxesIpadPalette.textMuted,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Row(
      children: [
        for (var index = 0; index < visible.length; index++) ...[
          if (index > 0) const SizedBox(width: 5),
          _BoxesIpadToyThumb(path: visible[index].toy.photoPath, size: 28),
        ],
        if (items.length > visible.length) ...[
          const SizedBox(width: 6),
          Text(
            '+${items.length - visible.length}',
            style: UiTokens.textMicro.copyWith(
              color: _BoxesIpadPalette.textMuted,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ],
    );
  }
}

class _BoxesIpadSideColumn extends StatelessWidget {
  final List<Boxe> boxes;
  final List<ToyCatalogItem> unboxed;
  final _BoxesIpadSummary summary;
  final ValueChanged<ToyCatalogItem> onAssignToy;
  final ValueChanged<ToyCatalogItem> onOpenToy;
  final VoidCallback onNewBox;
  final VoidCallback onOpenAllToys;
  final VoidCallback onOpenUnboxed;
  final VoidCallback onOpenLocations;

  const _BoxesIpadSideColumn({
    required this.boxes,
    required this.unboxed,
    required this.summary,
    required this.onAssignToy,
    required this.onOpenToy,
    required this.onNewBox,
    required this.onOpenAllToys,
    required this.onOpenUnboxed,
    required this.onOpenLocations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BoxesIpadSummaryCard(summary: summary),
        const SizedBox(height: 14),
        _BoxesIpadUnboxedCard(
          items: unboxed,
          hasBoxes: boxes.isNotEmpty,
          onAssignToy: onAssignToy,
          onOpenToy: onOpenToy,
          onOpenUnboxed: onOpenUnboxed,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: _BoxesIpadQuickActionsCard(
            onNewBox: onNewBox,
            onOpenAllToys: onOpenAllToys,
            onOpenUnboxed: onOpenUnboxed,
            onOpenLocations: onOpenLocations,
          ),
        ),
      ],
    );
  }
}

class _BoxesIpadSummaryCard extends StatelessWidget {
  final _BoxesIpadSummary summary;

  const _BoxesIpadSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return _BoxesIpadSurface(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo',
            style: UiTokens.textCaption.copyWith(
              color: _BoxesIpadPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _BoxesIpadStatTile(
                  value: summary.boxCount,
                  label: 'Caixas',
                  foreground: _BoxesIpadPalette.orange,
                  background: _BoxesIpadPalette.orangeLight,
                  border: _BoxesIpadPalette.orangeBorder,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BoxesIpadStatTile(
                  value: summary.toyCount,
                  label: 'Brinquedos',
                  foreground: const Color(0xFF8B5CF6),
                  background: const Color(0xFFF5F3FF),
                  border: const Color(0xFFDDD6FE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _BoxesIpadStatTile(
            value: summary.locationCount,
            label: 'Locais',
            foreground: const Color(0xFF2563EB),
            background: const Color(0xFFEFF6FF),
            border: const Color(0xFFBFDBFE),
            wide: true,
          ),
        ],
      ),
    );
  }
}

class _BoxesIpadStatTile extends StatelessWidget {
  final int value;
  final String label;
  final Color foreground;
  final Color background;
  final Color border;
  final bool wide;

  const _BoxesIpadStatTile({
    required this.value,
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 16 : 14,
        vertical: wide ? 13 : 12,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border, width: 1.5),
      ),
      child: wide
          ? Row(
              children: [
                Text(
                  '$value',
                  style: UiTokens.textTitle.copyWith(
                    color: foreground,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 9),
                Flexible(child: _BoxesIpadStatLabel(label: label)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  maxLines: 1,
                  style: UiTokens.textTitle.copyWith(
                    color: foreground,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                _BoxesIpadStatLabel(label: label),
              ],
            ),
    );
  }
}

class _BoxesIpadStatLabel extends StatelessWidget {
  final String label;

  const _BoxesIpadStatLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: UiTokens.textMicro.copyWith(
        color: _BoxesIpadPalette.textMid,
        fontSize: 11.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _BoxesIpadUnboxedCard extends StatelessWidget {
  final List<ToyCatalogItem> items;
  final bool hasBoxes;
  final ValueChanged<ToyCatalogItem> onAssignToy;
  final ValueChanged<ToyCatalogItem> onOpenToy;
  final VoidCallback onOpenUnboxed;

  const _BoxesIpadUnboxedCard({
    required this.items,
    required this.hasBoxes,
    required this.onAssignToy,
    required this.onOpenToy,
    required this.onOpenUnboxed,
  });

  @override
  Widget build(BuildContext context) {
    final visible = items.take(3).toList();
    return _BoxesIpadSurface(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sem caixa',
            style: UiTokens.textCaption.copyWith(
              color: _BoxesIpadPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Brinquedos que precisam de organização',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _BoxesIpadPalette.textMuted,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          if (visible.isEmpty)
            _BoxesIpadDoneState()
          else
            for (var index = 0; index < visible.length; index++) ...[
              _BoxesIpadUnboxedToyRow(
                item: visible[index],
                hasBoxes: hasBoxes,
                onAssign: () => onAssignToy(visible[index]),
                onOpen: () => onOpenToy(visible[index]),
              ),
              if (index < visible.length - 1)
                const Divider(height: 14, color: _BoxesIpadPalette.border),
            ],
          if (items.length > visible.length) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onOpenUnboxed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _BoxesIpadPalette.orange,
                  side: const BorderSide(
                    color: _BoxesIpadPalette.orangeBorder,
                    width: 1.4,
                  ),
                  backgroundColor: _BoxesIpadPalette.orangeLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '+${items.length - visible.length} brinquedos sem caixa · Ver todos',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BoxesIpadDoneState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: _BoxesIpadPalette.orangeLight,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _BoxesIpadPalette.orangeBorder),
      ),
      child: Text(
        'Tudo organizado por enquanto.',
        textAlign: TextAlign.center,
        style: UiTokens.textMicro.copyWith(
          color: _BoxesIpadPalette.textMid,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BoxesIpadUnboxedToyRow extends StatelessWidget {
  final ToyCatalogItem item;
  final bool hasBoxes;
  final VoidCallback onAssign;
  final VoidCallback onOpen;

  const _BoxesIpadUnboxedToyRow({
    required this.item,
    required this.hasBoxes,
    required this.onAssign,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        item.toy.name.trim().isEmpty ? 'Sem nome' : item.toy.name.trim();
    final category = _categoryLabel(item);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              _BoxesIpadToyThumb(path: item.toy.photoPath, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textMicro.copyWith(
                        color: _BoxesIpadPalette.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textMicro.copyWith(
                        color: _BoxesIpadPalette.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: hasBoxes ? onAssign : null,
                style: TextButton.styleFrom(
                  foregroundColor: _BoxesIpadPalette.orange,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: const Text('Atribuir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoxesIpadQuickActionsCard extends StatelessWidget {
  final VoidCallback onNewBox;
  final VoidCallback onOpenAllToys;
  final VoidCallback onOpenUnboxed;
  final VoidCallback onOpenLocations;

  const _BoxesIpadQuickActionsCard({
    required this.onNewBox,
    required this.onOpenAllToys,
    required this.onOpenUnboxed,
    required this.onOpenLocations,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _BoxesIpadActionData(
        label: 'Criar caixa',
        icon: Icons.add_rounded,
        foreground: _BoxesIpadPalette.orange,
        background: _BoxesIpadPalette.orangeLight,
        onTap: onNewBox,
      ),
      _BoxesIpadActionData(
        label: 'Reorganizar brinquedos',
        icon: Icons.swap_horiz_rounded,
        foreground: const Color(0xFF8B5CF6),
        background: const Color(0xFFF5F3FF),
        onTap: onOpenAllToys,
      ),
      _BoxesIpadActionData(
        label: 'Ver brinquedos sem caixa',
        icon: Icons.inbox_outlined,
        foreground: const Color(0xFF2563EB),
        background: const Color(0xFFEFF6FF),
        onTap: onOpenUnboxed,
      ),
      _BoxesIpadActionData(
        label: 'Ver locais',
        icon: Icons.place_outlined,
        foreground: _BoxesIpadPalette.orangeDark,
        background: const Color(0xFFFFF7ED),
        onTap: onOpenLocations,
      ),
    ];

    return _BoxesIpadSurface(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações rápidas',
            style: UiTokens.textCaption.copyWith(
              color: _BoxesIpadPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < actions.length; index++) ...[
            _BoxesIpadActionTile(data: actions[index]),
            if (index < actions.length - 1)
              const Divider(height: 1, color: _BoxesIpadPalette.border),
          ],
        ],
      ),
    );
  }
}

class _BoxesIpadActionTile extends StatelessWidget {
  final _BoxesIpadActionData data;

  const _BoxesIpadActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: data.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: data.foreground.withValues(alpha: 0.16),
                    width: 1.3,
                  ),
                ),
                child: Icon(data.icon, color: data.foreground, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _BoxesIpadPalette.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: _BoxesIpadPalette.textMuted,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoxesIpadActionData {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;

  const _BoxesIpadActionData({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });
}

class _BoxesIpadPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  const _BoxesIpadPill({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            style: UiTokens.textMicro.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxesIpadBadge extends StatelessWidget {
  final String label;

  const _BoxesIpadBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _BoxesIpadPalette.orangeLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _BoxesIpadPalette.orangeBorder, width: 1.3),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: UiTokens.textMicro.copyWith(
          color: _BoxesIpadPalette.orangeDark,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BoxesIpadToyThumb extends StatelessWidget {
  final String? path;
  final double size;

  const _BoxesIpadToyThumb({required this.path, required this.size});

  @override
  Widget build(BuildContext context) {
    final p = (path ?? '').trim();
    if (p.isEmpty) return _placeholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.file(
        File(p),
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _BoxesIpadPalette.photoBg,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: _BoxesIpadPalette.border),
      ),
      child: Icon(
        Icons.image_outlined,
        size: size * 0.45,
        color: _BoxesIpadPalette.textMuted,
      ),
    );
  }
}

String _boxTitleForDisplay(Boxe box) {
  final local = box.local.trim();
  if (local.isEmpty) return 'Caixa ${box.number}';
  return 'Caixa ${box.number} - $local';
}

String _toyCountLabel(int count) {
  return count == 1 ? '1 brinquedo' : '$count brinquedos';
}

String _categoryLabel(ToyCatalogItem item) {
  final label = item.category?.name.trim();
  if (label != null && label.isNotEmpty) return label;
  final id = item.toy.categoryId.trim();
  return id.isEmpty ? 'Sem categoria' : id;
}

class _BoxMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BoxMetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UiTokens.spacingSm,
        vertical: UiTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(UiTokens.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFF97316)),
          const SizedBox(width: UiTokens.spacingXs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ToyThumb extends StatelessWidget {
  final String? path;

  const _ToyThumb({required this.path});

  @override
  Widget build(BuildContext context) {
    final p = (path ?? '').trim();
    const size = 40.0;

    if (p.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(UiTokens.radiusPhoto),
        ),
        child: const Icon(Icons.image_outlined, size: 18),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(UiTokens.radiusPhoto),
      child: Image.file(
        File(p),
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) {
          return Container(
            width: size,
            height: size,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image_outlined, size: 18),
          );
        },
      ),
    );
  }
}
