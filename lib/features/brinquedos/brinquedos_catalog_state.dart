import 'package:rodizio_brinquedos_v3/data/db/app_database.dart';

class BrinquedosCatalogItem {
  final Toy toy;
  final Boxe? box;

  const BrinquedosCatalogItem({
    required this.toy,
    required this.box,
  });
}

class CategoryFilterOption {
  final String id;
  final String label;

  const CategoryFilterOption({
    required this.id,
    required this.label,
  });
}

class BrinquedosCatalogState {
  static const String boxFilterAll = '__all__';
  static const String boxFilterNone = '__none__';

  final bool loading;
  final String queryText;
  final String selectedBoxFilter;
  final String? selectedCategoryId;
  final List<Boxe> boxes;
  final List<CategoryFilterOption> categories;
  final int totalItemsCount;
  final List<BrinquedosCatalogItem> filteredItems;

  const BrinquedosCatalogState({
    required this.loading,
    required this.queryText,
    required this.selectedBoxFilter,
    required this.selectedCategoryId,
    required this.boxes,
    required this.categories,
    required this.totalItemsCount,
    required this.filteredItems,
  });

  static const empty = BrinquedosCatalogState(
    loading: true,
    queryText: '',
    selectedBoxFilter: boxFilterAll,
    selectedCategoryId: null,
    boxes: <Boxe>[],
    categories: <CategoryFilterOption>[],
    totalItemsCount: 0,
    filteredItems: <BrinquedosCatalogItem>[],
  );
}
