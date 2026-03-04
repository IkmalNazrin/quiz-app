import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system.dart';
import '../app_icons.dart';

class AppPodium extends StatelessWidget {
  final List<PodiumPlace> winners;

  const AppPodium({super.key, required this.winners});

  @override
  Widget build(BuildContext context) {
    // Ensure we have at least 3 places or placeholders
    final List<PodiumPlace?> displayWinners = List.generate(3, (index) {
      if (index < winners.length) return winners[index];
      return null;
    });

    // Order for podium: 2nd, 1st, 3rd
    final second = displayWinners.length > 1 ? displayWinners[1] : null;
    final first = displayWinners.isNotEmpty ? displayWinners[0] : null;
    final third = displayWinners.length > 2 ? displayWinners[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null)
          _buildPodiumStep(second, 2, 110)
              .animate()
              .slideY(
                  begin: 1,
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                  delay: 200.ms)
              .fadeIn(duration: 400.ms),
        const SizedBox(width: AppSpacing.sm),
        if (first != null)
          _buildPodiumStep(first, 1, 160)
              .animate()
              .slideY(
                  begin: 1,
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                  delay: 600.ms)
              .fadeIn(duration: 400.ms),
        const SizedBox(width: AppSpacing.sm),
        if (third != null)
          _buildPodiumStep(third, 3, 90)
              .animate()
              .slideY(
                  begin: 1,
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                  delay: 400.ms)
              .fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildPodiumStep(PodiumPlace winner, int place, double height) {
    Color color;
    String svgIcon;
    List<Color> gradientColors;

    switch (place) {
      case 1:
        color = const Color(0xFFFFD700); // Pure Gold
        svgIcon = AppSvgIcons.trophy;
        gradientColors = [
          const Color(0xFFFFE082),
          const Color(0xFFFFA000),
          const Color(0xFFFF8F00),
        ];
        break;
      case 2:
        color = const Color(0xFFE2E8F0); // Platinum/Silver
        svgIcon = AppSvgIcons.medal;
        gradientColors = [
          const Color(0xFFF8FAFC),
          const Color(0xFF94A3B8),
          const Color(0xFF475569),
        ];
        break;
      default:
        color = const Color(0xFFFB923C); // Vibrant Bronze/Copper
        svgIcon = AppSvgIcons.medal;
        gradientColors = [
          const Color(0xFFFFEDD5),
          const Color(0xFFD97706),
          const Color(0xFF92400E),
        ];
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (place == 1)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ],
                  color: color.withValues(alpha: 0.3),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 2.seconds),
            CircleAvatar(
              radius: place == 1 ? 35 : 30,
              backgroundColor: AppColors.surface,
              child: SvgPicture.string(
                svgIcon,
                width: place == 1 ? 40 : 30,
                height: place == 1 ? 40 : 30,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '$place',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )
            .animate(delay: 1.2.seconds)
            .scale(curve: Curves.elasticOut, duration: 800.ms),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: 90,
          child: Text(
            winner.name,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 85,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 1.0],
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${winner.score}',
                  style: AppTypography.h2.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  'PTS',
                  style: AppTypography.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PodiumPlace {
  final String name;
  final int score;
  const PodiumPlace({required this.name, required this.score});
}
