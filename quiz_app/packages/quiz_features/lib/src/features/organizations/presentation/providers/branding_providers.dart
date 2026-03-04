import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/organization_providers.dart';

/// Provider that fetches the branding for the current active organization.
import 'package:quiz_domain/quiz_domain.dart';

final organizationBrandingProvider =
    FutureProvider<OrganizationBrandingEntity?>((ref) async {
  final activeOrg = ref.watch(activeWorkspaceProvider);
  if (activeOrg == null) return null;

  final repository = ref.watch(organizationRepositoryProvider);
  final result = await repository.getBranding(activeOrg.id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (branding) => branding,
  );
});

/// Provider for the current effective branding.
/// If no organization is active, it returns default branding.
final currentBrandingProvider = Provider<OrganizationBrandingEntity>((ref) {
  final brandingAsync = ref.watch(organizationBrandingProvider);

  return brandingAsync.maybeWhen(
    data: (branding) {
      if (branding != null) return branding;
      return _defaultBranding;
    },
    orElse: () => _defaultBranding,
  );
});

final _defaultBranding = OrganizationBrandingEntity(
  id: 'default',
  organizationId: 'default',
  primaryColor: const Color(0xFF8B5CF6),
  secondaryColor: const Color(0xFF2DD4BF),
  accentColor: const Color(0xFFF472B6),
  appNameOverride: 'Quiz Arena',
);
