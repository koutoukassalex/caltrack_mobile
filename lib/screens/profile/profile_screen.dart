import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
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
  late TextEditingController _calController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _waterController;
  late TextEditingController _apiKeyController;

  late String _gender;
  late ActivityLevel _activityLevel;
  late GoalType _goal;
  bool _hideApiKey = true;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppProvider>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile.name);
    _ageController = TextEditingController(text: profile.age.toString());
    _heightController = TextEditingController(text: profile.heightCm.round().toString());
    _weightController = TextEditingController(text: profile.weightKg.toStringAsFixed(1));
    _calController = TextEditingController(text: profile.targetCalories.round().toString());
    _proteinController = TextEditingController(text: profile.targetProtein.round().toString());
    _carbsController = TextEditingController(text: profile.targetCarbs.round().toString());
    _fatController = TextEditingController(text: profile.targetFat.round().toString());
    _waterController = TextEditingController(text: profile.targetWaterMl.toString());
    _apiKeyController = TextEditingController(text: profile.geminiApiKey);

    _gender = profile.gender;
    _activityLevel = profile.activityLevel;
    _goal = profile.goal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _calController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _recalculateTargets() {
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final height = double.tryParse(_heightController.text) ?? 175.0;
    final age = int.tryParse(_ageController.text) ?? 25;

    final targets = NutritionCalculator.calculateTargets(
      gender: _gender,
      weightKg: weight,
      heightCm: height,
      age: age,
      activityLevel: _activityLevel,
      goal: _goal,
    );

    setState(() {
      _calController.text = targets['calories']!.round().toString();
      _proteinController.text = targets['protein']!.round().toString();
      _carbsController.text = targets['carbs']!.round().toString();
      _fatController.text = targets['fat']!.round().toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calculated optimal macros via Mifflin-St Jeor equation!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveAll() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final p = appProvider.profile.copyWith(
      name: _nameController.text.trim(),
      gender: _gender,
      age: int.tryParse(_ageController.text) ?? 25,
      heightCm: double.tryParse(_heightController.text) ?? 175.0,
      weightKg: double.tryParse(_weightController.text) ?? 70.0,
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile & targets saved successfully!'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          TextButton(
            onPressed: _saveAll,
            child: Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: accentColor),
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
            // 1. Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.7)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'A',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onBackground.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Biometrics & Calculator
            _buildSectionHeader('Biometrics & Goals'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
              ),
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
                          onSelected: (val) => setState(() => _gender = 'male'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('👩 Female')),
                          selected: _gender == 'female',
                          selectedColor: accentColor.withOpacity(0.2),
                          onSelected: (val) => setState(() => _gender = 'female'),
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
                        child: _buildFormField('Weight', _weightController, 'kg', const TextInputType.numberWithOptions(decimal: true)),
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
                      if (val != null) setState(() => _activityLevel = val);
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
                      DropdownMenuItem(value: GoalType.lose, child: Text('🔥 Lose Fat (-500 kcal)')),
                      DropdownMenuItem(value: GoalType.maintain, child: Text('⚖️ Maintain Weight')),
                      DropdownMenuItem(value: GoalType.gain, child: Text('💪 Build Muscle (+350 kcal)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _goal = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.bolt, color: accentColor),
                      label: Text('Auto-Calculate Targets', style: TextStyle(color: accentColor)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _recalculateTargets,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Daily Targets
            _buildSectionHeader('Daily Targets'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
              ),
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

            // 4. Appearance
            _buildSectionHeader('Appearance'),
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
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.light_mode, size: 18),
                          label: const Text('Light'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !profile.isDarkMode ? accentColor.withOpacity(0.15) : null,
                            side: BorderSide(color: !profile.isDarkMode ? accentColor : theme.dividerColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            if (profile.isDarkMode) appProvider.toggleTheme();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.dark_mode, size: 18),
                          label: const Text('Dark'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: profile.isDarkMode ? accentColor.withOpacity(0.15) : null,
                            side: BorderSide(color: profile.isDarkMode ? accentColor : theme.dividerColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            if (!profile.isDarkMode) appProvider.toggleTheme();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Accent Color',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(AppConstants.accentColors.length, (index) {
                      final color = AppConstants.accentColors[index];
                      final isSelected = profile.accentColorIndex == index;
                      return GestureDetector(
                        onTap: () => appProvider.setAccentColor(index),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.6),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 20, color: Colors.white)
                              : null,
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
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
              ),
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
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.5)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 6. Data Management
            _buildSectionHeader('Data & Backup'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
              ),
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
