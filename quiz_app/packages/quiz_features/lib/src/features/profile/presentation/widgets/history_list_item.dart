import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:quiz_domain/quiz_domain.dart';

class HistoryListItem extends StatelessWidget {
  final GameHistoryItem item;

  const HistoryListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Determine color based on score or rank (mock logic for now)
    final isHigh = item.score > 800; // Arbitrary threshold

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color:
              isHigh ? Colors.amber.withValues(alpha: 0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon / Rank placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isHigh
                  ? Colors.amber.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isHigh ? Icons.emoji_events : Icons.history,
                color: isHigh ? Colors.amber[700] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.quizTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMd().add_jm().format(item.playedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.score}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isHigh ? Colors.amber[800] : null,
                    ),
              ),
              Text(
                'PTS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
