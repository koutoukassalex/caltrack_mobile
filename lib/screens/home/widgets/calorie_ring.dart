import 'dart:math';
import 'package:flutter/material.dart';

class CalorieRing extends StatelessWidget {
  final double consumed;
  final double goal;
  final double burned;
  final Color accentColor;
  final List<Color>? gradientColors;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    required this.burned,
    required this.accentColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final net = consumed - burned;
    final remaining = (goal - net).round();
    final progress = goal > 0 ? (net / goal).clamp(0.0, 1.5) : 0.0;
    final isOverGoal = remaining < 0;

    final activeGradient = isOverGoal
        ? const [Color(0xFFEF4444), Color(0xFFF87171)]
        : (progress >= 0.98 && progress <= 1.05
            ? const [Color(0xFFF59E0B), Color(0xFFFBBF24)] // Golden celebration
            : (gradientColors ?? [accentColor, accentColor.withOpacity(0.7)]));

    return Center(
      child: SizedBox(
        width: 230,
        height: 230,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient subtle radial glow behind the ring
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: activeGradient.first.withOpacity(0.12),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: const Size(230, 230),
              painter: _RingPainter(
                progress: progress,
                trackColor: Theme.of(context).dividerColor.withOpacity(0.2),
                gradientColors: activeGradient,
                accentColor: accentColor,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isOverGoal
                        ? const [Color(0xFFEF4444), Color(0xFFF87171)]
                        : [
                            Theme.of(context).colorScheme.onBackground,
                            activeGradient.first,
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    remaining.abs().toString(),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      color: Colors.white,
                    ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        activeGradient.first.withOpacity(0.18),
                        activeGradient.last.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: activeGradient.first.withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${(progress * 100).round()}% of budget',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: activeGradient.first,
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
  final List<Color> gradientColors;
  final Color accentColor;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.gradientColors,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 28) / 2;
    const strokeWidth = 15.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Active progress arc with SweepGradient
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    // Sweep gradient shader rotated so it starts at top (-pi/2)
    final sweepGradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * pi,
      colors: gradientColors.length >= 2
          ? [gradientColors.first, gradientColors.last, gradientColors.first]
          : [accentColor, accentColor.withOpacity(0.8)],
      transform: const GradientRotation(-pi / 2),
    );

    final progressPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.gradientColors != gradientColors;
  }
}
