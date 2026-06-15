import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/dao/daily_log_dao.dart';
import 'data/dao/food_item_dao.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/daily_log_repository.dart';
import 'data/repositories/food_item_repository.dart';
import 'domain/services/nutrition_service.dart';
import 'presentation/providers/daily_log_provider.dart';
import 'presentation/providers/food_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Data Layer ───────────────────────────────────────────────
  final dbHelper          = DatabaseHelper();
  final foodItemDao       = FoodItemDao(dbHelper);
  final dailyLogDao       = DailyLogDao(dbHelper);
  final foodItemRepo      = FoodItemRepository(foodItemDao);
  final dailyLogRepo      = DailyLogRepository(dailyLogDao);

  // ── Domain Layer ─────────────────────────────────────────────
  final nutritionService  = NutritionService();

  // ── Presentation Layer ───────────────────────────────────────
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FoodProvider(foodItemRepo),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DailyLogProvider(dailyLogRepo, nutritionService),
        ),
      ],
      child: const FitnessTrackerApp(),
    ),
  );
}