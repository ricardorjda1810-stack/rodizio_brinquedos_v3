import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/data/services/photo_cropper_service.dart';
import 'package:rodizio_brinquedos_v3/ui/box_create_page.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';

class ToyCreatePage extends StatefulWidget {
  final ToyRepository toyRepository;
  final SettingsRepository? settingsRepository;

  const ToyCreatePage({
    super.key,
    required this.toyRepository,
    this.settingsRepository,
  });

  @override
  State<ToyCreatePage> createState() => _ToyCreatePageState();
}

class _ToyCreatePageState extends State<ToyCreatePage> {
  String? _selectedCategoryId;
  String? _selectedBoxId;
  String? _selectedLooseLocation;
  String? _photoSourcePath;
  bool _saving = false;

  AppFeedback? get _feedback {
    final settings = widget.settingsRepository;
    if (settings == null) return null;
    return AppFeedback(settings);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 85);
    if (image == null) return;
    final croppedPath =
        await PhotoCropperService.cropToSquare(sourcePath: image.path);
    if (!mounted || croppedPath == null) return;
    setState(() => _photoSourcePath = croppedPath);
  }

  Future<void> _createBox() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BoxCreatePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
        ),
      ),
    );
    if (created == true) {
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.toyRepository.addToyWithGeneratedName(
        categoryId: _selectedCategoryId!,
        boxId: _selectedBoxId,
        locationText: _selectedBoxId == null ? _selectedLooseLocation : null,
        photoSourcePath: _photoSourcePath,
      );
      await _feedback?.onCreateSaved(playSound: true);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar brinquedo: $e')),
      );
      setState(() => _saving = false);
    }
  }

  Widget _photoPreview() {
    final path = (_photoSourcePath ?? '').trim();
    if (path.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.image_outlined, size: 42)),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child:
              const Center(child: Icon(Icons.broken_image_outlined, size: 42)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo brinquedo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UiTokens.m),
          child: StreamBuilder<List<CategoryDefinition>>(
            stream: widget.toyRepository.watchCategories(activeOnly: true),
            builder: (context, categorySnap) {
              final categories =
                  categorySnap.data ?? const <CategoryDefinition>[];
              if (_selectedCategoryId != null &&
                  !categories.any((c) => c.id == _selectedCategoryId)) {
                _selectedCategoryId = null;
              }

              return StreamBuilder<List<Boxe>>(
                stream: widget.toyRepository.watchBoxes(),
                builder: (context, boxesSnap) {
                  final boxes = boxesSnap.data ?? const <Boxe>[];
                  if (_selectedBoxId != null &&
                      !boxes.any((b) => b.id == _selectedBoxId)) {
                    _selectedBoxId = null;
                  }

                  return StreamBuilder<List<LocationDefinition>>(
                    stream: widget.toyRepository.watchLocations(),
                    builder: (context, locationsSnap) {
                      final locations =
                          locationsSnap.data ?? const <LocationDefinition>[];

                      if (_selectedLooseLocation != null &&
                          !locations
                              .any((l) => l.name == _selectedLooseLocation)) {
                        _selectedLooseLocation = null;
                      }

                      return ListView(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: _photoPreview(),
                            ),
                          ),
                          const SizedBox(height: UiTokens.s),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.photo_camera_outlined),
                                  label: const Text('Camera'),
                                ),
                              ),
                              const SizedBox(width: UiTokens.s),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : () => _pickImage(ImageSource.gallery),
                                  icon:
                                      const Icon(Icons.photo_library_outlined),
                                  label: const Text('Galeria'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: UiTokens.m),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Categoria *',
                            ),
                            items: categories
                                .map(
                                  (c) => DropdownMenuItem<String>(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                            onChanged: _saving
                                ? null
                                : (v) =>
                                    setState(() => _selectedCategoryId = v),
                          ),
                          const SizedBox(height: UiTokens.m),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  initialValue: _selectedBoxId,
                                  decoration: const InputDecoration(
                                      labelText: 'Caixa (opcional)'),
                                  items: <DropdownMenuItem<String?>>[
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('Sem caixa'),
                                    ),
                                    ...boxes.map(
                                      (b) => DropdownMenuItem<String?>(
                                        value: b.id,
                                        child: Text(
                                            'Caixa ${b.number} - ${b.local}'),
                                      ),
                                    ),
                                  ],
                                  onChanged: _saving
                                      ? null
                                      : (v) =>
                                          setState(() => _selectedBoxId = v),
                                ),
                              ),
                              const SizedBox(width: UiTokens.s),
                              IconButton(
                                tooltip: 'Criar caixa',
                                onPressed: _saving ? null : _createBox,
                                icon: const Icon(Icons.add_box_outlined),
                              ),
                            ],
                          ),
                          if (_selectedBoxId == null) ...[
                            const SizedBox(height: UiTokens.m),
                            DropdownButtonFormField<String?>(
                              initialValue: _selectedLooseLocation,
                              decoration: const InputDecoration(
                                labelText: 'Local (Sem caixa)',
                              ),
                              items: <DropdownMenuItem<String?>>[
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Sem local'),
                                ),
                                ...locations.map(
                                  (l) => DropdownMenuItem<String?>(
                                    value: l.name,
                                    child: Text(l.name),
                                  ),
                                ),
                              ],
                              onChanged: _saving
                                  ? null
                                  : (v) => setState(
                                      () => _selectedLooseLocation = v),
                            ),
                          ],
                          const SizedBox(height: UiTokens.l),
                          FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: const Icon(Icons.save_outlined),
                            label: Text(
                                _saving ? 'Salvando...' : 'Salvar brinquedo'),
                          ),
                        ],
                      );
                    },
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
