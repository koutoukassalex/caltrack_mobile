enum GoalType {
  lose,
  maintain,
  gain,
}

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  very,
  extra,
}

extension ActivityLevelExtension on ActivityLevel {
  String get title {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.light:
        return 'Lightly Active';
      case ActivityLevel.moderate:
        return 'Moderately Active';
      case ActivityLevel.very:
        return 'Very Active';
      case ActivityLevel.extra:
        return 'Extremely Active';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Desk job, little to no exercise';
      case ActivityLevel.light:
        return 'Light exercise 1-3 days/week';
      case ActivityLevel.moderate:
        return 'Moderate exercise 3-5 days/week';
      case ActivityLevel.very:
        return 'Hard exercise 6-7 days/week';
      case ActivityLevel.extra:
        return 'Intense athletic training / physical job';
    }
  }

  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.very:
        return 1.725;
      case ActivityLevel.extra:
        return 1.9;
    }
  }
}

class UserProfile {
  String name;
  String gender; // 'male' or 'female'
  int age;
  double heightCm;
  double weightKg;
  ActivityLevel activityLevel;
  GoalType goal;
  double targetCalories;
  double targetProtein;
  double targetCarbs;
  double targetFat;
  int targetWaterMl;
  double weeklyRateKg; // Target speed: kg lost or gained per week (e.g. 0.25, 0.5, 0.75, 1.0)
  double targetWeightKg; // Target goal weight in kg
  double startWeightKg; // Initial baseline weight in kg
  String geminiApiKey;
  int accentColorIndex;
  bool isDarkMode;
  bool isOnboarded;
  bool autoSyncTargets; // Auto recalculate & sync targets when new weight is logged

  UserProfile({
    this.name = 'Alex',
    this.gender = 'male',
    this.age = 25,
    this.heightCm = 175.0,
    this.weightKg = 70.0,
    this.activityLevel = ActivityLevel.moderate,
    this.goal = GoalType.maintain,
    this.targetCalories = 2200.0,
    this.targetProtein = 150.0,
    this.targetCarbs = 250.0,
    this.targetFat = 65.0,
    this.targetWaterMl = 2500,
    this.weeklyRateKg = 0.5,
    this.targetWeightKg = 65.0,
    this.startWeightKg = 70.0,
    this.geminiApiKey = '',
    this.accentColorIndex = 0,
    this.isDarkMode = true,
    this.isOnboarded = false,
    this.autoSyncTargets = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel.name,
      'goal': goal.name,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'targetFat': targetFat,
      'targetWaterMl': targetWaterMl,
      'weeklyRateKg': weeklyRateKg,
      'targetWeightKg': targetWeightKg,
      'startWeightKg': startWeightKg,
      'geminiApiKey': geminiApiKey,
      'accentColorIndex': accentColorIndex,
      'isDarkMode': isDarkMode,
      'isOnboarded': isOnboarded,
      'autoSyncTargets': autoSyncTargets,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    ActivityLevel level = ActivityLevel.moderate;
    try {
      level = ActivityLevel.values.firstWhere(
        (e) => e.name == json['activityLevel'],
        orElse: () => ActivityLevel.moderate,
      );
    } catch (_) {}

    GoalType goalType = GoalType.maintain;
    try {
      goalType = GoalType.values.firstWhere(
        (e) => e.name == json['goal'],
        orElse: () => GoalType.maintain,
      );
    } catch (_) {}

    final weight = (json['weightKg'] as num?)?.toDouble() ?? 70.0;
    final startW = (json['startWeightKg'] as num?)?.toDouble() ?? weight;
    final targetW = (json['targetWeightKg'] as num?)?.toDouble() ?? (weight > 5.0 ? weight - 5.0 : 65.0);

    return UserProfile(
      name: json['name'] as String? ?? 'Alex',
      gender: json['gender'] as String? ?? 'male',
      age: (json['age'] as num?)?.toInt() ?? 25,
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 175.0,
      weightKg: weight,
      activityLevel: level,
      goal: goalType,
      targetCalories: (json['targetCalories'] as num?)?.toDouble() ?? 2200.0,
      targetProtein: (json['targetProtein'] as num?)?.toDouble() ?? 150.0,
      targetCarbs: (json['targetCarbs'] as num?)?.toDouble() ?? 250.0,
      targetFat: (json['targetFat'] as num?)?.toDouble() ?? 65.0,
      targetWaterMl: (json['targetWaterMl'] as num?)?.toInt() ?? 2500,
      weeklyRateKg: (json['weeklyRateKg'] as num?)?.toDouble() ?? 0.5,
      targetWeightKg: targetW,
      startWeightKg: startW,
      geminiApiKey: json['geminiApiKey'] as String? ?? '',
      accentColorIndex: (json['accentColorIndex'] as num?)?.toInt() ?? 0,
      isDarkMode: json['isDarkMode'] as bool? ?? true,
      isOnboarded: json['isOnboarded'] as bool? ?? false,
      autoSyncTargets: json['autoSyncTargets'] as bool? ?? true,
    );
  }

  UserProfile copyWith({
    String? name,
    String? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    GoalType? goal,
    double? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    int? targetWaterMl,
    double? weeklyRateKg,
    double? targetWeightKg,
    double? startWeightKg,
    String? geminiApiKey,
    int? accentColorIndex,
    bool? isDarkMode,
    bool? isOnboarded,
    bool? autoSyncTargets,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      targetWaterMl: targetWaterMl ?? this.targetWaterMl,
      weeklyRateKg: weeklyRateKg ?? this.weeklyRateKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      startWeightKg: startWeightKg ?? this.startWeightKg,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      accentColorIndex: accentColorIndex ?? this.accentColorIndex,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      autoSyncTargets: autoSyncTargets ?? this.autoSyncTargets,
    );
  }
}
