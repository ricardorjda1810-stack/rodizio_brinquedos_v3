import 'dart:io';

import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/core/analytics/app_analytics.dart';
import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/features/brinquedos/brinquedos_catalog_controller.dart';
import 'package:rodizio_brinquedos_v3/features/brinquedos/brinquedos_catalog_state.dart';
import 'package:rodizio_brinquedos_v3/l10n/app_localizations.dart';
import 'package:rodizio_brinquedos_v3/services/purchase_service.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_category_form_options.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_create_page.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/active_round_list.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_bottom_navigation.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/app_surface_card.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/empty_state.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/filter_bar.dart';

const String _toyBoxNoSelectionValue = '__sem_selecao_caixa__';
const String _toyBoxWithoutBoxValue = '__sem_caixa__';
const String _toyBoxRequiredMessage =
    'Selecione uma caixa ou escolha "Sem caixa" para salvar o brinquedo.';

class BrinquedosPage extends StatefulWidget {
  final ToyRepository toyRepository;
  final RoundRepository roundRepository;
  final SettingsRepository settingsRepository;
  final PurchaseService? purchaseService;
  final VoidCallback onOpenRodizioTab;
  final VoidCallback? onOpenHomeTab;
  final VoidCallback? onOpenRoundTab;
  final VoidCallback? onOpenWeeklyPlanning;
  final VoidCallback? onOpenToysTab;
  final VoidCallback? onOpenBoxesTab;
  final VoidCallback? onOpenSettings;
  final String? requestedBoxFilterId;
  final int requestedBoxFilterVersion;

  const BrinquedosPage({
    super.key,
    required this.toyRepository,
    required this.roundRepository,
    required this.settingsRepository,
    this.purchaseService,
    required this.onOpenRodizioTab,
    this.onOpenHomeTab,
    this.onOpenRoundTab,
    this.onOpenWeeklyPlanning,
    this.onOpenToysTab,
    this.onOpenBoxesTab,
    this.onOpenSettings,
    this.requestedBoxFilterId,
    this.requestedBoxFilterVersion = 0,
  });

  @override
  State<BrinquedosPage> createState() => _BrinquedosPageState();
}

class _BrinquedosPageState extends State<BrinquedosPage> {
  static const String _localAll = '__ALL__';
  static const String _localNone = '__NONE__';

  final TextEditingController _searchController = TextEditingController();
  late final BrinquedosCatalogController _controller;
  bool _startingRound = false;

  static const String _menuEditCategory = 'edit_category';
  static const String _menuEditLocation = 'edit_location';
  static const String _menuEditBox = 'edit_box';

  AppFeedback get _feedback => AppFeedback(widget.settingsRepository);

  String _selectedLocalFilter = _localAll;

  Widget _dropdownLabel(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller =
        BrinquedosCatalogController(toyRepository: widget.toyRepository);
    _controller.init();
    _applyRequestedBoxFilter();

    _searchController.addListener(() {
      _controller.setQueryText(_searchController.text);
    });
  }

  @override
  void didUpdateWidget(covariant BrinquedosPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requestedBoxFilterVersion !=
        widget.requestedBoxFilterVersion) {
      _applyRequestedBoxFilter();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    _controller.clearFilters();
    setState(() => _selectedLocalFilter = _localAll);
  }

  void _applyRequestedBoxFilter() {
    final requested = widget.requestedBoxFilterId;
    if (requested == null || requested.isEmpty) return;
    _controller.setBoxFilter(requested);
    _selectedLocalFilter = _localAll;
  }

  void _openToyDetail(BuildContext context, String toyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToyDetailPage(
          toyId: toyId,
          toyRepository: widget.toyRepository,
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
  }

  Future<void> _openToyCreate(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToyCreatePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
          purchaseService: widget.purchaseService,
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

  Future<void> _startRound() async {
    if (_startingRound) return;

    setState(() => _startingRound = true);
    try {
      if (!mounted) return;
      final result = await widget.roundRepository.startRound();
      if (!mounted) return;
      if (!result.created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nenhum brinquedo dispon\u00edvel para iniciar a rodada.',
            ),
          ),
        );
        return;
      }

      await _feedback.onRoundStarted();
      await AppAnalytics.logRoundCreated(
        toyCount: result.selectedCount,
        source: 'toys_tab',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Rodada criada com ${result.selectedCount} brinquedos.'),
        ),
      );
      widget.onOpenRodizioTab();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'N\u00e3o foi poss\u00edvel iniciar o rod\u00edzio: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _startingRound = false);
      }
    }
  }

  Future<void> _openSearchDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Buscar'),
          content: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Digite o nome do brinquedo...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar',
                      onPressed: () => _searchController.clear(),
                      icon: const Icon(Icons.close),
                    ),
            ),
            onSubmitted: (_) => Navigator.of(ctx).pop(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  String _categoryLabel(
    BrinquedosCatalogItem item,
    Map<String, String> categoryById,
    AppLocalizations l10n,
  ) {
    final id = item.toy.categoryId.trim();
    if (id.isEmpty) return l10n.noCategory;
    return l10n.categoryName(categoryById[id] ?? id);
  }

  String _boxAndLocationLabel(
      BrinquedosCatalogItem item, AppLocalizations l10n) {
    final boxName =
        item.box != null ? l10n.boxNumber(item.box!.number) : l10n.noBox;
    final boxLocation = (item.box?.local ?? '').trim();
    final toyLocation = (item.toy.locationText ?? '').trim();
    final location = boxLocation.isNotEmpty
        ? l10n.value(boxLocation)
        : (toyLocation.isNotEmpty ? l10n.value(toyLocation) : l10n.noLocation);
    return l10n.boxAndLocation(boxName: boxName, location: location);
  }

  Future<void> _editToyCategoryFromList(
    BuildContext context,
    BrinquedosCatalogItem item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await widget.toyRepository.ensureOfficialToyFormCategories();
    if (!context.mounted) return;

    final selectedCategoryId = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String? selectedId = item.toy.categoryId;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar categoria'),
              content: StreamBuilder(
                stream: widget.toyRepository.watchCategories(activeOnly: true),
                builder: (context, snapshot) {
                  final allCategories = snapshot.data ?? const [];
                  final categories = officialToyFormCategories(allCategories);
                  if (categories.isEmpty) {
                    return const Text('Nenhuma categoria oficial ativa.');
                  }

                  final currentIsOfficial =
                      categories.any((c) => c.id == item.toy.categoryId);
                  if (!categories.any((c) => c.id == selectedId)) {
                    selectedId = null;
                  }
                  final currentLabel = _categoryNameForId(
                    allCategories,
                    item.toy.categoryId,
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
        selectedCategoryId == item.toy.categoryId) {
      return;
    }

    try {
      await widget.toyRepository.updateToyCategory(
        toyId: item.toy.id,
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

  Future<void> _editToyLocationFromList(
    BuildContext context,
    BrinquedosCatalogItem item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (item.box != null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Este brinquedo ja usa o local da caixa.'),
        ),
      );
      return;
    }

    final locations = await widget.toyRepository.watchLocations().first;
    if (!context.mounted) return;

    String? selectedLocation = (item.toy.locationText ?? '').trim();
    if (selectedLocation.isEmpty) {
      selectedLocation = null;
    }
    if (selectedLocation != null &&
        !locations.any((l) => l.name == selectedLocation)) {
      selectedLocation = null;
    }

    var confirmed = false;
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Editar local'),
            content: SizedBox(
              width: double.maxFinite,
              child: DropdownButtonFormField<String?>(
                initialValue: selectedLocation,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Local (sem caixa)',
                ),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(
                    value: null,
                    child: _dropdownLabel('Sem local'),
                  ),
                  ...locations.map(
                    (l) => DropdownMenuItem<String?>(
                      value: l.name,
                      child: _dropdownLabel(l.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setDialogState(() => selectedLocation = value);
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
                  confirmed = true;
                  Navigator.of(ctx).pop(selectedLocation);
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );

    if (!confirmed) return;
    if (result == (item.toy.locationText ?? '').trim()) return;

    try {
      await widget.toyRepository.updateToyLocationText(
        toyId: item.toy.id,
        locationText: result,
      );
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Local atualizado.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao atualizar local: $e')),
      );
    }
  }

  Future<void> _editToyBoxFromList(
    BuildContext context,
    BrinquedosCatalogItem item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final boxes = await widget.toyRepository.watchBoxes().first;
    if (!context.mounted) return;

    String selectedBoxSelection = item.toy.boxId ?? _toyBoxNoSelectionValue;
    var confirmed = false;
    if (item.toy.boxId != null && !boxes.any((b) => b.id == item.toy.boxId)) {
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
                decoration: const InputDecoration(
                  labelText: 'Caixa',
                ),
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
    if (result == item.toy.boxId) return;

    try {
      await widget.toyRepository.setToyBox(
        toyId: item.toy.id,
        boxId: result,
      );
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

  Widget _buildToyRow(
    BuildContext context,
    BrinquedosCatalogItem item, {
    required String categoryLabel,
  }) {
    final l10n = context.l10n;
    final displayName = l10n.toyDisplayName(item.toy.name);

    return InkWell(
      borderRadius: BorderRadius.circular(UiTokens.radiusButton),
      onTap: () => _openToyDetail(context, item.toy.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiTokens.spacingSm,
          vertical: UiTokens.spacingSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoundToyThumb(path: item.toy.photoPath, dense: true),
            const SizedBox(width: UiTokens.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _boxAndLocationLabel(item, l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    categoryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF97316),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: UiTokens.spacingXs),
            PopupMenuButton<String>(
              tooltip: 'Mais op\u00e7\u00f5es',
              onSelected: (value) {
                if (value == _menuEditCategory) {
                  _editToyCategoryFromList(context, item);
                  return;
                }
                if (value == _menuEditBox) {
                  _editToyBoxFromList(context, item);
                  return;
                }
                if (value == _menuEditLocation) {
                  _editToyLocationFromList(context, item);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: _menuEditCategory,
                  child: Text('Editar categoria'),
                ),
                const PopupMenuItem<String>(
                  value: _menuEditBox,
                  child: Text('Editar caixa'),
                ),
                PopupMenuItem<String>(
                  value: _menuEditLocation,
                  enabled: item.box == null,
                  child: const Text('Editar local'),
                ),
              ],
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(UiTokens.radiusButton),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.more_vert, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToyList(
    BuildContext context,
    List<BrinquedosCatalogItem> items, {
    required Map<String, String> categoryById,
  }) {
    final children = <Widget>[];
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      children.add(
        _buildToyRow(
          context,
          item,
          categoryLabel: _categoryLabel(item, categoryById, context.l10n),
        ),
      );
      if (index < items.length - 1) {
        children.add(const Divider(height: 1, thickness: 0.6));
      }
    }

    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(
        UiTokens.spacingMd,
        UiTokens.spacingMd,
        UiTokens.spacingMd,
        UiTokens.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.catalog,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: UiTokens.spacingXs),
          Text(
            context.l10n.isEn
                ? '${items.length} items in this view'
                : '${items.length} itens nesta visualiza\u00e7\u00e3o',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: UiTokens.spacingMd),
          Column(children: children),
        ],
      ),
    );
  }

  List<FilterOption> _boxOptions(
    BrinquedosCatalogState state,
    AppLocalizations l10n,
  ) {
    return [
      FilterOption(
        id: BrinquedosCatalogState.boxFilterAll,
        label: '${l10n.box}: ${l10n.all}',
      ),
      FilterOption(
        id: BrinquedosCatalogState.boxFilterNone,
        label: '${l10n.box}: ${l10n.noBox}',
      ),
      ...state.boxes.map(
        (b) => FilterOption(
          id: b.id,
          label: l10n.boxLocationLabel(b.number, b.local),
        ),
      ),
    ];
  }

  List<FilterOption> _categoryOptions(
    BrinquedosCatalogState state,
    AppLocalizations l10n,
  ) {
    return [
      FilterOption(id: '', label: '${l10n.category}: ${l10n.all}'),
      ...state.categories.map(
        (c) => FilterOption(
          id: c.id,
          label: '${l10n.category}: ${l10n.categoryName(c.label)}',
        ),
      ),
    ];
  }

  ({List<FilterOption> locations, bool hasRealLocations}) _locationOptions(
    List<BrinquedosCatalogItem> baseItems,
    AppLocalizations l10n,
  ) {
    final set = <String>{};

    for (final it in baseItems) {
      final loc = _effectiveLocation(it);
      if (loc.isNotEmpty) set.add(loc);
    }

    final list = set.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return (
      locations: [
        FilterOption(id: _localAll, label: '${l10n.location}: ${l10n.all}'),
        FilterOption(
          id: _localNone,
          label: '${l10n.location}: ${l10n.noLocation}',
        ),
        ...list.map(
          (loc) => FilterOption(
            id: loc,
            label: '${l10n.location}: ${l10n.value(loc)}',
          ),
        ),
      ],
      hasRealLocations: list.isNotEmpty,
    );
  }

  List<BrinquedosCatalogItem> _applyLocalFilter(
    List<BrinquedosCatalogItem> items,
  ) {
    final f = _selectedLocalFilter;

    if (f == _localAll) return items;

    if (f == _localNone) {
      return items.where((it) => _effectiveLocation(it).isEmpty).toList();
    }

    return items.where((it) => _effectiveLocation(it) == f).toList();
  }

  String _effectiveLocation(BrinquedosCatalogItem item) {
    final toyLocation = (item.toy.locationText ?? '').trim();
    if (toyLocation.isNotEmpty) return toyLocation;
    final boxLocation = (item.box?.local ?? '').trim();
    if (boxLocation.isNotEmpty) return boxLocation;
    return '';
  }

  bool _hasActiveFilters(BrinquedosCatalogState state) {
    final hasQuery = _searchController.text.trim().isNotEmpty;
    final hasBox =
        state.selectedBoxFilter != BrinquedosCatalogState.boxFilterAll;
    final hasCat = (state.selectedCategoryId ?? '').isNotEmpty;
    final hasLocal = _selectedLocalFilter != _localAll;
    return hasQuery || hasBox || hasCat || hasLocal;
  }

  Widget _buildIpadCatalogFigmaLayout(
    BuildContext context, {
    required BrinquedosCatalogState state,
    required List<BrinquedosCatalogItem> visibleItems,
    required Map<String, String> categoryById,
    required List<FilterOption> locationOptions,
    required String selectedCategoryId,
    required bool showClear,
  }) {
    final bottomPadding = AppBottomNavigation.reservedScrollPadding(context);
    final l10n = context.l10n;
    final boxOptions = _boxOptions(state, l10n);
    final categoryOptions = _categoryOptions(state, l10n);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnsHeight =
            (constraints.maxHeight - bottomPadding - 24 - 134 - 18)
                .clamp(760.0, 1040.0)
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
                    _CatalogIpadHeader(
                      totalItems: state.totalItemsCount,
                      visibleItems: visibleItems.length,
                      filtersActive: showClear,
                      onNewToy: () => _openToyCreate(context),
                      onFiltersPressed: showClear ? _clearFilters : () {},
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: columnsHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _CatalogIpadCatalogCard(
                              items: visibleItems,
                              totalItems: state.totalItemsCount,
                              categoryById: categoryById,
                              filtersActive: showClear,
                              onToyTap: (toyId) =>
                                  _openToyDetail(context, toyId),
                              onClearFilters: _clearFilters,
                              onNewToy: () => _openToyCreate(context),
                            ),
                          ),
                          const SizedBox(width: 18),
                          SizedBox(
                            width: 332,
                            child: _CatalogIpadSideColumn(
                              searchController: _searchController,
                              boxOptions: boxOptions,
                              selectedBoxId: state.selectedBoxFilter,
                              onBoxChanged: _controller.setBoxFilter,
                              categoryOptions: categoryOptions,
                              selectedCategoryId: selectedCategoryId,
                              onCategoryChanged: (id) => _controller
                                  .setCategoryFilter(id.isEmpty ? null : id),
                              locationOptions: locationOptions,
                              selectedLocationId: _selectedLocalFilter,
                              onLocationChanged: (id) =>
                                  setState(() => _selectedLocalFilter = id),
                              totalItems: state.totalItemsCount,
                              boxesCount: state.boxes.length,
                              visibleItems: visibleItems,
                              onClearFilters: showClear ? _clearFilters : null,
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
    final l10n = context.l10n;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isIpad = constraints.maxWidth >= 860;

          return ColoredBox(
            color: isIpad ? _CatalogIpadPalette.bg : Colors.transparent,
            child: StreamBuilder<BrinquedosCatalogState>(
              stream: _controller.stream,
              initialData: BrinquedosCatalogState.empty,
              builder: (context, snapshot) {
                final state = snapshot.data ?? BrinquedosCatalogState.empty;

                final selectedCategoryId = state.selectedCategoryId ?? '';
                final baseItems = state.filteredItems;
                final categoryById = <String, String>{
                  for (final c in state.categories)
                    c.id: l10n.categoryName(c.label),
                };

                final locInfo = _locationOptions(baseItems, l10n);
                if (!locInfo.locations
                    .any((e) => e.id == _selectedLocalFilter)) {
                  _selectedLocalFilter = _localAll;
                }

                final visibleItems = _applyLocalFilter(baseItems);
                final showClear = _hasActiveFilters(state);

                if (state.loading && state.totalItemsCount == 0) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isIpad ? _CatalogIpadPalette.orange : null,
                    ),
                  );
                }

                if (isIpad) {
                  return _buildIpadCatalogFigmaLayout(
                    context,
                    state: state,
                    visibleItems: visibleItems,
                    categoryById: categoryById,
                    locationOptions: locInfo.locations,
                    selectedCategoryId: selectedCategoryId,
                    showClear: showClear,
                  );
                }

                if (state.totalItemsCount == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: UiTokens.m),
                    child: EmptyState(
                      icon: Icons.toys,
                      title: l10n.isEn
                          ? 'Add the toys from your home'
                          : 'Agora cadastre os brinquedos da sua casa',
                      message: l10n.isEn
                          ? 'Add real toys to build your visual catalog.'
                          : 'Adicione os brinquedos reais para montar seu cat\u00e1logo visual.',
                      actionLabel: l10n.newToy,
                      onAction: () => _openToyCreate(context),
                    ),
                  );
                }

                if (visibleItems.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: UiTokens.m),
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: l10n.isEn ? 'No results' : 'Nenhum resultado',
                      message: l10n.isEn
                          ? 'Adjust search and filters to find toys.'
                          : 'Ajuste busca e filtros para encontrar brinquedos.',
                      actionLabel: l10n.isEn ? 'Clear' : 'Limpar',
                      onAction: _clearFilters,
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UiTokens.m),
                  child: ListView(
                    padding: EdgeInsets.only(
                      top: UiTokens.m,
                      bottom: UiTokens.spacingXl +
                          MediaQuery.paddingOf(context).bottom +
                          88,
                    ),
                    children: [
                      AppSurfaceCard(
                        padding: const EdgeInsets.all(UiTokens.spacingMd),
                        color: UiTokens.actionOrangeSoft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.isEn ? 'Toys at home' : 'Brinquedos da casa',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: UiTokens.spacingXs),
                            Text(
                              l10n.isEn
                                  ? 'Add, find, and organize toys without wasting time.'
                                  : 'Cadastre, encontre e organize os brinquedos sem perder tempo.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: UiTokens.spacingSm),
                            Wrap(
                              spacing: UiTokens.s,
                              runSpacing: UiTokens.s,
                              children: [
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width < 560
                                      ? double.infinity
                                      : 240,
                                  child: FilledButton.icon(
                                    onPressed: () => _openToyCreate(context),
                                    icon: const Icon(Icons.add_rounded),
                                    label: Text(l10n.newToy),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width < 560
                                      ? double.infinity
                                      : 176,
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        _startingRound ? null : _startRound,
                                    icon: _startingRound
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.shuffle_rounded),
                                    label: Text(
                                      _startingRound
                                          ? (l10n.isEn
                                              ? 'Building...'
                                              : 'Montando...')
                                          : l10n.buildRotation,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UiTokens.spacingMd),
                      FilterBar(
                        boxes: _boxOptions(state, l10n),
                        categories: _categoryOptions(state, l10n),
                        locations: locInfo.locations,
                        selectedBoxId: state.selectedBoxFilter,
                        selectedCategoryId: selectedCategoryId,
                        selectedLocationId: _selectedLocalFilter,
                        onBoxChanged: _controller.setBoxFilter,
                        onCategoryChanged: (id) => _controller
                            .setCategoryFilter(id.isEmpty ? null : id),
                        onLocationChanged: (id) =>
                            setState(() => _selectedLocalFilter = id),
                        onSearchTap: () => _openSearchDialog(context),
                        showClear: showClear,
                        onClear: _clearFilters,
                      ),
                      const SizedBox(height: UiTokens.spacingSm),
                      _buildToyList(
                        context,
                        visibleItems,
                        categoryById: categoryById,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CatalogIpadHeader extends StatelessWidget {
  final int totalItems;
  final int visibleItems;
  final bool filtersActive;
  final VoidCallback onNewToy;
  final VoidCallback onFiltersPressed;

  const _CatalogIpadHeader({
    required this.totalItems,
    required this.visibleItems,
    required this.filtersActive,
    required this.onNewToy,
    required this.onFiltersPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _CatalogIpadSurface(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
      child: Row(
        children: [
          const _CatalogIpadHeroIcon(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textMicro.copyWith(
                    color: _CatalogIpadPalette.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.toys,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textTitle.copyWith(
                    color: _CatalogIpadPalette.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.isEn
                      ? 'View every toy in the catalog and keep the collection organized.'
                      : 'Veja todos os brinquedos cadastrados e mantenha o acervo organizado.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UiTokens.textCaption.copyWith(
                    color: _CatalogIpadPalette.textMuted,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _CatalogIpadHeaderStats(
            visibleItems: visibleItems,
            totalItems: totalItems,
          ),
          const SizedBox(width: 14),
          _CatalogIpadPrimaryButton(
            icon: Icons.add_rounded,
            label: l10n.newToy,
            onPressed: onNewToy,
          ),
          const SizedBox(width: 10),
          _CatalogIpadSecondaryButton(
            icon: Icons.tune_rounded,
            label: filtersActive ? '${l10n.filters} •' : l10n.filters,
            active: filtersActive,
            onPressed: onFiltersPressed,
          ),
        ],
      ),
    );
  }
}

class _CatalogIpadHeaderStats extends StatelessWidget {
  final int visibleItems;
  final int totalItems;

  const _CatalogIpadHeaderStats({
    required this.visibleItems,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      constraints: const BoxConstraints(minWidth: 104),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _CatalogIpadPalette.orangeLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _CatalogIpadPalette.orangeBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$visibleItems',
            style: UiTokens.textTitle.copyWith(
              color: _CatalogIpadPalette.orange,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            totalItems == visibleItems
                ? l10n.inCollection
                : (l10n.isEn ? 'of $totalItems' : 'de $totalItems'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _CatalogIpadPalette.textMid,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogIpadHeroIcon extends StatelessWidget {
  const _CatalogIpadHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4DF97316),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.toys_rounded,
        color: Colors.white,
        size: 29,
      ),
    );
  }
}

class _CatalogIpadCatalogCard extends StatelessWidget {
  final List<BrinquedosCatalogItem> items;
  final int totalItems;
  final Map<String, String> categoryById;
  final bool filtersActive;
  final ValueChanged<String> onToyTap;
  final VoidCallback onClearFilters;
  final VoidCallback onNewToy;

  const _CatalogIpadCatalogCard({
    required this.items,
    required this.totalItems,
    required this.categoryById,
    required this.filtersActive,
    required this.onToyTap,
    required this.onClearFilters,
    required this.onNewToy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtitle = filtersActive
        ? (l10n.isEn
            ? '${items.length} of $totalItems toys · filters active'
            : '${items.length} de $totalItems brinquedos · filtros ativos')
        : (l10n.isEn
            ? '$totalItems toys · full collection'
            : '$totalItems brinquedos · acervo completo');

    return _CatalogIpadSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 15),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.catalog,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textSectionTitle.copyWith(
                          color: _CatalogIpadPalette.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        totalItems == 0
                            ? (l10n.isEn
                                ? 'No toys added yet'
                                : 'Nenhum brinquedo cadastrado')
                            : subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UiTokens.textMicro.copyWith(
                          color: _CatalogIpadPalette.textMuted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (filtersActive) ...[
                  const SizedBox(width: 12),
                  _CatalogIpadSmallPill(
                    label: l10n.isEn ? 'Active filters' : 'Filtros ativos',
                    foreground: _CatalogIpadPalette.orange,
                    background: _CatalogIpadPalette.orangeLight,
                    border: _CatalogIpadPalette.orangeBorder,
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: _CatalogIpadPalette.border),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: items.isEmpty
                  ? _CatalogIpadEmptyCatalog(
                      totalItems: totalItems,
                      onAction: totalItems == 0 ? onNewToy : onClearFilters,
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _CatalogIpadToyListItem(
                          item: item,
                          categoryLabel: categoryById[item.toy.categoryId] ??
                              l10n.categoryName(item.toy.categoryId),
                          onTap: () => onToyTap(item.toy.id),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: _CatalogIpadCatalogFooter(
              visibleItems: items.length,
              totalItems: totalItems,
              filtersActive: filtersActive,
              onClearFilters: onClearFilters,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogIpadEmptyCatalog extends StatelessWidget {
  final int totalItems;
  final VoidCallback onAction;

  const _CatalogIpadEmptyCatalog({
    required this.totalItems,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final hasNoToys = totalItems == 0;
    final l10n = context.l10n;

    return Container(
      height: 286,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 42,
            color: _CatalogIpadPalette.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            hasNoToys
                ? (l10n.isEn
                    ? 'Add the toys from your home'
                    : 'Agora cadastre os brinquedos da sua casa')
                : (l10n.isEn ? 'No toys found' : 'Nenhum brinquedo encontrado'),
            textAlign: TextAlign.center,
            style: UiTokens.textCaption.copyWith(
              color: _CatalogIpadPalette.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              foregroundColor: _CatalogIpadPalette.orange,
              side: const BorderSide(
                color: _CatalogIpadPalette.orangeBorder,
                width: 1.5,
              ),
              backgroundColor: _CatalogIpadPalette.orangeLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            ),
            child: Text(
              hasNoToys
                  ? l10n.newToy
                  : (l10n.isEn ? 'Clear filters' : 'Limpar filtros'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogIpadToyListItem extends StatefulWidget {
  final BrinquedosCatalogItem item;
  final String categoryLabel;
  final VoidCallback onTap;

  const _CatalogIpadToyListItem({
    required this.item,
    required this.categoryLabel,
    required this.onTap,
  });

  @override
  State<_CatalogIpadToyListItem> createState() =>
      _CatalogIpadToyListItemState();
}

class _CatalogIpadToyListItemState extends State<_CatalogIpadToyListItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = l10n.toyDisplayName(widget.item.toy.name);
    final categoryStyle = _catalogCategoryStyle(
      widget.item.toy.categoryId,
      widget.categoryLabel,
    );

    final locationColor = widget.item.box == null
        ? const Color(0xFF92400E)
        : _CatalogIpadPalette.textMid;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_hovered ? 2 : 0, 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: _hovered
                ? _CatalogIpadPalette.orangeBorder
                : _CatalogIpadPalette.border,
            width: 1.4,
          ),
          boxShadow: _hovered
              ? const [
                  BoxShadow(
                    color: Color(0x1FAA6E32),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                  BoxShadow(color: Color(0x26F97316), spreadRadius: 1),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x10AA6E32),
                    blurRadius: 5,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(17),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _CatalogIpadToyPhoto(
                      path: widget.item.toy.photoPath,
                      size: 78,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: UiTokens.textSectionTitle.copyWith(
                            color: _CatalogIpadPalette.text,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            height: 1.18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _CatalogIpadSmallPill(
                              label: widget.categoryLabel.trim().isEmpty
                                  ? l10n.noCategory
                                  : l10n.categoryName(widget.categoryLabel),
                              foreground: categoryStyle.foreground,
                              background: categoryStyle.background,
                              border: categoryStyle.border,
                            ),
                            _CatalogIpadLocationPill(
                              label: _catalogLocationLabel(widget.item, l10n),
                              foreground: locationColor,
                              highlighted: widget.item.box == null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _CatalogIpadSmallPill(
                        label:
                            widget.item.box == null ? l10n.noBox : l10n.stored,
                        foreground: widget.item.box == null
                            ? const Color(0xFF92400E)
                            : _CatalogIpadPalette.orange,
                        background: widget.item.box == null
                            ? const Color(0xFFFFFBEB)
                            : _CatalogIpadPalette.orangeLight,
                        border: widget.item.box == null
                            ? const Color(0xFFFDE68A)
                            : _CatalogIpadPalette.orangeBorder,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _hovered
                              ? _CatalogIpadPalette.orange
                              : _CatalogIpadPalette.orangeLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _CatalogIpadPalette.orangeBorder,
                          ),
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: _hovered
                              ? Colors.white
                              : _CatalogIpadPalette.orange,
                          size: 21,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogIpadToyPhoto extends StatelessWidget {
  final String? path;
  final double size;

  const _CatalogIpadToyPhoto({
    required this.path,
    this.size = 115,
  });

  @override
  Widget build(BuildContext context) {
    final p = (path ?? '').trim();
    if (p.isEmpty) {
      return _CatalogIpadPhotoPlaceholder(size: size);
    }

    if (p.startsWith('assets/')) {
      return Image.asset(
        p,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _CatalogIpadPhotoPlaceholder(size: size),
      );
    }

    return Image.file(
      File(p),
      width: size,
      height: size,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _CatalogIpadPhotoPlaceholder(size: size),
    );
  }
}

class _CatalogIpadPhotoPlaceholder extends StatelessWidget {
  final double size;

  const _CatalogIpadPhotoPlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFF9F0E6),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 30,
        color: _CatalogIpadPalette.textMuted,
      ),
    );
  }
}

class _CatalogIpadLocationPill extends StatelessWidget {
  final String label;
  final Color foreground;
  final bool highlighted;

  const _CatalogIpadLocationPill({
    required this.label,
    required this.foreground,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 258),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFFBEB) : const Color(0xFFFFFAF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted
              ? const Color(0xFFFDE68A)
              : _CatalogIpadPalette.border,
          width: 1.1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 11, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UiTokens.textMicro.copyWith(
                color: foreground,
                fontSize: 10.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogIpadCatalogFooter extends StatelessWidget {
  final int visibleItems;
  final int totalItems;
  final bool filtersActive;
  final VoidCallback onClearFilters;

  const _CatalogIpadCatalogFooter({
    required this.visibleItems,
    required this.totalItems,
    required this.filtersActive,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = totalItems == 0
        ? (l10n.isEn
            ? 'Add the toys from your home'
            : 'Agora cadastre os brinquedos da sua casa')
        : (l10n.isEn
            ? 'Showing $visibleItems of $totalItems toys'
            : 'Mostrando $visibleItems de $totalItems brinquedos cadastrados');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: _CatalogIpadPalette.bg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _CatalogIpadPalette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UiTokens.textMicro.copyWith(
                color: _CatalogIpadPalette.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (filtersActive) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onClearFilters,
              style: TextButton.styleFrom(
                foregroundColor: _CatalogIpadPalette.orange,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.isEn ? 'Clear filters' : 'Limpar filtros'),
            ),
          ],
        ],
      ),
    );
  }
}

class _CatalogIpadSideColumn extends StatelessWidget {
  final TextEditingController searchController;
  final List<FilterOption> boxOptions;
  final String selectedBoxId;
  final ValueChanged<String> onBoxChanged;
  final List<FilterOption> categoryOptions;
  final String selectedCategoryId;
  final ValueChanged<String> onCategoryChanged;
  final List<FilterOption> locationOptions;
  final String selectedLocationId;
  final ValueChanged<String> onLocationChanged;
  final int totalItems;
  final int boxesCount;
  final List<BrinquedosCatalogItem> visibleItems;
  final VoidCallback? onClearFilters;

  const _CatalogIpadSideColumn({
    required this.searchController,
    required this.boxOptions,
    required this.selectedBoxId,
    required this.onBoxChanged,
    required this.categoryOptions,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.locationOptions,
    required this.selectedLocationId,
    required this.onLocationChanged,
    required this.totalItems,
    required this.boxesCount,
    required this.visibleItems,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categoryCount =
        categoryOptions.where((option) => option.id.isNotEmpty).length;
    final locationCount =
        locationOptions.where((option) => !option.id.startsWith('__')).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CatalogIpadSearchCard(controller: searchController),
        const SizedBox(height: 12),
        _CatalogIpadFilterCard(
          title: l10n.boxes,
          options: boxOptions,
          selectedId: selectedBoxId,
          onChanged: onBoxChanged,
          titleForValueLabel: l10n.box,
          styleFor: _catalogBoxStyle,
          maxOptionsHeight: 146,
        ),
        const SizedBox(height: 12),
        _CatalogIpadFilterCard(
          title: l10n.isEn ? 'Categories' : 'Categorias',
          options: categoryOptions,
          selectedId: selectedCategoryId,
          onChanged: onCategoryChanged,
          titleForValueLabel: l10n.category,
          styleFor: (option) => _catalogCategoryStyle(option.id, option.label),
          showCheck: true,
          maxOptionsHeight: 184,
        ),
        const SizedBox(height: 12),
        _CatalogIpadFilterCard(
          title: l10n.isEn ? 'Locations' : 'Locais',
          options: locationOptions,
          selectedId: selectedLocationId,
          onChanged: onLocationChanged,
          titleForValueLabel: l10n.location,
          styleFor: _catalogLocationStyle,
          maxOptionsHeight: 146,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _CatalogIpadSummaryCard(
            totalItems: totalItems,
            categoryCount: categoryCount,
            boxesCount: boxesCount,
            locationCount: locationCount,
            visibleItems: visibleItems,
            onClearFilters: onClearFilters,
          ),
        ),
      ],
    );
  }
}

class _CatalogIpadSearchCard extends StatelessWidget {
  final TextEditingController controller;

  const _CatalogIpadSearchCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _CatalogIpadSurface(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.searchToy,
            style: UiTokens.textMicro.copyWith(
              color: _CatalogIpadPalette.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            style: UiTokens.textCaption.copyWith(
              color: _CatalogIpadPalette.text,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '${l10n.toyName}...',
              hintStyle: UiTokens.textCaption.copyWith(
                color: _CatalogIpadPalette.textMuted,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color: _CatalogIpadPalette.textMuted,
              ),
              suffixIcon: controller.text.trim().isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.isEn ? 'Clear search' : 'Limpar busca',
                      onPressed: controller.clear,
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
              filled: true,
              fillColor: _CatalogIpadPalette.bg,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                  color: _CatalogIpadPalette.border,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                  color: _CatalogIpadPalette.orangeBorder,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogIpadFilterCard extends StatelessWidget {
  final String title;
  final List<FilterOption> options;
  final String selectedId;
  final ValueChanged<String> onChanged;
  final String titleForValueLabel;
  final _CatalogChipStyle Function(FilterOption option) styleFor;
  final bool showCheck;
  final double? maxOptionsHeight;

  const _CatalogIpadFilterCard({
    required this.title,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    required this.titleForValueLabel,
    required this.styleFor,
    this.showCheck = false,
    this.maxOptionsHeight,
  });

  @override
  Widget build(BuildContext context) {
    final chips = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final option in options)
          _CatalogIpadFilterChip(
            label: option.valueLabel(title: titleForValueLabel),
            selected: option.id == selectedId,
            style: styleFor(option),
            showCheck: showCheck && option.id == selectedId,
            onPressed: () => onChanged(option.id),
          ),
      ],
    );

    return _CatalogIpadSurface(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: UiTokens.textCaption.copyWith(
              color: _CatalogIpadPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          if (maxOptionsHeight == null)
            chips
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxOptionsHeight!),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 4),
                child: chips,
              ),
            ),
        ],
      ),
    );
  }
}

class _CatalogIpadFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool showCheck;
  final _CatalogChipStyle style;
  final VoidCallback onPressed;

  const _CatalogIpadFilterChip({
    required this.label,
    required this.selected,
    required this.showCheck,
    required this.style,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected ? style.background : const Color(0xFFFAFAF9);
    final foreground =
        selected ? style.foreground : _CatalogIpadPalette.textMuted;
    final border = selected ? style.border : const Color(0xFFE7E5E4);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 292),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 1.5),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: style.foreground.withValues(alpha: 0.09),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCheck) ...[
                Icon(Icons.check_rounded, size: 13, color: foreground),
                const SizedBox(width: 3),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UiTokens.textMicro.copyWith(
                  color: foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogIpadSummaryCard extends StatelessWidget {
  final int totalItems;
  final int categoryCount;
  final int boxesCount;
  final int locationCount;
  final List<BrinquedosCatalogItem> visibleItems;
  final VoidCallback? onClearFilters;

  const _CatalogIpadSummaryCard({
    required this.totalItems,
    required this.categoryCount,
    required this.boxesCount,
    required this.locationCount,
    required this.visibleItems,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final breakdown = _catalogBoxBreakdown(visibleItems, l10n);

    return _CatalogIpadSurface(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.isEn ? 'Summary' : 'Resumo',
            style: UiTokens.textCaption.copyWith(
              color: _CatalogIpadPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.9,
            children: [
              _CatalogIpadStatTile(
                value: '$totalItems',
                label: l10n.toys,
                foreground: _CatalogIpadPalette.orange,
                background: _CatalogIpadPalette.orangeLight,
                border: _CatalogIpadPalette.orangeBorder,
              ),
              _CatalogIpadStatTile(
                value: '$categoryCount',
                label: l10n.isEn ? 'Categories' : 'Categorias',
                foreground: const Color(0xFF8B5CF6),
                background: const Color(0xFFF5F3FF),
                border: const Color(0xFFDDD6FE),
              ),
              _CatalogIpadStatTile(
                value: '$boxesCount',
                label: l10n.boxes,
                foreground: const Color(0xFF16A34A),
                background: const Color(0xFFDCFCE7),
                border: const Color(0xFF86EFAC),
              ),
              _CatalogIpadStatTile(
                value: '$locationCount',
                label: l10n.isEn ? 'Locations' : 'Locais',
                foreground: const Color(0xFF2563EB),
                background: const Color(0xFFEFF6FF),
                border: const Color(0xFFBFDBFE),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _CatalogIpadPalette.border),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  if (breakdown.isEmpty)
                    _CatalogIpadBreakdownRow(
                      data: _CatalogBreakdownData(
                        label: l10n.isEn
                            ? 'No visible toys'
                            : 'Sem brinquedos visíveis',
                        value: 0,
                        foreground: _CatalogIpadPalette.textMuted,
                        background: const Color(0xFFF8FAFC),
                      ),
                    )
                  else
                    for (var index = 0; index < breakdown.length; index++) ...[
                      _CatalogIpadBreakdownRow(data: breakdown[index]),
                      if (index < breakdown.length - 1)
                        const SizedBox(height: 6),
                    ],
                  if (onClearFilters != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onClearFilters,
                        icon: const Icon(Icons.close_rounded, size: 17),
                        label: Text(
                            l10n.isEn ? 'Clear filters' : 'Limpar filtros'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _CatalogIpadPalette.orange,
                          side: const BorderSide(
                            color: _CatalogIpadPalette.orangeBorder,
                            width: 1.5,
                          ),
                          backgroundColor: _CatalogIpadPalette.orangeLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogIpadStatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  const _CatalogIpadStatTile({
    required this.value,
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textTitle.copyWith(
              color: foreground,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UiTokens.textMicro.copyWith(
              color: _CatalogIpadPalette.textMid,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogIpadBreakdownRow extends StatelessWidget {
  final _CatalogBreakdownData data;

  const _CatalogIpadBreakdownRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: data.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: data.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UiTokens.textMicro.copyWith(
                color: _CatalogIpadPalette.textMid,
                fontSize: 12.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${data.value}',
            style: UiTokens.textMicro.copyWith(
              color: _CatalogIpadPalette.textMid,
              fontSize: 12.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogIpadPrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _CatalogIpadPrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: _CatalogIpadPalette.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: _CatalogIpadPalette.orange.withValues(alpha: 0.35),
        textStyle: UiTokens.textButton.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}

class _CatalogIpadSecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onPressed;

  const _CatalogIpadSecondaryButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            active ? const Color(0xFFC2410C) : _CatalogIpadPalette.textMid,
        backgroundColor:
            active ? _CatalogIpadPalette.orangeLight : const Color(0xFFF5F5F4),
        side: BorderSide(
          color: active
              ? _CatalogIpadPalette.orangeBorder
              : const Color(0xFFE7E5E4),
          width: 1.5,
        ),
        textStyle: UiTokens.textButton.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}

class _CatalogIpadSmallPill extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  const _CatalogIpadSmallPill({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.1),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: UiTokens.textMicro.copyWith(
          color: foreground,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CatalogIpadSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _CatalogIpadSurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _CatalogIpadPalette.card,
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

class _CatalogChipStyle {
  final Color background;
  final Color foreground;
  final Color border;

  const _CatalogChipStyle({
    required this.background,
    required this.foreground,
    required this.border,
  });
}

class _CatalogBreakdownData {
  final String label;
  final int value;
  final Color foreground;
  final Color background;

  const _CatalogBreakdownData({
    required this.label,
    required this.value,
    required this.foreground,
    required this.background,
  });
}

class _CatalogIpadPalette {
  _CatalogIpadPalette._();

  static const Color bg = Color(0xFFFDF7F0);
  static const Color card = Colors.white;
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFF5E8);
  static const Color orangeBorder = Color(0xFFFDDCBA);
  static const Color text = Color(0xFF25180A);
  static const Color textMid = Color(0xFF6B4F30);
  static const Color textMuted = Color(0xFFA8896A);
  static const Color border = Color(0x1FB98750);
}

_CatalogChipStyle _catalogBoxStyle(FilterOption option) {
  if (option.id == BrinquedosCatalogState.boxFilterNone) {
    return const _CatalogChipStyle(
      background: Color(0xFFEFF6FF),
      foreground: Color(0xFF1D4ED8),
      border: Color(0xFFBFDBFE),
    );
  }

  if (option.id == BrinquedosCatalogState.boxFilterAll) {
    return const _CatalogChipStyle(
      background: _CatalogIpadPalette.orangeLight,
      foreground: _CatalogIpadPalette.orange,
      border: _CatalogIpadPalette.orangeBorder,
    );
  }

  return const _CatalogChipStyle(
    background: Color(0xFFF5F3FF),
    foreground: Color(0xFF6D28D9),
    border: Color(0xFFDDD6FE),
  );
}

_CatalogChipStyle _catalogLocationStyle(FilterOption option) {
  if (option.id.endsWith('NONE__')) {
    return const _CatalogChipStyle(
      background: Color(0xFFFFFBEB),
      foreground: Color(0xFF92400E),
      border: Color(0xFFFDE68A),
    );
  }

  if (option.id.endsWith('ALL__')) {
    return const _CatalogChipStyle(
      background: _CatalogIpadPalette.orangeLight,
      foreground: _CatalogIpadPalette.orange,
      border: _CatalogIpadPalette.orangeBorder,
    );
  }

  return const _CatalogChipStyle(
    background: Color(0xFFEFF6FF),
    foreground: Color(0xFF1D4ED8),
    border: Color(0xFFBFDBFE),
  );
}

_CatalogChipStyle _catalogCategoryStyle(String id, String label) {
  final text = '$id $label'.toLowerCase();

  if (text.contains('corpo') ||
      text.contains('movimento') ||
      text.contains('bola')) {
    return const _CatalogChipStyle(
      background: Color(0xFFFFF1F2),
      foreground: Color(0xFFBE123C),
      border: Color(0xFFFECDD3),
    );
  }

  if (text.contains('mão') ||
      text.contains('maos') ||
      text.contains('coord') ||
      text.contains('constru') ||
      text.contains('mont')) {
    return const _CatalogChipStyle(
      background: Color(0xFFFFFBEB),
      foreground: Color(0xFF92400E),
      border: Color(0xFFFDE68A),
    );
  }

  if (text.contains('imag') ||
      text.contains('faz') ||
      text.contains('bonec') ||
      text.contains('conta')) {
    return const _CatalogChipStyle(
      background: Color(0xFFF5F3FF),
      foreground: Color(0xFF5B21B6),
      border: Color(0xFFDDD6FE),
    );
  }

  if (text.contains('comun') ||
      text.contains('livro') ||
      text.contains('música') ||
      text.contains('musica')) {
    return const _CatalogChipStyle(
      background: Color(0xFFEFF6FF),
      foreground: Color(0xFF1D4ED8),
      border: Color(0xFFBFDBFE),
    );
  }

  return const _CatalogChipStyle(
    background: Color(0xFFFFF7ED),
    foreground: Color(0xFFC2410C),
    border: Color(0xFFFED7AA),
  );
}

String _catalogLocationLabel(
  BrinquedosCatalogItem item,
  AppLocalizations l10n,
) {
  final box = item.box;
  final toyLocation = (item.toy.locationText ?? '').trim();
  final boxLocation = (box?.local ?? '').trim();
  final location = boxLocation.isNotEmpty
      ? l10n.value(boxLocation)
      : (toyLocation.isNotEmpty ? l10n.value(toyLocation) : l10n.noLocation);

  if (box == null) return '${l10n.noBox} · $location';
  return '${l10n.boxNumber(box.number)} · $location';
}

List<_CatalogBreakdownData> _catalogBoxBreakdown(
  List<BrinquedosCatalogItem> items,
  AppLocalizations l10n,
) {
  final counts = <String, int>{};

  for (final item in items) {
    final box = item.box;
    final label = box == null ? l10n.noBox : l10n.boxNumber(box.number);
    counts[label] = (counts[label] ?? 0) + 1;
  }

  const colors = [
    (
      foreground: Color(0xFFF97316),
      background: Color(0xFFFFF7ED),
    ),
    (
      foreground: Color(0xFF8B5CF6),
      background: Color(0xFFF5F3FF),
    ),
    (
      foreground: Color(0xFF2563EB),
      background: Color(0xFFEFF6FF),
    ),
  ];

  final entries = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      return a.key.toLowerCase().compareTo(b.key.toLowerCase());
    });

  return [
    for (var index = 0; index < entries.length && index < 3; index++)
      _CatalogBreakdownData(
        label: entries[index].key,
        value: entries[index].value,
        foreground: colors[index].foreground,
        background: colors[index].background,
      ),
  ];
}
