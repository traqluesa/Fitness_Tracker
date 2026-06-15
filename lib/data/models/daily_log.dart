
class DailyLog {
  final int? id;
  final String date;          
  final int foodItemId;
  final double consumedAmount; 

  const DailyLog({
    this.id,
    required this.date,
    required this.foodItemId,
    required this.consumedAmount,
  });

  factory DailyLog.fromMap(Map<String, dynamic> map) => DailyLog(
        id: map['id'] as int?,
        date: map['date'] as String,
        foodItemId: map['food_item_id'] as int,
        consumedAmount: (map['consumed_amount'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'date': date,
      'food_item_id': foodItemId,
      'consumed_amount': consumedAmount,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  DailyLog copyWith({
    int? id,
    String? date,
    int? foodItemId,
    double? consumedAmount,
  }) =>
      DailyLog(
        id: id ?? this.id,
        date: date ?? this.date,
        foodItemId: foodItemId ?? this.foodItemId,
        consumedAmount: consumedAmount ?? this.consumedAmount,
      );
}