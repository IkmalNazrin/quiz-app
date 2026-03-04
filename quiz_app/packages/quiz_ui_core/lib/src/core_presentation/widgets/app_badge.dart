import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system.dart';
import 'badge_details_dialog.dart';

class AppBadge extends StatelessWidget {
  final String iconEmoji; // e.g., '🔥' or use flutter IconData
  final String title;
  final String description;
  final bool isLarge;

  const AppBadge({
    super.key,
    required this.iconEmoji,
    required this.title,
    required this.description,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => BadgeDetailsDialog(
            iconEmoji: iconEmoji,
            title: title,
            description: description,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(isLarge ? 12 : 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          iconEmoji,
          style: TextStyle(fontSize: isLarge ? 32 : 18),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 3.seconds, color: Colors.white24)
          .animate()
          .scale(
              begin: const Offset(0.8, 0.8),
              curve: Curves.elasticOut,
              duration: 800.ms),
    );
  }
}
