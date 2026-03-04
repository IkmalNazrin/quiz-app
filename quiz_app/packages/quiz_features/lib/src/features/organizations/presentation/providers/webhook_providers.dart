import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/organization_providers.dart';

import 'package:quiz_domain/quiz_domain.dart';

final webhooksProvider =
    FutureProvider.family<List<WebhookEntity>, String>((ref, orgId) async {
  final repository = ref.watch(organizationRepositoryProvider);
  final result = await repository.getWebhooks(orgId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (webhooks) => webhooks,
  );
});

final webhookLogsProvider =
    FutureProvider.family<List<WebhookLogEntity>, String>((ref, orgId) async {
  final repository = ref.watch(organizationRepositoryProvider);
  final result = await repository.getWebhookLogs(orgId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (logs) => logs,
  );
});
