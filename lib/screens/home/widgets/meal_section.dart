import 'package:flutter/material.dart';
import '../../../models/food_entry.dart';

class MealSection extends StatelessWidget {
  final MealType mealType;
  final List<FoodEntry> foods;
  final Function(String id) onDelete;
  final VoidCallback onAddFood;

  const MealSection({
    super.key,
    required this.mealType,
    required this.foods,
    required this.onDelete,
    required this.onAddFood,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories =
        foods.fold(0.0, (sum, item) => sum + item.calories).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(mealType.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      mealType.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (totalCalories > 0)
                      Text(
                        '$totalCalories kcal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 22),
                      color: Theme.of(context).colorScheme.primary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onAddFood,
                      tooltip: 'Add food to ${mealType.displayName}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (foods.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'No foods logged yet',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            )
          else ...[
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: foods.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = foods[index];
                return ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: Text(item.emoji, style: const TextStyle(fontSize: 20)),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${item.grams.round()}g  •  P: ${item.protein.round()}g  C: ${item.carbs.round()}g  F: ${item.fat.round()}g',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.calories.round()} kcal',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: Colors.redAccent.withOpacity(0.7),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => onDelete(item.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
