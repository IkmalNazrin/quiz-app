import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system.dart';

class AppPerformanceIndicator extends StatelessWidget {
  final double speedFactor; // 0.0 to 1.0 (1.0 = instant, 0.0 = timeout)
  final String label;

  const AppPerformanceIndicator({
    super.key,
    required this.speedFactor,
    required this.label,
  });

  Color _getColor() {
    if (speedFactor > 0.8) return AppColors.success;
    if (speedFactor > 0.5) return AppColors.primary;
    if (speedFactor > 0.3) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                value: speedFactor,
                strokeWidth: 6,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
              ),
            ),
            Icon(Icons.speed_rounded, color: _getColor(), size: 28)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2.seconds),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: AppTypography.label.copyWith(
            color: _getColor(),
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ).animate().fadeIn().slideY(begin: 0.2),
      ],
    );
  }
}
