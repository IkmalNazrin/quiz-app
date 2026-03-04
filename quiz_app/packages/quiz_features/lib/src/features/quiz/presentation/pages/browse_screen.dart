import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../features/leaderboard/presentation/widgets/leaderboard_preview.dart';
import '../../../../features/quiz/presentation/providers/quiz_provider.dart';
import '../../../../features/quiz/presentation/providers/category_provider.dart';
import 'package:quiz_features/quiz_features.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class BrowseScreen extends ConsumerWidget {
  final void Function(String quizId, String quizTitle) onHostGame;

  const BrowseScreen({super.key, required this.onHostGame});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicQuizzesAsync = ref.watch(filteredQuizzesProvider);

    return Stack(
      children: [
        // Content Area
        _buildContent(context, ref, publicQuizzesAsync),

        // Glass Header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: GlassHeader(
            height: AppSpacing.headerHeightExpanded + 60,
            title: const Text('Discover Quizzes'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const WorkspaceSwitcher(),
                const SizedBox(height: AppSpacing.sm),
                _buildSearchAndFilters(context, ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref,
      AsyncValue<List<dynamic>> publicQuizzesAsync) {
    final headerHeight = AppSpacing.getHeaderHeight(context, expanded: true);

    return RefreshIndicator(
      displacement: headerHeight + 20,
      onRefresh: () async => ref.invalidate(publicQuizzesProvider),
      child: publicQuizzesAsync.when(
        loading: () => ListView.builder(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              headerHeight + AppSpacing.md,
              AppSpacing.md,
              AppSpacing.bottomNavBarPadding),
          itemCount: 5,
          itemBuilder: (context, index) => const QuizCardSkeleton(),
        ),
        error: (err, stack) => _buildErrorState(err.toString()),
        data: (quizzes) {
          if (quizzes.isEmpty) return _buildEmptyState();
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                headerHeight + AppSpacing.md,
                AppSpacing.md,
                AppSpacing.bottomNavBarPadding),
            itemCount: quizzes.length,
            itemBuilder: (context, index) => _InteractiveQuizCard(
              quiz: quizzes[index],
              index: index,
              onHostGame: onHostGame,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categories = [
      'All',
      'Science',
      'History',
      'Geography',
      'Movies',
      'Tech'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search quizzes...',
              hintStyle: AppTypography.bodySmall,
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.primary, size: 20),
              filled: true,
              fillColor: AppColors.background.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories
                  .map((cat) => _CategoryChip(
                        label: cat,
                        isSelected: selectedCategory == cat,
                        onTap: () => ref
                            .read(selectedCategoryProvider.notifier)
                            .state = cat,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(error,
              style: AppTypography.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('No quizzes found',
              style: AppTypography.h3.copyWith(color: AppColors.textSecondary)),
          Text('Try adjusting your filters', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _InteractiveQuizCard extends StatefulWidget {
  final dynamic quiz;
  final int index;
  final void Function(String quizId, String quizTitle) onHostGame;

  const _InteractiveQuizCard({
    required this.quiz,
    required this.index,
    required this.onHostGame,
  });

  @override
  State<_InteractiveQuizCard> createState() => _InteractiveQuizCardState();
}

class _InteractiveQuizCardState extends State<_InteractiveQuizCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final difficulty = _getDifficulty();
    final difficultyGradient = _getDifficultyGradient(difficulty);

    return RepaintBoundary(
            child: AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.zero,
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: difficultyGradient,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.md)),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(),
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: _buildBadge(Icons.star_rounded, '4.8', AppColors.accent),
              ),
              Positioned(
                bottom: AppSpacing.sm,
                left: AppSpacing.sm,
                child: _buildBadge(Icons.speed_rounded, difficulty,
                    Colors.white.withValues(alpha: 0.2)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(widget.quiz.title,
                            style: AppTypography.h3,
                            overflow: TextOverflow.ellipsis)),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.25 : 0,
                      duration: AppAnimations.normal,
                      child: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('By ${widget.quiz.creatorName ?? 'Explorer'}',
                    style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _IconLabel(Icons.layers_rounded,
                        '${widget.quiz.questions.length} Qs'),
                    const SizedBox(width: AppSpacing.md),
                    _IconLabel(Icons.timer_rounded, '15s'),
                    const Spacer(),
                    AppButton(
                      label: 'Host',
                      width: 80,
                      height: 38,
                      type: AppButtonType.primary,
                      onPressed: () =>
                          widget.onHostGame(widget.quiz.id, widget.quiz.title),
                    ),
                  ],
                ),

                // Expandable Leaderboard Section
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: Column(
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: AppSpacing.md),
                        LeaderboardPreview(
                          quizId: widget.quiz.id,
                          quizTitle: widget.quiz.title,
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: AppAnimations.normal,
                  firstCurve: Curves.easeIn,
                  secondCurve: Curves.easeOutBack,
                ),
              ],
            ),
          ),
        ],
      ),
    ))
        .animate()
        .fadeIn(delay: (widget.index * 100).ms, duration: 400.ms)
        .slideX(begin: 0.1, curve: Curves.easeOutCubic);
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(label,
                    style: AppTypography.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDifficulty() {
    if (widget.quiz.title.toLowerCase().contains('hard') ||
        widget.quiz.questions.length > 15) return 'Hard';
    if (widget.quiz.questions.length > 8) return 'Medium';
    return 'Easy';
  }

  LinearGradient _getDifficultyGradient(String difficulty) {
    switch (difficulty) {
      case 'Hard':
        return AppColors.difficultyHard;
      case 'Medium':
        return AppColors.difficultyMedium;
      default:
        return AppColors.difficultyEasy;
    }
  }

  IconData _getCategoryIcon() {
    final cat = widget.quiz.category?.toLowerCase() ?? '';
    if (cat.contains('sci')) return Icons.science_rounded;
    if (cat.contains('tech')) return Icons.computer_rounded;
    if (cat.contains('hist')) return Icons.history_edu_rounded;
    if (cat.contains('mov')) return Icons.movie_filter_rounded;
    return Icons.emoji_events_rounded;
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconLabel(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.label),
      ],
    );
  }
}
