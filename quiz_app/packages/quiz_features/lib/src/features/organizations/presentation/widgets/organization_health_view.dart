import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../auth/presentation/providers/organization_providers.dart';
import '../providers/sso_providers.dart';
import '../providers/branding_providers.dart';
import '../providers/webhook_providers.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class OrganizationHealthView extends ConsumerWidget {
  const OrganizationHealthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrg = ref.watch(activeWorkspaceProvider);
    if (activeOrg == null)
      return const Center(child: Text('Please select an organization'));

    final ssoAsync = ref.watch(ssoConfigProvider(activeOrg.id));
    final brandingAsync = ref.watch(organizationBrandingProvider);
    final webhooksAsync = ref.watch(webhooksProvider(activeOrg.id));
    final membersAsync = ref.watch(organizationMembersProvider(activeOrg.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallScore(
              ref, ssoAsync, brandingAsync, webhooksAsync, membersAsync),
          const SizedBox(height: AppSpacing.xl),
          Text('Governance Breakdown', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          _buildChecklist(
              ref, ssoAsync, brandingAsync, webhooksAsync, membersAsync),
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _buildOverallScore(
    WidgetRef ref,
    AsyncValue sso,
    AsyncValue branding,
    AsyncValue webhooks,
    AsyncValue members,
  ) {
    int score = 0;
    if (sso.asData?.value?.isEnabled == true) score += 25;
    if (branding.asData?.value != null) score += 20;
    if (webhooks.asData?.value?.isNotEmpty == true) score += 15;

    final adminCount =
        members.asData?.value?.where((m) => m.role.name == 'admin').length ?? 0;
    if (adminCount >= 2) {
      score += 25;
    } else if (adminCount == 1) {
      score += 10;
    }

    score += 15; // Baseline for active org

    final color = score > 80
        ? AppColors.success
        : (score > 50 ? AppColors.secondary : AppColors.error);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    color: color,
                    backgroundColor: Colors.white10,
                  ),
                )
                    .animate()
                    .rotate(duration: 1.seconds, curve: Curves.easeOutBack),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$score',
                        style: AppTypography.h1
                            .copyWith(fontSize: 40, color: color)),
                    Text('HEALTH',
                        style: AppTypography.label
                            .copyWith(color: color.withValues(alpha: 0.7))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              score > 80
                  ? 'Enterprise Ready'
                  : (score > 50 ? 'Developing' : 'Action Required'),
              style: AppTypography.h3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist(
    WidgetRef ref,
    AsyncValue sso,
    AsyncValue branding,
    AsyncValue webhooks,
    AsyncValue members,
  ) {
    final ssoActive = sso.asData?.value?.isEnabled == true;
    final brandingActive = branding.asData?.value != null;
    final webhooksActive = webhooks.asData?.value?.isNotEmpty == true;
    final adminCount =
        members.asData?.value?.where((m) => m.role.name == 'admin').length ?? 0;

    return Column(
      children: [
        _buildCheckItem('SSO Enforcement', ssoActive,
            'Delegated auth reduces account takeover risks.', 25),
        const SizedBox(height: AppSpacing.md),
        _buildCheckItem('Admin Redundancy', adminCount >= 2,
            'Having at least 2 admins prevents lockout.', 25),
        const SizedBox(height: AppSpacing.md),
        _buildCheckItem('Brand Identity', brandingActive,
            'Custom branding increases user trust.', 20),
        const SizedBox(height: AppSpacing.md),
        _buildCheckItem('Event Stream', webhooksActive,
            'Integrations enable automated governance.', 15),
      ],
    );
  }

  Widget _buildCheckItem(
      String title, bool isComplete, String hint, int points) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(
            isComplete
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isComplete ? AppColors.success : Colors.white24,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: AppTypography.bodySmall
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: '+$points',
                      type: isComplete
                          ? StatusBadgeType.secondary
                          : StatusBadgeType.standard,
                    ),
                  ],
                ),
                Text(hint,
                    style: AppTypography.label.copyWith(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: 0.1, delay: 200.ms);
  }
}
