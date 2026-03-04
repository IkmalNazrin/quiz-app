import 'package:flutter/material.dart';

import 'package:quiz_domain/quiz_domain.dart';

class RankBadge extends StatelessWidget {
  final int level;

  const RankBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final title = LevelCalculator.getRankTitle(level);
    final hexColors = LevelCalculator.getRankColors(level);

    // Convert hex strings to Color objects
    final color1 = Color(int.parse(hexColors[0].replaceFirst('#', '0xFF')));
    final color2 = Color(int.parse(hexColors[1].replaceFirst('#', '0xFF')));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color1.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
