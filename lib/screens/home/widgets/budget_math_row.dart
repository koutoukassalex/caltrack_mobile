import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class BudgetMathRow extends StatelessWidget {
  final double goal;
  final double food;
  final double burned;

  const BudgetMathRow({
    super.key,
    required this.goal,
    required this.food,
    required this.burned,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (goal + burned - food).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.gradientCardDecoration(context: context, borderRadius: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(context, 'Base Goal', '${goal.round()}', null),
          _buildSign(context, '+'),
          _buildItem(context, 'Exercise', '${burned.round()}', const Color(0xFFA855F7)),
          _buildSign(context, '-'),
          _buildItem(context, 'Food', '${food.round()}', const Color(0xFFEF4444)),
          _buildSign(context, '='),
          _buildItem(
            context,
            'Remaining',
            '$remaining',
            remaining >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    String label,
    String val,
    Color? color, {
    bool isBold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: isBold ? 17 : 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildSign(BuildContext context, String sign) {
    return Text(
      sign,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}
