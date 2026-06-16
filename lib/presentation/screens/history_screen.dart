import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/daily_log_provider.dart';
import '../providers/food_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final foodProv = context.read<FoodProvider>();
      context.read<DailyLogProvider>().loadHistory(foodProv.foodItemsMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Logs'),
      ),
      body: Consumer<DailyLogProvider>(
        builder: (context, logProv, child) {
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

          if (logProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (logProv.historyDates.isEmpty) {
            return const Center(
              child: Text('No records of the past days could be found.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: logProv.historyDates.length,
            itemBuilder: (context, index) {
              final rawDate = logProv.historyDates[index];
              final summary = logProv.historySummaries[rawDate];

              if (summary == null) return const SizedBox.shrink();

              // Tarihi okunabilir formata cevir (Orn: 2026-05-18 -> Monday, May 18)
              String formattedDate = rawDate;
              try {
                final parsedDate = DateFormat('yyyy-MM-dd').parse(rawDate);
                formattedDate = DateFormat('EEEE, MMM d').format(parsedDate);
              } catch (e) {
                // Parse hatasi olursa orijinal rawDate kalsin
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: const Icon(Icons.calendar_today_rounded, color: Colors.blueGrey),
                  title: Text(
                    formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${summary.totalCalories.toStringAsFixed(0)} kcal consumed'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMacroSummaryItem('Protein', '${summary.totalProtein.toStringAsFixed(1)}g', Colors.blue),
                          _buildMacroSummaryItem('Carb.', '${summary.totalCarbs.toStringAsFixed(1)}g', Colors.green),
                          _buildMacroSummaryItem('Fat', '${summary.totalFat.toStringAsFixed(1)}g', Colors.red),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMacroSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
      ],
    );
  }
}