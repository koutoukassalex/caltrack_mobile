import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/utils.dart';
import '../../core/constants.dart';
import '../../models/user_profile.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;

  // Form Fields
  final _nameController = TextEditingController(text: 'Alex');
  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '70');

  String _gender = 'male';
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  GoalType _goal = GoalType.lose;

  // Calculated Targets
  Map<String, double> _calculatedTargets = {
    'calories': 2000.0,
    'protein': 140.0,
    'carbs': 220.0,
    'fat': 60.0,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _computeTargets() {
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final height = double.tryParse(_heightController.text) ?? 175.0;
    final age = int.tryParse(_ageController.text) ?? 25;

    _calculatedTargets = NutritionCalculator.calculateTargets(
      gender: _gender,
      weightKg: weight,
      heightCm: height,
      age: age,
      activityLevel: _activityLevel,
      goal: _goal,
    );
  }

  void _nextStep() {
    if (_currentStep == 2) {
      _computeTargets();
    }
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  Future<void> _finishOnboarding() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final height = double.tryParse(_heightController.text) ?? 175.0;
    final age = int.tryParse(_ageController.text) ?? 25;

    final updatedProfile = appProvider.profile.copyWith(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Alex',
      gender: _gender,
      age: age,
      heightCm: height,
      weightKg: weight,
      activityLevel: _activityLevel,
      goal: _goal,
      targetCalories: _calculatedTargets['calories'] ?? 2000.0,
      targetProtein: _calculatedTargets['protein'] ?? 140.0,
      targetCarbs: _calculatedTargets['carbs'] ?? 220.0,
      targetFat: _calculatedTargets['fat'] ?? 60.0,
      targetWaterMl: 2500,
      startWeightKg: weight,
      targetWeightKg: _goal == GoalType.lose ? (weight - 5.0) : _goal == GoalType.gain ? (weight + 3.0) : weight,
      weeklyRateKg: 0.5,
      isOnboarded: true,
    );

    await appProvider.updateProfile(updatedProfile);
    await appProvider.logWeight(weight, note: 'Initial baseline weigh-in', feeling: 'great');
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appProvider = Provider.of<AppProvider>(context);
    final accentColor = appProvider.currentAccentColor;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Progress Bar Indicator (steps 1, 2, 3)
              if (_currentStep > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _prevStep,
                    ),
                    Text(
                      'Step $_currentStep of 3',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 48), // spacer
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _currentStep / 3,
                  backgroundColor: theme.dividerColor.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 20),
              ],

              // Main Step Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildCurrentStep(context, accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, Color accentColor) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep(context, accentColor);
      case 1:
        return _buildPersonalInfoStep(context, accentColor);
      case 2:
        return _buildActivityAndGoalStep(context, accentColor);
      case 3:
        return _buildPlanRevealStep(context, accentColor);
      default:
        return const SizedBox.shrink();
    }
  }

  // ===== STEP 0: Welcome =====
  Widget _buildWelcomeStep(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [accentColor, accentColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('🎯', style: TextStyle(fontSize: 42)),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Welcome to\nCaLtrack AI',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: theme.colorScheme.onBackground,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your smart AI-powered nutrition coach. Track calories, log meals, and hit your fitness goals effortlessly.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: theme.colorScheme.onBackground.withOpacity(0.65),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 36),
        _buildFeatureItem('📊', 'Smart Macro Tracking', 'Calculates exact protein, carbs & fats tailored to you'),
        const SizedBox(height: 16),
        _buildFeatureItem('🍽️', '200+ Food Database', 'Instant search and 1-tap logging for common foods'),
        const SizedBox(height: 16),
        _buildFeatureItem('📸', 'AI Food Vision', 'Snap a photo of your meal and let Gemini identify the macros'),
        const SizedBox(height: 16),
        _buildFeatureItem('💧', 'Hydration & Exercise', 'Track water intake and calorie burn from your workouts'),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Let\'s Get Started',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String subtitle) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== STEP 1: Personal Info =====
  Widget _buildPersonalInfoStep(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about yourself',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This helps us compute your exact Basal Metabolic Rate (BMR).',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),

        // Name
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Your Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 18),

        // Gender Pills
        Text(
          'Gender',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onBackground.withOpacity(0.8)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _gender = 'male'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _gender == 'male' ? accentColor.withOpacity(0.15) : theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _gender == 'male' ? accentColor : theme.dividerColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text('👨 Male', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _gender = 'female'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _gender == 'female' ? accentColor.withOpacity(0.15) : theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _gender == 'female' ? accentColor : theme.dividerColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text('👩 Female', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Age, Height, Weight
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  suffixText: 'yrs',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Height',
                  suffixText: 'cm',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Current Weight',
            suffixText: 'kg',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 36),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== STEP 2: Activity Level & Goal =====
  Widget _buildActivityAndGoalStep(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity & Goal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'How active are you, and what would you like to achieve?',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 20),

        // Goal Cards
        Text(
          'Fitness Goal',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
        ),
        const SizedBox(height: 8),
        _buildGoalOption(GoalType.lose, '🔥 Lose Fat', 'Calorie deficit (-500 kcal/day)', accentColor),
        const SizedBox(height: 8),
        _buildGoalOption(GoalType.maintain, '⚖️ Maintain Weight', 'Balanced maintenance energy', accentColor),
        const SizedBox(height: 8),
        _buildGoalOption(GoalType.gain, '💪 Build Muscle', 'Caloric surplus (+350 kcal/day)', accentColor),

        const SizedBox(height: 24),

        // Activity Level Cards
        Text(
          'Activity Level',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
        ),
        const SizedBox(height: 8),
        ...ActivityLevel.values.map((lvl) {
          final isSelected = _activityLevel == lvl;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activityLevel = lvl),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor.withOpacity(0.12) : theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? accentColor : theme.dividerColor.withOpacity(0.4),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? accentColor : theme.disabledColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lvl.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          Text(
                            lvl.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Generate My Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGoalOption(GoalType type, String title, String subtitle, Color accentColor) {
    final theme = Theme.of(context);
    final isSelected = _goal == type;

    return GestureDetector(
      onTap: () => setState(() => _goal = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.12) : theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accentColor : theme.dividerColor.withOpacity(0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? accentColor : theme.disabledColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== STEP 3: Plan Reveal =====
  Widget _buildPlanRevealStep(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);
    final cal = _calculatedTargets['calories']?.round() ?? 2000;
    final p = _calculatedTargets['protein']?.round() ?? 140;
    final c = _calculatedTargets['carbs']?.round() ?? 220;
    final f = _calculatedTargets['fat']?.round() ?? 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        const Text('🎉', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          'Your Personalized Plan',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Formulated with the Mifflin-St Jeor equation for sustainable results.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),

        // Daily Calorie Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor.withOpacity(0.18), accentColor.withOpacity(0.06)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accentColor.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text(
                'DAILY CALORIE TARGET',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$cal',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              Text(
                'kcal / day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 3 Macro Pillars
        Row(
          children: [
            Expanded(
              child: _buildMacroPillar('🥩 Protein', '${p}g', AppConstants.proteinColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMacroPillar('🌾 Carbs', '${c}g', AppConstants.carbsColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMacroPillar('🥑 Fat', '${f}g', AppConstants.fatColor),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Water Goal
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💧', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Hydration Target: 2,500 ml / day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _finishOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start My Journey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Text('🚀', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMacroPillar(String label, String value, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
