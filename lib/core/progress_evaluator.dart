import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../models/daily_log.dart';
import '../models/weight_entry.dart';
import 'utils.dart';

enum ProgressStatus {
  crushingIt,
  aheadOfPace,
  needsAdjustment,
  undereating,
  plateau,
  milestone,
  needMoreData,
}

class ProgressEvaluationResult {
  final ProgressStatus status;
  final String statusTitle;
  final String statusBadge;
  final Color statusColor;
  final IconData statusIcon;
  final String message;
  final String actionableTip;
  final double averageDailyDeficit;
  final double targetDailyDeficit;
  final int daysLoggedPastWeek;
  final double totalWeightLostKg;
  final double remainingWeightKg;
  final double percentToGoal;
  final DateTime? projectedGoalDate;
  final int? estimatedWeeksRemaining;

  ProgressEvaluationResult({
    required this.status,
    required this.statusTitle,
    required this.statusBadge,
    required this.statusColor,
    required this.statusIcon,
    required this.message,
    required this.actionableTip,
    required this.averageDailyDeficit,
    required this.targetDailyDeficit,
    required this.daysLoggedPastWeek,
    required this.totalWeightLostKg,
    required this.remainingWeightKg,
    required this.percentToGoal,
    this.projectedGoalDate,
    this.estimatedWeeksRemaining,
  });
}

class ProgressEvaluator {
  static ProgressEvaluationResult evaluate({
    required UserProfile profile,
    required Map<String, DailyLog> allLogs,
    required List<WeightEntry> weightLogs,
  }) {
    final now = DateTime.now();

    // 1. Calculate past 7 days logs
    int daysLogged = 0;
    double totalCaloriesEaten = 0;
    double totalBurned = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key = DateUtilsHelper.formatDateKey(date);
      final log = allLogs[key];
      if (log != null && log.foods.isNotEmpty) {
        daysLogged++;
        totalCaloriesEaten += log.totalCalories;
        totalBurned += log.totalBurnedCalories;
      }
    }

    final double avgCaloriesEaten = daysLogged > 0 ? (totalCaloriesEaten / daysLogged) : profile.targetCalories;
    final double avgBurned = daysLogged > 0 ? (totalBurned / daysLogged) : 0.0;

    // Estimate TDEE
    final double bmr = NutritionCalculator.calculateBMR(
      gender: profile.gender,
      weightKg: profile.weightKg > 0 ? profile.weightKg : 70.0,
      heightCm: profile.heightCm > 0 ? profile.heightCm : 175.0,
      age: profile.age > 0 ? profile.age : 25,
    );
    final double tdee = (bmr * profile.activityLevel.multiplier) + avgBurned;

    // Actual vs Target deficit
    // In weight loss: positive deficit = (tdee - eaten)
    final double actualDailyDeficit = tdee - avgCaloriesEaten;
    final double targetDailyDeficit = profile.goal == GoalType.lose
        ? (profile.weeklyRateKg * 1100.0)
        : profile.goal == GoalType.gain
            ? -(profile.weeklyRateKg * 1100.0)
            : 0.0;

    // 2. Weight tracking stats
    final double currentWeight = profile.weightKg > 0 ? profile.weightKg : 70.0;
    final double startWeight = profile.startWeightKg > 0 ? profile.startWeightKg : currentWeight;
    final double targetWeight = profile.targetWeightKg > 0 ? profile.targetWeightKg : (startWeight - 5.0);

    final double totalWeightDiff = profile.goal == GoalType.lose
        ? (startWeight - currentWeight)
        : (currentWeight - startWeight);

    final double totalDistance = (startWeight - targetWeight).abs();
    final double remainingWeight = (currentWeight - targetWeight).abs();

    double percentDone = 0.0;
    if (totalDistance > 0) {
      percentDone = ((totalDistance - remainingWeight) / totalDistance * 100.0).clamp(0.0, 100.0);
    }

    // Projections
    int? weeksRemaining;
    DateTime? projectedDate;
    if (profile.weeklyRateKg > 0 && remainingWeight > 0) {
      weeksRemaining = (remainingWeight / profile.weeklyRateKg).ceil();
      projectedDate = now.add(Duration(days: weeksRemaining * 7));
    }

    // 3. Weight log velocity & plateau detection
    double recentWeightChange = 0.0;
    bool hasPlateau = false;
    if (weightLogs.length >= 2) {
      final sorted = List<WeightEntry>.from(weightLogs)..sort((a, b) => a.date.compareTo(b.date));
      final latest = sorted.last;
      
      // Look back ~7 to 14 days
      final olderEntries = sorted.where((e) => e.date.isBefore(latest.date.subtract(const Duration(days: 6)))).toList();
      if (olderEntries.isNotEmpty) {
        final reference = olderEntries.last;
        final diff = latest.weightKg - reference.weightKg;
        recentWeightChange = diff;
        // If loss goal and difference is between -0.1 and +0.3 kg over 7+ days despite logged deficit
        if (profile.goal == GoalType.lose && diff.abs() <= 0.2 && actualDailyDeficit >= 300) {
          hasPlateau = true;
        }
      }
    }

    // Milestone detection (e.g. lost 2kg, 5kg, 10kg or 25%, 50%, 75% goal)
    final bool isMilestone = totalWeightDiff >= 2.0 && (totalWeightDiff % 2.5 <= 0.4 || percentDone >= 49 && percentDone <= 55 || percentDone >= 98);

    // 4. Decision Matrix
    if (daysLogged < 2) {
      return ProgressEvaluationResult(
        status: ProgressStatus.needMoreData,
        statusTitle: 'Log More Meals to Activate AI Insights 📋',
        statusBadge: 'Need More Data',
        statusColor: const Color(0xFF64748B),
        statusIcon: Icons.edit_calendar_rounded,
        message: 'You have only logged meals on $daysLogged day(s) this week. For the most accurate pace tracking and AI feedback, log your breakfast, lunch, and dinner consistently.',
        actionableTip: 'Tip: Take 30 seconds to snap a food photo or log your meals right after eating.',
        averageDailyDeficit: actualDailyDeficit,
        targetDailyDeficit: targetDailyDeficit,
        daysLoggedPastWeek: daysLogged,
        totalWeightLostKg: totalWeightDiff,
        remainingWeightKg: remainingWeight,
        percentToGoal: percentDone,
        projectedGoalDate: projectedDate,
        estimatedWeeksRemaining: weeksRemaining,
      );
    }

    // Undereating check
    final double safeMinimum = profile.gender.toLowerCase() == 'female' ? 1200.0 : 1500.0;
    if (profile.goal == GoalType.lose && (avgCaloriesEaten < safeMinimum || actualDailyDeficit > 1200)) {
      return ProgressEvaluationResult(
        status: ProgressStatus.undereating,
        statusTitle: 'Careful: Calorie Deficit Is Too Aggressive ⚡',
        statusBadge: 'Eating Too Little',
        statusColor: const Color(0xFF3B82F6),
        statusIcon: Icons.warning_amber_rounded,
        message: 'Your average intake (${avgCaloriesEaten.round()} kcal) is below your safe metabolic floor ($safeMinimum kcal), creating an extreme deficit of ${actualDailyDeficit.round()} kcal/day. Undereating slows down metabolism, triggers hormonal fatigue, and burns lean muscle instead of fat.',
        actionableTip: 'Fuel up with an extra 250-350 kcal of clean energy today (e.g., Greek yogurt with almonds, a banana with peanut butter, or an extra scoop of whey).',
        averageDailyDeficit: actualDailyDeficit,
        targetDailyDeficit: targetDailyDeficit,
        daysLoggedPastWeek: daysLogged,
        totalWeightLostKg: totalWeightDiff,
        remainingWeightKg: remainingWeight,
        percentToGoal: percentDone,
        projectedGoalDate: projectedDate,
        estimatedWeeksRemaining: weeksRemaining,
      );
    }

    // Plateau check
    if (hasPlateau) {
      return ProgressEvaluationResult(
        status: ProgressStatus.plateau,
        statusTitle: 'Temporary Scale Stall (Normal Adaptation) 💧',
        statusBadge: 'Plateau / Water Retention',
        statusColor: const Color(0xFF8B5CF6),
        statusIcon: Icons.water_drop_rounded,
        message: 'Your scale weight has hovered around the same mark for over a week, even though your logged deficit is solid (~${actualDailyDeficit.round()} kcal/day). Fat loss is happening beneath the surface—cellular water retention frequently masks fat drops for 1–2 weeks after training or hormonal cycles.',
        actionableTip: 'Trust the physiology: drink 2.5L+ water, get 8 hours of sleep to reduce cortisol, and measure your waist. The scale "whoosh" drop will follow.',
        averageDailyDeficit: actualDailyDeficit,
        targetDailyDeficit: targetDailyDeficit,
        daysLoggedPastWeek: daysLogged,
        totalWeightLostKg: totalWeightDiff,
        remainingWeightKg: remainingWeight,
        percentToGoal: percentDone,
        projectedGoalDate: projectedDate,
        estimatedWeeksRemaining: weeksRemaining,
      );
    }

    // Calorie Surplus / Over budget in weight loss
    if (profile.goal == GoalType.lose && actualDailyDeficit < (targetDailyDeficit * 0.45)) {
      final double overBy = (profile.targetCalories - avgCaloriesEaten);
      return ProgressEvaluationResult(
        status: ProgressStatus.needsAdjustment,
        statusTitle: 'Intake is Slightly Over Your Target Budget ⚠️',
        statusBadge: 'Needs Adjustment',
        statusColor: const Color(0xFFF59E0B),
        statusIcon: Icons.trending_up_rounded,
        message: 'Over the last $daysLogged days, your intake averaged ${avgCaloriesEaten.round()} kcal/day against your target of ${profile.targetCalories.round()} kcal. This shrinks your weekly deficit to ${actualDailyDeficit.round()} kcal/day, which will slow down your target pace of -${profile.weeklyRateKg} kg/week.',
        actionableTip: 'Identify quick wins: trim cooking oil/dressings, avoid liquid calories, and add a 20-minute post-dinner walk to bring you right back on target.',
        averageDailyDeficit: actualDailyDeficit,
        targetDailyDeficit: targetDailyDeficit,
        daysLoggedPastWeek: daysLogged,
        totalWeightLostKg: totalWeightDiff,
        remainingWeightKg: remainingWeight,
        percentToGoal: percentDone,
        projectedGoalDate: projectedDate,
        estimatedWeeksRemaining: weeksRemaining,
      );
    }

    // Milestone Celebration
    if (isMilestone && totalWeightDiff > 0.5) {
      return ProgressEvaluationResult(
        status: ProgressStatus.milestone,
        statusTitle: 'Milestone Unlocked! Outstanding Work 🎉',
        statusBadge: 'Milestone Achieved',
        statusColor: const Color(0xFFEC4899),
        statusIcon: Icons.emoji_events_rounded,
        message: 'Incredible discipline! You have shed ${totalWeightDiff.toStringAsFixed(1)} kg since starting, completing ${percentDone.round()}% of your overall journey towards ${targetWeight.toStringAsFixed(1)} kg. Your daily deficit discipline is paying off visibly.',
        actionableTip: 'Celebrate this victory! Treat yourself to new gym wear, an extra rest day, or a relaxing massage.',
        averageDailyDeficit: actualDailyDeficit,
        targetDailyDeficit: targetDailyDeficit,
        daysLoggedPastWeek: daysLogged,
        totalWeightLostKg: totalWeightDiff,
        remainingWeightKg: remainingWeight,
        percentToGoal: percentDone,
        projectedGoalDate: projectedDate,
        estimatedWeeksRemaining: weeksRemaining,
      );
    }

    // Crushing it / On Track
    final formattedDate = projectedDate != null ? DateFormat('MMMM d, yyyy').format(projectedDate) : 'upcoming weeks';
    return ProgressEvaluationResult(
      status: ProgressStatus.crushingIt,
      statusTitle: 'Crushing It! Perfect Pace & Deficit 🌟',
      statusBadge: 'On Track (Optimal)',
      statusColor: const Color(0xFF10B981),
      statusIcon: Icons.check_circle_rounded,
      message: 'You are right in the sweet spot! Your average daily deficit is -${actualDailyDeficit.round()} kcal, closely matching your chosen speed of -${profile.weeklyRateKg} kg/week (-${targetDailyDeficit.round()} kcal/day). At this steady rate, you are on track to reach your goal of ${targetWeight.toStringAsFixed(1)} kg by $formattedDate!',
      actionableTip: 'Keep hitting your ${profile.targetProtein.round()}g protein target to protect lean muscle mass and stay satiated all day long.',
      averageDailyDeficit: actualDailyDeficit,
      targetDailyDeficit: targetDailyDeficit,
      daysLoggedPastWeek: daysLogged,
      totalWeightLostKg: totalWeightDiff,
      remainingWeightKg: remainingWeight,
      percentToGoal: percentDone,
      projectedGoalDate: projectedDate,
      estimatedWeeksRemaining: weeksRemaining,
    );
  }
}
