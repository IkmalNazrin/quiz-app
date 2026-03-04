import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import '../widgets/leaderboard_content.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  final String quizId;
  final String quizTitle;
  final bool initialIsTeam;

  const LeaderboardPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
    this.initialIsTeam = false,
  });

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  late bool _isTeam;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _isTeam = widget.initialIsTeam;
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.quizTitle,
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background,
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<bool>(
                        groupValue: _isTeam,
                        backgroundColor:
                            AppColors.surface.withValues(alpha: 0.5),
                        thumbColor: AppColors.primary,
                        children: {
                          false: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Players',
                              style: AppTypography.label.copyWith(
                                fontWeight: FontWeight.bold,
                                color: !_isTeam
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          true: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Teams',
                              style: AppTypography.label.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isTeam
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        },
                        onValueChanged: (value) {
                          if (value != null) {
                            setState(() => _isTeam = value);
                            if (_confettiController.state !=
                                ConfettiControllerState.playing) {
                              _confettiController.play();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0.2, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ));
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: LeaderboardContentView(
                        key: ValueKey(_isTeam),
                        quizId: widget.quizId,
                        isTeam: _isTeam,
                        quizTitle: widget.quizTitle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.accent,
                AppColors.secondary,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
