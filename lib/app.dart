import 'package:flutter/material.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'presentation/screens/add_food_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/food_detail_screen.dart';
import 'presentation/screens/food_list_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'package:fitness_tracker/core/app_theme.dart';
class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.dashboard,
      routes: {
        AppRoutes.dashboard:  (_) => const DashboardScreen(),
        AppRoutes.foodList:   (_) => const FoodListScreen(),
        AppRoutes.foodDetail: (_) => const FoodDetailScreen(),
        AppRoutes.addFood:    (_) => const AddFoodScreen(),
        AppRoutes.history:    (_) => const HistoryScreen(),
      },
    );
  }
}