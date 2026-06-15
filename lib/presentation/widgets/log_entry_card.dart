import 'package:flutter/material.dart';
import '../providers/daily_log_provider.dart';

class LogEntryCard extends StatelessWidget {
  final DailyLogEntry entry;
  final VoidCallback onDelete;

  const LogEntryCard({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final food   = entry.foodItem;
    final amount = entry.log.consumedAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
          child: Text(
            food.name[0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${amount.toStringAsFixed(0)} g  ·  '
          '${food.scaledCalories(amount).toStringAsFixed(0)} kcal  ·  '
          'P ${food.scaledProtein(amount).toStringAsFixed(1)} g  '
          'C ${food.scaledCarbs(amount).toStringAsFixed(1)} g  '
          'F ${food.scaledFat(amount).toStringAsFixed(1)} g',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: Colors.redAccent),
          tooltip: 'Remove',
          onPressed: () => _confirmDelete(context),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Entry'),
        content: Text('Remove "${entry.foodItem.name}" from today\'s log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Remove',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}