import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/organization_providers.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class AuditLogsView extends ConsumerWidget {
  const AuditLogsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrg = ref.watch(activeWorkspaceProvider);
    if (activeOrg == null)
      return const Center(child: Text('Please select an organization'));

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchLogs(ref, activeOrg.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return const Center(child: Text('No audit logs recorded yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildAuditListItem(log);
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchLogs(
      WidgetRef ref, String orgId) async {
    final repository = ref.read(organizationRepositoryProvider);
    final result = await repository.getAuditLogs(orgId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (logs) => logs,
    );
  }

  Widget _buildAuditListItem(Map<String, dynamic> log) {
    final event = log['event_type'] as String;
    final createdAt = DateTime.parse(log['created_at']);
    final details = log['details'] as Map<String, dynamic>?;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEventBadge(event),
              Text(
                DateFormat('MMM dd, HH:mm:ss').format(createdAt),
                style: AppTypography.label.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (details != null)
            Text(
              'User ID: ${log['user_id'] ?? 'System'}',
              style: AppTypography.bodySmall.copyWith(fontSize: 11),
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatOperationMessage(event, details),
            style:
                AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
          if (log['ip_address'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'IP: ${log['ip_address']}',
              style: AppTypography.label.copyWith(
                  fontSize: 9,
                  color: AppColors.textSecondary.withValues(alpha: 0.5)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventBadge(String event) {
    Color color = AppColors.primary;
    if (event.contains('INSERT')) color = AppColors.success;
    if (event.contains('DELETE')) color = AppColors.error;
    if (event.contains('UPDATE')) color = AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        event.replaceAll('_', ' '),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatOperationMessage(String event, Map<String, dynamic>? details) {
    final table = details?['table'] ?? 'unknown';
    final op = details?['operation'] ?? 'action';

    if (event.contains('organizations'))
      return 'Organization structure modified';
    if (event.contains('members')) return 'Team membership changed';
    if (event.contains('webhooks')) return 'Webhook configuration updated';

    return '$op on $table';
  }
}
