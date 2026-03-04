import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/organization_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Provider that determines the current user's role in the active organization.
///
/// Returns [AsyncValue<OrganizationRole?>].
/// Null means the user is not a member or there is no active workspace.
import 'package:quiz_domain/quiz_domain.dart';

final activeOrganizationRoleProvider =
    FutureProvider<OrganizationRole?>((ref) async {
  final activeOrg = ref.watch(activeWorkspaceProvider);
  final user = ref.watch(authStateProvider).value;

  if (activeOrg == null || user == null) return null;

  final repository = ref.watch(organizationRepositoryProvider);
  final membersResult = await repository.getOrganizationMembers(activeOrg.id);

  return membersResult.fold(
    (failure) => throw Exception(failure.message),
    (members) {
      try {
        final currentMember = members.firstWhere((m) => m.userId == user.id);
        return currentMember.role;
      } catch (_) {
        return null;
      }
    },
  );
});

/// Computes if the current user is an admin of the active organization.
final isOrganizationAdminProvider = Provider<bool>((ref) {
  final roleAsync = ref.watch(activeOrganizationRoleProvider);
  return roleAsync.maybeWhen(
    data: (role) => role == OrganizationRole.admin,
    orElse: () => false,
  );
});
