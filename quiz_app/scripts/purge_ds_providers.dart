import 'dart:io';

void main() async {
  final filesToClean = [
    'packages/quiz_features/lib/src/features/quiz/presentation/providers/quiz_provider.dart',
    'packages/quiz_features/lib/src/features/profile/presentation/providers/profile_provider.dart',
    'packages/quiz_features/lib/src/features/auth/presentation/providers/auth_provider.dart',
    'packages/quiz_features/lib/src/features/auth/presentation/providers/organization_providers.dart',
    'packages/quiz_features/lib/src/features/challenge/presentation/providers/challenge_provider.dart',
    'packages/quiz_features/lib/src/features/leaderboard/presentation/providers/leaderboard_provider.dart',
    'packages/quiz_features/lib/src/core_features/providers/core_providers.dart',
  ];

  for (final filePath in filesToClean) {
    if (!File(filePath).existsSync()) continue;
    String content = await File(filePath).readAsString();

    final dsRegex = RegExp(r"final [a-zA-Z0-9_]+RemoteDataSourceProvider = Provider<[A-Za-z0-9_]+>\(\(ref\) \{.*?\}\);", dotAll: true);
    content = content.replaceAll(dsRegex, "");

    final dsRegex2 = RegExp(r"final [a-zA-Z0-9_]+RemoteDataSourceProvider = Provider<.*?UnimplementedError.*?\);", dotAll: true);
    content = content.replaceAll(dsRegex2, "");

    // Core providers manual stripping
    if (filePath.contains('core_providers.dart')) {
       final infraRegex = RegExp(r"final (supabaseClientProvider|appDatabaseProvider|auditServiceProvider|offlineSyncRepositoryProvider|performanceServiceProvider|loggerServiceProvider) = Provider<.*?>\(\(ref\) \{.*?\}\);", dotAll: true);
       content = content.replaceAll(infraRegex, "");
       // Fallback for simple
       content = content.replaceAll(RegExp(r"^.*SupabaseClient.*$", multiLine: true), "");
       content = content.replaceAll(RegExp(r"^.*AppDatabase.*$", multiLine: true), "");
       content = content.replaceAll(RegExp(r"^.*AuditService.*$", multiLine: true), "");
       content = content.replaceAll(RegExp(r"^.*DriftOfflineSyncRepository.*$", multiLine: true), "");
    }
    
    // Auth provider imports fixes
    content = content.replaceAll("import 'package:supabase_flutter/supabase_flutter.dart';", "");
    content = content.replaceAll("import 'package:quiz_infrastructure/quiz_infrastructure.dart';", "");

    await File(filePath).writeAsString(content);
    print('Cleaned $filePath');
  }
}
