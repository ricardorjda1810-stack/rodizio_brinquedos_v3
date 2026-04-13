import 'package:flutter/material.dart';

import 'package:rodizio_brinquedos_v3/data/repositories/round_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/settings_repository.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';
import 'package:rodizio_brinquedos_v3/features/brinquedos/brinquedos_catalog_controller.dart';
import 'package:rodizio_brinquedos_v3/features/brinquedos/brinquedos_catalog_state.dart';
import 'package:rodizio_brinquedos_v3/ui/services/app_feedback.dart';
import 'package:rodizio_brinquedos_v3/ui/theme/ui_tokens.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_create_page.dart';
import 'package:rodizio_brinquedos_v3/ui/toy_detail_page.dart';
import 'package:rodizio_brinquedos_v3/ui/widgets/active_round_list.dart';
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
  final VoidCallback onOpenRodizioTab;
  final String? requestedBoxFilterId;
  final int requestedBoxFilterVersion;

  const BrinquedosPage({
    super.key,
    required this.toyRepository,
    required this.roundRepository,
    required this.settingsRepository,
    required this.onOpenRodizioTab,
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
        ),
      ),
    );
  }

  void _openToyCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToyCreatePage(
          toyRepository: widget.toyRepository,
          settingsRepository: widget.settingsRepository,
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rodada criada com ${result.selectedCount} brinquedos.'),
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
  ) {
    final id = item.toy.categoryId.trim();
    if (id.isEmpty) return 'Sem categoria';
    return categoryById[id] ?? id;
  }

  String _boxAndLocationLabel(BrinquedosCatalogItem item) {
    final boxName =
        item.box != null ? 'Caixa ${item.box!.number}' : 'Sem caixa';
    final boxLocation = (item.box?.local ?? '').trim();
    final toyLocation = (item.toy.locationText ?? '').trim();
    final location = boxLocation.isNotEmpty
        ? boxLocation
        : (toyLocation.isNotEmpty ? toyLocation : 'Sem local');
    return '$boxName - Local: $location';
  }

  Future<void> _editToyCategoryFromList(
    BuildContext context,
    BrinquedosCatalogItem item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final selectedCategoryId = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String selectedId = item.toy.categoryId;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar categoria'),
              content: StreamBuilder(
                stream: widget.toyRepository.watchCategories(activeOnly: true),
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
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                      ),
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

    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Editar local'),
            content: DropdownButtonFormField<String?>(
              initialValue: selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Local (sem caixa)',
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
              onChanged: (value) {
                setDialogState(() => selectedLocation = value);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(selectedLocation),
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );

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
    if (item.toy.boxId != null && !boxes.any((b) => b.id == item.toy.boxId)) {
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
              decoration: const InputDecoration(
                labelText: 'Caixa',
              ),
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
    final displayName =
        item.toy.name.trim().isEmpty ? 'Sem nome' : item.toy.name.trim();

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
                    _boxAndLocationLabel(item),
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
                          color: UiTokens.primaryStrong,
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
            'Cat\u00e1logo de brinquedos',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: UiTokens.spacingXs),
          Text(
            '${items.length} itens nesta visualiza\u00e7\u00e3o',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: UiTokens.spacingMd),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, thickness: 0.6),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildToyRow(
                context,
                item,
                categoryLabel: _categoryLabel(item, categoryById),
              );
            },
          ),
        ],
      ),
    );
  }

  List<FilterOption> _boxOptions(BrinquedosCatalogState state) {
    return [
      const FilterOption(
        id: BrinquedosCatalogState.boxFilterAll,
        label: 'Caixa: Todas',
      ),
      const FilterOption(
        id: BrinquedosCatalogState.boxFilterNone,
        label: 'Caixa: Sem caixa',
      ),
      ...state.boxes.map(
        (b) => FilterOption(
          id: b.id,
          label: 'Caixa ${b.number} - ${b.local}',
        ),
      ),
    ];
  }

  List<FilterOption> _categoryOptions(BrinquedosCatalogState state) {
    return [
      const FilterOption(id: '', label: 'Categoria: Todas'),
      ...state.categories
          .map((c) => FilterOption(id: c.id, label: 'Categoria: ${c.label}')),
    ];
  }

  ({List<FilterOption> locations, bool hasRealLocations}) _locationOptions(
    List<BrinquedosCatalogItem> baseItems,
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
        const FilterOption(id: _localAll, label: 'Local: Todos'),
        const FilterOption(id: _localNone, label: 'Local: Sem local'),
        ...list.map((loc) => FilterOption(id: loc, label: 'Local: $loc')),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiTokens.m),
        child: StreamBuilder<BrinquedosCatalogState>(
          stream: _controller.stream,
          initialData: BrinquedosCatalogState.empty,
          builder: (context, snapshot) {
            final state = snapshot.data ?? BrinquedosCatalogState.empty;

            final selectedCategoryId = state.selectedCategoryId ?? '';
            final baseItems = state.filteredItems;
            final categoryById = <String, String>{
              for (final c in state.categories) c.id: c.label,
            };

            final locInfo = _locationOptions(baseItems);
            if (!locInfo.locations.any((e) => e.id == _selectedLocalFilter)) {
              _selectedLocalFilter = _localAll;
            }

            final visibleItems = _applyLocalFilter(baseItems);
            final showClear = _hasActiveFilters(state);

            return Column(
              children: [
                const SizedBox(height: UiTokens.m),
                AppSurfaceCard(
                  padding: const EdgeInsets.all(UiTokens.spacingMd),
                  color: UiTokens.primarySoft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brinquedos da casa',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: UiTokens.spacingXs),
                      Text(
                        'Veja tudo de forma clara, filtre com leveza e monte a rodada quando quiser.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: UiTokens.spacingMd),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _startingRound ? null : _startRound,
                              icon: _startingRound
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.play_arrow),
                              label: Text(
                                _startingRound
                                    ? 'Iniciando...'
                                    : 'Iniciar rod\u00edzio',
                              ),
                            ),
                          ),
                          const SizedBox(width: UiTokens.s),
                          Tooltip(
                            message: 'Novo brinquedo',
                            child: FilledButton.tonalIcon(
                              onPressed: () => _openToyCreate(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Novo'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: UiTokens.m),
                FilterBar(
                  boxes: _boxOptions(state),
                  categories: _categoryOptions(state),
                  locations: locInfo.locations,
                  selectedBoxId: state.selectedBoxFilter,
                  selectedCategoryId: selectedCategoryId,
                  selectedLocationId: _selectedLocalFilter,
                  onBoxChanged: _controller.setBoxFilter,
                  onCategoryChanged: (id) =>
                      _controller.setCategoryFilter(id.isEmpty ? null : id),
                  onLocationChanged: (id) =>
                      setState(() => _selectedLocalFilter = id),
                  onSearchTap: () => _openSearchDialog(context),
                  showClear: showClear,
                  onClear: _clearFilters,
                ),
                const SizedBox(height: UiTokens.spacingXs),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.loading && state.totalItemsCount == 0) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.totalItemsCount == 0) {
                        return EmptyState(
                          icon: Icons.toys,
                          title: 'Nenhum brinquedo cadastrado',
                          message:
                              'Adicione brinquedos para montar seu cat\u00e1logo visual.',
                          actionLabel: 'Novo brinquedo',
                          onAction: () => _openToyCreate(context),
                        );
                      }

                      if (visibleItems.isEmpty) {
                        return EmptyState(
                          icon: Icons.search_off,
                          title: 'Nenhum resultado',
                          message:
                              'Ajuste busca e filtros para encontrar brinquedos.',
                          actionLabel: 'Limpar',
                          onAction: _clearFilters,
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: UiTokens.spacingLg + 20,
                        ),
                        child: _buildToyList(
                          context,
                          visibleItems,
                          categoryById: categoryById,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
