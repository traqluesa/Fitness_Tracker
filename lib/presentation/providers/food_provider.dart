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
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<FoodItem> get allItems => _allItems;


  List<FoodItem> get displayedItems =>
      _searchQuery.isEmpty ? _allItems : _filteredItems;


  Map<int, FoodItem> get foodItemsMap =>
      {for (final f in _allItems) if (f.id != null) f.id!: f};

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> loadFoodItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allItems = await _repository.getAllFoodItems();
      if (_searchQuery.isNotEmpty) {
        _filteredItems = await _repository.searchFoodItems(_searchQuery);
      } else {
        _filteredItems = _allItems;
      }
    } catch (e) {
      _setError("An error occurred while loading nutritional data.");
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

    try {
      _filteredItems = await _repository.searchFoodItems(query);
      notifyListeners();
    } catch (e) {
      _setError("An error occurred during the search.");
    }
  }

  Future<void> addFoodItem(FoodItem item) async {
    try {
      await _repository.addFoodItem(item);
      await loadFoodItems();
    } catch (e) {
      _setError("Food could not be added, please try again.");
    }
  }

  Future<void> updateFoodItem(FoodItem item) async {
    try {
      await _repository.updateFoodItem(item);
      await loadFoodItems();
    } catch (e) {
      _setError("The Food could not be updated.");
    }
  }

  Future<void> deleteFoodItem(int id) async {
    try {
      await _repository.deleteFoodItem(id);
      _allItems.removeWhere((f) => f.id == id);
      _filteredItems.removeWhere((f) => f.id == id);
      notifyListeners();
    } catch (e) {
      _setError("Food could not be deleted.");
    }
  }
}