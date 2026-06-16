import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/models/daily_log.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../../domain/services/nutrition_service.dart';

class DailyLogEntry {
  final DailyLog log;
  final FoodItem foodItem;

  const DailyLogEntry({required this.log, required this.foodItem});
}

class DailyLogProvider extends ChangeNotifier {
  final DailyLogRepository _repository;
  final NutritionService _nutritionService;

  DailyLogProvider(this._repository, this._nutritionService);

  List<DailyLog> _todayLogs = [];
  List<DailyLogEntry> _todayEntries = [];
  List<String> _historyDates = [];
  Map<String, MacroSummary> _historySummaries = {};

  bool _isLoading = false;
  String? _errorMessage; // Hata yönetimi için eklendi

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DailyLogEntry> get todayEntries => List.unmodifiable(_todayEntries);
  List<String> get historyDates => _historyDates;
  Map<String, MacroSummary> get historySummaries => _historySummaries;

  String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());
  String get todayDateFormatted => DateFormat('EEEE, MMM d').format(DateTime.now());

  MacroSummary get todayMacros {
    final foodMap = {for (final e in _todayEntries) e.foodItem.id!: e.foodItem};
    return _nutritionService.calculateDailyTotals(_todayLogs, foodMap);
  }

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

  Future<void> loadTodayLogs(Map<int, FoodItem> foodItems) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayLogs = await _repository.getLogsForDate(todayDate);
      _todayEntries = _todayLogs
          .map((log) {
        final food = foodItems[log.foodItemId];
        if (food == null) return null;
        return DailyLogEntry(log: log, foodItem: food);
      })
          .whereType<DailyLogEntry>()
          .toList();
    } catch (e) {
      _errorMessage = "Günlük veriler yüklenirken bir hata oluştu.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLog(DailyLog log, FoodItem foodItem) async {
    try {
      final newId = await _repository.addLog(log);
      final savedLog = log.copyWith(id: newId);
      _todayLogs.add(savedLog);
      _todayEntries.add(DailyLogEntry(log: savedLog, foodItem: foodItem));
      notifyListeners();
    } catch (e) {
      _setError("Öğün kaydedilemedi, lütfen tekrar deneyin.");
    }
  }

  Future<void> deleteLog(int logId) async {
    try {
      await _repository.deleteLog(logId);
      _todayLogs.removeWhere((l) => l.id == logId);
      _todayEntries.removeWhere((e) => e.log.id == logId);
      notifyListeners();
    } catch (e) {
      _setError("Öğün silinemedi.");
    }
  }

  Future<void> loadHistory(Map<int, FoodItem> foodItems) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _historyDates = await _repository.getDistinctDates();
      _historySummaries = {};
      for (final date in _historyDates) {
        if (date == todayDate) continue;
        final logs = await _repository.getLogsForDate(date);
        _historySummaries[date] = _nutritionService.calculateDailyTotals(logs, foodItems);
      }
    } catch (e) {
      _errorMessage = "Geçmiş veriler yüklenemedi.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}