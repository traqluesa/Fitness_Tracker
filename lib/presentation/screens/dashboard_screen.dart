import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_routes.dart';
import '../providers/daily_log_provider.dart';
import '../providers/food_provider.dart';
import '../widgets/log_entry_card.dart';
import '../widgets/macro_summary_card.dart';
import '../widgets/protein_progress_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final foodProv = context.read<FoodProvider>();
    final logProv  = context.read<DailyLogProvider>();
    await foodProv.loadFoodItems();
    if (!mounted) return;
    await logProv.loadTodayLogs(foodProv.foodItemsMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'History',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer2<FoodProvider, DailyLogProvider>(
        builder: (context, foodProv, logProv, child) {

          if (logProv.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(logProv.errorMessage!),
                  backgroundColor: Colors.redAccent,
                ),
              );
              logProv.clearError();
            });
          }

          if (logProv.isLoading || foodProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = logProv.todayMacros;
          final entries = logProv.todayEntries;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                Text(
                  logProv.todayDateFormatted,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                ProteinProgressBar(
                  current: summary.totalProtein,
                  goalMin: 150,
                  goalMax: 200,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: MacroSummaryCard(
                        label: 'Calories',
                        value: summary.totalCalories.toStringAsFixed(0),
                        unit: 'kcal',
                        color: const Color(0xFFEA580C),
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MacroSummaryCard(
                        label: 'Protein',
                        value: summary.totalProtein.toStringAsFixed(1),
                        unit: 'g',
                        color: const Color(0xFF2563EB),
                        icon: Icons.fitness_center_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: MacroSummaryCard(
                        label: 'Carbs',
                        value: summary.totalCarbs.toStringAsFixed(1),
                        unit: 'g',
                        color: const Color(0xFF16A34A),
                        icon: Icons.grain_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MacroSummaryCard(
                        label: 'Fat',
                        value: summary.totalFat.toStringAsFixed(1),
                        unit: 'g',
                        color: const Color(0xFFDC2626),
                        icon: Icons.water_drop_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Meals",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    Text(
                      '${entries.length} item${entries.length == 1 ? '' : 's'}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (entries.isEmpty)
                  _EmptyMealsPlaceholder()
                else
                  ...entries.map(
                        (e) => LogEntryCard(
                      key: ValueKey(e.log.id),
                      entry: e,
                      onDelete: () => context.read<DailyLogProvider>().deleteLog(e.log.id!),
                      onEdit: () => _showEditPortionDialog(context, e), // <-- DÜZENLEME BURAYA BAĞLANDI
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.foodList),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Meal'),
      ),
    );
  }

  void _showEditPortionDialog(BuildContext context, DailyLogEntry entry) {
    final textController = TextEditingController(text: entry.log.consumedAmount.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${entry.foodItem.name} Edit'),
          content: TextField(
            controller: textController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount Consumed',
              suffixText: 'g',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAmount = double.tryParse(textController.text);
                if (newAmount != null && newAmount > 0) {
                  final updatedLog = entry.log.copyWith(consumedAmount: newAmount);

                  context.read<DailyLogProvider>().updateLog(updatedLog, entry.foodItem);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyMealsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            Icon(Icons.no_meals_rounded, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No meals logged yet.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "Log Meal" to get started.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}