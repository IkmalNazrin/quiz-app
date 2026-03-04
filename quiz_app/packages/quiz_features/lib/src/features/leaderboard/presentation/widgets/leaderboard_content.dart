import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/leaderboard_provider.dart';
import 'package:quiz_features/quiz_features.dart';
import 'challenge_button.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class LeaderboardContentView extends ConsumerWidget {
  final String quizId;
  final bool isTeam;
  final String quizTitle;

  const LeaderboardContentView({
    super.key,
    required this.quizId,
    required this.isTeam,
    required this.quizTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(
        leaderboardProvider(LeaderboardParams(quizId: quizId, isTeam: isTeam)));

    return RefreshIndicator(
      onRefresh: () async {
        return ref.refresh(leaderboardProvider(
                LeaderboardParams(quizId: quizId, isTeam: isTeam))
            .future);
      },
      child: leaderboardAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No scores submitted yet.'));
          }

          final topThree = entries.take(3).toList();
          final theRest = entries.skip(3).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: _LeaderboardHeader(entries: topThree, isTeam: isTeam),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = theRest[index];
                      final rank = index + 4;

                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: rank <= 10
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                              border: rank <= 10
                                  ? Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.2))
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '$rank',
                                style: AppTypography.label.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: rank <= 10
                                      ? AppColors.primary
                                      : AppColors.textPrimary
                                          .withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            isTeam
                                ? (entry.teamName ?? 'Unnamed Team')
                                : (entry.username ?? 'Unknown'),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(Icons.stars_rounded,
                                  size: 12,
                                  color:
                                      AppColors.accent.withValues(alpha: 0.8)),
                              const SizedBox(width: 4),
                              Text(
                                '${entry.score} pts',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: ChallengeButton(
                            width: 90,
                            height: 32,
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => ChallengeLoadingScreen(
                                    quizId: quizId,
                                    quizTitle: quizTitle,
                                    isLeaderboardChallenge: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: (index * 40).ms, duration: 400.ms)
                          .slideY(
                              begin: 0.2, end: 0, curve: Curves.easeOutQuad);
                    },
                    childCount: theRest.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final bool isTeam;

  const _LeaderboardHeader({required this.entries, required this.isTeam});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final podiumWinners = entries.map((e) {
      return PodiumPlace(
        name:
            isTeam ? (e.teamName ?? 'Unnamed Team') : (e.username ?? 'Unknown'),
        score: e.score,
      );
    }).toList();

    return Column(
      children: [
        AppPodium(winners: podiumWinners),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
