import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_features/quiz_features.dart';

class AIGenesisModal extends ConsumerStatefulWidget {
  const AIGenesisModal({super.key});

  @override
  ConsumerState<AIGenesisModal> createState() => _AIGenesisModalState();
}

class __Status {
  static const String idle = 'idle';
  static const String thinking = 'thinking';
  static const String materializing = 'materializing';
  static const String complete = 'complete';
}

class _AIGenesisModalState extends ConsumerState<AIGenesisModal> {
  final _topicController = TextEditingController();
  int _questionCount = 10;
  String _difficulty = 'medium';
  String _status = __Status.idle;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _onGenerate() async {
    if (_topicController.text.trim().isEmpty) return;

    setState(() => _status = __Status.thinking);

    try {
      final request = AIGenerationRequest(
        content: _topicController.text.trim(),
        source: AISourceType.topic,
        questionCount: _questionCount,
        difficulty: _difficulty,
      );

      // Simulation of "Thinking" phase for better UX feel
      await Future.delayed(800.ms);
      if (mounted) setState(() => _status = __Status.materializing);

      final questions = await ref.read(aiGenerationProvider(request).future);

      if (mounted) {
        setState(() => _status = __Status.complete);
        await Future.delayed(600.ms); // Victory lap animation
        if (mounted) Navigator.of(context).pop(questions);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = __Status.idle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Genesis failed: $e',
                style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl,
          AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        gradient: AppColors.midnightGradient,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: AnimatedSwitcher(
        duration: 500.ms,
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInCirc,
        child: _status == __Status.idle
            ? _buildIdleState()
            : _buildProcessingState(),
      ),
    );
  }

  Widget _buildIdleState() {
    return Column(
      key: const ValueKey('idle'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHandle(),
        const SizedBox(height: AppSpacing.md),
        _buildHeader(),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: 'What should we learn?',
          hintText: 'e.g., Cyberpunk Aesthetics or Solar System',
          controller: _topicController,
          prefixIcon:
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
                child: _buildSelector('DIFFICULTY', ['easy', 'medium', 'hard'],
                    _difficulty, (v) => setState(() => _difficulty = v!))),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: _buildSelector(
                    'QUESTIONS',
                    [5, 10, 15, 20],
                    _questionCount,
                    (v) => setState(() => _questionCount = v!))),
          ],
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: 'START GENESIS',
          type: AppButtonType.premium,
          icon: const Icon(Icons.bolt_rounded),
          onPressed: _onGenerate,
        )
            .animate()
            .fadeIn(delay: 600.ms)
            .scale(curve: Curves.elasticOut, duration: 800.ms),
      ],
    );
  }

  Widget _buildProcessingState() {
    final isComplete = _status == __Status.complete;

    return Column(
      key: const ValueKey('processing'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.5, 1.5),
                      duration: 2.seconds,
                      curve: Curves.easeInOut)
                  .fadeOut(),

              // Core icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isComplete
                      ? AppColors.difficultyEasy
                      : AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isComplete ? AppColors.success : AppColors.primary)
                              .withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                    isComplete
                        ? Icons.check_circle_rounded
                        : Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 48),
              )
                  .animate(onPlay: (c) => isComplete ? null : c.repeat())
                  .shimmer(duration: 2.seconds)
                  .rotate(duration: 10.seconds),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          isComplete ? 'GENESIS COMPLETE' : _status.toUpperCase(),
          style: AppTypography.h2.copyWith(
              letterSpacing: 2,
              color: isComplete ? AppColors.success : AppColors.textPrimary),
        ).animate().fadeIn().scale(),
        const SizedBox(height: AppSpacing.md),
        Text(
          isComplete
              ? 'Your masterpiece is ready.'
              : 'Analyzing patterns and weaving questions...',
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Genesis', style: AppTypography.h3),
            Text('The future of quiz creation.',
                style: AppTypography.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildSelector<T>(
      String label, List<T> items, T current, Function(T?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<T>(
          initialValue: current,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border)),
          ),
          dropdownColor: AppColors.surface,
          items: items
              .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(v.toString().toUpperCase(),
                      style: AppTypography.bodySmall)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
