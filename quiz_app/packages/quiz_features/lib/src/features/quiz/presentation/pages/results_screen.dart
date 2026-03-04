import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../features/game/presentation/providers/game_session_provider.dart';
import '../../../../features/game/presentation/widgets/host_controls_overlay.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';

class ResultsScreen extends ConsumerWidget {
  final List<dynamic> players;
  final int correctAnswerIndex;
  final Map<String, dynamic> questionData;
  final Map<String, dynamic> teams;
  final bool isTeamMode;

  const ResultsScreen({
    super.key,
    required this.players,
    required this.correctAnswerIndex,
    required this.questionData,
    required this.teams,
    required this.isTeamMode,
  });

  int _calculateTeamScore(List<dynamic> teamPlayerIds) {
    if (teamPlayerIds.isEmpty) return 0;
    final representativePlayer = players.firstWhere(
      (p) => teamPlayerIds.contains(p['id']),
      orElse: () => {'score': 0},
    );
    return representativePlayer['score'];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameSessionProvider);
    final myUserId = ref.read(authStateProvider).value?.id;
    final isHost = myUserId == gameState.hostId;

    final String correctAnswerText =
        questionData['options'][correctAnswerIndex];

    // Performance Metrics Calculation
    final int streak = gameState.streak;
    final int totalTime = int.tryParse(questionData['timer'].toString()) ?? 20;
    final int timeLeft = gameState.timeLeft;
    final double speedFactor = (timeLeft / totalTime).clamp(0.0, 1.0);

    String speedLabel = 'GOOD EFFORT';
    if (speedFactor > 0.8) {
      speedLabel = 'LIGHTNING FAST';
    } else if (speedFactor > 0.6) {
      speedLabel = 'QUICK THINKING';
    } else if (speedFactor > 0.4) {
      speedLabel = 'CRUISING';
    }

    List<MapEntry<String, dynamic>> sortedTeams = [];
    if (isTeamMode) {
      sortedTeams = teams.entries.toList()
        ..sort((a, b) => _calculateTeamScore(b.value)
            .compareTo(_calculateTeamScore(a.value)));
    } else {
      players.sort((a, b) => b['score'].compareTo(a['score']));
    }

    final podiumWinners = isTeamMode
        ? sortedTeams
            .take(3)
            .map((e) =>
                PodiumPlace(name: e.key, score: _calculateTeamScore(e.value)))
            .toList()
        : players
            .take(3)
            .map((e) => PodiumPlace(name: e['nickname'], score: e['score']))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Content Area (Unpositioned to ensure proper constraints)
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                    height: AppSpacing.getHeaderHeight(
                        context)), // GlassHeader displacement
                const SizedBox(height: AppSpacing.md),

                AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  color: AppColors.success.withValues(alpha: 0.1),
                  showBorder: true,
                  borderColor: AppColors.success.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.success.withValues(alpha: 0.5),
                                blurRadius: 10)
                          ],
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CORRECT ANSWER',
                                style: AppTypography.label.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                    fontSize: 10)),
                            Text(
                              correctAnswerText,
                              style: AppTypography.h3.copyWith(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.5, curve: Curves.easeOutBack)
                    .scale(begin: const Offset(0.9, 0.9)),

                const SizedBox(height: AppSpacing.md),

                // Gamification Section (Streak & Speed) for Non-Host
                if (!isHost)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppStreakBar(streak: streak),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: AppPerformanceIndicator(
                              speedFactor: speedFactor,
                              label: speedLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

                const SizedBox(height: AppSpacing.md),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: AppPodium(winners: podiumWinners),
                )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.lg),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white10)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: Text('ROUND STANDINGS',
                            style: AppTypography.label.copyWith(
                              letterSpacing: 3,
                              fontWeight: FontWeight.w900,
                              color:
                                  AppColors.textPrimary.withValues(alpha: 0.4),
                            )),
                      ),
                      const Expanded(child: Divider(color: Colors.white10)),
                    ],
                  ),
                ).animate().fadeIn(delay: 1.seconds),

                Expanded(
                  child: isTeamMode
                      ? _buildTeamLeaderboard(sortedTeams)
                      : _buildIndividualLeaderboard(),
                ),

                // Transition Indicator
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 40),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.surface.withValues(alpha: 0.4),
                            AppColors.surface.withValues(alpha: 0.9),
                          ],
                        ),
                        border: Border(
                            top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text('GET READY FOR NEXT ROUND...',
                              style: AppTypography.label.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                color: AppColors.textPrimary,
                              )),
                        ],
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(duration: 2.seconds, color: Colors.white30),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Glass Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassHeader(
              title: Text('Round Results', style: AppTypography.h3),
            ),
          ),

          if (isHost) const HostControlsOverlay(),

          // Impact Overlay (Victory/Defeat)
          if (!isHost)
            _buildImpactOverlay(context, gameState.currentPointsGained > 0,
                gameState.currentPointsGained),
        ],
      ),
    );
  }

  Widget _buildImpactOverlay(
      BuildContext context, bool isCorrect, int pointsGained) {
    // Only show if we actually played (points > 0 or we answered).
    // For now, we assume if we are on this screen, we want feedback.
    // We use a TweenAnimationBuilder to fade it out after a few seconds so the user can see the leaderboard.

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: const Duration(seconds: 3),
      curve: const Interval(0.7, 1.0,
          curve: Curves.easeOut), // Fade out in last 30%
      builder: (context, opacity, child) {
        if (opacity == 0) return const SizedBox.shrink(); // Gone

        return Opacity(
          opacity: opacity,
          child: Container(
            color: Colors.black
                .withValues(alpha: 0.7 * opacity), // Dim background initially
            alignment: Alignment.center,
            child: Transform.scale(
              scale: isCorrect ? 1.0 : 1.0, // Base scale
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Icon(
                    isCorrect
                        ? Icons.check_circle_outline_rounded
                        : Icons.cancel_outlined,
                    color: isCorrect ? AppColors.success : AppColors.error,
                    size: 120,
                  )
                      .animate(target: isCorrect ? 1 : 0)
                      .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.2, 1.2),
                          duration: 600.ms,
                          curve: Curves.elasticOut) // Pop in
                      .then()
                      .scale(
                          begin: const Offset(1.2, 1.2),
                          end: const Offset(1.0, 1.0),
                          duration: 200.ms), // Settle

                  const SizedBox(height: AppSpacing.md),

                  // Text
                  Transform.rotate(
                    angle: isCorrect ? -0.1 : 0.1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCorrect ? AppColors.success : AppColors.error,
                        border: Border.all(color: Colors.white, width: 4),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                            color: (isCorrect
                                    ? AppColors.success
                                    : AppColors.error)
                                .withValues(alpha: 0.6),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Text(
                        isCorrect ? 'EPIC!' : 'MISSED',
                        style: AppTypography.h1.copyWith(
                          color: Colors.white,
                          fontSize: 48,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                          delay: 200.ms,
                          duration: 500.ms,
                          curve: Curves.elasticOut)
                      .shake(
                          delay: 200.ms,
                          hz: isCorrect ? 0 : 8), // Shake if wrong

                  const SizedBox(height: AppSpacing.lg),

                  if (isCorrect)
                    Text(
                      '+$pointsGained PTS',
                      style: AppTypography.h2.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          shadows: [
                            const Shadow(
                                blurRadius: 10, color: AppColors.success)
                          ]),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndividualLeaderboard() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isTop3 = index < 3;

        final isStreakInPlayer = (player['streak'] ?? 0) >= 3;

        // Mock Logic for Badges
        final bool showFireBadge =
            isStreakInPlayer || (index < 3 && player['score'] > 500);
        final bool showSpeedBadge = index == 0;

        return AppCard(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          color: isTop3
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface.withValues(alpha: 0.5),
          showBorder: true,
          borderColor: isTop3
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isTop3 ? AppColors.primary : AppColors.background,
                  shape: BoxShape.circle,
                  boxShadow: isTop3 ? AppColors.primaryGlow : [],
                ),
                child: Center(
                  child: Text('${index + 1}',
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isTop3 ? Colors.white : AppColors.textPrimary,
                      )),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        player['nickname'],
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight:
                              isTop3 ? FontWeight.w900 : FontWeight.w600,
                          color: isTop3 ? Colors.white : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showFireBadge) ...[
                      const SizedBox(width: 8),
                      const AppBadge(
                        iconEmoji: '🔥',
                        title: 'ON FIRE',
                        description:
                            'This player is on a hot streak! 3+ correct answers in a row.',
                        isLarge: false,
                      ),
                    ],
                    if (showSpeedBadge) ...[
                      const SizedBox(width: 4),
                      const AppBadge(
                        iconEmoji: '⚡',
                        title: 'SPEED DEMON',
                        description:
                            'Fastest finger in the room! Incredible reaction time.',
                        isLarge: false,
                      ),
                    ],
                  ],
                ),
              ),
              // Rolling Score Animation
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: player['score']),
                duration: Duration(
                    milliseconds: 1500 + (index * 200)), // Staggered slightly
                curve: Curves.easeOutExpo,
                builder: (context, value, child) {
                  return Text(
                    '$value',
                    style: AppTypography.h3.copyWith(
                      color: isTop3 ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  );
                },
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (1200 + index * 100).ms)
            .slideX(begin: 0.1, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildTeamLeaderboard(List<MapEntry<String, dynamic>> sortedTeams) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: sortedTeams.length,
      itemBuilder: (context, index) {
        final team = sortedTeams[index];
        final score = _calculateTeamScore(team.value);
        return AppCard(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Text('${index + 1}',
                  style: AppTypography.bodySmall
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: AppSpacing.md),
              Text(team.key, style: AppTypography.bodyLarge),
              const Spacer(),
              // Rolling Score Animation for Teams
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: score),
                duration: Duration(milliseconds: 1500 + (index * 200)),
                curve: Curves.easeOutExpo,
                builder: (context, value, child) {
                  return Text('$value',
                      style: AppTypography.h2
                          .copyWith(fontSize: 18, color: AppColors.primary));
                },
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
      },
    );
  }
}
