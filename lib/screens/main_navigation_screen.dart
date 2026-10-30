import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/food_entry.dart';
import 'home/home_screen.dart';
import 'stats/stats_screen.dart';
import 'chat/ai_chat_screen.dart';
import 'profile/profile_screen.dart';
import 'log/add_food_modal.dart';
import 'log/add_exercise_modal.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _showQuickAddSheet(BuildContext context) {
    final theme = Theme.of(context);
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final accentColor = appProvider.currentAccentColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Quick Log',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 1. Log Food
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🍕', style: TextStyle(fontSize: 22)),
                ),
                title: const Text('Log Food & Drink', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Search 200+ database foods or enter manually', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  _openAddFoodModal(context);
                },
              ),
              const SizedBox(height: 8),

              // 2. Scan with AI
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('📸', style: TextStyle(fontSize: 22)),
                ),
                title: const Text('Scan Meal with AI', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Snap a food photo to detect calories & macros', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _currentIndex = 2); // Switch to AI Chat tab
                },
              ),
              const SizedBox(height: 8),

              // 3. Log Workout
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🏃', style: TextStyle(fontSize: 22)),
                ),
                title: const Text('Log Workout & Exercise', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Record calories burned and exercise minutes', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  _openAddExerciseModal(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAddFoodModal(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddFoodModal(
        initialMeal: MealType.lunch,
        onAddFood: (entry) {
          appProvider.addFood(entry);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged ${entry.name}!')),
          );
        },
      ),
    );
  }

  void _openAddExerciseModal(BuildContext context) {
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
            SnackBar(content: Text('Logged ${entry.name}!')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appProvider = Provider.of<AppProvider>(context);
    final accentColor = appProvider.currentAccentColor;

    final screens = [
      HomeScreen(
        onNavigateToStats: () => setState(() => _currentIndex = 1),
        onNavigateToProfile: () => setState(() => _currentIndex = 3),
      ),
      const StatsScreen(),
      const AIChatScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(color: theme.dividerColor.withOpacity(0.4)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home', accentColor),
                _buildNavItem(1, Icons.trending_up_rounded, 'Progress', accentColor),
                // Center Quick Add Button
                GestureDetector(
                  onTap: () => _showQuickAddSheet(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: appProvider.currentAccentGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appProvider.currentAccentGradient.first.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                _buildNavItem(2, Icons.auto_awesome, 'AI Coach', accentColor),
                _buildNavItem(3, Icons.person_outline_rounded, 'Profile', accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color accentColor) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? accentColor : theme.colorScheme.onBackground.withOpacity(0.5),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? accentColor : theme.colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
