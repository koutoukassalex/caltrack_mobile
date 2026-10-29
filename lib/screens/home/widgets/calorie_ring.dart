import 'dart:math';
import 'package:flutter/material.dart';

class CalorieRing extends StatelessWidget {
  final double consumed;
  final double goal;
  final double burned;
  final Color accentColor;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    required this.burned,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final net = consumed - burned;
    final remaining = (goal - net).round();
    final progress = goal > 0 ? (net / goal).clamp(0.0, 1.5) : 0.0;
    final isOverGoal = remaining < 0;

    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(220, 220),
              painter: _RingPainter(
                progress: progress,
                trackColor: Theme.of(context).dividerColor.withOpacity(0.2),
                progressColor: isOverGoal
                    ? const Color(0xFFEF4444)
                    : (progress >= 0.98 && progress <= 1.05
                        ? const Color(0xFFF59E0B) // Golden celebration
                        : accentColor),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  remaining.abs().toString(),
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    color: isOverGoal
                        ? const Color(0xFFEF4444)
                        : Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Text(
                  isOverGoal ? 'kcal over' : 'kcal remaining',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progress * 100).round()}% of goal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
