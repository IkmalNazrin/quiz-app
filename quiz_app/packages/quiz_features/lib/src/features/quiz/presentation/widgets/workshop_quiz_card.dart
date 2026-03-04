import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

enum WorkshopQuizRank { novice, adept, master, legend }

class WorkshopQuizCard extends StatelessWidget {
  final QuizEntity quiz;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final VoidCallback onDelete;
  final VoidCallback onAnalytics; // New callback
  final int index;

  const WorkshopQuizCard({
    super.key,
    required this.quiz,
    required this.onTap,
    required this.onPlay,
    required this.onDelete,
    required this.onAnalytics, // New required param
    required this.index,
  });

  WorkshopQuizRank get _rank {
    // Basic logic based on question count and play count
    final score = (quiz.questions.length * 0.1) + (quiz.playCount * 0.05);
    if (score >= 10) return WorkshopQuizRank.legend;
    if (score >= 5) return WorkshopQuizRank.master;
    if (score >= 2) return WorkshopQuizRank.adept;
    return WorkshopQuizRank.novice;
  }

  Color get _rankColor {
    switch (_rank) {
      case WorkshopQuizRank.novice:
        return AppColors.textSecondary;
      case WorkshopQuizRank.adept:
        return AppColors.secondary;
      case WorkshopQuizRank.master:
        return AppColors.accent;
      case WorkshopQuizRank.legend:
        return AppColors.primary;
    }
  }

  String get _rankLabel {
    switch (_rank) {
      case WorkshopQuizRank.novice:
        return 'Novice';
      case WorkshopQuizRank.adept:
        return 'Adept';
      case WorkshopQuizRank.master:
        return 'Master';
      case WorkshopQuizRank.legend:
        return 'Legend';
    }
  }

  IconData get _categoryIcon {
    switch (quiz.category.toLowerCase()) {
      case 'tech':
      case 'programming':
        return Icons.terminal_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      case 'geography':
        return Icons.public_rounded;
      case 'math':
      case 'education':
        return Icons.calculate_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Icon with Glow
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _rankColor.withValues(alpha: 0.2),
                          _rankColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border:
                          Border.all(color: _rankColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(_categoryIcon, color: _rankColor, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Title and Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: AppTypography.h3.copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.quiz_rounded,
                              label: '${quiz.questions.length} Qs',
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: Icons.play_arrow_rounded,
                              label: '${quiz.playCount}',
                            ),
                            const SizedBox(width: 8),
                            if (!quiz.isPublic)
                              const _InfoChip(
                                icon: Icons.lock_rounded,
                                label: 'Private',
                                color: AppColors.error,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Bottom Section: Rank & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rank Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _rankColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border:
                          Border.all(color: _rankColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded, size: 14, color: _rankColor),
                        const SizedBox(width: 4),
                        Text(
                          _rankLabel.toUpperCase(),
                          style: AppTypography.label.copyWith(
                            color: _rankColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Actions
                  Row(
                    children: [
                      _ActionButton(
                        icon: Icons.bar_chart_rounded, // Analytics icon
                        color: AppColors.primary,
                        onPressed: onAnalytics,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ActionButton(
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.error,
                        onPressed: onDelete,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ActionButton(
                        icon: Icons.play_circle_fill_rounded,
                        color: AppColors.success,
                        size: 36,
                        onPressed: onPlay,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (100 * index).ms)
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.1, curve: Curves.easeOutCubic);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: color ?? AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.size = 32,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: size, height: size),
      icon: Icon(icon, color: color.withValues(alpha: 0.8), size: size * 0.8),
      onPressed: onPressed,
    ).animate(onPlay: (controller) => controller.stop()).scale(
        begin: const Offset(1, 1),
        end: const Offset(0.9, 0.9),
        duration: 100.ms);
  }
}
