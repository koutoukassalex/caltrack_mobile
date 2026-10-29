import 'package:flutter/material.dart';
import '../../../core/constants.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        children: [
          _buildMacroBar(
            context: context,
            label: 'Protein',
            current: currentProtein,
            target: targetProtein,
            color: AppConstants.proteinColor,
            emoji: '🥩',
          ),
          const SizedBox(height: 12),
          _buildMacroBar(
            context: context,
            label: 'Carbs',
            current: currentCarbs,
            target: targetCarbs,
            color: AppConstants.carbsColor,
            emoji: '🌾',
          ),
          const SizedBox(height: 12),
          _buildMacroBar(
            context: context,
            label: 'Fat',
            current: currentFat,
            target: targetFat,
            color: AppConstants.fatColor,
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
    required Color color,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '${current.round()} / ${target.round()}g  (${remaining >= 0 ? "$remaining" : "+${remaining.abs()}"} left)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
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
