import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../core/theme.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _startWeightController;
  late TextEditingController _calController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _waterController;
  late TextEditingController _apiKeyController;

  late String _gender;
  late ActivityLevel _activityLevel;
  late GoalType _goal;
  late double _weeklyRate;
  bool _hideApiKey = true;
  double? _lastKnownProfileWeight;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppProvider>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile.name);
    _ageController = TextEditingController(text: profile.age.toString());
    _heightController = TextEditingController(text: profile.heightCm.round().toString());
    _weightController = TextEditingController(text: profile.weightKg.toStringAsFixed(1));
    _targetWeightController = TextEditingController(text: profile.targetWeightKg.toStringAsFixed(1));
    _startWeightController = TextEditingController(text: profile.startWeightKg.toStringAsFixed(1));
    _calController = TextEditingController(text: profile.targetCalories.round().toString());
    _proteinController = TextEditingController(text: profile.targetProtein.round().toString());
    _carbsController = TextEditingController(text: profile.targetCarbs.round().toString());
    _fatController = TextEditingController(text: profile.targetFat.round().toString());
    _waterController = TextEditingController(text: profile.targetWaterMl.toString());
    _apiKeyController = TextEditingController(text: profile.geminiApiKey);

    _gender = profile.gender;
    _activityLevel = profile.activityLevel;
    _goal = profile.goal;
    _weeklyRate = profile.weeklyRateKg;
    _lastKnownProfileWeight = profile.weightKg;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = Provider.of<AppProvider>(context).profile;
    // If external progress weigh-in updated the weight in provider, sync controllers
    if (_lastKnownProfileWeight != null && (profile.weightKg - _lastKnownProfileWeight!).abs() > 0.05) {
      _lastKnownProfileWeight = profile.weightKg;
      _weightController.text = profile.weightKg.toStringAsFixed(1);
      _calController.text = profile.targetCalories.round().toString();
      _proteinController.text = profile.targetProtein.round().toString();
      _carbsController.text = profile.targetCarbs.round().toString();
      _fatController.text = profile.targetFat.round().toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _startWeightController.dispose();
    _calController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  /// Recalculates targets and immediately syncs them to AppProvider & StorageService
  Future<void> _recalculateAndSyncTargets({double? customWeeklyRate, bool showToast = true}) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final weight = double.tryParse(_weightController.text) ?? appProvider.profile.weightKg;
    final height = double.tryParse(_heightController.text) ?? appProvider.profile.heightCm;
    final age = int.tryParse(_ageController.text) ?? appProvider.profile.age;
    final rate = customWeeklyRate ?? _weeklyRate;
    final targetWeight = double.tryParse(_targetWeightController.text) ?? appProvider.profile.targetWeightKg;
    final startWeight = double.tryParse(_startWeightController.text) ?? appProvider.profile.startWeightKg;

    final targets = await appProvider.recalculateAndSyncTargets(
      weightKg: weight,
      heightCm: height,
      age: age,
      gender: _gender,
      activityLevel: _activityLevel,
      goal: _goal,
      weeklyRateKg: rate,
      targetWeightKg: targetWeight,
      startWeightKg: startWeight,
      notify: true,
    );

    setState(() {
      _weeklyRate = rate;
      _lastKnownProfileWeight = weight;
      _calController.text = targets['calories']!.round().toString();
      _proteinController.text = targets['protein']!.round().toString();
      _carbsController.text = targets['carbs']!.round().toString();
      _fatController.text = targets['fat']!.round().toString();
    });

    if (showToast && mounted) {
      final deficit = (rate * 1100).round();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _goal == GoalType.lose
                      ? 'Targets auto-calculated & synced: ${targets['calories']!.round()} kcal (-$deficit kcal deficit at ${rate.toStringAsFixed(2)} kg/wk)!'
                      : _goal == GoalType.gain
                          ? 'Targets auto-calculated & synced: ${targets['calories']!.round()} kcal (+$deficit kcal surplus at ${rate.toStringAsFixed(2)} kg/wk)!'
                          : 'Targets auto-calculated & synced: ${targets['calories']!.round()} kcal maintenance!',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  Future<void> _saveAll() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentWeight = double.tryParse(_weightController.text) ?? 70.0;
    final targetWeight = double.tryParse(_targetWeightController.text) ?? (currentWeight - 5.0);
    final startWeight = double.tryParse(_startWeightController.text) ?? currentWeight;

    final p = appProvider.profile.copyWith(
      name: _nameController.text.trim(),
      gender: _gender,
      age: int.tryParse(_ageController.text) ?? 25,
      heightCm: double.tryParse(_heightController.text) ?? 175.0,
      weightKg: currentWeight,
      targetWeightKg: targetWeight,
      startWeightKg: startWeight,
      weeklyRateKg: _weeklyRate,
      activityLevel: _activityLevel,
      goal: _goal,
      targetCalories: double.tryParse(_calController.text) ?? 2000.0,
      targetProtein: double.tryParse(_proteinController.text) ?? 150.0,
      targetCarbs: double.tryParse(_carbsController.text) ?? 200.0,
      targetFat: double.tryParse(_fatController.text) ?? 65.0,
      targetWaterMl: int.tryParse(_waterController.text) ?? 2500,
      geminiApiKey: _apiKeyController.text.trim(),
    );

    await appProvider.updateProfile(p);
    _lastKnownProfileWeight = currentWeight;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Profile & targets saved and synchronized!'),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showImportModal() {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Import Data JSON',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Paste your exported CaLtrack JSON string below to restore all profile settings and food logs.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                maxLines: 6,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  hintText: '{"profile": {...}, "logs": {...}}',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final str = textController.text.trim();
                    if (str.isNotEmpty) {
                      final appProvider = Provider.of<AppProvider>(context, listen: false);
                      final success = await appProvider.importBackup(str);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Data restored successfully!' : 'Invalid JSON backup string.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Restore Data'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all your logged meals, exercises, and reset targets to defaults. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              await appProvider.resetAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data has been reset.')),
              );
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appProvider = Provider.of<AppProvider>(context);
    final profile = appProvider.profile;
    final accentColor = appProvider.currentAccentColor;
    final gradient = appProvider.currentAccentGradient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              style: TextButton.styleFrom(foregroundColor: accentColor),
              onPressed: _saveAll,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Header Card with Rich Gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 22),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.first.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'A',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: 'Your Name',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.age} yrs • ${profile.heightCm.round()} cm • ${profile.weightKg.toStringAsFixed(1)} kg',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onBackground.withOpacity(0.65)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Biometrics & Calculator
            _buildSectionHeader('Biometrics & Auto-Calculator'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 22),
              child: Column(
                children: [
                  // Gender Toggle
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('👨 Male')),
                          selected: _gender == 'male',
                          selectedColor: accentColor.withOpacity(0.2),
                          onSelected: (val) {
                            setState(() => _gender = 'male');
                            _recalculateAndSyncTargets(showToast: false);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('👩 Female')),
                          selected: _gender == 'female',
                          selectedColor: accentColor.withOpacity(0.2),
                          onSelected: (val) {
                            setState(() => _gender = 'female');
                            _recalculateAndSyncTargets(showToast: false);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Age, Height, Weight
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField('Age', _ageController, 'yrs', TextInputType.number),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFormField('Height', _heightController, 'cm', TextInputType.number),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFormField('Current Wt', _weightController, 'kg', const TextInputType.numberWithOptions(decimal: true)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Starting Weight & Target Weight
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField('Start Weight', _startWeightController, 'kg', const TextInputType.numberWithOptions(decimal: true)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField('Goal Weight', _targetWeightController, 'kg', const TextInputType.numberWithOptions(decimal: true)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Activity Level Dropdown
                  DropdownButtonFormField<ActivityLevel>(
                    value: _activityLevel,
                    decoration: InputDecoration(
                      labelText: 'Activity Level',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: ActivityLevel.values.map((lvl) {
                      return DropdownMenuItem(
                        value: lvl,
                        child: Text('${lvl.title} (${lvl.multiplier}x)', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _activityLevel = val);
                        _recalculateAndSyncTargets(showToast: false);
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Goal Type Dropdown
                  DropdownButtonFormField<GoalType>(
                    value: _goal,
                    decoration: InputDecoration(
                      labelText: 'Fitness Goal',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: const [
                      DropdownMenuItem(value: GoalType.lose, child: Text('🔥 Lose Fat (Calorie Deficit)')),
                      DropdownMenuItem(value: GoalType.maintain, child: Text('⚖️ Maintain Weight')),
                      DropdownMenuItem(value: GoalType.gain, child: Text('💪 Build Muscle (Caloric Surplus)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _goal = val);
                        _recalculateAndSyncTargets(showToast: false);
                      }
                    },
                  ),

                  // Weekly Target Pace (Speed) Selector
                  if (_goal != GoalType.maintain) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _goal == GoalType.lose ? 'Weight Loss Speed' : 'Muscle Gain Speed',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: AppTheme.gradientBadgeDecoration(gradientColors: gradient),
                                child: Text(
                                  '${_goal == GoalType.lose ? "-" : "+"}${_weeklyRate.toStringAsFixed(2)} kg / week',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Preset speed chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildSpeedChip(0.25, '🐢 Relaxed\n0.25 kg/wk', accentColor),
                                const SizedBox(width: 8),
                                _buildSpeedChip(0.50, '⚡ Standard\n0.50 kg/wk', accentColor),
                                const SizedBox(width: 8),
                                _buildSpeedChip(0.75, '🔥 Active\n0.75 kg/wk', accentColor),
                                const SizedBox(width: 8),
                                _buildSpeedChip(1.00, '🚀 Aggressive\n1.00 kg/wk', accentColor),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Fine-tune Slider
                          Slider(
                            value: _weeklyRate.clamp(0.1, 1.5),
                            min: 0.1,
                            max: 1.5,
                            divisions: 14,
                            activeColor: accentColor,
                            label: '${_weeklyRate.toStringAsFixed(2)} kg/wk',
                            onChanged: (val) {
                              final rounded = (val * 100).round() / 100;
                              setState(() => _weeklyRate = rounded);
                              _recalculateAndSyncTargets(customWeeklyRate: rounded, showToast: false);
                            },
                          ),
                          // Dynamic Calculations & Estimation Banner
                          Builder(builder: (context) {
                            final dailyAdj = (_weeklyRate * 1100).round();
                            final currW = double.tryParse(_weightController.text) ?? 70.0;
                            final targetW = double.tryParse(_targetWeightController.text) ?? 65.0;
                            final diff = (currW - targetW).abs();
                            final weeks = _weeklyRate > 0 ? (diff / _weeklyRate).ceil() : 0;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: accentColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _goal == GoalType.lose
                                          ? 'Daily Deficit: -$dailyAdj kcal • ~${weeks} wks to reach ${targetW.toStringAsFixed(1)} kg'
                                          : 'Daily Surplus: +$dailyAdj kcal • ~${weeks} wks to reach ${targetW.toStringAsFixed(1)} kg',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onBackground.withOpacity(0.85),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Auto-Calculate & Sync Targets Button with Gradient
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: AppTheme.gradientButtonDecoration(
                      gradientColors: gradient,
                      borderRadius: 16,
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                      label: const Text(
                        'Auto-Calculate & Sync Targets',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => _recalculateAndSyncTargets(showToast: true),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Auto-Sync Toggle Tile
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto-Sync on New Weigh-ins',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Adjusts daily calorie & macro targets automatically when you log a new weight entry.',
                                style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: profile.autoSyncTargets,
                          activeColor: accentColor,
                          onChanged: (val) {
                            appProvider.toggleAutoSyncTargets(val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Daily Targets
            _buildSectionHeader('Current Daily Targets'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 22),
              child: Column(
                children: [
                  _buildFormField('Calories Goal', _calController, 'kcal', TextInputType.number),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildFormField('Protein', _proteinController, 'g', TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildFormField('Carbs', _carbsController, 'g', TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildFormField('Fat', _fatController, 'g', TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildFormField('Daily Water Goal', _waterController, 'ml', TextInputType.number),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. Appearance & Gradient Themes
            _buildSectionHeader('Appearance & Gradient Themes'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Light / Dark Mode Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (profile.isDarkMode) appProvider.toggleTheme();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: !profile.isDarkMode ? LinearGradient(colors: gradient) : null,
                              color: !profile.isDarkMode ? null : theme.cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: !profile.isDarkMode ? Colors.transparent : theme.dividerColor,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.light_mode, size: 18, color: !profile.isDarkMode ? Colors.white : theme.colorScheme.onBackground),
                                const SizedBox(width: 8),
                                Text(
                                  'Light Frost',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !profile.isDarkMode ? Colors.white : theme.colorScheme.onBackground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!profile.isDarkMode) appProvider.toggleTheme();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: profile.isDarkMode ? LinearGradient(colors: gradient) : null,
                              color: profile.isDarkMode ? null : theme.cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: profile.isDarkMode ? Colors.transparent : theme.dividerColor,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.dark_mode, size: 18, color: profile.isDarkMode ? Colors.white : theme.colorScheme.onBackground),
                                const SizedBox(width: 8),
                                Text(
                                  'Deep Dark',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: profile.isDarkMode ? Colors.white : theme.colorScheme.onBackground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Gradient Accent Themes',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Signature Gradient Swatches
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(AppConstants.accentGradients.length, (index) {
                      final grad = AppConstants.accentGradients[index];
                      final name = AppConstants.accentColorNames[index];
                      final isSelected = profile.accentColorIndex == index;

                      return GestureDetector(
                        onTap: () => appProvider.setAccentColor(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                grad.first.withOpacity(isSelected ? 0.25 : 0.08),
                                grad.last.withOpacity(isSelected ? 0.15 : 0.04),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? grad.first : theme.dividerColor.withOpacity(0.4),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: grad.first.withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: grad,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: grad.first.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? grad.first : theme.colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Gemini AI Configuration
            _buildSectionHeader('AI Integration'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy_outlined, color: accentColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Google AI Studio API Key',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _hideApiKey,
                    decoration: InputDecoration(
                      hintText: 'Default shared key active',
                      suffixIcon: IconButton(
                        icon: Icon(_hideApiKey ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _hideApiKey = !_hideApiKey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Optional. CaLtrack includes a free built-in key for food vision and nutritional coaching, but you can enter your own key here.',
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.55)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 6. Data Management
            _buildSectionHeader('Data & Backup'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 22),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Export JSON Backup'),
                      onPressed: () async {
                        final backup = await appProvider.exportBackup();
                        await Clipboard.setData(ClipboardData(text: backup));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backup copied to clipboard!')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.file_upload_outlined, size: 16),
                      label: const Text('Import JSON Backup'),
                      onPressed: _showImportModal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Reset All Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _showResetDialog,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedChip(double rate, String label, Color accentColor) {
    final isSelected = (_weeklyRate - rate).abs() < 0.05;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() => _weeklyRate = rate);
        _recalculateAndSyncTargets(customWeeklyRate: rate, showToast: false);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.18) : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : theme.dividerColor.withOpacity(0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? accentColor : theme.colorScheme.onBackground,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, String suffix, TextInputType keyboardType) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
      ),
    );
  }
}
