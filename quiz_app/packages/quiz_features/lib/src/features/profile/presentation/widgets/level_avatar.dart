import 'package:flutter/material.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class LevelAvatar extends StatelessWidget {
  final String? avatarUrl;
  final int totalXP;
  final double radius;

  const LevelAvatar({
    super.key,
    this.avatarUrl,
    required this.totalXP,
    this.radius = 60,
  });

  @override
  Widget build(BuildContext context) {
    final progress = LevelCalculator.getLevelProgress(totalXP);
    final level = LevelCalculator.getLevel(totalXP);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Progress Ring
        SizedBox(
          width: (radius + 8) * 2,
          height: (radius + 8) * 2,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),

        // Avatar Container
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(Icons.person_rounded,
                    size: radius, color: AppColors.primary)
                : null,
          ),
        ),

        // Level Badge
        Positioned(
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Lvl $level',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
