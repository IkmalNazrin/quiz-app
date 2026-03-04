import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';

class WorkshopStep extends ConsumerWidget {
  final String? quizId;
  const WorkshopStep({super.key, this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizEditorProvider(quizId));
    final notifier = ref.read(quizEditorProvider(quizId).notifier);

    return Column(
      children: [
        _buildRankHeader(state),
        Expanded(
          child: ReorderableListView.builder(
            padding: EdgeInsets.all(AppSpacing.xl),
            itemCount: state.quiz.questions.length,
            onReorder: notifier.reorderQuestions,
            proxyDecorator: (child, index, animation) {
              return Material(
                color: Colors.transparent,
                child: child.animate().scale(
                    begin: const Offset(1, 1), end: const Offset(1.02, 1.02)),
              );
            },
            itemBuilder: (context, index) {
              final question = state.quiz.questions[index];
              return Padding(
                key: ValueKey('question_$index'),
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _QuestionListTile(
                  index: index,
                  question: question,
                  onTap: () => _openQuestionEditor(context, ref, index, quizId),
                  onRemove: () => notifier.removeQuestion(index),
                ),
              );
            },
          ),
        ),
        _buildFooter(context, state, notifier, ref),
      ],
    );
  }

  Widget _buildRankHeader(QuizEditorState state) {
    final rank = state.rank;
    final Color color;
    final String label;

    switch (rank) {
      case QuizRank.novice:
        color = AppColors.textSecondary;
        label = 'Novice';
        break;
      case QuizRank.adept:
        color = AppColors.secondary;
        label = 'Adept';
        break;
      case QuizRank.master:
        color = AppColors.warning;
        label = 'Master';
        break;
      case QuizRank.legend:
        color = AppColors.primary;
        label = 'Legend';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('QUIZ RANK',
                  style: AppTypography.label
                      .copyWith(fontWeight: FontWeight.bold)),
              AnimatedContainer(
                duration: 300.ms,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      label.toUpperCase(),
                      style: AppTypography.label.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                  height: 6,
                  decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.full))),
              AnimatedFractionallySizedBox(
                duration: 800.ms,
                curve: Curves.easeOutExpo,
                widthFactor: state.strengthScore.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildFooter(BuildContext context, QuizEditorState state,
      QuizEditorNotifier notifier, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Back',
                type: AppButtonType.ghost,
                onPressed: () => notifier.setStep(QuizEditorStep.identity),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            FloatingActionButton.extended(
              onPressed: () {
                notifier.addQuestion();
                _openQuestionEditor(
                    context, ref, state.quiz.questions.length, quizId);
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Add Question',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              heroTag: 'add_question',
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'Next',
                onPressed:
                    state.quiz.questions.every((q) => q.question.isNotEmpty)
                        ? () => notifier.setStep(QuizEditorStep.review)
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openQuestionEditor(
      BuildContext context, WidgetRef ref, int index, String? quizId) {
    final state = ref.read(quizEditorProvider(quizId));
    final question = state.quiz.questions[index];
    QuestionEditorSheet.show(context, quizId, index, question);
  }
}

class _QuestionListTile extends StatelessWidget {
  final int index;
  final dynamic question;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _QuestionListTile({
    required this.index,
    required this.question,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.md),
      showBorder: true,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTypography.label.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question.isEmpty
                      ? 'Empty Question...'
                      : question.question,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: question.question.isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${question.options.length} Options • ${question.difficulty} • ${question.timer}s',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.drag_indicator_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
