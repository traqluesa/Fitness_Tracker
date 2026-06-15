import '../dao/food_item_dao.dart';
import '../models/food_item.dart';

class FoodItemRepository {
  final FoodItemDao _dao;

  FoodItemRepository(this._dao);

  Future<int> addFoodItem(FoodItem item)          => _dao.insert(item);
  Future<List<FoodItem>> getAllFoodItems()         => _dao.getAll();
  Future<FoodItem?> getFoodItemById(int id)        => _dao.getById(id);
  Future<List<FoodItem>> searchFoodItems(String q) =>
      q.isEmpty ? _dao.getAll() : _dao.search(q);
  Future<int> updateFoodItem(FoodItem item)        => _dao.update(item);
  Future<int> deleteFoodItem(int id)               => _dao.delete(id);
}