class FoodItem {
  final String id;
  final String name;
  final double cal;
  final double protein;
  final double carbs;
  final double fat;
  final String serving;
  final String category;
  final String emoji;

  const FoodItem({
    required this.id,
    required this.name,
    required this.cal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.serving,
    required this.category,
    required this.emoji,
  });

  /// Scale nutrition values for a specified weight in grams (base values are per 100g)
  Map<String, double> scaleToGrams(double grams) {
    final factor = grams / 100.0;
    return {
      'calories': (cal * factor),
      'protein': (protein * factor),
      'carbs': (carbs * factor),
      'fat': (fat * factor),
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String? ?? json['name'] as String,
      name: json['name'] as String,
      cal: (json['cal'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      serving: json['serving'] as String? ?? '100g',
      category: json['category'] as String? ?? 'general',
      emoji: json['emoji'] as String? ?? '🍽️',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cal': cal,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'serving': serving,
      'category': category,
      'emoji': emoji,
    };
  }
}
