import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/organization_providers.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class OrganizationMembersView extends ConsumerWidget {
  const OrganizationMembersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrg = ref.watch(activeWorkspaceProvider);
    if (activeOrg == null)
      return const Center(child: Text('Please select an organization'));

    final membersAsync = ref.watch(organizationMembersProvider(activeOrg.id));

    return membersAsync.when(
      data: (members) => ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: members.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0)
            return _buildAddMemberButton(context, ref, activeOrg.id);
          final member = members[index - 1];
          return _buildMemberTile(context, ref, member);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildAddMemberButton(
      BuildContext context, WidgetRef ref, String orgId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppButton(
        label: 'Invite Member',
        icon: const Icon(Icons.person_add_rounded),
        onPressed: () => _showInviteDialog(context, ref, orgId),
      ),
    );
  }

  Widget _buildMemberTile(
      BuildContext context, WidgetRef ref, OrganizationMemberEntity member) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.userId,
                    style: AppTypography
                        .bodyMedium), // Ideally show username/email
                Text(
                  member.role.name.toUpperCase(),
                  style: AppTypography.label.copyWith(
                    color: member.role == OrganizationRole.admin
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (member.role != OrganizationRole.admin)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: AppColors.error),
              onPressed: () => _removeMember(context, ref, member),
            ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context, WidgetRef ref, String orgId) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Invite Member'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: 'User Email'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final repo = ref.read(organizationRepositoryProvider);
              await repo.addMember(
                  orgId, emailController.text, OrganizationRole.member);
              if (context.mounted) {
                ref.invalidate(organizationMembersProvider(orgId));
                Navigator.pop(context);
              }
            },
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }

  void _removeMember(BuildContext context, WidgetRef ref,
      OrganizationMemberEntity member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member?'),
        content: const Text(
            'Are you sure you want to remove this member from the organization?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(organizationRepositoryProvider);
      await repo.removeMember(member.organizationId, member.userId);
      ref.invalidate(organizationMembersProvider(member.organizationId));
    }
  }
}
