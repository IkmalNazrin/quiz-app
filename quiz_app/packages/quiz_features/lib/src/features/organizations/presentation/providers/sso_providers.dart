import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/organization_providers.dart';

import 'package:quiz_domain/quiz_domain.dart';

final ssoConfigProvider =
    FutureProvider.family<OrganizationSSOConfigEntity?, String>(
        (ref, orgId) async {
  final repository = ref.watch(organizationRepositoryProvider);
  final result = await repository.getSSOConfig(orgId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (config) => config,
  );
});
