import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/analytics_provider.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class QuizAnalyticsView extends ConsumerWidget {
  final String quizId;

  const QuizAnalyticsView({super.key, required this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(quizAnalyticsProvider(quizId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.midnightGradient)),

          statsAsync.when(
            data: (stats) => Column(
              children: [
                GlassHeader(
                  title: const Text('Quiz Insights'),
                  leading: const BackButton(color: Colors.white),
                ),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(height: AppSpacing.md),
                            _buildChartSection(stats)
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.1),
                            const SizedBox(height: AppSpacing.lg),
                            _buildDistributionSection(stats)
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 600.ms)
                                .slideY(begin: 0.1),
                            const SizedBox(height: AppSpacing.lg),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: AppSpacing.xs, bottom: AppSpacing.sm),
                              child: Text('Key Performance Metrics',
                                  style: AppTypography.h3),
                            ),
                            _buildMetricsGrid(stats),
                            const SizedBox(height: 100),
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

  Widget _buildChartSection(stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text('Score Trends', style: AppTypography.h3),
        ),
        GlassCard(
          height: 240,
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) =>
                      AppColors.surface.withValues(alpha: 0.95),
                  tooltipBorder: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      return LineTooltipItem(
                        '${touchedSpot.y} pts',
                        AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withValues(alpha: 0.05),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        value.toInt().toString(),
                        style: AppTypography.label.copyWith(
                          fontSize: 10,
                          color: AppColors.textPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    reservedSize: 32,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'DAY ${value.toInt()}',
                        style: AppTypography.label.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 2.1),
                    const FlSpot(1, 3.8),
                    const FlSpot(2, 2.9),
                    const FlSpot(3, 4.8),
                    const FlSpot(4, 4.1),
                  ],
                  isCurved: true,
                  curveSmoothness: 0.35,
                  gradient: AppColors.primaryGradient,
                  barWidth: 5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.background,
                      strokeWidth: 3,
                      strokeColor: AppColors.primary,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.25),
                        AppColors.primary.withValues(alpha: 0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate(delay: 500.ms)
              .scale(duration: 1.seconds, curve: Curves.easeOutCubic),
        ),
      ],
    );
  }

  Widget _buildDistributionSection(stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text('Score Distribution', style: AppTypography.h3),
        ),
        GlassCard(
          height: 200,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 10,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      AppColors.surface.withValues(alpha: 0.9),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} players',
                      AppTypography.label.copyWith(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const labels = [
                        '0-20%',
                        '20-40%',
                        '40-60%',
                        '60-80%',
                        '80-100%'
                      ];
                      if (value.toInt() >= 0 && value.toInt() < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(labels[value.toInt()],
                              style: AppTypography.label.copyWith(fontSize: 8)),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                _makeGroupData(0, 2, AppColors.error),
                _makeGroupData(1, 4, AppColors.warning),
                _makeGroupData(2, 7, AppColors.primary),
                _makeGroupData(3, 5, AppColors.secondary),
                _makeGroupData(4, 3, AppColors.success),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: color.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(stats) {
    return Column(
      children: [
        _buildMetricTile(
          'Completion Rate',
          '${(stats.completionRate * 100).toStringAsFixed(1)}%',
          Icons.done_all_rounded,
          AppColors.success,
          index: 1,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildMetricTile(
          'Average Score',
          stats.avgScore.toStringAsFixed(1),
          Icons.insights_rounded,
          AppColors.secondary,
          index: 2,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildMetricTile(
          'Play Count',
          stats.playCount.toString(),
          Icons.play_circle_fill_rounded,
          AppColors.primary,
          index: 3,
        ),
      ],
    );
  }

  Widget _buildMetricTile(
      String title, String value, IconData icon, Color color,
      {required int index}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: AppTypography.bodyMedium),
        trailing: Text(
          value,
          style: AppTypography.h3.copyWith(color: color),
        ),
      ),
    ).animate(delay: (200 * index).ms).fadeIn().slideX(begin: 0.1);
  }
}
