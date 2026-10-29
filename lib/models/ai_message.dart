import 'food_entry.dart';

class SuggestedFoodOption {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double grams;
  final String emoji;
  final MealType suggestedMeal;

  SuggestedFoodOption({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.grams = 100,
    this.emoji = '🍽️',
    this.suggestedMeal = MealType.snacks,
  });

  factory SuggestedFoodOption.fromJson(Map<String, dynamic> json) {
    return SuggestedFoodOption(
      name: json['name'] as String? ?? 'Identified Food',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      grams: (json['grams'] as num?)?.toDouble() ?? 100.0,
      emoji: json['emoji'] as String? ?? '🍽️',
      suggestedMeal: MealTypeExtension.fromString(json['mealType'] as String? ?? 'lunch'),
    );
  }
}

class AIMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imagePath;
  final List<SuggestedFoodOption>? foodOptions;

  AIMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.imagePath,
    this.foodOptions,
  }) : timestamp = timestamp ?? DateTime.now();
}
