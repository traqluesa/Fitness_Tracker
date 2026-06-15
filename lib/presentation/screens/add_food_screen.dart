import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/food_item.dart';
import '../providers/food_provider.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _portionCtrl  = TextEditingController(text: '100');
  final _calCtrl      = TextEditingController();
  final _proteinCtrl  = TextEditingController();
  final _carbCtrl     = TextEditingController();
  final _fatCtrl      = TextEditingController();
  bool _isSaving      = false;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _portionCtrl, _calCtrl,
      _proteinCtrl, _carbCtrl, _fatCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final food = FoodItem(
      name:     _nameCtrl.text.trim(),
      portionG: double.parse(_portionCtrl.text),
      calories: double.parse(_calCtrl.text),
      proteinG: double.parse(_proteinCtrl.text),
      carbG:    double.parse(_carbCtrl.text),
      fatG:     double.parse(_fatCtrl.text),
    );

    await context.read<FoodProvider>().addFoodItem(food);

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Food item saved successfully!'),
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Custom Food')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info banner
            Card(
              color: const Color(0xFFEFF6FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFBFDBFE)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Enter nutritional values per reference portion '
                        '(default: per 100 g).',
                        style: TextStyle(
                            color: Color(0xFF1D4ED8), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _NutritionFormField(
              controller: _nameCtrl,
              label: 'Food Name',
              hint: 'e.g. Greek Yogurt',
              isText: true,
            ),
            const SizedBox(height: 14),
            _NutritionFormField(
              controller: _portionCtrl,
              label: 'Reference Portion (g)',
              hint: '100',
            ),
            const SizedBox(height: 14),
            _NutritionFormField(
              controller: _calCtrl,
              label: 'Calories (kcal)',
              hint: '0',
            ),
            const SizedBox(height: 14),
            _NutritionFormField(
              controller: _proteinCtrl,
              label: 'Protein (g)',
              hint: '0.0',
            ),
            const SizedBox(height: 14),
            _NutritionFormField(
              controller: _carbCtrl,
              label: 'Carbohydrates (g)',
              hint: '0.0',
            ),
            const SizedBox(height: 14),
            _NutritionFormField(
              controller: _fatCtrl,
              label: 'Fat (g)',
              hint: '0.0',
            ),
            const SizedBox(height: 28),

            ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving…' : 'Save Food Item'),
              onPressed: _isSaving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isText;

  const _NutritionFormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isText
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return '$label is required';
        if (!isText) {
          final n = double.tryParse(v.trim());
          if (n == null || n < 0) {
            return 'Enter a valid non-negative number';
          }
        }
        return null;
      },
    );
  }
}