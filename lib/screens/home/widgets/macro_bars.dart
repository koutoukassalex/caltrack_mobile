import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';

class MacroBars extends StatelessWidget {
  final double currentProtein;
  final double targetProtein;
  final double currentCarbs;
  final double targetCarbs;
  final double currentFat;
  final double targetFat;

  const MacroBars({
    super.key,
    required this.currentProtein,
    required this.targetProtein,
    required this.currentCarbs,
    required this.targetCarbs,
    required this.currentFat,
    required this.targetFat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 20),
      child: Column(
        children: [
          _buildMacroBar(
            context: context,
            label: 'Protein',
            current: currentProtein,
            target: targetProtein,
            gradient: AppConstants.proteinGradient,
            emoji: '🥩',
          ),
          const SizedBox(height: 14),
          _buildMacroBar(
            context: context,
            label: 'Carbs',
            current: currentCarbs,
            target: targetCarbs,
            gradient: AppConstants.carbsGradient,
            emoji: '🌾',
          ),
          const SizedBox(height: 14),
          _buildMacroBar(
            context: context,
            label: 'Fat',
            current: currentFat,
            target: targetFat,
            gradient: AppConstants.fatGradient,
            emoji: '🥑',
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar({
    required BuildContext context,
    required String label,
    required double current,
    required double target,
    required List<Color> gradient,
    required String emoji,
  }) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final remaining = (target - current).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: gradient.first,
                  ),
                ),
              ],
            ),
            Text(
              '${current.round()} / ${target.round()}g  (${remaining >= 0 ? "$remaining" : "+${remaining.abs()}"} left)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 9,
                width: double.infinity,
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 9,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
