import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_features/quiz_features.dart';

class QuizEditorPage extends ConsumerStatefulWidget {
  final String? quizId;
  const QuizEditorPage({super.key, this.quizId});

  @override
  ConsumerState<QuizEditorPage> createState() => _QuizEditorPageState();
}

class _QuizEditorPageState extends ConsumerState<QuizEditorPage> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizEditorProvider(widget.quizId));
    final notifier = ref.read(quizEditorProvider(widget.quizId).notifier);

    return PopScope(
      canPop: !state.isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Background Elements (e.g. Gradients)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.05),
                      AppColors.background,
                      AppColors.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Column(
              children: [
                const SizedBox(height: 120), // Header space
                _buildStepper(state.step),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: 400.ms,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildStepContent(state.step, widget.quizId),
                  ),
                ),
              ],
            ),

            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GlassHeader(
                height: 120,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () async {
                    if (!state.isDirty ||
                        await _showExitConfirmation(context)) {
                      if (context.mounted) context.pop();
                    }
                  },
                ),
                title: Text(
                  widget.quizId != null ? 'Pulse Workshop' : 'New Creation',
                  style: AppTypography.h3,
                ),
                actions: [
                  if (state.step == QuizEditorStep.review)
                    Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: AppButton(
                        label: 'Publish',
                        width: 100,
                        height: 40,
                        type: AppButtonType.premium,
                        isLoading: state.isLoading,
                        onPressed: () async {
                          final success = await notifier.publish();
                          if (success && context.mounted) {
                            _confettiController.play();
                            await Future.delayed(2.seconds);
                            if (context.mounted) {
                              context.pop(true);
                            }
                          }
                        },
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Confetti Overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.success,
                  AppColors.warning
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(QuizEditorStep step, String? quizId) {
    switch (step) {
      case QuizEditorStep.identity:
        return IdentityStep(quizId: quizId, key: const ValueKey('identity'));
      case QuizEditorStep.workshop:
        return WorkshopStep(quizId: quizId, key: const ValueKey('workshop'));
      case QuizEditorStep.review:
        return ReviewStep(quizId: quizId, key: const ValueKey('review'));
    }
  }

  Widget _buildStepper(QuizEditorStep currentStep) {
    final progress = (currentStep.index + 1) / QuizEditorStep.values.length;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      child: Column(
        children: [
          ProgressBar(value: progress, height: 6),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepIndicator(
                  label: 'Identity', isActive: currentStep.index >= 0),
              _StepIndicator(
                  label: 'Workshop', isActive: currentStep.index >= 1),
              _StepIndicator(label: 'Launch', isActive: currentStep.index >= 2),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
            title: Text('Discard Changes?', style: AppTypography.h3),
            content: Text(
              'Your progress on this creation will be lost. Return to the pulse?',
              style: AppTypography.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: Text('Stay',
                    style: AppTypography.label
                        .copyWith(color: AppColors.textSecondary)),
              ),
              AppButton(
                label: 'Discard',
                width: 100,
                height: 40,
                type: AppButtonType.ghost,
                onPressed: () => context.pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _StepIndicator extends StatelessWidget {
  final String label;
  final bool isActive;
  const _StepIndicator({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: 300.ms,
      style: AppTypography.label.copyWith(
        color: isActive ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
      child: Text(label),
    );
  }
}
