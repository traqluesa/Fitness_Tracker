import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // ── Singleton pattern ────────────────────────────────────────
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'fitness_tracker.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // ── Schema creation ──────────────────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_items (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        portion_g   REAL    NOT NULL DEFAULT 100,
        calories    REAL    NOT NULL DEFAULT 0,
        protein_g   REAL    NOT NULL DEFAULT 0,
        carb_g      REAL    NOT NULL DEFAULT 0,
        fat_g       REAL    NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_logs (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        date            TEXT    NOT NULL,
        food_item_id    INTEGER NOT NULL,
        consumed_amount REAL    NOT NULL,
        FOREIGN KEY (food_item_id) REFERENCES food_items (id)
          ON DELETE CASCADE
      )
    ''');

    await _seedFoodItems(db);
  }

  // ── Seed data ────────────────────────────────────────────────
  Future<void> _seedFoodItems(Database db) async {
    const seeds = [
      {
        'name': 'Chicken Breast',
        'portion_g': 100.0,
        'calories': 165.0,
        'protein_g': 31.0,
        'carb_g': 0.0,
        'fat_g': 3.6,
      },
      {
        'name': 'Oatmeal',
        'portion_g': 100.0,
        'calories': 389.0,
        'protein_g': 16.9,
        'carb_g': 66.3,
        'fat_g': 6.9,
      },
      {
        'name': 'Rice Flour',
        'portion_g': 100.0,
        'calories': 366.0,
        'protein_g': 6.0,
        'carb_g': 80.0,
        'fat_g': 1.4,
      },
      {
        'name': 'Beef (Ground, Lean)',
        'portion_g': 100.0,
        'calories': 215.0,
        'protein_g': 26.1,
        'carb_g': 0.0,
        'fat_g': 12.0,
      },
    ];

    final batch = db.batch();
    for (final food in seeds) {
      batch.insert('food_items', food);
    }
    await batch.commit(noResult: true);
  }
}