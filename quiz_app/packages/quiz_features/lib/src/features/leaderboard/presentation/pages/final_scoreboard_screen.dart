import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../../features/quiz/presentation/providers/quiz_provider.dart';
import '../../../../features/challenge/presentation/providers/challenge_provider.dart';
import '../../../../features/leaderboard/presentation/providers/leaderboard_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:quiz_features/quiz_features.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class FinalScoreboardScreen extends ConsumerStatefulWidget {
  final List<dynamic> players;
  final Map<String, dynamic> teams;
  final bool isTeamMode;
  final String quizId;
  final String sessionId;
  final bool isHost;

  const FinalScoreboardScreen({
    super.key,
    required this.players,
    required this.teams,
    required this.isTeamMode,
    required this.quizId,
    required this.sessionId,
    this.isHost = false,
  });

  @override
  ConsumerState<FinalScoreboardScreen> createState() =>
      _FinalScoreboardScreenState();
}

class _FinalScoreboardScreenState extends ConsumerState<FinalScoreboardScreen> {
  String? _myUserId;

  bool _isLoading = true;
  String? _publicQuizTitle;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
    _initializeScreen();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  int _calculateTeamScore(List<dynamic> teamPlayerIds) {
    if (teamPlayerIds.isEmpty) return 0;
    // Sum scores of all players in the team
    int total = 0;
    for (var playerId in teamPlayerIds) {
      final player = widget.players.firstWhere(
        (p) => p['id'] == playerId,
        orElse: () => null,
      );
      if (player != null) {
        total += (player['score'] as num).toInt();
      }
    }
    return total;
  }

  void _showRatingDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Rating',
      pageBuilder: (context, anim1, anim2) {
        double currentRating = 3;
        return Center(
          child: AppCard(
            margin: const EdgeInsets.all(AppSpacing.xl),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Rate this Quiz', style: AppTypography.h2),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Enjoyed "${_publicQuizTitle ?? 'this quiz'}"? Let the creator know!',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                RatingBar.builder(
                  initialRating: currentRating,
                  minRating: 1,
                  itemSize: 40,
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: AppColors.accent),
                  onRatingUpdate: (rating) => currentRating = rating,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Maybe Later',
                        type: AppButtonType.ghost,
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: 'Submit',
                        onPressed: () async {
                          context.pop();
                          await _submitRating(currentRating);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _initializeScreen() async {
    await _determineMyDetails();
    await _checkIfQuizIsPublic();
    if (mounted) {
      setState(() => _isLoading = false);

      final isMultiplayer = widget.players.length > 1 ||
          (widget.players.isNotEmpty &&
              widget.players[0]['id'] != 'local_player');

      if (_publicQuizTitle != null && _myUserId != null && isMultiplayer) {
        if (widget.isTeamMode) {
          unawaited(_submitTeamScoresToLeaderboard());
        } else {
          unawaited(_submitIndividualScoreToLeaderboard());
        }
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _confettiController.play();
            _showRatingDialog();
          }
        });
      }
    }
  }

  Future<void> _determineMyDetails() async {
    final user = ref.read(authStateProvider).value;
    if (user == null || !mounted) return;

    setState(() {
      _myUserId = user.id;
      _myUserId = user.id;
    });

    try {
      final meAsPlayer = widget.players.firstWhere(
        (p) => p['isRegistered'] == true && p['userId'] == user.id,
        orElse: () => {},
      );

      if (meAsPlayer.isNotEmpty) {
        for (var entry in widget.teams.entries) {
          if ((entry.value as List).contains(meAsPlayer['id'])) {
            break;
          }
        }
      }
    } catch (e) {
      AppLogger.e('Error determining details: $e', category: LogCategory.ui);
    }
  }

  Future<void> _submitIndividualScoreToLeaderboard() async {
    final me = widget.players.firstWhere(
      (p) => p['userId'] == _myUserId,
      orElse: () => null,
    );
    if (me != null) {
      await ref.read(leaderboardRepositoryProvider).submitScore(
            quizId: widget.quizId,
            score: me['score'],
          );
    }
  }

  Future<void> _submitTeamScoresToLeaderboard() async {
    // Only host submits team scores usually, or each member submits for their team
    final me = widget.players.firstWhere(
      (p) => p['userId'] == _myUserId,
      orElse: () => null,
    );
    if (me != null) {
      String? myTeamName;
      for (var entry in widget.teams.entries) {
        if ((entry.value as List).contains(me['id'])) {
          myTeamName = entry.key;
          break;
        }
      }
      if (myTeamName != null) {
        await ref.read(leaderboardRepositoryProvider).submitScore(
              quizId: widget.quizId,
              score: me['score'],
              teamName: myTeamName,
            );
      }
    }
  }

  Future<void> _submitRating(double rating) async {
    final result =
        await ref.read(quizRepositoryProvider).rateQuiz(widget.quizId, rating);
    result.fold(
      (failure) => AppLogger.e('Error rating quiz: ${failure.message}', category: LogCategory.ui),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks for your feedback!'))),
    );
  }

  void _showIndividualChallengeDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Challenge',
      pageBuilder: (context, anim1, anim2) {
        return ChallengeDialog(
          onChallenge: (username) => _sendIndividualChallenge(username),
        );
      },
    );
  }

  Future<void> _sendIndividualChallenge(String username) async {
    final me = widget.players.firstWhere(
      (p) => p['userId'] == _myUserId,
      orElse: () => null,
    );
    if (me == null) return;

    final result = await ref.read(challengeRepositoryProvider).sendChallenge(
          quizId: widget.quizId,
          opponentUsername: username,
          challengerScore: me['score'],
        );
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to send challenge: ${failure.message}'))),
      (_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Challenge sent!')));
        context.goNamed('dashboard', extra: {'initialIndex': 2});
      },
    );
  }

  Future<void> _checkIfQuizIsPublic() async {
    final result = await ref.read(quizRepositoryProvider).getPublicQuizzes();
    result.fold(
      (failure) =>
          AppLogger.e("Could not check if quiz is public: ${failure.message}", category: LogCategory.ui),
      (quizzes) {
        if (mounted) {
          final isPublic = quizzes.any((q) => q.id == widget.quizId);
          if (isPublic) {
            setState(() {
              _publicQuizTitle =
                  quizzes.firstWhere((q) => q.id == widget.quizId).title;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMultiplayerGame = widget.players.length > 1;

    // Map winners for podium
    final List<PodiumPlace> podiumWinners = [];
    if (widget.isTeamMode) {
      final sortedTeams = widget.teams.keys.toList()
        ..sort((a, b) => _calculateTeamScore(widget.teams[b] as List)
            .compareTo(_calculateTeamScore(widget.teams[a] as List)));
      for (var teamName in sortedTeams.take(3)) {
        podiumWinners.add(PodiumPlace(
            name: teamName,
            score: _calculateTeamScore(widget.teams[teamName] as List)));
      }
    } else {
      final sortedPlayers = List.from(widget.players)
        ..sort((a, b) => (b['score'] as num).compareTo(a['score'] as num));
      for (var player in sortedPlayers.take(3)) {
        podiumWinners
            .add(PodiumPlace(name: player['nickname'], score: player['score']));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StarryBackground(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const GlassHeader(title: Text('FINAL SCOREBOARD')),
                  const SizedBox(height: AppSpacing.xl),
                  AppPodium(
                    winners: podiumWinners,
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: AppSpacing.xxl),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.isTeamMode
                          ? widget.teams.length
                          : widget.players.length,
                      itemBuilder: (context, index) {
                        if (widget.isTeamMode) {
                          final sortedTeams = widget.teams.keys.toList()
                            ..sort((a, b) =>
                                _calculateTeamScore(widget.teams[b] as List)
                                    .compareTo(_calculateTeamScore(
                                        widget.teams[a] as List)));
                          final teamName = sortedTeams[index];
                          final score = _calculateTeamScore(
                              widget.teams[teamName] as List);
                          return _buildStandingsCard(
                              teamName, score, index, widget.teams.length);
                        } else {
                          final sortedPlayers = List.from(widget.players)
                            ..sort((a, b) => (b['score'] as num)
                                .compareTo(a['score'] as num));
                          final player = sortedPlayers[index];
                          return _buildStandingsCard(player['nickname'],
                              player['score'], index, widget.players.length);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  if (widget.isHost)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: AppButton(
                        label: 'VIEW INSIGHTS',
                        type: AppButtonType.secondary,
                        icon: const Icon(Icons.analytics_rounded, size: 20),
                        onPressed: () => context.pushNamed(
                          'game_report',
                          pathParameters: {'sessionId': widget.sessionId},
                          extra: {
                            'players': widget.players,
                            'teams': widget.teams,
                            'isTeamMode': widget.isTeamMode,
                            'quizId': widget.quizId,
                          },
                        ),
                      ),
                    ).animate().fadeIn(delay: 1.6.seconds).slideY(begin: 0.5),
                  const SizedBox(height: AppSpacing.md),
                  if (!_isLoading &&
                      _myUserId != null &&
                      isMultiplayerGame &&
                      !widget.isTeamMode)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: AppButton(
                        label: 'CHALLENGE AGAIN',
                        type: AppButtonType.ghost,
                        icon: const Icon(Icons.people_alt_rounded, size: 20),
                        onPressed: () =>
                            _showIndividualChallengeDialog(context),
                      ),
                    ).animate().fadeIn(delay: 1.5.seconds).slideY(begin: 0.5),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AppButton(
                      label: 'BACK TO DASHBOARD',
                      type: AppButtonType.premium,
                      onPressed: () => context.goNamed('dashboard'),
                    ),
                  ).animate().fadeIn(delay: 1.8.seconds).scale(
                      begin: const Offset(0.9, 0.9), curve: Curves.elasticOut),
                ],
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
                  AppColors.secondary,
                  AppColors.accent,
                  Colors.pink,
                  Colors.orange,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandingsCard(
      String name, int score, int index, int totalItems) {
    final isTop3 = index < 3;
    final isFirst = index == 0;
    // Sequential reveal delay: staggered based on index, but starting after podium (800ms)
    final delay = (1200 + index * 150).ms;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: RepaintBoundary(
            child: AppCard(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          color: isTop3
              ? (isFirst
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1))
              : AppColors.surface.withValues(alpha: 0.7),
          borderColor: isTop3 ? AppColors.primary.withValues(alpha: 0.3) : null,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: isTop3 ? AppColors.primaryGradient : null,
                  color: isTop3 ? null : AppColors.background,
                  shape: BoxShape.circle,
                  boxShadow: isTop3 ? AppColors.primaryGlow : null,
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
                        name,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight:
                              isTop3 ? FontWeight.w800 : FontWeight.w600,
                          letterSpacing: isTop3 ? 0.5 : 0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isFirst) ...[
                      const SizedBox(width: 8),
                      const AppBadge(
                        iconEmoji: '👑',
                        title: 'MVP',
                        description:
                            'The overall champion of this session! All hail the Quiz King/Queen.',
                        isLarge: false,
                      ).animate().scale(
                          delay: delay + 400.ms, curve: Curves.elasticOut),
                    ],
                    if (isTop3 && !isFirst) ...[
                      const SizedBox(width: 4),
                      const AppBadge(
                        iconEmoji: '🏅',
                        title: 'TOP PERFORMER',
                        description:
                            'Made it to the podium! A stellar performance.',
                        isLarge: false,
                      ).animate().scale(
                          delay: delay + 400.ms, curve: Curves.elasticOut),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedCounter(
                    value: score,
                    style: AppTypography.h3.copyWith(
                      fontSize: 20,
                      color: isFirst ? AppColors.accent : AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                    suffix: ' pts',
                    duration: 1200.ms,
                  ),
                ],
              ),
            ],
          ),
        )),
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 600.ms)
        .slideX(begin: 0.2, curve: Curves.easeOutBack);
  }
}
