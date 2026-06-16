import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_routes.dart';
import '../providers/food_provider.dart';
import '../providers/daily_log_provider.dart';
import '../../data/models/daily_log.dart';
import '../../data/models/food_item.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().loadFoodItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Selection'),
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProv, child) {

          if (foodProv.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(foodProv.errorMessage!),
                  backgroundColor: Colors.redAccent,
                ),
              );
              foodProv.clearError();
            });
          }

          return Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) => foodProv.searchFoodItems(query),
                  decoration: InputDecoration(
                    hintText: 'Search for food...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        foodProv.searchFoodItems('');
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              if (foodProv.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (foodProv.displayedItems.isEmpty)
                const Expanded(
                  child: Center(child: Text('No food matching the search criteria was found..')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: foodProv.displayedItems.length,
                    itemBuilder: (context, index) {
                      final item = foodProv.displayedItems[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('100g = ${item.calories.toStringAsFixed(0)} kcal • P: ${item.proteinG}g'),
                        trailing: const Icon(Icons.add_circle_outline_rounded, color: Colors.green),
                        onTap: () => _showLogMealBottomSheet(context, item),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addFood),
        icon: const Icon(Icons.restaurant_menu_rounded),
        label: const Text('Define a New Food'),
      ),
    );
  }

  void _showLogMealBottomSheet(BuildContext context, FoodItem item) {
    final amountController = TextEditingController(text: '100');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Reference Serving Value: ${item.portionG.toStringAsFixed(0)}g'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'How many grams did you consume?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      final logProv = context.read<DailyLogProvider>();
                      final newLog = DailyLog(
                        date: logProv.todayDate,
                        foodItemId: item.id!,
                        consumedAmount: amount,
                      );
                      logProv.addLog(newLog, item);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save to My Daily consumer'),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}