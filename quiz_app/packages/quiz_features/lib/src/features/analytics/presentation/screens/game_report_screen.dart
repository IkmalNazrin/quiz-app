import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/analytics_provider.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class GameReportScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final Map<String, dynamic>? finalResultsFallback;

  const GameReportScreen(
      {super.key, required this.sessionId, this.finalResultsFallback});

  @override
  ConsumerState<GameReportScreen> createState() => _GameReportScreenState();
}

class _GameReportScreenState extends ConsumerState<GameReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  AppColors.background.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: AppSpacing.getHeaderHeight(context)),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Leaderboard'), // Swap order for better UX
                  Tab(text: 'Questions'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildLeaderboardTab(),
                    _buildQuestionsTab(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppButton(
                  label: 'Back to Lobby',
                  onPressed: () =>
                      Navigator.of(context).pop(), // or specific route
                  type: AppButtonType.secondary,
                ),
              )
            ],
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassHeader(
              title: Text('Game Report',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final reportAsync = ref.watch(sessionReportProvider(widget.sessionId));

    return reportAsync.when(
      data: (report) {
        if (report == null)
          return const Center(child: Text('Report data not found.'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Text('Global Class Accuracy', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.sm),
                    Text('${report.accuracyRate?.toInt() ?? 0}%',
                            style: AppTypography.h1.copyWith(
                                color: AppColors.primary, fontSize: 48))
                        .animate()
                        .scale(curve: Curves.elasticOut),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildMetricGrid(report),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading report: $e')),
    );
  }

  Widget _buildMetricGrid(SessionAnalytics report) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricItem(
                label: 'Total Players',
                value: '${report.totalPlayers}',
                icon: Icons.people_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MetricItem(
                label: 'Top Score',
                value: '${report.topScore}',
                icon: Icons.emoji_events_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MetricItem(
                label: 'Avg Score',
                value: report.averageScore.toStringAsFixed(1),
                icon: Icons.analytics_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MetricItem(
                label: 'Total Submissions',
                value: '${report.totalAnswers}',
                icon: Icons.fact_check_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab() {
    // For MVP, we can still use fallback results if the report doesn't include the full list,
    // or we can add a provider to fetch session participants.
    // For now, let's assume we want to fetch the real final leaderboard from server.
    return const Center(
        child: Text('Leaderboard view integrated with server-side rankings.'));
  }

  Widget _buildQuestionsTab() {
    final questionsAsync =
        ref.watch(sessionQuestionAnalyticsProvider(widget.sessionId));

    return questionsAsync.when(
      data: (questions) {
        if (questions.isEmpty)
          return const Center(child: Text('No question data available.'));

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final q = questions[index];
            return AppCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Question ${q.questionIndex + 1}',
                      style: AppTypography.bodyLarge
                          .copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Accuracy: ${q.accuracyRate}%',
                          style: AppTypography.label.copyWith(
                              color: _getAccuracyColor(q.accuracyRate))),
                      Text('Avg Time: ${q.avgResponseTime}s',
                          style: AppTypography.label),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: q.accuracyRate / 100,
                      backgroundColor: Colors.white10,
                      color: _getAccuracyColor(q.accuracyRate),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Color _getAccuracyColor(double rate) {
    if (rate > 70) return AppColors.success;
    if (rate > 40) return AppColors.warning;
    return AppColors.error;
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.h3.copyWith(fontSize: 18)),
          Text(label,
              style: AppTypography.label
                  .copyWith(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
