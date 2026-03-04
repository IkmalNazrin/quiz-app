import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../manager/history_provider.dart';
import 'history_list_item.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class SliverHistoryList extends ConsumerWidget {
  const SliverHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.value?.id;

    if (userId == null) {
      return const SliverToBoxAdapter(
          child: Center(child: Text("Please login to view history")));
    }

    final historyAsync = ref.watch(userHistoryProvider(userId));

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off,
                      size: 48,
                      color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    "No games played yet!",
                    style: AppTypography.bodyLarge
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = history[index];
              return HistoryListItem(item: item);
            },
            childCount: history.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text("Failed to load history: $err")),
        ),
      ),
    );
  }
}
