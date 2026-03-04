import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/organization_providers.dart';
import '../providers/organizations_providers.dart';
import '../widgets/audit_logs_view.dart';
import '../widgets/organization_members_view.dart';
import '../widgets/branding_settings_view.dart';
import '../widgets/webhook_settings_view.dart';
import '../widgets/sso_configuration_view.dart';
import '../widgets/webhook_logs_view.dart';
import '../widgets/organization_health_view.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final String organizationId;
  const AdminDashboardScreen({super.key, required this.organizationId});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeOrg = ref.watch(activeWorkspaceProvider);
    final isAdmin = ref.watch(isOrganizationAdminProvider);

    if (activeOrg == null || activeOrg.id != widget.organizationId) {
      return const Scaffold(
          body: Center(child: Text('Invalid Organization Session')));
    }

    if (!isAdmin) {
      return const Scaffold(body: Center(child: Text('Unauthorized access')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StarryBackground(
        child: Column(
          children: [
            GlassHeader(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Admin Dashboard', style: AppTypography.h3),
                  Text(activeOrg.name,
                      style: AppTypography.label
                          .copyWith(color: AppColors.primary)),
                ],
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Health', icon: Icon(Icons.favorite_rounded)),
                Tab(text: 'Members', icon: Icon(Icons.people_rounded)),
                Tab(text: 'Identity', icon: Icon(Icons.security_rounded)),
                Tab(text: 'Branding', icon: Icon(Icons.palette_rounded)),
                Tab(text: 'Webhooks', icon: Icon(Icons.webhook_rounded)),
                Tab(text: 'Delivery Logs', icon: Icon(Icons.terminal_rounded)),
                Tab(
                    text: 'Audit Logs',
                    icon: Icon(Icons.history_toggle_off_rounded)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const OrganizationHealthView(),
                  const OrganizationMembersView(),
                  const SSOConfigurationView(),
                  const BrandingSettingsView(),
                  const WebhookSettingsView(),
                  const WebhookLogsView(),
                  const AuditLogsView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
