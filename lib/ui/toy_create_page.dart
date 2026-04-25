import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/services/premium_gate.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/box_create_page.dart';
import 'package:rodizio_brinquedos_v3/ui/photo_crop_page.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/category_quick_picker.dart';

class ToyCreatePage extends StatefulWidget {
  final ToyRepository toyRepository;
  final SettingsRepository? settingsRepository;
  final PurchaseService? purchaseService;

  const ToyCreatePage({
    super.key,
    required this.toyRepository,
    this.settingsRepository,
    this.purchaseService,
  });

  @override
  State<ToyCreatePage> createState() => _ToyCreatePageState();
}

class _ToyCreatePageState extends State<ToyCreatePage> {
  static const Duration _localFieldAnimationDuration = Duration(
    milliseconds: 200,
  );
  static const String _noBoxOptionValue = '__sem_caixa__';
  static const String _locationRequiredMessage =
      'Selecione uma caixa ou escolha "Sem caixa" para salvar o brinquedo.';
  static String? _lastCategoryId;

  String? _selectedCategoryId;
  String? _selectedBoxSelection;
  String? _selectedLooseLocation;
  String? _photoSourcePath;
  bool _saving = false;
  bool _boxSelectionTouched = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId ??= _lastCategoryId;
  }

  AppFeedback? get _feedback {
    final settings = widget.settingsRepository;
    if (settings == null) return null;
    return AppFeedback(settings);
  }

  bool get _hasExplicitBoxSelection => _selectedBoxSelection != null;

  bool get _isWithoutBoxSelected => _selectedBoxSelection == _noBoxOptionValue;

  String? get _selectedBoxId =>
      _isWithoutBoxSelected ? null : _selectedBoxSelection;

  void _showLocationSelectionWarning() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(_locationRequiredMessage)));
  }

  bool _validateBeforeSave() {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma categoria.')));
      return false;
    }

    if (!_hasExplicitBoxSelection) {
      setState(() => _boxSelectionTouched = true);
      _showLocationSelectionWarning();
      return false;
    }

    return true;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 85);
    if (image == null || !mounted) return;
    final croppedPath = await PhotoCropPage.open(
      context,
      sourcePath: image.path,
    );
    if (!mounted || croppedPath == null) return;
    setState(() => _photoSourcePath = croppedPath);
  }

  Future<void> _createBox() async {
    final allowed = await PremiumGate.ensurePremium(
      context: context,
      purchaseService: widget.purchaseService,
    );
    if (!allowed) return;

    await HapticFeedback.selectionClick();
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final created = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => BoxCreatePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
        ),
      ),
    );
    if (!mounted) return;
    if (created == true) {
      setState(() {});
    }
  }

  Future<void> _save() async {
    final allowed = await PremiumGate.ensurePremium(
      context: context,
      purchaseService: widget.purchaseService,
    );
    if (!allowed) return;

    if (!_validateBeforeSave()) return;

    await HapticFeedback.lightImpact();
    setState(() => _saving = true);
    try {
      await widget.toyRepository.addToyWithGeneratedName(
        categoryId: _selectedCategoryId!,
        boxId: _selectedBoxId,
        locationText: _isWithoutBoxSelected ? _selectedLooseLocation : null,
        photoSourcePath: _photoSourcePath,
      );
      await _feedback?.onCreateSaved(playSound: true);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar brinquedo: $e')));
      setState(() => _saving = false);
    }
  }

  Future<void> _saveAndAddAnother() async {
    final allowed = await PremiumGate.ensurePremium(
      context: context,
      purchaseService: widget.purchaseService,
    );
    if (!allowed) return;

    if (!_validateBeforeSave()) return;

    await HapticFeedback.lightImpact();
    setState(() => _saving = true);

    try {
      await widget.toyRepository.addToyWithGeneratedName(
        categoryId: _selectedCategoryId!,
        boxId: _selectedBoxId,
        locationText: _isWithoutBoxSelected ? _selectedLooseLocation : null,
        photoSourcePath: _photoSourcePath,
      );

      _lastCategoryId = _selectedCategoryId;

      await _feedback?.onCreateSaved(playSound: true);
      if (!mounted) return;

      setState(() {
        _saving = false;
        _photoSourcePath = null;
        _selectedLooseLocation = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brinquedo salvo! Adicione outro.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar brinquedo: $e')));
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
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 42),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final showLocal = _isWithoutBoxSelected;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: UiTokens.bg,
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
                    _selectedBoxSelection = null;
                  }

                  return StreamBuilder<List<LocationDefinition>>(
                    stream: widget.toyRepository.watchLocations(),
                    builder: (context, locationsSnap) {
                      final locations =
                          locationsSnap.data ?? const <LocationDefinition>[];
                      final categoriesSorted = [...categories]..sort((a, b) {
                          int rank(String name) {
                            final n = name.toLowerCase();
                            if (n.contains('veic')) return 0;
                            if (n.contains('bonec')) return 1;
                            if (n.contains('mont')) return 2;
                            if (n.contains('faz')) return 3;
                            if (n.contains('jogo')) return 4;
                            if (n.contains('liv')) return 5;
                            if (n.contains('arte')) return 6;
                            if (n.contains('music')) return 7;
                            if (n.contains('banh')) return 8;
                            if (n.contains('out')) return 9;
                            return 100;
                          }

                          final ra = rank(a.name);
                          final rb = rank(b.name);
                          if (ra != rb) return ra.compareTo(rb);
                          return a.name.compareTo(b.name);
                        });

                      if (_selectedBoxId != null &&
                          !boxes.any((b) => b.id == _selectedBoxId)) {
                        _selectedBoxSelection = null;
                      }

                      if (_selectedLooseLocation != null &&
                          !locations.any(
                            (l) => l.name == _selectedLooseLocation,
                          )) {
                        _selectedLooseLocation = null;
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.only(
                                bottom: UiTokens.m,
                              ),
                              children: [
                                AppSurfaceCard(
                                  padding:
                                      const EdgeInsets.all(UiTokens.spacingMd),
                                  color: UiTokens.primarySoft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cadastrar com calma',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(
                                          height: UiTokens.spacingXs),
                                      Text(
                                        'Escolha a foto, marque a categoria principal e indique onde o brinquedo fica guardado.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: UiTokens.spacingMd),
                                AppSurfaceCard(
                                  padding:
                                      const EdgeInsets.all(UiTokens.spacingMd),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Foto do brinquedo',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      const SizedBox(
                                          height: UiTokens.spacingXs),
                                      Text(
                                        'A foto aparece primeiro e ajuda a reconhecer tudo mais r\u00e1pido.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      const SizedBox(
                                          height: UiTokens.spacingSm),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          UiTokens.radiusCard,
                                        ),
                                        child: AspectRatio(
                                          aspectRatio: 1.42,
                                          child: _photoPreview(),
                                        ),
                                      ),
                                      const SizedBox(
                                          height: UiTokens.spacingSm),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: _saving
                                                  ? null
                                                  : () async {
                                                      await HapticFeedback
                                                          .selectionClick();
                                                      await _pickImage(
                                                        ImageSource.camera,
                                                      );
                                                    },
                                              icon: const Icon(
                                                Icons.photo_camera_outlined,
                                              ),
                                              label: const Text('C\u00e2mera'),
                                            ),
                                          ),
                                          const SizedBox(width: UiTokens.s),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: _saving
                                                  ? null
                                                  : () async {
                                                      await HapticFeedback
                                                          .selectionClick();
                                                      await _pickImage(
                                                        ImageSource.gallery,
                                                      );
                                                    },
                                              icon: const Icon(
                                                Icons.photo_library_outlined,
                                              ),
                                              label: const Text('Galeria'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: UiTokens.spacingMd),
                                AppSurfaceCard(
                                  padding:
                                      const EdgeInsets.all(UiTokens.spacingMd),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Categoria principal',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      const SizedBox(
                                          height: UiTokens.spacingXs),
                                      Text(
                                        'Escolha s\u00f3 uma: a que melhor representa o est\u00edmulo principal.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      const SizedBox(
                                          height: UiTokens.spacingSm),
                                      CategoryQuickPicker<CategoryDefinition>(
                                        categories: categoriesSorted,
                                        selectedId: _selectedCategoryId,
                                        disabled: _saving,
                                        getId: (c) => c.id,
                                        getName: (c) => c.name,
                                        getExamples: (c) => c.examples,
                                        onSelected: (id) => setState(
                                          () => _selectedCategoryId = id,
                                        ),
                                      ),
                                      if (_selectedCategoryId == null) ...[
                                        const SizedBox(
                                            height: UiTokens.spacingSm),
                                        Text(
                                          'Obrigat\u00f3rio.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: UiTokens.warning,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: UiTokens.spacingMd),
                                AppSurfaceCard(
                                  padding:
                                      const EdgeInsets.all(UiTokens.spacingMd),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Onde guardar',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      const SizedBox(
                                          height: UiTokens.spacingXs),
                                      Text(
                                        'Voc\u00ea pode deixar em uma caixa ou marcar como item sem caixa.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      const SizedBox(
                                          height: UiTokens.spacingMd),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final compact =
                                              constraints.maxWidth < 420;

                                          return Wrap(
                                            spacing: UiTokens.s,
                                            runSpacing: UiTokens.s,
                                            children: [
                                              SizedBox(
                                                width: compact
                                                    ? constraints.maxWidth
                                                    : constraints.maxWidth -
                                                        118,
                                                child: DropdownButtonFormField<
                                                    String?>(
                                                  initialValue:
                                                      _selectedBoxSelection,
                                                  decoration: InputDecoration(
                                                    labelText: 'Caixa',
                                                    helperText:
                                                        'Escolha uma caixa ou marque "Sem caixa".',
                                                    errorText: _boxSelectionTouched &&
                                                            !_hasExplicitBoxSelection
                                                        ? _locationRequiredMessage
                                                        : null,
                                                  ),
                                                  items: <DropdownMenuItem<
                                                      String?>>[
                                                    const DropdownMenuItem<
                                                        String?>(
                                                      value: null,
                                                      child: Text(
                                                        'Selecione uma caixa ou "Sem caixa"',
                                                      ),
                                                    ),
                                                    const DropdownMenuItem<
                                                        String?>(
                                                      value: _noBoxOptionValue,
                                                      child: Text('Sem caixa'),
                                                    ),
                                                    ...boxes.map(
                                                      (b) => DropdownMenuItem<
                                                          String?>(
                                                        value: b.id,
                                                        child: Text(
                                                          'Caixa ${b.number} - ${b.local}',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: _saving
                                                      ? null
                                                      : (v) => setState(() {
                                                            _selectedBoxSelection =
                                                                v;
                                                            _boxSelectionTouched =
                                                                true;
                                                            if (!_isWithoutBoxSelected) {
                                                              _selectedLooseLocation =
                                                                  null;
                                                            }
                                                          }),
                                                ),
                                              ),
                                              SizedBox(
                                                width: compact
                                                    ? constraints.maxWidth
                                                    : 110,
                                                child: FilledButton.tonalIcon(
                                                  onPressed: _saving
                                                      ? null
                                                      : () async {
                                                          await _createBox();
                                                        },
                                                  icon: const Icon(
                                                    Icons.add_box_outlined,
                                                  ),
                                                  label: const Text('Nova'),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      AnimatedSize(
                                        duration: _localFieldAnimationDuration,
                                        curve: Curves.easeOut,
                                        alignment: Alignment.topCenter,
                                        child: AnimatedSwitcher(
                                          duration:
                                              _localFieldAnimationDuration,
                                          switchInCurve: Curves.easeOut,
                                          switchOutCurve: Curves.easeOut,
                                          transitionBuilder:
                                              (child, animation) {
                                            final offset = Tween<Offset>(
                                              begin: const Offset(0, -0.03),
                                              end: Offset.zero,
                                            ).animate(animation);
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: offset,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: showLocal
                                              ? Padding(
                                                  key: const ValueKey(
                                                    'local-field',
                                                  ),
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: UiTokens.m,
                                                  ),
                                                  child:
                                                      DropdownButtonFormField<
                                                          String?>(
                                                    initialValue:
                                                        _selectedLooseLocation,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'Local',
                                                    ),
                                                    items: <DropdownMenuItem<
                                                        String?>>[
                                                      const DropdownMenuItem<
                                                          String?>(
                                                        value: null,
                                                        child: Text(
                                                          'Sem local',
                                                        ),
                                                      ),
                                                      ...locations.map(
                                                        (l) => DropdownMenuItem<
                                                            String?>(
                                                          value: l.name,
                                                          child: Text(l.name),
                                                        ),
                                                      ),
                                                    ],
                                                    onChanged: _saving
                                                        ? null
                                                        : (v) => setState(
                                                              () =>
                                                                  _selectedLooseLocation =
                                                                      v,
                                                            ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(
                                                  key: ValueKey(
                                                    'local-field-hidden',
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.only(top: UiTokens.s),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final stacked = constraints.maxWidth < 380;

                                  final saveButton = SizedBox(
                                    height: 50,
                                    child: FilledButton.icon(
                                      onPressed: _saving ? null : _save,
                                      icon: const Icon(Icons.save_outlined),
                                      label: Text(
                                        _saving ? 'Salvando...' : 'Salvar',
                                      ),
                                    ),
                                  );

                                  final saveAnotherButton = SizedBox(
                                    height: 50,
                                    child: FilledButton.tonalIcon(
                                      onPressed:
                                          _saving ? null : _saveAndAddAnother,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Salvar e outro'),
                                    ),
                                  );

                                  if (stacked) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: saveButton,
                                        ),
                                        const SizedBox(height: UiTokens.s),
                                        SizedBox(
                                          width: double.infinity,
                                          child: saveAnotherButton,
                                        ),
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Expanded(child: saveButton),
                                      const SizedBox(width: UiTokens.s),
                                      Expanded(child: saveAnotherButton),
                                    ],
                                  );
                                },
                              ),
                            ),
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
