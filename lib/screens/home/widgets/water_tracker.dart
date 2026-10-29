import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class WaterTrackerWidget extends StatelessWidget {
  final int currentMl;
  final int targetMl;
  final Function(int) onAddWater;
  final VoidCallback onResetWater;

  const WaterTrackerWidget({
    super.key,
    required this.currentMl,
    required this.targetMl,
    required this.onAddWater,
    required this.onResetWater,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        targetMl > 0 ? (currentMl / targetMl).clamp(0.0, 1.0) : 0.0;
    final int cupsCount = (currentMl / 250).floor();
    final int targetCups = (targetMl / 250).ceil();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('💧', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Hydration',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '$currentMl / $targetMl ml',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.waterColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    onPressed: onResetWater,
                    tooltip: 'Reset water',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Theme.of(context).dividerColor.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppConstants.waterColor),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onAddWater(250),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+250 ml (1 cup)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.waterColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onAddWater(500),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+500 ml (Bottle)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.waterColor,
                    side: const BorderSide(color: AppConstants.waterColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
