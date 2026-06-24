import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/box_create_page.dart';
import 'package:rodizio_brinquedos_v3/ui/photo_crop_page.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_category_form_options.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/category_quick_picker.dart';

class ToyCreatePage extends StatefulWidget {
  final ToyRepository toyRepository;
  final SettingsRepository? settingsRepository;
  final PurchaseService? purchaseService;
  final VoidCallback? onOpenHomeTab;
  final VoidCallback? onOpenRoundTab;
  final VoidCallback? onOpenWeeklyPlanning;
  final VoidCallback? onOpenToysTab;
  final VoidCallback? onOpenBoxesTab;
  final VoidCallback? onOpenSettings;

  const ToyCreatePage({
    super.key,
    required this.toyRepository,
    this.settingsRepository,
    this.purchaseService,
    this.onOpenHomeTab,
    this.onOpenRoundTab,
    this.onOpenWeeklyPlanning,
    this.onOpenToysTab,
    this.onOpenBoxesTab,
    this.onOpenSettings,
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

  final TextEditingController _nameController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedBoxSelection;
  String? _selectedLooseLocation;
  String? _photoSourcePath;
  bool _saving = false;
  bool _boxSelectionTouched = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    unawaited(widget.toyRepository.ensureOfficialToyFormCategories());
    _selectedCategoryId ??= _lastCategoryId;
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onNameChanged)
      ..dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (!mounted) return;
    setState(() {});
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

  String? get _manualToyName {
    final value = _nameController.text.trim();
    return value.isEmpty ? null : value;
  }

  String get _previewToyName => _manualToyName ?? 'Nome gerado automaticamente';

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
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final created = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => BoxCreatePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
          topNavigationIndex: 1,
          onOpenHomeTab: widget.onOpenHomeTab,
          onOpenRoundTab: widget.onOpenRoundTab,
          onOpenWeeklyPlanning: widget.onOpenWeeklyPlanning,
          onOpenToysTab: widget.onOpenToysTab,
          onOpenBoxesTab: widget.onOpenBoxesTab,
          onOpenSettings: widget.onOpenSettings,
        ),
      ),
    );
    if (!mounted) return;
    if (created == true) {
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (!_validateBeforeSave()) return;

    await HapticFeedback.lightImpact();
    setState(() => _saving = true);
    try {
      await widget.toyRepository.addToyWithGeneratedName(
        categoryId: _selectedCategoryId!,
        name: _manualToyName,
        boxId: _selectedBoxId,
        locationText: _isWithoutBoxSelected ? _selectedLooseLocation : null,
        photoSourcePath: _photoSourcePath,
      );
      await _logToyCreated();
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
    if (!_validateBeforeSave()) return;

    await HapticFeedback.lightImpact();
    setState(() => _saving = true);

    try {
      await widget.toyRepository.addToyWithGeneratedName(
        categoryId: _selectedCategoryId!,
        name: _manualToyName,
        boxId: _selectedBoxId,
        locationText: _isWithoutBoxSelected ? _selectedLooseLocation : null,
        photoSourcePath: _photoSourcePath,
      );

      _lastCategoryId = _selectedCategoryId;
      await _logToyCreated();

      await _feedback?.onCreateSaved(playSound: true);
      if (!mounted) return;

      _nameController.clear();
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

  Future<void> _logToyCreated() {
    return AppAnalytics.logToyCreated(
      category: _selectedCategoryId ?? 'unknown',
      hasPhoto: (_photoSourcePath ?? '').trim().isNotEmpty,
      hasBox: _selectedBoxId != null,
    );
  }

  void _cancel() {
    Navigator.of(context).maybePop();
  }

  CategoryDefinition? _selectedCategory(
    List<CategoryDefinition> categories,
  ) {
    final selectedId = _selectedCategoryId;
    if (selectedId == null) return null;
    for (final category in categories) {
      if (category.id == selectedId) return category;
    }
    return null;
  }

  Boxe? _selectedBox(List<Boxe> boxes) {
    final boxId = _selectedBoxId;
    if (boxId == null) return null;
    for (final box in boxes) {
      if (box.id == boxId) return box;
    }
    return null;
  }

  String _categoryLabel(List<CategoryDefinition> categories) {
    final category = _selectedCategory(categories);
    if (category == null) return 'Categoria pendente';
    return toyFormCategoryName(category);
  }

  String _storageLabel(List<Boxe> boxes) {
    if (_isWithoutBoxSelected) {
      final local = (_selectedLooseLocation ?? '').trim();
      return local.isEmpty ? 'Sem caixa' : 'Sem caixa · $local';
    }

    final box = _selectedBox(boxes);
    if (box == null) return 'Local pendente';
    return 'Caixa ${box.number} · ${box.local}';
  }

  String _statusLabel() {
    if (_selectedCategoryId == null && !_hasExplicitBoxSelection) {
      return 'Faltam categoria e local';
    }
    if (_selectedCategoryId == null) return 'Falta categoria';
    if (!_hasExplicitBoxSelection) return 'Falta local';
    return 'Pronto para salvar';
  }

  bool get _isReadyToSave =>
      _selectedCategoryId != null && _hasExplicitBoxSelection;

  Widget _buildIpadTopNavigation() {
    return AppTopNavigation(
      currentIndex: 1,
      onHomeTap: widget.onOpenHomeTab ?? _cancel,
      onRoundTap: widget.onOpenRoundTab ?? _cancel,
      onWeeklyPlanningTap: widget.onOpenWeeklyPlanning ?? _cancel,
      onToysTap: widget.onOpenToysTab ?? _cancel,
      onBoxesTap: widget.onOpenBoxesTab ?? _cancel,
      onSettingsTap: widget.onOpenSettings ?? _cancel,
    );
  }

  Widget _buildIpadLayout({
    required List<CategoryDefinition> officialCategories,
    required List<Boxe> boxes,
    required List<LocationDefinition> locations,
    required bool showLocal,
  }) {
    final bottomPadding = AppBottomNavigation.reservedScrollPadding(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(24, 18, 24, bottomPadding),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildIpadTopNavigation(),
        const SizedBox(height: 18),
        _buildIpadHeader(),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = constraints.maxWidth >= 980 ? 22.0 : 18.0;
            final leftWidth = (constraints.maxWidth - gap) * 0.43;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: leftWidth.clamp(360.0, 520.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildIpadPhotoCard(),
                      const SizedBox(height: 16),
                      _buildIpadPreviewCard(
                        officialCategories: officialCategories,
                        boxes: boxes,
                      ),
                      const SizedBox(height: 16),
                      _buildIpadStatusCard(),
                    ],
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildIpadInfoCard(
                        officialCategories: officialCategories,
                        boxes: boxes,
                      ),
                      const SizedBox(height: 16),
                      _buildIpadCategoryCard(
                        officialCategories: officialCategories,
                      ),
                      const SizedBox(height: 16),
                      _buildIpadOrganizationCard(
                        boxes: boxes,
                        locations: locations,
                        showLocal: showLocal,
                      ),
                      const SizedBox(height: 16),
                      _buildIpadSecondaryActionsCard(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildIpadHeader() {
    return _ToyCreateIpadSurface(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA31A), Color(0xFFF97316)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33F97316),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.toys_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RODÍZIO DE BRINQUEDOS',
                  style: UiTokens.textCaption.copyWith(
                    color: _ToyCreateIpadPalette.orange,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Novo brinquedo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textTitle.copyWith(
                    color: _ToyCreateIpadPalette.text,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Cadastre um brinquedo para incluir no rodízio.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textBody.copyWith(
                    color: _ToyCreateIpadPalette.textMid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          OutlinedButton.icon(
            onPressed: _saving ? null : _cancel,
            icon: const Icon(Icons.close_rounded, size: 19),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC2410C),
              side: const BorderSide(
                color: _ToyCreateIpadPalette.orangeBorder,
                width: 1.4,
              ),
              minimumSize: const Size(126, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 19),
            label: Text(_saving ? 'Salvando...' : 'Salvar brinquedo'),
            style: FilledButton.styleFrom(
              backgroundColor: _ToyCreateIpadPalette.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(166, 52),
              elevation: 4,
              shadowColor: const Color(0x4DF97316),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpadPhotoCard() {
    final hasPhoto = (_photoSourcePath ?? '').trim().isNotEmpty;

    return _ToyCreateIpadSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ToyCreateIpadSectionHeader(
            icon: Icons.photo_camera_outlined,
            title: 'Foto do brinquedo',
            subtitle:
                'A foto aparece primeiro e ajuda a reconhecer tudo mais rápido.',
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 1.02,
              child:
                  hasPhoto ? _photoPreview() : const _ToyCreateIpadPhotoEmpty(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () async {
                          await HapticFeedback.selectionClick();
                          await _pickImage(ImageSource.camera);
                        },
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Câmera'),
                  style: _ToyCreateIpadButtonStyles.outline(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () async {
                          await HapticFeedback.selectionClick();
                          await _pickImage(ImageSource.gallery);
                        },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeria'),
                  style: _ToyCreateIpadButtonStyles.outline(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIpadPreviewCard({
    required List<CategoryDefinition> officialCategories,
    required List<Boxe> boxes,
  }) {
    final hasPhoto = (_photoSourcePath ?? '').trim().isNotEmpty;
    final categoryLabel = _categoryLabel(officialCategories);
    final storageLabel = _storageLabel(boxes);

    return _ToyCreateIpadSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ToyCreateIpadSectionHeader(
            icon: Icons.visibility_outlined,
            title: 'Prévia',
            subtitle: 'Como o brinquedo começa a aparecer no catálogo.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _ToyCreateIpadPalette.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: hasPhoto
                        ? _photoPreview()
                        : Container(
                            color: _ToyCreateIpadPalette.orangeLight,
                            child: const Icon(
                              Icons.toys_outlined,
                              color: _ToyCreateIpadPalette.orange,
                              size: 30,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _previewToyName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textBody.copyWith(
                          color: _ToyCreateIpadPalette.text,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ToyCreateIpadMiniPill(
                        label: categoryLabel,
                        icon: Icons.category_outlined,
                        foreground: _selectedCategoryId == null
                            ? _ToyCreateIpadPalette.textMuted
                            : _ToyCreateIpadPalette.orange,
                        background: _selectedCategoryId == null
                            ? const Color(0xFFF8F2EA)
                            : _ToyCreateIpadPalette.orangeLight,
                      ),
                      const SizedBox(height: 7),
                      _ToyCreateIpadMiniPill(
                        label: storageLabel,
                        icon: Icons.inventory_2_outlined,
                        foreground: _hasExplicitBoxSelection
                            ? _ToyCreateIpadPalette.green
                            : _ToyCreateIpadPalette.textMuted,
                        background: _hasExplicitBoxSelection
                            ? _ToyCreateIpadPalette.greenLight
                            : const Color(0xFFF8F2EA),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpadStatusCard() {
    final ready = _isReadyToSave;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: ready
            ? _ToyCreateIpadPalette.greenLight
            : _ToyCreateIpadPalette.orangeLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ready
              ? _ToyCreateIpadPalette.greenBorder
              : _ToyCreateIpadPalette.orangeBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              ready ? Icons.check_circle_outline : Icons.info_outline_rounded,
              color: ready
                  ? _ToyCreateIpadPalette.green
                  : _ToyCreateIpadPalette.orange,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusLabel(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textBody.copyWith(
                    color: _ToyCreateIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ready
                      ? 'Tudo certo para entrar no rodízio.'
                      : 'Complete os campos obrigatórios antes de salvar.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _ToyCreateIpadPalette.textMid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpadInfoCard({
    required List<CategoryDefinition> officialCategories,
    required List<Boxe> boxes,
  }) {
    return _ToyCreateIpadSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ToyCreateIpadSectionHeader(
            icon: Icons.edit_note_rounded,
            title: 'Informações principais',
            subtitle: 'Digite um nome ou deixe vazio para o app gerar.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            enabled: !_saving,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome do brinquedo',
              hintText: 'Ex: Blocos de montar',
              prefixIcon: Icon(Icons.toys_outlined),
              helperText: 'Opcional: vazio usa o nome automático por caixa.',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ToyCreateIpadInfoTile(
                  label: 'Categoria',
                  value: _categoryLabel(officialCategories),
                  icon: Icons.category_outlined,
                  color: _selectedCategoryId == null
                      ? _ToyCreateIpadPalette.textMuted
                      : _ToyCreateIpadPalette.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ToyCreateIpadInfoTile(
            label: 'Organização',
            value: _storageLabel(boxes),
            icon: Icons.inventory_2_outlined,
            color: _hasExplicitBoxSelection
                ? _ToyCreateIpadPalette.green
                : _ToyCreateIpadPalette.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildIpadCategoryCard({
    required List<CategoryDefinition> officialCategories,
  }) {
    return _ToyCreateIpadSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ToyCreateIpadSectionHeader(
            icon: Icons.interests_outlined,
            title: 'Categoria',
            subtitle:
                'Escolha o estímulo principal para equilibrar as rodadas.',
          ),
          const SizedBox(height: 16),
          if (officialCategories.isEmpty)
            Text(
              'Preparando categorias oficiais...',
              style: UiTokens.textCaption.copyWith(
                color: _ToyCreateIpadPalette.textMuted,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final category in officialCategories)
                  _buildIpadCategoryOption(category),
              ],
            ),
          if (_selectedCategoryId == null) ...[
            const SizedBox(height: 14),
            const _ToyCreateIpadInlineNotice(
              icon: Icons.error_outline_rounded,
              label: 'Categoria obrigatória para salvar.',
              color: _ToyCreateIpadPalette.orange,
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'A categoria equilibra as rodadas e garante variedade nas brincadeiras.',
            style: UiTokens.textCaption.copyWith(
              color: _ToyCreateIpadPalette.textMid,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpadCategoryOption(CategoryDefinition category) {
    final selected = _selectedCategoryId == category.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _saving
            ? null
            : () {
                FocusScope.of(context).unfocus();
                setState(() => _selectedCategoryId = category.id);
              },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 210,
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: selected ? _ToyCreateIpadPalette.orangeLight : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? _ToyCreateIpadPalette.orange
                  : _ToyCreateIpadPalette.border,
              width: selected ? 1.5 : 1.1,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x1FF97316),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: selected
                      ? _ToyCreateIpadPalette.orange
                      : const Color(0xFFFFFBF6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  selected ? Icons.check_rounded : Icons.category_outlined,
                  color: selected ? Colors.white : _ToyCreateIpadPalette.orange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toyFormCategoryName(category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textCaption.copyWith(
                        color: _ToyCreateIpadPalette.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    finalText(
                      toyFormCategoryDevelopmentAspect(category) ??
                          toyFormCategoryExamples(category) ??
                          '',
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

  Widget finalText(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        normalized,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: UiTokens.textMicro.copyWith(
          color: _ToyCreateIpadPalette.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildIpadOrganizationCard({
    required List<Boxe> boxes,
    required List<LocationDefinition> locations,
    required bool showLocal,
  }) {
    return _ToyCreateIpadSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ToyCreateIpadSectionHeader(
            icon: Icons.inventory_2_outlined,
            title: 'Organização',
            subtitle: 'Escolha onde o brinquedo fica guardado.',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: _selectedBoxSelection,
                  decoration: InputDecoration(
                    labelText: 'Caixa',
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    helperText: 'Escolha uma caixa ou marque "Sem caixa".',
                    errorText: _boxSelectionTouched && !_hasExplicitBoxSelection
                        ? _locationRequiredMessage
                        : null,
                  ),
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Selecione uma caixa'),
                    ),
                    const DropdownMenuItem<String?>(
                      value: _noBoxOptionValue,
                      child: Text('Sem caixa'),
                    ),
                    ...boxes.map(
                      (box) => DropdownMenuItem<String?>(
                        value: box.id,
                        child: Text('Caixa ${box.number} - ${box.local}'),
                      ),
                    ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => setState(() {
                            _selectedBoxSelection = value;
                            _boxSelectionTouched = true;
                            if (!_isWithoutBoxSelected) {
                              _selectedLooseLocation = null;
                            }
                          }),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: FilledButton.tonalIcon(
                  onPressed: _saving ? null : _createBox,
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Nova caixa'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _ToyCreateIpadPalette.orangeLight,
                    foregroundColor: const Color(0xFFC2410C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: _localFieldAnimationDuration,
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: _localFieldAnimationDuration,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: const Offset(0, -0.03),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: showLocal
                  ? Padding(
                      key: const ValueKey('ipad-local-field'),
                      padding: const EdgeInsets.only(top: 16),
                      child: DropdownButtonFormField<String?>(
                        initialValue: _selectedLooseLocation,
                        decoration: const InputDecoration(
                          labelText: 'Local',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                        items: <DropdownMenuItem<String?>>[
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Sem local'),
                          ),
                          ...locations.map(
                            (location) => DropdownMenuItem<String?>(
                              value: location.name,
                              child: Text(location.name),
                            ),
                          ),
                        ],
                        onChanged: _saving
                            ? null
                            : (value) => setState(
                                  () => _selectedLooseLocation = value,
                                ),
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('ipad-local-field-hidden'),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          const _ToyCreateIpadInlineNotice(
            icon: Icons.check_circle_outline,
            label: 'Todo brinquedo novo entra no rodízio após salvar.',
            color: _ToyCreateIpadPalette.green,
          ),
        ],
      ),
    );
  }

  Widget _buildIpadSecondaryActionsCard() {
    return _ToyCreateIpadSurface(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ações',
                  style: UiTokens.textBody.copyWith(
                    color: _ToyCreateIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Salve e continue cadastrando quando estiver organizando muitos brinquedos.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _ToyCreateIpadPalette.textMid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.tonalIcon(
            onPressed: _saving ? null : _saveAndAddAnother,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Salvar e outro'),
            style: FilledButton.styleFrom(
              backgroundColor: _ToyCreateIpadPalette.orangeLight,
              foregroundColor: const Color(0xFFC2410C),
              minimumSize: const Size(162, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
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
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    return Scaffold(
      backgroundColor: isTablet ? _ToyCreateIpadPalette.bg : UiTokens.bg,
      appBar: isTablet ? null : AppBar(title: const Text('Novo brinquedo')),
      body: SafeArea(
        child: Padding(
          padding:
              isTablet ? EdgeInsets.zero : const EdgeInsets.all(UiTokens.m),
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
                      final officialCategories =
                          officialToyFormCategories(categories);
                      if (_selectedCategoryId != null &&
                          !officialCategories
                              .any((c) => c.id == _selectedCategoryId)) {
                        _selectedCategoryId = null;
                      }

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

                      if (isTablet) {
                        return _buildIpadLayout(
                          officialCategories: officialCategories,
                          boxes: boxes,
                          locations: locations,
                          showLocal: showLocal,
                        );
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
                                  color: UiTokens.actionOrangeSoft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Novo brinquedo',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(
                                          height: UiTokens.spacingXs),
                                      Text(
                                        'Foto, categoria e lugar de guardar. O essencial em poucos passos.',
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
                                      if (officialCategories.isNotEmpty)
                                        CategoryQuickPicker<CategoryDefinition>(
                                          categories: officialCategories,
                                          selectedId: _selectedCategoryId,
                                          disabled: _saving,
                                          getId: (c) => c.id,
                                          getName: toyFormCategoryName,
                                          getExamples: toyFormCategoryExamples,
                                          getDevelopmentAspect:
                                              toyFormCategoryDevelopmentAspect,
                                          onSelected: (id) => setState(
                                            () => _selectedCategoryId = id,
                                          ),
                                        ),
                                      if (officialCategories.isEmpty) ...[
                                        Text(
                                          'Preparando categorias oficiais...',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: UiTokens.textSecondary,
                                              ),
                                        ),
                                      ],
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
                                                        'Selecione uma caixa',
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

class _ToyCreateIpadSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ToyCreateIpadSurface({
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _ToyCreateIpadPalette.border, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14A76A2B),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ToyCreateIpadSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ToyCreateIpadSectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _ToyCreateIpadPalette.orangeLight,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: _ToyCreateIpadPalette.orange, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textBody.copyWith(
                  color: _ToyCreateIpadPalette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textCaption.copyWith(
                  color: _ToyCreateIpadPalette.textMid,
                  fontWeight: FontWeight.w600,
                  height: 1.28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToyCreateIpadPhotoEmpty extends StatelessWidget {
  const _ToyCreateIpadPhotoEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _ToyCreateIpadPalette.photoBg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _ToyCreateIpadPalette.border),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: _ToyCreateIpadPalette.textMuted,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Nenhuma foto adicionada',
              style: UiTokens.textBody.copyWith(
                color: _ToyCreateIpadPalette.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Toque em câmera ou galeria para incluir.',
              style: UiTokens.textCaption.copyWith(
                color: _ToyCreateIpadPalette.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToyCreateIpadMiniPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;

  const _ToyCreateIpadMiniPill({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UiTokens.textMicro.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToyCreateIpadInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ToyCreateIpadInfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ToyCreateIpadPalette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _ToyCreateIpadPalette.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _ToyCreateIpadPalette.text,
                    fontWeight: FontWeight.w900,
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

class _ToyCreateIpadInlineNotice extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ToyCreateIpadInlineNotice({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: UiTokens.textCaption.copyWith(
                color: _ToyCreateIpadPalette.textMid,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToyCreateIpadButtonStyles {
  static ButtonStyle outline() {
    return OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF6B4F30),
      side: const BorderSide(color: _ToyCreateIpadPalette.border),
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _ToyCreateIpadPalette {
  static const bg = Color(0xFFFDF7F0);
  static const photoBg = Color(0xFFF0E5D8);
  static const border = Color(0xFFF3E2D0);
  static const orange = Color(0xFFF97316);
  static const orangeLight = Color(0xFFFFF4E8);
  static const orangeBorder = Color(0xFFFDD7AF);
  static const text = Color(0xFF25180A);
  static const textMid = Color(0xFF6B4F30);
  static const textMuted = Color(0xFFA8896A);
  static const green = Color(0xFF16A34A);
  static const greenLight = Color(0xFFEAFBF0);
  static const greenBorder = Color(0xFFB6E8C8);
  static const purple = Color(0xFF8B5CF6);
}
