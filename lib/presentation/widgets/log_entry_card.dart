import 'package:flutter/material.dart';
import '../../data/models/food_item.dart';
import '../providers/daily_log_provider.dart';

class LogEntryCard extends StatelessWidget {
  final DailyLogEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const LogEntryCard({
    super.key,
    required this.entry,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final log = entry.log;
    final food = entry.foodItem;


    final factor = log.consumedAmount / food.portionG;
    final calories = (food.calories * factor).toStringAsFixed(0);
    final protein = (food.proteinG * factor).toStringAsFixed(1);
    final carbs = (food.carbG * factor).toStringAsFixed(1);
    final fat = (food.fatG * factor).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${log.consumedAmount.toStringAsFixed(0)}g consumed • $calories kcal",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "P: ${protein}g  C: ${carbs}g  F: ${fat}g",
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
              onPressed: onEdit,
              tooltip: 'Edit Portion',
            ),

            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: onDelete,
              tooltip: 'Delete Meal',
            ),
          ],
        ),
      ),
    );
  }
}