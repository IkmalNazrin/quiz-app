import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quiz_domain/quiz_domain.dart';

import 'package:quiz_features/quiz_features.dart';

final organizationRepositoryProvider = Provider<IOrganizationRepository>((ref) {
  throw UnimplementedError('Infrastructure injection required');
});

final userOrganizationsProvider =
    FutureProvider<List<OrganizationEntity>>((ref) async {
  final repository = ref.watch(organizationRepositoryProvider);
  final result = await repository.getUserOrganizations();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (orgs) => orgs,
  );
});

class WorkspaceNotifier extends StateNotifier<OrganizationEntity?> {
  WorkspaceNotifier() : super(null);

  void selectWorkspace(OrganizationEntity? org) {
    state = org;
  }
}

final activeWorkspaceProvider =
    StateNotifierProvider<WorkspaceNotifier, OrganizationEntity?>((ref) {
  return WorkspaceNotifier();
});

final organizationMembersProvider =
    FutureProvider.family<List<OrganizationMemberEntity>, String>(
        (ref, orgId) async {
  final repository = ref.watch(organizationRepositoryProvider);
  final result = await repository.getOrganizationMembers(orgId);
  return result.fold((l) => throw Exception(l.message), (r) => r);
});
