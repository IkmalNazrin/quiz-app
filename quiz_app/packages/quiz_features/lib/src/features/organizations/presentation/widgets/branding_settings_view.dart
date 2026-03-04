import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/organization_providers.dart';
import '../providers/branding_providers.dart';

import 'package:quiz_ui_core/quiz_ui_core.dart';

class BrandingSettingsView extends ConsumerStatefulWidget {
  const BrandingSettingsView({super.key});

  @override
  ConsumerState<BrandingSettingsView> createState() =>
      _BrandingSettingsViewState();
}

class _BrandingSettingsViewState extends ConsumerState<BrandingSettingsView> {
  late TextEditingController _nameController;
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _accentColor;
  String? _logoUrl;
  String? _bannerUrl;
  bool _isSaving = false;
  bool _isUploadingLogo = false;
  bool _isUploadingBanner = false;

  @override
  void initState() {
    super.initState();
    final branding = ref.read(currentBrandingProvider);
    _nameController = TextEditingController(text: branding.appNameOverride);
    _primaryColor = branding.primaryColor;
    _secondaryColor = branding.secondaryColor;
    _accentColor = branding.accentColor;
    _logoUrl = branding.logoUrl;
    _bannerUrl = branding.bannerUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveBranding() async {
    final activeOrg = ref.read(activeWorkspaceProvider);
    if (activeOrg == null) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(organizationRepositoryProvider);
      final result = await repo.updateBranding(activeOrg.id, {
        'primary_color':
            '#${_primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
        'secondary_color':
            '#${_secondaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
        'accent_color':
            '#${_accentColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
        'app_name_override': _nameController.text,
        'logo_url': _logoUrl,
        'banner_url': _bannerUrl,
      });

      result.fold(
        (failure) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${failure.message}'))),
        (_) {
          ref.invalidate(organizationBrandingProvider);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Branding updated!')));
        },
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadImage(
      String type, Function(String) onUploaded) async {
    final activeOrg = ref.read(activeWorkspaceProvider);
    if (activeOrg == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    final file = result.files.single;
    final fileExtension = file.extension ?? 'png';

    setState(() {
      if (type == 'logo') {
        _isUploadingLogo = true;
      } else {
        _isUploadingBanner = true;
      }
    });

    try {
      final repo = ref.read(organizationRepositoryProvider);
      final result = await repo.uploadBrandingAsset(
          activeOrg.id, type, file.bytes!, fileExtension);

      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${failure.message}'))),
        (url) => setState(() => onUploaded(url)),
      );
    } finally {
      if (mounted) {
        setState(() {
          if (type == 'logo') {
            _isUploadingLogo = false;
          } else {
            _isUploadingBanner = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identity', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workspace Name', style: AppTypography.label),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Custom App Name (e.g. Acme Quiz)',
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Logo', style: AppTypography.label),
                          const SizedBox(height: 8),
                          _buildAssetUploader(
                            label: 'Upload Logo',
                            imageUrl: _logoUrl,
                            isLoading: _isUploadingLogo,
                            onTap: () => _pickAndUploadImage(
                                'logo', (url) => _logoUrl = url),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Login Banner', style: AppTypography.label),
                          const SizedBox(height: 8),
                          _buildAssetUploader(
                            label: 'Upload Banner',
                            imageUrl: _bannerUrl,
                            isLoading: _isUploadingBanner,
                            onTap: () => _pickAndUploadImage(
                                'banner', (url) => _bannerUrl = url),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Theme Colors', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          _buildColorPicker('Primary Color', _primaryColor,
              (c) => setState(() => _primaryColor = c)),
          const SizedBox(height: AppSpacing.md),
          _buildColorPicker('Secondary Color', _secondaryColor,
              (c) => setState(() => _secondaryColor = c)),
          const SizedBox(height: AppSpacing.md),
          _buildColorPicker('Accent Color', _accentColor,
              (c) => setState(() => _accentColor = c)),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'Save Branding Changes',
            onPressed: _isSaving ? null : _saveBranding,
            isLoading: _isSaving,
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildPreviewCard(),
        ],
      ),
    );
  }

  Widget _buildColorPicker(
      String label, Color currentColor, ValueChanged<Color> onSelected) {
    final colors = [
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF2DD4BF), // Teal
      const Color(0xFFF472B6), // Pink
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFEF4444), // Red
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF64748B), // Slate
    ];

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((color) {
              final isSelected = color == currentColor;
              return GestureDetector(
                onTap: () => onSelected(color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 8)
                          ]
                        : [],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetUploader({
    required String label,
    required String? imageUrl,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.white10),
          image: imageUrl != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                )
              : null,
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      imageUrl != null
                          ? Icons.edit_rounded
                          : Icons.cloud_upload_rounded,
                      color: Colors.white54),
                  const SizedBox(height: 4),
                  Text(imageUrl != null ? 'Change' : label,
                      style: AppTypography.label
                          .copyWith(fontSize: 10, color: Colors.white54)),
                ],
              ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Live Preview', style: AppTypography.label),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              colors: [_primaryColor, _secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: Center(
            child: Text(
              _nameController.text.isEmpty
                  ? 'Quiz Arena'
                  : _nameController.text,
              style: AppTypography.h1.copyWith(color: Colors.white),
            )
                .animate(key: ValueKey(_nameController.text))
                .fadeIn()
                .scale(curve: Curves.easeOutBack),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }
}
