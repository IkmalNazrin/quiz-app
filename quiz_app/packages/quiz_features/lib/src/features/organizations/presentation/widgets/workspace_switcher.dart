import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/organization_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../features/organizations/presentation/providers/organizations_providers.dart';
import 'package:go_router/go_router.dart';

import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

class WorkspaceSwitcher extends ConsumerWidget {
  const WorkspaceSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationsAsync = ref.watch(userOrganizationsProvider);
    final activeWorkspace = ref.watch(activeWorkspaceProvider);

    return organizationsAsync.when(
      data: (orgs) {
        if (orgs.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('WORKSPACE',
                      style: AppTypography.label.copyWith(
                          color: AppColors.textSecondary, letterSpacing: 1.2)),
                  if (activeWorkspace != null &&
                      ref.watch(isOrganizationAdminProvider))
                    TextButton.icon(
                      onPressed: () => context.pushNamed(
                        'admin_organization',
                        pathParameters: {'orgId': activeWorkspace.id},
                      ),
                      icon: const Icon(Icons.settings_outlined, size: 14),
                      label: Text('MANAGE',
                          style: AppTypography.label
                              .copyWith(color: AppColors.primary)),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, minimumSize: Size.zero),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _WorkspaceChip(
                      label: 'Personal',
                      isSelected: activeWorkspace == null,
                      onTap: () => ref
                          .read(activeWorkspaceProvider.notifier)
                          .selectWorkspace(null),
                      icon: Icons.person_rounded,
                    ),
                    ...orgs.map((OrganizationEntity org) => _WorkspaceChip(
                          label: org.name,
                          isSelected: activeWorkspace?.id == org.id,
                          onTap: () => ref
                              .read(activeWorkspaceProvider.notifier)
                              .selectWorkspace(org),
                          icon: Icons.business_rounded,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _WorkspaceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _WorkspaceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
