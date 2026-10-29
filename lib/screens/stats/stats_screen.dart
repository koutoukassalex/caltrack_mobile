import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../core/progress_evaluator.dart';
import '../../models/weight_entry.dart';
import '../../models/user_profile.dart';

enum StatsTimeframe { days7, days30, days90, all }

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  StatsTimeframe _timeframe = StatsTimeframe.days30;

  void _showLogProgressModal(BuildContext context, double currentWeight) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final theme = Theme.of(context);
    final accentColor = appProvider.currentAccentColor;

    double weight = currentWeight > 0 ? currentWeight : 70.0;
    final weightController = TextEditingController(text: weight.toStringAsFixed(1));
    final noteController = TextEditingController();
    String? selectedFeeling = 'great';
    DateTime selectedDate = DateTime.now();

    final feelings = [
      {'id': 'energetic', 'icon': '🚀', 'label': 'High Energy'},
      {'id': 'great', 'icon': '😊', 'label': 'Great & Light'},
      {'id': 'normal', 'icon': '⚖️', 'label': 'Consistent'},
      {'id': 'tired', 'icon': '🥱', 'label': 'Fatigued / Sore'},
      {'id': 'bloated', 'icon': '💧', 'label': 'Water Retention'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('⚖️ ', style: TextStyle(fontSize: 22)),
                            Text('Log Progress & Weight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        // Date picker button
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 14),
                          label: Text(
                            DateFormat('MMM d').format(selectedDate),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Weight Input with Stepper
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 28),
                            color: accentColor,
                            onPressed: () {
                              final curr = double.tryParse(weightController.text) ?? weight;
                              final next = (curr - 0.1).clamp(20.0, 300.0);
                              weightController.text = next.toStringAsFixed(1);
                              setModalState(() {});
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: weightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                suffixText: 'kg',
                                suffixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 28),
                            color: accentColor,
                            onPressed: () {
                              final curr = double.tryParse(weightController.text) ?? weight;
                              final next = (curr + 0.1).clamp(20.0, 300.0);
                              weightController.text = next.toStringAsFixed(1);
                              setModalState(() {});
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text('How are you feeling today?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // Feelings chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: feelings.map((f) {
                          final isSel = selectedFeeling == f['id'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(f['icon']!, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(f['label']!, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              selected: isSel,
                              selectedColor: accentColor.withOpacity(0.2),
                              onSelected: (val) {
                                setModalState(() => selectedFeeling = val ? f['id'] : null);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 18),
                    // Progress Note
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'Optional Note / Reflection',
                        hintText: 'e.g. Fasted morning weight, feeling energized!',
                        prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),

                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          final val = double.tryParse(weightController.text);
                          if (val != null && val > 20 && val < 400) {
                            appProvider.logWeight(
                              val,
                              note: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
                              feeling: selectedFeeling,
                              date: selectedDate,
                            );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logged progress: ${val.toStringAsFixed(1)} kg on ${DateFormat("MMM d").format(selectedDate)}!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: const Text('Save Progress Entry', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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

        // Run smart progress evaluation
        final eval = ProgressEvaluator.evaluate(
          profile: profile,
          allLogs: allLogs,
          weightLogs: weightLogs,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Progress & Analytics'),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: accentColor, size: 20),
                ),
                tooltip: 'Log Weight & Progress',
                onPressed: () => _showLogProgressModal(context, profile.weightKg),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SMART COACHING FEEDBACK CARD ("Messages based if you are doing good or not")
                _buildCoachingFeedbackCard(eval, accentColor, theme),

                const SizedBox(height: 18),

                // 2. GOAL JOURNEY & PACE TRACKER CARD
                _buildGoalJourneyCard(profile, eval, accentColor, theme),

                const SizedBox(height: 18),

                // 3. LOG PROGRESS HERO QUICK-ACTION BANNER
                _buildQuickLogBanner(profile, accentColor, theme),

                const SizedBox(height: 24),

                // 4. TIMEFRAME SELECTOR + WEIGHT TRAJECTORY CHART
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weight History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    _buildTimeframeSelector(theme, accentColor),
                  ],
                ),
                const SizedBox(height: 12),
                _buildWeightChartCard(weightLogs, profile, accentColor, theme),

                const SizedBox(height: 24),

                // 5. WEEKLY CALORIE ADHERENCE & DEFICIT CHART
                _buildCalorieOverviewCard(allLogs, profile, accentColor, theme),

                const SizedBox(height: 24),

                // 6. MACRONUTRIENT DISTRIBUTION
                _buildMacroDistributionCard(allLogs, profile, accentColor, theme),

                const SizedBox(height: 24),

                // 7. RECENT PROGRESS LOGS HISTORY
                _buildProgressHistorySection(weightLogs, appProvider, accentColor, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== 1. Smart Coaching Feedback Card =====
  Widget _buildCoachingFeedbackCard(ProgressEvaluationResult eval, Color accentColor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: eval.statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: eval.statusColor.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: eval.statusColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(eval.statusIcon, color: eval.statusColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: eval.statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        eval.statusBadge.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: eval.statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      eval.statusTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            eval.message,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: theme.colorScheme.onBackground.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    eval.actionableTip,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Deficit Summary Chips
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Actual Deficit',
                        style: TextStyle(fontSize: 10, color: theme.colorScheme.onBackground.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${eval.averageDailyDeficit.round()} kcal/d',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: eval.statusColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Target Pace Deficit',
                        style: TextStyle(fontSize: 10, color: theme.colorScheme.onBackground.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${eval.targetDailyDeficit.round()} kcal/d',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Weekly Adherence',
                        style: TextStyle(fontSize: 10, color: theme.colorScheme.onBackground.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${eval.daysLoggedPastWeek}/7 Days',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== 2. Goal Journey Card =====
  Widget _buildGoalJourneyCard(UserProfile profile, ProgressEvaluationResult eval, Color accentColor, ThemeData theme) {
    final startW = profile.startWeightKg > 0 ? profile.startWeightKg : profile.weightKg;
    final currW = profile.weightKg > 0 ? profile.weightKg : 70.0;
    final targetW = profile.targetWeightKg > 0 ? profile.targetWeightKg : (startW - 5.0);

    return Container(
      padding: const EdgeInsets.all(18),
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
                'Goal Journey',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${profile.goal == GoalType.lose ? "-" : "+"}${profile.weeklyRateKg.toStringAsFixed(2)} kg/wk pace',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Weight points: Start -> Current -> Goal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeightMilestone('Start', '${startW.toStringAsFixed(1)} kg', theme),
              Icon(Icons.arrow_forward_rounded, size: 16, color: theme.dividerColor),
              _buildWeightMilestone('Current', '${currW.toStringAsFixed(1)} kg', theme, isHighlight: true, color: accentColor),
              Icon(Icons.arrow_forward_rounded, size: 16, color: theme.dividerColor),
              _buildWeightMilestone('Target Goal', '${targetW.toStringAsFixed(1)} kg', theme, color: const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (eval.percentToGoal / 100.0).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: theme.scaffoldBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${eval.percentToGoal.toStringAsFixed(0)}% Completed',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor),
              ),
              Text(
                eval.estimatedWeeksRemaining != null
                    ? '~${eval.estimatedWeeksRemaining} weeks remaining'
                    : 'Target reached!',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightMilestone(String label, String value, ThemeData theme, {bool isHighlight = false, Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.55)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.bold,
            color: color ?? theme.colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  // ===== 3. Quick Log Banner =====
  Widget _buildQuickLogBanner(UserProfile profile, Color accentColor, ThemeData theme) {
    return InkWell(
      onTap: () => _showLogProgressModal(context, profile.weightKg),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            Text('📝', style: TextStyle(fontSize: 26)),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Today\'s Progress & Mood',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Track weight, energy levels, and daily reflections',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  // ===== 4. Timeframe Selector & Weight Chart =====
  Widget _buildTimeframeSelector(ThemeData theme, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeframeBtn(StatsTimeframe.days7, '7D', accentColor),
          _buildTimeframeBtn(StatsTimeframe.days30, '30D', accentColor),
          _buildTimeframeBtn(StatsTimeframe.days90, '90D', accentColor),
          _buildTimeframeBtn(StatsTimeframe.all, 'ALL', accentColor),
        ],
      ),
    );
  }

  Widget _buildTimeframeBtn(StatsTimeframe tf, String label, Color accentColor) {
    final isSel = _timeframe == tf;
    return GestureDetector(
      onTap: () => setState(() => _timeframe = tf),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.white : Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightChartCard(List<WeightEntry> weightLogs, UserProfile profile, Color accentColor, ThemeData theme) {
    final now = DateTime.now();
    DateTime cutoff;
    switch (_timeframe) {
      case StatsTimeframe.days7:
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case StatsTimeframe.days30:
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case StatsTimeframe.days90:
        cutoff = now.subtract(const Duration(days: 90));
        break;
      case StatsTimeframe.all:
        cutoff = DateTime(2000);
        break;
    }

    final filtered = weightLogs.where((e) => e.date.isAfter(cutoff)).toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            const Text('📊', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              'No weight entries in this period',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "+ Log Progress" to record your first entry.',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onBackground.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    double minY = filtered.first.weightKg;
    double maxY = filtered.first.weightKg;
    for (var e in filtered) {
      if (e.weightKg < minY) minY = e.weightKg;
      if (e.weightKg > maxY) maxY = e.weightKg;
    }
    if (profile.targetWeightKg > 0) {
      if (profile.targetWeightKg < minY) minY = profile.targetWeightKg;
      if (profile.targetWeightKg > maxY) maxY = profile.targetWeightKg;
    }
    minY = (minY - 2).floorToDouble();
    maxY = (maxY + 2).ceilToDouble();

    final spots = <FlSpot>[];
    for (int i = 0; i < filtered.length; i++) {
      spots.add(FlSpot(i.toDouble(), filtered[i].weightKg));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
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
                'Weight Trend (${filtered.length} logs)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
              ),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Actual', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 12),
                  Container(width: 8, height: 2, color: const Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  const Text('Goal', style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(color: theme.dividerColor.withOpacity(0.2), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (filtered.length / 4).ceilToDouble().clamp(1.0, 100.0),
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < filtered.length) {
                          return Text(
                            DateFormat('M/d').format(filtered[idx].date),
                            style: TextStyle(fontSize: 10, color: theme.colorScheme.onBackground.withOpacity(0.5)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (val, meta) {
                        return Text(
                          '${val.toInt()}k',
                          style: TextStyle(fontSize: 10, color: theme.colorScheme.onBackground.withOpacity(0.5)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Actual Weight Line
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: accentColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: spots.length <= 15,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: accentColor,
                        strokeWidth: 2,
                        strokeColor: theme.cardColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: accentColor.withOpacity(0.12),
                    ),
                  ),
                  // Target Goal Line (Horizontal)
                  if (profile.targetWeightKg > 0)
                    LineChartBarData(
                      spots: [
                        FlSpot(0, profile.targetWeightKg),
                        FlSpot((filtered.length - 1).toDouble().clamp(0.0, 1000.0), profile.targetWeightKg),
                      ],
                      isCurved: false,
                      color: const Color(0xFF10B981).withOpacity(0.7),
                      barWidth: 1.5,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== 5. Weekly Calorie Adherence Bar Chart =====
  Widget _buildCalorieOverviewCard(Map<String, dynamic> allLogs, UserProfile profile, Color accentColor, ThemeData theme) {
    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final barGroups = <BarChartGroupData>[];
    double maxCal = profile.targetCalories;

    for (int i = 0; i < last7Days.length; i++) {
      final day = last7Days[i];
      final key = DateUtilsHelper.formatDateKey(day);
      final log = allLogs[key];
      final cal = log != null ? log.totalCalories as double : 0.0;
      if (cal > maxCal) maxCal = cal;

      // Color logic: green if under target (in deficit), amber if near, red if surplus
      Color barColor = accentColor;
      if (cal > 0) {
        if (cal <= profile.targetCalories) {
          barColor = const Color(0xFF10B981);
        } else if (cal <= profile.targetCalories * 1.15) {
          barColor = const Color(0xFFF59E0B);
        } else {
          barColor = const Color(0xFFEF4444);
        }
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: cal,
              color: barColor,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
      );
    }

    return Container(
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
                'Weekly Calorie Adherence',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
              ),
              Text(
                'Goal: ${profile.targetCalories.round()} kcal',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: (maxCal * 1.15).ceilToDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(color: theme.dividerColor.withOpacity(0.2), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (val, meta) => Text(
                        '${(val / 1000).toStringAsFixed(1)}k',
                        style: TextStyle(fontSize: 10, color: theme.colorScheme.onBackground.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < last7Days.length) {
                          return Text(
                            DateFormat('E').format(last7Days[idx]),
                            style: TextStyle(fontSize: 10, color: theme.colorScheme.onBackground.withOpacity(0.6)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== 6. Macro Distribution Card =====
  Widget _buildMacroDistributionCard(Map<String, dynamic> allLogs, UserProfile profile, Color accentColor, ThemeData theme) {
    final now = DateTime.now();
    double totalP = 0, totalC = 0, totalF = 0;
    int loggedDays = 0;

    for (int i = 0; i < 7; i++) {
      final key = DateUtilsHelper.formatDateKey(now.subtract(Duration(days: i)));
      final log = allLogs[key];
      if (log != null && log.foods.isNotEmpty) {
        totalP += log.totalProtein;
        totalC += log.totalCarbs;
        totalF += log.totalFat;
        loggedDays++;
      }
    }

    final avgP = loggedDays > 0 ? (totalP / loggedDays) : profile.targetProtein;
    final avgC = loggedDays > 0 ? (totalC / loggedDays) : profile.targetCarbs;
    final avgF = loggedDays > 0 ? (totalF / loggedDays) : profile.targetFat;

    return Container(
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
            'Average Daily Macros (Past 7 Days)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMacroItem('Protein', avgP, profile.targetProtein, const Color(0xFFEF4444), theme),
              const SizedBox(width: 10),
              _buildMacroItem('Carbs', avgC, profile.targetCarbs, const Color(0xFF3B82F6), theme),
              const SizedBox(width: 10),
              _buildMacroItem('Fats', avgF, profile.targetFat, const Color(0xFFF59E0B), theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, double actual, double target, Color color, ThemeData theme) {
    final percent = target > 0 ? (actual / target * 100).round() : 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text('${actual.round()}g', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text('Goal: ${target.round()}g ($percent%)', style: TextStyle(fontSize: 10, color: theme.colorScheme.onBackground.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  // ===== 7. Recent Progress History List =====
  Widget _buildProgressHistorySection(List<WeightEntry> weightLogs, AppProvider appProvider, Color accentColor, ThemeData theme) {
    final sorted = List<WeightEntry>.from(weightLogs)..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weigh-In Logs (${sorted.length})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
            ),
            if (sorted.isNotEmpty)
              TextButton(
                onPressed: () => _showLogProgressModal(context, appProvider.profile.weightKg),
                child: const Text('+ Add Weigh-in', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (sorted.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text('No weigh-ins recorded yet. Tap "+ Log Progress" above!'),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length.clamp(0, 15),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = sorted[index];
              // Calculate delta from preceding chronological entry (next in reverse sorted list)
              double? delta;
              if (index < sorted.length - 1) {
                delta = entry.weightKg - sorted[index + 1].weightKg;
              }

              String feelingEmoji = '⚖️';
              if (entry.feeling == 'energetic') feelingEmoji = '🚀';
              if (entry.feeling == 'great') feelingEmoji = '😊';
              if (entry.feeling == 'tired') feelingEmoji = '🥱';
              if (entry.feeling == 'bloated') feelingEmoji = '💧';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Text(feelingEmoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${entry.weightKg.toStringAsFixed(1)} kg',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              if (delta != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: delta <= 0
                                        ? const Color(0xFF10B981).withOpacity(0.15)
                                        : const Color(0xFFEF4444).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${delta > 0 ? "+" : ""}${delta.toStringAsFixed(1)} kg',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: delta <= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (entry.note != null && entry.note!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              entry.note!,
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.65)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('EEE, MMM d').format(entry.date),
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.5)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: Colors.grey,
                      onPressed: () => appProvider.deleteWeight(entry.id),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
