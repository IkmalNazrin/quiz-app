import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../auth/presentation/providers/organization_providers.dart';
import '../providers/sso_providers.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class SSOConfigurationView extends ConsumerStatefulWidget {
  const SSOConfigurationView({super.key});

  @override
  ConsumerState<SSOConfigurationView> createState() =>
      _SSOConfigurationViewState();
}

class _SSOConfigurationViewState extends ConsumerState<SSOConfigurationView> {
  late TextEditingController _entityIdController;
  late TextEditingController _metadataUrlController;
  late TextEditingController _domainController;
  bool _isEnabled = false;
  String _providerType = 'saml';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _entityIdController = TextEditingController();
    _metadataUrlController = TextEditingController();
    _domainController = TextEditingController();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConfig();
    });
  }

  Future<void> _loadConfig() async {
    final activeOrg = ref.read(activeWorkspaceProvider);
    if (activeOrg == null) return;

    final config = await ref.read(ssoConfigProvider(activeOrg.id).future);
    if (config != null) {
      setState(() {
        _isEnabled = config.isEnabled;
        _providerType = config.providerType;
        _entityIdController.text = config.entityId ?? '';
        _metadataUrlController.text = config.metadataUrl ?? '';
        _domainController.text = config.domainFilter ?? '';
      });
    }
  }

  @override
  void dispose() {
    _entityIdController.dispose();
    _metadataUrlController.dispose();
    _domainController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    final activeOrg = ref.read(activeWorkspaceProvider);
    if (activeOrg == null) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(organizationRepositoryProvider);
      final result = await repo.updateSSOConfig(activeOrg.id, {
        'is_enabled': _isEnabled,
        'provider_type': _providerType,
        'entity_id': _entityIdController.text.trim(),
        'metadata_url': _metadataUrlController.text.trim(),
        'domain_filter': _domainController.text.trim(),
      });

      result.fold(
        (failure) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${failure.message}'))),
        (_) {
          ref.invalidate(ssoConfigProvider(activeOrg.id));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SSO Configuration updated!')));
        },
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildStatusToggle(),
          const SizedBox(height: AppSpacing.lg),
          if (_isEnabled) ...[
            _buildConfigForm(),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Save SSO Configuration',
              onPressed: _isSaving ? null : _saveConfig,
              isLoading: _isSaving,
              type: AppButtonType.premium,
            ),
          ],
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _buildInfoSection() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Enterprise Identity', style: AppTypography.h3),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Secure your organization by delegating authentication to your internal identity provider (IdP).',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SSO Status', style: AppTypography.label),
              Text(
                _isEnabled ? 'Active and Enforced' : 'Disabled',
                style: AppTypography.bodySmall.copyWith(
                  color:
                      _isEnabled ? AppColors.success : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: _isEnabled,
            onChanged: (val) => setState(() => _isEnabled = val),
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Configuration Details', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Provider Type', style: AppTypography.label),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'saml',
                      label: Text('SAML 2.0'),
                      icon: Icon(Icons.account_tree_rounded, size: 16)),
                  ButtonSegment(
                      value: 'oidc',
                      label: Text('OIDC'),
                      icon: Icon(Icons.badge_rounded, size: 16)),
                ],
                selected: {_providerType},
                onSelectionChanged: (val) =>
                    setState(() => _providerType = val.first),
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(_providerType == 'saml' ? 'Entity ID' : 'Client ID',
                  style: AppTypography.label),
              const SizedBox(height: 8),
              TextField(
                controller: _entityIdController,
                decoration: InputDecoration(
                  hintText: _providerType == 'saml'
                      ? 'urn:amazon:cognito:sp:...'
                      : '0oa...',
                  filled: true,
                  fillColor: Colors.black26,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(_providerType == 'saml' ? 'Metadata URL' : 'Discovery URL',
                  style: AppTypography.label),
              const SizedBox(height: 8),
              TextField(
                controller: _metadataUrlController,
                decoration: InputDecoration(
                  hintText: 'https://...',
                  filled: true,
                  fillColor: Colors.black26,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Domain Filter (Restricted to)', style: AppTypography.label),
              const SizedBox(height: 8),
              TextField(
                controller: _domainController,
                decoration: const InputDecoration(
                  hintText: 'acme.com',
                  filled: true,
                  fillColor: Colors.black26,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().slideY(begin: 0.1);
  }
}
