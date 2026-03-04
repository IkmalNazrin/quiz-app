import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/analytics_provider.dart';
import './quiz_analytics_view.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_features/quiz_features.dart';

class HostAnalyticsDashboard extends ConsumerWidget {
  const HostAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userStart = authState.valueOrNull;
    if (userStart == null || userStart.id.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view analytics')),
      );
    }

    final statsAsync = ref.watch(hostMetricsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Premium Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.midnightGradient,
            ),
          ),

          statsAsync.when(
            data: (stats) => Column(
              children: [
                GlassHeader(
                  title: const Text('Host Performance'),
                  leading: const BackButton(color: Colors.white),
                  height: 120,
                  child: Text(
                    _getPersonalityMessage(stats),
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.secondary),
                  ).animate().fadeIn(delay: 400.ms).slideX(),
                ),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildSummaryGrid(stats),
                            const SizedBox(height: AppSpacing.xxl),
                            _buildSectionHeader('Asset Performance Metrics'),
                            const SizedBox(height: AppSpacing.md),
                            _buildQuizzesSection(context, ref, userStart.id),
                            const SizedBox(height: AppSpacing.xxl),
                            _buildSectionHeader('Executive Summary Insights'),
                            const SizedBox(height: AppSpacing.md),
                            _buildInsightCard(
                              'Market Penetration',
                              'You have entertained ${stats.lifetimePlayers} unique players!',
                              Icons.public_rounded,
                              AppColors.primary,
                            ).animate().fadeIn(delay: 800.ms).scale(),
                            const SizedBox(height: AppSpacing.md),
                            _buildInsightCard(
                              'User Satisfaction',
                              'Your aggregate metrics are stellar!',
                              Icons.auto_awesome_rounded,
                              AppColors.accent,
                            ).animate().fadeIn(delay: 1000.ms).scale(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.h3.copyWith(letterSpacing: -0.5),
    ).animate().fadeIn().slideX(begin: -0.2);
  }

  Widget _buildSummaryGrid(stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.1,
      children: [
        _EpicStatCard(
          title: 'Sessions',
          value: stats.sessionsHosted.toString(),
          icon: Icons.auto_stories_rounded,
          gradient: AppColors.primaryGradient,
          delay: 200.ms,
        ),
        _EpicStatCard(
          title: 'Total Plays',
          value: stats.sessionsHosted.toString(),
          icon: Icons.rocket_launch_rounded,
          gradient: AppColors.difficultyMedium,
          delay: 400.ms,
        ),
        _EpicStatCard(
          title: 'Players',
          value: stats.lifetimePlayers.toString(),
          icon: Icons.groups_rounded,
          gradient: AppColors.difficultyEasy,
          delay: 600.ms,
        ),
        _EpicStatCard(
          title: 'Host Rating',
          value: stats.globalAvgScore.toStringAsFixed(1),
          icon: Icons.star_rounded,
          gradient: AppColors.premiumGold,
          delay: 800.ms,
        ),
      ],
    );
  }

  Widget _buildQuizzesSection(
      BuildContext context, WidgetRef ref, String hostId) {
    final quizzesAsync = ref.watch(hostQuizzesPerformanceProvider(hostId));

    return quizzesAsync.when(
      data: (quizzes) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: quizzes.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return GlassCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        QuizAnalyticsView(quizId: quiz['id'].toString())),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_stories_rounded,
                    color: AppColors.primary, size: 20),
              ),
              title: Text(quiz['title'] ?? 'Untitled',
                  style: AppTypography.bodyLarge
                      .copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${quiz['playCount'] ?? 0} Plays • ${quiz['avgRating'] ?? 0} Rating',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.textSecondary),
            ),
          ).animate(delay: (100 * index).ms).fadeIn().slideX(begin: 0.1);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Text(
            'Load Error: $error',
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(
      String title, String description, IconData icon, Color accentColor) {
// ... rest of file
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.h4),
                Text(description, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPersonalityMessage(HostMetrics stats) {
    if (stats.sessionsHosted == 0)
      return 'System Initialized. Awaiting first asset deployment.';
    if (stats.globalAvgScore >= 80)
      return 'Elite KPI Performance: Exceptional user satisfaction and reach.';
    if (stats.globalAvgScore >= 60)
      return 'Strategic Growth: Portfolio impact is scaling successfully.';
    return 'Infrastructure Online. Ready for session initialization.';
  }
}

class _EpicStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final Duration delay;

  const _EpicStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => gradient.createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 32),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                    duration: 2.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.h2.copyWith(
                fontSize: 28,
                letterSpacing: -1,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              title.toUpperCase(),
              style: AppTypography.label.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delay)
        .scale(curve: Curves.elasticOut, duration: 800.ms);
  }
}
