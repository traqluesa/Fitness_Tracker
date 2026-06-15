import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/food_item.dart';

class FoodItemDao {
  final DatabaseHelper _dbHelper;

  FoodItemDao(this._dbHelper);

  Future<int> insert(FoodItem item) async {
    final db = await _dbHelper.database;
    return db.insert(
      'food_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FoodItem>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query('food_items', orderBy: 'name ASC');
    return rows.map(FoodItem.fromMap).toList();
  }

  Future<FoodItem?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : FoodItem.fromMap(rows.first);
  }

  Future<List<FoodItem>> search(String query) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'food_items',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return rows.map(FoodItem.fromMap).toList();
  }

  Future<int> update(FoodItem item) async {
    final db = await _dbHelper.database;
    return db.update(
      'food_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }
}