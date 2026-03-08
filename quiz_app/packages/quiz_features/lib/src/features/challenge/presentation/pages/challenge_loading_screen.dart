import '../../../../features/quiz/services/offline_game_engine.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/challenge/presentation/providers/challenge_provider.dart';
import '../../../../features/quiz/presentation/providers/quiz_provider.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core_features/providers/core_providers.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';

class ChallengeLoadingScreen extends ConsumerStatefulWidget {
  final String? challengeId;
  final String? quizId;
  final String? quizTitle;
  final LeaderboardEntry? opponentTeam;
  final bool isLeaderboardChallenge;

  const ChallengeLoadingScreen({
    super.key,
    this.challengeId,
    this.quizId,
    this.quizTitle,
    this.opponentTeam,
    this.isLeaderboardChallenge = false,
  });

  @override
  ConsumerState<ChallengeLoadingScreen> createState() =>
      _ChallengeLoadingScreenState();
}

class _ChallengeLoadingScreenState
    extends ConsumerState<ChallengeLoadingScreen> {
  Map<String, dynamic>? _challengeData;

  @override
  void initState() {
    super.initState();
    _loadAndStartChallenge();
  }

  Future<void> _loadAndStartChallenge() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      if (mounted) context.pop();
      return;
    }

    try {
      List<Map<String, dynamic>> questions = [];
      String quizIdForEngine = '';

      if (widget.isLeaderboardChallenge) {
        if (widget.quizId == null)
          throw Exception('Quiz ID required for leaderboard challenge');
        final quizEither = await ref.read(quizRepositoryProvider).getQuizDetails(widget.quizId!);
        final quiz = quizEither.fold((l) => throw Exception(l.message), (r) => r);
        questions = quiz.questions
            .map((q) => {
                  'question': q.question,
                  'options': q.options,
                  'correctAnswerIndex': q.correctAnswerIndex,
                  'difficulty': q.difficulty,
                  'timer': q.timer,
                  'correct_index': q.correctAnswerIndex,
                })
            .toList();
        quizIdForEngine = quiz.id;
      } else {
        final challengeEither = await ref.read(challengeRepositoryProvider).getChallengeById(widget.challengeId!);
        final challenge = challengeEither.fold((l) => throw Exception(l.message), (r) => r);
        _challengeData = {'id': challenge.id, 'quiz_id': challenge.quizTitle};
        final quizId = challenge.quizTitle; // Model sets quiz_id to quizTitle
        final quizEither = await ref.read(quizRepositoryProvider).getQuizDetails(quizId);
        final quiz = quizEither.fold((l) => throw Exception(l.message), (r) => r);

        questions = quiz.questions
            .map((q) => {
                  'question': q.question,
                  'options': q.options,
                  'correct_index': q.correctAnswerIndex,
                  'difficulty': q.difficulty,
                  'timer': q.timer,
                })
            .toList();

        quizIdForEngine = quiz.id;
      }

      if (!mounted) return;

      final engine = OfflineGameEngine(
        questions: questions,
        quizId: quizIdForEngine,
        username: user.name ?? 'User',
        offlineSyncRepository: ref.read(offlineSyncRepositoryProvider),
      );

      engine.eventStream.listen((event) {
        if (event['event'] == 'final-results' && mounted) {
          final eventData = event['data'];
          final List<dynamic> finalPlayers = eventData['players'] ?? [];

          int finalScore = 0;
          if (finalPlayers.isNotEmpty) {
            final playerData = finalPlayers[0];
            finalScore = (playerData['score'] as num?)?.toInt() ?? 0;
          }

          if (widget.isLeaderboardChallenge) {
            _sendLeaderboardChallenge(finalScore, user.id, user.name ?? 'User');
          } else {
            _completeNormalChallenge(finalScore);
          }
        }
      });

      engine.start();

      await context.pushNamed(
        'game',
        extra: {
          'engine': engine,
          'gamePin': 'OFFLINE',
          'initialQuestionData': {
            ...questions[0],
            'questionIndex': 1,
            'totalQuestions': questions.length
          },
          'isChallenge': true,
        },
      );
    } catch (e) {
      debugPrint('Error loading challenge: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        context.pop();
      }
    }
  }

  Future<void> _sendLeaderboardChallenge(
      int myScore, String userId, String username) async {
    try {
      final challenge = ChallengeEntity(
        id: '',
        quizTitle: widget.quizId!,
        status: 'pending',
        challengeType: '1v1',
        challengerId: userId,
        challengerUsername: username,
        challengerScore: myScore,
        opponentId: widget.opponentTeam?.userId,
        opponentUsername: widget.opponentTeam?.username ?? 'Opponent',
        opponentScore: 0,
        createdAt: DateTime.now(),
      );

      final result = await ref
          .read(challengeRepositoryProvider)
          .createChallenge(challenge);

      result.fold((failure) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed: ${failure.message}')));
      }, (_) {
        if (mounted) {
          _showSuccessDialog(
              'Challenge Sent!', 'Your score of $myScore has been sent.');
        }
      });
    } catch (e) {
      debugPrint('Error sending challenge: $e');
    }
  }

  Future<void> _completeNormalChallenge(int myScore) async {
    if (_challengeData == null) return;
    final challengeId = _challengeData!['id'];

    final result = await ref
        .read(challengeRepositoryProvider)
        .completeChallenge(challengeId, myScore);

    result.fold((failure) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${failure.message}')));
    }, (_) {
      final challengerScore =
          (_challengeData!['challenger_score'] as num?)?.toInt() ?? 0;
      final bool didIWin = myScore > challengerScore;

      if (mounted) {
        _showSuccessDialog(didIWin ? 'You Won!' : 'You Lost!',
            'Your Score: $myScore\nOpponent: $challengerScore');
      }
    });
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: AppCard(
            margin: const EdgeInsets.all(AppSpacing.xl),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.h2),
                const SizedBox(height: AppSpacing.md),
                Text(content,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.goNamed('dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    child: const Text('Back to Dashboard'),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn()
              .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .rotate(duration: 2.seconds),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Preparing Arena...',
                        style: AppTypography.h3
                            .copyWith(color: Colors.white, letterSpacing: 1),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text(
                        'Synchronizing challenge data',
                        style: AppTypography.bodySmall
                            .copyWith(color: Colors.white70),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
