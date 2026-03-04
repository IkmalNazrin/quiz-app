import 'dart:io';

void main() async {
  final filesToRefactor = [
    'packages/quiz_features/lib/src/features/quiz/presentation/providers/quiz_provider.dart',
    'packages/quiz_features/lib/src/features/profile/presentation/providers/profile_provider.dart',
    'packages/quiz_features/lib/src/features/profile/presentation/manager/history_provider.dart',
    'packages/quiz_features/lib/src/features/privacy/presentation/providers/privacy_provider.dart',
    'packages/quiz_features/lib/src/features/leaderboard/presentation/providers/leaderboard_provider.dart',
    'packages/quiz_features/lib/src/features/game/presentation/providers/game_session_provider.dart',
    'packages/quiz_features/lib/src/features/auth/presentation/providers/organization_providers.dart',
    'packages/quiz_features/lib/src/features/auth/presentation/providers/auth_provider.dart',
    'packages/quiz_features/lib/src/features/challenge/presentation/providers/challenge_provider.dart',
    'packages/quiz_features/lib/src/features/ai/presentation/providers/ai_provider.dart',
    'packages/quiz_features/lib/src/features/analytics/presentation/providers/analytics_provider.dart',
    'packages/quiz_features/lib/src/core_features/providers/core_providers.dart',
  ];

  for (final filePath in filesToRefactor) {
    if (!File(filePath).existsSync()) continue;
    String content = await File(filePath).readAsString();

    // Remove the bad imports
    content = content.replaceAll("import 'package:quiz_infrastructure/quiz_infrastructure.dart';", "");
    content = content.replaceAll("import 'package:supabase_flutter/supabase_flutter.dart';", "");
    content = content.replaceAll("import 'package:supabase_flutter/supabase_flutter.dart' as supabase;", "");

    // Generic replacement for Impl instantiations within Providers
    final implRegex = RegExp(r"return\s+([A-Za-z0-9_]+Impl)\(.*?\);", dotAll: true);
    content = content.replaceAllMapped(implRegex, (match) {
      if (match.group(0)!.contains('Notifier')) return match.group(0)!; // skip notifiers if any
      return "throw UnimplementedError('Infrastructure injection required');";
    });
    
    // For specific cases like Supabase.instance.client
    content = content.replaceAll("return Supabase.instance.client;", "throw UnimplementedError('Infrastructure injection required');");

    await File(filePath).writeAsString(content);
    print('Refactored providers in $filePath');
  }
}
