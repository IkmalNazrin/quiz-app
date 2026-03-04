import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_features/quiz_features.dart';
import '../../../../features/quiz/presentation/providers/quiz_provider.dart';
import '../../../../features/quiz/presentation/widgets/workshop_quiz_card.dart';
import '../../../../features/analytics/presentation/providers/analytics_provider.dart';
import '../../../../features/ai/presentation/widgets/ai_genesis_modal.dart';
import '../../../../features/quiz/presentation/providers/quiz_editor_provider.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class WorkshopScreen extends ConsumerWidget {
  final Function(String, String) onHostGame;

  const WorkshopScreen({super.key, required this.onHostGame});

  void _openAIGenesis(BuildContext context, WidgetRef ref) async {
    final List<QuestionEntity>? questions =
        await showModalBottomSheet<List<QuestionEntity>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AIGenesisModal(),
    );

    if (questions != null && questions.isNotEmpty && context.mounted) {
      // Initialize the editor with these questions
      ref
          .read(quizEditorProvider(null).notifier)
          .initializeWithQuestions('AI Generated Quiz', questions);
      _navigateToEditor(context, ref);
    }
  }

  void _navigateToEditor(BuildContext context, WidgetRef ref,
      {String? quizId}) async {
    final result = await context.pushNamed(
      'editor',
      pathParameters: {'id': quizId ?? 'new'},
    );
    if (result == true) {
      unawaited(ref.read(myQuizzesProvider.notifier).refresh());
    }
  }

  void _navigateToAnalytics(BuildContext context) {
    context.pushNamed('analytics');
  }

  void _navigateToQuizAnalytics(BuildContext context, String quizId) {
    context.pushNamed(
      'quiz_analytics',
      pathParameters: {'id': quizId},
    );
  }

  void _confirmDeleteQuiz(BuildContext context, WidgetRef ref, String quizId) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ...
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancel',
                        type: AppButtonType.ghost,
                        color: AppColors.textSecondary,
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: 'Delete',
                        type: AppButtonType.primary,
                        color: AppColors.error,
                        onPressed: () {
                          context.pop();
                          ref
                              .read(myQuizzesProvider.notifier)
                              .deleteQuiz(quizId);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .scale(curve: Curves.elasticOut, duration: 600.ms)
              .fadeIn(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(myQuizzesProvider);
    final headerHeight = AppSpacing.getHeaderHeight(context);

    return Column(
      children: [
        GlassHeader(
          title: const Text('Workshop'),
        ),
        const WorkspaceSwitcher(),
        Expanded(
          child: quizzesAsync.when(
            data: (quizzes) {
              if (quizzes.isEmpty) {
                return _buildEmptyState(context, ref);
              }
              return RefreshIndicator.adaptive(
                onRefresh: () => ref.read(myQuizzesProvider.notifier).refresh(),
                edgeOffset: headerHeight,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      headerHeight + AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.bottomNavBarPadding),
                  itemCount: quizzes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Creator Hub',
                              style: AppTypography.h1,
                            ).animate().fadeIn().slideX(begin: -0.1),
                            Text(
                              'Manage and publish your masterpieces.',
                              style: AppTypography.bodySmall,
                            )
                                .animate()
                                .fadeIn(delay: 100.ms)
                                .slideX(begin: -0.05),
                            const SizedBox(height: AppSpacing.lg),

                            // Prominent Analytics Discovery Banner
                            _buildPerformanceBanner(context, ref),

                            const SizedBox(height: AppSpacing.lg),

                            AppButton(
                              label: 'New Creation',
                              type: AppButtonType.premium,
                              icon: const Icon(Icons.add_rounded,
                                  color: Colors.white),
                              onPressed: () => _navigateToEditor(context, ref),
                            ).animate().scale(
                                delay: 200.ms,
                                curve: Curves.elasticOut,
                                duration: 800.ms),
                            const SizedBox(height: AppSpacing.md),

                            AppButton(
                              label: 'AI Genesis',
                              type: AppButtonType.ghost,
                              color: AppColors.primary,
                              icon: const Icon(Icons.auto_awesome_rounded,
                                  color: AppColors.primary),
                              onPressed: () => _openAIGenesis(context, ref),
                            )
                                .animate(onPlay: (c) => c.repeat())
                                .shimmer(delay: 3.seconds, duration: 2.seconds)
                                .fadeIn(delay: 400.ms),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ),
                      );
                    }

                    final quiz = quizzes[index - 1];
                    return WorkshopQuizCard(
                      quiz: quiz,
                      index: index,
                      onTap: () =>
                          _navigateToEditor(context, ref, quizId: quiz.id),
                      onPlay: () => onHostGame(quiz.id, quiz.title),
                      onAnalytics: () =>
                          _navigateToQuizAnalytics(context, quiz.id),
                      onDelete: () => _confirmDeleteQuiz(context, ref, quiz.id),
                    );
                  },
                ),
              );
            },
            loading: () => ListView.builder(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  headerHeight + AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.bottomNavBarPadding),
              itemCount: 5,
              itemBuilder: (context, index) => const QuizCardSkeleton(),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: AppSpacing.md),
                  Text('Failed to load quizzes\n$err',
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Retry',
                    type: AppButtonType.ghost,
                    onPressed: () =>
                        ref.read(myQuizzesProvider.notifier).refresh(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceBanner(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final statsAsync =
        user != null ? ref.watch(hostAnalyticsProvider(user.id)) : null;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _navigateToAnalytics(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.secondary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.insights_rounded,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Insights',
                      style: AppTypography.h3.copyWith(fontSize: 18),
                    ),
                    statsAsync?.when(
                          data: (stats) => Text(
                            'Total Sessions: ${stats.sessionsHosted} • Avg Accuracy: ${stats.globalAvgScore}%',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          loading: () => const Text('Loading stats...',
                              style: TextStyle(fontSize: 10)),
                          error: (_, __) => const Text('Tap to view analytics',
                              style: TextStyle(fontSize: 10)),
                        ) ??
                        const Text('Tap to view analytics',
                            style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2), width: 2),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 64, color: AppColors.primary),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
            const SizedBox(height: AppSpacing.xl),
            Text('No Creations Yet', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Your workshop is ready for your first quiz. Let your creativity flow!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  label: 'Start First Quiz',
                  type: AppButtonType.premium,
                  onPressed: () => _navigateToEditor(context, ref),
                ),
                const SizedBox(width: AppSpacing.md),
                // Analytics button in empty state too? Maybe not necessary if no data.
              ],
            ),
          ],
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
    );
  }
}
