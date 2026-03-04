import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class ArenaPage extends ConsumerStatefulWidget {
  final List<ChallengeEntity> challenges;
  final String currentUserId;
  final Function(String) onStartChallenge;

  const ArenaPage({
    super.key,
    required this.challenges,
    required this.currentUserId,
    required this.onStartChallenge,
  });

  @override
  ConsumerState<ArenaPage> createState() => _ArenaPageState();
}

class _ArenaPageState extends ConsumerState<ArenaPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending =
        widget.challenges.where((c) => c.status == 'pending').toList();
    final completed =
        widget.challenges.where((c) => c.status == 'completed').toList();

    final headerHeight = AppSpacing.getHeaderHeight(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, headerHeight + AppSpacing.md,
          AppSpacing.md, AppSpacing.bottomNavBarPadding),
      child: Column(
        children: [
          // Premium Pill Tab Selector
          Center(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PillTab(
                    label: 'Pending',
                    count: pending.length,
                    isSelected: _tabController.index == 0,
                    onTap: () => _tabController.animateTo(0),
                  ),
                  _PillTab(
                    label: 'History',
                    isSelected: _tabController.index == 1,
                    onTap: () => _tabController.animateTo(1),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

          SizedBox(height: AppSpacing.lg),

          // Staggered List Content
          AnimatedSwitcher(
            duration: 300.ms,
            child: _tabController.index == 0
                ? _ChallengeList(
                    key: const ValueKey('pending_list'),
                    challenges: pending,
                    currentUserId: widget.currentUserId,
                    isCompleted: false,
                    onStartChallenge: widget.onStartChallenge,
                  )
                : _ChallengeList(
                    key: const ValueKey('history_list'),
                    challenges: completed,
                    currentUserId: widget.currentUserId,
                    isCompleted: true,
                    onStartChallenge: widget.onStartChallenge,
                  ),
          ),
        ],
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillTab({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 250.ms,
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count != null && count! > 0) ...[
              SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChallengeList extends StatelessWidget {
  final List<ChallengeEntity> challenges;
  final String currentUserId;
  final bool isCompleted;
  final Function(String) onStartChallenge;

  const _ChallengeList({
    super.key,
    required this.challenges,
    required this.currentUserId,
    required this.isCompleted,
    required this.onStartChallenge,
  });

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              Icon(
                isCompleted ? Icons.history_rounded : Icons.bolt_outlined,
                size: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                isCompleted ? 'No completed matches' : 'Arena is quiet...',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ).animate().fadeIn();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return _ArenaChallengeCard(
          challenge: challenges[index],
          currentUserId: currentUserId,
          isCompleted: isCompleted,
          onStartChallenge: onStartChallenge,
        )
            .animate()
            .fadeIn(delay: (index * 100).ms, duration: 400.ms)
            .slideX(begin: 0.1, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _ArenaChallengeCard extends StatelessWidget {
  final ChallengeEntity challenge;
  final String currentUserId;
  final bool isCompleted;
  final Function(String) onStartChallenge;

  const _ArenaChallengeCard({
    required this.challenge,
    required this.currentUserId,
    required this.isCompleted,
    required this.onStartChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final amIChallenger = challenge.challengerId == currentUserId;
    final opponentName = amIChallenger
        ? (challenge.opponentUsername ?? 'Unknown')
        : challenge.challengerUsername;
    final myScore =
        amIChallenger ? challenge.challengerScore : challenge.opponentScore;
    final theirScore =
        amIChallenger ? challenge.opponentScore : challenge.challengerScore;
    final didIWin = isCompleted && myScore > theirScore;

    return GlassCard(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.quizTitle,
                      style: AppTypography.h3.copyWith(fontSize: 18),
                    ),
                    Text(
                      amIChallenger
                          ? 'Challenged $opponentName'
                          : 'Challenged by $opponentName',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                _ResultBadge(didIWin: didIWin)
              else if (amIChallenger)
                _StatusBadge(label: 'Waiting', color: AppColors.warning)
              else
                _StatusBadge(label: 'New', color: AppColors.error),
            ],
          ),
          if (isCompleted) ...[
            SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ScoreDisplay(score: myScore, isWinner: didIWin),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text('VS',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.3))),
                ),
                _ScoreDisplay(
                    score: theirScore, isWinner: !didIWin, isOpponent: true),
              ],
            ),
          ] else if (!amIChallenger) ...[
            SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Enter Arena',
              onPressed: () => onStartChallenge(challenge.id),
              type: AppButtonType.primary,
              icon: const Icon(Icons.play_arrow_rounded),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final bool didIWin;
  const _ResultBadge({required this.didIWin});

  @override
  Widget build(BuildContext context) {
    final color = didIWin ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            didIWin
                ? Icons.emoji_events_rounded
                : Icons.sentiment_very_dissatisfied_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            didIWin ? 'VICTORY' : 'DEFEAT',
            style: AppTypography.label.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 10,
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
            delay: 2.seconds,
            duration: 1.5.seconds,
            color: Colors.white.withValues(alpha: 0.3))
        .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 2.seconds,
            curve: Curves.easeInOutSine);
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.label
            .copyWith(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final int score;
  final bool isWinner;
  final bool isOpponent;

  const _ScoreDisplay({
    required this.score,
    required this.isWinner,
    this.isOpponent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$score',
          style: AppTypography.h1.copyWith(
            fontSize: 36,
            color: isWinner ? AppColors.success : AppColors.textPrimary,
          ),
        ),
        Text(
          isOpponent ? 'THEM' : 'YOU',
          style: AppTypography.label.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
