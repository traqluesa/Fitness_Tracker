import '../../data/models/daily_log.dart';
import '../../data/models/food_item.dart';

/// Immutable value object representing aggregated macro totals for a day.
class MacroSummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const MacroSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory MacroSummary.empty() => const MacroSummary(
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
      );
}

/// Pure service class that performs macro calculations.
/// Has NO dependency on Flutter, SQLite, or any UI concern.
class NutritionService {
  /// Aggregates macro totals from a list of [DailyLog] entries.
  /// [foodItems] is a map keyed by food item id for O(1) lookups.
  MacroSummary calculateDailyTotals(
    List<DailyLog> logs,
    Map<int, FoodItem> foodItems,
  ) {
    double calories = 0, protein = 0, carbs = 0, fat = 0;

    for (final log in logs) {
      final food = foodItems[log.foodItemId];
      if (food == null) continue; // Defensive: orphaned log
      calories += food.scaledCalories(log.consumedAmount);
      protein  += food.scaledProtein(log.consumedAmount);
      carbs    += food.scaledCarbs(log.consumedAmount);
      fat      += food.scaledFat(log.consumedAmount);
    }

    return MacroSummary(
      totalCalories: calories,
      totalProtein: protein,
      totalCarbs: carbs,
      totalFat: fat,
    );
  }
}