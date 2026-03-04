import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';

class ReviewStep extends ConsumerWidget {
  final String? quizId;
  const ReviewStep({super.key, this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizEditorProvider(quizId));

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_rounded,
                  color: AppColors.success, size: 28),
              SizedBox(width: AppSpacing.md),
              Text('Final Pulse Check', style: AppTypography.h2),
            ],
          ).animate().fadeIn(),
          SizedBox(height: AppSpacing.xl),
          AppCard(
            padding: EdgeInsets.all(AppSpacing.xl),
            showBorder: true,
            child: Column(
              children: [
                _buildStatRow('Title', state.quiz.title),
                Divider(height: AppSpacing.xl),
                _buildStatRow(
                    'Questions', state.quiz.questions.length.toString()),
                Divider(height: AppSpacing.xl),
                _buildStatRow(
                    'Visibility', state.quiz.isPublic ? 'Public' : 'Private'),
                Divider(height: AppSpacing.xl),
                _buildStatRow('Est. Playtime',
                    '${(state.quiz.questions.map((e) => e.timer).fold(0, (a, b) => a + b) / 60).toStringAsFixed(1)} min'),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05),
          SizedBox(height: AppSpacing.xxl),
          _buildWarningCard(state),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTypography.bodyLarge
                  .copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWarningCard(QuizEditorState state) {
    final hasEmptyQuestions =
        state.quiz.questions.any((q) => q.question.isEmpty);
    if (!hasEmptyQuestions) return const SizedBox.shrink();

    return AppCard(
      color: AppColors.error.withValues(alpha: 0.05),
      padding: EdgeInsets.all(AppSpacing.lg),
      showBorder: true,
      borderColor: AppColors.error.withValues(alpha: 0.2),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Some questions are incomplete. Please review them in the workshop.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
