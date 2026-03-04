import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_button.dart';

class BadgeDetailsDialog extends StatelessWidget {
  final String iconEmoji;
  final String title;
  final String description;

  const BadgeDetailsDialog({
    super.key,
    required this.iconEmoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: AppColors.primaryGlow,
                ),
                child: Text(
                  iconEmoji,
                  style: const TextStyle(fontSize: 48),
                ),
              )
                  .animate()
                  .scale(curve: Curves.elasticOut, duration: 800.ms)
                  .shimmer(duration: 2.seconds),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title.toUpperCase(),
                style: AppTypography.h2.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                description,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Awesome!',
                onPressed: () => Navigator.pop(context),
                type: AppButtonType.ghost,
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.2),
      ),
    );
  }
}
