enum MealType {
  breakfast,
  lunch,
  dinner,
  snacks,
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snacks:
        return 'Snacks';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🍳';
      case MealType.lunch:
        return '🥗';
      case MealType.dinner:
        return '🍲';
      case MealType.snacks:
        return '🍎';
    }
  }

  static MealType fromString(String str) {
    switch (str.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snacks':
      case 'snack':
      default:
        return MealType.snacks;
    }
  }
}

class FoodEntry {
  final String id;
  final String name;
  final MealType mealType;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double grams;
  final String emoji;
  final DateTime timestamp;

  FoodEntry({
    required this.id,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.grams = 100,
    this.emoji = '🍽️',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mealType': mealType.name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'grams': grams,
      'emoji': emoji,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      mealType: MealTypeExtension.fromString(json['mealType'] as String? ?? 'snacks'),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      grams: (json['grams'] as num?)?.toDouble() ?? 100.0,
      emoji: json['emoji'] as String? ?? '🍽️',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
