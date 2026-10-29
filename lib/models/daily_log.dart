import 'food_entry.dart';
import 'exercise_entry.dart';

class DailyLog {
  final String date; // YYYY-MM-DD
  List<FoodEntry> foods;
  List<ExerciseEntry> exercises;
  int waterMl;
  String? note;

  DailyLog({
    required this.date,
    List<FoodEntry>? foods,
    List<ExerciseEntry>? exercises,
    this.waterMl = 0,
    this.note,
  })  : foods = foods ?? [],
        exercises = exercises ?? [];

  double get totalCalories => foods.fold(0.0, (sum, item) => sum + item.calories);
  double get totalProtein => foods.fold(0.0, (sum, item) => sum + item.protein);
  double get totalCarbs => foods.fold(0.0, (sum, item) => sum + item.carbs);
  double get totalFat => foods.fold(0.0, (sum, item) => sum + item.fat);
  double get totalBurnedCalories =>
      exercises.fold(0.0, (sum, item) => sum + item.caloriesBurned);

  double get netCalories => totalCalories - totalBurnedCalories;

  List<FoodEntry> getFoodsForMeal(MealType type) {
    return foods.where((f) => f.mealType == type).toList();
  }

  double getMealCalories(MealType type) {
    return getFoodsForMeal(type).fold(0.0, (sum, item) => sum + item.calories);
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'foods': foods.map((f) => f.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'waterMl': waterMl,
      'note': note,
    };
  }

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      date: json['date'] as String,
      foods: (json['foods'] as List<dynamic>?)
              ?.map((f) => FoodEntry.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      waterMl: (json['waterMl'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
    );
  }
}
