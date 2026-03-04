import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../auth/presentation/providers/organization_providers.dart';
import '../providers/webhook_providers.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class WebhookLogsView extends ConsumerWidget {
  const WebhookLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrg = ref.watch(activeWorkspaceProvider);
    if (activeOrg == null)
      return const Center(child: Text('Please select an organization'));

    final logsAsync = ref.watch(webhookLogsProvider(activeOrg.id));

    return logsAsync.when(
      data: (logs) => logs.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: logs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) =>
                  _buildLogCard(context, logs[index])
                      .animate()
                      .fadeIn(delay: (index * 50).ms),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.md),
          Text('No Webhook Logs', style: AppTypography.h3),
          const SizedBox(height: 8),
          Text('Try triggering some events to see logs here.',
              style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, WebhookLogEntity log) {
    final isSuccess = log.responseStatus != null &&
        log.responseStatus! >= 200 &&
        log.responseStatus! < 300;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSuccess
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log.responseStatus?.toString() ?? 'FAILED',
                style: TextStyle(
                  color: isSuccess ? AppColors.success : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.eventType,
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    log.createdAt.toLocal().toString().split('.')[0],
                    style: AppTypography.label
                        .copyWith(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Text(
          '${log.executionTimeMs}ms',
          style: AppTypography.label.copyWith(fontSize: 10),
        ),
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          _buildDetailRow('Payload', log.payload.toString()),
          if (log.responseBody != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow('Response', log.responseBody!),
          ],
          if (log.errorMessage != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow('Error', log.errorMessage!, isError: true),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isError = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.label
                .copyWith(fontSize: 9, color: AppColors.primary)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 11,
              color: isError ? AppColors.error : Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}
