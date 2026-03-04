import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system.dart';

class AppTimer extends StatelessWidget {
  final int timeLeft;
  final int totalTime;

  const AppTimer({
    super.key,
    required this.timeLeft,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (timeLeft / totalTime).clamp(0.0, 1.0);
    final Color color = _getColor(percentage);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '$timeLeft',
              style: AppTypography.h1.copyWith(
                color: color,
                fontSize: 32,
              ),
            )
                .animate(target: timeLeft <= 5 ? 1 : 0)
                .scale(duration: 500.ms, curve: Curves.elasticOut)
                .shake(duration: 500.ms),
          ],
        ),
      ],
    );
  }

  Color _getColor(double percentage) {
    if (percentage > 0.6) return AppColors.success;
    if (percentage > 0.3) return AppColors.warning;
    return AppColors.error;
  }
}
