import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';

class IdentityStep extends ConsumerWidget {
  final String? quizId;
  const IdentityStep({super.key, this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizEditorProvider(quizId));
    final notifier = ref.read(quizEditorProvider(quizId).notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: AppSpacing.xl),

          AppCard(
            padding: EdgeInsets.all(AppSpacing.xl),
            showBorder: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CORE DETAILS',
                    style: AppTypography.label.copyWith(
                        color: AppColors.primary, letterSpacing: 1.2)),
                SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Quiz Title',
                  hintText: 'e.g., The Physics of Music',
                  initialValue: state.quiz.title,
                  maxLength: 50,
                  prefixIcon: Icon(Icons.auto_awesome_rounded,
                      color: AppColors.primary),
                  onChanged: notifier.updateTitle,
                ),
                SizedBox(height: AppSpacing.xl),
                _buildDiscoveryCard(state, notifier),
                SizedBox(height: AppSpacing.xl),
                _buildPowerUpCard(state, notifier),
                SizedBox(height: AppSpacing.xl),
                _buildCategoryDropdown(state, notifier),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutBack),

          SizedBox(height: AppSpacing.xxl),

          // Next Button
          AppButton(
            label: 'Enter Workshop',
            type: AppButtonType.premium,
            icon: Icon(Icons.chevron_right_rounded),
            onPressed: state.quiz.title.trim().isEmpty
                ? null
                : () => notifier.setStep(QuizEditorStep.workshop),
          ).animate().fadeIn(delay: 400.ms),

          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Define Your Creation', style: AppTypography.h2),
        SizedBox(height: AppSpacing.xs),
        Text(
          'Every epic quiz starts with a clear identity. Set the tone for your participants.',
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildDiscoveryCard(
      QuizEditorState state, QuizEditorNotifier notifier) {
    return AppCard(
      color: AppColors.background.withValues(alpha: 0.5),
      padding: EdgeInsets.all(AppSpacing.md),
      showBorder: true,
      borderColor: state.quiz.isPublic
          ? AppColors.primary.withValues(alpha: 0.3)
          : AppColors.border,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: (state.quiz.isPublic
                      ? AppColors.primary
                      : AppColors.textSecondary)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              state.quiz.isPublic
                  ? Icons.public_rounded
                  : Icons.public_off_rounded,
              color: state.quiz.isPublic
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discovery Mode',
                    style: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(
                  state.quiz.isPublic
                      ? 'Public: Anyone can play and find this quiz.'
                      : 'Private: Only visible to you.',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: state.quiz.isPublic,
            onChanged: notifier.toggleVisibility,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(
      QuizEditorState state, QuizEditorNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CATEGORY',
            style:
                AppTypography.label.copyWith(color: AppColors.textSecondary)),
        SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: state.quiz.category,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.category_rounded, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
          ),
          dropdownColor: AppColors.surface,
          items:
              ['Tech', 'Science', 'History', 'Geography', 'Movies', 'General']
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v, style: AppTypography.bodyMedium),
                      ))
                  .toList(),
          onChanged: (v) => notifier.updateCategory(v!),
        ),
      ],
    );
  }

  Widget _buildPowerUpCard(QuizEditorState state, QuizEditorNotifier notifier) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.md),
      showBorder: true,
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.secondary),
              SizedBox(width: AppSpacing.sm),
              Text('Power-Up Mode',
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: state.quiz.powerUpMode,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
            ),
            dropdownColor: AppColors.surface,
            items: [
              DropdownMenuItem(
                value: 'disabled',
                child: Text('⛔ Disabled (Pure Skill)',
                    style: AppTypography.bodyMedium),
              ),
              DropdownMenuItem(
                value: 'balanced',
                child: Text('⚖️ Balanced (Standard)',
                    style: AppTypography.bodyMedium),
              ),
              DropdownMenuItem(
                value: 'chaos',
                child: Text('🔥 Chaos (Party Mode)',
                    style: AppTypography.bodyMedium),
              ),
            ],
            onChanged: (v) => notifier.setPowerUpMode(v!),
          ),
        ],
      ),
    );
  }
}
