/// Represents a food item stored in the local SQLite database.
/// All nutritional values are stored per [portionG] grams as the reference unit.
/// Scaled helper methods compute values for any arbitrary consumed amount.
class FoodItem {
  final int? id;
  final String name;
  final double portionG;   // Reference portion (e.g., 100 g)
  final double calories;   // kcal per portionG
  final double proteinG;   // grams per portionG
  final double carbG;      // grams per portionG
  final double fatG;       // grams per portionG

  const FoodItem({
    this.id,
    required this.name,
    required this.portionG,
    required this.calories,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) => FoodItem(
        id: map['id'] as int?,
        name: map['name'] as String,
        portionG: (map['portion_g'] as num).toDouble(),
        calories: (map['calories'] as num).toDouble(),
        proteinG: (map['protein_g'] as num).toDouble(),
        carbG: (map['carb_g'] as num).toDouble(),
        fatG: (map['fat_g'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'portion_g': portionG,
      'calories': calories,
      'protein_g': proteinG,
      'carb_g': carbG,
      'fat_g': fatG,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // ── Scaling helpers ──────────────────────────────────────────
  double scaledCalories(double amountG) => (amountG / portionG) * calories;
  double scaledProtein(double amountG)  => (amountG / portionG) * proteinG;
  double scaledCarbs(double amountG)    => (amountG / portionG) * carbG;
  double scaledFat(double amountG)      => (amountG / portionG) * fatG;

  FoodItem copyWith({
    int? id,
    String? name,
    double? portionG,
    double? calories,
    double? proteinG,
    double? carbG,
    double? fatG,
  }) =>
      FoodItem(
        id: id ?? this.id,
        name: name ?? this.name,
        portionG: portionG ?? this.portionG,
        calories: calories ?? this.calories,
        proteinG: proteinG ?? this.proteinG,
        carbG: carbG ?? this.carbG,
        fatG: fatG ?? this.fatG,
      );

  @override
  String toString() => 'FoodItem(id: $id, name: $name)';
}