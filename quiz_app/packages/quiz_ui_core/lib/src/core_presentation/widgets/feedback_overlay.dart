import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system.dart';

class FeedbackOverlay extends StatelessWidget {
  final bool isCorrect;
  final int points;
  final int streak;

  const FeedbackOverlay({
    super.key,
    required this.isCorrect,
    required this.points,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.success : AppColors.error;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.4),
        backgroundBlendMode: BlendMode.darken,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                  border:
                      Border.all(color: color.withValues(alpha: 0.5), width: 4),
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 10),
                  ],
                ),
                child: Icon(
                  isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 80,
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 2.seconds),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .shimmer(duration: 1.5.seconds, color: Colors.white30),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                isCorrect ? 'EPIC SUCCESS!' : 'UNLUCKY',
                style: AppTypography.h1.copyWith(
                  color: Colors.white,
                  fontSize: 42,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: color, blurRadius: 20),
                  ],
                ),
              ).animate().slideY(begin: 0.2).fadeIn(),
              const SizedBox(height: AppSpacing.md),
              if (isCorrect && points > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: AppColors.primaryGlow,
                  ),
                  child: Text(
                    '+$points POINTS',
                    style: AppTypography.h2
                        .copyWith(color: Colors.white, fontSize: 28),
                  ),
                )
                    .animate()
                    .scale(delay: 400.ms, curve: Curves.elasticOut)
                    .fadeIn(),
              if (streak >= 2) ...[
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.streakGradient,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.streakFire.withValues(alpha: 0.4),
                          blurRadius: 15),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fireplace_rounded,
                          color: Colors.white, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '$streak STREAK!',
                        style: AppTypography.h3
                            .copyWith(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .slideY(begin: 0.5, curve: Curves.easeOutBack),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
