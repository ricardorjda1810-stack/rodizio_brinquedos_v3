import 'dart:async';

import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';
import 'package:rodizio_brinquedos_v3/data/repositories/toy_repository.dart';

import 'brinquedos_catalog_state.dart';

class BrinquedosCatalogController {
  final ToyRepository _toyRepository;
  final _stateController = StreamController<BrinquedosCatalogState>.broadcast();

  StreamSubscription<List<Toy>>? _toysSub;
  StreamSubscription<List<Boxe>>? _boxesSub;
  StreamSubscription<List<CategoryDefinition>>? _categoriesSub;

  List<Toy> _latestToys = const <Toy>[];
  List<Boxe> _latestBoxes = const <Boxe>[];
  List<CategoryDefinition> _latestCategories = const <CategoryDefinition>[];

  String _queryText = '';
  String _selectedBoxFilter = BrinquedosCatalogState.boxFilterAll;
  String? _selectedCategoryId;

  BrinquedosCatalogController({required ToyRepository toyRepository})
      : _toyRepository = toyRepository;

  Stream<BrinquedosCatalogState> get stream => _stateController.stream;

  static const List<CategoryFilterOption> _defaultCategories = <CategoryFilterOption>[
    CategoryFilterOption(id: 'veiculos', label: 'Veículos'),
    CategoryFilterOption(id: 'bonecos', label: 'Bonecos'),
    CategoryFilterOption(id: 'montagem', label: 'Montagem'),
    CategoryFilterOption(id: 'livros', label: 'Livros'),
    CategoryFilterOption(id: 'jogos', label: 'Jogos'),
    CategoryFilterOption(id: 'faz_de_conta', label: 'Faz de conta'),
    CategoryFilterOption(id: 'artes', label: 'Artes'),
    CategoryFilterOption(id: 'musica', label: 'Música'),
    CategoryFilterOption(id: 'banho', label: 'Banho'),
    CategoryFilterOption(id: 'outros', label: 'Outros'),
  ];

  void init() {
    _emit();

    _toysSub = _toyRepository.watchAll().listen((items) {
      _latestToys = items;
      _emit();
    });

    _boxesSub = _toyRepository.watchBoxes().listen((items) {
      _latestBoxes = items;
      _emit();
    });

    _categoriesSub = _toyRepository.watchCategories(activeOnly: false).listen((items) {
      _latestCategories = items;
      _emit();
    });
  }

  void setQueryText(String value) {
    if (_queryText == value) return;
    _queryText = value;
    _emit();
  }

  void setBoxFilter(String value) {
    if (_selectedBoxFilter == value) return;
    _selectedBoxFilter = value;
    _emit();
  }

  void setCategoryFilter(String? value) {
    if (_selectedCategoryId == value) return;
    _selectedCategoryId = value;
    _emit();
  }

  void clearFilters() {
    _queryText = '';
    _selectedBoxFilter = BrinquedosCatalogState.boxFilterAll;
    _selectedCategoryId = null;
    _emit();
  }

  void _emit() {
    if (_stateController.isClosed) return;

    final categories = _buildCategories();
    if (_selectedCategoryId != null && !categories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = null;
    }

    final boxById = <String, Boxe>{
      for (final b in _latestBoxes) b.id: b,
    };

    final items = _latestToys
        .map(
          (toy) => BrinquedosCatalogItem(
            toy: toy,
            box: toy.boxId == null ? null : boxById[toy.boxId!],
          ),
        )
        .where(_matchesQuery)
        .where(_matchesBoxFilter)
        .where(_matchesCategoryFilter)
        .toList();

    _stateController.add(
      BrinquedosCatalogState(
        loading: _latestToys.isEmpty && _latestBoxes.isEmpty && _latestCategories.isEmpty,
        queryText: _queryText,
        selectedBoxFilter: _selectedBoxFilter,
        selectedCategoryId: _selectedCategoryId,
        boxes: _latestBoxes,
        categories: categories,
        totalItemsCount: _latestToys.length,
        filteredItems: items,
      ),
    );
  }

  List<CategoryFilterOption> _buildCategories() {
    final byId = <String, String>{
      for (final c in _defaultCategories) c.id: c.label,
    };

    for (final c in _latestCategories) {
      final label = c.name.trim();
      if (label.isNotEmpty) {
        byId[c.id] = label;
      }
    }

    final options = byId.entries
        .map((e) => CategoryFilterOption(id: e.key, label: e.value))
        .toList();
    options.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return options;
  }

  bool _matchesQuery(BrinquedosCatalogItem item) {
    final q = _queryText.trim().toLowerCase();
    if (q.isEmpty) return true;
    return item.toy.name.trim().toLowerCase().contains(q);
  }

  bool _matchesBoxFilter(BrinquedosCatalogItem item) {
    if (_selectedBoxFilter == BrinquedosCatalogState.boxFilterAll) return true;
    if (_selectedBoxFilter == BrinquedosCatalogState.boxFilterNone) {
      return item.toy.boxId == null;
    }
    return item.toy.boxId == _selectedBoxFilter;
  }

  bool _matchesCategoryFilter(BrinquedosCatalogItem item) {
    final categoryId = _selectedCategoryId;
    if (categoryId == null) return true;
    return item.toy.categoryId == categoryId;
  }

  Future<void> dispose() async {
    await _toysSub?.cancel();
    await _boxesSub?.cancel();
    await _categoriesSub?.cancel();
    await _stateController.close();
  }
}
