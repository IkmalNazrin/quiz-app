import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/leaderboard_provider.dart';
import '../pages/leaderboard_page.dart';
import 'package:quiz_features/quiz_features.dart';
import 'challenge_button.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class LeaderboardPreview extends ConsumerStatefulWidget {
  final String quizId;
  final String quizTitle;

  const LeaderboardPreview({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  ConsumerState<LeaderboardPreview> createState() => _LeaderboardPreviewState();
}

class _LeaderboardPreviewState extends ConsumerState<LeaderboardPreview> {
  bool _isTeam = false;

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider(
        LeaderboardParams(quizId: widget.quizId, isTeam: _isTeam)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isTeam ? 'Team Rankings' : 'Individual Rankings',
              style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            _buildTypeToggle(),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Leaderboard List
        leaderboardAsync.when(
          data: (entries) => _buildList(entries),
          loading: () => _buildLoading(),
          error: (err, stack) => _buildError(err.toString()),
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: AppSvgIcons.user,
            isSelected: !_isTeam,
            onTap: () => setState(() => _isTeam = false),
          ),
          _ToggleButton(
            icon: AppSvgIcons.users,
            isSelected: _isTeam,
            onTap: () => setState(() => _isTeam = true),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<LeaderboardEntry> entries) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: Text(
            'No scores yet. Be the first!',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final displayEntries = entries.take(3).toList();

    return Column(
      children: [
        ...displayEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return _LeaderboardItem(
            entry: data,
            rank: index + 1,
            isTeam: _isTeam,
            quizId: widget.quizId,
            quizTitle: widget.quizTitle,
          )
              .animate()
              .fadeIn(delay: (index * 100).ms, duration: 400.ms)
              .slideX(begin: 0.05);
        }),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'View Full Leaderboard',
          type: AppButtonType.ghost,
          height: 36,
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => LeaderboardPage(
                  quizId: widget.quizId,
                  quizTitle: widget.quizTitle,
                  initialIsTeam: _isTeam,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Column(
      children: List.generate(3, (index) => const LeaderboardSkeleton()),
    );
  }

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Text(
          'Failed to load scores',
          style: AppTypography.bodySmall.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: SvgPicture.string(
          icon,
          width: 16,
          height: 16,
          colorFilter: ColorFilter.mode(
            isSelected ? Colors.white : AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final bool isTeam;
  final String quizId;
  final String quizTitle;

  const _LeaderboardItem({
    required this.entry,
    required this.rank,
    required this.isTeam,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _buildRankBadge(),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTeam
                      ? (entry.teamName ?? 'Unnamed Team')
                      : (entry.username ?? 'Explorer'),
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${entry.score} pts',
                  style: AppTypography.label.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          ChallengeButton(
            isTeam: isTeam,
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
        ],
      ),
    );
  }

  Widget _buildRankBadge() {
    Color color;
    switch (rank) {
      case 1:
        color = AppColors.accent;
        break;
      case 2:
        color = const Color(0xFF94A3B8);
        break;
      case 3:
        color = const Color(0xFFB45309);
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
