import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/analytics_provider.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class HostAnalyticsScreen extends ConsumerWidget {
  const HostAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostMetricsAsync = ref.watch(hostMetricsProvider);
    final sessionsAnalyticsAsync = ref.watch(allSessionsAnalyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Ambient Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.getHeaderHeight(context) + AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildOverviewSection(hostMetricsAsync),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildSectionHeader('GAME SESSION HISTORY'),
                      const SizedBox(height: AppSpacing.md),
                    ]),
                  ),
                ),
                sessionsAnalyticsAsync.when(
                  data: (sessions) {
                    if (sessions.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildEmptyState(),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final session = sessions[index];
                          return _buildEpicSessionRow(session, index);
                        },
                        childCount: sessions.length,
                      ),
                    );
                  },
                  loading: () => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const AnalyticsQuizRowSkeleton(),
                      childCount: 5,
                    ),
                  ),
                  error: (_, __) =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassHeader(
              title: Text(
                'Host Analytics',
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(AsyncValue<HostMetrics> metricsAsync) {
    return metricsAsync.when(
      data: (metrics) {
        final totalQuizzes = metrics.sessionsHosted;
        final totalPlayers = metrics.lifetimePlayers;
        final hostRating = metrics.globalAvgScore.toStringAsFixed(1);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _EpicStatCard(
                    label: 'Sessions Hosted',
                    value: '$totalQuizzes',
                    icon: Icons.quiz_rounded,
                    gradient: AppColors.primaryGradient,
                    delay: 0.ms,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _EpicStatCard(
                    label: 'Avg Participant Score',
                    value: hostRating,
                    icon: Icons.star_rounded,
                    gradient: AppColors.premiumGold,
                    delay: 100.ms,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _EpicStatCard(
                    label: 'Lifetime Players',
                    value: '$totalPlayers',
                    icon: Icons.groups_rounded,
                    gradient: AppColors.difficultyEasy, // Green/Teal gradient
                    delay: 200.ms,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _EpicStatCard(
                    label: 'Peak Players',
                    value: '${metrics.peakPlayerCount}',
                    icon: Icons.auto_graph_rounded,
                    gradient: AppColors.difficultyMedium,
                    delay: 300.ms,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => Column(
        children: [
          Row(
            children: [
              Expanded(child: AnalyticsStatCardSkeleton()),
              SizedBox(width: AppSpacing.md),
              Expanded(child: AnalyticsStatCardSkeleton()),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: AnalyticsStatCardSkeleton()),
              SizedBox(width: AppSpacing.md),
              Expanded(child: AnalyticsStatCardSkeleton()),
            ],
          ),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTypography.label.copyWith(
            color: AppColors.textPrimary.withValues(alpha: 0.8),
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1);
  }

  Widget _buildEpicSessionRow(SessionAnalytics session, int index) {
    final performance =
        session.accuracyRate != null ? session.accuracyRate! / 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session: ${session.gamePin}',
                        style: AppTypography.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(session.createdAt),
                        style: AppTypography.label.copyWith(
                            color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text('${session.totalPlayers} players',
                      style: AppTypography.label
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Accuracy Bar Indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Global Accuracy',
                        style: AppTypography.label.copyWith(fontSize: 10)),
                    Text('${(performance * 100).toInt()}%',
                        style: AppTypography.label.copyWith(
                            color: _getPerformanceColor(performance))),
                  ],
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                    LayoutBuilder(builder: (context, constraints) {
                      return Container(
                        height: 6,
                        width: constraints.maxWidth * performance,
                        decoration: BoxDecoration(
                          color: _getPerformanceColor(performance),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          boxShadow: [
                            BoxShadow(
                              color: _getPerformanceColor(performance)
                                  .withValues(alpha: 0.5),
                              blurRadius: 6,
                            )
                          ],
                        ),
                      ).animate(delay: (500 + index * 50).ms).scaleX(
                          begin: 0,
                          alignment: Alignment.centerLeft,
                          duration: 800.ms,
                          curve: Curves.easeOutExpo);
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (500 + index * 50).ms).slideY(begin: 0.1),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getPerformanceColor(double value) {
    if (value > 0.8) return AppColors.success;
    if (value > 0.5) return AppColors.primary;
    if (value > 0.3) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Center(
          child: Text("No quizzes found.",
              style: TextStyle(color: Colors.white54))),
    );
  }
}

class _EpicStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final Duration delay;

  const _EpicStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              Icon(Icons.auto_graph_rounded,
                  color: AppColors.success.withValues(alpha: 0.8), size: 16),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(value,
                  style: AppTypography.h2.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ))
              .animate(delay: delay + 200.ms)
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
          const SizedBox(height: 4),
          Text(label,
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    ).animate(delay: delay).fadeIn().slideY(begin: 0.2);
  }
}
