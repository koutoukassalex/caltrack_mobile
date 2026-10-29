import 'package:flutter/material.dart';
import '../../../models/food_entry.dart';

class QuickAddRow extends StatelessWidget {
  final Function(FoodEntry) onQuickAdd;

  const QuickAddRow({
    super.key,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    final quickItems = [
      {
        'name': 'Banana',
        'emoji': '🍌',
        'cal': 105.0,
        'p': 1.3,
        'c': 27.0,
        'f': 0.3,
        'g': 118.0,
      },
      {
        'name': '2 Boiled Eggs',
        'emoji': '🥚',
        'cal': 143.0,
        'p': 13.0,
        'c': 0.7,
        'f': 10.0,
        'g': 100.0,
      },
      {
        'name': 'Whey Scoop',
        'emoji': '💪',
        'cal': 120.0,
        'p': 24.0,
        'c': 2.5,
        'f': 1.5,
        'g': 30.0,
      },
      {
        'name': 'Black Coffee',
        'emoji': '☕',
        'cal': 2.0,
        'p': 0.3,
        'c': 0.0,
        'f': 0.0,
        'g': 240.0,
      },
      {
        'name': 'Greek Yogurt',
        'emoji': '🥛',
        'cal': 100.0,
        'p': 17.0,
        'c': 6.0,
        'f': 0.7,
        'g': 170.0,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Add',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            Text(
              'Tap to log',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: quickItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final item = quickItems[idx];
              return InkWell(
                onTap: () {
                  final entry = FoodEntry(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: item['name'] as String,
                    mealType: MealType.snacks,
                    calories: item['cal'] as double,
                    protein: item['p'] as double,
                    carbs: item['c'] as double,
                    fat: item['f'] as double,
                    grams: item['g'] as double,
                    emoji: item['emoji'] as String,
                  );
                  onQuickAdd(entry);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(item['emoji'] as String,
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 6),
                      Text(
                        item['name'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${(item['cal'] as double).round()} kcal',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
