import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system.dart';

class AppStreakBar extends StatelessWidget {
  final int streak;
  final double height;

  const AppStreakBar({
    super.key,
    required this.streak,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    // 0-2: Cool, 3-5: Hot, 6+: On Fire!
    final isFire = streak >= 3;
    final isSuperFire = streak >= 6;

    // Calculate progress (capped at 10 for visual fullness)
    final double progress = (streak / 10).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'STREAK',
              style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7)),
            ),
            const Spacer(),
            if (streak > 0)
              Row(
                children: [
                  Text(
                    '$streak',
                    style: AppTypography.h3.copyWith(
                      color: isFire ? AppColors.streakFire : AppColors.primary,
                      fontSize: 18,
                    ),
                  )
                      .animate(key: ValueKey(streak))
                      .scale(duration: 300.ms, curve: Curves.elasticOut),
                  if (isFire) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.local_fire_department_rounded,
                            color: AppColors.streakFire, size: 18)
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1200.ms, color: Colors.yellow)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(begin: 1.0, end: 1.2, duration: 600.ms),
                  ]
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Background Track
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: Colors.white10),
              ),
            ),

            // Fill
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: height,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: isFire
                        ? AppColors.streakGradient
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: isFire
                        ? [
                            BoxShadow(
                                color:
                                    AppColors.streakFire.withValues(alpha: 0.5),
                                blurRadius: 10)
                          ]
                        : [
                            BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 8)
                          ],
                  ),
                ).animate(key: ValueKey(streak)).shimmer(duration: 2.seconds);
              },
            ),
          ],
        ),
        if (isSuperFire)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'UNSTOPPABLE!',
              style: AppTypography.label.copyWith(
                  color: AppColors.streakFire, fontWeight: FontWeight.bold),
            ).animate().fadeIn().slideX(begin: -0.1),
          ),
      ],
    );
  }
}
