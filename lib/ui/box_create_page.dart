import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/ui/locations_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/photo_crop_page.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

class BoxCreatePage extends StatefulWidget {
  final ToyRepository toyRepository;
  final SettingsRepository? settingsRepository;

  const BoxCreatePage({
    super.key,
    required this.toyRepository,
    this.settingsRepository,
  });

  @override
  State<BoxCreatePage> createState() => _BoxCreatePageState();
}

class _BoxCreatePageState extends State<BoxCreatePage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _extraLocalController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _saving = false;
  bool _showExtraLocal = false;
  String? _selectedLocationId;
  String? _photoSourcePath;

  AppFeedback? get _feedback {
    final settings = widget.settingsRepository;
    if (settings == null) return null;
    return AppFeedback(settings);
  }

  @override
  void dispose() {
    _extraLocalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save(List<LocationDefinition> locations) async {
    final localToSave = _resolveLocalToSave(locations);

    setState(() => _saving = true);
    try {
      await widget.toyRepository.addBoxWithAutoNumber(
        local: localToSave,
        notes: _notesController.text,
        photoSourcePath: _photoSourcePath,
      );
      await _feedback?.onCreateSaved();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar caixa: $e')));
      setState(() => _saving = false);
    }
  }

  String _resolveLocalToSave(List<LocationDefinition> locations) {
    final extra = _extraLocalController.text.trim();
    if (extra.isNotEmpty) return extra;

    if (locations.isEmpty) return '';

    final selectedId = _selectedLocationId;
    if (selectedId == null) return '';

    for (final location in locations) {
      if (location.id == selectedId) {
        return location.name.trim();
      }
    }

    return '';
  }

  String _previewName(int nextNumber, List<LocationDefinition> locations) {
    final localName = _resolveLocalToSave(locations);
    if (localName.isEmpty) return 'Ser\u00e1 criada: Caixa $nextNumber';
    return 'Ser\u00e1 criada: Caixa $nextNumber - $localName';
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final xfile = await _picker.pickImage(source: source, imageQuality: 85);
    if (xfile == null || !mounted) return;
    final croppedPath = await PhotoCropPage.open(
      context,
      sourcePath: xfile.path,
    );
    if (!mounted || croppedPath == null) return;
    setState(() {
      _photoSourcePath = croppedPath;
    });
  }

  Future<void> _openPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final hasPhoto = (_photoSourcePath ?? '').trim().isNotEmpty;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remover foto'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _photoSourcePath = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoArea() {
    final path = (_photoSourcePath ?? '').trim();
    return InkWell(
      borderRadius: BorderRadius.circular(UiTokens.radiusCard),
      onTap: _saving ? null : _openPhotoOptions,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiTokens.radiusCard),
        child: AspectRatio(
          aspectRatio: 1.35,
          child: path.isEmpty
              ? Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera_outlined),
                      SizedBox(height: UiTokens.xs),
                      Text('Adicionar foto (opcional)'),
                    ],
                  ),
                )
              : Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined),
                        SizedBox(height: UiTokens.xs),
                        Text('Falha ao carregar a foto'),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiTokens.bg,
      appBar: AppBar(title: const Text('Nova caixa')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UiTokens.m),
          child: StreamBuilder<List<Boxe>>(
            stream: widget.toyRepository.watchBoxes(),
            builder: (context, boxesSnapshot) {
              if (boxesSnapshot.connectionState == ConnectionState.waiting &&
                  !boxesSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final boxes = boxesSnapshot.data ?? const <Boxe>[];
              var nextNumber = 1;
              for (final box in boxes) {
                if (box.number >= nextNumber) {
                  nextNumber = box.number + 1;
                }
              }

              return StreamBuilder<List<LocationDefinition>>(
                stream: widget.toyRepository.watchLocations(),
                builder: (context, snapshot) {
                  final locations = snapshot.data ?? const <LocationDefinition>[];

                  final selectedLocationId =
                      _selectedLocationId != null &&
                              locations.any((l) => l.id == _selectedLocationId)
                          ? _selectedLocationId
                          : null;
                  if (selectedLocationId == null &&
                      _selectedLocationId != null) {
                    _selectedLocationId = null;
                  }

                  final extraLocalFilled =
                      _extraLocalController.text.trim().isNotEmpty;
                  final canSave = !_saving &&
                      (locations.isEmpty ||
                          extraLocalFilled ||
                          _selectedLocationId != null);

                  return ListView(
                    padding: const EdgeInsets.only(bottom: UiTokens.spacingLg),
                    children: [
                      AppSurfaceCard(
                        padding: const EdgeInsets.all(UiTokens.spacingMd),
                        color: UiTokens.primarySoft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organizar uma nova caixa',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: UiTokens.spacingXs),
                            Text(
                              'Defina foto, local e observa\u00e7\u00f5es para manter a organiza\u00e7\u00e3o da casa simples e clara.',
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
                      AppSurfaceCard(
                        padding: const EdgeInsets.all(UiTokens.spacingMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Foto da caixa',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: UiTokens.spacingXs),
                            Text(
                              'Opcional, mas ajuda muito na identifica\u00e7\u00e3o visual.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: UiTokens.spacingSm),
                            _buildPhotoArea(),
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
                              'Dados principais',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: UiTokens.spacingMd),
                            TextFormField(
                              initialValue: 'Caixa $nextNumber',
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Nome',
                              ),
                            ),
                            const SizedBox(height: UiTokens.spacingXs),
                            Text(
                              _previewName(nextNumber, locations),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: UiTokens.spacingMd),
                            if (locations.isNotEmpty)
                              DropdownButtonFormField<String>(
                                key: ValueKey(selectedLocationId),
                                initialValue: selectedLocationId,
                                decoration: const InputDecoration(
                                  labelText: 'Localiza\u00e7\u00e3o da caixa',
                                  hintText: 'Selecione um local',
                                ),
                                items: locations
                                    .map(
                                      (l) => DropdownMenuItem<String>(
                                        value: l.id,
                                        child: Text(l.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _saving
                                    ? null
                                    : (value) => setState(
                                          () => _selectedLocationId = value,
                                        ),
                              ),
                            if (locations.isNotEmpty)
                              const SizedBox(height: UiTokens.spacingSm),
                            Wrap(
                              spacing: UiTokens.spacingSm,
                              runSpacing: UiTokens.spacingSm,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: _saving
                                      ? null
                                      : () => setState(
                                            () =>
                                                _showExtraLocal = !_showExtraLocal,
                                          ),
                                  child: Text(
                                    _showExtraLocal
                                        ? 'Ocultar local extra'
                                        : 'Local extra',
                                  ),
                                ),
                                if (locations.isNotEmpty)
                                  Text(
                                    'Ou use um local j\u00e1 cadastrado.',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                            if (_showExtraLocal) ...[
                              const SizedBox(height: UiTokens.spacingSm),
                              TextField(
                                controller: _extraLocalController,
                                enabled: !_saving,
                                decoration: const InputDecoration(
                                  labelText: 'Local extra (manual)',
                                  hintText: 'Ex.: Sala do fundo',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                            const SizedBox(height: UiTokens.spacingSm),
                            TextField(
                              controller: _notesController,
                              enabled: !_saving,
                              minLines: 2,
                              maxLines: 4,
                              maxLength: 120,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(120),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Informacoes importantes (opcional)',
                                hintText: 'Ex.: pecas pequenas na parte de cima',
                              ),
                            ),
                            if (locations.isEmpty) ...[
                              const SizedBox(height: UiTokens.spacingSm),
                              Container(
                                padding: const EdgeInsets.all(UiTokens.spacingMd),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius:
                                      BorderRadius.circular(UiTokens.radiusLg),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nenhum local cadastrado',
                                      style:
                                          Theme.of(context).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: UiTokens.spacingXs),
                                    Text(
                                      'Voc\u00ea pode salvar sem local ou cadastrar locais nas Configura\u00e7\u00f5es.',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: UiTokens.spacingSm),
                                    OutlinedButton.icon(
                                      onPressed: _saving
                                          ? null
                                          : () async {
                                              await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      LocationsManagePage(
                                                    toyRepository:
                                                        widget.toyRepository,
                                                    settingsRepository:
                                                        widget.settingsRepository,
                                                  ),
                                                ),
                                              );
                                              if (!mounted) return;
                                              setState(() {});
                                            },
                                      icon: const Icon(Icons.place_outlined),
                                      label: const Text('Gerenciar locais'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: UiTokens.spacingSm),
                      FilledButton.icon(
                        onPressed: canSave ? () => _save(locations) : null,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_saving ? 'Salvando...' : 'Salvar caixa'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
