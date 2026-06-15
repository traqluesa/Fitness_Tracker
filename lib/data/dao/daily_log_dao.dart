import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/daily_log.dart';

class DailyLogDao {
  final DatabaseHelper _dbHelper;

  DailyLogDao(this._dbHelper);

  Future<int> insert(DailyLog log) async {
    final db = await _dbHelper.database;
    return db.insert(
      'daily_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DailyLog>> getByDate(String date) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'daily_logs',
      where: 'date = ?',
      whereArgs: [date],
    );
    return rows.map(DailyLog.fromMap).toList();
  }

  /// Returns every date that has at least one log entry, newest first.
  Future<List<String>> getDistinctDates() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT date FROM daily_logs ORDER BY date DESC',
    );
    return result.map((r) => r['date'] as String).toList();
  }

  Future<int> update(DailyLog log) async {
    final db = await _dbHelper.database;
    return db.update(
      'daily_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete('daily_logs', where: 'id = ?', whereArgs: [id]);
  }
}