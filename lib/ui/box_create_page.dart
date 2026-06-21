import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/locations_manage_page.dart';
import 'package:rodizio_brinquedos_v3/ui/photo_crop_page.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';

class BoxCreatePage extends StatefulWidget {
  final ToyRepository toyRepository;
  final SettingsRepository? settingsRepository;
  final PurchaseService? purchaseService;
  final int topNavigationIndex;
  final VoidCallback? onOpenHomeTab;
  final VoidCallback? onOpenRoundTab;
  final VoidCallback? onOpenWeeklyPlanning;
  final VoidCallback? onOpenToysTab;
  final VoidCallback? onOpenBoxesTab;
  final VoidCallback? onOpenSettings;

  const BoxCreatePage({
    super.key,
    required this.toyRepository,
    this.settingsRepository,
    this.purchaseService,
    this.topNavigationIndex = 2,
    this.onOpenHomeTab,
    this.onOpenRoundTab,
    this.onOpenWeeklyPlanning,
    this.onOpenToysTab,
    this.onOpenBoxesTab,
    this.onOpenSettings,
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
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
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

  void _cancel() {
    Navigator.of(context).maybePop();
  }

  VoidCallback _navigationAction(VoidCallback? action) {
    return action ?? _cancel;
  }

  Future<void> _openLocationsPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocationsManagePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Widget _buildIpadTopNavigation() {
    return AppTopNavigation(
      currentIndex: widget.topNavigationIndex,
      onHomeTap: _navigationAction(widget.onOpenHomeTab),
      onRoundTap: _navigationAction(widget.onOpenRoundTab),
      onWeeklyPlanningTap: _navigationAction(widget.onOpenWeeklyPlanning),
      onToysTap: _navigationAction(widget.onOpenToysTab),
      onBoxesTap: _navigationAction(widget.onOpenBoxesTab),
      onSettingsTap: _navigationAction(widget.onOpenSettings),
    );
  }

  String _boxName(int nextNumber) => 'Caixa $nextNumber';

  String _locationPreview(List<LocationDefinition> locations) {
    final local = _resolveLocalToSave(locations);
    if (local.isNotEmpty) return local;
    if (locations.isEmpty) return 'Sem local cadastrado';
    return 'Escolha um local';
  }

  Widget _buildMobileLayout({
    required int nextNumber,
    required List<LocationDefinition> locations,
    required String? selectedLocationId,
    required bool canSave,
  }) {
    return Padding(
      padding: const EdgeInsets.all(UiTokens.m),
      child: ListView(
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  initialValue: _boxName(nextNumber),
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Nome'),
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
                        : (value) =>
                            setState(() => _selectedLocationId = value),
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
                                () => _showExtraLocal = !_showExtraLocal,
                              ),
                      child: Text(
                        _showExtraLocal ? 'Ocultar local extra' : 'Local extra',
                      ),
                    ),
                    if (locations.isNotEmpty)
                      Text(
                        'Ou use um local j\u00e1 cadastrado.',
                        style: Theme.of(context).textTheme.bodySmall,
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
                  inputFormatters: [LengthLimitingTextInputFormatter(120)],
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
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(UiTokens.radiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nenhum local cadastrado',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: UiTokens.spacingXs),
                        Text(
                          'Voc\u00ea pode salvar sem local ou cadastrar locais nas Configura\u00e7\u00f5es.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: UiTokens.spacingSm),
                        OutlinedButton.icon(
                          onPressed: _saving ? null : _openLocationsPage,
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
      ),
    );
  }

  Widget _buildIpadLayout({
    required int nextNumber,
    required List<LocationDefinition> locations,
    required String? selectedLocationId,
    required bool canSave,
  }) {
    final bottomPadding = AppBottomNavigation.reservedScrollPadding(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(24, 18, 24, bottomPadding),
      physics: const BouncingScrollPhysics(),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1032),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildIpadTopNavigation(),
                const SizedBox(height: 18),
                _BoxCreateIpadHeader(
                  title: 'Nova caixa',
                  subtitle: 'Organize onde os brinquedos ficam guardados.',
                  canSave: canSave,
                  saving: _saving,
                  onSave: () => _save(locations),
                  onCancel: _cancel,
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final gap = constraints.maxWidth >= 980 ? 22.0 : 18.0;
                    final leftWidth = (constraints.maxWidth - gap) * 0.58;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: leftWidth.clamp(520.0, 650.0),
                          child: _buildIpadInfoCard(
                            nextNumber: nextNumber,
                            locations: locations,
                            selectedLocationId: selectedLocationId,
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildIpadPreviewCard(
                                nextNumber: nextNumber,
                                locations: locations,
                              ),
                              const SizedBox(height: 16),
                              _buildIpadTipCard(),
                              const SizedBox(height: 16),
                              _buildIpadActionsCard(
                                locations: locations,
                                canSave: canSave,
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
    );
  }

  Widget _buildIpadInfoCard({
    required int nextNumber,
    required List<LocationDefinition> locations,
    required String? selectedLocationId,
  }) {
    return _BoxCreateIpadSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BoxCreateIpadSectionTitle(
            icon: Icons.inventory_2_outlined,
            title: 'Informa\u00e7\u00f5es da caixa',
            subtitle:
                'Nome autom\u00e1tico, local e observa\u00e7\u00f5es reais.',
          ),
          const SizedBox(height: 18),
          TextFormField(
            initialValue: _boxName(nextNumber),
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Nome da caixa',
              prefixIcon: Icon(Icons.inventory_2_outlined),
              helperText: 'O app numera a caixa automaticamente ao salvar.',
            ),
          ),
          const SizedBox(height: 14),
          if (locations.isNotEmpty)
            DropdownButtonFormField<String>(
              key: ValueKey('ipad-location-$selectedLocationId'),
              initialValue: selectedLocationId,
              decoration: const InputDecoration(
                labelText: 'Local',
                hintText: 'Selecione um local',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              items: locations
                  .map(
                    (location) => DropdownMenuItem<String>(
                      value: location.id,
                      child: Text(location.name),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _selectedLocationId = value),
            ),
          if (locations.isNotEmpty) const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _saving
                    ? null
                    : () => setState(() => _showExtraLocal = !_showExtraLocal),
                icon: Icon(
                  _showExtraLocal
                      ? Icons.visibility_off_outlined
                      : Icons.add_location_alt_outlined,
                ),
                label: Text(
                  _showExtraLocal ? 'Ocultar local extra' : 'Local extra',
                ),
              ),
              if (locations.isNotEmpty)
                Text(
                  'Use um local cadastrado ou informe um local manual.',
                  style: UiTokens.textCaption.copyWith(
                    color: _BoxCreateIpadPalette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (_showExtraLocal) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _extraLocalController,
              enabled: !_saving,
              decoration: const InputDecoration(
                labelText: 'Local extra (manual)',
                hintText: 'Ex.: Sala do fundo',
                prefixIcon: Icon(Icons.edit_location_alt_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _notesController,
            enabled: !_saving,
            minLines: 3,
            maxLines: 5,
            maxLength: 120,
            inputFormatters: [LengthLimitingTextInputFormatter(120)],
            decoration: const InputDecoration(
              labelText: 'Observa\u00e7\u00e3o (opcional)',
              hintText: 'Ex.: pe\u00e7as pequenas na parte de cima',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (locations.isEmpty) ...[
            const SizedBox(height: 10),
            _BoxCreateIpadNotice(
              title: 'Nenhum local cadastrado',
              message:
                  'Voc\u00ea pode salvar sem local ou cadastrar locais nas Configura\u00e7\u00f5es.',
              actionLabel: 'Gerenciar locais',
              onAction: _saving ? null : _openLocationsPage,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIpadPreviewCard({
    required int nextNumber,
    required List<LocationDefinition> locations,
  }) {
    final path = (_photoSourcePath ?? '').trim();
    final local = _locationPreview(locations);

    return _BoxCreateIpadSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BoxCreateIpadSectionTitle(
            icon: Icons.visibility_outlined,
            title: 'Pr\u00e9via',
            subtitle: 'Como a caixa vai aparecer na organiza\u00e7\u00e3o.',
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _saving ? null : _openPhotoOptions,
            borderRadius: BorderRadius.circular(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 1.35,
                child: path.isEmpty
                    ? Container(
                        color: _BoxCreateIpadPalette.photoBg,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: _BoxCreateIpadPalette.orangeLight,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _BoxCreateIpadPalette.orangeBorder,
                                ),
                              ),
                              child: const Icon(
                                Icons.photo_camera_outlined,
                                color: _BoxCreateIpadPalette.orange,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Adicionar foto',
                              style: UiTokens.textBody.copyWith(
                                color: _BoxCreateIpadPalette.text,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Opcional para identificar melhor',
                              style: UiTokens.textCaption.copyWith(
                                color: _BoxCreateIpadPalette.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => Container(
                          color: _BoxCreateIpadPalette.photoBg,
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _BoxCreateIpadPalette.orangeLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _BoxCreateIpadPalette.orangeBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: _BoxCreateIpadPalette.orange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _boxName(nextNumber),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textBody.copyWith(
                          color: _BoxCreateIpadPalette.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        local,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textCaption.copyWith(
                          color: _BoxCreateIpadPalette.textMid,
                          fontWeight: FontWeight.w700,
                        ),
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

  Widget _buildIpadTipCard() {
    return const _BoxCreateIpadSupportCard(
      icon: Icons.lightbulb_outline_rounded,
      title: 'Dica',
      message:
          'Use nomes de locais que a fam\u00edlia reconhece no dia a dia. Isso deixa a busca dos brinquedos mais r\u00e1pida.',
    );
  }

  Widget _buildIpadActionsCard({
    required List<LocationDefinition> locations,
    required bool canSave,
  }) {
    return _BoxCreateIpadSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BoxCreateIpadSectionTitle(
            icon: Icons.touch_app_outlined,
            title: 'A\u00e7\u00f5es',
            subtitle: 'Atalhos seguros para concluir o cadastro.',
          ),
          const SizedBox(height: 14),
          _BoxCreateIpadActionRow(
            icon: Icons.photo_camera_outlined,
            title: (_photoSourcePath ?? '').trim().isEmpty
                ? 'Adicionar foto'
                : 'Alterar foto',
            subtitle: 'Foto opcional da caixa',
            onTap: _saving ? null : _openPhotoOptions,
          ),
          const Divider(height: 14, color: _BoxCreateIpadPalette.border),
          _BoxCreateIpadActionRow(
            icon: Icons.place_outlined,
            title: 'Gerenciar locais',
            subtitle: locations.isEmpty
                ? 'Crie locais para organizar melhor'
                : '${locations.length} locais cadastrados',
            onTap: _saving ? null : _openLocationsPage,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _cancel,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: canSave ? () => _save(locations) : null,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Salvando...' : 'Salvar'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: _BoxCreateIpadPalette.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIpad = MediaQuery.sizeOf(context).shortestSide >= 600;

    return Scaffold(
      backgroundColor: isIpad ? _BoxCreateIpadPalette.bg : UiTokens.bg,
      appBar: isIpad ? null : AppBar(title: const Text('Nova caixa')),
      body: SafeArea(
        bottom: !isIpad,
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

                final selectedLocationId = _selectedLocationId != null &&
                        locations.any((l) => l.id == _selectedLocationId)
                    ? _selectedLocationId
                    : null;
                if (selectedLocationId == null && _selectedLocationId != null) {
                  _selectedLocationId = null;
                }

                final extraLocalFilled =
                    _extraLocalController.text.trim().isNotEmpty;
                final canSave = !_saving &&
                    (locations.isEmpty ||
                        extraLocalFilled ||
                        _selectedLocationId != null);

                if (isIpad) {
                  return _buildIpadLayout(
                    nextNumber: nextNumber,
                    locations: locations,
                    selectedLocationId: selectedLocationId,
                    canSave: canSave,
                  );
                }

                return _buildMobileLayout(
                  nextNumber: nextNumber,
                  locations: locations,
                  selectedLocationId: selectedLocationId,
                  canSave: canSave,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BoxCreateIpadPalette {
  static const bg = Color(0xFFFDF7F0);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFF3E2D0);
  static const orange = Color(0xFFF97316);
  static const orangeDark = Color(0xFFC2410C);
  static const orangeLight = Color(0xFFFFF3E8);
  static const orangeBorder = Color(0xFFFFD2AE);
  static const text = Color(0xFF25180A);
  static const textMid = Color(0xFF6B4F30);
  static const textMuted = Color(0xFFA8896A);
  static const photoBg = Color(0xFFF2F7F1);
  static const green = Color(0xFF16A34A);
  static const greenLight = Color(0xFFEAFBF0);
  static const greenBorder = Color(0xFFBBF7D0);
  static const shadow = Color(0x14F97316);
}

class _BoxCreateIpadSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _BoxCreateIpadSurface({
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _BoxCreateIpadPalette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _BoxCreateIpadPalette.border),
        boxShadow: const [
          BoxShadow(
            color: _BoxCreateIpadPalette.shadow,
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BoxCreateIpadHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool canSave;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _BoxCreateIpadHeader({
    required this.title,
    required this.subtitle,
    required this.canSave,
    required this.saving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return _BoxCreateIpadSurface(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA11F), _BoxCreateIpadPalette.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x45F97316),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROD\u00cdZIO DE BRINQUEDOS',
                  style: UiTokens.textMicro.copyWith(
                    color: _BoxCreateIpadPalette.orange,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textTitle.copyWith(
                    color: _BoxCreateIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: UiTokens.textBody.copyWith(
                    color: _BoxCreateIpadPalette.textMid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: saving ? null : onCancel,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(128, 52),
                  foregroundColor: _BoxCreateIpadPalette.orangeDark,
                  side: const BorderSide(
                    color: _BoxCreateIpadPalette.orangeBorder,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: canSave ? onSave : null,
                icon: const Icon(Icons.save_outlined),
                label: Text(saving ? 'Salvando...' : 'Salvar caixa'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(154, 52),
                  backgroundColor: _BoxCreateIpadPalette.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE7D8C8),
                  disabledForegroundColor: _BoxCreateIpadPalette.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoxCreateIpadSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BoxCreateIpadSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _BoxCreateIpadPalette.orangeLight,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _BoxCreateIpadPalette.orangeBorder),
          ),
          child: Icon(icon, color: _BoxCreateIpadPalette.orange, size: 22),
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
                style: UiTokens.textSectionTitle.copyWith(
                  color: _BoxCreateIpadPalette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textCaption.copyWith(
                  color: _BoxCreateIpadPalette.textMuted,
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

class _BoxCreateIpadNotice extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;

  const _BoxCreateIpadNotice({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _BoxCreateIpadPalette.greenLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _BoxCreateIpadPalette.greenBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_outlined, color: _BoxCreateIpadPalette.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: UiTokens.textBody.copyWith(
                    color: _BoxCreateIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: UiTokens.textCaption.copyWith(
                    color: _BoxCreateIpadPalette.textMid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _BoxCreateIpadSupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _BoxCreateIpadSupportCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _BoxCreateIpadSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _BoxCreateIpadPalette.orangeLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _BoxCreateIpadPalette.orangeBorder),
            ),
            child: Icon(icon, color: _BoxCreateIpadPalette.orange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: UiTokens.textBody.copyWith(
                    color: _BoxCreateIpadPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: UiTokens.textCaption.copyWith(
                    color: _BoxCreateIpadPalette.textMid,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

class _BoxCreateIpadActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _BoxCreateIpadActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _BoxCreateIpadPalette.orangeLight,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _BoxCreateIpadPalette.orangeBorder),
                ),
                child:
                    Icon(icon, color: _BoxCreateIpadPalette.orange, size: 22),
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
                        color: _BoxCreateIpadPalette.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UiTokens.textCaption.copyWith(
                        color: _BoxCreateIpadPalette.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: _BoxCreateIpadPalette.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
