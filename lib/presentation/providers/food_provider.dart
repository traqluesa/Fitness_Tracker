import 'package:flutter/foundation.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/food_item_repository.dart';

class FoodProvider extends ChangeNotifier {
  final FoodItemRepository _repository;

  FoodProvider(this._repository);

  List<FoodItem> _allItems = [];
  List<FoodItem> _filteredItems = [];
  String _searchQuery = '';
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<FoodItem> get allItems => _allItems;

  /// Displays filtered results when searching, all items otherwise.
  List<FoodItem> get displayedItems =>
      _searchQuery.isEmpty ? _allItems : _filteredItems;

  /// Map of id → FoodItem for O(1) lookups in DailyLogProvider.
  Map<int, FoodItem> get foodItemsMap =>
      {for (final f in _allItems) if (f.id != null) f.id!: f};

  Future<void> loadFoodItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allItems = await _repository.getAllFoodItems();
      _filteredItems = _allItems;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchFoodItems(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredItems = _allItems;
      notifyListeners();
      return;
    }
    _filteredItems = await _repository.searchFoodItems(query);
    notifyListeners();
  }

  Future<void> addFoodItem(FoodItem item) async {
    await _repository.addFoodItem(item);
    await loadFoodItems(); // Reload to receive the DB-assigned id
  }

  Future<void> deleteFoodItem(int id) async {
    await _repository.deleteFoodItem(id);
    _allItems.removeWhere((f) => f.id == id);
    _filteredItems.removeWhere((f) => f.id == id);
    notifyListeners();
  }
}