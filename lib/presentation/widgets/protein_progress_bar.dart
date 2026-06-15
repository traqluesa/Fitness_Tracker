import 'package:flutter/material.dart';

class ProteinProgressBar extends StatelessWidget {
  final double current;
  final double goalMin; // Lower bound (green threshold)
  final double goalMax; // Upper bound (100 % mark)

  const ProteinProgressBar({
    super.key,
    required this.current,
    required this.goalMin,
    required this.goalMax,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / goalMax).clamp(0.0, 1.0);
    final reached  = current >= goalMin;
    final color    = reached
        ? const Color(0xFF16A34A)
        : const Color(0xFF2563EB);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Protein Goal',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                _StatusBadge(reached: reached, color: color),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 13,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${current.toStringAsFixed(1)} g consumed',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Goal: ${goalMin.toStringAsFixed(0)}–'
                  '${goalMax.toStringAsFixed(0)} g',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool reached;
  final Color color;

  const _StatusBadge({required this.reached, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        reached ? '✓ Goal Met' : 'In Progress',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}