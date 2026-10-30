import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/utils.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
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
  int _currentStep = 0; // 0: Welcome, 1: Personal Info, 2: Goal & Activity, 3: Weight Loss Speed, 4: Plan Reveal

  // Form Fields
  final _nameController = TextEditingController(text: 'Alex');
  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '70');
  final _targetWeightController = TextEditingController(text: '65');

  String _gender = 'male';
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  GoalType _goal = GoalType.lose;
  double _weeklyRate = 0.50; // kg per week

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
    _targetWeightController.dispose();
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
      weeklyRateKg: _weeklyRate,
    );
  }

  void _nextStep() {
    // If leaving Step 1, adapt target weight if default
    if (_currentStep == 1) {
      final currentWeight = double.tryParse(_weightController.text) ?? 70.0;
      if (_goal == GoalType.lose) {
        _targetWeightController.text = (currentWeight > 5 ? currentWeight - 5.0 : 60.0).toStringAsFixed(1);
      } else if (_goal == GoalType.gain) {
        _targetWeightController.text = (currentWeight + 3.0).toStringAsFixed(1);
      } else {
        _targetWeightController.text = currentWeight.toStringAsFixed(1);
      }
    }

    // If leaving Step 3 (Speed & Target), calculate personalized targets
    if (_currentStep == 3) {
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
    final targetWeight = double.tryParse(_targetWeightController.text) ??
        (_goal == GoalType.lose ? (weight - 5.0) : _goal == GoalType.gain ? (weight + 3.0) : weight);

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
      targetWeightKg: targetWeight,
      weeklyRateKg: _weeklyRate,
      autoSyncTargets: true,
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
    final gradient = appProvider.currentAccentGradient;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Progress Bar Indicator (steps 1 to 4)
              if (_currentStep > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: _prevStep,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: AppTheme.gradientBadgeDecoration(gradientColors: gradient),
                      child: Text(
                        'Step $_currentStep of 4',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // spacer
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        Container(color: theme.dividerColor.withOpacity(0.2)),
                        FractionallySizedBox(
                          widthFactor: (_currentStep / 4).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradient),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Main Step Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildCurrentStep(context, accentColor, gradient),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, Color accentColor, List<Color> gradient) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep(context, accentColor, gradient);
      case 1:
        return _buildPersonalInfoStep(context, accentColor, gradient);
      case 2:
        return _buildActivityAndGoalStep(context, accentColor, gradient);
      case 3:
        return _buildWeightLossSpeedStep(context, accentColor, gradient);
      case 4:
        return _buildPlanRevealStep(context, accentColor, gradient);
      default:
        return const SizedBox.shrink();
    }
  }

  // ===== STEP 0: Welcome =====
  Widget _buildWelcomeStep(BuildContext context, Color accentColor, List<Color> gradient) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 96,
          height: 96,
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
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Text('🎯', style: TextStyle(fontSize: 46)),
          ),
        ),
        const SizedBox(height: 26),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [theme.colorScheme.onBackground, accentColor],
          ).createShader(bounds),
          child: const Text(
            'CaLtrack AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Next-Generation Smart Calorie & Macro Coach',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Personalized targets based on how fast you want to lose weight, multimodal AI food vision, and auto-calculating macros.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onBackground.withOpacity(0.7),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 30),
        _buildFeatureItem('⚡', 'Custom Loss Speed', 'Choose your weekly rate & we calculate exact daily deficits'),
        const SizedBox(height: 12),
        _buildFeatureItem('🔄', 'Auto Target Calculator', 'Targets stay in sync automatically whenever your weight updates'),
        const SizedBox(height: 12),
        _buildFeatureItem('📸', 'AI Vision Meal Logger', 'Snap a plate to instantly detect macros & calories with Gemini'),
        const SizedBox(height: 12),
        _buildFeatureItem('🎨', 'Gradient Themes', 'Rich luminous dark and light themes crafted for visual delight'),
        const SizedBox(height: 36),
        Container(
          width: double.infinity,
          height: 56,
          decoration: AppTheme.gradientButtonDecoration(gradientColors: gradient),
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Let\'s Get Started',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
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
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.65),
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
  Widget _buildPersonalInfoStep(BuildContext context, Color accentColor, List<Color> gradient) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about yourself',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'We use the clinical Mifflin-St Jeor formula to determine your exact metabolic burn rate.',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onBackground.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 24),

        // Name
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Your Name',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 18),

        // Gender Pills
        Text(
          'Biological Sex',
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
                  decoration: AppTheme.gradientCardDecoration(
                    context: context,
                    accentGlow: _gender == 'male' ? accentColor : null,
                    isSelected: _gender == 'male',
                    borderRadius: 16,
                  ),
                  child: Center(
                    child: Text(
                      '👨 Male',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _gender == 'male' ? accentColor : theme.colorScheme.onBackground,
                      ),
                    ),
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
                  decoration: AppTheme.gradientCardDecoration(
                    context: context,
                    accentGlow: _gender == 'female' ? accentColor : null,
                    isSelected: _gender == 'female',
                    borderRadius: 16,
                  ),
                  child: Center(
                    child: Text(
                      '👩 Female',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _gender == 'female' ? accentColor : theme.colorScheme.onBackground,
                      ),
                    ),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
            prefixIcon: const Icon(Icons.monitor_weight_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),

        const SizedBox(height: 36),

        Container(
          width: double.infinity,
          height: 54,
          decoration: AppTheme.gradientButtonDecoration(gradientColors: gradient),
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== STEP 2: Activity Level & Goal =====
  Widget _buildActivityAndGoalStep(BuildContext context, Color accentColor, List<Color> gradient) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal & Activity Level',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'What is your primary objective right now?',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onBackground.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 20),

        // Goal Cards
        Text(
          'Fitness Objective',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
        ),
        const SizedBox(height: 8),
        _buildGoalOption(GoalType.lose, '🔥 Lose Fat', 'Sustain a tailored calorie deficit to shed body fat', accentColor, gradient),
        const SizedBox(height: 10),
        _buildGoalOption(GoalType.maintain, '⚖️ Maintain Weight', 'Optimize energy & maintain current physique', accentColor, gradient),
        const SizedBox(height: 10),
        _buildGoalOption(GoalType.gain, '💪 Build Muscle', 'Caloric surplus for lean athletic hypertrophy', accentColor, gradient),

        const SizedBox(height: 24),

        // Activity Level Cards
        Text(
          'Daily Activity Level',
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
                decoration: AppTheme.gradientCardDecoration(
                  context: context,
                  accentGlow: isSelected ? accentColor : null,
                  isSelected: isSelected,
                  borderRadius: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? accentColor : theme.dividerColor,
                          width: 2,
                        ),
                        color: isSelected ? accentColor : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
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
                              color: isSelected ? accentColor : theme.colorScheme.onBackground,
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

        const SizedBox(height: 28),

        Container(
          width: double.infinity,
          height: 54,
          decoration: AppTheme.gradientButtonDecoration(gradientColors: gradient),
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Next: Weight Loss Pace', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGoalOption(GoalType type, String title, String subtitle, Color accentColor, List<Color> gradient) {
    final isSelected = _goal == type;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _goal = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.gradientCardDecoration(
          context: context,
          accentGlow: isSelected ? accentColor : null,
          isSelected: isSelected,
          borderRadius: 16,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : theme.dividerColor,
                  width: 2,
                ),
                color: isSelected ? accentColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? accentColor : theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onBackground.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== STEP 3: Weight Loss Speed & Target Goal =====
  Widget _buildWeightLossSpeedStep(BuildContext context, Color accentColor, List<Color> gradient) {
    final theme = Theme.of(context);
    final currentW = double.tryParse(_weightController.text) ?? 70.0;
    final targetW = double.tryParse(_targetWeightController.text) ?? (currentW - 5.0);
    final diff = (currentW - targetW).abs();
    final weeks = _weeklyRate > 0 ? (diff / _weeklyRate).ceil() : 0;
    final dailyDeficit = (_weeklyRate * 1100).round();

    final isLoss = _goal == GoalType.lose;
    final isGain = _goal == GoalType.gain;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLoss
              ? 'How fast do you want to lose weight?'
              : isGain
                  ? 'How fast do you want to build muscle?'
                  : 'Your Maintenance Target',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isLoss
              ? 'Select your weekly fat loss pace. We adjust your daily calorie deficit and macros to protect muscle while shedding fat.'
              : isGain
                  ? 'Select your weekly muscle building pace. A controlled caloric surplus maximizes hypertrophy while minimizing fat accumulation.'
                  : 'We will calculate your exact maintenance calories so your weight stays perfectly steady.',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onBackground.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 20),

        if (isLoss || isGain) ...[
          // Speed Presets
          Text(
            isLoss ? 'Recommended Loss Speeds' : 'Recommended Surplus Speeds',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
          ),
          const SizedBox(height: 10),

          if (isLoss) ...[
            _buildSpeedCard(
              rate: 0.25,
              title: '🐢 Gentle & Sustainable',
              rateLabel: '-0.25 kg / week',
              detail: '-275 kcal/day deficit • Easiest to maintain long-term',
              accentColor: accentColor,
            ),
            const SizedBox(height: 8),
            _buildSpeedCard(
              rate: 0.50,
              title: '⚡ Steady & Recommended',
              rateLabel: '-0.50 kg / week',
              detail: '-550 kcal/day deficit • Optimal fat loss with muscle retention',
              accentColor: accentColor,
              isRecommended: true,
            ),
            const SizedBox(height: 8),
            _buildSpeedCard(
              rate: 0.75,
              title: '🔥 Active & Fast',
              rateLabel: '-0.75 kg / week',
              detail: '-825 kcal/day deficit • Faster results for committed users',
              accentColor: accentColor,
            ),
            const SizedBox(height: 8),
            _buildSpeedCard(
              rate: 1.00,
              title: '🚀 Intensive & Aggressive',
              rateLabel: '-1.00 kg / week',
              detail: '-1,100 kcal/day deficit • Maximum safe speed',
              accentColor: accentColor,
            ),
          ] else ...[
            _buildSpeedCard(
              rate: 0.25,
              title: '🐢 Lean Hypertrophy',
              rateLabel: '+0.25 kg / week',
              detail: '+275 kcal/day surplus • Clean lean gains',
              accentColor: accentColor,
            ),
            const SizedBox(height: 8),
            _buildSpeedCard(
              rate: 0.35,
              title: '⚡ Standard Muscle Gain',
              rateLabel: '+0.35 kg / week',
              detail: '+385 kcal/day surplus • Recommended for athletic gains',
              accentColor: accentColor,
              isRecommended: true,
            ),
            const SizedBox(height: 8),
            _buildSpeedCard(
              rate: 0.50,
              title: '💪 Power Surplus',
              rateLabel: '+0.50 kg / week',
              detail: '+550 kcal/day surplus • For hardgainers & strength focus',
              accentColor: accentColor,
            ),
          ],

          const SizedBox(height: 20),

          // Custom Rate Slider
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fine-tune weekly speed',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: AppTheme.gradientBadgeDecoration(gradientColors: gradient),
                      child: Text(
                        '${isLoss ? "-" : "+"}${_weeklyRate.toStringAsFixed(2)} kg / wk',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _weeklyRate.clamp(0.10, 1.50),
                  min: 0.10,
                  max: 1.50,
                  divisions: 14,
                  activeColor: accentColor,
                  label: '${_weeklyRate.toStringAsFixed(2)} kg/wk',
                  onChanged: (val) {
                    setState(() {
                      _weeklyRate = (val * 100).round() / 100;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Target Goal Weight Input
          TextField(
            controller: _targetWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              labelText: isLoss ? 'Goal Target Weight' : 'Target Bulking Weight',
              suffixText: 'kg',
              prefixIcon: const Icon(Icons.flag_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),

          const SizedBox(height: 16),

          // Dynamic Estimation Banner with Gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor.withOpacity(0.18), accentColor.withOpacity(0.06)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accentColor.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome, color: accentColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoss
                            ? 'Daily Deficit: -$dailyDeficit kcal / day'
                            : 'Daily Surplus: +$dailyDeficit kcal / day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Projected timeline: ~${weeks > 0 ? weeks : 1} weeks to reach ${targetW.toStringAsFixed(1)} kg (${diff.toStringAsFixed(1)} kg total)',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onBackground.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Maintain Weight Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 18),
            child: Row(
              children: [
                const Text('⚖️', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Maintaining current weight of ${currentW.toStringAsFixed(1)} kg.\nYour daily calories will match your exact maintenance expenditure.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 30),

        Container(
          width: double.infinity,
          height: 54,
          decoration: AppTheme.gradientButtonDecoration(gradientColors: gradient),
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Generate My Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSpeedCard({
    required double rate,
    required String title,
    required String rateLabel,
    required String detail,
    required Color accentColor,
    bool isRecommended = false,
  }) {
    final isSelected = (_weeklyRate - rate).abs() < 0.04;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _weeklyRate = rate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: AppTheme.gradientCardDecoration(
          context: context,
          accentGlow: isSelected ? accentColor : null,
          isSelected: isSelected,
          borderRadius: 16,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : theme.dividerColor,
                  width: 2,
                ),
                color: isSelected ? accentColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? accentColor : theme.colorScheme.onBackground,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'POPULAR',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onBackground.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              rateLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? accentColor : theme.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== STEP 4: Plan Reveal =====
  Widget _buildPlanRevealStep(BuildContext context, Color accentColor, List<Color> gradient) {
    final theme = Theme.of(context);
    final cal = _calculatedTargets['calories']?.round() ?? 2000;
    final p = _calculatedTargets['protein']?.round() ?? 140;
    final c = _calculatedTargets['carbs']?.round() ?? 220;
    final f = _calculatedTargets['fat']?.round() ?? 60;
    final currentW = double.tryParse(_weightController.text) ?? 70.0;
    final targetW = double.tryParse(_targetWeightController.text) ?? 65.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: gradient),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text('🎉', style: TextStyle(fontSize: 38)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your Tailored Plan is Ready!',
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
          'Formulated with Mifflin-St Jeor equation at your chosen ${_weeklyRate.toStringAsFixed(2)} kg/wk pace.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onBackground.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 22),

        // Daily Calorie Hero Card with Rich Gradient
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradient.first.withOpacity(0.22),
                gradient.last.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gradient.first.withOpacity(0.45), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: AppTheme.gradientBadgeDecoration(gradientColors: gradient),
                child: Text(
                  'DAILY CALORIE BUDGET',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [theme.colorScheme.onBackground, accentColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: Text(
                  '$cal',
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'kcal / day to hit your goal',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
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
              child: _buildMacroPillar('🥩 Protein', '${p}g', AppConstants.proteinGradient),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMacroPillar('🌾 Carbs', '${c}g', AppConstants.carbsGradient),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMacroPillar('🥑 Fat', '${f}g', AppConstants.fatGradient),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Goal Pace & Target Weight Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Pace: ${_weeklyRate.toStringAsFixed(2)} kg / week',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      Text(
                        'Goal: ${targetW.toStringAsFixed(1)} kg (${(currentW - targetW).abs().toStringAsFixed(1)} kg delta)',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Auto-Sync ON',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        Container(
          width: double.infinity,
          height: 56,
          decoration: AppTheme.gradientButtonDecoration(gradientColors: gradient),
          child: ElevatedButton(
            onPressed: _finishOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start My Journey', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                Text('🚀', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMacroPillar(String label, String value, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 16),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gradient.first)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
