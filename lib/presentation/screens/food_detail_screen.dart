import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_routes.dart';
import '../../data/models/daily_log.dart';
import '../../data/models/food_item.dart';
import '../providers/daily_log_provider.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _amountCtrl   = TextEditingController(text: '100');
  double _amount      = 100.0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = ModalRoute.of(context)!.settings.arguments as FoodItem;

    return Scaffold(
      appBar: AppBar(title: Text(food.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card ─────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            const Color(0xFF2563EB).withOpacity(0.1),
                        child: Text(
                          food.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Values per '
                              '${food.portionG.toStringAsFixed(0)} g',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Amount input ────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount to Log',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    decoration: const InputDecoration(
                      suffixText: 'g',
                      hintText: 'Enter grams',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final n = double.tryParse(v);
                      if (n == null || n <= 0) {
                        return 'Enter a valid positive number';
                      }
                      return null;
                    },
                    onChanged: (v) {
                      final n = double.tryParse(v);
                      if (n != null && n > 0) {
                        setState(() => _amount = n);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Live macro breakdown ────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrition for '
                    '${_amount.toStringAsFixed(0)} g',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _MacroRow(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Calories',
                    value:
                        '${food.scaledCalories(_amount).toStringAsFixed(0)} kcal',
                    color: const Color(0xFFEA580C),
                  ),
                  const Divider(height: 16),
                  _MacroRow(
                    icon: Icons.fitness_center_rounded,
                    label: 'Protein',
                    value:
                        '${food.scaledProtein(_amount).toStringAsFixed(1)} g',
                    color: const Color(0xFF2563EB),
                  ),
                  const Divider(height: 16),
                  _MacroRow(
                    icon: Icons.grain_rounded,
                    label: 'Carbohydrates',
                    value:
                        '${food.scaledCarbs(_amount).toStringAsFixed(1)} g',
                    color: const Color(0xFF16A34A),
                  ),
                  const Divider(height: 16),
                  _MacroRow(
                    icon: Icons.water_drop_rounded,
                    label: 'Fat',
                    value:
                        '${food.scaledFat(_amount).toStringAsFixed(1)} g',
                    color: const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
  bottomNavigationBar: SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text("Add to Today's Log"),
        onPressed: () => _addToLog(context, food),
      ),
    ),
  ),
);
}
Future<void> _addToLog(BuildContext context, FoodItem food) async {

if (!_formKey.currentState!.validate()) return;
final logProvider = context.read<DailyLogProvider>();
final log = DailyLog(
  date: logProvider.todayDate,
  foodItemId: food.id!,
  consumedAmount: _amount,
);

await logProvider.addLog(log, food);

if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      '${food.name} (${_amount.toStringAsFixed(0)} g) added!',
    ),
    backgroundColor: const Color(0xFF16A34A),
    behavior: SnackBarBehavior.floating,
  ),
);
// Pop all the way back to Dashboard in one step
Navigator.popUntil(
    context, ModalRoute.withName(AppRoutes.dashboard));
    }

}
class _MacroRow extends StatelessWidget {

final IconData icon;

final String label;

final String value;

final Color color;
const _MacroRow({

required this.icon,

required this.label,

required this.value,

required this.color,

});
@override

Widget build(BuildContext context) {

return Row(

children: [

Icon(icon, size: 18, color: color),

const SizedBox(width: 10),

Text(label, style: const TextStyle(fontSize: 14)),

const Spacer(),

Text(

value,

style: TextStyle(

fontWeight: FontWeight.w700,

color: color,

fontSize: 14,

),

),

],

);

}

}