import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/weight_entry.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _showWeightDialog(BuildContext context, double currentWeight) {
    _weightController.text = currentWeight > 0 ? currentWeight.toStringAsFixed(1) : '70.0';
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('⚖️ ', style: TextStyle(fontSize: 22)),
              Text('Log Weight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your weight for today to keep your progress and calorie calculations accurate.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  suffixText: 'kg',
                  suffixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(_weightController.text);
                if (val != null && val > 20 && val < 400) {
                  appProvider.logWeight(val);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logged weight: ${val.toStringAsFixed(1)} kg'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        final profile = appProvider.profile;
        final accentColor = appProvider.currentAccentColor;
        final allLogs = appProvider.allLogs;
        final weightLogs = appProvider.weightLogs;

        // Calculate past 7 days data for the chart
        final now = DateTime.now();
        final List<DateTime> last7Days = List.generate(7, (i) {
          return now.subtract(Duration(days: 6 - i));
        });

        double totalWeeklyCalories = 0.0;
        double totalWeeklyProtein = 0.0;
        double totalWeeklyCarbs = 0.0;
        double totalWeeklyFat = 0.0;
        int activeDaysCount = 0;

        final List<BarChartGroupData> barGroups = [];
        double maxCalorieFound = profile.targetCalories;

        for (int i = 0; i < last7Days.length; i++) {
          final day = last7Days[i];
          final key = DateUtilsHelper.formatDateKey(day);
          final log = allLogs[key];
          final consumed = log != null ? log.totalCalories : 0.0;

          if (consumed > 0) {
            totalWeeklyCalories += consumed;
            totalWeeklyProtein += log!.totalProtein;
            totalWeeklyCarbs += log.totalCarbs;
            totalWeeklyFat += log.totalFat;
            activeDaysCount++;
          }

          if (consumed > maxCalorieFound) {
            maxCalorieFound = consumed;
          }

          final isSelectedDay = DateUtilsHelper.formatDateKey(day) ==
              DateUtilsHelper.formatDateKey(appProvider.currentDate);

          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: consumed,
                  color: isSelectedDay
                      ? accentColor
                      : (consumed > profile.targetCalories
                          ? const Color(0xFFEF4444)
                          : accentColor.withOpacity(0.55)),
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
          );
        }

        final avgCalories = activeDaysCount > 0 ? (totalWeeklyCalories / activeDaysCount).round() : 0;
        final avgProtein = activeDaysCount > 0 ? (totalWeeklyProtein / activeDaysCount).round() : 0;
        final avgCarbs = activeDaysCount > 0 ? (totalWeeklyCarbs / activeDaysCount).round() : 0;
        final avgFat = activeDaysCount > 0 ? (totalWeeklyFat / activeDaysCount).round() : 0;

        // Today's Macro distribution for Pie Chart
        final todayLog = appProvider.currentLog;
        final double pCal = todayLog.totalProtein * 4;
        final double cCal = todayLog.totalCarbs * 4;
        final double fCal = todayLog.totalFat * 9;
        final double totalMacroCal = pCal + cCal + fCal;

        final double pPct = totalMacroCal > 0 ? (pCal / totalMacroCal) * 100 : 33.3;
        final double cPct = totalMacroCal > 0 ? (cCal / totalMacroCal) * 100 : 33.3;
        final double fPct = totalMacroCal > 0 ? (fCal / totalMacroCal) * 100 : 33.4;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Stats & Progress'),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Weight Logging Quick Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('⚖️', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                'Weight Log',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Goal: ${profile.goal.name.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _showWeightDialog(context, profile.weightKg),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: accentColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                profile.weightKg > 0 ? profile.weightKg.toStringAsFixed(1) : '--',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'kg',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Update Today\'s Weight'),
                          onPressed: () => _showWeightDialog(context, profile.weightKg),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Weekly Calorie Overview (Bar Chart)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Calorie Overview',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Goal: ${profile.targetCalories.round()} kcal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (maxCalorieFound * 1.15).clamp(1500.0, 6000.0),
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final date = last7Days[group.x.toInt()];
                                  return BarTooltipItem(
                                    '${DateFormat('E, MMM d').format(date)}\n${rod.toY.round()} kcal',
                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    final index = val.toInt();
                                    if (index >= 0 && index < last7Days.length) {
                                      final date = last7Days[index];
                                      final label = DateFormat('E').format(date); // Mon, Tue...
                                      final isToday = DateUtilsHelper.formatDateKey(date) ==
                                          DateUtilsHelper.formatDateKey(now);
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          isToday ? 'Today' : label,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                            color: isToday
                                                ? accentColor
                                                : theme.colorScheme.onBackground.withOpacity(0.6),
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: barGroups,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Weekly Averages Grid
                Text(
                  'Weekly Averages',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        '🔥 Calories',
                        '$avgCalories kcal',
                        'Daily Avg',
                        accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        '🥩 Protein',
                        '${avgProtein}g',
                        'Daily Avg',
                        AppConstants.proteinColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        '🌾 Carbs',
                        '${avgCarbs}g',
                        'Daily Avg',
                        AppConstants.carbsColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        '🥑 Fat',
                        '${avgFat}g',
                        'Daily Avg',
                        AppConstants.fatColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 4. Macro Breakdown (Pie Chart)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Macro Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 36,
                                sections: [
                                  PieChartSectionData(
                                    color: AppConstants.proteinColor,
                                    value: pPct,
                                    title: '${pPct.round()}%',
                                    radius: 28,
                                    titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: AppConstants.carbsColor,
                                    value: cPct,
                                    title: '${cPct.round()}%',
                                    radius: 28,
                                    titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: AppConstants.fatColor,
                                    value: fPct,
                                    title: '${fPct.round()}%',
                                    radius: 28,
                                    titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegendItem('Protein', '${todayLog.totalProtein.round()}g', AppConstants.proteinColor),
                                const SizedBox(height: 10),
                                _buildLegendItem('Carbohydrates', '${todayLog.totalCarbs.round()}g', AppConstants.carbsColor),
                                const SizedBox(height: 10),
                                _buildLegendItem('Healthy Fats', '${todayLog.totalFat.round()}g', AppConstants.fatColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Weight History Log List
                Text(
                  'Weight History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                if (weightLogs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.monitor_weight_outlined, size: 38, color: theme.disabledColor),
                        const SizedBox(height: 8),
                        Text(
                          'No weight entries yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(weightLogs.length, (index) {
                    final entry = weightLogs[weightLogs.length - 1 - index]; // latest first
                    WeightEntry? prevEntry;
                    if (weightLogs.length - 2 - index >= 0) {
                      prevEntry = weightLogs[weightLogs.length - 2 - index];
                    }
                    final diff = prevEntry != null ? entry.weightKg - prevEntry.weightKg : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEE, MMM d, yyyy').format(entry.date),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              if (diff != 0.0)
                                Text(
                                  diff > 0 ? '+${diff.toStringAsFixed(1)} kg' : '${diff.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: diff > 0 ? Colors.orange : const Color(0xFF10B981),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            '${entry.weightKg.toStringAsFixed(1)} kg',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTile(
    BuildContext context,
    String label,
    String value,
    String subtitle,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onBackground.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, String grams, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          grams,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
