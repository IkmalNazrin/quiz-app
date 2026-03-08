import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../design_system.dart';

/// The core skeleton widget that provides the shimmer effect.
/// Used to build more complex skeleton components.
class AppSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.margin,
  });

  const AppSkeleton.circular({
    super.key,
    required double size,
    this.margin,
  })  : width = size,
        height = size,
        borderRadius = null,
        shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(AppRadius.sm)),
        shape: shape,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 2000.ms,
          color: AppColors.primary.withValues(alpha: 0.15),
          angle: 0.8, // Diagonal shimmer
          curve: Curves.easeInOutQuad,
          stops: [0.0, 0.5, 1.0],
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(
            duration: 1200.ms,
            begin: 0.4,
            end: 1.0,
            curve: Curves.easeInOut); // Subtle breathing effect
  }
}

/// Matches the layout of [WorkshopQuizCard]
class QuizCardSkeleton extends StatelessWidget {
  const QuizCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image Placeholder
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg)),
              ),
              child: const Center(
                child:
                    AppSkeleton(width: 48, height: 48, shape: BoxShape.circle),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
              duration: 2.seconds,
              color: AppColors.primary.withValues(alpha: 0.1)),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const AppSkeleton(height: 24, width: double.infinity),
                const SizedBox(height: AppSpacing.sm),
                // Subtitle / Description
                const AppSkeleton(height: 16, width: 200),
                const SizedBox(height: AppSpacing.md),

                // Tags Row
                Row(
                  children: [
                    const AppSkeleton(
                        height: 24,
                        width: 80,
                        borderRadius:
                            BorderRadius.all(Radius.circular(AppRadius.full))),
                    const SizedBox(width: AppSpacing.sm),
                    const AppSkeleton(
                        height: 24,
                        width: 60,
                        borderRadius:
                            BorderRadius.all(Radius.circular(AppRadius.full))),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                Divider(
                    color: AppColors.border.withValues(alpha: 0.3), height: 1),
                const SizedBox(height: AppSpacing.md),

                // Stats Row
                Row(
                  children: [
                    const AppSkeleton.circular(size: 20),
                    const SizedBox(width: 8),
                    const AppSkeleton(height: 14, width: 40),
                    const SizedBox(width: AppSpacing.lg),
                    const AppSkeleton.circular(size: 20),
                    const SizedBox(width: 8),
                    const AppSkeleton(height: 14, width: 60),
                    const Spacer(),
                    const AppSkeleton(
                        height: 36,
                        width: 80,
                        borderRadius:
                            BorderRadius.all(Radius.circular(AppRadius.md))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Matches the layout of a Challenge Card (Arena/Dashboard)
class ChallengeCardSkeleton extends StatelessWidget {
  const ChallengeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Icon Placeholder
          const AppSkeleton.circular(size: 56),
          const SizedBox(width: AppSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton(height: 18, width: 140),
                const SizedBox(height: 8),
                const AppSkeleton(height: 14, width: 200),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    AppSkeleton(height: 12, width: 80),
                    SizedBox(width: 12),
                    AppSkeleton(height: 12, width: 60),
                  ],
                ),
              ],
            ),
          ),

          // Action Button Placeholder
          const SizedBox(width: 8),
          const AppSkeleton(
              height: 36,
              width: 36,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm))),
        ],
      ),
    );
  }
}

/// Matches the Profile Screen Header + Stats
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        // Avatar Ring
        Stack(
          alignment: Alignment.center,
          children: [
            const AppSkeleton.circular(size: 110),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
            const AppSkeleton.circular(size: 96),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Name & Handle
        const AppSkeleton(height: 32, width: 180),
        const SizedBox(height: 8),
        const AppSkeleton(height: 16, width: 100),
        const SizedBox(height: AppSpacing.xl),

        // Level Badge
        const AppSkeleton(
            height: 40,
            width: 140,
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.full))),
        const SizedBox(height: AppSpacing.xxl),

        // Stats Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          children: List.generate(
              3,
              (index) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        AppSkeleton.circular(size: 32),
                        SizedBox(height: 8),
                        AppSkeleton(height: 14, width: 60),
                      ],
                    ),
                  )),
        ),
      ],
    );
  }
}

/// Matches Leaderboard / Analytics List Items
class LeaderboardSkeleton extends StatelessWidget {
  const LeaderboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Rank
          const AppSkeleton(height: 20, width: 20),
          const SizedBox(width: AppSpacing.md),
          // Avatar
          const AppSkeleton.circular(size: 40),
          const SizedBox(width: AppSpacing.md),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeleton(height: 16, width: 120),
                SizedBox(height: 4),
                AppSkeleton(height: 12, width: 80),
              ],
            ),
          ),
          // Score
          const AppSkeleton(
              height: 24,
              width: 60,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm))),
        ],
      ),
    );
  }
}

/// Matches the Stat Cards in Analytics
class AnalyticsStatCardSkeleton extends StatelessWidget {
  const AnalyticsStatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppSkeleton(
                  height: 34,
                  width: 34,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              AppSkeleton(
                  height: 16,
                  width: 16,
                  shape: BoxShape.circle,
                  margin: EdgeInsets.zero),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppSkeleton(height: 32, width: 80),
          const SizedBox(height: 4),
          const AppSkeleton(height: 12, width: 60),
        ],
      ),
    );
  }
}

/// Matches the Quiz Performance Row in Analytics
class AnalyticsQuizRowSkeleton extends StatelessWidget {
  const AnalyticsQuizRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: AppSkeleton(height: 20, width: 150)),
              const SizedBox(width: AppSpacing.md),
              const AppSkeleton(
                  height: 20,
                  width: 60,
                  borderRadius:
                      BorderRadius.all(Radius.circular(AppRadius.full))),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              AppSkeleton(height: 10, width: 50),
              AppSkeleton(height: 10, width: 30),
            ],
          ),
          const SizedBox(height: 6),
          const AppSkeleton(
              height: 8,
              width: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.xs))),
        ],
      ),
    );
  }
}
