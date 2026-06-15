import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/services/nutrition_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final foodProv = context.read<FoodProvider>();
    if (foodProv.allItems.isEmpty) await foodProv.loadFoodItems();
    if (!mounted) return;
    await context
        .read<DailyLogProvider>()
        .loadHistory(foodProv.foodItemsMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Consumer<DailyLogProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final dates = provider.historyDates
              .where((d) => d != provider.todayDate)
              .toList();

          if (dates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded,
                      size: 72, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Text(
                    'No history yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Past logged days will appear here.',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dates.length,
              itemBuilder: (_, i) {
                final date    = dates[i];
                final summary = provider.historySummaries[date];
                if (summary == null) return const SizedBox.shrink();
                return _HistoryCard(date: date, summary: summary);
              },
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String date;
  final MacroSummary summary;

  const _HistoryCard({required this.date, required this.summary});

  String get _formatted {
    try {
      final p  = date.split('-');
      final dt = DateTime(
        int.parse(p[0]), int.parse(p[1]), int.parse(p[2]),
      );
      return DateFormat('EEEE, MMM d, yyyy').format(dt);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 14, color: Color(0xFF2563EB)),
                const SizedBox(width: 6),
                Text(
                  _formatted,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _MacroChip(
                  label:
                      '${summary.totalCalories.toStringAsFixed(0)} kcal',
                  color: const Color(0xFFEA580C),
                ),
                _MacroChip(
                  label:
                      'P ${summary.totalProtein.toStringAsFixed(1)} g',
                  color: const Color(0xFF2563EB),
                ),
                _MacroChip(
                  label:
                      'C ${summary.totalCarbs.toStringAsFixed(1)} g',
                  color: const Color(0xFF16A34A),
                ),
                _MacroChip(
                  label: 'F ${summary.totalFat.toStringAsFixed(1)} g',
                  color: const Color(0xFFDC2626),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}