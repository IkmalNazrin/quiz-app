import '../../../../features/quiz/services/offline_game_engine.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../features/game/presentation/providers/game_session_provider.dart';
import 'package:go_router/go_router.dart';

import '../widgets/power_up_dock.dart';
import '../../../../features/game/presentation/widgets/host_controls_overlay.dart';

import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  final OfflineGameEngine? engine;
  final String? gamePin;
  final Map<String, dynamic>? initialQuestionData;
  final bool isChallenge;

  const QuestionScreen({
    super.key,
    this.engine,
    this.gamePin,
    this.initialQuestionData,
    this.isChallenge = false,
  });

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen>
    with TickerProviderStateMixin {
  int? _selectedAnswerIndex;
  bool _answerSubmitted = false;
  Map<String, dynamic> _currentQuestion = {};

  // Power-Up State
  bool _isDoubleDownActive = false;
  List<int> _hiddenOptions = [];

  late final AnimationController _timerController;
  double _smoothTimeLeft = 15.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestionData != null) {
      _currentQuestion = widget.initialQuestionData!;
    }

    // Ticker for 60fps smooth UI updates
    // Use AnimationController to drive smooth UI updates
    _timerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _timerController.addListener(() {
      if (mounted) {
        setState(() {
          final gameState = ref.read(gameSessionProvider);
          final roundEndsAt = gameState.roundEndsAt;
          final totalTime =
              (gameState.currentQuestion?['timer'] as num? ?? 15.0).toDouble();

          if (roundEndsAt != null) {
            final remaining =
                roundEndsAt.difference(DateTime.now()).inMilliseconds / 1000.0;
            _smoothTimeLeft = remaining.clamp(0.0, totalTime);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _submitAnswer(int index) {
    if (_answerSubmitted) return;
    HapticService.light();
    setState(() {
      _selectedAnswerIndex = index;
      _answerSubmitted = true;
    });
    ref
        .read(gameSessionProvider.notifier)
        .submitAnswer(index, isDoubleDown: _isDoubleDownActive);
  }

  void _activate5050() {
    if (_hiddenOptions.isNotEmpty) return;

    final currentQuestion =
        ref.read(gameSessionProvider).currentQuestion ?? _currentQuestion;
    final correctIndex = currentQuestion['correctAnswerIndex'] as int?;

    if (correctIndex != null) {
      final totalOptions = (currentQuestion['options'] as List).length;
      final wrongIndices = List.generate(totalOptions, (i) => i)
          .where((i) => i != correctIndex)
          .toList();
      wrongIndices.shuffle();
      setState(() {
        _hiddenOptions = wrongIndices.take(2).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('50/50 not available in Live Mode yet')));
    }
  }

  void _activateRetry() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Second Chance Active: Next wrong answer will be saved!')));
  }

  Color _getOptionColor(int index) {
    if (!_answerSubmitted) return AppColors.surface;
    if (_selectedAnswerIndex == index)
      return AppColors.primary.withValues(alpha: 0.1);
    return AppColors.surface.withValues(alpha: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameSessionProvider);
    final currentQuestion = gameState.currentQuestion ?? _currentQuestion;
    final questionText = currentQuestion['question'] ?? 'Loading...';
    final options = List<String>.from(currentQuestion['options'] ?? []);

    // Smooth time is updated by Ticker
    final totalTime = (currentQuestion['timer'] as num? ?? 15.0).toDouble();

    // Urgency Logic
    final bool isUrgent = _smoothTimeLeft <= 5.0 && _smoothTimeLeft > 0;

    ref.listen(gameSessionProvider, (previous, next) {
      if (next.status == 'round_over' && previous?.status != 'round_over') {
        context.pushNamed(
          'results',
          extra: {
            'players': List<dynamic>.from(next.finalResults['players']),
            'teams': Map<String, dynamic>.from(next.finalResults['teams']),
            'isTeamMode': next.finalResults['isTeamMode'] ?? false,
            'correctAnswerIndex': next.finalResults['correctAnswerIndex'],
            'questionData': currentQuestion,
          },
        );
      } else if (next.status == 'finished') {
        if (widget.isChallenge) {
          context.pop();
        } else {
          context.goNamed(
            'scoreboard',
            extra: {
              'players': List<dynamic>.from(next.finalResults['players'] ?? []),
              'teams':
                  Map<String, dynamic>.from(next.finalResults['teams'] ?? {}),
              'isTeamMode': next.finalResults['isTeamMode'] ?? false,
              'quizId': next.finalResults['quizId'],
              'sessionId': next.id, // Ensure engine provides session UUID
              'isHost': next.hostId ==
                  ref.read(authStateProvider).value?.id,
            },
          );
        }
      } else if (next.status == 'playing' && previous?.status != 'playing') {
        context.pop();
      }
    });

    ref.listen(gameSessionProvider, (prev, next) {
      if (next.currentQuestion != prev?.currentQuestion) {
        setState(() {
          _selectedAnswerIndex = null;
          _answerSubmitted = false;
          _isDoubleDownActive = false;
          _hiddenOptions = [];

          // Re-evaluate retry availability based on inventory?
          // Actually inventory persists, but we might want to reset local flags.
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Urgency Background Pulse
          if (isUrgent && !gameState.isTimerAccelerated)
            Positioned.fill(
              child: Container(color: AppColors.error.withValues(alpha: 0.05))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 500.ms),
            ),

          // Main Content Area (Unpositioned to ensure proper constraints)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.getHeaderHeight(context) + AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _buildTimerHeader(_smoothTimeLeft, totalTime,
                      gameState.streak, gameState.isTimerAccelerated, isUrgent),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      questionText,
                      style: AppTypography.h2.copyWith(height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      curve: Curves.elasticOut,
                      duration: 800.ms),
                  const Spacer(),
                  ...List.generate(options.length, (index) {
                    final isSelected = _selectedAnswerIndex == index;
                    final isHidden = _hiddenOptions.contains(index);

                    if (isHidden) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: AppCard(
                        onTap: _answerSubmitted
                            ? null
                            : () => _submitAnswer(index),
                        color: _getOptionColor(index),
                        showBorder: true,
                        borderColor: isSelected
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: AppRadius.lg,
                        child: AnimatedContainer(
                          duration: 250.ms,
                          curve: Curves.easeOutBack, // Bouncy selection
                          transform: isSelected
                              ? Matrix4.diagonal3Values(1.02, 1.02, 1.0)
                              : Matrix4.identity(),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      spreadRadius: -2,
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.background
                                          .withValues(alpha: 0.5),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 10)
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: AppTypography.h3.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary
                                              .withValues(alpha: 0.7),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate(
                          target: isHidden ? 0 : 1,
                        )
                        .fadeIn(delay: (400 + index * 100).ms, duration: 500.ms)
                        .slideY(
                            begin: 0.5,
                            curve: Curves.elasticOut,
                            duration: 800.ms)
                        .scale(begin: const Offset(0.9, 0.9));
                  }),
                  const Spacer(),
                  if (_answerSubmitted)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_rounded,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Answer Locked',
                              style: AppTypography.label.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().shake(),
                    ),
                  if (gameState.isSyncing)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Syncing answer...',
                              style: AppTypography.label.copyWith(
                                color: AppColors.primary.withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(duration: 2.seconds),
                    ),
                ],
              ),
            ),
          ),

          // Glass Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassHeader(
              title: Text(
                'Question ${currentQuestion['questionIndex'] ?? 0}/${currentQuestion['totalQuestions'] ?? 0}',
                style: AppTypography.h3,
              ),
            ),
          ),

          // Epic Social Pressure Pulse Overlay
          if (gameState.isTimerAccelerated)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 1.seconds,
                      curve: Curves.easeInOut)
                  .fadeOut(duration: 1.seconds, curve: Curves.easeInOut),
            ),

          if (gameState.hostId ==
              ref.read(authStateProvider).value?.id)
            const HostControlsOverlay(),

          if (gameState.status == 'round_over')
            Positioned.fill(
              child: FeedbackOverlay(
                isCorrect: gameState.currentPointsGained > 0,
                points: gameState.currentPointsGained,
                streak: gameState.streak,
              ),
            ),

          // Dock
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: PowerUpDock(
              isAnswerSubmitted: _answerSubmitted,
              onUseDoubleDown: () => setState(() => _isDoubleDownActive = true),
              onUse5050: _activate5050,
              onUseRetry: _activateRetry,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerHeader(double timeLeft, double totalTime, int streak,
      bool isAccelerated, bool isUrgent) {
    final progress = timeLeft / totalTime;
    final color = isAccelerated ? AppColors.accent : _getTimerColor(progress);

    return Column(
      children: [
        ProgressBar(
          value: progress,
          color: color,
        )
            .animate(target: isUrgent ? 1 : 0)
            .shake(
                hz: 8,
                curve: Curves.easeInOut) // Shake bar slightly when urgent
            .tint(color: AppColors.error, duration: 500.ms), // Tint redder
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_rounded, size: 16, color: color)
                          .animate(target: isUrgent ? 1 : 0)
                          .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.3, 1.3),
                              duration: 400.ms,
                              curve: Curves.easeInOut)
                          .then(delay: 400.ms)
                          .scale(
                              begin: const Offset(1.3, 1.3),
                              end: const Offset(1, 1)),
                      const SizedBox(width: 6),
                      Text(
                        '${timeLeft.toStringAsFixed(1)}s',
                        style: AppTypography.label.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      )
                          .animate(target: isUrgent ? 1 : 0)
                          .shake(hz: 5, duration: 500.ms)
                          .tint(color: AppColors.error),
                    ],
                  ),
                )
                    .animate(
                      target: progress < 0.2 || isAccelerated ? 1 : 0,
                      onPlay: (c) => c.repeat(),
                    )
                    .shake(duration: 400.ms, hz: 6)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      curve: Curves.elasticOut,
                      duration: 300.ms,
                    ),
                if (_isDoubleDownActive)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: AppColors.accentGlow,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('2x POINTS',
                              style: AppTypography.label
                                  .copyWith(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                        begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
                  ).animate().fadeIn().scale(),
              ],
            ),
            if (streak >= 2)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.streakGradient,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.streakFire.withValues(alpha: 0.3),
                        blurRadius: 8),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fireplace_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$streak STREAK',
                      style: AppTypography.label.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(duration: 500.ms),
            if (isAccelerated)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppColors.accentGlow,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 16)
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1.seconds),
                    const SizedBox(width: 6),
                    Text(
                      'SOCIAL PRESSURE!',
                      style: AppTypography.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                      duration: 300.ms,
                      begin: const Offset(1, 1),
                      end: const Offset(1.25, 1.25),
                      curve: Curves.elasticOut)
                  .shimmer(
                      duration: 600.ms,
                      color: Colors.white.withValues(alpha: 0.8))
                  .blur(
                      begin: const Offset(0, 0),
                      end: const Offset(2, 0),
                      duration: 300.ms),
          ],
        ),
      ],
    );
  }

  Color _getTimerColor(double percentage) {
    if (percentage > 0.6) return AppColors.success;
    if (percentage > 0.3) return AppColors.warning;
    return AppColors.error;
  }
}
