import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/utils.dart';
import '../../models/food_entry.dart';
import 'widgets/ai_spark_card.dart';
import 'widgets/calorie_ring.dart';
import 'widgets/budget_math_row.dart';
import 'widgets/macro_bars.dart';
import 'widgets/water_tracker.dart';
import 'widgets/quick_add_row.dart';
import 'widgets/meal_section.dart';
import 'widgets/calendar_sheet.dart';
import '../log/add_food_modal.dart';
import '../log/add_exercise_modal.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToStats;
  final VoidCallback? onNavigateToProfile;

  const HomeScreen({
    super.key,
    this.onNavigateToStats,
    this.onNavigateToProfile,
  });

  void _showAddFoodModal(BuildContext context, MealType mealType) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddFoodModal(
        initialMeal: mealType,
        onAddFood: (entry) {
          appProvider.addFood(entry);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged ${entry.name} (${entry.calories.round()} kcal)'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showAddExerciseModal(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExerciseModal(
        profile: appProvider.profile,
        onAddExercise: (entry) {
          appProvider.addExercise(entry);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged workout: ${entry.name} (-${entry.caloriesBurned.round()} kcal)'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showCalendar(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalendarSheet(
        selectedDate: appProvider.currentDate,
        allLogs: appProvider.allLogs,
        onSelectDate: (date) {
          appProvider.setDate(date);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final profile = appProvider.profile;
        final log = appProvider.currentLog;
        final accentColor = appProvider.currentAccentColor;
        final currentDate = appProvider.currentDate;
        final now = DateTime.now();
        final isToday = currentDate.year == now.year &&
            currentDate.month == now.month &&
            currentDate.day == now.day;

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top App Bar / Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Greeting + Theme Toggle + Avatar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateUtilsHelper.getGreeting(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.name.isNotEmpty ? profile.name : 'Alex',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    color: theme.colorScheme.onBackground,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // Theme Toggle Button
                                IconButton(
                                  icon: Icon(
                                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                    size: 22,
                                    color: theme.colorScheme.onBackground.withOpacity(0.8),
                                  ),
                                  tooltip: 'Toggle Theme',
                                  onPressed: () => appProvider.toggleTheme(),
                                ),
                                const SizedBox(width: 4),
                                // Avatar Circle
                                GestureDetector(
                                  onTap: onNavigateToProfile,
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          accentColor,
                                          accentColor.withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentColor.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        profile.name.isNotEmpty
                                            ? profile.name[0].toUpperCase()
                                            : 'A',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Row 2: Date Selector Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, size: 22),
                                onPressed: () => appProvider.previousDay(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              ),
                              GestureDetector(
                                onTap: () => _showCalendar(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        size: 16,
                                        color: accentColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateUtilsHelper.formatFriendly(currentDate),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: accentColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        size: 18,
                                        color: accentColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_right,
                                  size: 22,
                                  color: isToday
                                      ? theme.disabledColor
                                      : theme.colorScheme.onBackground,
                                ),
                                onPressed: isToday ? null : () => appProvider.nextDay(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content Stream
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // AI Daily Spark Card
                      AISparkCard(
                        tip: appProvider.sparkTip,
                        onRefresh: () => appProvider.refreshSparkTip(),
                        accentColor: accentColor,
                      ),

                      const SizedBox(height: 20),

                      // Calorie Ring (Tap opens detailed Stats)
                      GestureDetector(
                        onTap: onNavigateToStats,
                        child: CalorieRing(
                          consumed: log.totalCalories,
                          goal: profile.targetCalories,
                          burned: log.totalBurnedCalories,
                          accentColor: accentColor,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Budget Math Row
                      BudgetMathRow(
                        goal: profile.targetCalories,
                        food: log.totalCalories,
                        burned: log.totalBurnedCalories,
                      ),

                      const SizedBox(height: 16),

                      // Macro Bars
                      MacroBars(
                        currentProtein: log.totalProtein,
                        targetProtein: profile.targetProtein,
                        currentCarbs: log.totalCarbs,
                        targetCarbs: profile.targetCarbs,
                        currentFat: log.totalFat,
                        targetFat: profile.targetFat,
                      ),

                      const SizedBox(height: 16),

                      // Water Tracker
                      WaterTrackerWidget(
                        currentMl: log.waterMl,
                        targetMl: profile.targetWaterMl,
                        onAddWater: (ml) => appProvider.updateWater(ml),
                        onResetWater: () => appProvider.setWater(0),
                      ),

                      const SizedBox(height: 16),

                      // Quick Add Row
                      QuickAddRow(
                        onQuickAdd: (food) {
                          appProvider.addFood(food);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Quick added ${food.name}!'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Workouts & Exercises Card if any
                      if (log.exercises.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text('🏃', style: TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Workouts & Exercise',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onBackground,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '-${log.totalBurnedCalories.round()} kcal',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8B5CF6),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...log.exercises.map((ex) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '${ex.durationMinutes} mins',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.colorScheme.onBackground.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '-${ex.caloriesBurned.round()} kcal',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF8B5CF6),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                            onPressed: () => appProvider.deleteExercise(ex.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],

                      // Section Title for Meals
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today's Meals",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.fitness_center, size: 16),
                            label: const Text('Add Workout'),
                            onPressed: () => _showAddExerciseModal(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Meals: Breakfast, Lunch, Dinner, Snacks
                      MealSection(
                        mealType: MealType.breakfast,
                        foods: log.getFoodsForMeal(MealType.breakfast),
                        onDelete: (id) => appProvider.deleteFood(id),
                        onAddFood: () => _showAddFoodModal(context, MealType.breakfast),
                      ),

                      MealSection(
                        mealType: MealType.lunch,
                        foods: log.getFoodsForMeal(MealType.lunch),
                        onDelete: (id) => appProvider.deleteFood(id),
                        onAddFood: () => _showAddFoodModal(context, MealType.lunch),
                      ),

                      MealSection(
                        mealType: MealType.dinner,
                        foods: log.getFoodsForMeal(MealType.dinner),
                        onDelete: (id) => appProvider.deleteFood(id),
                        onAddFood: () => _showAddFoodModal(context, MealType.dinner),
                      ),

                      MealSection(
                        mealType: MealType.snacks,
                        foods: log.getFoodsForMeal(MealType.snacks),
                        onDelete: (id) => appProvider.deleteFood(id),
                        onAddFood: () => _showAddFoodModal(context, MealType.snacks),
                      ),

                      // Extra spacing for floating bottom bar
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
