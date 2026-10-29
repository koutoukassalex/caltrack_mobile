import 'package:intl/intl.dart';
import '../models/user_profile.dart';

class NutritionCalculator {
  /// Calculate Basal Metabolic Rate using the Mifflin-St Jeor equation
  static double calculateBMR({
    required String gender,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    if (gender.toLowerCase() == 'female') {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    }
  }

  /// Calculate Total Daily Energy Expenditure (TDEE) and recommended macros
  static Map<String, double> calculateTargets({
    required String gender,
    required double weightKg,
    required double heightCm,
    required int age,
    required ActivityLevel activityLevel,
    required GoalType goal,
  }) {
    final bmr = calculateBMR(
      gender: gender,
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
    );

    final tdee = bmr * activityLevel.multiplier;

    double targetCalories = tdee;
    switch (goal) {
      case GoalType.lose:
        targetCalories = tdee - 500;
        if (targetCalories < 1200) targetCalories = 1200; // Safe minimum
        break;
      case GoalType.maintain:
        targetCalories = tdee;
        break;
      case GoalType.gain:
        targetCalories = tdee + 350;
        break;
    }

    // Protein: ~2.0g per kg for active/recomposition, min 1.6g
    final double proteinGrams = (weightKg * 2.0).clamp(60.0, 250.0);
    final double proteinCalories = proteinGrams * 4.0;

    // Fat: ~25% of target calories (9 cal/gram)
    final double fatCalories = targetCalories * 0.25;
    final double fatGrams = (fatCalories / 9.0).clamp(30.0, 120.0);

    // Carbs: Remaining calories (4 cal/gram)
    final double remainingCalories = targetCalories - proteinCalories - (fatGrams * 9.0);
    final double carbsGrams = (remainingCalories > 0 ? remainingCalories / 4.0 : 50.0).clamp(30.0, 500.0);

    return {
      'calories': targetCalories.roundToDouble(),
      'protein': proteinGrams.roundToDouble(),
      'carbs': carbsGrams.roundToDouble(),
      'fat': fatGrams.roundToDouble(),
    };
  }
}

class DateUtilsHelper {
  static String formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatFriendly(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final comp = DateTime(date.year, date.month, date.day);

    if (comp == today) return 'Today';
    if (comp == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (comp == today.add(const Duration(days: 1))) return 'Tomorrow';

    return DateFormat('EEE, MMM d').format(date);
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
