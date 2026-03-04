import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../auth/presentation/providers/organization_providers.dart';
import '../providers/webhook_providers.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class WebhookSettingsView extends ConsumerWidget {
  const WebhookSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrg = ref.watch(activeWorkspaceProvider);
    if (activeOrg == null)
      return const Center(child: Text('Please select an organization'));

    final webhooksAsync = ref.watch(webhooksProvider(activeOrg.id));

    return webhooksAsync.when(
      data: (webhooks) => ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: webhooks.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeader(context, ref, activeOrg.id);
          final webhook = webhooks[index - 1];
          return _buildWebhookCard(context, ref, webhook);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, String orgId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Registered Endpoints', style: AppTypography.h3),
            AppButton(
              label: 'Add Webhook',
              type: AppButtonType.premium,
              icon: const Icon(Icons.add_link_rounded),
              onPressed: () => _showAddWebhookDialog(context, ref, orgId),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Receive real-time notifications for organization events.',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05);
  }

  Widget _buildWebhookCard(
      BuildContext context, WidgetRef ref, WebhookEntity webhook) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                webhook.isActive
                    ? Icons.check_circle_rounded
                    : Icons.pause_circle_rounded,
                color: webhook.isActive
                    ? AppColors.success
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  webhook.url,
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
                onPressed: () => _deleteWebhook(context, ref, webhook),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 6,
            children: webhook.events
                .map((e) => _buildEventChip(e).animate().scale(delay: 200.ms))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Secret: ••••••••••••••••',
                style: AppTypography.label.copyWith(fontSize: 10),
              ),
              TextButton(
                onPressed: () => _showSecret(context, webhook.secret),
                child:
                    const Text('Reveal Secret', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildEventChip(String event) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        event,
        style: const TextStyle(
            color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddWebhookDialog(
      BuildContext context, WidgetRef ref, String orgId) {
    final urlController = TextEditingController();
    final List<String> availableEvents = [
      'game.started',
      'game.ended',
      'quiz.created',
      'member.joined'
    ];
    final List<String> selectedEvents = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Register New Webhook', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.lg),
              Text('Target URL', style: AppTypography.label),
              const SizedBox(height: 8),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: 'https://your-api.com/webhooks',
                  filled: true,
                  fillColor: Colors.black26,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Event Subscriptions', style: AppTypography.label),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                children: availableEvents.map((event) {
                  final isSelected = selectedEvents.contains(event);
                  return FilterChip(
                    label: Text(event),
                    selected: isSelected,
                    onSelected: (val) {
                      setModalState(() {
                        if (val) {
                          selectedEvents.add(event);
                        } else {
                          selectedEvents.remove(event);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Activate Webhook',
                onPressed: () async {
                  if (urlController.text.isEmpty) return;
                  final repo = ref.read(organizationRepositoryProvider);
                  await repo.createWebhook(
                      orgId, urlController.text, selectedEvents);
                  if (context.mounted) {
                    ref.invalidate(webhooksProvider(orgId));
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecret(BuildContext context, String secret) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Webhook Signing Secret'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Use this key to verify the authenticity of requests from Quiz Arena.',
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            SelectableText(
              secret,
              style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 14,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done')),
        ],
      ),
    );
  }

  void _deleteWebhook(
      BuildContext context, WidgetRef ref, WebhookEntity webhook) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Webhook?'),
        content:
            const Text('This endpoint will no longer receive notifications.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(organizationRepositoryProvider);
      await repo.deleteWebhook(webhook.id);
      ref.invalidate(webhooksProvider(webhook.organizationId));
    }
  }
}
